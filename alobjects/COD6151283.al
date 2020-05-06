codeunit 6151283 "SS Action - Login Screen"
{
    // 
    // NPR5.54/TSA /20200205 CASE 387912 Initial Version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function locks the POS';
        ConfirmTitle: Label 'We need your confirmation...';
        ConfirmMessage: Label 'You current order will be lost. Are you sure you want to restart your session?';
        SAVE_SALE: Label 'Saving Sales...';
        REQUIRES_ATTENTION: Label 'Your order must be handled by an attendant. It has reference number %1.';
        CANCEL_SALE: Label 'Sale was canceled %1';

    local procedure ActionCode(): Text
    begin

        exit ('SS-LOGIN-SCREEN');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.5');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin

        with Sender do
          if DiscoverAction20(
            ActionCode(),
            ActionDescription,
            ActionVersion())
          then begin
            RegisterWorkflow20(
                'var responseJson;'+
                'var result;'+
                'await (result = await popup.confirm ({title: $captions.ConfirmTitle, caption: $captions.ConfirmMessage}));' +
                'if (result) {'+
                  'await (responseJson = await workflow.respond());'+
                  'var response = JSON.parse (responseJson);'+
                  'if (response.message) {await popup.message (response.message);}'+
                '};'
               );
            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption (ActionCode(), 'ConfirmTitle', ConfirmTitle);
        Captions.AddActionCaption (ActionCode(), 'ConfirmMessage', ConfirmMessage);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        WorkflowResponseJson: Text;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;

        ChangeToLoginScreen (POSSession, WorkflowResponseJson);

        if (WorkflowResponseJson = '') then
          WorkflowResponseJson := '{}';

        FrontEnd.WorkflowResponse (WorkflowResponseJson);
    end;

    procedure ChangeToLoginScreen(POSSession: Codeunit "POS Session";var WorkflowResponseJson: Text)
    var
        SalePOS: Record "Sale POS";
        POSQuoteEntry: Record "POS Quote Entry";
        POSCreateEntry: Codeunit "POS Create Entry";
        POSSale: Codeunit "POS Sale";
        POSSetup: Codeunit "POS Setup";
        POSResumeSaleMgt: Codeunit "POS Resume Sale Mgt.";
        ResponseMessage: Text;
        PosEntryNo: Integer;
        SalesIsCanceled: Boolean;
    begin

        POSSession.GetSetup (POSSetup);
        POSCreateEntry.InsertUnitLogoutEntry (POSSetup.Register (), POSSetup.Salesperson ());

        SalesIsCanceled := false;
        if (IsOkToCancel (POSSession)) then
          SalesIsCanceled := CancelSale (POSSession);

        if (not SalesIsCanceled) then begin
          POSSession.GetSale (POSSale);
          POSSale.GetCurrentSale (SalePOS);
          PosEntryNo := POSResumeSaleMgt.DoSaveAsPOSQuote (SalePOS, true);
          POSQuoteEntry.Get (PosEntryNo);
          ResponseMessage := StrSubstNo (REQUIRES_ATTENTION, POSQuoteEntry."Sales Ticket No.");
          WorkflowResponseJson := StrSubstNo ('{"message" : {"title":"%1", "caption":"%2"}}', SAVE_SALE, ResponseMessage);
        end;

        POSSession.ChangeViewLogin();
    end;

    procedure IsOkToCancel(POSSession: Codeunit "POS Session"): Boolean
    var
        POSPaymentLine: Codeunit "POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin

        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.CalculateBalance (SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount = 0) then
          exit (true);

        exit (false);
    end;

    procedure CancelSale(POSSession: Codeunit "POS Session"): Boolean
    var
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        Line: Record "Sale Line POS";
    begin

        POSSession.GetSale (POSSale);
        POSSale.RefreshCurrent();

        POSSession.GetSaleLine (POSSaleLine);
        POSSaleLine.DeleteAll();

        with Line do begin
          Type := Type::Comment;
          Description := StrSubstNo (CANCEL_SALE, CurrentDateTime);
          "Sale Type" := "Sale Type"::Cancelled;
        end;
        POSSaleLine.InsertLine (Line);

        POSSession.GetSale (POSSale);
        exit (POSSale.TryEndSale2 (POSSession, false));
    end;
}

