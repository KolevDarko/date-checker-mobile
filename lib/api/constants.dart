const baseUrl = 'http://datecheck.lifehqapp.com';
const batchWarningsUrl = baseUrl + '/api/warnings/active/';
const productsUrl = baseUrl + '/api/products/';
const productsSyncUrl = baseUrl + '/api/sync/products/';
const productBatchesUrl = baseUrl + '/api/product-batches/';
const syncBatchesUrl = baseUrl + '/api/sync/batches/';
const authUrl = baseUrl + '/api-token-auth/';

Map<String, String> uploadBatchHeaders = {
  'Authorization': 'Token 6f51968bda023efc8b9bd3b8ea65d9beccc58b87',
  'Content-Type': 'application/json',
};
