codeunit 6014527 "NPR Credit Card Prot. Helper"
{
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
        EFTBINGroupPaymentLink: Record "NPR EFT BIN Group Paym. Link";
    begin
        if EFTBINRange.IsEmpty then
            exit(false); //Fallback to old prefix table

        if not EFTBINRange.FindMatch(CardPan) then
            exit(false);

        if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", LocationCode) then
            if LocationCode = '' then
                exit(false)
            else
                if not EFTBINGroupPaymentLink.Get(EFTBINRange."BIN Group Code", '') then
                    exit(false);

        exit(POSPaymentMethod.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;
}

