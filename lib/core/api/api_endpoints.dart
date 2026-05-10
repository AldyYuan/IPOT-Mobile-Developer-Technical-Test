class APIEndpoints {
  static const String menu = '/api/v1/menu';
  static const String orders = '/api/v1/orders';
  static const String categories = '/api/v1/categories';

  static String orderById(String id) => '/api/v1/orders/$id';
  static String tableStatus(String id) => '/api/v1/tables/$id/status';
}
