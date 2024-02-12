codeunit 6184707 "NPR POS Action: BGSISCashMgt B"
{
    Access = Internal;

    internal procedure PrepareHTTPRequest(Direction: Option In,Out; POSUnitNo: Code[10]; SalespersonCode: Code[20]) Request: JsonObject;
    var
        BGSISPOSUnitMapping: Record "NPR BG SIS POS Unit Mapping";
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
        InputDialog: Page "NPR Input Dialog";
        AmountToHandle: Decimal;
        AmountToHandleLbl: Label 'Amount to Handle';
        AmountToHandleErr: Label 'Amount to Handle must be positive.';
    begin
        BGSISPOSUnitMapping.Get(POSUnitNo);
        BGSISPOSUnitMapping.TestField("Fiscal Printer IP Address");

        Request.Add('url', 'http://' + BGSISPOSUnitMapping."Fiscal Printer IP Address");

        InputDialog.SetInput(1, AmountToHandle, AmountToHandleLbl);
        InputDialog.RunModal();
        InputDialog.InputDecimal(1, AmountToHandle);

        if AmountToHandle <= 0 then
            Error(AmountToHandleErr);

        if Direction = Direction::Out then
            AmountToHandle := -AmountToHandle;

        Request.Add('requestBody', BGSISCommunicationMgt.CreateJSONBodyForCashHandling(POSUnitNo, SalespersonCode, AmountToHandle));
    end;

    internal procedure HandleResponse(ResponseText: Text)
    var
        BGSISCommunicationMgt: Codeunit "NPR BG SIS Communication Mgt.";
    begin
        BGSISCommunicationMgt.ProcessCashHandlingResponse(ResponseText);
    end;
}
