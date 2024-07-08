codeunit 6184650 "NPR POS Print Receipt On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        POSSalesPrintMgt: Codeunit "NPR POS Sales Print Mgt.";
    begin
        POSSalesPrintMgt.PrintPOSEntrySalesReceipt(Rec);
    end;
}