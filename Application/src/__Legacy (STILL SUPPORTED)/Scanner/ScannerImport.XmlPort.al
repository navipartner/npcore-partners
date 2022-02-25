xmlport 6014401 "NPR Scanner Import"
{
    Caption = 'Import from Scanner File';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = '|';
    Format = VariableText;
    UseRequestPage = false;

    schema
    {
        textelement(Root)
        {
            tableelement(tmpImport; Integer)
            {
                AutoSave = false;
                XmlName = 'tmpImport';
                UseTemporary = true;
                textelement(shelf)
                {
                }
                textelement(scanned_item_code)
                {
                }
                textelement(quantity)
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    IScannerImport.ImportLine(shelf, scanned_item_code, quantity);
                end;
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        IScannerImport.GetInitialLine();
    end;

    trigger OnPostXmlPort()
    begin
        IScannerImport.ShowErrors();
    end;

    procedure ScannerImportFactory(SpecificScannerImport: Enum "NPR Scanner Import"; RecRef: RecordRef)
    begin
        IScannerImport := SpecificScannerImport;
        IScannerImport.SetRecordRef(RecRef);
    end;

    var
        IScannerImport: Interface "NPR IScanner Import";
}