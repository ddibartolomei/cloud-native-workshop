package com.redhat.cloudnative.catalog;

import java.util.*;
import java.util.stream.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(value = "/api/catalog")
public class CatalogController {

    @Autowired
    private ProductRepository repository;

    @Value("${spring.datasource.username}")
    private String dbUser;

    @ResponseBody
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Product> getAll() {
        Spliterator<Product> products = repository.findAll().spliterator();
        System.out.println(">>>>>>>>>>>>> DB USER: " + dbUser);
        return StreamSupport.stream(products, false).collect(Collectors.toList());
    }
}