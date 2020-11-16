codeunit 6014527 "NPR Credit Card Prot. Helper"
{
    trigger OnRun()
    begin
    end;

    procedure FindPaymentType(CardPan: Code[20]; var PaymentTypePOS: Record "NPR Payment Type POS"; LocationCode: Code[10]): Boolean
    var
        PaymentTypePrefix: Record "NPR Payment Type - Prefix";
        "Filter": Text[30];
        Len: Integer;
    begin
        if MatchEFTBINRange(CardPan, PaymentTypePOS, LocationCode) then
            exit(true);

        Filter := CardPan;
        Len := StrLen(Filter);
        while Len > 0 do begin
            PaymentTypePrefix.SetRange(PaymentTypePrefix.Prefix, Filter);
            if PaymentTypePrefix.Find('-') then
                repeat
                    PaymentTypePOS.Reset;
                    PaymentTypePOS.SetCurrentKey("No.", "Via Terminal");
                    PaymentTypePOS.SetRange("No.", PaymentTypePrefix."Payment Type");
                    PaymentTypePOS.SetRange("Via Terminal", true);
                    PaymentTypePOS.SetRange("Location Code", LocationCode);
                    if PaymentTypePOS.FindFirst then
                        exit(true)
                    else
                        if LocationCode <> '' then begin
                            PaymentTypePOS.SetRange("Location Code", '');
                            if PaymentTypePOS.FindFirst then
                                exit(true);
                        end;
                until (PaymentTypePrefix.Next = 0);
            Len := Len - 1;
            Filter := CopyStr(Filter, 1, Len);
        end;
        exit(false);
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

    local procedure MatchEFTBINRange(CardPan: Code[20]; var PaymentTypePOS: Record "NPR Payment Type POS"; LocationCode: Code[10]): Boolean
    var
        EFTBINRange: Record "NPR EFT BIN Range";
        EFTBINGroup: Record "NPR EFT BIN Group";
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

        exit(PaymentTypePOS.Get(EFTBINGroupPaymentLink."Payment Type POS"));
    end;
}

