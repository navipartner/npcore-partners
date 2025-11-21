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
        if MatchIssuerID(EFTTransactionRequest."Card Issuer ID", EFTTransactionRequest."Original POS Payment Type Code", LocationCode, POSPaymentMethod) then
            exit(true);
        if MatchApplicationID(EFTTransactionRequest."Card Application ID", EFTTransactionRequest."Original POS Payment Type Code", LocationCode, POSPaymentMethod) then
            exit(true);
        if MatchBIN(EFTTransactionRequest."Card Number", EFTTransactionRequest."Original POS Payment Type Code", LocationCode, POSPaymentMethod) then
            exit(true);
    end;

    procedure MatchBIN(CardNumber: Text; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if CardNumber = '' then
            exit(false);

        if not EFTBINRange.FindMatch(CardNumber) then
            exit(false);

        EFTBINGroupPaymentLink.SetRange("Group Code", EFTBINRange."BIN Group Code");
        EFTBINGroupPaymentLink.SetRange("Location Code", LocationCode);
        if not EFTBINGroupPaymentLink.FindFirst() then
            if LocationCode = '' then
                exit(false)
            else begin
                EFTBINGroupPaymentLink.SetRange("Group Code", EFTBINRange."BIN Group Code");
                EFTBINGroupPaymentLink.SetRange("Location Code", '');
                if not EFTBINGroupPaymentLink.FindFirst() then
                    exit(false);
            end;

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    procedure MatchApplicationID(ApplicationID: Text; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTAidMap: Record "NPR EFT Aid Rid Mapping";
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if ApplicationID = '' then
            exit(false);
        if (not EFTAidMap.Get(ApplicationID)) then begin
            EFTAidMap.SetFilter(RID, ApplicationID.Substring(1, 10) + '*');
            if (not EFTAidMap.FindFirst()) then
                exit(false);
        end;
        if not EFTBINGroup.Get(EFTAidMap."Bin Group Code") then
            exit(false);

        EFTBINGroupPaymentLink.SetRange("Group Code", EFTBINGroup.Code);
        EFTBINGroupPaymentLink.SetRange("Location Code", LocationCode);
        if not EFTBINGroupPaymentLink.FindFirst() then
            if LocationCode = '' then
                exit(false)
            else begin
                EFTBINGroupPaymentLink.SetRange("Group Code", EFTBINGroup.Code);
                EFTBINGroupPaymentLink.SetRange("Location Code", '');
                if not EFTBINGroupPaymentLink.FindFirst() then
                    exit(false);
            end;

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    local procedure MatchIssuerID(CardIssuerId: Text[30]; OriginalPOSPaymentMethodType: Code[10]; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if CardIssuerId = '' then
            exit(false);

        EFTBINGroup.SetRange("Card Issuer ID", CardIssuerId);
        if not EFTBINGroup.FindFirst() then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, LocationCode, OriginalPOSPaymentMethodType) then
            if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, LocationCode, '') then
                if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, '', OriginalPOSPaymentMethodType) then
                    if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, '', '') then
                        exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    procedure MatchBIN(CardNumber: Text; OriginalPOSPaymentMethodType: Code[10]; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if CardNumber = '' then
            exit(false);

        if not EFTBINRange.FindMatch(CardNumber) then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode, OriginalPOSPaymentMethodType) then
            if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode, '') then
                if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '', OriginalPOSPaymentMethodType) then
                    if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '', '') then
                        exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;

    procedure MatchApplicationID(CardApplicationId: Text; OriginalPOSPaymentMethodType: Code[10]; LocationCode: Text; var POSPaymentMethod: Record "NPR POS Payment Method"): Boolean
    var
        EFTAidMap: Record "NPR EFT Aid Rid Mapping";
        EFTBINGroup: Record "NPR EFT BIN Group";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if CardApplicationId = '' then
            exit(false);
        if (not EFTAidMap.Get(CardApplicationId)) then begin
            EFTAidMap.SetFilter(RID, CardApplicationId.Substring(1, 10) + '*');
            if (not EFTAidMap.FindFirst()) then
                exit(false);
        end;
        if not EFTBINGroup.Get(EFTAidMap."Bin Group Code") then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, LocationCode, OriginalPOSPaymentMethodType) then
            if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, LocationCode, '') then
                if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, '', OriginalPOSPaymentMethodType) then
                    if not EFTBINGroupPaymentLink.Get(EFTBINGroup.Code, '', '') then
                        exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;
}