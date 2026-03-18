#!/usr/bin/env node

/**
 * Install the claude-orchestrator plugin to ~/.claude/plugins/.
 *
 * Usage:
 *   npx @anthropic-ai/claude-orchestrator install
 *   node bin/install.js
 */

import { cpSync, existsSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const pluginRoot = join(__dirname, '..');
const targetDir = join(process.env.HOME || '~', '.claude', 'plugins', 'local', 'claude-orchestrator');

function main() {
  console.log('Installing claude-orchestrator plugin...\n');

  // Create target directory
  mkdirSync(targetDir, { recursive: true });

  // Copy plugin files
  const dirs = ['.claude-plugin', 'skills', 'agents', 'commands', 'hooks', 'lib'];
  for (const dir of dirs) {
    const src = join(pluginRoot, dir);
    if (existsSync(src)) {
      cpSync(src, join(targetDir, dir), { recursive: true });
      console.log(`  ✓ Copied ${dir}/`);
    }
  }

  console.log(`\nPlugin installed to: ${targetDir}`);
  console.log('\nNext steps:');
  console.log('  1. Restart Claude Code to load the plugin');
  console.log('  2. Run /doctor to verify agent availability');
  console.log('  3. Run /orchestrator-init to create project config');
  console.log('  4. Try: "delegate this code review to codex"');
}

main();
