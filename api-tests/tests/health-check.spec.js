const { test, expect } = require('@playwright/test');

test.describe('Backend Health Check', () => {
  const baseURL = 'http://localhost:8080';

  test('should verify backend is running', async ({ request }) => {
    const response = await request.get(`${baseURL}/actuator/health`);
    
    if (response.status() === 404) {
      // If actuator health endpoint is not available, try a simple endpoint
      const simpleResponse = await request.get(`${baseURL}/api/v1/users`);
      // We expect 401 (unauthorized) which means the endpoint exists
      expect([401, 403].includes(simpleResponse.status())).toBeTruthy();
      console.log('✅ Backend is running - API endpoints are accessible');
    } else {
      expect(response.status()).toBe(200);
      const health = await response.json();
      expect(health.status).toBe('UP');
      console.log('✅ Backend health check passed:', health);
    }
  });

  test('should verify database connection', async ({ request }) => {
    // Try to access H2 console to verify database is working
    const response = await request.get(`${baseURL}/h2-console`);
    expect(response.status()).toBe(200);
    console.log('✅ H2 database console is accessible');
  });

  test('should verify API endpoints are secured', async ({ request }) => {
    const protectedEndpoints = [
      '/api/v1/users',
      '/api/v1/artists',
      '/api/v1/songs',
      '/api/v1/requests'
    ];

    for (const endpoint of protectedEndpoints) {
      const response = await request.get(`${baseURL}${endpoint}`);
      expect([401, 403].includes(response.status())).toBeTruthy();
      console.log(`✅ ${endpoint} is properly secured (status: ${response.status()})`);
    }
  });

  test('should verify public endpoints are accessible', async ({ request }) => {
    const publicEndpoints = [
      '/api/v1/users/signup',
      '/api/v1/users/login'
    ];

    for (const endpoint of publicEndpoints) {
      const response = await request.post(`${baseURL}${endpoint}`, {
        data: {}
      });
      // We expect 400 (bad request) for empty data, not 401/403
      expect(![401, 403].includes(response.status())).toBeTruthy();
      console.log(`✅ ${endpoint} is publicly accessible (status: ${response.status()})`);
    }
  });
});
