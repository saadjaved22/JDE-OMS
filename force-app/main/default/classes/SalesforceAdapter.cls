global class SalesforceAdapter implements commercepayments.PaymentGatewayAdapter {
  global SalesforceAdapter() {
  }

  global commercepayments.GatewayResponse processRequest(commercepayments.paymentGatewayContext gatewayContext) {
    System.debug('SalesforceAdapter.processRequest was called but this is not in use.');
    return null;
  }

  public commercepayments.GatewayResponse createTokenizeResponse(
    commercepayments.PaymentMethodTokenizationRequest tokenizeRequest
  ) {
    System.debug('SalesforceAdapter.tokenizeRequest was called but this is not in use.');
    return null;
  }

  public commercepayments.GatewayResponse createAuthResponse(commercepayments.AuthorizationRequest authRequest) {
    System.debug('SalesforceAdapter.createAuthResponse was called but this is not in use.');
    return null;
  }

  public commercepayments.GatewayResponse createAuthReversalResponse(
    commercepayments.AuthorizationReversalRequest authReversalRequest
  ) {
    System.debug('SalesforceAdapter.createAuthReversalResponse was called but this is not in use.');
    return null;
  }

  public commercepayments.GatewayResponse createCaptureResponse(commercepayments.CaptureRequest captureRequest) {
    commercepayments.CaptureResponse captureResponse = new commercepayments.CaptureResponse();
    System.debug('SalesforceAdapter.createCaptureResponse was called but this is not in use.');
    return null;
  }

  public commercepayments.GatewayResponse createSaleResponse(commercepayments.SaleRequest saleRequest) {
    commercepayments.SaleResponse saleResponse = new commercepayments.SaleResponse();
    commercepayments.PaymentMethodTokenizationResponse paymentMethodTokenizationResponse = new commercepayments.PaymentMethodTokenizationResponse();
    System.debug('SalesforceAdapter.createSaleResponse was called but this is not in use.');
    return null;
  }

  public commercepayments.GatewayResponse createRefundResponse(commercepayments.ReferencedRefundRequest refundRequest) {
    commercepayments.ReferencedRefundResponse refundResponse = new commercepayments.ReferencedRefundResponse();
    System.debug('SalesforceAdapter.createRefundResponse was called but this is not in use.');
    return null;
  }
}