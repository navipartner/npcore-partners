#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248650 "NPR Ecom Try Capture"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";

    trigger OnRun()
    var
        EcomCaptureImpl: Codeunit "NPR EcomCaptureImpl";
    begin
        EcomCaptureImpl.Process(Rec, _Success, _ErrorText);
    end;

    internal procedure GetResponse(var Success: Boolean; var ErrorText: Text)
    begin
        Success := _Success;
        ErrorText := _ErrorText;
    end;

    var
        _Success: Boolean;
        _ErrorText: Text;
}
#endif