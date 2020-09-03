codeunit 6014612 "NPR TaxFree PTF Offline"
{
    // Premier offline is no longer maintained.
    // It does not support terminal card recognition or customer specific tax free percentage deals. It prints a hardcoded voucher from old times.
    // The only reason it still exists is because customers on the Faroe Islands cannot use PREMIER_PI webservice integration.
    // NPR5.30/NPKNAV/20170310  CASE 261964 Transport NPR5.30 - 26 January 2017
    // NPR5.40/MMV /20180112 CASE 293106 Refactored tax free module
    // NPR5.48/MMV /20181105 CASE 334588 Fixed mismatch in event subscriber signature


    trigger OnRun()
    begin
    end;

    var
        MerchantID: Text;
        VATNumber: Text;
        CountryCode: Integer;
        POSUnitNo: Code[10];
        Error_MissingParameters: Label 'Missing parameters for handler %1 on tax free unit %2';
        Error_InvalidCountryCode: Label 'Premier Tax Free Offline handler is only supported on the Faroe Islands.';
        Error_TestConn: Label 'Cannot test connection on an offline tax free handler';
        MinimumAmountLimit: Decimal;
        Error_NotSupported: Label 'Operation is not supported by tax free handler: %1';

    local procedure HandlerID(): Text
    begin
        exit('PREMIER_OFFLINE')
    end;

    [TryFunction]
    local procedure InitializeHandler(TaxFreeRequest: Record "NPR Tax Free Request")
    var
        tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary;
        Variant: Variant;
        TaxFreeUnit: Record "NPR Tax Free POS Unit";
    begin
        TaxFreeUnit.Get(TaxFreeRequest."POS Unit No.");

        if not TaxFreeUnit."Handler Parameters".HasValue then
            Error(Error_MissingParameters, TaxFreeUnit."Handler ID", TaxFreeUnit."POS Unit No.");

        AddParameters(tmpHandlerParameters);
        tmpHandlerParameters.DeserializeParameterBLOB(TaxFreeUnit);

        if tmpHandlerParameters.TryGetParameterValue('Merchant ID', Variant) then
            MerchantID := Variant;

        if tmpHandlerParameters.TryGetParameterValue('VAT Number', Variant) then
            VATNumber := Variant;

        if tmpHandlerParameters.TryGetParameterValue('Country Code', Variant) then
            CountryCode := Variant;

        if tmpHandlerParameters.TryGetParameterValue('Minimum Amount Limit', Variant) then
            MinimumAmountLimit := Variant;

        POSUnitNo := TaxFreeUnit."POS Unit No.";

        if (StrLen(MerchantID) = 0) or (StrLen(VATNumber) = 0) or (CountryCode = 0) then
            Error(Error_MissingParameters, TaxFreeUnit."Handler ID", TaxFreeUnit."POS Unit No.");
    end;

    local procedure AddParameters(var tmpHandlerParameters: Record "NPR Tax Free Handler Param.")
    begin
        tmpHandlerParameters.AddParameter('Merchant ID', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('VAT Number', tmpHandlerParameters."Data Type"::Text);
        tmpHandlerParameters.AddParameter('Country Code', tmpHandlerParameters."Data Type"::Integer);
        tmpHandlerParameters.AddParameter('Minimum Amount Limit', tmpHandlerParameters."Data Type"::Decimal);
    end;

    local procedure "// Commands"()
    begin
    end;

    local procedure VoucherPrint(var AuditRoll: Record "NPR Audit Roll")
    var
        LinePrintMgt: Codeunit "NPR RP Line Print Mgt.";
    begin
        LinePrintMgt.ProcessCodeunit(CODEUNIT::"NPR Report: TaxFree Receipt", AuditRoll);
    end;

    local procedure "// Aux"()
    begin
    end;

    local procedure IsStoredSaleEligible(SalesTicketNo: Text): Boolean
    var
        AuditRoll: Record "NPR Audit Roll";
    begin
        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetFilter(Quantity, '>0');
        AuditRoll.SetFilter("VAT %", '>0');
        AuditRoll.CalcSums("Amount Including VAT");

        exit(AuditRoll."Amount Including VAT" >= MinimumAmountLimit);
    end;

    local procedure IsActiveSaleEligible(SalesTicketNo: Text): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Sales Ticket No.", SalesTicketNo);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetFilter(Quantity, '>0');
        SaleLinePOS.SetFilter("VAT %", '>0');
        SaleLinePOS.CalcSums("Amount Including VAT");

        exit(SaleLinePOS."Amount Including VAT" >= MinimumAmountLimit);
    end;

    local procedure "// Event Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnLookupHandler', '', false, false)]
    local procedure OnLookupHandler(var HashSet: DotNet NPRNetHashSet_Of_T)
    begin
        HashSet.Add(HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnLookupHandlerParameters', '', false, false)]
    local procedure OnLookupHandlerParameter(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary)
    begin
        if not TaxFreeUnit.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        AddParameters(tmpHandlerParameters);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnSetUnitParameters', '', false, false)]
    local procedure OnSetUnitParameters(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean)
    var
        TaxFreeMgt: Codeunit "NPR Tax Free Handler Mgt.";
    begin
        if not TaxFreeUnit.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        TaxFreeMgt.SetGenericHandlerParameters(TaxFreeUnit); //Use the built-in support for storing parameters in the unit BLOB instead of externally.
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnUnitAutoConfigure', '', false, false)]
    local procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnUnitTestConnection', '', false, false)]
    local procedure OnUnitTestConnection(var TaxFreeRequest: Record "NPR Tax Free Request"; var Handled: Boolean)
    var
        Valid: Boolean;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        if not (CountryCode in [234]) then
            Error(Error_InvalidCountryCode);

        Error(Error_TestConn);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherIssueFromPOSSale', '', false, false)]
    local procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var Handled: Boolean; var SkipRecordHandling: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        RecRef: RecordRef;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);

        if not (CountryCode in [234]) then
            Error(Error_InvalidCountryCode);

        AuditRoll.SetRange("Sales Ticket No.", SalesReceiptNo);
        AuditRoll.FindSet;
        RecRef.GetTable(AuditRoll);
        VoucherPrint(AuditRoll);

        SkipRecordHandling := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherVoid', '', false, false)]
    local procedure OnVoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherReissue', '', false, false)]
    local procedure OnVoucherReissue(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherLookup', '', false, false)]
    local procedure OnVoucherLookup(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, TaxFreeRequest."Handler ID");
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherPrint', '', false, false)]
    local procedure OnVoucherPrint(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnVoucherConsolidate', '', false, false)]
    local procedure OnVoucherConsolidate(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary; var Handled: Boolean)
    var
        tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsValidTerminalIIN', '', false, false)]
    local procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean; var Handled: Boolean)
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        Error(Error_NotSupported, HandlerID);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsActiveSaleEligible', '', false, false)]
    local procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Eligible := IsActiveSaleEligible(SalesTicketNo);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014610, 'OnIsStoredSaleEligible', '', false, false)]
    local procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean; var Handled: Boolean)
    var
        tmpEligibleServices: Record "NPR Tax Free GB I2 Service" temporary;
    begin
        if not TaxFreeRequest.IsThisHandler(HandlerID) then
            exit;

        Handled := true;
        InitializeHandler(TaxFreeRequest);
        Eligible := IsStoredSaleEligible(SalesTicketNo);
    end;
}

