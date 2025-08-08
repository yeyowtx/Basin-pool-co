/**
 * Test ClickUp API Connection and Create Project Structure
 */

const https = require('https');
const { AUTOMATION_CONFIG } = require('./config.js');

const clickupApi = {
  baseUrl: AUTOMATION_CONFIG.clickup.baseUrl,
  headers: {
    'Authorization': AUTOMATION_CONFIG.clickup.apiToken,
    'Content-Type': 'application/json'
  },

  // Make API request
  request: (method, endpoint, data = null) => {
    return new Promise((resolve, reject) => {
      const options = {
        hostname: 'api.clickup.com',
        port: 443,
        path: `/api/v2${endpoint}`,
        method: method,
        headers: clickupApi.headers
      };

      const req = https.request(options, (res) => {
        let responseData = '';
        
        res.on('data', (chunk) => {
          responseData += chunk;
        });
        
        res.on('end', () => {
          try {
            const parsed = JSON.parse(responseData);
            if (res.statusCode >= 200 && res.statusCode < 300) {
              resolve(parsed);
            } else {
              reject(new Error(`API Error ${res.statusCode}: ${parsed.err || responseData}`));
            }
          } catch (e) {
            reject(new Error(`Parse Error: ${responseData}`));
          }
        });
      });

      req.on('error', (error) => {
        reject(error);
      });

      if (data) {
        req.write(JSON.stringify(data));
      }
      
      req.end();
    });
  },

  // Test connection
  testConnection: async () => {
    try {
      console.log('🔄 Testing ClickUp API connection...');
      const user = await clickupApi.request('GET', '/user');
      console.log(`✅ Connected to ClickUp as: ${user.user.username} (${user.user.email})`);
      return true;
    } catch (error) {
      console.error('❌ ClickUp connection failed:', error.message);
      return false;
    }
  },

  // Get space details
  getSpace: async () => {
    try {
      const spaceId = AUTOMATION_CONFIG.clickup.spaceId;
      console.log(`🔄 Getting space details for ID: ${spaceId}...`);
      const space = await clickupApi.request('GET', `/space/${spaceId}`);
      console.log(`✅ Space found: ${space.name}`);
      return space;
    } catch (error) {
      console.error('❌ Failed to get space:', error.message);
      return null;
    }
  },

  // Create folder for client project
  createProjectFolder: async (clientData) => {
    try {
      const spaceId = AUTOMATION_CONFIG.clickup.spaceId;
      const template = AUTOMATION_CONFIG.projectTemplate;
      
      const folderData = {
        name: template.name.replace('{{clientName}}', clientData.clientName),
        hidden: false
      };

      console.log(`🔄 Creating project folder: ${folderData.name}...`);
      const folder = await clickupApi.request('POST', `/space/${spaceId}/folder`, folderData);
      console.log(`✅ Project folder created: ${folder.id}`);
      return folder;
    } catch (error) {
      console.error('❌ Failed to create project folder:', error.message);
      return null;
    }
  },

  // Create list for tasks
  createTaskList: async (folderId, listName) => {
    try {
      const listData = {
        name: listName,
        content: 'GoHighLevel sub-account onboarding tasks',
        due_date_time: false,
        priority: true,
        assignee: AUTOMATION_CONFIG.clickup.userId,
        status: 'red'
      };

      console.log(`🔄 Creating task list: ${listName}...`);
      const list = await clickupApi.request('POST', `/folder/${folderId}/list`, listData);
      console.log(`✅ Task list created: ${list.id}`);
      return list;
    } catch (error) {
      console.error('❌ Failed to create task list:', error.message);
      return null;
    }
  }
};

// Test the complete setup
async function testSetup() {
  console.log('🚀 Starting ClickUp API test and setup...\n');

  // Test connection
  const connected = await clickupApi.testConnection();
  if (!connected) return;

  // Get space details
  const space = await clickupApi.getSpace();
  if (!space) return;

  // Create test project
  const testClient = {
    clientName: 'TEST CLIENT - Delete Me',
    projectType: 'test',
    subAccountId: 'test-123'
  };

  const folder = await clickupApi.createProjectFolder(testClient);
  if (!folder) return;

  const list = await clickupApi.createTaskList(folder.id, 'Onboarding Tasks');
  if (!list) return;

  console.log('\n✅ ClickUp setup test completed successfully!');
  console.log(`📋 Project URL: https://app.clickup.com/${AUTOMATION_CONFIG.clickup.spaceId.slice(0,8)}/v/f/${folder.id}`);
  
  // Clean up test project
  console.log('\n🧹 Cleaning up test project...');
  try {
    await clickupApi.request('DELETE', `/folder/${folder.id}`);
    console.log('✅ Test project cleaned up');
  } catch (error) {
    console.log('⚠️ Could not clean up test project - please delete manually');
  }
}

// Run the test
testSetup().catch(console.error);