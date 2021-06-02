codeunit 6150855 "NPR POS Action: Ret.Amt.Dialog"
{
    var
        ActionDescription: Label 'Show the return amount (change) after sale ends for mPOS.';
        ConfirmEndOfSaleTitle: Label '(MPOS) End of Sale';

    local procedure ActionCode(): Text
    begin
        exit('SHOW_RET_AMT_DIALOG');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::Generic,
          Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('ConfirmReturnAmount', 'message ({title: labels.confirm_title, caption: context.confirm_message});');
            Sender.RegisterWorkflow(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'confirm_title', ConfirmEndOfSaleTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        POSSale: Codeunit "NPR POS Sale";
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesDateText: Text;
        ReceiptNo: Text;
        HTML: Text;
        JSON: Codeunit "NPR POS JSON Management";
        HtmlLbl: Label '<center><table border="0" cellspacing="0"><tr><td align="left">Receipt No.</td><td align="right">%1</td></tr><tr><td align="left">Sales Amount</td><td align="right">%2</td></tr><tr><td align="left">Paid Amount</td><td align="right">%3</td></tr><tr><td>&nbsp;</td></tr><tr><td align="left"><h2>Amount to Return&nbsp;&nbsp;</h2></td><td align="right"><h2>%4</h2></td></tr></table>', Locked = true;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Parameters, FrontEnd);
        POSSession.GetSale(POSSale);
        POSSale.GetLastSaleInfo(SalesAmount, PaidAmount, SalesDateText, ReturnAmount, ReceiptNo);
        ReturnAmount := Abs(ReturnAmount);

        HTML :=
        StrSubstNo(HtmlLbl,
          ReceiptNo,
          Format(SalesAmount, 0, '<Precision,2:2><Standard Format,0>'),
          Format(PaidAmount, 0, '<Precision,2:2><Standard Format,0>'),
          Format(ReturnAmount, 0, '<Precision,2:2><Standard Format,0>'));

        JSON.SetContext('confirm_message', HTML);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if Rec."Subscriber Function" <> 'ShowReturnAmountDialog' then
            exit;

        Rec.Description := ActionDescription;
        Rec."Sequence No." := 80;
        Rec.Enabled := true;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Ret.Amt.Dialog");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure ShowReturnAmountDialog(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
        MPOSProfile: Record "NPR MPOS Profile";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSAction: Record "NPR POS Action";
        POSEntry: Record "NPR POS Entry";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'ShowReturnAmountDialog' then
            exit;
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit;
        POSUnit.Get(SalePOS."Register No.");
        if not POSUnit.GetProfile(MPOSProfile) then
            exit;

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        if not POSEntry.IsEmpty then
            exit;

        POSFrontEnd.GetSession(POSSession);
        POSSession.RetrieveSessionAction(ActionCode(), POSAction);
        POSFrontEnd.InvokeWorkflow(POSAction);
    end;
}

