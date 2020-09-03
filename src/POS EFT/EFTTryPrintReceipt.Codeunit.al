codeunit 6184509 "NPR EFT Try Print Receipt"
{
    // NPR5.49/MMV /20190401 CASE 345188 Created object

    TableNo = "NPR EFT Transaction Request";

    trigger OnRun()
    begin
        Rec.PrintReceipts(false);
    end;
}

