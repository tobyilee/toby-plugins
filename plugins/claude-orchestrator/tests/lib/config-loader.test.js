import { describe, it } from 'node:test';
import assert from 'node:assert/strict';
import { parseYamlFrontmatter, DEFAULT_CONFIG, loadConfig } from '../../lib/config-loader.js';

describe('parseYamlFrontmatter', () => {
  it('should parse simple key-value pairs', () => {
    const content = `---
name: test
version: 1
enabled: true
---
# Body`;
    const result = parseYamlFrontmatter(content);
    assert.equal(result.name, 'test');
    assert.equal(result.version, 1);
    assert.equal(result.enabled, true);
  });

  it('should parse nested objects', () => {
    const content = `---
agents:
  codex:
    enabled: true
    binary: codex
    timeout_ms: 300000
---`;
    const result = parseYamlFrontmatter(content);
    assert.equal(result.agents.codex.enabled, true);
    assert.equal(result.agents.codex.binary, 'codex');
    assert.equal(result.agents.codex.timeout_ms, 300000);
  });

  it('should parse inline arrays', () => {
    const content = `---
fallback_chain:
  - claude_subagent
  - codex
  - gemini
---`;
    const result = parseYamlFrontmatter(content);
    assert.deepEqual(result.fallback_chain, ['claude_subagent', 'codex', 'gemini']);
  });

  it('should return null for no frontmatter', () => {
    const result = parseYamlFrontmatter('# Just a heading\nSome text');
    assert.equal(result, null);
  });

  it('should handle empty string values', () => {
    const content = `---
model: ""
---`;
    const result = parseYamlFrontmatter(content);
    assert.equal(result.model, '');
  });

  it('should skip comment lines', () => {
    const content = `---
# This is a comment
name: test
# Another comment
value: 42
---`;
    const result = parseYamlFrontmatter(content);
    assert.equal(result.name, 'test');
    assert.equal(result.value, 42);
  });
});

describe('DEFAULT_CONFIG', () => {
  it('should have all required sections', () => {
    assert.ok(DEFAULT_CONFIG.agents);
    assert.ok(DEFAULT_CONFIG.routing);
    assert.ok(DEFAULT_CONFIG.fallback_chain);
    assert.ok(DEFAULT_CONFIG.fallback);
    assert.ok(DEFAULT_CONFIG.post_edit_review);
    assert.ok(DEFAULT_CONFIG.budget);
  });

  it('should have codex, gemini, claude_subagent agents', () => {
    assert.ok(DEFAULT_CONFIG.agents.codex);
    assert.ok(DEFAULT_CONFIG.agents.gemini);
    assert.ok(DEFAULT_CONFIG.agents.claude_subagent);
  });
});

describe('loadConfig', () => {
  it('should return defaults for non-existent directory', () => {
    const config = loadConfig('/nonexistent/path');
    assert.deepEqual(config, DEFAULT_CONFIG);
  });
});
