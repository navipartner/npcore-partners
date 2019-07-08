codeunit 6151092 "Nc RapidConnect Import Mgt."
{
    // NC2.12/MHA /20180418  CASE 308107 Object created - RapidStart with NaviConnect
    // NC2.16/MHA /20180906  CASE 313184 Apply Package has COMMIT in RapidStart meaning Import and Apply must be split
    // NC2.17/MHA /20181116  CASE 335927 Removed green code and added Xml Import

    TableNo = "Nc Import Entry";

    trigger OnRun()
    begin
        //-NC2.17 [335927]
        //ImportExcel(Rec);
        ImportRapidConnect(Rec);
        //+NC2.17 [335927]
    end;

    local procedure ImportRapidConnect(var NcImportEntry: Record "Nc Import Entry")
    var
        NcRapidConnectSetup: Record "Nc RapidConnect Setup";
        DataLogMgt: Codeunit "Data Log Management";
        XmlDoc: DotNet XmlDocument;
        XmlLoaded: Boolean;
        TableIdFilter: Text;
    begin
        NcRapidConnectSetup.SetRange("Import Type",NcImportEntry."Import Type");
        NcRapidConnectSetup.SetFilter("Package Code",'<>%1','');
        if not NcRapidConnectSetup.FindSet then
          exit;

        //-NC2.17 [335927]
        XmlLoaded := TryLoadXml(NcImportEntry,XmlDoc);
        if XmlLoaded then
          TableIdFilter := GetTableIdFilter(XmlDoc);
        //+NC2.17 [335927]

        repeat
          DataLogMgt.DisableDataLog(NcRapidConnectSetup."Disable Data Log on Import");
          //-NC2.17 [335927]
          //ImportExcelPackage(NcRapidConnectSetup,NcImportEntry);
          if XmlLoaded then
            ImportXmlPackage(NcRapidConnectSetup,XmlDoc)
          else
            ImportExcelPackage(NcRapidConnectSetup,NcImportEntry);
          //+NC2.17 [335927]

        until NcRapidConnectSetup.Next = 0;

        //-NC2.16 [313184]
        Commit;
        asserterror begin
          NcRapidConnectSetup.FindSet;
          repeat
            DataLogMgt.DisableDataLog(NcRapidConnectSetup."Disable Data Log on Import");
            //-NC2.17 [335927]
            //ApplyExcelPackage(NcRapidConnectSetup,NcImportEntry);
            if XmlLoaded then
              ApplyXmlPackage(NcRapidConnectSetup,TableIdFilter)
            else
              ApplyExcelPackage(NcRapidConnectSetup,NcImportEntry);
            //+NC2.17 [335927]
          until NcRapidConnectSetup.Next = 0;
          Commit;
          Error('');
        end;
        //+NC2.16 [313184]

        DataLogMgt.DisableDataLog(false);
    end;

    local procedure ImportExcelPackage(NcRapidConnectSetup: Record "Nc RapidConnect Setup";var NcImportEntry: Record "Nc Import Entry")
    var
        ConfigPackage: Record "Config. Package";
        TempBlob: Record TempBlob temporary;
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageTable: Record "Config. Package Table";
        ConfigExcelExchange: Codeunit "Config. Excel Exchange";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        TableIdFilter: Text;
    begin
        if NcRapidConnectSetup."Package Code" = '' then
          exit;

        LoadExcel(NcImportEntry,NcRapidConnectSetup."Package Code",TempBlob,TableIdFilter);

        //-NC2.12 [313362]
        ConfigExcelExchange.SetHideDialog(not UseDialog());
        //+NC2.12 [313362]
        ConfigExcelExchange.ImportExcel(TempBlob);

        ConfigPackage.Get(NcRapidConnectSetup."Package Code");
        ConfigPackageTable.SetRange("Package Code",NcRapidConnectSetup."Package Code");
        if ConfigPackage."Exclude Config. Tables" then begin
          ConfigPackageTable.FilterGroup(40);
          ConfigPackageTable.SetFilter("Table ID",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
            DATABASE::"Config. Template Header",DATABASE::"Config. Template Line",
            DATABASE::"Config. Questionnaire",DATABASE::"Config. Question Area",DATABASE::"Config. Question",
            DATABASE::"Config. Line",DATABASE::"Config. Package Filter",DATABASE::"Config. Field Mapping");
        end;
        ConfigPackageTable.FilterGroup(41);
        ConfigPackageTable.SetFilter("Table ID",TableIdFilter);

        //-NC2.12 [313362]
        ConfigPackageMgt.SetHideDialog(not UseDialog());
        //+NC2.12 [313362]
        //-NC2.16 [313184]
        if NcRapidConnectSetup."Validate Package" then
          ConfigPackageMgt.ValidatePackageRelations(ConfigPackageTable,TempConfigPackageTable,false);
        //+NC2.16 [313184]
    end;

    local procedure ApplyExcelPackage(NcRapidConnectSetup: Record "Nc RapidConnect Setup";var NcImportEntry: Record "Nc Import Entry")
    var
        ConfigPackage: Record "Config. Package";
        TempBlob: Record TempBlob temporary;
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
        TableIdFilter: Text;
    begin
        //-NC2.16 [313184]
        if NcRapidConnectSetup."Package Code" = '' then
          exit;
        if not NcRapidConnectSetup."Apply Package" then
          exit;

        LoadExcel(NcImportEntry,NcRapidConnectSetup."Package Code",TempBlob,TableIdFilter);

        ConfigPackage.Get(NcRapidConnectSetup."Package Code");
        ConfigPackageTable.SetRange("Package Code",NcRapidConnectSetup."Package Code");
        if ConfigPackage."Exclude Config. Tables" then begin
          ConfigPackageTable.FilterGroup(40);
          ConfigPackageTable.SetFilter("Table ID",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
            DATABASE::"Config. Template Header",DATABASE::"Config. Template Line",
            DATABASE::"Config. Questionnaire",DATABASE::"Config. Question Area",DATABASE::"Config. Question",
            DATABASE::"Config. Line",DATABASE::"Config. Package Filter",DATABASE::"Config. Field Mapping");
        end;
        ConfigPackageTable.FilterGroup(41);
        ConfigPackageTable.SetFilter("Table ID",TableIdFilter);

        ConfigPackageMgt.SetHideDialog(not UseDialog());
        ConfigPackageMgt.ApplyPackage(ConfigPackage,ConfigPackageTable,false);
        //+NC2.16 [313184]
    end;

    local procedure LoadExcel(var NcImportEntry: Record "Nc Import Entry";PackageCode: Code[20];var TempBlob: Record TempBlob temporary;var TableIdFilter: Text)
    var
        XmlDomMgt: Codeunit "XML DOM Management";
        InStream: InStream;
        CellData: DotNet CellData;
        Enumerator: DotNet IEnumerator;
        WrkBookReader: DotNet WorkbookReader;
        WrkBookPart: DotNet WorkbookPart;
        WrkBookWriter: DotNet WorkbookWriter;
        WrkShtReader: DotNet WorksheetReader;
        WrkShtWriter: DotNet WorksheetWriter;
        SheetCount: Integer;
        WrkSheetId: Integer;
    begin
        NcImportEntry.CalcFields("Document Source");
        TempBlob.Blob := NcImportEntry."Document Source";

        TempBlob.Blob.CreateInStream(InStream);
        WrkBookWriter := WrkBookWriter.Open(InStream);
        WrkBookReader := WrkBookReader.Open(InStream);
        WrkBookPart := WrkBookReader.Workbook.WorkbookPart;

        WrkSheetId := WrkBookReader.FirstSheetId;
        SheetCount := WrkBookPart.Workbook.Sheets.ChildElements.Count;
        while WrkSheetId <= SheetCount do begin
          WrkShtReader := WrkBookReader.GetWorksheetById(Format(WrkSheetId));
          WrkShtWriter := WrkBookWriter.GetWorksheetByName(WrkShtReader.Name);
          WrkShtWriter.SetCellValueText(1,'A',PackageCode,WrkShtWriter.DefaultCellDecorator);

          Enumerator := WrkShtReader.GetEnumerator;
          Enumerator.MoveNext();
          Enumerator.MoveNext();
          Enumerator.MoveNext();
          CellData := Enumerator.Current;
          TableIdFilter += '|' + CellData.Value;

          WrkSheetId += 1;
        end;
        WrkBookWriter.Close();

        TableIdFilter := DelStr(TableIdFilter,1,1);
    end;

    local procedure UseDialog(): Boolean
    begin
        //-NC2.16 [313184]
        exit(false);
        //+NC2.16 [313184]
    end;

    local procedure "--- Xml Import"()
    begin
    end;

    local procedure ImportXmlPackage(NcRapidConnectSetup: Record "Nc RapidConnect Setup";var XmlDoc: DotNet XmlDocument)
    var
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageRecord: Record "Config. Package Record";
        ConfigPackageData: Record "Config. Package Data";
        NpXmlDomMgt: Codeunit "NpXml Dom Mgt.";
        XmlDocElement: DotNet XmlElement;
        XmlElement: DotNet XmlElement;
        XmlElement2: DotNet XmlElement;
        PackageNo: Integer;
        TableId: Integer;
    begin
        //-NC2.17 [335927]
        if IsNull(XmlDoc) then
          exit;

        XmlDocElement := XmlDoc.DocumentElement;
        if IsNull(XmlDocElement) then
          exit;

        foreach XmlElement in XmlDocElement.SelectNodes('record') do begin
          Evaluate(TableId,XmlElement.GetAttribute('table_id'),9);
          ConfigPackageTable.Get(NcRapidConnectSetup."Package Code",TableId);

          Clear(ConfigPackageRecord);
          ConfigPackageRecord.LockTable;
          ConfigPackageRecord.SetRange("Package Code",ConfigPackageTable."Package Code");
          ConfigPackageRecord.SetRange("Table ID",ConfigPackageTable."Table ID");
          if ConfigPackageRecord.FindLast then;
          PackageNo := ConfigPackageRecord."No." + 1;

          ConfigPackageRecord.Init;
          ConfigPackageRecord."Package Code" := ConfigPackageTable."Package Code";
          ConfigPackageRecord."Table ID" := ConfigPackageTable."Table ID";
          ConfigPackageRecord."No." := PackageNo;
          ConfigPackageRecord.Insert(true);

          foreach XmlElement2 in XmlElement.SelectNodes('field') do begin
            ConfigPackageData.Init;
            ConfigPackageData."Package Code" := ConfigPackageRecord."Package Code";
            ConfigPackageData."Table ID" := ConfigPackageRecord."Table ID";
            ConfigPackageData."No." := ConfigPackageRecord."No.";
            Evaluate(ConfigPackageData."Field ID",XmlElement2.GetAttribute('field_no'),9);
            ConfigPackageData.Value := CopyStr(XmlElement2.InnerText,1,MaxStrLen(ConfigPackageData.Value));
            ConfigPackageData.Insert(true);
          end;
        end;
        //+NC2.17 [335927]
    end;

    local procedure ApplyXmlPackage(NcRapidConnectSetup: Record "Nc RapidConnect Setup";TableIdFilter: Text)
    var
        ConfigPackage: Record "Config. Package";
        TempBlob: Record TempBlob temporary;
        TempConfigPackageTable: Record "Config. Package Table" temporary;
        ConfigPackageTable: Record "Config. Package Table";
        ConfigPackageMgt: Codeunit "Config. Package Management";
    begin
        //-NC2.17 [335927]
        if NcRapidConnectSetup."Package Code" = '' then
          exit;
        if not NcRapidConnectSetup."Apply Package" then
          exit;

        ConfigPackage.Get(NcRapidConnectSetup."Package Code");
        ConfigPackageTable.SetRange("Package Code",NcRapidConnectSetup."Package Code");
        if ConfigPackage."Exclude Config. Tables" then begin
          ConfigPackageTable.FilterGroup(40);
          ConfigPackageTable.SetFilter("Table ID",'<>%1&<>%2&<>%3&<>%4&<>%5&<>%6&<>%7&<>%8',
            DATABASE::"Config. Template Header",DATABASE::"Config. Template Line",
            DATABASE::"Config. Questionnaire",DATABASE::"Config. Question Area",DATABASE::"Config. Question",
            DATABASE::"Config. Line",DATABASE::"Config. Package Filter",DATABASE::"Config. Field Mapping");
        end;

        ConfigPackageTable.FilterGroup(41);
        ConfigPackageTable.SetFilter("Table ID",TableIdFilter);

        ConfigPackageMgt.SetHideDialog(not UseDialog());
        ConfigPackageMgt.ApplyPackage(ConfigPackage,ConfigPackageTable,false);
        //+NC2.17 [335927]
    end;

    local procedure GetTableIdFilter(var XmlDoc: DotNet XmlDocument) TableIdFilter: Text
    var
        TempInteger: Record "Integer" temporary;
        XmlDocElement: DotNet XmlElement;
        XmlElement: DotNet XmlElement;
        TableId: Integer;
    begin
        //-NC2.17 [335927]
        if IsNull(XmlDoc) then
          exit('=0&<>0');
        XmlDocElement := XmlDoc.DocumentElement;
        if IsNull(XmlDocElement) then
          exit('=0&<>0');

        foreach XmlElement in XmlDocElement.SelectNodes('record') do begin
          Evaluate(TableId,XmlElement.GetAttribute('table_id'),9);
          if not TempInteger.Get(TableId) then begin
            TempInteger.Init;
            TempInteger.Number := TableId;
            TempInteger.Insert;

            TableIdFilter += '|' + Format(TableId);
          end;
        end;
        if TableIdFilter = '' then
          exit('=0&<>0');

        TableIdFilter := DelStr(TableIdFilter,1,1);
        exit(TableIdFilter);
        //+NC2.17 [335927]
    end;

    [TryFunction]
    local procedure TryLoadXml(var NcImportEntry: Record "Nc Import Entry";var XmlDoc: DotNet XmlDocument)
    begin
        //-NC2.17 [335927]
        if not NcImportEntry.LoadXmlDoc(XmlDoc) then
          Error('');
        //+NC2.17 [335927]
    end;
}

