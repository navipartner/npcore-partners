codeunit 6014424 "NPR Receipt Footer Mgt."
{
    procedure SetDefaultBreakLineNumberOfCharacters(var POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    begin
        if POSUnitReceiptTextProfile."Break Line" <> 0 then
            exit;
        POSUnitReceiptTextProfile."Break Line" := 40;
    end;

    procedure IsReceiptTextSet(POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile"): Boolean
    begin
        exit(StrLen(POSUnitReceiptTextProfile."Sales Ticket Rcpt. Text") > 0);
    end;

    procedure BreakSalesTicketReceiptText(var POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    var
        TicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        ReceiptTextTokens: List of [Text];
        ReceiptText: Text;
        PreviewReceiptText: Text;
        LineNo: Integer;
    begin
        if not IsReceiptTextSet(POSUnitReceiptTextProfile) then
            exit;
        SetDefaultBreakLineNumberOfCharacters(POSUnitReceiptTextProfile);
        TicketRcptText.DeleteAllForCurrProfile(POSUnitReceiptTextProfile.Code);
        ReceiptTextTokens := POSUnitReceiptTextProfile."Sales Ticket Rcpt. Text".Split(' ');
        foreach ReceiptText in ReceiptTextTokens do begin
            if StrLen(PreviewReceiptText + ReceiptText + ' ') < POSUnitReceiptTextProfile."Break Line" then
                PreviewReceiptText += ReceiptText + ' '
            else begin
                LineNo += 10000;
                TicketRcptText.Add(POSUnitReceiptTextProfile.Code, LineNo, PreviewReceiptText);
                Clear(PreviewReceiptText);
                PreviewReceiptText := ReceiptText + ' ';
            end;
        end;
        if PreviewReceiptText <> '' then begin
            TicketRcptText.Add(POSUnitReceiptTextProfile.Code, LineNo + 10000, PreviewReceiptText);
        end;
    end;

    procedure GetSalesTicketReceiptText(var PreviewReceiptText: Text; POSUnit: Record "NPR POS Unit")
    var
        POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile";
    begin
        clear(PreviewReceiptText);
        if not POSUnitReceiptTextProfile.Get(POSUnit."POS Unit Receipt Text Profile") then
            exit;
        GetSalesTicketReceiptText(PreviewReceiptText, POSUnitReceiptTextProfile);
    end;

    procedure GetSalesTicketReceiptText(var PreviewReceiptText: Text; POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    var
        TicketRcptText: Record "NPR POS Ticket Rcpt. Text";
        CrLf: Text;
        PreviewReceiptTextTokensCount: Integer;
        Iteration: Integer;
    begin
        clear(PreviewReceiptText);
        TicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitReceiptTextProfile.Code);
        if TicketRcptText.IsEmpty() then
            exit;
        CrLf[1] := 13;
        CrLf[2] := 10;
        PreviewReceiptTextTokensCount := TicketRcptText.Count();
        repeat
            PreviewReceiptText += TicketRcptText."Receipt Text";
            Iteration += 1;
            if Iteration < PreviewReceiptTextTokensCount then
                PreviewReceiptText += CrLf;
        until TicketRcptText.Next() = 0;
    end;

    procedure GetSalesTicketReceiptText(var TicketRcptText: Record "NPR POS Ticket Rcpt. Text"; POSUnit: Record "NPR POS Unit")
    var
        POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile";
    begin
        TicketRcptText.Reset();
        if not POSUnitReceiptTextProfile.Get(POSUnit."POS Unit Receipt Text Profile") then
            exit;
        GetSalesTicketReceiptText(TicketRcptText, POSUnitReceiptTextProfile);
    end;

    procedure GetSalesTicketReceiptText(var TicketRcptText: Record "NPR POS Ticket Rcpt. Text"; POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    var
        CrLf: Text;
        PreviewReceiptTextTokensCount: Integer;
        Iteration: Integer;
    begin
        TicketRcptText.Reset();
        TicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitReceiptTextProfile.Code);
    end;
}

