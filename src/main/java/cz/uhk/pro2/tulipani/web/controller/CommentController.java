package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.web.dto.CreateCommentRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tasks/{taskId}/comments")
@RequiredArgsConstructor
@Validated
public class CommentController {

    @PostMapping
    public ResponseEntity<Void> addComment(@PathVariable Long taskId, @RequestBody CreateCommentRequest req,
                                           @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        throw new UnsupportedOperationException("Not implemented");
    }
}

