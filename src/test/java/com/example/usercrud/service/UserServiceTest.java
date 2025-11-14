package com.example.usercrud.service;

import com.example.usercrud.model.User;
import com.example.usercrud.repository.UserRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepository userRepository;

    @InjectMocks
    private UserService userService;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("John Doe", "john@example.com", "1234567890");
        testUser.setId(1L);
    }

    @Test
    void getAllUsers_ShouldReturnAllUsers() {
        // Given
        List<User> users = Arrays.asList(testUser, new User("Jane Doe", "jane@example.com", "0987654321"));
        when(userRepository.findAll()).thenReturn(users);

        // When
        List<User> result = userService.getAllUsers();

        // Then
        assertEquals(2, result.size());
        verify(userRepository).findAll();
    }

    @Test
    void getUserById_WhenUserExists_ShouldReturnUser() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));

        // When
        Optional<User> result = userService.getUserById(1L);

        // Then
        assertTrue(result.isPresent());
        assertEquals("John Doe", result.get().getName());
        verify(userRepository).findById(1L);
    }

    @Test
    void createUser_WhenEmailDoesNotExist_ShouldCreateUser() {
        // Given
        when(userRepository.existsByEmail("john@example.com")).thenReturn(false);
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        User result = userService.createUser(testUser);

        // Then
        assertNotNull(result);
        assertEquals("John Doe", result.getName());
        verify(userRepository).existsByEmail("john@example.com");
        verify(userRepository).save(testUser);
    }

    @Test
    void updateUser_WhenUserExists_ShouldUpdateUser() {
        // Given
        User updatedDetails = new User("John Updated", "john@example.com", "9999999999");
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.save(any(User.class))).thenReturn(testUser);

        // When
        User result = userService.updateUser(1L, updatedDetails);

        // Then
        assertNotNull(result);
        verify(userRepository).findById(1L);
        verify(userRepository).save(testUser);
    }

    @Test
    void createUser_WhenEmailExists_ShouldThrowException() {
        // Given
        when(userRepository.existsByEmail("john@example.com")).thenReturn(true);

        // When & Then
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.createUser(testUser);
        });

        assertEquals("Email already exists", exception.getMessage());
        verify(userRepository).existsByEmail("john@example.com");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void updateUser_WhenUserNotFound_ShouldThrowException() {
        // Given
        User updatedDetails = new User("John Updated", "john@example.com", "9999999999");
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.updateUser(999L, updatedDetails);
        });

        assertTrue(exception.getMessage().contains("User not found"));
        verify(userRepository).findById(999L);
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void updateUser_WhenEmailChangedAndExists_ShouldThrowException() {
        // Given
        User updatedDetails = new User("John Updated", "newemail@example.com", "9999999999");
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        when(userRepository.existsByEmail("newemail@example.com")).thenReturn(true);

        // When & Then
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.updateUser(1L, updatedDetails);
        });

        assertEquals("Email already exists", exception.getMessage());
        verify(userRepository).findById(1L);
        verify(userRepository).existsByEmail("newemail@example.com");
        verify(userRepository, never()).save(any(User.class));
    }

    @Test
    void deleteUser_WhenUserExists_ShouldDeleteUser() {
        // Given
        when(userRepository.findById(1L)).thenReturn(Optional.of(testUser));
        doNothing().when(userRepository).delete(testUser);

        // When
        userService.deleteUser(1L);

        // Then
        verify(userRepository).findById(1L);
        verify(userRepository).delete(testUser);
    }

    @Test
    void deleteUser_WhenUserNotFound_ShouldThrowException() {
        // Given
        when(userRepository.findById(999L)).thenReturn(Optional.empty());

        // When & Then
        RuntimeException exception = assertThrows(RuntimeException.class, () -> {
            userService.deleteUser(999L);
        });

        assertTrue(exception.getMessage().contains("User not found"));
        verify(userRepository).findById(999L);
        verify(userRepository, never()).delete(any(User.class));
    }
}