package cz.uhk.pro2.tulipani.web.exception;

import java.time.OffsetDateTime;
import java.util.List;

public record ErrorResponse(String message, List<String> errors, OffsetDateTime timestamp) {
}
