codeunit 6014642 "NPR Ext. POS Sale Lookup" implements "NPR Nc Import List ILookup"
{
    Access = Internal;
    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
    end;

    internal procedure RunLookupImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    begin
        LookupExtPOSSale(ImportEntry);
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
