-- Add verification fields to users table
-- First add columns as nullable
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_number VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS phone_verified BOOLEAN;
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_code VARCHAR(255);
ALTER TABLE users ADD COLUMN IF NOT EXISTS verification_code_expiry TIMESTAMP;

-- Update existing users to have default values
UPDATE users SET email_verified = false WHERE email_verified IS NULL;
UPDATE users SET phone_verified = false WHERE phone_verified IS NULL;

-- Now add NOT NULL constraints
ALTER TABLE users ALTER COLUMN email_verified SET NOT NULL;
ALTER TABLE users ALTER COLUMN phone_verified SET NOT NULL;
