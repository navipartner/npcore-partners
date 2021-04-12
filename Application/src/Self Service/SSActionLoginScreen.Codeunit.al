codeunit 6151283 "NPR SS Action: Login Screen"
{
    var
        ActionDescription: Label 'This built in function locks the POS';
        ConfirmTitle: Label 'We need your confirmation...';
        ConfirmMessage: Label 'Your current order will be lost. Are you sure you want to restart your session?';
        SAVE_SALE: Label 'Saving Sales...';
        REQUIRES_ATTENTION: Label 'Your order must be handled by an attendant. It has reference number %1.';
        CANCEL_SALE: Label 'Sale was canceled %1';

    local procedure ActionCode(): Text
    begin

        exit('SS-LOGIN-SCREEN');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction20(
          ActionCode(),
          ActionDescription,
          ActionVersion())
        then begin
            Sender.RegisterWorkflow20(
                'let result = await popup.confirm ({title: $captions.ConfirmTitle, caption: $captions.ConfirmMessage});' +
                'if (result) {' +
                  'let responseJson = await workflow.respond();' +
                  'let response = JSON.parse (responseJson);' +
                  'if (response.message) {await popup.message (response.message);}' +
                '};'
               );
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode(), 'ConfirmTitle', ConfirmTitle);
        Captions.AddActionCaption(ActionCode(), 'ConfirmMessage', ConfirmMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        WorkflowResponseJson: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;

        ChangeToLoginScreen(POSSession, WorkflowResponseJson);

        if (WorkflowResponseJson = '') then
            WorkflowResponseJson := '{}';

        FrontEnd.WorkflowResponse(WorkflowResponseJson);
    end;

    procedure ChangeToLoginScreen(POSSession: Codeunit "NPR POS Session"; var WorkflowResponseJson: Text)
    var
        SalePOS: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        POSResumeSaleMgt: Codeunit "NPR POS Resume Sale Mgt.";
        ResponseMessage: Text;
        PosEntryNo: Integer;
        SalesIsCanceled: Boolean;
    begin

        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitLogoutEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        SalesIsCanceled := false;
        if (IsOkToCancel(POSSession)) then
            SalesIsCanceled := CancelSale(POSSession);

        if (not SalesIsCanceled) then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            PosEntryNo := POSResumeSaleMgt.DoSaveAsPOSQuote(POSSession, SalePOS, true, true);
            POSQuoteEntry.Get(PosEntryNo);
            ResponseMessage := StrSubstNo(REQUIRES_ATTENTION, POSQuoteEntry."Sales Ticket No.");
            WorkflowResponseJson := StrSubstNo('{"message" : {"title":"%1", "caption":"%2"}}', SAVE_SALE, ResponseMessage);
        end;
        POSSession.StartPOSSession();
    end;

    procedure IsOkToCancel(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin

        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount = 0) then
            exit(true);

        exit(false);
    end;

    procedure CancelSale(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Line: Record "NPR POS Sale Line";
    begin

        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        with Line do begin
            Type := Type::Comment;
            Description := StrSubstNo(CANCEL_SALE, CurrentDateTime);
            "Sale Type" := "Sale Type"::Cancelled;
        end;
        POSSaleLine.InsertLine(Line);

        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndSale(POSSession, false));
    end;
}

