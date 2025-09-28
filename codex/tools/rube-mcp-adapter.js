#!/usr/bin/env node

/**
 * Rube MCP Adapter for OpenAI Codex
 * 
 * This adapter bridges Rube's HTTP-based MCP server to Codex's stdio transport requirement.
 * It converts between stdio and HTTP protocols to enable Rube toolkit integration with Codex.
 */

const { spawn } = require('child_process');
const http = require('http');
const https = require('https');

class RubeMCPAdapter {
  constructor() {
    this.rubeEndpoint = process.env.RUBE_ENDPOINT || 'https://api.rube.app';
    this.authToken = process.env.RUBE_AUTH_TOKEN;
    this.setupStdioInterface();
  }

  setupStdioInterface() {
    // Handle stdio communication with Codex
    process.stdin.setEncoding('utf8');
    process.stdin.on('data', (data) => {
      this.handleCodexMessage(data.trim());
    });

    // Send initial capabilities
    this.sendToCodex({
      jsonrpc: '2.0',
      method: 'initialize',
      params: {
        protocolVersion: '2024-11-05',
        capabilities: {
          tools: {},
          resources: {},
          prompts: {}
        },
        serverInfo: {
          name: 'rube-mcp-adapter',
          version: '1.0.0'
        }
      }
    });
  }

  async handleCodexMessage(message) {
    try {
      const request = JSON.parse(message);
      
      switch (request.method) {
        case 'tools/list':
          await this.handleToolsList(request);
          break;
        case 'tools/call':
          await this.handleToolCall(request);
          break;
        case 'resources/list':
          await this.handleResourcesList(request);
          break;
        case 'resources/read':
          await this.handleResourceRead(request);
          break;
        default:
          this.sendError(request.id, -32601, 'Method not found');
      }
    } catch (error) {
      console.error('Error handling Codex message:', error);
      this.sendError(null, -32700, 'Parse error');
    }
  }

  async handleToolsList(request) {
    try {
      // Forward to Rube HTTP API
      const tools = await this.makeRubeRequest('/tools/list', 'GET');
      
      this.sendToCodex({
        jsonrpc: '2.0',
        id: request.id,
        result: {
          tools: tools || []
        }
      });
    } catch (error) {
      this.sendError(request.id, -32603, 'Internal error');
    }
  }

  async handleToolCall(request) {
    try {
      const { name, arguments: args } = request.params;
      
      // Forward tool call to Rube
      const result = await this.makeRubeRequest('/tools/call', 'POST', {
        name,
        arguments: args
      });

      this.sendToCodex({
        jsonrpc: '2.0',
        id: request.id,
        result: {
          content: result.content || [],
          isError: result.isError || false
        }
      });
    } catch (error) {
      this.sendError(request.id, -32603, 'Tool call failed');
    }
  }

  async handleResourcesList(request) {
    try {
      const resources = await this.makeRubeRequest('/resources/list', 'GET');
      
      this.sendToCodex({
        jsonrpc: '2.0',
        id: request.id,
        result: {
          resources: resources || []
        }
      });
    } catch (error) {
      this.sendError(request.id, -32603, 'Internal error');
    }
  }

  async handleResourceRead(request) {
    try {
      const { uri } = request.params;
      const resource = await this.makeRubeRequest(`/resources/read?uri=${encodeURIComponent(uri)}`, 'GET');
      
      this.sendToCodex({
        jsonrpc: '2.0',
        id: request.id,
        result: {
          contents: resource.contents || []
        }
      });
    } catch (error) {
      this.sendError(request.id, -32603, 'Resource read failed');
    }
  }

  async makeRubeRequest(path, method, body = null) {
    return new Promise((resolve, reject) => {
      const url = new URL(path, this.rubeEndpoint);
      const options = {
        method,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.authToken}`
        }
      };

      const req = (url.protocol === 'https:' ? https : http).request(url, options, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const result = JSON.parse(data);
            resolve(result);
          } catch (error) {
            reject(error);
          }
        });
      });

      req.on('error', reject);

      if (body) {
        req.write(JSON.stringify(body));
      }
      
      req.end();
    });
  }

  sendToCodex(message) {
    process.stdout.write(JSON.stringify(message) + '\n');
  }

  sendError(id, code, message) {
    this.sendToCodex({
      jsonrpc: '2.0',
      id,
      error: {
        code,
        message
      }
    });
  }
}

// Initialize the adapter
new RubeMCPAdapter();

// Handle process termination
process.on('SIGINT', () => {
  process.exit(0);
});

process.on('SIGTERM', () => {
  process.exit(0);
});
