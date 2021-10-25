codeunit 6014642 "NPR Ext. POS Sale Lookup"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
        LookupExtPOSSale(Rec);
    end;

    local procedure LookupExtPOSSale(ImportEntry: Record "NPR Nc Import Entry")
    var
        ExtPOSSale: Record "NPR External POS Sale";
        ExtPOSSaleProcessor: Codeunit "NPR Ext. POS Sale Processor";
        ExtPOSSaleCard: Page "NPR External POS Sale Card";
    begin
        ExtPOSSaleProcessor.GetExternalPOSSale(ImportEntry, ExtPOSSale);
        ExtPOSSaleCard.SetTableView(ExtPOSSale);
        ExtPOSSaleCard.Run();
    end;
}
