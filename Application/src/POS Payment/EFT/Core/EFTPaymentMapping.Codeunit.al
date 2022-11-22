codeunit 6184510 "NPR EFT Payment Mapping"
{
    Access = Internal;

    procedure FindPaymentType(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        LocationCode: Text;
    begin
        if SalePOS.Get(EFTTransactionRequest."Register No.", EFTTransactionRequest."Sales Ticket No.") then
            LocationCode := SalePOS."Location Code";
        if MatchIssuerID(EFTTransactionRequest, LocationCode, POSPaymentMethod) then
            exit(true);
        if MatchApplicationID(EFTTransactionRequest, LocationCode, POSPaymentMethod) then
            exit(true);
        if MatchBIN(EFTTransactionRequest, LocationCode, POSPaymentMethod) then
            exit(true);
    end;

    local procedure MatchBIN(EFTTransactionRequest: Record "NPR EFT Transaction Request"; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
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

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    local procedure MatchIssuerID(EFTTransactionRequest: Record "NPR EFT Transaction Request"; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Paym. Link";
    begin
        if EFTTransactionRequest."Card Issuer ID" = '' then
            exit(false);

        EFTBINGroup.SetRange("Card Issuer ID", EFTTransactionRequest."Card Issuer ID");
        if not EFTBINGroup.FindFirst() then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, LocationCode) then
            if LocationCode = '' then
                exit(false)
            else
                if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, '') then
                    exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    local procedure MatchApplicationID(EFTTransactionRequest: Record "NPR EFT Transaction Request"; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTAidMap: Record "NPR EFT Aid Rid Mapping";
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Paym. Link";
    begin
        if EFTTransactionRequest."Card Application ID" = '' then
            exit(false);
        if (not EFTAidMap.Get(EFTTransactionRequest."Card Application ID")) then begin
            EFTAidMap.SetFilter(RID, EFTTransactionRequest."Card Application ID".Substring(1, 10) + '*');
            if (not EFTAidMap.FindFirst()) then
                exit(false);
        end;
        if not EFTBINGroup.Get(EFTAidMap."Bin Group Code") then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, LocationCode) then
            if LocationCode = '' then
                exit(false)
            else
                if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, '') then
                    exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;
}

