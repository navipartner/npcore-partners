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
    internal procedure OnAfterImportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;
}