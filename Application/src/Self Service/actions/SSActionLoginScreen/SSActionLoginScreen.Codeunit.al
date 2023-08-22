codeunit 6151283 "NPR SS Action: Login Screen" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function locks the POS';
        ConfirmMessageLbl: Label 'Your current order will be lost. Are you sure you want to restart your session?';
        ConfirmTitleLbl: Label 'We need your confirmation...';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('ConfirmTitle', ConfirmTitleLbl);
        WorkflowConfig.AddLabel('ConfirmMessage', ConfirmMessageLbl);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
        WorkflowResponseJson: Text;
    begin
        ChangeToLoginScreen(POSSession, WorkflowResponseJson);

        if (WorkflowResponseJson = '') then
            WorkflowResponseJson := '{}';

        FrontEnd.WorkflowResponse(WorkflowResponseJson);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionLoginScreenSS.js###
'let main=async({captions:e})=>{if(await popup.confirm({title:e.ConfirmTitle,caption:e.ConfirmMessage})){let a=await workflow.respond(),s=JSON.parse(a);s.message&&await popup.message(s.message)}};'
        )
    end;

    procedure ChangeToLoginScreen(POSSession: Codeunit "NPR POS Session"; var WorkflowResponseJson: Text)
    var
        SalePOS: Record "NPR POS Sale";
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        POSResumeSaleMgt: Codeunit "NPR POS Resume Sale Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSetup: Codeunit "NPR POS Setup";
        SalesIsCanceled: Boolean;
        PosEntryNo: Integer;
        Requires_Attention: Label 'Your order must be handled by an attendant. It has reference number %1.';
        ResponseLbl: Label '{"message" : {"title":"%1", "caption":"%2"}}', Locked = true;
        Save_Sale: Label 'Saving Sales...';
        ResponseMessage: Text;
    begin
        POSSession.GetSetup(POSSetup);
        POSCreateEntry.InsertUnitLogoutEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());

        SalesIsCanceled := false;
        if (IsOkToCancel(POSSession)) then
            SalesIsCanceled := CancelSale(POSSession);

        if (not SalesIsCanceled) then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            PosEntryNo := POSResumeSaleMgt.DoSaveAsPOSQuote(POSSession, SalePOS, true);
            POSQuoteEntry.Get(PosEntryNo);
            ResponseMessage := StrSubstNo(Requires_Attention, POSQuoteEntry."Sales Ticket No.");
            WorkflowResponseJson := StrSubstNo(ResponseLbl, Save_Sale, ResponseMessage);
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
        SalePOS: Record "NPR POS Sale";
        Line: Record "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CANCEL_SALE: Label 'Sale was canceled %1';
    begin
        POSSession.GetSale(POSSale);
        POSSale.RefreshCurrent();

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        Line."Line Type" := Line."Line Type"::Comment;
        Line.Description := StrSubstNo(CANCEL_SALE, CurrentDateTime);
        POSSaleLine.InsertLine(Line);

        POSSale.GetCurrentSale(SalePOS);
        SalePOS."Header Type" := SalePOS."Header Type"::Cancelled;
        POSSale.Refresh(SalePOS);
        POSSale.Modify(false, false);

        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndSale(POSSession, false));
    end;
}

