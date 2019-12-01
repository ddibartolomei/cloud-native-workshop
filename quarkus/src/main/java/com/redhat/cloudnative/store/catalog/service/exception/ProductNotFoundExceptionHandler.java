package com.redhat.cloudnative.store.catalog.service.exception;

import javax.ws.rs.core.Response;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

@Provider
public class ProductNotFoundExceptionHandler implements ExceptionMapper<ProductNotFoundException>{

    public Response toResponse(ProductNotFoundException ex){
        return Response.status(404).entity("Product not found").build();
    }
}