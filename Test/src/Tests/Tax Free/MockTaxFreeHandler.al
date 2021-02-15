codeunit 85018 "NPR Mock Tax Free Handler" implements "NPR Tax Free Handler Interface"
{
    EventSubscriberInstance = Manual;
    procedure OnIsActiveSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    begin
        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeHandlerInterface.OnIsActiveSaleEligible(TaxFreeRequest, SalesTicketNo, Eligible);
    end;

    procedure OnIsStoredSaleEligible(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesTicketNo: Code[20]; var Eligible: Boolean)
    begin
        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeHandlerInterface.OnIsStoredSaleEligible(TaxFreeRequest, SalesTicketNo, Eligible);
    end;

    procedure OnIsValidTerminalIIN(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean)
    begin
        OnIsValidTerminalIINResponse(TaxFreeRequest, MaskedCardNo, IsForeignIIN)
    end;

    procedure OnUnitAutoConfigure(var TaxFreeRequest: Record "NPR Tax Free Request"; Silent: Boolean)
    begin
    end;

    procedure OnUnitTestConnection(var TaxFreeRequest: Record "NPR Tax Free Request")
    begin
    end;

    procedure OnVoucherConsolidate(var TaxFreeRequest: Record "NPR Tax Free Request"; var tmpTaxFreeConsolidation: Record "NPR Tax Free Consolidation" temporary)
    begin
        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeHandlerInterface.OnVoucherConsolidate(TaxFreeRequest, tmpTaxFreeConsolidation);
    end;

    procedure OnVoucherIssueFromPOSSale(var TaxFreeRequest: Record "NPR Tax Free Request"; SalesReceiptNo: Code[20]; var SkipRecordHandling: Boolean)
    var
        TaxFreeLibrary: codeunit "NPR Library - Tax Free";
    begin
        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeHandlerInterface.OnVoucherIssueFromPOSSale(TaxFreeRequest, SalesReceiptNo, SkipRecordHandling);
    end;

    procedure OnVoucherLookup(var TaxFreeRequest: Record "NPR Tax Free Request"; VoucherNo: Text)
    begin
        Constructor(TaxFreeRequest."Handler ID Enum");
        TaxFreeHandlerInterface.OnVoucherLookup(TaxFreeRequest, VoucherNo);
    end;

    procedure OnVoucherPrint(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher"; IsRecentVoucher: Boolean)
    begin
        TaxFreeRequest.Success := true;
    end;

    procedure OnVoucherReissue(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    var
        TaxFreeLibrary: codeunit "NPR Library - Tax Free";
    begin
        TaxFreeLibrary.IssueVoucherResponseGB(TaxFreeRequest, true);
    end;

    procedure OnVoucherVoid(var TaxFreeRequest: Record "NPR Tax Free Request"; TaxFreeVoucher: Record "NPR Tax Free Voucher")
    begin
        TaxFreeRequest.Success := true;
    end;

    procedure OnLookupHandlerParameter(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean; var tmpHandlerParameters: Record "NPR Tax Free Handler Param." temporary)
    begin
    end;

    procedure OnSetUnitParameters(TaxFreeUnit: Record "NPR Tax Free POS Unit"; var Handled: Boolean)
    begin
    end;

    var
        TaxFreeGBI2: Codeunit "NPR Tax Free GB I2";
        NPRTaxFreePTFPI: Codeunit "NPR Tax Free PTF PI";
        ConstructorSet: Boolean;
        TaxFreeHandlerInterface: Interface "NPR Tax Free Handler Interface";

    procedure Constructor(TaxFreeHandlerID: Enum "NPR Tax Free Handler ID")
    begin
        if ConstructorSet then
            exit;
        TaxFreeHandlerInterface := TaxFreeHandlerID;
        ConstructorSet := true;
    end;

    // local procedure InitConstructor(TaxFreeRequest: Record "NPR Tax Free Request")
    // begin
    //     case true of
    //         TaxFreeRequest.IsThisHandler(TaxFreeGBI2.HandlerID):
    //             Constructor(TaxFreeGBI2);
    //         TaxFreeRequest.IsThisHandler(NPRTaxFreePTFOffline.HandlerID):
    //             Constructor(NPRTaxFreePTFOffline);
    //         TaxFreeRequest.IsThisHandler(NPRTaxFreePTFPI.HandlerID):
    //             Constructor(NPRTaxFreePTFPI);
    //         else begin
    //                 Error('');
    //             end;
    //     end;
    // end;

    local procedure OnIsValidTerminalIINResponse(var TaxFreeRequest: Record "NPR Tax Free Request"; MaskedCardNo: Text; var IsForeignIIN: Boolean)
    begin
        case true of
            TaxFreeRequest."Handler ID Enum" = TaxFreeRequest."Handler ID Enum"::GLOBALBLUE_I2:
                begin
                    MaskedCardNo := '1234567';

                    Constructor(TaxFreeRequest."Handler ID Enum"::GLOBALBLUE_I2);
                    TaxFreeHandlerInterface.OnIsValidTerminalIIN(TaxFreeRequest, MaskedCardNo, IsForeignIIN);
                end;
            TaxFreeRequest."Handler ID Enum" = TaxFreeRequest."Handler ID Enum"::PREMIER_PI:
                IsForeignIIN := true;
            else begin
                    Error('');
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Tax Free GB I2", 'OnBeforeIssueVoucher', '', true, true)]
    procedure OnBeforeIssueVoucherGB(var TaxFreeRequest: Record "NPR Tax Free Request"; CustomerXML: Text; PaymentXML: Text; PurchaseXML: Text; var Handeled: Boolean)
    var
        TaxFreeLibrary: codeunit "NPR Library - Tax Free";
    begin
        TaxFreeLibrary.IssueVoucherResponseGB(TaxFreeRequest, true);
        Handeled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Tax Free PTF PI", 'OnBeforeIssueVoucher', '', true, true)]
    procedure OnBeforeIssueVoucherPFTPI(var TaxFreeRequest: Record "NPR Tax Free Request"; RecRef: RecordRef; var Handeled: Boolean)
    var
        TaxFreeLibrary: codeunit "NPR Library - Tax Free";
    begin
        TaxFreeLibrary.IssueVoucherResponseGB(TaxFreeRequest, true);
        Handeled := true;
    end;
}
