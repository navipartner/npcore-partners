codeunit 6150809 "NPR POSAction: PayIn Payout"
{
    var
        ActionDescription: Label 'This built in function handles cash deposit / withdrawls from the till';
        PayOptionType: Option PAYIN,PAYOUT;
        AmountPrompt: Label 'Enter Amount';
        DescriptionPrompt: Label 'Enter Description';
        VATSetupError: Label 'Pay-in and Pay-out are cash transactions that must not use accounts that post VAT. Check setup for account %1.';
        ReadingErr: Label 'reading in %1';

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
                RegisterWorkflowStep('account', 'respond();');
                RegisterWorkflowStep('amount', 'numpad (labels.Amount).cancel(abort);');
                RegisterWorkflowStep('description', 'input({caption: labels.Description, value: context.accountdescription}).cancel(abort);');
                RegisterWorkflowStep('handle', 'respond();');
                RegisterWorkflowStep('FixedReasonCode', 'if (param.FixedReasonCode != "")  {respond()}');
                RegisterWorkflowStep('LookupReasonCode', 'if (param.LookupReasonCode)  {respond()}');
                RegisterWorkflow(false);
                RegisterOptionParameter('Pay Option', 'Pay In,Payout', 'Payout');
                RegisterTextParameter('FixedAccountCode', '');
                RegisterTextParameter('FixedReasonCode', '');
                RegisterBooleanParameter('LookupReasonCode', false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'Amount', AmountPrompt);
        Captions.AddActionCaption(ActionCode, 'Description', DescriptionPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        PayOption: Integer;
        AccountNo: Code[20];
        Description: Text;
        Amount: Decimal;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());
        PayOption := JSON.GetIntegerOrFail('Pay Option', StrSubstNo(ReadingErr, ActionCode()));

        if (PayOption = -1) then
            PayOption := 0;

        case WorkflowStep of
            'account':
                SelectAccount(JSON, FrontEnd);
            'handle':
                begin

                    Description := GetInput(JSON, 'description');
                    Amount := GetDecimal(JSON, 'amount');
                    JSON.SetScopeRoot();
                    AccountNo := JSON.GetStringOrFail('accountno', StrSubstNo(ReadingErr, ActionCode()));

                    case PayOption of
                        0:
                            RegisterAccountSales(POSSession, AccountNo, Description, Amount, PayOptionType::PAYIN);
                        1:
                            RegisterAccountSales(POSSession, AccountNo, Description, Amount, PayOptionType::PAYOUT);
                    end;

                    POSSession.ChangeViewSale();
                    POSSession.RequestRefreshData();

                end;
            'FixedReasonCode':
                OnActionFixedReasonCode(JSON, POSSession);
            'LookupReasonCode':
                OnActionLookupReasonCode(POSSession);
        end;

        Handled := true;
    end;

    local procedure OnActionFixedReasonCode(JSON: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session")
    var
        ReasonCode: Code[10];
    begin
        JSON.SetScopeRoot();
        JSON.SetScopeParameters(ActionCode());
        ReasonCode := JSON.GetStringOrFail('FixedReasonCode', StrSubstNo(ReadingErr, ActionCode()));
        if ReasonCode = '' then
            exit;

        ApplyReasonCode(ReasonCode, POSSession);
    end;

    local procedure OnActionLookupReasonCode(POSSession: Codeunit "NPR POS Session")
    var
        ReasonCode: Record "Reason Code";
    begin
        if PAGE.RunModal(0, ReasonCode) <> ACTION::LookupOK then
            exit;

        ApplyReasonCode(ReasonCode.Code, POSSession);
    end;

    local procedure ActionCode(): Text
    begin
        exit('PAYIN_PAYOUT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    local procedure SelectAccount(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        GLAccount: Record "G/L Account";
        AccountNo: Text;
    begin
        JSON.SetScopeRoot();
        JSON.SetScopeParameters(ActionCode());
        AccountNo := UpperCase(JSON.GetString('FixedAccountCode'));
        if AccountNo <> '' then
            GLAccount.Get(AccountNo)
        else
            if PAGE.RunModal(PAGE::"NPR TouchScreen: G/L Accounts", GLAccount) <> ACTION::LookupOK then
                Error('');

        JSON.SetScopeRoot();
        JSON.SetContext('accountno', GLAccount."No.");
        JSON.SetContext('accountdescription', GLAccount.Name);
        FrontEnd.SetActionContext(ActionCode, JSON);
    end;

    local procedure RegisterAccountSales(POSSession: Codeunit "NPR POS Session"; AccountNo: Code[20]; Description: Text; Amount: Decimal; PayOption: Option)
    var
        Line: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin

        if (PayOption = PayOptionType::PAYIN) then
            Amount *= -1;

        Line.Type := Line.Type::"G/L Entry";
        Line."Sale Type" := Line."Sale Type"::"Out payment";
        Line."No." := AccountNo;
        Line.Description := Description;
        Line."Custom Descr" := (Description <> '');
        Line.Quantity := 1;
        Line."Amount Including VAT" := Amount;
        Line."Unit Price" := Amount;

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.InsertLine(Line);

        POSSaleLine.GetCurrentSaleLine(Line);
        Line.Description := Description;

        Line.UpdateAmounts(Line);

        Line.Modify();

        POSSaleLine.RefreshCurrent();
    end;

    local procedure ApplyReasonCode(ReasonCode: Code[10]; var POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR Sale POS";
        SaleLinePOS: Record "NPR Sale Line POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS."Reason Code" := ReasonCode;
        SaleLinePOS.Modify(true);
    end;

    local procedure "--"()
    begin
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())));
    end;

    local procedure GetDecimal(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin

        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit(0);

        exit(JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode())));
    end;
}
