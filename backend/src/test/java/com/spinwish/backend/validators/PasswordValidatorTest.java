package com.spinwish.backend.validators;

import jakarta.validation.ConstraintValidatorContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PasswordValidatorTest {

    private PasswordValidator passwordValidator;

    @Mock
    private ConstraintValidatorContext context;

    @Mock
    private ConstraintValidatorContext.ConstraintViolationBuilder violationBuilder;

    @BeforeEach
    void setUp() {
        passwordValidator = new PasswordValidator();
        passwordValidator.initialize(null);
        
        when(context.buildConstraintViolationWithTemplate(anyString())).thenReturn(violationBuilder);
    }

    @Test
    void isValid_WithValidPassword_ShouldReturnTrue() {
        // Given
        String validPassword = "SecurePass123!";

        // When
        boolean result = passwordValidator.isValid(validPassword, context);

        // Then
        assertTrue(result);
    }

    @Test
    void isValid_WithNullPassword_ShouldReturnTrue() {
        // Given
        String nullPassword = null;

        // When
        boolean result = passwordValidator.isValid(nullPassword, context);

        // Then
        assertTrue(result); // Let @NotNull handle null validation
    }

    @Test
    void isValid_WithEmptyPassword_ShouldReturnTrue() {
        // Given
        String emptyPassword = "";

        // When
        boolean result = passwordValidator.isValid(emptyPassword, context);

        // Then
        assertTrue(result); // Let @NotBlank handle empty validation
    }

    @Test
    void isValid_WithPasswordTooShort_ShouldReturnFalse() {
        // Given
        String shortPassword = "Short1!";

        // When
        boolean result = passwordValidator.isValid(shortPassword, context);

        // Then
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate("Password must be at least 8 characters long");
    }

    @Test
    void isValid_WithPasswordTooLong_ShouldReturnFalse() {
        // Given
        String longPassword = "A".repeat(129) + "1!";

        // When
        boolean result = passwordValidator.isValid(longPassword, context);

        // Then
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate("Password must not exceed 128 characters");
    }

    @Test
    void isValid_WithoutLowercase_ShouldReturnFalse() {
        // Given
        String passwordWithoutLowercase = "PASSWORD123!";

        // When
        boolean result = passwordValidator.isValid(passwordWithoutLowercase, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password must contain at least one lowercase letter");
    }

    @Test
    void isValid_WithoutUppercase_ShouldReturnFalse() {
        // Given
        String passwordWithoutUppercase = "password123!";

        // When
        boolean result = passwordValidator.isValid(passwordWithoutUppercase, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password must contain at least one uppercase letter");
    }

    @Test
    void isValid_WithoutDigit_ShouldReturnFalse() {
        // Given
        String passwordWithoutDigit = "Password!";

        // When
        boolean result = passwordValidator.isValid(passwordWithoutDigit, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password must contain at least one digit");
    }

    @Test
    void isValid_WithoutSpecialCharacter_ShouldReturnFalse() {
        // Given
        String passwordWithoutSpecial = "Password123";

        // When
        boolean result = passwordValidator.isValid(passwordWithoutSpecial, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password must contain at least one special character (@$!%*?&)");
    }

    @Test
    void isValid_WithCommonPassword_ShouldReturnFalse() {
        // Given
        String commonPassword = "Password123!";

        // When
        boolean result = passwordValidator.isValid(commonPassword, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password is too common. Please choose a more secure password");
    }

    @Test
    void isValid_WithSequentialNumbers_ShouldReturnFalse() {
        // Given
        String passwordWithSequential = "Secure123!";

        // When
        boolean result = passwordValidator.isValid(passwordWithSequential, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password should not contain sequential characters");
    }

    @Test
    void isValid_WithSequentialLetters_ShouldReturnFalse() {
        // Given
        String passwordWithSequential = "Abcdef1!";

        // When
        boolean result = passwordValidator.isValid(passwordWithSequential, context);

        // Then
        assertFalse(result);
        verify(context).buildConstraintViolationWithTemplate("Password should not contain sequential characters");
    }

    @Test
    void isValid_WithMultipleViolations_ShouldReturnFalse() {
        // Given
        String weakPassword = "weak";

        // When
        boolean result = passwordValidator.isValid(weakPassword, context);

        // Then
        assertFalse(result);
        verify(context, times(5)).buildConstraintViolationWithTemplate(anyString());
    }

    @Test
    void isValid_WithStrongPassword_ShouldReturnTrue() {
        // Given
        String strongPassword = "MyStr0ng&UniqueP@ssw0rd";

        // When
        boolean result = passwordValidator.isValid(strongPassword, context);

        // Then
        assertTrue(result);
    }
}
