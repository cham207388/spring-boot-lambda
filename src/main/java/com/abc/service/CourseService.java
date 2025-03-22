package com.abc.service;

import com.abc.dto.Course;
import com.abc.repository.CourseRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final CourseRepository courseRepository;
    public void addCourse(Course course) {
        courseRepository.save(course);
    }

    // Retrieve all courses
    public List<Course> getAllCourses() {
        return (List<Course>) courseRepository.findAll();
    }

    // Retrieve a course by id
    public Optional<Course> getCourseById(String id) {
        return courseRepository.findById(id);
    }

    public Optional<Course> getCourseByName(String name) {
        return courseRepository.findByName(name);
    }

}
