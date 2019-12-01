package com.redhat.service;

import io.quarkus.test.junit.QuarkusTest;
import org.junit.jupiter.api.Test;

import static io.restassured.RestAssured.given;

@QuarkusTest
public class StoreCatalogServiceTest {

    @Test
    public void testProductListEndpoint() {
        given()
          .when().get("/api/store/catalog")
          .then()
             .statusCode(200);
    }

}