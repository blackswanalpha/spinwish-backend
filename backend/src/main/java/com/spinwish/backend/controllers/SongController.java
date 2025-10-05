package com.spinwish.backend.controllers;

import com.spinwish.backend.models.requests.songs.SongRequest;
import com.spinwish.backend.models.responses.songs.SongResponse;
import com.spinwish.backend.services.SongService;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/api/v1/songs")
public class SongController {

    @Autowired
    private SongService songService;

    @PostMapping
    public ResponseEntity<SongResponse> create(@RequestBody @Valid SongRequest request) {
        SongResponse songResponse = songService.create(request);
        return new ResponseEntity<>(songResponse, HttpStatus.CREATED);
    }

    @GetMapping
    public ResponseEntity<List<SongResponse>> getAll() {
        List<SongResponse> songResponses = songService.getAll();
        return new ResponseEntity<>(songResponses, HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<SongResponse> getById(@PathVariable UUID id) {
        SongResponse songResponse = songService.getById(id);
        return new ResponseEntity<>(songResponse, HttpStatus.OK);
    }

    @PutMapping("/{id}")
    public ResponseEntity<SongResponse> update(@PathVariable UUID id, @RequestBody @Valid SongRequest request) {
        SongResponse songResponse = songService.update(id, request);
        return new ResponseEntity<>(songResponse, HttpStatus.OK);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable UUID id) {
        songService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
