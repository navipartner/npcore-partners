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
        ParamCalledFrom_CaptionLbl: Label 'CalledFrom';
        ParamCalledFrom_DescLbl: Label 'Specifies the action from which this action was called.';
        ParamCalledFromOptionsLbl: Label 'insertItem,changeQty,discount,deleteLine,changeView,payment,endSale';
        ParamCalledFromOptions_CaptionLbl: Label 'Insert Item,Change Quantity,Discount,Delete Line,Change View,Payment,End Sale';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddTextParameter(RowOneMessageParameterName(), '', ParamRowOneMessage_CaptionLbl, ParamRowOneMessage_DescLbl);
        WorkflowConfig.AddTextParameter(RowTwoMessageParameterName(), '', ParamRowTwoMessage_CaptionLbl, ParamRowTwoMessage_DescLbl);
        WorkflowConfig.AddOptionParameter(ParamCalledFrom_CaptionLbl, ParamCalledFromOptionsLbl, '', ParamCalledFrom_CaptionLbl, ParamCalledFrom_DescLbl, ParamCalledFromOptions_CaptionLbl);
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
        Context.SetContext('hwcRequest1', PrepareHwcRequest(Sale, 1, 1, Context.GetStringParameter(RowOneMessageParameterName())));
        Context.SetContext('hwcRequest2', PrepareHwcRequest(Sale, 2, 0, Context.GetStringParameter(RowTwoMessageParameterName()).PadRight(GetMaxMessageLength(), ' ')));
    end;

    local procedure ProcessLaurelMiniPOSData(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    begin
        Response := ParseHwcResponse(Context);
        ProcessLaurelMiniPOSResponse(Context, Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionHULFPDisplay.js###
        'let main = async ({ workflow, hwc, popup, context, captions }) => { await workflow.respond("SetValuesToContext"); const result1 = await handleHwcRequest(hwc, workflow, popup, captions, context.hwcRequest1); if (!result1.Success) return {sucess: false}; const result2 = await handleHwcRequest(hwc, workflow, popup, captions, context.hwcRequest2); return { success: result1.Success && result2.Success }; }; async function handleHwcRequest(hwc, workflow, popup, captions, hwcRequest) { let _contextId; let _bcResponse = { Success: false }; _contextId = hwc.registerResponseHandler(async (hwcResponse) => { if (hwcResponse.Success) { try { console.log("[Hungary Laurel HWC]", hwcResponse); hwcResponse.HwcInvokeCall = false; _bcResponse = await workflow.respond("Process", { hwcResponse }); hwc.unregisterResponseHandler(_contextId); if (_bcResponse.Success) { if (_bcResponse.ShowSuccessMessage) { popup.message({ caption: _bcResponse.Message, title: captions.workflowTitle }); } } else { popup.error({ caption: _bcResponse.Message, title: captions.workflowTitle }); } } catch (e) { hwc.unregisterResponseHandler(_contextId, e); } } }); try { await hwc.invoke(hwcRequest.HwcName, hwcRequest, _contextId); } catch (invokeErr) { hwc.unregisterResponseHandler(_contextId); return await workflow.respond("Process", { hwcResponse:{ Success: false, ErrorMessage: "HWC Invoke failed: " + invokeErr.message, HwcInvokeCall: true } }); } await hwc.waitForContextCloseAsync(_contextId); return _bcResponse; }'
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

        HwcResponse.Get('ErrorMessage', JsonTok);
        Response.Add('ErrorMessage', JsonTok);

        HwcResponse.Get('HwcInvokeCall', JsonTok);
        Response.Add('HwcInvokeCall', JsonTok);

        if HwcResponse.Get('ResponseMessage', JsonTok) then begin
            JsonTok.ReadFrom(JsonTok.AsValue().AsText().Replace('\"', '"'));
            Response.Add('ResponseMessage', JsonTok);
        end;
    end;

    local procedure ProcessLaurelMiniPOSResponse(Context: Codeunit "NPR POS JSON Helper"; Response: JsonObject)
    var
        ResponseMsgToken: JsonToken;
    begin
        ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Context, Response); // //Handles Success boolean and Error Message from HWC

        if Response.Get('ResponseMessage', ResponseMsgToken) then
            HULCommunicationMgt.ThrowErrorMsgFromResponseMessageIfNotSuccessful(ResponseMsgToken.AsObject()); //Handles iErrCode and sErrMsg from ResponseMessage
    end;

    local procedure ThrowErrorMsgFromResponseIfCommunicationNotSuccessful(Context: Codeunit "NPR POS JSON Helper"; Response: JsonObject)
    var
        SuccessToken: JsonToken;
        ErrorMsgToken: JsonToken;
    begin
        Response.Get('Success', SuccessToken);
        if (SuccessToken.AsValue().AsBoolean()) then
            exit;
        Response.Get('ErrorMessage', ErrorMsgToken);

        if IsProcessHwcInvokeAndCalledFromChangeView(Context, Response) then
            ChangePOSViewToSale();

        Error(ErrorMsgToken.AsValue().AsText());
    end;

    local procedure IsProcessHwcInvokeAndCalledFromChangeView(Context: Codeunit "NPR POS JSON Helper"; Response: JsonObject): Boolean
    var
        HwcInvokeCallToken: JsonToken;
        DisplayCalledFrom: Option insertItem,changeQty,discount,deleteLine,changeView,payment,endSale;
    begin
        DisplayCalledFrom := Context.GetIntegerParameter(CalledFromParameterName());
        exit((DisplayCalledFrom = DisplayCalledFrom::changeView) and Response.Get('HwcInvokeCall', HwcInvokeCallToken) and (HwcInvokeCallToken.AsValue().AsBoolean()))
    end;

    local procedure ChangePOSViewToSale()
    var
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
        ViewType: Option Login,Sale,Payment,Balance,Locked;
    begin
        POSActionChangeViewB.ChangeView(ViewType::Sale, '');
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

    internal procedure CalledFromParameterName(): Text[30]
    begin
        exit('CalledFrom');
    end;
    #endregion
    var
        HULCommunicationMgt: Codeunit "NPR HU L Communication Mgt.";
}