xmlport 6014403 "NPR Cipher Lab Scanner Import"
{
    Caption = 'Cipher Lab Scanner Import';
    Direction = Import;
    FieldDelimiter = '"';
    FieldSeparator = ',';
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
                textelement(scanned_item_code)
                {
                }
                textelement(quantity)
                {
                }

                trigger OnBeforeInsertRecord()
                begin
                    IScannerImport.ImportLine('', scanned_item_code.TrimStart('$'), quantity);
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