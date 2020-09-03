codeunit 6060051 "NPR Item Wksht.Valid. Process"
{
    // NPR5.25\BR \20160707 CASE 246088 New Codeunit

    Subtype = Test;

    trigger OnRun()
    begin
        ValidateItemWorksheetLineProcessing;
    end;

    var
        GlobalItemWorksheetLine: Record "NPR Item Worksheet Line";

    [Test]
    procedure ValidateItemWorksheetLineProcessing()
    begin
        ValidateRegisterLine;
    end;

    [Normal]
    procedure SetGlobalItemWorksheetline(ParItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        GlobalItemWorksheetLine := ParItemWorksheetLine;
    end;

    procedure ValidateRegisterLine()
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
        ItemWkshLine: Record "NPR Item Worksheet Line";
    begin
        ItemWkshLine := GlobalItemWorksheetLine;
        ItemWshtRegisterLine.SetCalledFromTest(true);
        ItemWkshLine.Status := ItemWkshLine.Status::Validated;
        ItemWshtRegisterLine.Run(ItemWkshLine);
        Error('');
    end;
}

