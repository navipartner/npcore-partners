codeunit 6150816 "POS Action - VAT Refussion"
{
    // NPR5.32/NPKNAV/20170526  CASE 269014 Transport NPR5.32 - 26 May 2017


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built in function for handling VAT refussion';
        Setup: Codeunit "POS Setup";
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MinAmountLimit: Label 'Minimum payment amount for %1 is %2.';
        TEXTConfirmRefussionTitle: Label 'Confirm VAT Refussion';
        TEXTConfrmRefussionLead: Label 'VAT Refussion payment of amount %1 are being added.\\Press Yes to add refussion payment. Press No to abort.';
        TEXTRefussionNotPos_title: Label 'VAT Refussion is not possible';
        TEXTRefussionNotPos_lead: Label 'VAT Amount can not be zero for VAT Refussion';

    local procedure ActionCode(): Text
    begin
        exit ('VATREFUSION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do begin
          if DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple) then
          begin
            RegisterWorkflowStep('VATAmt', 'context.VATAmount');
            RegisterWorkflowStep('confirmRefussion','if ( (param.AskForConfirm == true) && (context.VATAmount != 0) ) { confirm(labels.confirmRefussion_title,labels.confirmRefussion_lead.replace("%1",context.VATAmount)).no(abort); }');
            RegisterWorkflowStep('informRefussionNotPossible','if (context.VATAmount == 0) { message(labels.informRefussionNotPossible_title, labels.informRefussionNotPossible_lead); abort; }');
            RegisterWorkflowStep('doRefussion', 'if (context.VATAmount != 0) { respond(); } ');
            RegisterWorkflow(true);

            RegisterTextParameter('PaymentTypePOSCode', '');
            RegisterBooleanParameter('AskForConfirm', false);

          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode,'confirmRefussion_title',TEXTConfirmRefussionTitle);
        Captions.AddActionCaption (ActionCode,'informRefussionNotPossible_title', TEXTRefussionNotPos_title);
        Captions.AddActionCaption (ActionCode,'informRefussionNotPossible_lead', TEXTRefussionNotPos_lead);
        Captions.AddActionCaption (ActionCode,'confirmRefussion_lead', TEXTConfrmRefussionLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;


        case WorkflowStep of
          'doRefussion' : OnDoRefussion(Context, POSSession,FrontEnd);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";Parameters: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
        JSON: Codeunit "POS JSON Management";
        TotalVATOnSale: Decimal;
        PaymentTypePOS: Record "Payment Type POS";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        POSPaymentLine: Codeunit "POS Payment Line";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //Calc VAT amount before
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        TotalVATOnSale := CalcVATFromSale(SalePOS);

        //Check pos payment type
        JSON.InitializeJObjectParser(Parameters,FrontEnd);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentType(PaymentTypePOS, JSON.GetString('PaymentTypePOSCode', true), SalePOS."Register No.");
        PaymentTypePOS.Get(PaymentTypePOS."No.", PaymentTypePOS."Register No.");

        ValidateMinMaxAmount(PaymentTypePOS, TotalVATOnSale);

        Context.SetContext('VATAmount',TotalVATOnSale);

        FrontEnd.SetActionContext(ActionCode,Context);

        Handled := true;
    end;

    local procedure "--"()
    begin
    end;

    local procedure OnConfirmRefussion(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    begin
    end;

    local procedure OnDoRefussion(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        POSPaymentLine: Codeunit "POS Payment Line";
        PaymentLinePOS: Record "Sale Line POS";
        TotalVATOnSale: Decimal;
        PaymentTypePOS: Record "Payment Type POS";
    begin

        POSSession.GetSetup(Setup);

        //Get payment type
        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters', true);
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPaymentType(PaymentTypePOS, JSON.GetString('PaymentTypePOSCode', true), SalePOS."Register No.");
        PaymentTypePOS.Get(PaymentTypePOS."No.", PaymentTypePOS."Register No.");

        //Get amount and add to payment line
        JSON.InitializeJObjectParser(Context,FrontEnd);
        PaymentLinePOS."No." := PaymentTypePOS."No.";
        PaymentLinePOS."Amount Including VAT" := JSON.GetDecimal('VATAmount', true);
        POSPaymentLine.InsertPaymentLine (PaymentLinePOS, 0);

        POSSession.RequestRefreshData();
    end;

    local procedure "---"()
    begin
    end;

    local procedure CalcVATFromSale(SalePOS: Record "Sale POS") VATAmount: Decimal
    var
        SaleLinePOS: Record "Sale Line POS";
        TotalVAT: Decimal;
        PaymentTypePOS: Record "Payment Type POS";
        POSPaymentLine: Codeunit "POS Payment Line";
        PaymentLinePOS: Record "Sale Line POS";
    begin
        //SalePOS."Price including VAT";
        //Register No.,Sales Ticket No.,Date,Sale Type,Line No.
        SaleLinePOS.Reset;
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Date, SalePOS.Date);
        SaleLinePOS.SetRange("Sale Type", SalePOS."Sale type");

        if SaleLinePOS.IsEmpty then exit;
        SaleLinePOS.FindSet(false, false);
        TotalVAT := 0;
        repeat
          TotalVAT := TotalVAT + (SaleLinePOS."Amount Including VAT" - SaleLinePOS."VAT Base Amount");


        until (0 = SaleLinePOS.Next);

        exit(TotalVAT);
    end;

    local procedure ValidateMinMaxAmount(PaymentTypePOS: Record "Payment Type POS";AmountToCapture: Decimal)
    begin

        if (PaymentTypePOS."Maximum Amount" <> 0) then
          if (AmountToCapture > PaymentTypePOS."Maximum Amount") then
            Error  (MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Maximum Amount");

        if (PaymentTypePOS."Minimum Amount" <> 0) then
          if (AmountToCapture < PaymentTypePOS."Minimum Amount") then
            Error (MaxAmountLimit, PaymentTypePOS.Description, PaymentTypePOS."Minimum Amount");
    end;
}

