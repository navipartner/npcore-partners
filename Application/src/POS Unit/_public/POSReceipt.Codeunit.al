codeunit 6059937 "NPR POS Receipt"
{
    procedure GetReceiptText(LineNo: Integer; RcptTxtProfileCode: Code[20]; var ReceiptText: Text[2048])
    var
        POSTicketRcpt: Record "NPR POS Ticket Rcpt. Text";
    begin
        POSTicketRcpt.SetRange("Rcpt. Txt. Profile Code", RcptTxtProfileCode);
        POSTicketRcpt.SetRange("Line No.", LineNo);
        if POSTicketRcpt.FindFirst() then
            ReceiptText := POSTicketRcpt."Receipt Text";
    end;

    procedure IsReceiptTextSet(POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile"): Boolean
    begin
        exit(ReceiptFooterMgt.IsReceiptTextSet(POSUnitReceiptTextProfile));
    end;

    [Obsolete('Breaking lines in Text Receipt preview is not used anymore', 'NPR23.0')]
    procedure SetDefaultBreakLineNumberOfCharacters(var POSUnitReceiptTextProfile: Record "NPR POS Unit Rcpt.Txt Profile")
    begin
        
    end;

    var
        ReceiptFooterMgt: Codeunit "NPR Receipt Footer Mgt.";
}
