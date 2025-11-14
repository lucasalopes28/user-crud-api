package com.example.usercrud.model;

import jakarta.validation.ConstraintViolation;
import jakarta.validation.Validation;
import jakarta.validation.Validator;
import jakarta.validation.ValidatorFactory;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.util.Set;

import static org.junit.jupiter.api.Assertions.*;

class UserTest {

    private Validator validator;

    @BeforeEach
    void setUp() {
        ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
        validator = factory.getValidator();
    }

    @Test
    void constructor_WithValidData_ShouldCreateUser() {
        // When
        User user = new User("John Doe", "john@example.com", "1234567890");

        // Then
        assertEquals("John Doe", user.getName());
        assertEquals("john@example.com", user.getEmail());
        assertEquals("1234567890", user.getPhone());
        assertNotNull(user.getCreatedAt());
        assertNotNull(user.getUpdatedAt());
    }

    @Test
    void defaultConstructor_ShouldCreateEmptyUser() {
        // When
        User user = new User();

        // Then
        assertNull(user.getId());
        assertNull(user.getName());
        assertNull(user.getEmail());
        assertNull(user.getPhone());
    }

    @Test
    void validation_WithBlankName_ShouldFail() {
        // Given
        User user = new User("", "john@example.com", "1234567890");

        // When
        Set<ConstraintViolation<User>> violations = validator.validate(user);

        // Then
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("Name is required")));
    }

    @Test
    void validation_WithInvalidEmail_ShouldFail() {
        // Given
        User user = new User("John Doe", "invalid-email", "1234567890");

        // When
        Set<ConstraintViolation<User>> violations = validator.validate(user);

        // Then
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("Email should be valid")));
    }

    @Test
    void validation_WithTooLongPhone_ShouldFail() {
        // Given
        User user = new User("John Doe", "john@example.com", "12345678901234567890");

        // When
        Set<ConstraintViolation<User>> violations = validator.validate(user);

        // Then
        assertFalse(violations.isEmpty());
        assertTrue(violations.stream().anyMatch(v -> v.getMessage().contains("Phone number cannot exceed 15 characters")));
    }

    @Test
    void validation_WithValidData_ShouldPass() {
        // Given
        User user = new User("John Doe", "john@example.com", "1234567890");

        // When
        Set<ConstraintViolation<User>> violations = validator.validate(user);

        // Then
        assertTrue(violations.isEmpty());
    }

    @Test
    void settersAndGetters_ShouldWorkCorrectly() {
        // Given
        User user = new User();
        LocalDateTime now = LocalDateTime.now();

        // When
        user.setId(1L);
        user.setName("Jane Doe");
        user.setEmail("jane@example.com");
        user.setPhone("0987654321");
        user.setCreatedAt(now);
        user.setUpdatedAt(now);

        // Then
        assertEquals(1L, user.getId());
        assertEquals("Jane Doe", user.getName());
        assertEquals("jane@example.com", user.getEmail());
        assertEquals("0987654321", user.getPhone());
        assertEquals(now, user.getCreatedAt());
        assertEquals(now, user.getUpdatedAt());
    }

    @Test
    void onCreate_ShouldSetTimestamps() {
        // Given
        User user = new User("John Doe", "john@example.com", "1234567890");
        user.setCreatedAt(null);
        user.setUpdatedAt(null);

        // When
        user.onCreate();

        // Then
        assertNotNull(user.getCreatedAt());
        assertNotNull(user.getUpdatedAt());
    }

    @Test
    void onUpdate_ShouldUpdateTimestamp() {
        // Given
        User user = new User("John Doe", "john@example.com", "1234567890");
        LocalDateTime originalUpdatedAt = user.getUpdatedAt();

        // When
        try {
            Thread.sleep(10); // Small delay to ensure timestamp difference
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
        user.onUpdate();

        // Then
        assertNotNull(user.getUpdatedAt());
        assertNotEquals(originalUpdatedAt, user.getUpdatedAt());
    }
}
