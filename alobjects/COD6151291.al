codeunit 6151291 "SS Action - Payment"
{
    // NPR5.55/JAKUBV/20200807  CASE 386254 Transport NPR5.55 - 31 July 2020


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Unattended payment';

    local procedure ActionCode(): Text
    begin
        exit ('SS-PAYMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
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
              'await workflow.respond("SetContext");' +

              'let paymentSuccess = await workflow.run($context.handlerWorkflow, { context: { amount: $context.amount, paymentType: $parameters.PaymentType }});' +
              'await workflow.respond("TryEndSale");'
            );

            RegisterTextParameter('PaymentType', '');
            SetWorkflowTypeUnattended ();
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        case WorkflowStep of
          'SetContext' : SetContext(POSSession, Context);
          'TryEndSale' : TryEndSale(POSSession, Context);
        end;
    end;

    local procedure SetContext(POSSession: Codeunit "POS Session";Context: Codeunit "POS JSON Management")
    var
        PaymentTypePOS: Record "Payment Type POS";
        POSSetup: Codeunit "POS Setup";
        PaymentHandlerWorkflow: Text;
        ForceAmount: Decimal;
    begin
        POSSession.GetSetup(POSSetup);
        PaymentTypePOS.GetByRegister(Context.GetStringParameter('PaymentType', true), POSSetup.Register());

        OnGetPaymentHandler(PaymentTypePOS, PaymentHandlerWorkflow, ForceAmount);
        if PaymentHandlerWorkflow = '' then begin
          Error('No payment handler registered for %1', PaymentTypePOS."No.");
        end;

        Context.SetContext('handlerWorkflow', PaymentHandlerWorkflow);

        if ForceAmount <> 0 then begin
          Context.SetContext('amount', ForceAmount);
        end else begin
          Context.SetContext('amount', GetAmountSuggestion(POSSession, PaymentTypePOS));
        end;
    end;

    local procedure TryEndSale(POSSession: Codeunit "POS Session";Context: Codeunit "POS JSON Management")
    var
        POSSetup: Codeunit "POS Setup";
        PaymentTypePOS: Record "Payment Type POS";
        ReturnPaymentTypePOS: Record "Payment Type POS";
        Register: Record Register;
        POSSale: Codeunit "POS Sale";
    begin
        POSSession.RequestRefreshData ();
        POSSession.GetSetup(POSSetup);
        POSSession.GetSale(POSSale);
        POSSetup.GetRegisterRecord(Register);

        PaymentTypePOS.GetByRegister(Context.GetStringParameter('PaymentType', true), Register."Register No.");
        ReturnPaymentTypePOS.GetByRegister(Register."Return Payment Type", Register."Register No.");

        POSSale.TryEndSaleWithBalancing(POSSession, PaymentTypePOS, ReturnPaymentTypePOS);
    end;

    local procedure GetAmountSuggestion(POSSession: Codeunit "POS Session";PaymentTypePOS: Record "Payment Type POS"): Decimal
    var
        POSPaymentLine: Codeunit "POS Payment Line";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        exit(POSPaymentLine.CalculateRemainingPaymentSuggestionInCurrentSale(PaymentTypePOS));
    end;

    [IntegrationEvent(false, false)]
    local procedure OnGetPaymentHandler(PaymentTypePOS: Record "Payment Type POS";var PaymentHandler: Text;var ForceAmount: Decimal)
    begin
    end;
}

