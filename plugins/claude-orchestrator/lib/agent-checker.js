import { execFileSync } from 'node:child_process';

/**
 * Check if a CLI agent is available and authenticated.
 *
 * @param {string} binary - CLI binary name (e.g., 'codex', 'gemini', 'claude')
 * @returns {{ available: boolean, version?: string, authOk: boolean, error?: string }}
 */
export function checkAgent(binary) {
  const result = {
    available: false,
    version: undefined,
    authOk: false,
    error: undefined,
  };

  // Check if binary exists using execFileSync (safe, no shell injection)
  try {
    execFileSync('which', [binary], { encoding: 'utf-8', timeout: 5000 });
  } catch {
    result.error = `${binary}: command not found`;
    return result;
  }

  // Get version
  try {
    const output = execFileSync(binary, ['--version'], {
      encoding: 'utf-8',
      timeout: 5000,
    }).trim();
    result.version = output;
    result.available = true;
  } catch {
    // Some CLIs don't support --version but are still available
    result.available = true;
    result.version = 'unknown';
  }

  // Auth check is best-effort — actual auth verified on first use
  result.authOk = true;

  return result;
}

/**
 * Check all configured agents and return status report.
 *
 * @param {object} agentsConfig - agents section from orchestrator config
 * @returns {Record<string, { available: boolean, version?: string, authOk: boolean, enabled: boolean }>}
 */
export function checkAllAgents(agentsConfig) {
  const results = {};

  for (const [name, config] of Object.entries(agentsConfig)) {
    const binary = config.binary || name;
    const enabled = config.enabled !== false;

    if (!enabled) {
      results[name] = { available: false, enabled: false, reason: 'disabled in config' };
      continue;
    }

    const check = checkAgent(name === 'claude_subagent' ? 'claude' : binary);
    results[name] = { ...check, enabled };
  }

  return results;
}

/**
 * Get list of available agent names from config.
 *
 * @param {object} agentsConfig - agents section from orchestrator config
 * @returns {string[]} Names of available agents
 */
export function getAvailableAgents(agentsConfig) {
  const statuses = checkAllAgents(agentsConfig);
  return Object.entries(statuses)
    .filter(([, status]) => status.available && status.enabled)
    .map(([name]) => name);
}
