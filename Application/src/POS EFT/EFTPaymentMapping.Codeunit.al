codeunit 6184510 "NPR EFT Payment Mapping"
{
    // NPR5.48/MMV /20190124 CASE 341237 Created object
    // NPR5.49/MMV /20190312 CASE 345188 Renamed object


    trigger OnRun()
    begin
    end;

    procedure FindPaymentType(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var PaymentTypePOS: Record "NPR Payment Type POS"): Boolean
    var
        SalePOS: Record "NPR Sale POS";
        LocationCode: Text;
    begin
        if SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.") then
            LocationCode := SalePOS."Location Code";

        if MatchBIN(EFTTransactionRequest, LocationCode, PaymentTypePOS) then
            exit(true);

        if MatchApplicationID(EFTTransactionRequest, LocationCode, PaymentTypePOS) then
            exit(true);

        if MatchIssuerID(EFTTransactionRequest, LocationCode, PaymentTypePOS) then
            exit(true);
    end;

    local procedure MatchBIN(EFTTransactionRequest: Record "NPR EFT Transaction Request"; LocationCode: Text; var PaymentTypePOS: Record "NPR Payment Type POS"): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Paym. Link";
    begin
        if EFTTransactionRequest."Card Number" = '' then
            exit(false);

        if not EFTBINRange.FindMatch(EFTTransactionRequest."Card Number") then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode) then
            if LocationCode = '' then
                exit(false)
            else
                if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '') then
                    exit(false);

        exit(PaymentTypePOS.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    local procedure MatchApplicationID(EFTTransactionRequest: Record "NPR EFT Transaction Request"; LocationCode: Text; var PaymentTypePOS: Record "NPR Payment Type POS"): Boolean
    begin
        //EFTTransactionRequest."Card Application ID"
        exit(false);
    end;

    local procedure MatchIssuerID(EFTTransactionRequest: Record "NPR EFT Transaction Request"; LocationCode: Text; var PaymentTypePOS: Record "NPR Payment Type POS"): Boolean
    begin
        //EFTTransactionRequest."Card Issuer ID"
        exit(false);
    end;
}

