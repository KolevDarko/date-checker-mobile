const baseUrl = 'http://datecheck.lifehqapp.com';
const batchWarningsUrl = baseUrl + '/api/warnings/active/';
const productsUrl = baseUrl + '/api/products/';
const productsSyncUrl = baseUrl + '/api/sync/products/';
const productBatchesUrl = baseUrl + '/api/product-batches/';
const syncBatchesUrl = baseUrl + '/api/sync/batches/';
const authUrl = baseUrl + '/api-token-auth/';

Map authHeaders = {
  'Authorization': '',
  'Content-Type': 'application/json',
};
