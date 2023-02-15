codeunit 6150855 "NPR POS Action: Ret.Amt.Dialog" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        ActionDescription: Label 'Show the return amount (change) after sale ends for mPOS.';

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::SHOW_RET_AMT_DIALOG));
    end;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        LabelConfirmEndOfSaleTitleLbl: Label '(MPOS) End of Sale';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('confirm_title', LabelConfirmEndOfSaleTitleLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'ConfirmReturnAmount':
                CreateReturnAmtMessage(Context, POSSession, Sale);
        end;
    end;

    local procedure CreateReturnAmtMessage(JSON: Codeunit "NPR POS JSON Helper"; POSSession: Codeunit "NPR POS Session"; POSSale: Codeunit "NPR POS Sale")
    var
        JObject: JsonObject;
        SalesAmount: Decimal;
        PaidAmount: Decimal;
        ReturnAmount: Decimal;
        SalesDateText: Text;
        ReceiptNo: Text;
        HTML: Text;
        HtmlLbl: Label '<center><table border="0" cellspacing="0"><tr><td align="left">Receipt No.</td><td align="right">%1</td></tr><tr><td align="left">Sales Amount</td><td align="right">%2</td></tr><tr><td align="left">Paid Amount</td><td align="right">%3</td></tr><tr><td>&nbsp;</td></tr><tr><td align="left"><h2>Amount to Return&nbsp;&nbsp;</h2></td><td align="right"><h2>%4</h2></td></tr></table>', Locked = true;
    begin
        JSON.InitializeJObjectParser(JObject);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure ShowReturnAmountDialog(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    var
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
        POSUnit.Get(SalePOS."Register No.");
        if POSUnit."POS Type" <> POSUnit."POS Type"::MPOS then
            exit;

        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        POSEntry.SetRange("Entry Type", POSEntry."Entry Type"::"Cancelled Sale");
        if not POSEntry.IsEmpty then
            exit;

        POSFrontEnd.GetSession(POSSession);
        POSSession.RetrieveSessionAction(ActionCode(), POSAction);
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Action: Ret.Amt.Dialog");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRetAmtDialog.js###
'let main=async({workflow:t,context:a,popup:e,captions:i})=>{await t.respond("ConfirmReturnAmount"),await e.message({title:i.confirm_title,caption:a.confirm_message})};'
        );
    end;
}

