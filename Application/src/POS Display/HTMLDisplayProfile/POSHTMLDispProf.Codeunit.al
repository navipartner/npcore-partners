codeunit 6060082 "NPR POS HTML Disp. Prof."
{
    Access = Internal;

    var
        MsgRememberInputLabel: Label 'REMEMBER TO ASK FOR SIGNATURE ON THE CUSTOMER DISPLAY.', Comment = 'Input reminder', MaxLength = 100;
        MsgRememberInputTitleLabel: Label 'CUSTOMER DISPLAY', Comment = 'Input reminder', MaxLength = 100;
        MsgInputCancelledLabel: Label 'Signature capture was canceled', Comment = 'User canceled signature', MaxLength = 100;

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
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
        ReceiptContent: JsonObject;
        Context: JsonObject;
        JsParam: JsonObject;
    begin
        POSUnit.Get(SaleHeader."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        JsParam.Add('JSAction', 'UpdateReceipt');
        ReceiptContent := HtmlDisplayReq.GetReceiptContent(POSUnit."No.", SaleHeader."Sales Ticket No.", SaleHeader.Date);
        JsParam.Add('ReceiptContent', ReceiptContent);
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale")
    begin
        SendInputSignalToHWC(SalePOS."Sales Ticket No.");
    end;

    procedure UpdateHTMLDisplay(SaleLinePOS: Record "NPR POS Sale Line")
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
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
        JsParam.Add('Labels', HtmlDisplayReq.GetLabels());
        Context.Add('JSParameter', JsParam);
        SendRequest(POSUnit."No.", Context, False);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HWC Response Method", 'OnHardwareConnectorResponse', '', false, false)]
    local procedure OnHardwareConnectorResponse(RequestId: Guid; Response: JsonToken; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        ValidatePage: Page "NPR POS HTML Validate Input";
        HtmlProfSession: Codeunit "NPR POS HTML Disp. Session";
        Setup: Codeunit "NPR POS Setup";
        ResponseObj: JsonToken;
        InputObj: JsonToken;
        validateResult: Text;
    begin
        if (not HtmlProfSession.PopGuid(RequestId)) then
            exit;
        POSSession.GetSetup(Setup);
        POSUnit.Get(Setup.GetPOSUnitNo());
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
                        POSEntry.SetFilter("Document No.", HtmlProfSession.GetLastTicketNo());
                        POSEntry.FindLast();
                        EnterCustomerInput(InputObj.AsObject(), POSEntry);
                    end;
                'REDO':
                    begin
                        SendInputSignalToHWC(HtmlProfSession.GetLastTicketNo());
                        exit;
                    end;
                'CANCEL':
                    begin
                        Message(MsgInputCancelledLabel);
                    end;
            end
        end;
        HtmlProfSession.ClearLastTicketNo();
    end;

    /// <summary>
    ///  This method takes a JSON object of the form {PhoneNumber: [Text], Signature: [Text]} where:
    /// PhoneNumber is a text containing a phone number;
    /// Signature is a two dimensional array where the first dimension relates to different strokes and 
    /// the second dimension contains the Point objects in an array [{x: [number], y: [number]}]
    /// </summary>
    /// <param name="InputObj"></param>
    procedure EnterCustomerInput(InputObj: JsonObject; POSEntry: Record "NPR POS Entry")
    var
        POSSession: Codeunit "NPR POS Session";
        POSUnit: Record "NPR POS Unit";
        CostumerInput: Record "NPR POS Costumer Input";
        Setup: Codeunit "NPR POS Setup";
        PhoneObj: JsonToken;
        SignObj: JsonToken;
        signStream: OutStream;
    begin
        POSSession.GetSetup(Setup);
        POSUnit.Get(Setup.GetPOSUnitNo());
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        if (not InputObj.Get('PhoneNumber', PhoneObj)) then
            exit;
        if (not InputObj.Get('Signature', SignObj)) then
            exit;
        if (POSEntry."Entry No." = 0) then
            exit;
        CostumerInput.Init();
        CostumerInput.Context := "NPR POS Costumer Input Context"::MONEY_BACK;
        CostumerInput."Phone Number" := CopyStr(PhoneObj.AsValue().AsText(), 1, 50);
        CostumerInput.Signature.CreateOutStream(signStream);
        CostumerInput."Date & Time" := CurrentDateTime();
        signStream.WriteText(SignObj.AsValue().AsText());
        CostumerInput."POS Entry No." := POSEntry."Entry No.";
        CostumerInput.Insert();
    end;

    local procedure SendInputSignalToHWC(TicketNo: Code[20])
    var
        POSSession: Codeunit "NPR POS Session";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        HtmlProf: Record "NPR POS HTML Disp. Prof.";
        Setup: Codeunit "NPR POS Setup";
        POSSaleLines: Record "NPR POS Entry Sales Line";
        HtmlProfSession: Codeunit "NPR POS HTML Disp. Session";
        Context: JsonObject;
        JsParam: JsonObject;
        Sum: Decimal;
        cPage: Page "NPR Custom Message Page";
    begin
        POSSession.GetSetup(Setup);
        if (not POSUnit.Get(Setup.GetPOSUnitNo())) then
            exit;
        if (not HtmlProf.Get(POSUnit."POS HTML Display Profile")) then
            exit;
        if (not (HtmlProf."CIO: Money Back" <> HtmlProf."CIO: Money Back"::None)) then
            exit;
        POSEntry.SetFilter("Document No.", TicketNo);
        if (not POSEntry.FindLast()) then
            exit;
        if (POSEntry."Amount Incl. Tax" >= 0) then
            exit;
        if (POSEntry.CalcFields("Is Pay-in Pay-out") and POSEntry."Is Pay-in Pay-out") then
            exit;
        POSSaleLines.SetFilter("POS Entry No.", '=%1', POSEntry."Entry No.");
        POSSaleLines.SetFilter(Type, '=%1', POSSaleLines.Type::Item);
        repeat
            Sum := Sum + POSSaleLines."Amount Incl. VAT";
        until POSSaleLines.Next() = 0;
        if (Sum >= 0.00) then
            exit;
        HtmlProfSession.SetLastTicketNo(TicketNo);
        Context.Add('DisplayAction', 'SendJS');
        JsParam.Add('JSAction', 'GetInput');
        JsParam.Add('InputType', Format(HtmlProf."CIO: Money Back"));
        Context.Add('JSParameter', JsParam);
        cPage.ShowMessage(MsgRememberInputTitleLabel, MsgRememberInputLabel);
        SendRequest(POSUnit."No.", Context, True);
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