codeunit 6014637 "NPR Ext. POS Sale Converter"
{
    Access = Internal;
    TableNo = "NPR External POS Sale";
    trigger OnRun()
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        POSCreateEntry.CreatePOSEntryFromExternalPOSSale(Rec);
    end;

}
