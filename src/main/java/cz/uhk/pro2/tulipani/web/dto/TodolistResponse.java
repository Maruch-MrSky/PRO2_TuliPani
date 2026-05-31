package cz.uhk.pro2.tulipani.web.dto;

public record TodolistResponse(
        Integer todolistId,
        String name,
        String listType) {
}