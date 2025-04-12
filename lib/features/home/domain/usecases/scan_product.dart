import '../entities/product.dart';
import '../repositories/home_repository.dart';

class ScanProduct {
  final HomeRepository repository;

  ScanProduct(this.repository);

  Future<Product> execute(String barcode) async {
    try {
      return await repository.scanProduct(barcode);
    } catch (e) {
      throw Exception('Scan failed: $e');
    }
  }
  Future<List<Product>> search(String query) {
    return repository.searchProducts(query);
  }
}