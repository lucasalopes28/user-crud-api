package com.example.usercrud.controller;

import com.example.usercrud.model.User;
import com.example.usercrud.service.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.Mockito.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

@WebMvcTest(UserController.class)
class UserControllerTest {

    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private UserService userService;

    @Autowired
    private ObjectMapper objectMapper;

    private User testUser;

    @BeforeEach
    void setUp() {
        testUser = new User("John Doe", "john@example.com", "1234567890");
        testUser.setId(1L);
    }

    @Test
    void getAllUsers_ShouldReturnListOfUsers() throws Exception {
        // Given
        List<User> users = Arrays.asList(testUser, new User("Jane Doe", "jane@example.com", "0987654321"));
        when(userService.getAllUsers()).thenReturn(users);

        // When & Then
        mockMvc.perform(get("/api/users"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.length()").value(2))
                .andExpect(jsonPath("$[0].name").value("John Doe"))
                .andExpect(jsonPath("$[0].email").value("john@example.com"));

        verify(userService).getAllUsers();
    }

    @Test
    void getUserById_WhenUserExists_ShouldReturnUser() throws Exception {
        // Given
        when(userService.getUserById(1L)).thenReturn(Optional.of(testUser));

        // When & Then
        mockMvc.perform(get("/api/users/1"))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.name").value("John Doe"))
                .andExpect(jsonPath("$.email").value("john@example.com"));

        verify(userService).getUserById(1L);
    }

    @Test
    void createUser_WithValidData_ShouldCreateUser() throws Exception {
        // Given
        User newUser = new User("Jane Doe", "jane@example.com", "0987654321");
        when(userService.createUser(any(User.class))).thenReturn(testUser);

        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(newUser)))
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.name").value("John Doe"));

        verify(userService).createUser(any(User.class));
    }

    @Test
    void deleteUser_WhenUserExists_ShouldDeleteUser() throws Exception {
        // Given
        doNothing().when(userService).deleteUser(1L);

        // When & Then
        mockMvc.perform(delete("/api/users/1"))
                .andExpect(status().isNoContent());

        verify(userService).deleteUser(1L);
    }

    @Test
    void getUserById_WhenUserNotFound_ShouldReturnNotFound() throws Exception {
        // Given
        when(userService.getUserById(999L)).thenReturn(Optional.empty());

        // When & Then
        mockMvc.perform(get("/api/users/999"))
                .andExpect(status().isNotFound());

        verify(userService).getUserById(999L);
    }

    @Test
    void createUser_WithInvalidData_ShouldReturnBadRequest() throws Exception {
        // Given
        User newUser = new User("Jane Doe", "jane@example.com", "0987654321");
        when(userService.createUser(any(User.class))).thenThrow(new RuntimeException("Email already exists"));

        // When & Then
        mockMvc.perform(post("/api/users")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(newUser)))
                .andExpect(status().isBadRequest());

        verify(userService).createUser(any(User.class));
    }

    @Test
    void updateUser_WithValidData_ShouldUpdateUser() throws Exception {
        // Given
        User updatedUser = new User("John Updated", "john@example.com", "9999999999");
        updatedUser.setId(1L);
        when(userService.updateUser(eq(1L), any(User.class))).thenReturn(updatedUser);

        // When & Then
        mockMvc.perform(put("/api/users/1")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedUser)))
                .andExpect(status().isOk())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))
                .andExpect(jsonPath("$.name").value("John Updated"));

        verify(userService).updateUser(eq(1L), any(User.class));
    }

    @Test
    void updateUser_WhenUserNotFound_ShouldReturnNotFound() throws Exception {
        // Given
        User updatedUser = new User("John Updated", "john@example.com", "9999999999");
        when(userService.updateUser(eq(999L), any(User.class))).thenThrow(new RuntimeException("User not found"));

        // When & Then
        mockMvc.perform(put("/api/users/999")
                .contentType(MediaType.APPLICATION_JSON)
                .content(objectMapper.writeValueAsString(updatedUser)))
                .andExpect(status().isNotFound());

        verify(userService).updateUser(eq(999L), any(User.class));
    }

    @Test
    void deleteUser_WhenUserNotFound_ShouldReturnNotFound() throws Exception {
        // Given
        doThrow(new RuntimeException("User not found")).when(userService).deleteUser(999L);

        // When & Then
        mockMvc.perform(delete("/api/users/999"))
                .andExpect(status().isNotFound());

        verify(userService).deleteUser(999L);
    }
}