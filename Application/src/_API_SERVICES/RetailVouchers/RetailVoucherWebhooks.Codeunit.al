codeunit 6248394 "NPR Retail Voucher Webhooks"
{
    Access = Internal;


#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    [ExternalBusinessEvent('voucher_created', 'Voucher Created', 'Triggered when a voucher is created', EventCategory::"NPR Retail Vouchers", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR Retail Voucher Webhooks", 'X')]
    procedure OnVoucherCreated(voucherId: Guid; voucherType: Code[20]; initialamount: Decimal; customerNo: Code[20]; referenceNo: Text[50]; issuingDocumentNo: Code[20]; issuingExternalDocumentNo: Code[50])
    begin
    end;

    [ExternalBusinessEvent('voucher_payment', 'Voucher Payment', 'Triggered when voucher is used for payment', EventCategory::"NPR Retail Vouchers", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR Retail Voucher Webhooks", 'X')]
    procedure OnVoucherPayment(voucherId: Guid; voucherType: Code[20]; initialamount: Decimal; amount: Decimal; customerNo: Code[20])
    begin
    end;
#endif
}