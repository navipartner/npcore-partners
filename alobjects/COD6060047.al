codeunit 6060047 "Item Wsht. Imp. Exp. Mgt."
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.19\BR\20160216  CASE 182391 Added function  ExportToExcel
    // NPR5.22\BR\20160321  CASE 182391 Added support for mapping an Excel file
    // NPR5.22\BR\20160325  CASE 237658 Added functions to support Web Service
    // NPR5.23\BR\20160525  CASE 242498 Added Event Publishers OnBeforeExportWorksheet(Variant)Line OnAfterImportWorksheet(Variant)Line
    // NPR5.23\BR\20160531  CASE 242498 Fixed issue not inserting item no. after import.
    // NPR5.28\BR\20161123  CASE 259200 Restruture Events to avoid memory leak


    trigger OnRun()
    begin
    end;

    var
        ItemWkshtXmlFile: File;
        ItemWorksheet: Record "Item Worksheet";
        XmlOUTStream: OutStream;
        XmlINStream: InStream;
        IsExported: Boolean;
        FromFile: Text[250];
        ToFile: Text[250];
        TextExportComplete: Label 'Export Complete.';
        TextExportFailed: Label 'Export Failed.';
        TextExportCancelled: Label 'Export Cancelled.';
        TextImportComplete: Label 'Import Complete.';
        TextImportFailed: Label 'Import Failed.';
        TextDialogImport: Label 'Import XML file';

        procedure Export(ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        if ItemWorksheet.Get(ItemWorksheetLine."Worksheet Template Name",ItemWorksheetLine."Worksheet Name") then begin
          ItemWorksheet.SetRange("Item Template Name",ItemWorksheetLine."Worksheet Template Name");
          ItemWorksheet.SetRange(Name,ItemWorksheetLine."Worksheet Name");
          ItemWkshtXmlFile.Create(TemporaryPath + 'ItemWorkSheet.xml');
          ItemWkshtXmlFile.CreateOutStream(XmlOUTStream);
          IsExported := XMLPORT.Export(XMLPORT::"Item Worksheet Import/Export", XmlOUTStream,ItemWorksheet);
          FromFile := ItemWkshtXmlFile.Name;
          ToFile := 'ItemWorkSheet.xml';
          ItemWkshtXmlFile.Close;
          if IsExported then begin
            if not Download(FromFile,'Download file','C:\Temp','Xml file(*.xml)|*.xml',ToFile) then
              Message(TextExportCancelled)
            else
              Message(TextExportComplete);
             Erase(FromFile);
          end else
            Message(TextExportFailed);
        end;
    end;

        procedure Import()
    var
        FileMgt: Codeunit "File Management";
    begin
        FromFile := FileMgt.UploadFile(TextDialogImport,'.xml');

        ItemWkshtXmlFile.Open(FromFile);
        ItemWkshtXmlFile.CreateInStream(XmlINStream);
        XMLPORT.Import(XMLPORT::"Item Worksheet Import/Export", XmlINStream);
        ItemWkshtXmlFile.Close;
    end;

        procedure ExportToExcel(ParItemWorksheetLine: Record "Item Worksheet Line")
    var
        ExportExcelItemWorksheet: Report "Export Excel Item Worksheet";
        ItemWorksheetLine: Record "Item Worksheet Line";
    begin
        //-NPR4.19
        ItemWorksheetLine.Reset;
        ItemWorksheetLine.CopyFilters(ParItemWorksheetLine);
        ItemWorksheetLine.SetRange("Worksheet Template Name",ParItemWorksheetLine."Worksheet Template Name");
        ItemWorksheetLine.SetRange("Worksheet Name",ParItemWorksheetLine."Worksheet Name");
        ExportExcelItemWorksheet.SetTableView(ItemWorksheetLine);
        ExportExcelItemWorksheet.Run;
        //+NPR4.19
    end;

        procedure ImportFromExcel(ItemWorksheet: Record "Item Worksheet")
    var
        ImportExcelItemWorksheet: Report "Import Excel Item Worksheet";
    begin
        ItemWorksheet.SetRange("Item Template Name",ItemWorksheet."Item Template Name");
        ItemWorksheet.SetRange(Name, ItemWorksheet.Name);
        ImportExcelItemWorksheet.SetTableView(ItemWorksheet);
        ImportExcelItemWorksheet.Run;
    end;

        procedure SelectExcelToMap(ItemWorksheet: Record "Item Worksheet")
    var
        MapExcelItemWorksheet: Report "Map Excel Item Worksheet";
    begin
        ItemWorksheet.SetRange("Item Template Name",ItemWorksheet."Item Template Name");
        ItemWorksheet.SetRange(Name, ItemWorksheet.Name);
        MapExcelItemWorksheet.SetTableView(ItemWorksheet);
        MapExcelItemWorksheet.Run;
    end;

        procedure SetImportActionWorksheetLine(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        //-NPR5.22
        if ItemWorksheetLine."Existing Item No." <> '' then
          ItemWorksheetLine.Action := ItemWorksheetLine.Action :: UpdateAndCreateVariants
        else
          //-NPR5.23 [242498]
          //ItemWorksheetLine.Action := ItemWorksheetLine.Action :: CreateNew;
          ItemWorksheetLine.Validate(Action,ItemWorksheetLine.Action :: CreateNew);
          //+NPR5.23 [242498]
        //+NPR5.22
    end;

        procedure SetImportActionWorksheetVariantLine(ItemWorksheetLine: Record "Item Worksheet Line";ActionIfVariantUnknown: Option Skip,Create;ActionIfVarietyUnknown: Option Skip,Create;var ItemWorksheetVariantLine: Record "Item Worksheet Variant Line")
    var
        VarietyValue: Record "Variety Value";
    begin
        //-NPR5.22
        if ItemWorksheetVariantLine."Existing Variant Code" <> '' then begin
          ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action :: Update;
        end else begin
          if not VarietyValue.Get(ItemWorksheetLine."Variety 1",ItemWorksheetLine."Variety 1 Table (Base)",ItemWorksheetVariantLine."Variety 1 Value") then begin
            if ActionIfVarietyUnknown = ActionIfVarietyUnknown :: Create then
              ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action:: CreateNew
            else
              ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action:: Skip;
           end else begin
            if ActionIfVariantUnknown = ActionIfVariantUnknown :: Create then
              ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action:: CreateNew
            else
              ItemWorksheetVariantLine.Action := ItemWorksheetVariantLine.Action:: Skip;
          end;
          ItemWorksheetVariantLine.Validate(Action);
        end;
        //+NPR5.22
    end;

        procedure RaiseOnBeforeExportWorksheetLine(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        //-NPR5.28 [259200]
        OnBeforeExportWorksheetLine(ItemWorksheetLine);
        //+NPR5.28 [259200]
    end;

        procedure RaiseOnBeforeExportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "Item Worksheet Variant Line")
    begin
        //-NPR5.28 [259200]
        OnBeforeExportWorksheetVariantLine(ItemWorksheetVariantLine);
        //+NPR5.28 [259200]
    end;

        procedure RaiseOnAfterImportWorksheetLine(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
        //-NPR5.28 [259200]
        OnAfterImportWorksheetLine(ItemWorksheetLine);
        //+NPR5.28 [259200]
    end;

        procedure RaiseOnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "Item Worksheet Variant Line")
    begin
        //-NPR5.28 [259200]
        OnAfterImportWorksheetVariantLine(ItemWorksheetVariantLine);
        //+NPR5.28 [259200]
    end;

    local procedure "----Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportWorksheetLine(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeExportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "Item Worksheet Variant Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterImportWorksheetLine(var ItemWorksheetLine: Record "Item Worksheet Line")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterImportWorksheetVariantLine(var ItemWorksheetVariantLine: Record "Item Worksheet Variant Line")
    begin
    end;
}

