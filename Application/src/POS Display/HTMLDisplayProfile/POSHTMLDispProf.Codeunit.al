codeunit 6059901 "NPR POS HTML Disp. Prof."
{
    Access = Internal;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterInitializeAtLogin', '', true, true)]
    local procedure OnAfterInitializeAtLogin(POSUnit: Record "NPR POS Unit")
    var
        Context: JsonObject;
        DisplayRequest: Codeunit "NPR POS Html Disp. Req";
    begin
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        Context.Add('DisplayAction', 'Open');
        DisplayRequest.AppendMediaObject(Context, POSUnit);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterInitSale', '', true, true)]
    local procedure OnAfterInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
    begin
        POSUnit.Get(SaleHeader."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterResumeSale', '', true, true)]
    local procedure OnAfterResumeSale(SalePOS: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SalePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SalePOS."Sales Ticket No.", SalePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale")
    begin
        SendInputSignalToHWC();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertSaleLine', '', true, true)]
    local procedure UpdateDisplayOnSaleLineInsert(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SaleLinePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> Codeunit::"NPR POS HTML Disp. Prof." then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'UpdateDisplayOnSaleLineInsert' then
            exit;

        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterDeletePOSSaleLine', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SaleLinePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnUpdateLine', '', true, true)]
    local procedure OnUpdateLine(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SaleLinePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterSetQuantity', '', true, true)]
    local procedure OnAfterSetQuantity(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SaleLinePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnAfterDeleteLine', '', true, true)]
    local procedure OnAfterDeleteLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SaleLinePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnAfterInsertPaymentLine', '', true, true)]
    local procedure OnAfterInsertPaymentLine(SaleLinePOS: Record "NPR POS Sale Line")
    var
        POSUnit: Record "NPR POS Unit";
        Context: JsonObject;
        JsParam: JsonObject;
        ReceiptContent: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSUnit.Get(SaleLinePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date);
        JsParam.Add('JSAction', 'UpdateReceipt');
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('ReceiptContent', ReceiptContent);
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HWC Response Method", 'OnHardwareConnectorResponse', '', false, false)]
    local procedure OnHardwareConnectorResponse(RequestId: Guid; Response: JsonToken; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRec: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        CostumerInput: Record "NPR POS Costumer Input";
        ValidatePage: Page "NPR POS HTML Validate Input";
        HwcGUID: Codeunit "NPR POS HTML Disp. Session";
        ResponseObj: JsonToken;
        InputObj: JsonToken;
        PhoneObj: JsonToken;
        SignObj: JsonToken;
        validateResult: Text;
        signStream: OutStream;
    begin
        if (not HwcGUID.PopGuid(RequestId)) then
            exit;
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        POSUnit.Get(POSSaleRec."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        if (
        Response.AsObject().Get('JSON', ResponseObj) and
        ResponseObj.AsObject().Get('Input', InputObj)
        ) then begin
            validateResult := ValidatePage.ValidateInput(InputObj.AsObject());
            case validateResult of
                'OK':
                    begin
                        CostumerInput.Init();
                        CostumerInput.Context := "NPR POS Costumer Input Context"::MONEY_BACK;
                        InputObj.AsObject().Get('PhoneNumber', PhoneObj);
                        InputObj.AsObject().Get('Signature', SignObj);
                        CostumerInput."Phone Number" := PhoneObj.AsValue().AsText();
                        CostumerInput.Signature.CreateOutStream(signStream);
                        CostumerInput."Date & Time" := CurrentDateTime();
                        signStream.WriteText(SignObj.AsValue().AsText());
                        POSEntry.Reset();
                        POSEntry.SetFilter(POSEntry."POS Unit No.", POSUnit."No.");
                        POSEntry.FindLast();
                        CostumerInput."POS Entry No." := POSEntry."Entry No.";
                        CostumerInput.Insert();
                    end;
                'REDO':
                    begin
                        SendInputSignalToHWC();
                    end;
                'CANCEL':
                    begin
                        Message('Signature capture was canceled');
                    end;
            end;
        end
    end;

    local procedure SendInputSignalToHWC()
    var
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRec: Record "NPR POS Sale";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        HtmlProf: Record "NPR POS HTML Disp. Prof.";
        Context: JsonObject;
        JsParam: JsonObject;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRec);
        POSEntry.Reset();
        POSEntry.SetFilter(POSEntry."POS Unit No.", POSSaleRec."Register No.");
        if (not POSEntry.FindLast()) then
            exit;
        if (not POSUnit.Get(POSSaleRec."Register No.")) then
            exit;
        if (not HtmlProf.Get(POSUnit."POS HTML Display Profile")) then
            exit;
        if (POSEntry."Amount Incl. Tax" >= 0) then
            exit;
        if (not (HtmlProf."CIO: Money Back" <> HtmlProf."CIO: Money Back"::None)) then
            exit;
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('JSAction', 'GetInput');
        JsParam.Add('InputType', Format(HtmlProf."CIO: Money Back"));
        Context.Add('JSParameter', JsParam);
        SendRequest(POSSaleRec."Register No.", Context, True);
    end;

    local procedure SendRequest(POSUnitCode: Code[10]; Context: JsonObject; AwaitResponse: Boolean)
    var
        Request: Codeunit "NPR Front-End: HWC";
        POSUnitDisplay: Record "NPR POS Unit Display";
        POSUnit: Record "NPR POS Unit";
        FrontEnd: Codeunit "NPR POS Front End Management";
        HtmlDisplay: Record "NPR POS HTML Disp. Prof.";
        HwcGUID: Codeunit "NPR POS HTML Disp. Session";
        JSParamTxt: Text;
        JsToken: JsonToken;
    begin
        POSUnit.Get(POSUnitCode);
        HtmlDisplay.Get(POSUnit."POS HTML Display Profile");
        Request.SetHandler('HTMLDisplay');
        if (Context.Get('JSParameter', JsToken)) then begin
            JsToken.AsObject().Add('ExVAT', HtmlDisplay."Ex. VAT");
            JsToken.AsObject().Add('ReturnInput', Format(HtmlDisplay."CIO: Money Back"));
            JsToken.WriteTo(JSParamTxt);
            Context.Replace('JSParameter', JSParamTxt);
        end;
        Request.SetRequest(Context);
        if (not POSUnitDisplay.Get(POSUnitCode)) then begin
            POSUnitDisplay.Init();
            POSUnitDisplay.POSUnit := POSUnitCode;
            POSUnitDisplay.Insert();
        end;
        if (AwaitResponse) then begin
            HwcGUID.AddGuid(Request.AwaitResponse());
        end;
    FrontEnd.InvokeFrontEndMethod2(Request);

    end;
}