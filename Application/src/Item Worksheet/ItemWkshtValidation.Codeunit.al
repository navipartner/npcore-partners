codeunit 6060052 "NPR Item Wksht. Validation"
{
    Access = Internal;
    TableNo = "NPR Item Worksheet Line";

    trigger OnRun()
    begin
        ClearLastError();
        ValidateItemWorksheetLineProcessing(Rec);
    end;

    procedure ValidateItemWorksheetLineProcessing(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        ItemWshtRegisterLine.SetCalledFromTest(true);
        ItemWorksheetLine.Status := ItemWorksheetLine.Status::Validated;
        ItemWshtRegisterLine.Run(ItemWorksheetLine);
        Error(''); // If the preceding Run call has not thrown an error, an empty one is thrown to roll back changes
    end;
}
