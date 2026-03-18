import { readFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

/**
 * Default orchestrator configuration.
 */
const DEFAULT_CONFIG = {
  agents: {
    codex: {
      enabled: true,
      binary: 'codex',
      default_model: '',
      sandbox: 'workspace-write',
      timeout_ms: 300000,
      max_concurrent: 3,
    },
    gemini: {
      enabled: true,
      binary: 'gemini',
      default_model: '',
      sandbox: true,
      yolo: true,
      timeout_ms: 300000,
      max_concurrent: 2,
    },
    claude_subagent: {
      enabled: true,
      default_model: 'sonnet',
      permission_mode: 'dontAsk',
      disable_skills: true,
      no_session_persistence: true,
      max_budget_usd: 1.0,
    },
  },
  routing: {
    large_context: 'gemini',
    fast_generation: 'codex',
    complex_reasoning: 'claude_subagent',
    simple_edit: 'codex',
    review: 'gemini',
    documentation: 'claude_subagent',
    testing: 'codex',
    default: 'claude_subagent',
  },
  fallback_chain: ['claude_subagent', 'codex', 'gemini'],
  fallback: {
    auto_fallback_intents: ['read', 'review', 'research'],
    require_confirmation_intents: ['write', 'refactor'],
  },
  post_edit_review: {
    enabled: false,
    review_mode: 'advisory',
    agent: 'codex',
    file_patterns: ['*.ts', '*.tsx', '*.py', '*.js'],
    min_changed_lines: 10,
    high_risk_dirs: ['src/auth/', 'src/core/'],
    debounce_ms: 2000,
  },
  budget: {
    max_concurrent_agents: 5,
    max_delegation_depth: 2,
  },
};

/**
 * Parse YAML frontmatter from a markdown file.
 * Returns the parsed YAML object, or null if no frontmatter found.
 */
function parseYamlFrontmatter(content) {
  const match = content.match(/^---\n([\s\S]*?)\n---/);
  if (!match) return null;

  // Simple YAML parser for our config structure
  // Handles: scalars, arrays, nested objects (2 levels)
  const yaml = match[1];
  return parseSimpleYaml(yaml);
}

/**
 * Minimal YAML parser sufficient for orchestrator config.
 * Uses stack of { obj, key, indent } frames to track nesting.
 */
function parseSimpleYaml(text) {
  const lines = text.split('\n');
  const result = {};
  // Stack: [{ obj, key, indent }]
  // obj = the object we're writing keys into
  // key = the last key written at this level
  const stack = [{ obj: result, key: null, indent: -2 }];

  for (const line of lines) {
    if (line.trim() === '' || line.trim().startsWith('#')) continue;

    const lineIndent = line.search(/\S/);
    const trimmed = line.trim();

    // Pop stack back to correct nesting level
    while (stack.length > 1 && stack[stack.length - 1].indent >= lineIndent) {
      stack.pop();
    }

    const frame = stack[stack.length - 1];

    // Array item: "- value"
    if (trimmed.startsWith('- ')) {
      const value = trimmed.slice(2).trim();
      // Array items belong to the parent frame's last key
      // We were pushed into an empty {} by "key:\n", need to go up one level
      const parentFrame = stack.length >= 2 ? stack[stack.length - 2] : frame;
      const arrayKey = parentFrame.key;
      if (arrayKey && parentFrame.obj[arrayKey] !== undefined) {
        if (!Array.isArray(parentFrame.obj[arrayKey])) {
          parentFrame.obj[arrayKey] = [];
        }
        parentFrame.obj[arrayKey].push(parseValue(value));
      }
      continue;
    }

    // Key: value pair
    const colonIdx = trimmed.indexOf(':');
    if (colonIdx === -1) continue;

    const key = trimmed.slice(0, colonIdx).trim();
    const rawValue = trimmed.slice(colonIdx + 1).trim();

    if (rawValue === '' || rawValue.startsWith('#')) {
      // Nested object (or future array — will convert on first "- item")
      frame.obj[key] = {};
      frame.key = key;
      stack.push({ obj: frame.obj[key], key: null, indent: lineIndent });
    } else if (rawValue.startsWith('[')) {
      frame.obj[key] = parseInlineArray(rawValue);
      frame.key = key;
    } else {
      frame.obj[key] = parseValue(rawValue);
      frame.key = key;
    }
  }

  return result;
}

function parseValue(raw) {
  if (raw === '' || raw === '~' || raw === 'null') return null;
  if (raw === 'true') return true;
  if (raw === 'false') return false;
  if (/^-?\d+$/.test(raw)) return parseInt(raw, 10);
  if (/^-?\d+\.\d+$/.test(raw)) return parseFloat(raw);
  // Strip quotes
  if ((raw.startsWith('"') && raw.endsWith('"')) || (raw.startsWith("'") && raw.endsWith("'"))) {
    return raw.slice(1, -1);
  }
  // Strip inline comment
  const commentIdx = raw.indexOf('#');
  if (commentIdx > 0) return parseValue(raw.slice(0, commentIdx).trim());
  return raw;
}

function parseInlineArray(raw) {
  if (raw === '[]') return [];
  // Parse ["a", "b", "c"] style
  const match = raw.match(/^\[(.*)\]$/);
  if (match) {
    return match[1].split(',').map(s => parseValue(s.trim()));
  }
  return [];
}

/**
 * Deep merge source into target. Source values override target.
 */
function deepMerge(target, source) {
  const result = { ...target };
  for (const key of Object.keys(source)) {
    if (source[key] && typeof source[key] === 'object' && !Array.isArray(source[key])) {
      result[key] = deepMerge(target[key] || {}, source[key]);
    } else {
      result[key] = source[key];
    }
  }
  return result;
}

/**
 * Load orchestrator config from .claude/orchestrator.local.md.
 * Falls back to defaults if file doesn't exist.
 *
 * @param {string} [workingDir] - Project root directory
 * @returns {object} Merged config (defaults + file overrides)
 */
export function loadConfig(workingDir) {
  const dir = workingDir || process.cwd();
  const configPath = join(dir, '.claude', 'orchestrator.local.md');

  if (!existsSync(configPath)) {
    return { ...DEFAULT_CONFIG };
  }

  try {
    const content = readFileSync(configPath, 'utf-8');
    const parsed = parseYamlFrontmatter(content);
    if (!parsed) return { ...DEFAULT_CONFIG };
    return deepMerge(DEFAULT_CONFIG, parsed);
  } catch (err) {
    console.error(`[orchestrator] Config load error: ${err.message}`);
    return { ...DEFAULT_CONFIG };
  }
}

export { DEFAULT_CONFIG, parseYamlFrontmatter };
