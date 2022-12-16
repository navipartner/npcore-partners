codeunit 6060021 "NPR EFT Transaction Pub. Mgt."
{
    Access = Public;

    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";

    procedure GetEFTReceiptText(SalesTicketNo: Code[20]; ReceiptNo: Integer): Text
    begin
        exit(EFTTransactionMgt.GetEFTReceiptText(SalesTicketNo, ReceiptNo));
    end;
}
