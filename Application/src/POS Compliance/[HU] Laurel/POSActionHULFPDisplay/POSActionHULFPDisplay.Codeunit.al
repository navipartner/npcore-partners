codeunit 6248344 "NPR POS Action: HUL FP Display" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'This is a built-in action to manage fiscal printer message display.';
        ParamRowOneMessage_CaptionLbl: Label 'RowOneMessage';
        ParamRowOneMessage_DescLbl: Label 'Specifies the Message to be displayed on the Laurel fiscal printer monitor row one.';
        ParamRowTwoMessage_CaptionLbl: Label 'RowTwoMessage';
        ParamRowTwoMessage_DescLbl: Label 'Specifies the Message to be displayed on the Laurel fiscal printer monitor row two.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddTextParameter(RowOneMessageParameterName(), '', ParamRowOneMessage_CaptionLbl, ParamRowOneMessage_DescLbl);
        WorkflowConfig.AddTextParameter(RowTwoMessageParameterName(), '', ParamRowTwoMessage_CaptionLbl, ParamRowTwoMessage_DescLbl);
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

    local procedure SetValuesToContext(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    begin
        Context.SetContext('hwcRequest1', PrepareHwcRequest(Sale, 1, 1, Context.GetStringParameter('RowOneMessage')));
        Context.SetContext('hwcRequest2', PrepareHwcRequest(Sale, 2, 0, Context.GetStringParameter('RowTwoMessage').PadRight(GetMaxMessageLength(), ' ')));
    end;

    local procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    begin
        Response := ParseHwcResponse(Context);
        ProcessLaurelMiniPOSResponse(Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHULFPDisplay.js###
'let main = async ({ workflow, hwc, popup, context, captions }) => { await workflow.respond("SetValuesToContext"); const result1 = await handleHwcRequest(hwc, workflow, popup, captions, context.hwcRequest1); const result2 = await handleHwcRequest(hwc, workflow, popup, captions, context.hwcRequest2); return { success: result1.Success && result2.Success }; }; async function handleHwcRequest(hwc, workflow, popup, captions, hwcRequest) { let _contextId; let _bcResponse = { Success: false }; _contextId = hwc.registerResponseHandler(async (hwcResponse) => { if (hwcResponse.Success) { try { console.log("[Hungary Laurel HWC]", hwcResponse); _bcResponse = await workflow.respond("Process", { hwcResponse }); hwc.unregisterResponseHandler(_contextId); if (_bcResponse.Success) { if (_bcResponse.ShowSuccessMessage) { popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle }); } } else { popup.error({ caption: _bcResponse.Message, title: captions.workflowTitle }); } } catch (e) { hwc.unregisterResponseHandler(_contextId, e); } } }); await hwc.invoke(hwcRequest.HwcName, hwcRequest, _contextId); await hwc.waitForContextCloseAsync(_contextId); return _bcResponse; }'
        );
    end;

    #region POS Action HU Laurel FP Display - Hwc Request

    local procedure PrepareHwcRequest(Sale: Codeunit "NPR POS Sale"; RowNumber: Integer; ClearDisplay: Integer; Message: Text) HwcRequest: JsonObject
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        HULCommunicationMgt.SetBaseHwcRequestValues(HwcRequest, POSSale."Register No.");
        HwcRequest.Add('Payload', PrepareWriteDisplayRequest(RowNumber, ClearDisplay, Message));
    end;

    local procedure PrepareWriteDisplayRequest(RowNumber: Integer; ClearDisplay: Integer; Message: Text): Text
    var
        JsonTextWriter: Codeunit "Json Text Reader/Writer";
    begin
        JsonTextWriter.WriteStartObject('');
        JsonTextWriter.WriteStringProperty('command', 'writeDisplay');
        JsonTextWriter.WriteStartObject('data');
        JsonTextWriter.WriteStringProperty('row', Format(RowNumber));
        JsonTextWriter.WriteStringProperty('col', '1');
        JsonTextWriter.WriteStringProperty('clear', Format(ClearDisplay));
        JsonTextWriter.WriteStringProperty('message', CopyStr(Message, 1, GetMaxMessageLength()));
        JsonTextWriter.WriteEndObject(); // data
        JsonTextWriter.WriteEndObject();
        exit(JsonTextWriter.GetJSonAsText());
    end;

    local procedure GetMaxMessageLength(): Integer
    begin
        exit(40);
    end;
    #endregion

    #region POS Action HU Laurel FP Display - Hwc Response

    local procedure ParseHwcResponse(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        HwcResponse: JsonObject;
        JsonTok: JsonToken;
    begin
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

    local procedure ProcessLaurelMiniPOSResponse(Response: JsonObject)
    var
        ResponseMessage: JsonObject;
        ResponseMsgToken: JsonToken;
    begin
        HULCommunicationMgt.ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Response); //Handles Success boolean from HWC and Error Message

        Response.Get('ResponseMessage', ResponseMsgToken);
        ResponseMessage := ResponseMsgToken.AsObject();

        HULCommunicationMgt.ThrowErrorMsgFromResponseMessageIfNotSuccessful(ResponseMessage); //Handles iErrCode and sErrMsg from ResponseMessage
    end;
    #endregion

    #region POS Action HU Laurel FP Display - Action Parameter Captions
    internal procedure RowOneMessageParameterName(): Text[30]
    begin
        exit('RowOneMessage');
    end;

    internal procedure RowTwoMessageParameterName(): Text[30]
    begin
        exit('RowTwoMessage');
    end;
    #endregion
    var
        HULCommunicationMgt: Codeunit "NPR HU L Communication Mgt.";
}