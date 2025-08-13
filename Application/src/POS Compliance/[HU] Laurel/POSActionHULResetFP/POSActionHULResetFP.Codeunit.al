codeunit 6248451 "NPR POS Action: HU L Reset FP" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action for fiscal printer cash management.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'SetValuesToContext':
                SetValuesToContext(Context, Sale);
            'Process':
                FrontEnd.WorkflowResponse(ProcessLaurelMiniPOSData(Context));
        end;
    end;

    procedure SetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    begin
        SetRequestValuesToContext(Context, Sale);
    end;

    internal procedure SetRequestValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    begin
        Context.SetContext('hwcRequest', PrepareHwcRequest(Sale));
        Context.SetContext('showSpinner', false);
    end;

    local procedure PrepareHwcRequest(Sale: Codeunit "NPR POS Sale") HwcRequest: JsonObject
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        HULCommunicationMgt.SetBaseHwcRequestValues(HwcRequest, POSSale."Register No.");

        HwcRequest.Add('Payload', PrepareResetPrinterRequest());
    end;

    local procedure PrepareResetPrinterRequest(): Text
    begin
        exit(HULCommunicationMgt.ResetPrinter());
    end;

    internal procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    begin
        Response := ParseHwcResponse(Context);
        HULCommunicationMgt.ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Response); //Handles Success boolean from HWC and Error Message
    end;

    internal procedure ParseHwcResponse(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HwcResponse: JsonObject;
        JsonTok: JsonToken;
    begin
        // HWC data
        Response.Add('ShowSuccessMessage', false);

        HwcResponse := Context.GetJsonObject('hwcResponse');
        HwcResponse.Get('Success', JsonTok);
        Response.Add('Success', JsonTok.AsValue().AsBoolean());

        HwcResponse.Get('ResponseMessage', JsonTok);
        JsonTok.ReadFrom(JsonTok.AsValue().AsText().Replace('\"', '"'));
        Response.Add('ResponseMessage', JsonTok);

        HwcResponse.Get('ErrorMessage', JsonTok);
        Response.Add('ErrorMessage', JsonTok);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHULResetFP.js###
'let main = async ({ workflow, hwc, popup, context, captions}) => { let _dialogRef, _contextId, _bcResponse = { "Success": false}; await workflow.respond("SetValuesToContext"); if (context.showSpinner) { _dialogRef = await popup.spinner({ caption: captions.workflowTitle, abortEnabled: false }); } try { _contextId = hwc.registerResponseHandler(async (hwcResponse) => { if (hwcResponse.Success) { try { console.log("[Hungary Laurel HWC] ", hwcResponse); if (_dialogRef) _dialogRef.updateCaption(captions.statusProcessing); _bcResponse = await workflow.respond("Process", { hwcResponse: hwcResponse}); hwc.unregisterResponseHandler(_contextId); if (_bcResponse.Success) { if (_bcResponse.ShowSuccessMessage) { popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle }); } } else { popup.error({ caption: _bcResponse.Message, title: captions.workflowTitle}); } } catch (e) { hwc.unregisterResponseHandler(_contextId, e); } } }); if (_dialogRef) _dialogRef.updateCaption(captions.statusExecuting); await hwc.invoke( context.hwcRequest.HwcName, context.hwcRequest, _contextId ); await hwc.waitForContextCloseAsync(_contextId); return ({ "success": _bcResponse.Success }); } finally { if (_dialogRef) _dialogRef.close(); _dialogRef = null } }'
        );
    end;

    var
        HULCommunicationMgt: Codeunit "NPR HU L Communication Mgt.";
}