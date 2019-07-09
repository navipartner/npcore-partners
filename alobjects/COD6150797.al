codeunit 6150797 "POS Action - Cancel Sale"
{
    // NPR5.32/ANEN /20170321  CASE 269494 Adding to sal line pos, sale typ cancelled
    // NPR5.38/MMV /20171120 CASE 296802 Use new delete function for robustness against invalid POSSaleLine state.
    // NPR5.42/BHR/20180510  CASE 313914 Added Security functionality
    // NPR5.46/TSA /20180914 CASE 314603 Refactored the security functionality to use secure methods


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Cancel Sale';
        Title: Label 'Cancel Sale';
        Prompt: Label 'Are you sure you want to cancel this sales? All lines will be deleted.';
        PartlyPaid: Label 'This sales can''t be deleted. It has been partly paid. You must first void the payment.';
        CustomerInvoice: Label 'This sales can''t be deleted. It has a customer invoice attached. ';
        CANCEL_SALE: Label 'Sale was canceled %1';

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

            RegisterWorkflowStep ('', 'confirm(labels.title, labels.prompt).respond();');
            RegisterDataBinding ();
            //-NPR5.42 [313914]
            RegisterOptionParameter('Security','None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword','None');
            //+NPR5.42 [313914]
            RegisterWorkflow(true);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        CancelSale (Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'title', Title);
        Captions.AddActionCaption (ActionCode, 'prompt', Prompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        POSPaymentLine: Codeunit "POS Payment Line";
        SaleAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        Subtotal: Decimal;
    begin

        if not Action.IsThisAction(ActionCode) then
          exit;

        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.CalculateBalance (SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount <> 0) then
          Error (PartlyPaid);

        FrontEnd.SetActionContext (ActionCode, Context);
        Handled := true;
    end;

    local procedure ActionCode(): Text
    begin
        exit ('CANCEL_POS_SALE');
    end;

    local procedure ActionVersion(): Text
    begin

        exit ('1.2'); //-+NPR5.46 [314603]
    end;

    local procedure CancelSale(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        Line: Record "Sale Line POS";
    begin

        JSON.InitializeJObjectParser(Context,FrontEnd);
        POSSession.GetSaleLine (POSSaleLine);

        POSSaleLine.DeleteAll();

        with Line do begin
          Type := Type::Comment;
          Description := StrSubstNo (CANCEL_SALE, CurrentDateTime);
          "Sale Type" := "Sale Type"::Cancelled;
        end;

        POSSaleLine.InsertLine(Line);

        POSSession.GetSale(POSSale);
        POSSale.TryEndSale (POSSession);
    end;
}

