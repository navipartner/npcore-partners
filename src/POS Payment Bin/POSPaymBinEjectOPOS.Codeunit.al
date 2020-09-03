codeunit 6150642 "NPR POS Paym.Bin Eject: OPOS"
{
    // NPR5.40/MMV /20180228 CASE 300660 Created object
    // NPR5.41/MMV /20180425 CASE 312990 Renamed object


    trigger OnRun()
    begin
    end;

    var
        NameDevice: Label 'Device Name';
        DescriptionDevice: Label 'Name of OPOS device to send request to';
        ErrorEject: Label 'OPOS Drawer Eject for %1 failed with error:\ %2';

    local procedure InvokeMethodCode(): Text
    begin
        exit('OPOS');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnEjectPaymentBin', '', false, false)]
    local procedure OnEjectPaymentBin(POSPaymentBin: Record "NPR POS Payment Bin"; var Ejected: Boolean)
    var
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        DeviceName: Text;
        OPOSEjectDrawerRequest: DotNet NPRNetEjectDrawerRequest;
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit; //This method is only supported via transcendence.

        DeviceName := POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'device_name', '');

        OPOSEjectDrawerRequest := OPOSEjectDrawerRequest.EjectDrawerRequest();
        OPOSEjectDrawerRequest.DeviceName := DeviceName;
        OPOSEjectDrawerRequest.Timeout := 2000;

        POSFrontEnd.InvokeDevice(OPOSEjectDrawerRequest, InvokeMethodCode(), InvokeMethodCode());

        Ejected := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnLookupBinInvokeMethods', '', false, false)]
    local procedure OnLookupBinInvokeMethods(var tmpRetailList: Record "NPR Retail List")
    begin
        tmpRetailList.Number += 1;
        tmpRetailList.Choice := InvokeMethodCode;
        tmpRetailList.Value := InvokeMethodCode;
        tmpRetailList.Insert;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150641, 'OnShowInvokeParameters', '', false, false)]
    local procedure OnShowInvokeParameters(POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        if POSPaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'device_name', '');

        POSPaymentBinInvokeMgt.ShowGenericParameters(POSPaymentBin);
    end;

    [EventSubscriber(ObjectType::Table, 6150633, 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            'device_name':
                Caption := NameDevice;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150633, 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(PaymentBinInvokeParameter: Record "NPR POS Paym. Bin Eject Param."; var Caption: Text)
    var
        PaymentBin: Record "NPR POS Payment Bin";
    begin
        if not PaymentBin.Get(PaymentBinInvokeParameter."Bin No.") then
            exit;
        if PaymentBin."Eject Method" <> InvokeMethodCode() then
            exit;

        case PaymentBinInvokeParameter.Name of
            'device_name':
                Caption := DescriptionDevice;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150716, 'OnDeviceResponse', '', false, false)]
    local procedure OnOPOSEjectResponse(ActionName: Text; Step: Text; Envelope: DotNet NPRNetResponseEnvelope0; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        OPOSEjectDrawerResponse: DotNet NPRNetEjectDrawerResponse;
        ErrorMessage: Text;
        Stargate: Codeunit "NPR POS Stargate Management";
    begin
        if ActionName <> InvokeMethodCode then
            exit;

        Stargate.DeserializeEnvelope(Envelope, OPOSEjectDrawerResponse, FrontEnd);

        ErrorMessage := OPOSEjectDrawerResponse.ErrorMessage;
        if (not OPOSEjectDrawerResponse.Success) and (ErrorMessage <> '') then
            Message(ErrorEject, OPOSEjectDrawerResponse.DeviceName, ErrorMessage);
    end;
}

