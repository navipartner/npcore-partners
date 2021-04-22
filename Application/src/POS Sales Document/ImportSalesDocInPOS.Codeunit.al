codeunit 6014562 "NPR Import Sales Doc. In POS"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        RetailSalesDocImpMgt.SynchronizePOSSaleWithDocument(Rec);
    end;
}