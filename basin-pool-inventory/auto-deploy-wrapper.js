#!/usr/bin/env node

/**
 * Basin Pool Co. - Auto-Deploy Wrapper
 * 
 * This script wraps git commands to automatically deploy to Netlify
 * whenever commits are made during development sessions.
 */

const { exec, spawn } = require('child_process');
const path = require('path');

// Configuration
const NETLIFY_URL = 'https://neon-kheer-4be3e9.netlify.app';
const REPO_ORIGIN = 'origin';
const BRANCH = 'main';

/**
 * Execute shell command and return promise
 */
function execPromise(command, options = {}) {
    return new Promise((resolve, reject) => {
        exec(command, options, (error, stdout, stderr) => {
            if (error) {
                reject({ error, stderr });
            } else {
                resolve(stdout.trim());
            }
        });
    });
}

/**
 * Check if we're in a git repository
 */
async function isGitRepo() {
    try {
        await execPromise('git rev-parse --git-dir');
        return true;
    } catch {
        return false;
    }
}

/**
 * Check if there are uncommitted changes
 */
async function hasChanges() {
    try {
        const status = await execPromise('git status --porcelain');
        return status.length > 0;
    } catch {
        return false;
    }
}

/**
 * Check if there are unpushed commits
 */
async function hasUnpushedCommits() {
    try {
        const count = await execPromise(`git rev-list --count HEAD ^${REPO_ORIGIN}/${BRANCH} 2>/dev/null || echo "1"`);
        return parseInt(count) > 0;
    } catch {
        return true; // Assume we need to push if we can't check
    }
}

/**
 * Auto-deploy function
 */
async function autoDeploy(commitMessage = null) {
    console.log('🚀 Basin Pool Co. - Auto Deploy');
    console.log('================================');
    
    try {
        // Check if we're in a git repository
        if (!(await isGitRepo())) {
            console.log('❌ Error: Not in a git repository');
            return false;
        }
        
        // Stage and commit changes if any exist
        if (await hasChanges()) {
            console.log('📝 Staging changes...');
            await execPromise('git add .');
            
            const message = commitMessage || 'Auto-deploy: Basin Pool inventory updates';
            const fullMessage = `${message}

🤖 Generated with [Claude Code](https://claude.ai/code)

Co-Authored-By: Claude <noreply@anthropic.com>`;
            
            console.log('💾 Committing changes...');
            await execPromise(`git commit -m "${fullMessage}"`);
        } else {
            console.log('ℹ️  No uncommitted changes');
        }
        
        // Push to GitHub if there are unpushed commits
        if (await hasUnpushedCommits()) {
            console.log('⬆️  Pushing to GitHub...');
            await execPromise(`git push ${REPO_ORIGIN} ${BRANCH}`);
            
            console.log('✅ Successfully deployed to GitHub!');
            console.log(`🌐 Netlify will build and deploy automatically`);
            console.log(`📱 Live at: ${NETLIFY_URL}`);
            console.log('⏱️  Deployment takes ~2-5 minutes');
            
            return true;
        } else {
            console.log('ℹ️  No new commits to push');
            console.log(`🌐 App is up to date: ${NETLIFY_URL}`);
            return false;
        }
        
    } catch (error) {
        console.error('❌ Deploy failed:', error.stderr || error.message);
        return false;
    }
}

// Export for use as module
module.exports = { autoDeploy };

// If run directly, execute auto-deploy
if (require.main === module) {
    const commitMessage = process.argv[2];
    autoDeploy(commitMessage).then(deployed => {
        process.exit(deployed ? 0 : 1);
    });
}