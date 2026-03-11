codeunit 6151088 "NPR JQ Cleanup Park Sale"
{
    Access = Internal;
    TableNo = "NPR POS Sale";

    var
        _POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        _SavePOSSaleBL: Codeunit "NPR POS Action: SavePOSSvSl B";
        _POSCreateEntry: Codeunit "NPR POS Create Entry";

    trigger OnRun()
    begin
        _SavePOSSaleBL.CreateSavedSaleEntry(Rec, _POSSavedSaleEntry);
        _POSCreateEntry.InsertParkSaleEntry(Rec."Register No.", Rec."Salesperson Code");
        Rec.Delete(true);
    end;
}
