codeunit 6150797 "NPR POSAction: Cancel Sale"
{
    // NPR5.32/ANEN/20170321 CASE 269494 Adding to sal line pos, sale typ cancelled
    // NPR5.38/MMV /20171120 CASE 296802 Use new delete function for robustness against invalid POSSaleLine state.
    // NPR5.42/BHR /20180510 CASE 313914 Added Security functionality
    // NPR5.46/TSA /20180914 CASE 314603 Refactored the security functionality to use secure methods
    // NPR5.54/ALPO/20200203 CASE 364658 Resume POS Sale:
    //                                   - Function CancelSale():
    //                                     - removed unused call paramters: Context (DotNet Newtonsoft.Json.Linq.JObject.'Newtonsoft.Json) & FrontEnd (Codeunit POS Front End Management)
    //                                     - added return value (boolean)
    //                                     - set to global
    // NPR5.54/MMV /20200217 CASE 364658 Added configurable start of new sale to allow business logic first.
    // NPR5.55/ALPO/20200720 CASE 391678 Possibility to set an alternative description for cancalled sale


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
        AltSaleCancelDescription: Text;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin

                RegisterWorkflowStep('', 'confirm(labels.title, labels.prompt).respond();');
                RegisterDataBinding();
                //-NPR5.42 [313914]
                RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
                //+NPR5.42 [313914]
                RegisterWorkflow(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        //CancelSale (Context, POSSession, FrontEnd);  //NPR5.54 [364658]-revoked
        CancelSaleAndStartNew(POSSession);  //NPR5.54 [364658]
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'title', Title);
        Captions.AddActionCaption(ActionCode, 'prompt', Prompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin

        if not Action.IsThisAction(ActionCode) then
            exit;

        //-NPR5.54 [364658]-revoked
        /*
        POSSession.GetPaymentLine (POSPaymentLine);
        POSPaymentLine.CalculateBalance (SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        IF (PaidAmount <> 0) THEN
          ERROR (PartlyPaid);
        */
        //+NPR5.54 [364658]-revoked
        CheckSaleBeforeCancel(POSSession);  //NPR5.54 [364658]

        FrontEnd.SetActionContext(ActionCode, Context);
        Handled := true;

    end;

    local procedure ActionCode(): Text
    begin
        exit('CANCEL_POS_SALE');
    end;

    local procedure ActionVersion(): Text
    begin

        exit('1.2'); //-+NPR5.46 [314603]
    end;

    procedure CheckSaleBeforeCancel(POSSession: Codeunit "NPR POS Session")
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        //-NPR5.54 [364658]
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount <> 0) then
            Error(PartlyPaid);
        //+NPR5.54 [364658]
    end;

    procedure CancelSaleAndStartNew(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Line: Record "NPR Sale Line POS";
    begin
        //-NPR5.54 [364658]
        if not CancelSale(POSSession) then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.SelectViewForEndOfSale(POSSession);
        exit(true);
        //+NPR5.54 [364658]
    end;

    procedure CancelSale(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Line: Record "NPR Sale Line POS";
    begin
        //-NPR5.54 [364658]
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        with Line do begin
            Type := Type::Comment;
            //-NPR5.55 [391678]
            if AltSaleCancelDescription <> '' then begin
                Description := CopyStr(AltSaleCancelDescription, 1, MaxStrLen(Description));
                "Description 2" := CopyStr(AltSaleCancelDescription, MaxStrLen(Description) + 1, MaxStrLen("Description 2"));
            end else
                //+NPR5.55 [391678]
                Description := StrSubstNo(CANCEL_SALE, CurrentDateTime);
            "Sale Type" := "Sale Type"::Cancelled;
        end;
        POSSaleLine.InsertLine(Line);

        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndSale2(POSSession, false));
        //+NPR5.54 [364658]
    end;

    procedure SetAlternativeDescription(NewAltSaleCancelDescription: Text)
    begin
        //-NPR5.55 [391678]
        AltSaleCancelDescription := NewAltSaleCancelDescription;
        //+NPR5.55 [391678]
    end;
}

