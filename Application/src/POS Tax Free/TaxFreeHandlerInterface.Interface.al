interface "NPR Tax Free Handler Interface"
{

    procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean);
    procedure OnUnitTestConnection(var TaxFreeRequest: Record "NPR Tax Free Request");
    procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var SkipRecordHandling: Boolean);
    procedure OnVoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher");
    procedure OnVoucherReissue(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher");
    procedure OnVoucherLookup(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text)
    procedure OnVoucherPrint(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean)
    procedure OnVoucherConsolidate(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean)
    procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    procedure OnLookupHandlerParameter(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary)
    procedure OnSetUnitParameters(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean)
}
