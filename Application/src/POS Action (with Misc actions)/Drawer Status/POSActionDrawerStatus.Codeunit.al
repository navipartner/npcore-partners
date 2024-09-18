codeunit 6184846 "NPR POS Action: Drawer Status" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ParameterOperation_OptionsLbl: Label 'SetValuesToContext,Process', Locked = true;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        AbortErrorMessage: Label 'This action can not be aborted. Please close Cash Drawer in order to continue.';
        ActionDescription: Label 'This is a built-in action for getting the cash drawer open status';
        Executing: Label 'Please close Cash Drawer in order to continue...';
        ParameterOperation_NameCaptionLbl: Label 'Operation';
        ParameterOperation_NameDescriptionLbl: Label 'Operation to perform';
        ParameterOperation_OptionCaptionsLbl: Label 'SetValuesToContext,Process';
        StatusProcessing: Label 'Cash Drawer closed validation...';
        WorkflowTitle: Label 'Cash Drawer';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);

        WorkflowConfig.AddOptionParameter(
                    ParameterOperation_Name(),
                    ParameterOperation_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, ParameterOperation_OptionsLbl),
#pragma warning restore
            ParameterOperation_NameCaptionLbl,
                    ParameterOperation_NameDescriptionLbl,
                    ParameterOperation_OptionCaptionsLbl);

        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusExecuting', Executing);
        WorkflowConfig.AddLabel('abortErrorMessage', AbortErrorMessage);
        WorkflowConfig.AddLabel('statusProcessing', StatusProcessing);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'SetValuesToContext':
                SetValuesToContext(Context, Sale, Setup);
            'Process':
                FrontEnd.WorkflowResponse(ProcessCashDrawerData(Context));
        end;
    end;

    procedure SetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(Setup.GetPOSUnitNo());
        POSPaymentBin.Get(POSUnit."Default POS Payment Bin");

        if POSPaymentBin."Eject Method" <> 'OPOS' then
            exit;

        OnActionGetCashDrawerStatus(Context, POSPaymentBin);
    end;

    local procedure OnActionGetCashDrawerStatus(Context: Codeunit "NPR POS JSON Helper"; POSPaymentBin: Record "NPR POS Payment Bin")
    var
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        POSSession: Codeunit "NPR POS Session";
        HwcRequest: JsonObject;
        DeviceName: Text;
    begin
        POSSession.GetFrontEnd(POSFrontEnd, true);

        DeviceName := POSPaymentBinInvokeMgt.GetTextParameterValue(POSPaymentBin."No.", 'device_name', '');

        HwcRequest.Add('HwcName', HwcIntegrationName());
        HwcRequest.Add('Type', 'CheckDrawer');
        HwcRequest.Add('DeviceName', DeviceName);
        HwcRequest.Add('TimeoutMs', 2000);

        Context.SetContext('hwcRequest', HwcRequest);
        Context.SetContext('showSpinner', true);
    end;

    local procedure HwcIntegrationName(): Text
    begin
        exit('OPOSCashDrawer');
    end;

    local procedure ProcessCashDrawerData(Context: Codeunit "NPR POS JSON Helper") Result: JsonObject
    var
        HwcResponse: JsonObject;
        SuccessJson: JsonToken;
    begin
        // HWC data
        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcResponse.Get('Success', SuccessJson);

        Result.Add('ShowSuccessMessage', false);
        Result.Add('Success', SuccessJson.AsValue().AsBoolean());
    end;

    local procedure ParameterOperation_Name(): Text[30]
    begin
        exit('Operation');
    end;

    procedure AddCashDrawerStatusWorkflow(var Workflow: JsonObject; Setup: Codeunit "NPR POS Setup")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSUnit: Record "NPR POS Unit";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
        WaitForCashDrawerToClose: Boolean;
        ActionParameters: JsonObject;
    begin
        if not POSUnit.Get(Setup.GetPOSUnitNo()) then
            exit;
        if not POSPaymentBin.Get(POSUnit."Default POS Payment Bin") then
            exit;

        WaitForCashDrawerToClose := POSPaymentBinInvokeMgt.GetBooleanParameterValue(POSPaymentBin."No.", 'wait_for_cash_drawer_to_close', false);

        if WaitForCashDrawerToClose then
            Workflow.Add('CASH_DRAWER_STATUS', ActionParameters);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDrawerStatus.js###
'let main=async({workflow:o,hwc:t,popup:i,context:l,captions:s})=>{let e,a,r={Success:!1};await o.respond("SetValuesToContext"),l.showSpinner&&(e=await i.simplePayment({showStatus:!0,title:s.workflowTitle,amount:" ",onAbort:async()=>{await i.confirm(s.confirmAbort)&&(e.updateStatus(s.statusAborting),await t.invoke(l.hwcRequest.HwcName,{CardAction:"RequestCancel"},a))},abortValue:{completed:"Aborted"}}));try{return a=t.registerResponseHandler(async n=>{if(n.Success)try{console.log("[Cash Drawer HWC] ",n),e&&e.updateStatus(s.statusProcessing),r=await o.respond("Process",{hwcResponse:n}),t.unregisterResponseHandler(a),r.Success?r.ShowSuccessMessage&&i.message({caption:r.Message,title:s.workflowTitle}):i.error({caption:r.Message,title:s.workflowTitle})}catch(u){t.unregisterResponseHandler(a,u)}}),e&&e.updateStatus(s.statusExecuting),e&&e.enableAbort(!0),await t.invoke(l.hwcRequest.HwcName,l.hwcRequest,a),await t.waitForContextCloseAsync(a),{success:r.Success}}finally{e&&e.close(),e=null}};'
        );
    end;
}
