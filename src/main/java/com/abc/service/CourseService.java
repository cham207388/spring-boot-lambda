package com.abc.service;

import com.abc.dto.Course;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.enhanced.dynamodb.DynamoDbTable;

import java.util.*;

@Service
@RequiredArgsConstructor
public class CourseService {

    private final DynamoDbTable<Course> courseTable;

    public void addCourse(Course course) {
        courseTable.putItem(course);
    }

    public List<Course> getAllCourses() {
        return courseTable.scan()
                .items()
                .stream()
                .toList();
    }

    public Optional<Course> getCourseById(String id) {
        return Optional.ofNullable(courseTable.getItem(r -> r.key(k -> k.partitionValue(id))));
    }

    public boolean updateCourse(String id, Course newCourse) {
        Course existing = courseTable.getItem(r -> r.key(k -> k.partitionValue(id)));
        if (existing == null) return false;

        newCourse.setId(id);
        courseTable.putItem(newCourse);
        return true;
    }

    public boolean deleteCourse(String id) {
        Course existing = courseTable.getItem(r -> r.key(k -> k.partitionValue(id)));
        if (existing == null) return false;

        courseTable.deleteItem(existing);
        return true;
    }
}