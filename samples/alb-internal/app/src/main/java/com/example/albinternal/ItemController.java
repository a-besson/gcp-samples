package com.example.albinternal;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotBlank;
import java.util.List;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class ItemController {

    private final ItemRepository repository;

    public ItemController(ItemRepository repository) {
        this.repository = repository;
    }

    @GetMapping("/api/items")
    public List<Item> list() {
        return repository.findAll();
    }

    @PostMapping("/api/items")
    public ResponseEntity<Item> create(@Valid @RequestBody CreateItemRequest request) {
        Item saved = repository.save(new Item(request.name()));
        return ResponseEntity.status(HttpStatus.CREATED).body(saved);
    }

    public record CreateItemRequest(@NotBlank String name) {
    }
}
