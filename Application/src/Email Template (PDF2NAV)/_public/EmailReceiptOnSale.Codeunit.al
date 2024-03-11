codeunit 6184655 "NPR E-mail Receipt On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        EmailDocMgt: Codeunit "NPR E-mail Doc. Mgt.";
    begin
        EmailDocMgt.SendEmailReceiptOnSale(Rec);
    end;
}