package cz.uhk.pro2.tulipani.web.controller;

import cz.uhk.pro2.tulipani.web.dto.CreateAttachmentRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/tasks/{taskId}/attachments")
@RequiredArgsConstructor
@Validated
public class AttachmentController {

    @PostMapping
    public ResponseEntity<Void> addAttachment(@PathVariable Long taskId, @RequestBody CreateAttachmentRequest req,
                                              @RequestHeader(value = "X-Auth-Id", required = false) String authId) {
        throw new UnsupportedOperationException("Not implemented");
    }
}

