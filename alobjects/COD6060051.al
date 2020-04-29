codeunit 6060051 "Item Wksht. Validate Process"
{
    // NPR5.25\BR \20160707 CASE 246088 New Codeunit

    Subtype = Test;

    trigger OnRun()
    begin
        ValidateItemWorksheetLineProcessing;
    end;

    var
        GlobalItemWorksheetLine: Record "Item Worksheet Line";

    [Test]
    procedure ValidateItemWorksheetLineProcessing()
    begin
        ValidateRegisterLine;
    end;

    [Normal]
    procedure SetGlobalItemWorksheetline(ParItemWorksheetLine: Record "Item Worksheet Line")
    begin
        GlobalItemWorksheetLine := ParItemWorksheetLine;
    end;

    procedure ValidateRegisterLine()
    var
        ItemWshtRegisterLine: Codeunit "Item Wsht.-Register Line";
        ItemWkshLine: Record "Item Worksheet Line";
    begin
        ItemWkshLine := GlobalItemWorksheetLine;
        ItemWshtRegisterLine.SetCalledFromTest(true);
        ItemWkshLine.Status := ItemWkshLine.Status::Validated;
        ItemWshtRegisterLine.Run(ItemWkshLine);
        Error('');
    end;
}

