#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248648 "NPR EcomLineCaptureTryProcess"
{
    Access = Internal;
    TableNo = "NPR Magento Payment Line";
    trigger OnRun()
    var
        EcomLineCaptureImpl: Codeunit "NPR EcomLineCaptureImpl";
    begin
        EcomLineCaptureImpl.Process(Rec);
    end;
}
#endif