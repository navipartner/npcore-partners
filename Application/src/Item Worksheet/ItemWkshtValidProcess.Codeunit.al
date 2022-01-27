codeunit 6060051 "NPR Item Wksht.Valid. Process"
{
    Access = Internal;
    Subtype = Test;

    trigger OnRun()
    begin
        ValidateItemWorksheetLineProcessing();
    end;

    var
        GlobalItemWorksheetLine: Record "NPR Item Worksheet Line";

    [Test]
    procedure ValidateItemWorksheetLineProcessing()
    begin
        ValidateRegisterLine();
    end;

    [Normal]
    procedure SetGlobalItemWorksheetline(ParItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        GlobalItemWorksheetLine := ParItemWorksheetLine;
    end;

    procedure ValidateRegisterLine()
    var
        ItemWkshLine: Record "NPR Item Worksheet Line";
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        ItemWkshLine := GlobalItemWorksheetLine;
        ItemWshtRegisterLine.SetCalledFromTest(true);
        ItemWkshLine.Status := ItemWkshLine.Status::Validated;
        ItemWshtRegisterLine.Run(ItemWkshLine);
        Error('');
    end;
}

