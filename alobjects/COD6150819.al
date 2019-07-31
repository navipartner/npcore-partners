codeunit 6150819 "POS Action - Reverse Cred.Sale"
{
    // NPR5.37.02/MMV /20171114  CASE 296478 Moved text constant to in-line constant


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Refund / Reverse Sale. This action will prompt for a receipt no and recreate the sales with reversed quantity.';
        Title: Label 'Reverse Sale';
        ReceiptPrompt: Label 'Receipt Number';
        ReasonPrompt: Label 'Return Reason';
        ResellablePrompt: Label 'Are the returned items resellable?';
        NotAllowed: Label '%1 does not have the rights to return sales ticket. Make a return sale instead.';
        ReasonRequired: Label 'You must choose a return reason.';

    local procedure ActionCode(): Text
    begin
        exit('REVERSE_CREDIT_SALE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('receipt', 'input(labels.title, labels.receiptprompt).respond().cancel(abort);');
                RegisterWorkflowStep('reason', 'context.PromptForReason && respond();');
                RegisterWorkflowStep('handle', 'respond();');
                RegisterWorkflow(true);

                //RegisterOptionParameter ('ItemCondition', 'Mint,Used,Not Suitable for Resale', 'Used');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action"; Parameters: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        Setup: Codeunit "POS Setup";
        RetailSetup: Record "Retail Setup";
        SalespersonPurchaser: Record "Salesperson/Purchaser";
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        // TODO: Remove this verification and start the permission & security workflow instead
        POSSession.GetSetup(Setup);
        SalespersonPurchaser.Get(Setup.Salesperson);

        RetailSetup.Get();
        Context.SetContext('PromptForReason', RetailSetup."Reason for Return Mandatory");

        case SalespersonPurchaser."Reverse Sales Ticket" of
            SalespersonPurchaser."Reverse Sales Ticket"::No:
                Error(NotAllowed, SalespersonPurchaser.Name);
        end;

        FrontEnd.SetActionContext(ActionCode, Context);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ReturnReasonCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);


        case WorkflowStep of
            'receipt':
                begin
                    //FrontEnd.PauseWorkflow();
                    //VerifyReceiptForReversal (Context, POSSession, FrontEnd);
                    //FrontEnd.ResumeWorkflow();
                end;
            'reason':
                begin
                    //xx FrontEnd.PauseWorkflow();
                    ReturnReasonCode := SelectReturnReason(Context, POSSession, FrontEnd);
                    JSON.SetContext('ReturnReasonCode', ReturnReasonCode);
                    FrontEnd.SetActionContext(ActionCode, JSON);
                    //xx FrontEnd.ResumeWorkflow();
                end;
            'handle':
                begin
                    VerifyReceiptForReversal(Context, POSSession, FrontEnd);
                    CopySalesReceiptForReversal(Context, POSSession, FrontEnd);
                    POSSession.ChangeViewSale();
                    POSSession.RequestRefreshData();
                end;
        end;
        //message ('Now in workflowstep %1 have data %2', WorkflowStep, Context.ToString ());

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'receiptprompt', ReceiptPrompt);
        Captions.AddActionCaption(ActionCode, 'reasonprompt', ReasonPrompt);
    end;

    local procedure VerifyReceiptForReversal(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        AuditRoll: Record "Audit Roll";
        SalesTicketNo: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScope('/', true);
        JSON.SetScope('$receipt', true);
        SalesTicketNo := JSON.GetString('input', true);
        if (SalesTicketNo = '') then
            Error('That receipt is not valid for sales reversal.');

        AuditRoll.SetRange("Sales Ticket No.", SalesTicketNo);
        AuditRoll.FindFirst();
    end;

    local procedure CopySalesReceiptForReversal(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        RetailSalesCode: Codeunit "Retail Sales Code";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        RetailSetup: Record "Retail Setup";
        SalesTicketNo: Code[20];
        ReturnReasonCode: Code[20];
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        JSON.SetScope('/', true);
        JSON.SetScope('$receipt', true);
        SalesTicketNo := JSON.GetString('input', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        RetailSalesCode.ReverseSalesTicket2(SalePOS, SalesTicketNo);

        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");

        RetailSetup.Get();
        if (RetailSetup."Reason for Return Mandatory") then begin
            JSON.SetScope('/', true);
            ReturnReasonCode := JSON.GetString('ReturnReasonCode', true);
            SaleLinePOS.ModifyAll("Return Reason Code", ReturnReasonCode);
        end;

        SaleLinePOS.ModifyAll("Return Sale Sales Ticket No.", SalesTicketNo);

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();

        POSSale.RefreshCurrent();
    end;

    local procedure SelectReturnReason(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"): Code[20]
    var
        RetailSetup: Record "Retail Setup";
        ReturnReason: Record "Return Reason";
    begin

        if (PAGE.RunModal(PAGE::"Touch Screen - Return Reasons", ReturnReason) = ACTION::LookupOK) then
            exit(ReturnReason.Code);

        Error(ReasonRequired);
    end;
}

