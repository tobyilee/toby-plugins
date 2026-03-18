#!/usr/bin/env node

/**
 * Stop hook: Automatic fallback to another agent on rate limit/error.
 *
 * Behavior:
 * - Normal completion → exit 0 (passthrough)
 * - Rate limit / API error with read-only task → auto-fallback, exit 2
 * - Rate limit with write task → notification only, exit 2
 *
 * Exit codes:
 *   0 = stop normally
 *   2 = feed stderr content back to Claude
 */

import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { execFileSync } from 'node:child_process';

async function main() {
  // Read hook input from stdin
  let input;
  try {
    const raw = readFileSync(0, 'utf-8'); // fd 0 = stdin
    input = JSON.parse(raw);
  } catch {
    // If no valid JSON on stdin, just pass through
    process.exit(0);
  }

  // Check if stop hook is already active (prevent loops)
  if (input.stop_hook_active) {
    process.exit(0);
  }

  // Infer stop reason from last assistant message
  const lastMessage = input.last_assistant_message || '';
  const isRateLimit = /rate.?limit|429|too many requests|overloaded/i.test(lastMessage);
  const isApiError = /api.?error|500|503|service.?unavailable/i.test(lastMessage);

  // Normal completion — pass through
  if (!isRateLimit && !isApiError) {
    process.exit(0);
  }

  // Load config
  let config;
  try {
    const configPath = join(input.working_directory || process.cwd(), '.claude', 'orchestrator.local.md');
    readFileSync(configPath, 'utf-8');
    // Config loaded — use defaults for now (full parsing in config-loader.js)
    config = {
      fallback_chain: ['codex', 'gemini'],
      auto_fallback_intents: ['read', 'review', 'research'],
    };
  } catch {
    config = {
      fallback_chain: ['codex', 'gemini'],
      auto_fallback_intents: ['read', 'review', 'research'],
    };
  }

  // Determine if the last task was read-only (heuristic: no Edit/Write tool in recent history)
  const lastToolName = input.tool_name || '';
  const isWriteTask = /Edit|Write|Bash/i.test(lastToolName);

  if (isWriteTask) {
    // Write task — notification only, no auto-fallback
    const reason = isRateLimit ? 'rate limit' : 'API error';
    process.stderr.write(
      `Claude encountered a ${reason}. A write operation was in progress.\n` +
      `Would you like to continue with a different agent? ` +
      `Available fallback agents: ${config.fallback_chain.join(', ')}\n`
    );
    process.exit(2);
  }

  // Read-only task — attempt auto-fallback
  const fallbackAgent = config.fallback_chain[0];
  if (!fallbackAgent) {
    process.exit(0);
  }

  // Check if fallback agent is available
  try {
    const binary = fallbackAgent === 'claude_subagent' ? 'claude' : fallbackAgent;
    execFileSync('which', [binary], { encoding: 'utf-8', timeout: 3000 });
  } catch {
    process.stderr.write(
      `Claude encountered an error but fallback agent '${fallbackAgent}' is not available.\n`
    );
    process.exit(2);
  }

  const reason = isRateLimit ? 'rate limit' : 'API error';
  process.stderr.write(
    `Claude hit a ${reason}. Automatically falling back to ${fallbackAgent} ` +
    `for the current read-only task. Use /delegate to manually route tasks.\n`
  );
  process.exit(2);
}

main().catch(err => {
  process.stderr.write(`[orchestrator on-stop hook error] ${err.message}\n`);
  process.exit(0); // Don't block on hook errors
});
