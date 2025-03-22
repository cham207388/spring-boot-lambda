package com.abc.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class SwaggerRedirect {

    @GetMapping("/swagger-ui")
    public String redirectToUi() {
        return "redirect:/swagger-ui.html";
    }
}
