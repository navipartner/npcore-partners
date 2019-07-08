xmlport 6014511 "Export Wizard Template exp/imp"
{
    // NPR5.23/THRO/20160404 CASE 234161 Import / Export Export Wizard Template
    // NPR5.41/THRO/20180610 CASE 308570 Added UseXmlDataFormat

    Caption = 'Export Wizard Template exp/imp';

    schema
    {
        textelement(ExportWizard)
        {
            textelement(UseCompanyName)
            {
            }
            textelement(UseFileName)
            {
            }
            textelement(FieldStartDelimeter)
            {
            }
            textelement(FieldEndDelimeter)
            {
            }
            textelement(FieldSeparator)
            {
            }
            textelement(RaiseErrors)
            {
            }
            textelement(RecordSeparator)
            {
            }
            textelement(DataItemSeparator)
            {
            }
            textelement(ShowStatus)
            {
            }
            textelement(WriteFieldHeader)
            {
            }
            textelement(WriteTableInformation)
            {
            }
            textelement(SkipFlowFields)
            {
            }
            textelement(OutFileEncoding)
            {
            }
            textelement(FileMode)
            {
            }
            textelement(TrimSpecialChars)
            {
            }
            textelement(UseXmlDataFormat)
            {
                MinOccurs = Zero;
            }
            textelement(FilterLanguage)
            {
                MinOccurs = Zero;
            }
            tableelement(AllObj;AllObj)
            {
                XmlName = 'Table';
                UseTemporary = true;
                fieldelement(ObjectID;AllObj."Object ID")
                {
                }
                fieldelement(ObjectName;AllObj."Object Name")
                {
                }
            }
            tableelement(Field;Field)
            {
                XmlName = 'Field';
                UseTemporary = true;
                fieldelement(TableNo;Field.TableNo)
                {
                }
                fieldelement(FieldNo;Field."No.")
                {
                }
                fieldelement(FieldName;Field.FieldName)
                {
                }
            }
            tableelement("Table Filter";"Table Filter")
            {
                XmlName = 'Filters';
                UseTemporary = true;
                fieldelement(TableNumber;"Table Filter"."Table Number")
                {
                }
                fieldelement(LineNo;"Table Filter"."Line No.")
                {
                }
                fieldelement(FieldNumber;"Table Filter"."Field Number")
                {
                }
                fieldelement(FieldFilter;"Table Filter"."Field Filter")
                {
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Export Wizard Template exp/imp';

        layout
        {
        }

        actions
        {
        }
    }

    procedure SetExportData(var pTable: Record AllObj;var pField: Record "Field";var pFilter: Record "Table Filter";pUseCompanyName: Text[50];pFileName: Text[250];pFieldStartDelimeter: Text[10];pFieldEndDelimeter: Text[10];pFieldSeparator: Text[10];pRaiseErrors: Boolean;pRecordSeparator: Text[30];pDataItemSeparator: Text[30];pShowStatus: Boolean;pWriteFieldHeader: Boolean;pWriteTableInformation: Boolean;pSkipFlowFields: Boolean;pOutFileEncoding: Text[30];pFileMode: Option OStream,ADOStream;pTrimSpecialChars: Boolean;pUseXmlDataFormat: Boolean;pFilterLanguage: Integer)
    begin
        if pTable.FindSet then
          repeat
            AllObj.Init;
            AllObj := pTable;
            AllObj.Insert;
          until pTable.Next = 0;
        if pField.FindSet then
          repeat
            Field.Init;
            Field := pField;
            Field.Insert;
          until pField.Next  =0;

        if pFilter.FindSet then
          repeat
            "Table Filter".Init;
            "Table Filter" := pFilter;
            "Table Filter".Insert;
          until pFilter.Next = 0;

        UseCompanyName := pUseCompanyName;
        UseFileName := pFileName;
        FieldStartDelimeter := pFieldStartDelimeter;
        FieldEndDelimeter := pFieldEndDelimeter;
        FieldSeparator := pFieldSeparator;
        RaiseErrors := Format(pRaiseErrors,0,9);
        RecordSeparator := pRecordSeparator;
        DataItemSeparator := pDataItemSeparator;
        ShowStatus := Format(pShowStatus,0,9);
        WriteFieldHeader := Format(pWriteFieldHeader,0,9);
        WriteTableInformation := Format(pWriteTableInformation,0,9);
        SkipFlowFields := Format(pSkipFlowFields,0,9);
        OutFileEncoding := pOutFileEncoding;
        FileMode := Format(pFileMode);
        TrimSpecialChars := Format(pTrimSpecialChars,0,9);
        FilterLanguage := Format(pFilterLanguage);
        //-NPR5.41 [308570]
        UseXmlDataFormat := Format(pUseXmlDataFormat,0,9);
        //+NPR5.41 [308570]
    end;

    procedure GetImportData(var pTable: Record AllObj;var pField: Record "Field";var pFilter: Record "Table Filter";var pUseCompanyName: Text[50];var pFileName: Text[250];var pFieldStartDelimeter: Text[10];var pFieldEndDelimeter: Text[10];var pFieldSeparator: Text[10];var pRaiseErrors: Boolean;var pRecordSeparator: Text[30];var pDataItemSeparator: Text[30];var pShowStatus: Boolean;var pWriteFieldHeader: Boolean;var pWriteTableInformation: Boolean;var pSkipFlowFields: Boolean;var pOutFileEncoding: Text[30];var pFileMode: Option OStream,ADOStream;var pTrimSpecialChars: Boolean;var pUseXmlDataFormat: Boolean;var pFilterLanguage: Integer)
    begin
        AllObj.SetFilter("Object ID",'<>%1',0);
        if AllObj.FindSet then
          repeat
            pTable.Init;
            pTable := AllObj;
            pTable.Insert;
          until AllObj.Next = 0;
        Field.SetFilter(TableNo,'<>%1',0);
        if Field.FindSet then
          repeat
            pField.Init;
            pField := Field;
            pField.Insert;
          until Field.Next = 0;
        if "Table Filter".FindSet then
          repeat
            pFilter.Init;
            pFilter := "Table Filter";
            pFilter.Insert;
          until "Table Filter".Next = 0;

        pUseCompanyName := UseCompanyName;
        pFileName := UseFileName;
        pFieldStartDelimeter := FieldStartDelimeter;
        pFieldEndDelimeter := FieldEndDelimeter;
        pFieldSeparator := FieldSeparator;
        Evaluate(pRaiseErrors,RaiseErrors,9);
        pRecordSeparator := RecordSeparator;
        pDataItemSeparator := DataItemSeparator;
        Evaluate(pShowStatus,ShowStatus,9);
        Evaluate(pWriteFieldHeader,WriteFieldHeader,9);
        Evaluate(pWriteTableInformation,WriteTableInformation,9);
        Evaluate(pSkipFlowFields,SkipFlowFields,9);
        pOutFileEncoding := OutFileEncoding;
        Evaluate(pFileMode,FileMode);
        Evaluate(pTrimSpecialChars,TrimSpecialChars,9);
        if FilterLanguage <> '' then
          Evaluate(pFilterLanguage,FilterLanguage);
        //-NPR5.41 [308570]
        if UseXmlDataFormat = '' then
          UseXmlDataFormat := '0';
        Evaluate(pUseXmlDataFormat,UseXmlDataFormat,9);
        //+NPR5.41 [308570]
    end;
}

