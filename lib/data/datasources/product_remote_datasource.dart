import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/variables.dart';
import '../../core/utils/app_logger.dart';
import '../models/responses/product_model.dart';
import 'auth_local_datasource.dart';

class ProductRemoteDatasource {
  Future<Map<String, String>> _getHeaders() async {
    final token = await AuthLocalDatasource().getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<Either<String, ProductListResponse>> getProducts({
    String? search,
    int? categoryId,
    bool? requiresPrescription,
    int page = 1,
    int perPage = 15,
  }) async {
    try {
      final headers = await _getHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'per_page': perPage.toString(),
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null && categoryId > 0) {
        queryParams['category_id'] = categoryId.toString();
      }
      if (requiresPrescription != null) {
        queryParams['requires_prescription'] = requiresPrescription.toString();
      }

      final uri = Uri.parse(Variables.products).replace(queryParameters: queryParams);

      AppLogger.apiRequest('GET', uri.toString());

      final response = await http.get(uri, headers: headers);

      AppLogger.apiResponse(
        Variables.products,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return Right(ProductListResponse.fromJson(data));
        }
        return const Left('Format response tidak valid');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil data produk');
    } catch (e) {
      AppLogger.error('GetProducts error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, ProductModel>> getProductById(int id) async {
    try {
      final headers = await _getHeaders();
      final url = '${Variables.products}/$id';

      AppLogger.apiRequest('GET', url);

      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      AppLogger.apiResponse(url, response.statusCode, response.body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ProductModel.fromJson(data['data']));
        }
        return const Left('Produk tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Produk tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mengambil detail produk');
    } catch (e) {
      AppLogger.error('GetProductById error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }

  Future<Either<String, ProductModel>> searchByBarcode(String barcode) async {
    try {
      final headers = await _getHeaders();

      AppLogger.apiRequest('POST', Variables.productBarcode, body: {'barcode': barcode});

      final response = await http.post(
        Uri.parse(Variables.productBarcode),
        headers: headers,
        body: jsonEncode({'barcode': barcode}),
      );

      AppLogger.apiResponse(
        Variables.productBarcode,
        response.statusCode,
        response.body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['data'] != null) {
          return Right(ProductModel.fromJson(data['data']));
        }
        return const Left('Produk tidak ditemukan');
      } else if (response.statusCode == 404) {
        return const Left('Produk tidak ditemukan');
      } else if (response.statusCode == 401) {
        return const Left('Sesi telah berakhir');
      }
      return const Left('Gagal mencari produk');
    } catch (e) {
      AppLogger.error('SearchByBarcode error', error: e);
      return Left('Koneksi gagal: ${e.toString()}');
    }
  }
}

class ProductListResponse {
  final List<ProductModel> products;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  ProductListResponse({
    required this.products,
    required this.currentPage,
    required this.lastPage,
    required this.perPage,
    required this.total,
  });

  factory ProductListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final meta = json['meta'] ?? data;

    List<ProductModel> products = [];
    if (data != null) {
      final productList = data['data'] ?? data;
      if (productList is List) {
        products = productList.map((e) => ProductModel.fromJson(e)).toList();
      }
    }

    return ProductListResponse(
      products: products,
      currentPage: meta?['current_page'] ?? 1,
      lastPage: meta?['last_page'] ?? 1,
      perPage: meta?['per_page'] ?? 15,
      total: meta?['total'] ?? products.length,
    );
  }

  bool get hasNextPage => currentPage < lastPage;
}
