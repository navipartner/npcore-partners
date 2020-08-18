codeunit 6184474 "POS Action - EFT Payment"
{
    // NPR5.55/JAKUBV/20200807  CASE 386254 Transport NPR5.55 - 31 July 2020


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'EFT Request Workflow';

    local procedure ActionCode(): Text
    begin
        exit ('EFT_PAYMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
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
              'let paymentCreated = await workflow.respond("PrepareRequest");' +

              'runtime.suspendTimeout();' +
              'let success = await workflow.run($context.integrationWorkflow, { context: { entryNo: $context.entryNo }});' +

              'return paymentCreated && success;'
            );
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150733, 'OnAction', '', false, false)]
    local procedure OnAction20("Action": Record "POS Action";WorkflowStep: Text;Context: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session";State: Codeunit "POS Workflows 2.0 - State";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        case WorkflowStep of
          'PrepareRequest' : PrepareRequest(POSSession, Context, FrontEnd);
        end;
    end;

    local procedure PrepareRequest(POSSession: Codeunit "POS Session";Context: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        EFTTransactionMgt: Codeunit "EFT Transaction Mgt.";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        EFTSetup: Record "EFT Setup";
        PaymentTypePOS: Record "Payment Type POS";
        IntegrationWorkflow: Text;
        EftEntryNo: Integer;
        EFTTransactionRequest: Record "EFT Transaction Request";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        PaymentTypePOS.GetByRegister(Context.GetString('paymentType', true), SalePOS."Register No.");
        EFTSetup.FindSetup(SalePOS."Register No.", PaymentTypePOS."No.");

        EftEntryNo := EFTTransactionMgt.PreparePayment(EFTSetup, PaymentTypePOS, Context.GetDecimal('amount', true), '', SalePOS, IntegrationWorkflow);
        Context.SetContext('integrationWorkflow', IntegrationWorkflow);
        Context.SetContext('entryNo', EftEntryNo);

        EFTTransactionRequest.Get(EftEntryNo);

        if EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND] then begin
          FrontEnd.WorkflowResponse('true');
        end else begin
          FrontEnd.WorkflowResponse('false');  //we might recover last instead of paying.
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6151291, 'OnGetPaymentHandler', '', false, false)]
    local procedure OnGetPaymentHandlerSelfService(PaymentTypePOS: Record "Payment Type POS";var PaymentHandler: Text;var ForceAmount: Decimal)
    begin
        if PaymentTypePOS."Processing Type" <> PaymentTypePOS."Processing Type"::EFT then
          exit;
        PaymentHandler := ActionCode();
    end;
}

