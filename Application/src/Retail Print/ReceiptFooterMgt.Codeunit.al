codeunit 6014424 "NPR Receipt Footer Mgt."
{
    Access = Internal;

    [Obsolete('Breaking lines, in Text Receipt preview, is not used anymore', 'NPR23.0')]
    procedure SetDefaultBreakLineNumberOfCharacters(var POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    begin

    end;

    procedure IsReceiptTextSet(POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile"): Boolean
    var
        TicketRcptText: Record "NPR POS Ticket Rcpt. Text";
    begin
        TicketRcptText.Reset();
        TicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitReceiptTextProfile.Code);
        exit(not TicketRcptText.IsEmpty());
    end;

    [Obsolete('Splitting text area, in Text Receipt preview, into the Text Receipt Lines is not supported anymore.', 'NPR23.0')]
    procedure BreakSalesTicketReceiptText(var POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    begin

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
    begin
        TicketRcptText.Reset();
        TicketRcptText.SetRange("Rcpt. Txt. Profile Code", POSUnitReceiptTextProfile.Code);
    end;       
}

