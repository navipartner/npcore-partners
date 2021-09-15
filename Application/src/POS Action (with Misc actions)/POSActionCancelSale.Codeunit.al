codeunit 6150797 "NPR POSAction: Cancel Sale"
{
    var
        ActionDescriptionLbl: Label 'Cancel Sale';
        TitleLbl: Label 'Cancel Sale';
        PromptLbl: Label 'Are you sure you want to cancel this sales? All lines will be deleted.';
        PartlyPaidErr: Label 'This sales can''t be deleted. It has been partly paid. You must first void the payment.';
        CANCEL_SALELbl: Label 'Sale was canceled %1';
        AltSaleCancelDescription: Text;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescriptionLbl,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('', 'confirm(labels.title, labels.prompt).respond();');
            Sender.RegisterDataBinding();
            Sender.RegisterOptionParameter('Security', 'None,SalespersonPassword,CurrentSalespersonPassword,SupervisorPassword', 'None');
            Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        CancelSaleAndStartNew(POSSession);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'title', TitleLbl);
        Captions.AddActionCaption(ActionCode(), 'prompt', PromptLbl);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        CheckSaleBeforeCancel(POSSession);

        FrontEnd.SetActionContext(ActionCode(), Context);
        Handled := true;
    end;

    local procedure ActionCode(): Code[20]
    var
        CancelPosSalesLbl: Label 'CANCEL_POS_SALE', Locked = true;
    begin
        exit(CancelPosSalesLbl);
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.2');
    end;

    procedure CheckSaleBeforeCancel(POSSession: Codeunit "NPR POS Session")
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SaleAmount: Decimal;
        Subtotal: Decimal;
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.CalculateBalance(SaleAmount, PaidAmount, ReturnAmount, Subtotal);
        if (PaidAmount <> 0) then
            Error(PartlyPaidErr);
    end;

    procedure CancelSaleAndStartNew(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
    begin
        if not CancelSale(POSSession) then
            exit(false);

        POSSession.GetSale(POSSale);
        POSSale.SelectViewForEndOfSale(POSSession);
        exit(true);
    end;

    procedure CancelSale(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Line: Record "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.DeleteAll();

        Line.Type := Line.Type::Comment;
        if AltSaleCancelDescription <> '' then begin
            Line.Description := CopyStr(AltSaleCancelDescription, 1, MaxStrLen(Line.Description));
            Line."Description 2" := CopyStr(AltSaleCancelDescription, MaxStrLen(Line.Description) + 1, MaxStrLen(Line."Description 2"));
        end else
            Line.Description := StrSubstNo(CANCEL_SALELbl, CurrentDateTime);
        Line."Sale Type" := Line."Sale Type"::Cancelled;
        POSSaleLine.InsertLine(Line);

        POSSession.GetSale(POSSale);
        exit(POSSale.TryEndSale(POSSession, false));
    end;

    procedure SetAlternativeDescription(NewAltSaleCancelDescription: Text)
    begin
        AltSaleCancelDescription := NewAltSaleCancelDescription;
    end;
}

