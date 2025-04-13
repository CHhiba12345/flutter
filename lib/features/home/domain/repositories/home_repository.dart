import '../entities/product.dart';

abstract class HomeRepository {
  Future<Product> scanProduct(String barcode);
  Future<List<Product>> searchProducts(String query);
  Future<Product> getProduct(String code);
  Future<bool> getfavoriteProduct(String uid, String productid);
}