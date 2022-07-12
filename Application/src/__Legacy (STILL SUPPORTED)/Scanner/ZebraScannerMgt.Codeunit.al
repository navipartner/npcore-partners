codeunit 6059859 "NPR Zebra Scanner Mgt" implements "NPR IScanner Provider"
{
    Access = Internal;

    procedure Import(ScannerImport: Enum "NPR Scanner Import"; RecRef: RecordRef)
    var
        ZebraScannerImport: XmlPort "NPR Scanner Import";
    begin
        ZebraScannerImport.ScannerImportFactory(ScannerImport, RecRef);
        ZebraScannerImport.Run();
    end;
}