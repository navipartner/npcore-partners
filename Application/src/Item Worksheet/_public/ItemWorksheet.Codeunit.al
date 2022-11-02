codeunit 6014440 "NPR Item Worksheet"
{
    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnBeforeExportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    procedure OnAfterImportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [BusinessEvent(false)]
    procedure OnAfterRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    procedure ItemWorksheetLineRunCheck(var ItemWorksheetLine: Record "NPR Item Worksheet Line"; StopOnError: Boolean; CalledFromRegister: Boolean)
    var
        ItemWshtCheckLine: Codeunit "NPR Item Wsht.-Check Line";
    begin
        ItemWshtCheckLine.RunCheck(ItemWorksheetLine, StopOnError, CalledFromRegister);
    end;

    procedure ItemWorksheetRunRegisterLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line"): Boolean
    var
        ItemWshtRegisterLine: Codeunit "NPR Item Wsht.Register Line";
    begin
        exit(ItemWshtRegisterLine.Run(ItemWorksheetLine));
    end;
}