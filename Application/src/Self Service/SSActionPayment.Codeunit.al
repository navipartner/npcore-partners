codeunit 6151291 "NPR SS Action: Payment"
{
    Access = Internal;

    var
        ActionDescription: Label 'Unattended payment';

    local procedure ActionCode(): Text[20]
    begin
        exit('SS-PAYMENT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
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
              'await workflow.respond("SetContext");' +

              'let paymentSuccess = await workflow.run($context.handlerWorkflow, { context: { amount: $context.amount, paymentType: $parameters.PaymentType }});' +
              'await workflow.respond("TryEndSale");'
            );

            Sender.RegisterTextParameter('PaymentType', '');
            Sender.SetWorkflowTypeUnattended();
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        case WorkflowStep of
            'SetContext':
                SetContext(POSSession, Context);
            'TryEndSale':
                TryEndSale(POSSession, Context);
        end;
    end;

    local procedure SetContext(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management")
    var
        POSPaymentMethod: Record "NPR POS Payment Method";
        POSSetup: Codeunit "NPR POS Setup";
        PaymentHandlerWorkflow: Text;
        ForceAmount: Decimal;
    begin
        EnsureSaleIsNotEmpty(POSSession);

        POSSession.GetSetup(POSSetup);
        POSPaymentMethod.Get(Context.GetStringParameterOrFail('PaymentType', ActionCode()));

        OnGetPaymentHandler(POSPaymentMethod, PaymentHandlerWorkflow, ForceAmount);
        if PaymentHandlerWorkflow = '' then begin
            Error('No payment handler registered for %1', POSPaymentMethod.Code);
        end;

        Context.SetContext('handlerWorkflow', PaymentHandlerWorkflow);

        if ForceAmount <> 0 then begin
            Context.SetContext('amount', ForceAmount);
        end else begin
            Context.SetContext('amount', GetAmountSuggestion(POSSession, POSPaymentMethod));
        end;
    end;

    local procedure TryEndSale(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management")
    var
        POSSetup: Codeunit "NPR POS Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        ReturnPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.RequestRefreshData();
        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);

        POSPaymentMethod.Get(Context.GetStringParameterOrFail('PaymentType', ActionCode()));
        ReturnPOSPaymentMethod.Get(POSPaymentMethod."Return Payment Method Code");

        POSSale.TryEndDirectSaleWithBalancing(POSSession, POSPaymentMethod, ReturnPOSPaymentMethod);
    end;

    local procedure EnsureSaleIsNotEmpty(POSSession: Codeunit "NPR POS Session")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        SaleLinePOS: Record "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        Setup: Codeunit "NPR POS Setup";
        NO_SALES_LINES: Label 'There are no sales lines in the POS. You must add at least one sales line before handling payment.';
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(POSUnit);
        PosUnit.GetProfile(POSAuditProfile);
        if not POSAuditProfile."Allow Zero Amount Sales" then begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
            SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
            SaleLinePOS.SetFilter(Type, '<>%1', SaleLinePOS.Type::Comment);
            if SaleLinePOS.IsEmpty() then
                Error(NO_SALES_LINES);
        end;
    end;

    local procedure GetAmountSuggestion(POSSession: Codeunit "NPR POS Session"; POSPaymentMethod: Record "NPR POS Payment Method"): Decimal
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        exit(POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(POSPaymentMethod));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPaymentHandler(POSPaymentMethod: Record "NPR POS Payment Method"; var PaymentHandler: Text; var ForceAmount: Decimal)
    begin
    end;
}

