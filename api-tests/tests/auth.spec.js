const { test, expect } = require('@playwright/test');

test.describe('Authentication API Tests', () => {
  const baseURL = 'http://localhost:8080/api/v1';
  let authToken = '';
  let userId = '';

  test.beforeAll(async ({ request }) => {
    // Create a role first (required for user creation)
    const roleResponse = await request.post(`${baseURL}/roles`, {
      data: {
        roleName: 'CLIENT'
      }
    });
    expect(roleResponse.ok()).toBeTruthy();
  });

  test('should create a new user account', async ({ request }) => {
    const response = await request.post(`${baseURL}/users/signup`, {
      data: {
        emailAddress: 'test@example.com',
        username: 'testuser',
        password: 'password123',
        roleName: 'CLIENT'
      }
    });

    expect(response.status()).toBe(201);
    const responseBody = await response.json();

    expect(responseBody).toHaveProperty('emailAddress', 'test@example.com');
    expect(responseBody).toHaveProperty('username', 'testuser');
    
    console.log('User created successfully:', responseBody);
  });

  test('should login with valid credentials', async ({ request }) => {
    const response = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: 'test@example.com',
        password: 'password123'
      }
    });

    expect(response.status()).toBe(200);
    const responseBody = await response.json();

    expect(responseBody).toHaveProperty('token');
    expect(responseBody).toHaveProperty('userDetails');
    expect(responseBody.userDetails).toHaveProperty('emailAddress', 'test@example.com');

    authToken = responseBody.token;
    console.log('Login successful:', responseBody);
  });

  test('should fail login with invalid credentials', async ({ request }) => {
    const response = await request.post(`${baseURL}/users/login`, {
      data: {
        emailAddress: 'test@example.com',
        password: 'wrongpassword'
      }
    });

    expect(response.status()).toBe(401);
  });

  test('should access protected endpoint with valid token', async ({ request }) => {
    const response = await request.get(`${baseURL}/users`, {
      headers: {
        'Authorization': `Bearer ${authToken}`
      }
    });

    expect(response.status()).toBe(200);
    const users = await response.json();
    expect(Array.isArray(users)).toBeTruthy();
    console.log('Protected endpoint accessed successfully');
  });

  test('should fail to access protected endpoint without token', async ({ request }) => {
    const response = await request.get(`${baseURL}/users`);
    expect(response.status()).toBe(401);
  });

  test('should fail to access protected endpoint with invalid token', async ({ request }) => {
    const response = await request.get(`${baseURL}/users`, {
      headers: {
        'Authorization': 'Bearer invalid-token'
      }
    });
    expect(response.status()).toBe(401);
  });
});
