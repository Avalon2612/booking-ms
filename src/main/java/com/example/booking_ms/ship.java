package com.example.booking_ms;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ship   {
    @GetMapping("/ship")
    public String getData() {
        return "Please  book ship ticket with 30% discount";
    }
}