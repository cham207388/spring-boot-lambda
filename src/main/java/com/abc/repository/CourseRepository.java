package com.abc.repository;

import com.abc.dto.Course;
import org.socialsignin.spring.data.dynamodb.repository.EnableScan;
import org.springframework.data.repository.CrudRepository;

import java.util.Optional;

@EnableScan
public interface CourseRepository extends CrudRepository<Course, String> {

    Optional<Course> findByName(String name);

}