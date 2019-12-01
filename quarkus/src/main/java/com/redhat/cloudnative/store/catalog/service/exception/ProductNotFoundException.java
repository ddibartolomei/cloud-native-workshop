package com.redhat.cloudnative.store.catalog.service.exception;

public class ProductNotFoundException extends RuntimeException {

    private static final long serialVersionUID = -8406375915738553296L;

    public ProductNotFoundException() {
        super();
    }

    public ProductNotFoundException(final String message, final Throwable cause) {
        super(message, cause);
    }

    public ProductNotFoundException(final String message) {
        super(message);
    }

    public ProductNotFoundException(final Throwable cause) {
        super(cause);
    }
}