#!/usr/bin/env bun

import { exec } from 'child_process';
import { promisify } from 'util';

const execAsync = promisify(exec);

async function openPR() {
  try {
    // Get current branch
    const { stdout: branchOutput } = await execAsync('git rev-parse --abbrev-ref HEAD');
    const currentBranch = branchOutput.trim();
    
    if (currentBranch === 'main' || currentBranch === 'master') {
      console.error('❌ Cannot create PR from main/master branch');
      process.exit(1);
    }

    // Get remote URL
    const { stdout: remoteOutput } = await execAsync('git remote get-url origin');
    const remoteUrl = remoteOutput.trim();
    
    // Convert git URL to https URL
    let githubUrl = remoteUrl;
    
    // Handle SSH format: git@github.com:user/repo.git
    if (githubUrl.startsWith('git@')) {
      githubUrl = githubUrl.replace(/^git@([^:]+):/, 'https://$1/');
    }
    
    // Handle git protocol: git://github.com/user/repo.git
    if (githubUrl.startsWith('git://')) {
      githubUrl = githubUrl.replace(/^git:\/\//, 'https://');
    }
    
    // Remove .git suffix
    githubUrl = githubUrl.replace(/\.git$/, '');
    
    if (!githubUrl.includes('github.com')) {
      console.error('❌ Not a GitHub repository');
      process.exit(1);
    }

    // Get default branch (main or master)
    let defaultBranch = 'main';
    try {
      const { stdout: defaultBranchOutput } = await execAsync(
        'git symbolic-ref refs/remotes/origin/HEAD | sed "s@^refs/remotes/origin/@@"'
      );
      defaultBranch = defaultBranchOutput.trim() || 'main';
    } catch {
      // Fallback to main
      defaultBranch = 'main';
    }

    // Construct PR URL
    const prUrl = `${githubUrl}/compare/${defaultBranch}...${currentBranch}?expand=1`;
    
    console.log(`🚀 Opening PR for branch: ${currentBranch}`);
    console.log(`📝 Target branch: ${defaultBranch}`);
    console.log(`🔗 ${prUrl}`);
    
    // Open in browser
    await execAsync(`open "${prUrl}"`);
    
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

openPR();

