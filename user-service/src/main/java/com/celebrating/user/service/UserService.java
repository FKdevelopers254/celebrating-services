package com.celebrating.user.service;

import com.celebrating.user.model.User;
import com.celebrating.user.model.CelebrityProfile;
import com.celebrating.user.model.UserStats;
import com.celebrating.user.repository.UserRepository;
import com.celebrating.user.repository.CelebrityProfileRepository;
import com.celebrating.userservice.kafka.UserEventProducer;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final CelebrityProfileRepository celebrityProfileRepository;
    private final UserEventProducer userEventProducer;

    @Transactional(readOnly = true)
    public List<User> getAllCelebrities() {
        return userRepository.findAllCelebrities();
    }

    @Transactional(readOnly = true)
    public List<User> searchCelebrities(String query) {
        return userRepository.searchCelebrities(query);
    }

    @Transactional(readOnly = true)
    public Optional<User> getUserById(UUID id) {
        return userRepository.findById(id);
    }

    @Transactional(readOnly = true)
    public Optional<User> getUserByUsername(String username) {
        return userRepository.findByUsername(username);
    }

    @Transactional
    public User createUser(User user) {
        // Initialize user stats
        UserStats stats = new UserStats();
        stats.setUser(user);
        user.setStats(stats);

        // If user is a celebrity, create celebrity profile
        if ("CELEBRITY".equals(user.getRole())) {
            CelebrityProfile profile = new CelebrityProfile();
            profile.setUser(user);
            user.setCelebrityProfile(profile);
        }

        User savedUser = userRepository.save(user);
        
        // Send user created event via Kafka
        try {
            userEventProducer.sendUserCreatedEvent(savedUser.getId().toString(), savedUser);
            System.out.println("User created event sent for user: " + savedUser.getId());
        } catch (Exception e) {
            System.err.println("Failed to send user created event: " + e.getMessage());
        }
        
        return savedUser;
    }

    @Transactional
    public Optional<User> updateUser(UUID id, User userDetails) {
        return userRepository.findById(id)
            .map(user -> {
                user.setFullName(userDetails.getFullName());
                user.setBio(userDetails.getBio());
                user.setLocation(userDetails.getLocation());
                user.setProfileImageUrl(userDetails.getProfileImageUrl());
                user.setPrivate(userDetails.isPrivate());
                User updatedUser = userRepository.save(user);
                
                // Send user updated event via Kafka
                try {
                    userEventProducer.sendUserUpdatedEvent(updatedUser.getId().toString(), updatedUser);
                    System.out.println("User updated event sent for user: " + updatedUser.getId());
                } catch (Exception e) {
                    System.err.println("Failed to send user updated event: " + e.getMessage());
                }
                
                return updatedUser;
            });
    }

    @Transactional
    public Optional<CelebrityProfile> updateCelebrityProfile(UUID userId, CelebrityProfile profileDetails) {
        return celebrityProfileRepository.findByUserId(userId)
            .map(profile -> {
                profile.setStageName(profileDetails.getStageName());
                profile.setProfessions(profileDetails.getProfessions());
                profile.setMajorAchievements(profileDetails.getMajorAchievements());
                profile.setNotableProjects(profileDetails.getNotableProjects());
                profile.setCollaborations(profileDetails.getCollaborations());
                profile.setNetWorth(profileDetails.getNetWorth());
                return celebrityProfileRepository.save(profile);
            });
    }

    @Transactional(readOnly = true)
    public Optional<CelebrityProfile> getCelebrityProfile(UUID userId) {
        return celebrityProfileRepository.findByUserId(userId);
    }

    @Transactional(readOnly = true)
    public List<CelebrityProfile> searchCelebrityProfiles(String query) {
        return celebrityProfileRepository.searchCelebrityProfiles(query);
    }
} 