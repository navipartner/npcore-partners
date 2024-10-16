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
'let main=async({workflow:o,hwc:a,popup:n,context:r,captions:t})=>{let e,i,s={Success:!1};await o.respond("SetValuesToContext"),r.showSpinner&&(e=await n.spinner({caption:t.workflowTitle,abortEnabled:!1}));try{return i=a.registerResponseHandler(async l=>{if(l.Success)try{console.log("[Cash Drawer HWC] ",l),e&&e.updateCaption(t.statusProcessing),s=await o.respond("Process",{hwcResponse:l}),a.unregisterResponseHandler(i),s.Success?s.ShowSuccessMessage&&n.message({caption:s.Message,title:t.workflowTitle}):n.error({caption:s.Message,title:t.workflowTitle})}catch(c){a.unregisterResponseHandler(i,c)}}),e&&e.updateCaption(t.statusExecuting),await a.invoke(r.hwcRequest.HwcName,r.hwcRequest,i),await a.waitForContextCloseAsync(i),{success:s.Success}}finally{e&&e.close(),e=null}};'
        );
    end;
}
