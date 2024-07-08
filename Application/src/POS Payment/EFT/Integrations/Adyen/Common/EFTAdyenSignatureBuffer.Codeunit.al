codeunit 6184591 "NPR EFT Adyen Signature Buffer"
{
    SingleInstance = true;
    Access = Internal;

    var
        _signature: Text;
        _eftEntryNo: Integer;

    procedure SetSignatureData(signature: Text; eftEntryNo: Integer)
    begin
        _signature := signature;
        _eftEntryNo := eftEntryNo;
    end;

    procedure GetSignatureData(var signature: Text; var eftEntryNo: Integer)
    begin
        signature := _signature;
        eftEntryNo := _eftEntryNo;
    end;
}