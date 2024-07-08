codeunit 6060047 "NPR Item Wsht. Imp. Exp."
{
    Access = Internal;

    var
        _ItemWorksheet: Record "NPR Item Worksheet";
        IsExported: Boolean;
        XmlINStream: InStream;
        TextExportCancelledMsg: Label 'Export Cancelled.';
        TextExportCompleteMsg: Label 'Export Complete.';
        TextExportFailedMsg: Label 'Export Failed.';
        XmlOUTStream: OutStream;
        FromFile: Text;
        ToFile: Text;

    internal procedure Export(ItemWorksheetLine: Record "NPR Item Worksheet Line")
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        if _ItemWorksheet.Get(ItemWorksheetLine."Worksheet Template Name", ItemWorksheetLine."Worksheet Name") then begin
            _ItemWorksheet.SetRange("Item Template Name", ItemWorksheetLine."Worksheet Template Name");
            _ItemWorksheet.SetRange(Name, ItemWorksheetLine."Worksheet Name");
            TempBlob.CreateOutStream(XmlOUTStream);
            IsExported := XMLPORT.Export(XMLPORT::"NPR Item Worksh. Import/Export", XmlOUTStream, _ItemWorksheet);
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

    internal procedure Import()
    var
        FileMgt: Codeunit "File Management";
        TempBlob: Codeunit "Temp Blob";
    begin
        FromFile := FileMgt.BLOBImport(TempBlob, '.xml');

        TempBlob.CreateInStream(XmlINStream);
        XMLPORT.Import(XMLPORT::"NPR Item Worksh. Import/Export", XmlINStream);
    end;

    internal procedure ExportToExcel(ParItemWorksheetLine: Record "NPR Item Worksheet Line")
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

    internal procedure ImportFromExcel(NprItemWorksheet: Record "NPR Item Worksheet")
    var
        ImportExcelItemWorksheet: Report "NPR Import Excel Item Worksh.";
    begin
        NprItemWorksheet.SetRange("Item Template Name", NprItemWorksheet."Item Template Name");
        NprItemWorksheet.SetRange(Name, NprItemWorksheet.Name);
        ImportExcelItemWorksheet.SetTableView(NprItemWorksheet);
        ImportExcelItemWorksheet.Run();
    end;

    internal procedure SelectExcelToMap(NprItemWorksheet: Record "NPR Item Worksheet")
    var
        MapExcelItemWorksheet: Report "NPR Map Excel Item Worksh.";
    begin
        NprItemWorksheet.SetRange("Item Template Name", NprItemWorksheet."Item Template Name");
        NprItemWorksheet.SetRange(Name, NprItemWorksheet.Name);
        MapExcelItemWorksheet.SetTableView(NprItemWorksheet);
        MapExcelItemWorksheet.Run();
    end;

    internal procedure SetImportActionWorksheetLine(var ItemWorksheetLine: Record "NPR Item Worksheet Line")
    begin
        if ItemWorksheetLine."Existing Item No." <> '' then
            ItemWorksheetLine.Action := ItemWorksheetLine.Action::UpdateAndCreateVariants
        else
            ItemWorksheetLine.Validate(Action, ItemWorksheetLine.Action::CreateNew);
    end;

    internal procedure SetImportActionWorksheetVariantLine(ItemWorksheetLine: Record "NPR Item Worksheet Line"; ActionIfVariantUnknown: Option Skip,Create; ActionIfVarietyUnknown: Option Skip,Create; var ItemWorksheetVariantLine: Record "NPR Item Worksh. Variant Line")
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
}
