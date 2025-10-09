# How to Add Test Earnings Data

## Why Total Earnings Shows KES 0.00

The earnings system calculates total earnings from:
1. **Tips** - Money sent by fans as tips
2. **Accepted Song Requests** - Payment for accepted song requests

If you're seeing KES 0.00, it means there are no tips or accepted song requests in the database yet.

---

## Option 1: Add Test Data via SQL (Recommended for Testing)

### Step 1: Find Your DJ User ID

1. Start the backend server
2. Login as a DJ user in the app
3. Check the backend logs or database to find your user ID

Or run this SQL query:
```sql
SELECT id, email_address, full_name FROM users WHERE role_id = (SELECT id FROM roles WHERE role_name = 'DJ');
```

### Step 2: Add Sample Tip Payments

Replace `YOUR_DJ_USER_ID` with your actual DJ user ID:

```sql
-- Add sample tips
INSERT INTO tip_payments (id, dj_id, fan_id, amount, transaction_date, transaction_id, payment_method, status, message, created_at)
VALUES 
  (RANDOM_UUID(), 'YOUR_DJ_USER_ID', NULL, 500.00, NOW(), 'TIP001', 'MPESA', 'COMPLETED', 'Great music!', NOW()),
  (RANDOM_UUID(), 'YOUR_DJ_USER_ID', NULL, 300.00, NOW(), 'TIP002', 'MPESA', 'COMPLETED', 'Love your set!', NOW()),
  (RANDOM_UUID(), 'YOUR_DJ_USER_ID', NULL, 200.00, NOW(), 'TIP003', 'MPESA', 'COMPLETED', 'Keep it up!', NOW());
```

### Step 3: Add Sample Song Request Payments

First, create a sample song request:
```sql
-- Add a sample song request
INSERT INTO requests (id, user_id, dj_id, song_title, artist_name, status, created_at, updated_at)
VALUES 
  (RANDOM_UUID(), NULL, 'YOUR_DJ_USER_ID', 'Test Song', 'Test Artist', 'ACCEPTED', NOW(), NOW());
```

Then add the payment for it:
```sql
-- Add payment for the request (use the request ID from above)
INSERT INTO requests_payment (id, request_id, amount, transaction_date, transaction_id, payment_method, status, created_at)
VALUES 
  (RANDOM_UUID(), 'REQUEST_ID_FROM_ABOVE', 250.00, NOW(), 'REQ001', 'MPESA', 'COMPLETED', NOW());
```

### Step 4: Refresh the App

Pull down to refresh the earnings tab, and you should see:
- **Total Earnings**: KES 1,250.00 (500 + 300 + 200 + 250)
- **Tips**: KES 1,000.00
- **Song Requests**: KES 250.00
- **Available for Payout**: KES 1,250.00

---

## Option 2: Use the App to Generate Earnings (Requires Full Setup)

### For Tips:
1. Login as a **Fan** user
2. Find a DJ
3. Send a tip to the DJ
4. The tip will appear in the DJ's earnings

### For Song Requests:
1. Login as a **Fan** user
2. Find a DJ
3. Submit a song request with payment
4. Login as the **DJ**
5. Accept the song request
6. The payment will appear in the DJ's earnings

---

## Option 3: Create a Test Data Seeder (For Development)

You can create a data seeder class in the backend to automatically populate test data:

### Create: `backend/src/main/java/com/spinwish/backend/config/TestDataSeeder.java`

```java
@Component
@Profile("dev") // Only run in development
public class TestDataSeeder implements CommandLineRunner {
    
    @Autowired
    private UsersRepository usersRepository;
    
    @Autowired
    private TipPaymentsRepository tipPaymentsRepository;
    
    @Autowired
    private RequestsPaymentRepository requestsPaymentRepository;
    
    @Override
    public void run(String... args) throws Exception {
        // Find a DJ user
        Users dj = usersRepository.findAll().stream()
            .filter(u -> "DJ".equals(u.getRole().getRoleName()))
            .findFirst()
            .orElse(null);
            
        if (dj == null) {
            System.out.println("No DJ user found. Skipping test data seeding.");
            return;
        }
        
        // Check if test data already exists
        if (tipPaymentsRepository.count() > 0) {
            System.out.println("Test data already exists. Skipping seeding.");
            return;
        }
        
        // Add sample tips
        TipPayments tip1 = new TipPayments();
        tip1.setDj(dj);
        tip1.setAmount(500.0);
        tip1.setTransactionDate(LocalDateTime.now());
        tip1.setTransactionId("TEST_TIP_001");
        tip1.setPaymentMethod("MPESA");
        tip1.setStatus("COMPLETED");
        tip1.setMessage("Test tip 1");
        tipPaymentsRepository.save(tip1);
        
        TipPayments tip2 = new TipPayments();
        tip2.setDj(dj);
        tip2.setAmount(300.0);
        tip2.setTransactionDate(LocalDateTime.now());
        tip2.setTransactionId("TEST_TIP_002");
        tip2.setPaymentMethod("MPESA");
        tip2.setStatus("COMPLETED");
        tip2.setMessage("Test tip 2");
        tipPaymentsRepository.save(tip2);
        
        System.out.println("Test data seeded successfully!");
        System.out.println("DJ: " + dj.getFullName() + " now has KES 800.00 in earnings");
    }
}
```

Then restart the backend server with the `dev` profile:
```bash
./mvnw spring-boot:run -Dspring-boot.run.profiles=dev
```

---

## Quick SQL Script for H2 Database

If you're using H2 database (default for development), you can access the H2 console:

1. Go to: `http://localhost:8080/h2-console`
2. JDBC URL: `jdbc:h2:mem:testdb` (or check your application.properties)
3. Username: `sa`
4. Password: (leave empty or check your application.properties)

Then run this complete script:

```sql
-- Find your DJ user ID first
SELECT id, email_address, full_name FROM users WHERE role_id IN (SELECT id FROM roles WHERE role_name = 'DJ');

-- Replace 'YOUR_DJ_ID_HERE' with the actual ID from above
-- Add tips
INSERT INTO tip_payments (id, dj_id, amount, transaction_date, transaction_id, payment_method, status, message, created_at)
VALUES 
  (RANDOM_UUID(), 'YOUR_DJ_ID_HERE', 500.00, CURRENT_TIMESTAMP, 'TIP001', 'MPESA', 'COMPLETED', 'Great music!', CURRENT_TIMESTAMP),
  (RANDOM_UUID(), 'YOUR_DJ_ID_HERE', 300.00, CURRENT_TIMESTAMP, 'TIP002', 'MPESA', 'COMPLETED', 'Love your set!', CURRENT_TIMESTAMP),
  (RANDOM_UUID(), 'YOUR_DJ_ID_HERE', 200.00, CURRENT_TIMESTAMP, 'TIP003', 'MPESA', 'COMPLETED', 'Keep it up!', CURRENT_TIMESTAMP),
  (RANDOM_UUID(), 'YOUR_DJ_ID_HERE', 150.00, CURRENT_TIMESTAMP, 'TIP004', 'MPESA', 'COMPLETED', 'Amazing!', CURRENT_TIMESTAMP);

-- Verify the data
SELECT * FROM tip_payments WHERE dj_id = 'YOUR_DJ_ID_HERE';
```

---

## Verify Earnings in the App

After adding test data:

1. **Open the app**
2. **Login as the DJ user**
3. **Go to Earnings Tab**
4. **Pull down to refresh**

You should now see:
- ✅ Total Earnings: KES 1,150.00
- ✅ Tips: KES 1,150.00
- ✅ Available for Payout: KES 1,150.00

---

## Troubleshooting

### Still showing KES 0.00?

1. **Check the backend logs** for any errors
2. **Verify the data was inserted**:
   ```sql
   SELECT COUNT(*) FROM tip_payments WHERE dj_id = 'YOUR_DJ_ID_HERE';
   ```
3. **Check the API response**:
   - Open browser dev tools
   - Go to Network tab
   - Refresh the earnings page
   - Check the response from `/api/v1/earnings/me/summary`

4. **Verify you're logged in as the correct DJ**:
   - Check the JWT token
   - Verify the email matches the DJ user

### Backend returns error?

Check the backend console for error messages. Common issues:
- DJ user not found
- Database connection issues
- Authentication token expired

---

## Production Considerations

In production:
- Earnings come from real transactions
- Tips are sent by fans through the app
- Song requests are paid for and accepted by DJs
- No manual data insertion needed

For testing/development:
- Use the SQL scripts above to add test data
- Or create a data seeder class
- Or use the app's full flow to generate real transactions

