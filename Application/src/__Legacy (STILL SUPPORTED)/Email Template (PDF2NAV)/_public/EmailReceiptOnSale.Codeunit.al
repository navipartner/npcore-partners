codeunit 6184655 "NPR E-mail Receipt On Sale"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendEmailReceiptOnSale(Rec);
    end;
}