codeunit 6184474 "NPR POS Action: EFT Payment"
{
    var
        ActionDescription: Label 'EFT Request Workflow';

    local procedure ActionCode(): Code[20]
    begin
        exit('EFT_PAYMENT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
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
              'let paymentCreated = await workflow.respond("PrepareRequest");' +

              'runtime.suspendTimeout();' +
              'let success = await workflow.run($context.integrationWorkflow, { context: { entryNo: $context.entryNo }});' +

              'return paymentCreated && success;'
            );
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        case WorkflowStep of
            'PrepareRequest':
                PrepareRequest(POSSession, Context, FrontEnd);
        end;
    end;

    local procedure PrepareRequest(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        EFTSetup: Record "NPR EFT Setup";
        POSPaymentMethod: Record "NPR POS Payment Method";
        IntegrationWorkflow: Text;
        EftEntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        PreparingErr: Label 'preparing request in %1';
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSPaymentMethod.Get(Context.GetStringOrFail('paymentType', StrSubstNo(PreparingErr, ActionCode())));
        EFTSetup.FindSetup(SalePOS."Register No.", POSPaymentMethod.Code);

        EftEntryNo := EFTTransactionMgt.PreparePayment(EFTSetup, Context.GetDecimalOrFail('amount', StrSubstNo(PreparingErr, ActionCode())), '', SalePOS, IntegrationWorkflow);
        Context.SetContext('integrationWorkflow', IntegrationWorkflow);
        Context.SetContext('entryNo', EftEntryNo);

        EFTTransactionRequest.Get(EftEntryNo);

        if EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND] then begin
            FrontEnd.WorkflowResponse('true');
        end else begin
            FrontEnd.WorkflowResponse('false');  //we might recover last instead of paying.
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR SS Action: Payment", 'OnGetPaymentHandler', '', false, false)]
    local procedure OnGetPaymentHandlerSelfService(POSPaymentMethod: Record "NPR POS Payment Method"; var PaymentHandler: Text; var ForceAmount: Decimal)
    begin
        if POSPaymentMethod."Processing Type" <> POSPaymentMethod."Processing Type"::EFT then
            exit;
        PaymentHandler := ActionCode();
    end;
}
