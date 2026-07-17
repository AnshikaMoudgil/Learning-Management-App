import '../models/invoice.dart';
import 'api_client.dart';

class InvoiceService {
  final ApiClient _api = ApiClient();

  Future<List<Invoice>> getInvoices() async {
    final result = await _api.get('/api/v1/invoices');
    return (result as List).map((d) => Invoice.fromJson(d)).toList();
  }

  Future<Invoice> getInvoice(String id) async {
    final result = await _api.get('/api/v1/invoices/$id');
    return Invoice.fromJson(result);
  }

  Future<String> getPdfUrl(String id) async {
    final result = await _api.get('/api/v1/invoices/$id/pdf');
    return (result as Map)['url'] as String;
  }
}
