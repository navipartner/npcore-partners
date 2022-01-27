codeunit 6060047 "NPR Item Wsht. Imp. Exp."
{
    Access = Internal;
    var
        ItemWorksheet: Record "NPR Item Worksheet";
        IsExported: Boolean;
        XmlINStream: InStream;
        TextExportCancelledMsg: Label 'Export Cancelled.';
        TextExportCompleteMsg: Label 'Export Complete.';
        TextExportFailedMsg: Label 'Export Failed.';
        XmlOUTStream: OutStream;
        FromFile: Text;
        ToFile: Text;

    procedure Export(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        if ItemWorksheet.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name") then begin
            ItemWorksheet.SetRange("Item Template Name", ItemWorksheetLine."Worksheet Template Name");
            ItemWorksheet.SetRange(Name, ItemWorksheetLine."Worksheet Name");
            TempBlob.CreateOutStream(XmlOUTStream);
            IsExported := XMLPORT.Export(XMLPORT::"NPR Item Worksh. Import/Export", XmlOUTStream, ItemWorksheet);
            TempBlob.CreateInStream(XmlINStream);
            if IsExported then begin
                if not DownloadFromStream(XmlINStream, 'Download file', 'C:\Temp', 'Xml file(*.xml)|*.xml', ToFile) then
                    Message(TextExportCancelledMsg)
                else
                    Message(TextExportCompleteMsg);
            end else
                Message(TextExportFailedMsg);
        end;
    end;

    procedure Import()
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
    begin
        FromFile := FileMgt.BLOBImport(TempBlob, '.xml');

        TempBlob.CreateInStream(XmlINStream);
        XMLPORT.Import(XMLPORT::"NPR Item Worksh. Import/Export", XmlINStream);
    end;

    procedure ExportToExcel(ParItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        ItemWorksheetLine: Record "NPR Item Worksheet Line";
        ExportExcelItemWorksheet: Report "NPR Export Excel Item Worksh.";
    begin
        ItemWorksheetLine.Reset();
        ItemWorksheetLine.CopyFilters(ParItemWorksheetLine);
        ItemWorksheetLine.SetRange("Worksheet Template Name", ParItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name", ParItemWorksheetLine."Worksheet Name");
        ExportExcelItemWorksheet.SetTableView(ItemWorksheetLine);
        ExportExcelItemWorksheet.Run();
    end;

    procedure ImportFromExcel(ItemWorksheet: Record "NPR Item Worksheet")
    var
        ImportExcelItemWorksheet: Report "NPR Import Excel Item Worksh.";
    begin
        ItemWorksheet.SetRange("Item Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheet.SetRange(Name, ItemWorksheet.Name);
        ImportExcelItemWorksheet.SetTableView(ItemWorksheet);
        ImportExcelItemWorksheet.Run();
    end;

    procedure SelectExcelToMap(ItemWorksheet: Record "NPR Item Worksheet")
    var
        MapExcelItemWorksheet: Report "NPR Map Excel Item Worksh.";
    begin
        ItemWorksheet.SetRange("Item Template Name", ItemWorksheet."Item Template Name");
        ItemWorksheet.SetRange(Name, ItemWorksheet.Name);
        MapExcelItemWorksheet.SetTableView(ItemWorksheet);
        MapExcelItemWorksheet.Run();
    end;

    procedure SetImportActionWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        if ItemWorksheetLine."Existing Item No." <> '' then
            ItemWorksheetLine.Action := ItemWorksheetLine.Action::UpdateAndCreateVariants
        else
            ItemWorksheetLine.Validate(Action, ItemWorksheetLine.Action::CreateNew);
    end;

    procedure SetImportActionWorksheetVariantLine(ItemWorksheetLine: Record "NPR Item Worksheet Line"; ActionIfVariantUnknown: Option Skip,Create; ActionIfVarietyUnknown: Option Skip,Create; var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    var
        VarietyValue: Record "NPR Variety Value";
    begin
        if ItemWorksheetVariantLine."Existing Variant Code" <> '' then begin
            ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Update;
        end else begin
            if not VarietyValue.Get(ItemWorksheetLine."Variety 1", ItemWorksheetLine."Variety 1 Table (Base)", ItemWorksheetVariantLine."Variety 1 Value") then begin
                if ActionIfVarietyUnknown = ActionIfVarietyUnknown::Create then
                    ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew
                else
                    ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Skip;
            end else begin
                if ActionIfVariantUnknown = ActionIfVariantUnknown::Create then
                    ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::CreateNew
                else
                    ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action::Skip;
            end;
            ItemWorksheetVariantLine.Validate(Action);
        end;
    end;

    procedure RaiseOnBeforeExportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        OnBeforeExportWorksheetLine(ItemWorksheetLine);
    end;

    procedure RaiseOnBeforeExportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
        OnBeforeExportWorksheetVariantLine(ItemWorksheetVariantLine);
    end;

    procedure RaiseOnAfterImportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        OnAfterImportWorksheetLine(ItemWorksheetLine);
    end;

    procedure RaiseOnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
        OnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterImportWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
    begin
    end;
}

