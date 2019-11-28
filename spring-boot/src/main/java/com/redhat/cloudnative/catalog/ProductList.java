package com.redhat.cloudnative.catalog;

import java.io.Serializable;
import java.util.List;

public class ProductList implements Serializable {
  
  private static final long serialVersionUID = 1L;
  
  private List<Product> productList;
  
  public ProductList() {
  }

  /**
   * @return the productList
   */
  public List<Product> getProductList() {
    return productList;
  }
  
  /**
   * @param productList the productList to set
   */
  public void setProductList(List<Product> productList) {
    this.productList = productList;
  }
  
  @Override
  public String toString() {
    return "ProductList [" + productList.size() + "]";
  }
}