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
class EmailValidatorTest {

    private EmailValidator emailValidator;

    @Mock
    private ConstraintValidatorContext context;

    @Mock
    private ConstraintValidatorContext.ConstraintViolationBuilder violationBuilder;

    @BeforeEach
    void setUp() {
        emailValidator = new EmailValidator();
        emailValidator.initialize(null);
    }

    @Test
    void isValid_WithValidEmail_ShouldReturnTrue() {
        // Given
        String validEmail = "test@example.com";

        // When
        boolean result = emailValidator.isValid(validEmail, context);

        // Then
        assertTrue(result);
    }

    @Test
    void isValid_WithNullEmail_ShouldReturnTrue() {
        // Given
        String nullEmail = null;

        // When
        boolean result = emailValidator.isValid(nullEmail, context);

        // Then
        assertTrue(result); // Let @NotNull handle null validation
    }

    @Test
    void isValid_WithEmptyEmail_ShouldReturnTrue() {
        // Given
        String emptyEmail = "";

        // When
        boolean result = emailValidator.isValid(emptyEmail, context);

        // Then
        assertTrue(result); // Let @NotBlank handle empty validation
    }

    @Test
    void isValid_WithInvalidEmailFormat_ShouldReturnFalse() {
        // Given
        String invalidEmail = "invalid-email";

        // When
        boolean result = emailValidator.isValid(invalidEmail, context);

        // Then
        assertFalse(result);
    }

    @Test
    void isValid_WithEmailTooLong_ShouldReturnFalse() {
        // Given
        String longEmail = "a".repeat(250) + "@example.com"; // Over 254 characters
        when(context.buildConstraintViolationWithTemplate(anyString())).thenReturn(violationBuilder);

        // When
        boolean result = emailValidator.isValid(longEmail, context);

        // Then
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate("Email address is too long (max 254 characters)");
    }

    @Test
    void isValid_WithConsecutiveDots_ShouldReturnFalse() {
        // Given
        String emailWithConsecutiveDots = "test..email@example.com";
        when(context.buildConstraintViolationWithTemplate(anyString())).thenReturn(violationBuilder);

        // When
        boolean result = emailValidator.isValid(emailWithConsecutiveDots, context);

        // Then
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate("Email address cannot contain consecutive dots");
    }

    @Test
    void isValid_WithLocalPartTooLong_ShouldReturnFalse() {
        // Given
        String emailWithLongLocalPart = "a".repeat(65) + "@example.com"; // Over 64 characters in local part
        when(context.buildConstraintViolationWithTemplate(anyString())).thenReturn(violationBuilder);

        // When
        boolean result = emailValidator.isValid(emailWithLongLocalPart, context);

        // Then
        assertFalse(result);
        verify(context).disableDefaultConstraintViolation();
        verify(context).buildConstraintViolationWithTemplate("Email local part is too long (max 64 characters)");
    }

    @Test
    void isValid_WithValidComplexEmail_ShouldReturnTrue() {
        // Given
        String complexValidEmail = "user.name+tag@example-domain.co.uk";

        // When
        boolean result = emailValidator.isValid(complexValidEmail, context);

        // Then
        assertTrue(result);
    }

    @Test
    void isValid_WithValidEmailWithNumbers_ShouldReturnTrue() {
        // Given
        String emailWithNumbers = "user123@example123.com";

        // When
        boolean result = emailValidator.isValid(emailWithNumbers, context);

        // Then
        assertTrue(result);
    }
}
