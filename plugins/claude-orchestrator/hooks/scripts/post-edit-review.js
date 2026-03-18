#!/usr/bin/env node

/**
 * PostToolUse hook: Automatic code review after Edit/Write operations.
 *
 * Behavior based on config review_mode:
 * - "off": exit 0 (no review)
 * - "advisory": review + report findings via exit 0 (info only)
 * - "blocking": review + report findings via exit 2 (Claude must fix)
 *
 * Debouncing: Uses a timestamp file to avoid reviewing every single edit
 * in rapid succession.
 */

import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join, extname } from 'node:path';

async function main() {
  // Read hook input from stdin
  let input;
  try {
    const raw = readFileSync(0, 'utf-8');
    input = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  // Only process Edit and Write tools
  const toolName = input.tool_name;
  if (toolName !== 'Edit' && toolName !== 'Write') {
    process.exit(0);
  }

  // Load config
  const workDir = input.working_directory || process.cwd();
  let config;
  try {
    const configPath = join(workDir, '.claude', 'orchestrator.local.md');
    const content = readFileSync(configPath, 'utf-8');
    // Extract post_edit_review settings (simplified parsing)
    const enabledMatch = content.match(/post_edit_review:[\s\S]*?enabled:\s*(true|false)/);
    const modeMatch = content.match(/review_mode:\s*(\w+)/);
    const minLinesMatch = content.match(/min_changed_lines:\s*(\d+)/);
    const debounceMatch = content.match(/debounce_ms:\s*(\d+)/);

    config = {
      enabled: enabledMatch ? enabledMatch[1] === 'true' : false,
      review_mode: modeMatch ? modeMatch[1] : 'advisory',
      min_changed_lines: minLinesMatch ? parseInt(minLinesMatch[1]) : 10,
      debounce_ms: debounceMatch ? parseInt(debounceMatch[1]) : 2000,
      file_patterns: ['*.ts', '*.tsx', '*.py', '*.js'],
      high_risk_dirs: ['src/auth/', 'src/core/'],
    };
  } catch {
    config = { enabled: false, review_mode: 'off' };
  }

  // Check if review is enabled
  if (!config.enabled || config.review_mode === 'off') {
    process.exit(0);
  }

  // Get the file that was edited
  const filePath = input.tool_input?.file_path || '';
  if (!filePath) {
    process.exit(0);
  }

  // Check file extension against patterns
  const ext = extname(filePath);
  const matchesPattern = config.file_patterns.some(p => {
    const patExt = p.startsWith('*') ? p.slice(1) : p;
    return ext === patExt;
  });
  if (!matchesPattern) {
    process.exit(0);
  }

  // Debounce: check if we reviewed recently
  const debounceFile = join(workDir, '.claude', '.orchestrator-review-ts');
  try {
    if (existsSync(debounceFile)) {
      const lastReview = parseInt(readFileSync(debounceFile, 'utf-8').trim());
      const elapsed = Date.now() - lastReview;
      if (elapsed < config.debounce_ms) {
        process.exit(0); // Too soon, skip this review
      }
    }
  } catch {
    // Ignore debounce errors
  }

  // Update debounce timestamp
  try {
    writeFileSync(debounceFile, String(Date.now()));
  } catch {
    // Ignore write errors
  }

  // Check if file is in high-risk directory (lower threshold)
  const isHighRisk = config.high_risk_dirs.some(dir => filePath.includes(dir));
  const minLines = isHighRisk ? Math.max(1, Math.floor(config.min_changed_lines / 3)) : config.min_changed_lines;

  // Estimate change size from tool_input
  let changeSize = 0;
  if (toolName === 'Edit' && input.tool_input?.new_string) {
    changeSize = input.tool_input.new_string.split('\n').length;
  } else if (toolName === 'Write' && input.tool_input?.content) {
    changeSize = input.tool_input.content.split('\n').length;
  }

  if (changeSize < minLines) {
    process.exit(0); // Change too small to review
  }

  // Generate review feedback
  const feedback = [
    `[Orchestrator Review] File: ${filePath}`,
    `Change size: ~${changeSize} lines${isHighRisk ? ' (HIGH RISK directory)' : ''}`,
    `Consider reviewing: security implications, error handling, edge cases.`,
  ].join('\n');

  if (config.review_mode === 'advisory') {
    // Info only — stderr but exit 0 (doesn't block)
    process.stderr.write(feedback + '\n');
    process.exit(0);
  }

  if (config.review_mode === 'blocking') {
    // Blocking — exit 2 to feed feedback to Claude
    process.stderr.write(feedback + '\nPlease review and address any issues.\n');
    process.exit(2);
  }

  process.exit(0);
}

main().catch(() => {
  // Don't block on hook errors
  process.exit(0);
});
