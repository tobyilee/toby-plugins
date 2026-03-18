/**
 * Parse Codex JSONL output to extract assistant messages and token usage.
 *
 * @param {string} output - Raw JSONL output from codex exec --json
 * @returns {{ content: string, tokenUsage?: { input: number, output: number }, error?: string }}
 */
export function parseCodexJsonl(output) {
  const lines = output.trim().split('\n');
  let content = '';
  let tokenUsage = null;

  for (const line of lines) {
    try {
      const event = JSON.parse(line);

      if (event.type === 'item.completed' && event.item?.type === 'agent_message') {
        const textParts = (event.item.content || [])
          .filter(c => c.type === 'text')
          .map(c => c.text);
        content += textParts.join('\n');
      }

      if (event.type === 'turn.completed' && event.usage) {
        tokenUsage = {
          input: event.usage.input_tokens || 0,
          output: event.usage.output_tokens || 0,
        };
      }

      if (event.type === 'error') {
        return { content: '', error: event.message || 'Unknown Codex error' };
      }
    } catch {
      // Skip non-JSON lines
    }
  }

  return { content: sanitize(content), tokenUsage };
}

/**
 * Parse Gemini JSON output to extract response and usage stats.
 *
 * @param {string} output - Raw JSON output from gemini -p -o json
 * @returns {{ content: string, tokenUsage?: { input: number, output: number }, error?: string }}
 */
export function parseGeminiJson(output) {
  try {
    const data = JSON.parse(output.trim());

    if (data.error) {
      return { content: '', error: `${data.error.type}: ${data.error.message}` };
    }

    const content = data.response || data.text || '';
    let tokenUsage = null;

    if (data.usage) {
      const totalInput = Object.values(data.usage)
        .reduce((sum, m) => sum + (m.inputTokens || 0), 0);
      const totalOutput = Object.values(data.usage)
        .reduce((sum, m) => sum + (m.outputTokens || 0), 0);
      tokenUsage = { input: totalInput, output: totalOutput };
    }

    return { content: sanitize(content), tokenUsage };
  } catch {
    // If not valid JSON, return raw output as content
    return { content: sanitize(output.trim()), tokenUsage: null };
  }
}

/**
 * Parse Claude CLI JSONL output to extract result.
 *
 * @param {string} output - Raw JSONL from claude -p --output-format json
 * @returns {{ content: string, tokenUsage?: { input: number, output: number }, cost?: number, sessionId?: string, error?: string }}
 */
export function parseClaudeJsonl(output) {
  const lines = output.trim().split('\n');

  for (const line of lines) {
    try {
      const event = JSON.parse(line);

      if (event.type === 'result') {
        if (event.is_error) {
          return { content: '', error: event.result || 'Unknown Claude error' };
        }
        return {
          content: sanitize(event.result || ''),
          tokenUsage: event.usage ? {
            input: event.usage.input_tokens || 0,
            output: event.usage.output_tokens || 0,
          } : null,
          cost: event.total_cost_usd,
          sessionId: event.session_id,
        };
      }
    } catch {
      // Skip non-JSON lines
    }
  }

  return { content: sanitize(output.trim()), error: 'No result event found' };
}

/**
 * Sanitize output by masking potential sensitive information.
 */
function sanitize(text) {
  if (!text) return text;
  // Mask API key patterns
  return text
    .replace(/sk-[a-zA-Z0-9]{20,}/g, 'sk-***MASKED***')
    .replace(/AIza[a-zA-Z0-9_-]{35}/g, 'AIza***MASKED***')
    .replace(/ghp_[a-zA-Z0-9]{36}/g, 'ghp_***MASKED***')
    .replace(/gho_[a-zA-Z0-9]{36}/g, 'gho_***MASKED***')
    .replace(/Bearer [a-zA-Z0-9._-]{20,}/g, 'Bearer ***MASKED***');
}
