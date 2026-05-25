package cz.uhk.pro2.tulipani.web.dto;

public record TodolistResponse(
        Long todolistId,
        String name,
        String listType) {
}