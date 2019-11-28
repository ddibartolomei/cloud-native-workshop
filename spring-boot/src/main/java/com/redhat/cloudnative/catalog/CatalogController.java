package com.redhat.cloudnative.catalog;

import java.util.*;
import java.util.stream.*;

import com.redhat.cloudnative.catalog.exception.ProductNotFoundException;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping(value = "/api/catalog")
public class CatalogController {

    @Autowired
    private ProductRepository repository;

    @ResponseBody
    @GetMapping(produces = MediaType.APPLICATION_JSON_VALUE)
    public List<Product> getAll() {
        Spliterator<Product> products = repository.findAll().spliterator();
        return StreamSupport.stream(products, false).collect(Collectors.toList());
    }

    @ResponseBody
    @GetMapping(value = "/test/list", produces = MediaType.APPLICATION_JSON_VALUE)
    public ProductList getAll2() {
        Spliterator<Product> products = repository.findAll().spliterator();
        ProductList p = new ProductList();
        p.setProductList(StreamSupport.stream(products, false).collect(Collectors.toList()));
        return p;
    }

    @ResponseBody
    @GetMapping(value = "/{id}", produces = MediaType.APPLICATION_JSON_VALUE)
    public Product getProduct(@PathVariable("id") String id) {
        return repository.findById(id)
          .orElseThrow(ProductNotFoundException::new);
    }
}