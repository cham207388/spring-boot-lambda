package com.abc.config;

import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Info;
import org.springdoc.core.models.GroupedOpenApi;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@Configuration
public class SwaggerConfig {

    @Bean
    public OpenAPI customOpenAPI() {
        return new OpenAPI().info(new Info()
                .title("Course API")
                .description("API for managing courses via Lambda")
                .version("1.0.0"));
    }

    @Bean
    public GroupedOpenApi courseGroup() {
        return GroupedOpenApi.builder()
                .group("course")
                .pathsToMatch("/courses/**")
                .build();
    }
}
