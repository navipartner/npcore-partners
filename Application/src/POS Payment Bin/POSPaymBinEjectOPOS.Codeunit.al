codeunit 6150642 "NPR POS Paym.Bin Eject: OPOS"
{
    Access = Internal;

    local procedure InvokeMethodCode(): Text
    begin
        exit('OPOS');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnEjectPaymentBin', '', false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    var
        HWCRequest: Codeunit "NPR Front-End: HWC";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        POSSession: Codeunit "NPR POS Session";
        RequestBody: JsonObject;
        DeviceName: Text;
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        POSSession.GetFrontEnd(POSFrontEnd, true);

        DeviceName := POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'device_name', '');

        RequestBody.Add('Type', 'EjectDrawer');
        RequestBody.Add('DeviceName', DeviceName);
        RequestBody.Add('TimeoutMs', 2000);
        HWCRequest.SetHandler('OPOSCashDrawer');
        HWCRequest.SetRequest(RequestBody);
        POSFrontEnd.InvokeFrontEndMethod2(HWCRequest);

        Ejected := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnLookupBinInvokeMethods', '', false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := CopyStr(InvokeMethodCode(), 1, 246);
        tmpRetailList.Value := CopyStr(InvokeMethodCode(), 1, 250);
        tmpRetailList.Insert();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Bin Eject Mgt.", 'OnShowInvokeParameters', '', false, false)]
    local procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'device_name', '');
        POSPaymentBinInvokeMgt.GetBooleanParameterValue(POSPaymentBin."No.", 'wait_for_cash_drawer_to_close', false);

        POSPaymentBinInvokeMgt.ShowGenericParameters(POSPaymentBin);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Paym. Bin Eject Param.", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
        CashDrawerWaitForClose: Label 'Wait for Cash Drawer to Close';
        NameDevice: Label 'Device Name';
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            'device_name':
                Caption := NameDevice;
            'wait_for_cash_drawer_to_close':
                Caption := CashDrawerWaitForClose;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Paym. Bin Eject Param.", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
        DescriptionCloseCashDrawer: Label 'Specifies if POS should wait user to close a Cash Drawer before proceeding further';
        DescriptionDevice: Label 'Name of OPOS device to send request to';
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            'device_name':
                Caption := DescriptionDevice;
            'wait_for_cash_drawer_to_close':
                Caption := DescriptionCloseCashDrawer;
        end;
    end;
}