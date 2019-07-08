table 6014511 "Saved Export Wizard"
{
    // NPR5.23/THRO/20160404 CASE 234161 Table for saving template setup
    // NPR5.41/THRO/20180410 CASE 308570 Added setup parameter UseXmlDataFormat

    Caption = 'Saved Export Wizard';
    DataCaptionFields = "Code",Description;
    DrillDownPageID = "Saved Export Wizard";
    LookupPageID = "Saved Export Wizard";

    fields
    {
        field(1;"Code";Code[10])
        {
            Caption = 'Code';
        }
        field(10;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(100;"Saved Data";BLOB)
        {
            Caption = 'Saved Data';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        Text001: Label 'Wizard template setup';

    procedure SaveSetup(var Tables: Record AllObj;var "Fields": Record "Field";var TableFilters: Record "Table Filter";pUseCompanyName: Text[50];pFileName: Text[250];pFieldStartDelimeter: Text[10];pFieldEndDelimeter: Text[10];pFieldSeparator: Text[10];pRaiseErrors: Boolean;pRecordSeparator: Text[30];pDataItemSeparator: Text[30];pShowStatus: Boolean;pWriteFieldHeader: Boolean;pWriteTableInformation: Boolean;pSkipFlowFields: Boolean;pOutFileEncoding: Text[30];pFileMode: Option OStream,ADOStream;pTrimSpecialChars: Boolean;pUseXmlDataFormat: Boolean)
    var
        SavedExportWizard: Record "Saved Export Wizard";
        OutStr: OutStream;
        WizardExport: XMLport "Export Wizard Template exp/imp";
    begin
        if PAGE.RunModal(6014568,SavedExportWizard) <> ACTION::LookupOK then
          exit;
        SavedExportWizard."Saved Data".CreateOutStream(OutStr);
        WizardExport.SetExportData(Tables,Fields,TableFilters,pUseCompanyName,pFileName,pFieldStartDelimeter,pFieldEndDelimeter,
                                   pFieldSeparator,pRaiseErrors,pRecordSeparator,pDataItemSeparator,pShowStatus,pWriteFieldHeader,
        //-NPR5.41 [308570]
                                   pWriteTableInformation,pSkipFlowFields,pOutFileEncoding,pFileMode,pTrimSpecialChars,pUseXmlDataFormat,GlobalLanguage);
        //+NPR5.41 [308570]
        WizardExport.SetDestination(OutStr);
        WizardExport.Export;
        SavedExportWizard.Modify;
    end;

    procedure SaveSetupToFile(var Tables: Record AllObj;var "Fields": Record "Field";var TableFilters: Record "Table Filter";pUseCompanyName: Text[50];pFileName: Text[250];pFieldStartDelimeter: Text[10];pFieldEndDelimeter: Text[10];pFieldSeparator: Text[10];pRaiseErrors: Boolean;pRecordSeparator: Text[30];pDataItemSeparator: Text[30];pShowStatus: Boolean;pWriteFieldHeader: Boolean;pWriteTableInformation: Boolean;pSkipFlowFields: Boolean;pOutFileEncoding: Text[30];pFileMode: Option OStream,ADOStream;pTrimSpecialChars: Boolean;pUseXmlDataFormat: Boolean)
    var
        WizardExport: XMLport "Export Wizard Template exp/imp";
        FileMgt: Codeunit "File Management";
        TempFile: File;
        OutStr: OutStream;
        FromFileName: Text;
        ToFileName: Text;
        Exported: Boolean;
    begin
        TempFile.Create(TemporaryPath + 'WizardExport.xml');
        TempFile.CreateOutStream(OutStr);
        WizardExport.SetExportData(Tables,Fields,TableFilters,pUseCompanyName,pFileName,pFieldStartDelimeter,pFieldEndDelimeter,
                                   pFieldSeparator,pRaiseErrors,pRecordSeparator,pDataItemSeparator,pShowStatus,pWriteFieldHeader,
        //-NPR5.41 [308570]
                                   pWriteTableInformation,pSkipFlowFields,pOutFileEncoding,pFileMode,pTrimSpecialChars,pUseXmlDataFormat,GlobalLanguage);
        //+NPR5.41 [308570]
        WizardExport.SetDestination(OutStr);
        Exported := WizardExport.Export;
        FromFileName := TempFile.Name;
        TempFile.Close;
        ToFileName := 'WizardTemplate.xml';
        if Exported then begin
          Download(FromFileName,Text001,'', 'Xml file(*.xml)|*.xml', ToFileName);
          Erase(FromFileName);
        end;
    end;

    procedure LoadSetup(var Tables: Record AllObj;var "Fields": Record "Field";var TableFilters: Record "Table Filter";var pUseCompanyName: Text[50];var pFileName: Text[250];var pFieldStartDelimeter: Text[10];var pFieldEndDelimeter: Text[10];var pFieldSeparator: Text[10];var pRaiseErrors: Boolean;var pRecordSeparator: Text[30];var pDataItemSeparator: Text[30];var pShowStatus: Boolean;var pWriteFieldHeader: Boolean;var pWriteTableInformation: Boolean;var pSkipFlowFields: Boolean;var pOutFileEncoding: Text[30];var pFileMode: Option OStream,ADOStream;var pTrimSpecialChars: Boolean;var pUseXmlDataFormat: Boolean)
    var
        SavedExportWizard: Record "Saved Export Wizard";
        RecordRef: RecordRef;
        FieldRef: FieldRef;
        InStr: InStream;
        WizardExport: XMLport "Export Wizard Template exp/imp";
        OrgLanguage: Integer;
        FilterLanguage: Integer;
    begin
        if PAGE.RunModal(6014568,SavedExportWizard) <> ACTION::LookupOK then
          exit;
        SavedExportWizard.CalcFields("Saved Data");
        if not SavedExportWizard."Saved Data".HasValue then
          exit;
        SavedExportWizard."Saved Data".CreateInStream(InStr);
        WizardExport.SetSource(InStr);
        WizardExport.Import;
        WizardExport.GetImportData(Tables,Fields,TableFilters,pUseCompanyName,pFileName,pFieldStartDelimeter,pFieldEndDelimeter,pFieldSeparator,
                                   pRaiseErrors,pRecordSeparator,pDataItemSeparator,pShowStatus,pWriteFieldHeader,pWriteTableInformation,
        //-NPR5.41 [308570]
                                   pSkipFlowFields,pOutFileEncoding,pFileMode,pTrimSpecialChars,pUseXmlDataFormat,FilterLanguage);
        //+NPR5.41 [308570]

        if (FilterLanguage <> 0) and (FilterLanguage <> GlobalLanguage) then begin
          if TableFilters.FindSet then
            repeat
              OrgLanguage := GlobalLanguage;
              GlobalLanguage(FilterLanguage);
              RecordRef.Open(TableFilters."Table Number");
              FieldRef := RecordRef.Field(TableFilters."Field Number");
              FieldRef.SetFilter(TableFilters."Field Filter");
              GlobalLanguage(OrgLanguage);
              TableFilters."Field Filter" := FieldRef.GetFilter;
              TableFilters.Modify;
              RecordRef.Close;
            until TableFilters.Next = 0;
        end;
    end;
}

