package com.example.myapp;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

class MainTest {
    @Test
    void greets() {
        assertEquals("Hello, world!", Main.greeting());
    }
}
