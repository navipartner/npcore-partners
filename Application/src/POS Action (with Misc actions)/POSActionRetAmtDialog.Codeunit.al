codeunit 6150855 "NPR POS Action: Ret.Amt.Dialog"
{
    // NPR5.46/MMV /20180716 CASE 290734 Created object
    // NPR5.54/MMV /20200220 CASE 364658 Skip for cancelled sales


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Show the return amount (change) after sale ends for mPOS.';
        ConfirmEndOfSaleTitle: Label '(MPOS) End of Sale';

    local procedure ActionCode(): Text
    begin
        exit('SHOW_RET_AMT_DIALOG');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'confirm_title', ConfirmEndOfSaleTitle);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
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
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;

        JSON.InitializeJObjectParser(Parameters, FrontEnd);
        POSSession.GetSale(POSSale);
        POSSale.GetLastSaleInfo(SalesAmount, PaidAmount, SalesDateText, ReturnAmount, ReceiptNo);
        ReturnAmount := Abs(ReturnAmount);

        HTML :=
        StrSubstNo('<center>' +
        '<table border="0" cellspacing="0">' +
        '<tr><td align="left">Receipt No.</td><td align="right">%1</td></tr>' +
        '<tr><td align="left">Sales Amount</td><td align="right">%2</td></tr>' +
        '<tr><td align="left">Paid Amount</td><td align="right">%3</td></tr>' +
        '<tr><td>&nbsp;</td></tr><tr><td align="left"><h2>Amount to Return&nbsp;&nbsp;</h2></td>' +
        '<td align="right"><h2>%4</h2></td></tr>' +
        '</table>',
          ReceiptNo,
          Format(SalesAmount, 0, '<Precision,2:2><Standard Format,0>'),
          Format(PaidAmount, 0, '<Precision,2:2><Standard Format,0>'),
          Format(ReturnAmount, 0, '<Precision,2:2><Standard Format,0>'));

        JSON.SetContext('confirm_message', HTML);
        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        OperationType: Option VoidLast,ReprintLast,LookupLast,OpenConn,CloseConn,VerifySetup,ShowTransactions,AuxOperation;
        EftType: Text;
        JSON: Codeunit "NPR POS JSON Management";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        AuxId: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    local procedure "--- OnFinishSale Workflow"()
    begin
    end;

    [EventSubscriber(ObjectType::Table, 6150730, 'OnBeforeInsertEvent', '', true, true)]
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

    [EventSubscriber(ObjectType::Codeunit, 6150705, 'OnFinishSale', '', true, true)]
    local procedure ShowReturnAmountDialog(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR Sale POS")
    var
        MPOSAppSetup: Record "NPR MPOS App Setup";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSAction: Record "NPR POS Action";
        POSEntry: Record "NPR POS Entry";
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;
        if POSSalesWorkflowStep."Subscriber Function" <> 'ShowReturnAmountDialog' then
            exit;
        if not MPOSAppSetup.IsMPOSEnabled(SalePOS."Register No.") then
            exit;
        if not POSSession.IsActiveSession(POSFrontEnd) then
            exit;

        //-NPR5.54 [364658]
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        if not POSEntry.IsEmpty then
            exit;
        //+NPR5.54 [364658]

        POSFrontEnd.GetSession(POSSession);
        POSSession.RetrieveSessionAction(ActionCode, POSAction);
        POSFrontEnd.InvokeWorkflow(POSAction);
    end;
}

