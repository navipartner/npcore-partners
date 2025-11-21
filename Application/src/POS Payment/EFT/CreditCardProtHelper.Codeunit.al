codeunit 6014527 "NPR Credit Card Prot. Helper"
{
#pragma warning disable AA0139
    Access = Internal;
    trigger OnRun()
    begin
    end;

    procedure FindPaymentType(CardPan: Code[20]; var POSPaymentMethod: Record "NPR POS Payment Method"; LocationCode: Code[10]): Boolean
    begin
        if MatchEFTBINRange(CardPan, POSPaymentMethod, LocationCode) then
            exit(true);
    end;

    procedure CutCardPan(CardPan: Code[100]): Code[30]
    var
        TextPosition: Integer;
    begin
        if StrLen(CardPan) = 0 then
            exit(CardPan);

        TextPosition := StrPos(CardPan, 'D');
        if TextPosition <> 0 then
            exit(CopyStr(CardPan, 1, TextPosition - 1));

        exit(CardPan)
    end;

    local procedure MatchEFTBINRange(CardPan: Code[20]; var POSPaymentMethod: Record "NPR POS Payment Method"; LocationCode: Code[10]): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if EFTBINRange.IsEmpty then
            exit(false); //Fallback to old prefix table

        if not EFTBINRange.FindMatch(CardPan) then
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

    procedure FindPaymentType(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var POSPaymentMethod: Record "NPR POS Payment Method"; LocationCode: Code[10]): Boolean
    begin
        if MatchEFTBINRange(EFTTransactionRequest, POSPaymentMethod, LocationCode) then
            exit(true);
    end;

    local procedure MatchEFTBINRange(EFTTransactionRequest: Record "NPR EFT Transaction Request"; var POSPaymentMethod: Record "NPR POS Payment Method"; LocationCode: Code[10]): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Payment Link";
    begin
        if EFTBINRange.IsEmpty then
            exit(false); //Fallback to old prefix table

        if not EFTBINRange.FindMatch(EFTTransactionRequest."Card Number") then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode, EFTTransactionRequest."Original POS Payment Type Code") then
            if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode, '') then
                if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '', EFTTransactionRequest."Original POS Payment Type Code") then
                    if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '', '') then
                        exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;
#pragma warning restore AA0139
}