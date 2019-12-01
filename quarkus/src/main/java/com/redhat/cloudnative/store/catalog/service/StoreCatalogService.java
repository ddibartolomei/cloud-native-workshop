package com.redhat.cloudnative.store.catalog.service;

import javax.inject.Inject;
import javax.persistence.EntityManager;
import javax.persistence.NoResultException;
import javax.persistence.Query;
import javax.persistence.TypedQuery;
import javax.transaction.Transactional;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;

import com.redhat.cloudnative.store.catalog.service.exception.ProductNotFoundException;
import com.redhat.cloudnative.store.catalog.service.model.Product;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collection;

@Path("/api/store/catalog")
public class StoreCatalogService {

    private final Logger logger = LoggerFactory.getLogger(StoreCatalogService.class);
 
    @Inject
    EntityManager em;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public Collection<Product> getProducts() {
        logger.debug("Requested all products");
        Query query = em.createQuery("SELECT p FROM Product p");
        return (Collection<Product>) query.getResultList();
    }

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    @Path("/{id}")
    public Product getProduct(@PathParam("id") String id) {
        logger.debug("Requested product {}", id);
        try {
            TypedQuery<Product> query = em.createQuery("SELECT p FROM Product p WHERE p.itemId=:pid", Product.class)
                                        .setParameter("pid", id);
            return (Product) query.getSingleResult();
        } catch (NoResultException e) {
            throw new ProductNotFoundException();
        }
    }

    @POST
    @Produces(MediaType.APPLICATION_JSON)
    @Consumes(MediaType.APPLICATION_JSON)
    @Transactional
    public void addOrUpdateProduct(Product product) {
        logger.debug("Adding/Updating product {}", product.getItemId());
        Product p = em.find(Product.class, product.getItemId());
        if (p != null) {
            em.merge(product);
            logger.debug("Product updated ({})", product);
        }
        else {
            em.persist(product);
            logger.debug("Product added ({})", product);
        }
    }
}