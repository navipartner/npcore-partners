codeunit 6059861 "NPR Cipher Lab Scanner Mgt" implements "NPR IScanner Provider"
{
    Access = Internal;

    procedure Import(ScannerImport: Enum "NPR Scanner Import"; RecRef: RecordRef)
    var
        CipherLabScannerImport: XmlPort "NPR Cipher Lab Scanner Import";
    begin
        CipherLabScannerImport.ScannerImportFactory(ScannerImport, RecRef);
        CipherLabScannerImport.Run();
    end;
}