codeunit 6150816 "NPR POSAction: VAT Refusion"
{
    var
        ActionDescription: Label 'This is a built in function for handling VAT refussion';
        Setup: Codeunit "NPR POS Setup";
        MaxAmountLimit: Label 'Maximum payment amount for %1 is %2.';
        MinAmountLimit: Label 'Minimum payment amount for %1 is %2.';
        TEXTConfirmRefussionTitle: Label 'Confirm VAT Refussion';
        TEXTConfrmRefussionLead: Label 'VAT Refussion payment of amount %1 are being added.\\Press Yes to add refussion payment. Press No to abort.';
        TEXTRefussionNotPos_title: Label 'VAT Refussion is not possible';
        TEXTRefussionNotPos_lead: Label 'VAT Amount can not be zero for VAT Refussion';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('VATREFUSION');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do begin
            if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion(),
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                RegisterWorkflowStep('VATAmt', 'context.VATAmount');
                RegisterWorkflowStep('confirmRefussion', 'if ( (param.AskForConfirm == true) && (context.VATAmount != 0) ) { confirm(labels.confirmRefussion_title,labels.confirmRefussion_lead.replace("%1",context.VATAmount)).no(abort); }');
                RegisterWorkflowStep('informRefussionNotPossible', 'if (context.VATAmount == 0) { message(labels.informRefussionNotPossible_title, labels.informRefussionNotPossible_lead); abort; }');
                RegisterWorkflowStep('doRefussion', 'if (context.VATAmount != 0) { respond(); } ');
                RegisterWorkflow(true);

                RegisterTextParameter('PaymentTypePOSCode', '');
                RegisterBooleanParameter('AskForConfirm', false);

            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'confirmRefussion_title', TEXTConfirmRefussionTitle);
        Captions.AddActionCaption(ActionCode, 'informRefussionNotPossible_title', TEXTRefussionNotPos_title);
        Captions.AddActionCaption(ActionCode, 'informRefussionNotPossible_lead', TEXTRefussionNotPos_lead);
        Captions.AddActionCaption(ActionCode, 'confirmRefussion_lead', TEXTConfrmRefussionLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;


        case WorkflowStep of
            'doRefussion':
                OnDoRefussion(Context, POSSession, FrontEnd);
        end;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', true, true)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; Parameters: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
        JSON: Codeunit "NPR POS JSON Management";
        TotalVATOnSale: Decimal;
        NPRPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR Sale POS";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        //Calc VAT amount before
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        TotalVATOnSale := CalcVATFromSale(SalePOS);

        //Check pos payment type
        JSON.InitializeJObjectParser(Parameters, FrontEnd);
        POSSession.GetPaymentLine(POSPaymentLine);
        NPRPOSPaymentMethod.Get(JSON.GetStringOrFail('PaymentTypePOSCode', StrSubstNo(ReadingErr, ActionCode())));

        ValidateMinMaxAmount(NPRPOSPaymentMethod, TotalVATOnSale);

        Context.SetContext('VATAmount', TotalVATOnSale);

        FrontEnd.SetActionContext(ActionCode, Context);

        Handled := true;
    end;

    local procedure "--"()
    begin
    end;

    local procedure OnConfirmRefussion(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    begin
    end;

    local procedure OnDoRefussion(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaymentLinePOS: Record "NPR Sale Line POS";
        TotalVATOnSale: Decimal;
        POSPaymentMethod: Record "NPR POS Payment Method";
    begin

        POSSession.GetSetup(Setup);

        //Get payment type
        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        POSSession.GetPaymentLine(POSPaymentLine);
        POSPaymentLine.GetPOSPaymentMethod(POSPaymentMethod, JSON.GetStringOrFail('PaymentTypePOSCode', StrSubstNo(ReadingErr, ActionCode())));
        POSPaymentMethod.Get(POSPaymentMethod.Code);

        //Get amount and add to payment line
        JSON.InitializeJObjectParser(Context, FrontEnd);
        PaymentLinePOS."No." := POSPaymentMethod.Code;
        PaymentLinePOS."Amount Including VAT" := JSON.GetDecimalOrFail('VATAmount', StrSubstNo(ReadingErr, ActionCode()));
        POSPaymentLine.InsertPaymentLine(PaymentLinePOS, 0);

        POSSession.RequestRefreshData();
    end;

    local procedure CalcVATFromSale(SalePOS: Record "NPR Sale POS") VATAmount: Decimal
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TotalVAT: Decimal;
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        PaymentLinePOS: Record "NPR Sale Line POS";
    begin
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

    local procedure ValidateMinMaxAmount(NPRPOSPaymentMethod: Record "NPR POS Payment Method"; AmountToCapture: Decimal)
    begin

        if (NPRPOSPaymentMethod."Maximum Amount" <> 0) then
            if (AmountToCapture > NPRPOSPaymentMethod."Maximum Amount") then
                Error(MaxAmountLimit, NPRPOSPaymentMethod.Description, NPRPOSPaymentMethod."Maximum Amount");

        if (NPRPOSPaymentMethod."Minimum Amount" <> 0) then
            if (AmountToCapture < NPRPOSPaymentMethod."Minimum Amount") then
                Error(MaxAmountLimit, NPRPOSPaymentMethod.Description, NPRPOSPaymentMethod."Minimum Amount");
    end;
}
