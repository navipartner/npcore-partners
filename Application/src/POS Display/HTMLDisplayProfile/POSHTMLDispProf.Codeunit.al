codeunit 6060082 "NPR POS HTML Disp. Prof."
{
    Access = Internal;

    var
        State: Codeunit "NPR POS HTML Disp. Session";
        MsgRememberInputLabel: Label 'REMEMBER TO ASK FOR SIGNATURE ON THE CUSTOMER DISPLAY.', Comment = 'Input reminder', MaxLength = 100;
        MsgRememberInputTitleLabel: Label 'CUSTOMER DISPLAY', Comment = 'Input reminder', MaxLength = 100;
        MsgInputCancelledLabel: Label 'Signature capture was canceled', Comment = 'User canceled signature', MaxLength = 100;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterInitializeAtLogin', '', true, true)]
    local procedure OnAfterInitializeAtLogin(POSUnit: Record "NPR POS Unit")
    var
        Request: JsonObject;
        DisplayRequest: Codeunit "NPR POS Html Disp. Req";
    begin
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        DisplayRequest.OpenRequest(Request, (not State.MediaIsDownloaded()));
        State.SetDidDownload(true);
        SendRequest(Request);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterInitSale', '', true, true)]
    local procedure OnAfterInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        UpdateReceipt();
    end;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterResumeSale', '', true, true)]
    local procedure OnAfterResumeSale(SalePOS: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterDeletePOSSaleLine', '', true, true)]
    local procedure OnAfterDeletePOSSaleLine(var Sender: Codeunit "NPR POS Sale Line"; SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnUpdateLine', '', true, true)]
    local procedure OnUpdateLine(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterSetQuantity', '', true, true)]
    local procedure OnAfterSetQuantity(var Sender: Codeunit "NPR POS Sale Line"; var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnAfterDeleteLine', '', true, true)]
    local procedure OnAfterDeleteLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale Line", 'OnAfterInsertPOSSaleLine', '', true, true)]
    local procedure OnAfterInsertPOSSaleLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Payment Line", 'OnAfterInsertPaymentLine', '', true, true)]
    local procedure OnAfterInsertPaymentLine(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        UpdateReceipt();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnAfterEndSale', '', true, true)]
    local procedure OnAfterEndSale(SalePOS: Record "NPR POS Sale")
    var
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(SalePOS."Register No.");
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        SendInputSignalToHWC(SalePOS."Sales Ticket No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR HWC Response Method", 'OnHardwareConnectorResponse', '', false, false)]
    local procedure OnHardwareConnectorResponse(RequestId: Guid; Response: JsonToken; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSUnit: Record "NPR POS Unit";
        Setup: Codeunit "NPR POS Setup";
        ReqType: Text;
    begin
        POSSession.GetSetup(Setup);
        POSUnit.Get(Setup.GetPOSUnitNo());
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        if (not State.PopGuid(RequestId, ReqType)) then
            exit;
        case ReqType of
            'GetInput':
                HandleGetInputResponse(Response);
        end;
    end;

    procedure UpdateHTMLDisplay()
    begin
        UpdateReceipt();
    end;

    local procedure UpdateReceipt()
    var
        POSSession: Codeunit "NPR POS Session";
        PosSetup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
        Request: JsonObject;
        HtmlDisplayReq: Codeunit "NPR POS Html Disp. Req";
    begin
        POSSession.GetSetup(PosSetup);
        if (not POSUnit.Get(PosSetup.GetPOSUnitNo())) then
            exit;
        if (POSUnit."POS HTML Display Profile" = '') then
            exit;
        HtmlDisplayReq.UpdateReceiptRequest(Request);
        SendRequest(Request);
    end;

    local procedure HandleGetInputResponse(Response: JsonToken)
    var
        HtmlResponseParser: Codeunit "NPR POS Html Disp. Resp";
        POSEntry: Record "NPR POS Entry";
        ValidatePage: Page "NPR POS HTML Validate Input";
        InputObj: JsonObject;
        ValidateResult: Text;
    begin
        if (not HtmlResponseParser.ParseGetInputResponse(Response.AsObject(), InputObj)) then begin
            Message('An error occoured while gathering input: ' + GetLastErrorText());
        end else begin
            ValidateResult := ValidatePage.ValidateInput(InputObj);
            case ValidateResult of
                'OK':
                    begin
                        POSEntry.SetFilter("Document No.", State.GetLastTicketNo());
                        POSEntry.FindLast();
                        EnterCustomerInput(InputObj, POSEntry);
                    end;
                'REDO':
                    begin
                        SendInputSignalToHWC(State.GetLastTicketNo());
                        exit;
                    end;
                'CANCEL':
                    begin
                        Message(MsgInputCancelledLabel);
                    end;
            end
        end;
        State.ClearLastTicketNo();
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
        SignStream: OutStream;
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
        CostumerInput.Signature.CreateOutStream(SignStream);
        CostumerInput."Date & Time" := CurrentDateTime();
        SignStream.WriteText(SignObj.AsValue().AsText());
        CostumerInput."POS Entry No." := POSEntry."Entry No.";
        CostumerInput.Insert();
    end;

    local procedure SendInputSignalToHWC(TicketNo: Code[20])
    var
        POSSession: Codeunit "NPR POS Session";
        HtmlProfSession: Codeunit "NPR POS HTML Disp. Session";
        HtmlProfRequest: Codeunit "NPR POS Html Disp. Req";
        Setup: Codeunit "NPR POS Setup";
        POSEntry: Record "NPR POS Entry";
        POSUnit: Record "NPR POS Unit";
        HtmlProf: Record "NPR POS HTML Disp. Prof.";
        POSSaleLines: Record "NPR POS Entry Sales Line";
        Request: JsonObject;
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
        HtmlProfRequest.InputRequest(Request, HtmlProf);
        cPage.ShowMessage(MsgRememberInputTitleLabel, MsgRememberInputLabel);
        AwaitSendRequest(Request, 'GetInput');
    end;

    local procedure SendRequest(Request: JsonObject)
    var
        Hwc: Codeunit "NPR Front-End: HWC";
        FrontEnd: Codeunit "NPR POS Front End Management";
    begin
        Hwc.SetHandler('HTMLDisplay');
        Hwc.SetRequest(Request);
        FrontEnd.InvokeFrontEndMethod2(Hwc);
    end;

    local procedure AwaitSendRequest(Request: JsonObject; ReqType: Text)
    var
        Hwc: Codeunit "NPR Front-End: HWC";
        FrontEnd: Codeunit "NPR POS Front End Management";
        HwcGUID: Codeunit "NPR POS HTML Disp. Session";
    begin
        Hwc.SetHandler('HTMLDisplay');
        Hwc.SetRequest(Request);
        HwcGUID.AddGuid(Hwc.AwaitResponse(), ReqType);
        FrontEnd.InvokeFrontEndMethod2(Hwc);
    end;
}