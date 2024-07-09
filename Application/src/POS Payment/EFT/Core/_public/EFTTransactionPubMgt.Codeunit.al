codeunit 6060021 "NPR EFT Transaction Pub. Mgt."
{
    Access = Public;

    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";

    [Obsolete('Pending Removal due to move to a new function GetEFTReceiptText because this one supports only one sucesfull EFT Transaction, not all of them.', '2024-03-28')]
    procedure GetEFTReceiptText(SalesTicketNo: Code[20]; ReceiptNo: Integer): Text
    begin
        exit(EFTTransactionMgt.GetEFTReceiptText(SalesTicketNo, ReceiptNo));
    end;

    procedure GetEFTReceiptText(SalesTicketNo: Code[20]): Text
    begin
        exit(EFTTransactionMgt.GetEFTReceiptText(SalesTicketNo));
    end;
}
