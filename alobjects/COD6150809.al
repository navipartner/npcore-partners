codeunit 6150809 "POS Action - PayIn Payout"
{
    // NPR5.38/MHA /20180119  CASE 295072 Extended Workflow with Reason Code
    // NPR5.48/TSA /20190207 CASE 345292 Added UpdateAmounts() to get correct VAT calculation


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This built in function handles cash deposit / withdrawls from the till';
        PayOptionType: Option PAYIN,PAYOUT;
        AmountPrompt: Label 'Enter Amount.';
        DescriptionPrompt: Label 'Enter Description.';

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
            RegisterWorkflowStep ('account', 'respond();');
            RegisterWorkflowStep ('amount', 'numpad (labels.Amount).cancel(abort);');
            RegisterWorkflowStep ('description', 'input({caption: labels.Description, value: context.accountdescription}).cancel(abort);');
            RegisterWorkflowStep ('handle', 'respond();');
            //-NPR5.38 [295072]
            RegisterWorkflowStep('FixedReasonCode','if (param.FixedReasonCode != "")  {respond()}');
            RegisterWorkflowStep('LookupReasonCode','if (param.LookupReasonCode)  {respond()}');
            //+NPR5.38 [295072]
            RegisterWorkflow (false);
            RegisterOptionParameter ('Pay Option', 'Pay In,Payout','Payout');
            //-NPR5.38 [295072]
            RegisterTextParameter('FixedAccountCode','');
            RegisterTextParameter('FixedReasonCode','');
            RegisterBooleanParameter('LookupReasonCode',false);
            //+NPR5.38 [295072]
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'Amount', AmountPrompt);
        Captions.AddActionCaption (ActionCode, 'Description', DescriptionPrompt);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        PayOption: Integer;
        AccountNo: Code[20];
        Description: Text;
        Amount: Decimal;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope ('parameters', true);
        PayOption := JSON.GetInteger ('Pay Option', true);

        if (PayOption = -1) then
          PayOption := 0;

        case WorkflowStep of
          //-NPR5.38 [295072]
          //'account' : SelectAccount (JSON, POSSession, FrontEnd);
          'account':
            SelectAccount(JSON,FrontEnd);
          //+NPR5.38 [295072]
          'handle' :
            begin

              Description := GetInput (JSON, 'description');
              Amount := GetDecimal (JSON, 'amount');
              JSON.SetScope ('/', true);
              AccountNo := JSON.GetString ('accountno', true);

              case PayOption of
                0 : RegisterAccountSales (POSSession, AccountNo, Description, Amount, PayOptionType::PAYIN);
                1 : RegisterAccountSales (POSSession, AccountNo, Description, Amount, PayOptionType::PAYOUT);
              end;

              POSSession.ChangeViewSale();
              POSSession.RequestRefreshData();

            end;
          //-NPR5.38 [295072]
          'FixedReasonCode':
            OnActionFixedReasonCode(JSON,POSSession);
          'LookupReasonCode':
            OnActionLookupReasonCode(POSSession);
          //+NPR5.38 [295072]
        end;

        Handled := true;
    end;

    local procedure OnActionFixedReasonCode(JSON: Codeunit "POS JSON Management";POSSession: Codeunit "POS Session")
    var
        ReasonCode: Code[10];
    begin
        //-NPR5.38 [295072]
        JSON.SetScope('/', true);
        JSON.SetScope('parameters',true);
        ReasonCode := JSON.GetString('FixedReasonCode',true);
        if ReasonCode = '' then
          exit;

        ApplyReasonCode(ReasonCode,POSSession);
        //+NPR5.38 [295072]
    end;

    local procedure OnActionLookupReasonCode(POSSession: Codeunit "POS Session")
    var
        ReasonCode: Record "Reason Code";
    begin
        //-NPR5.38 [295072]
        if PAGE.RunModal(0,ReasonCode) <> ACTION::LookupOK then
          exit;

        ApplyReasonCode(ReasonCode.Code,POSSession);
        //+NPR5.38 [295072]
    end;

    local procedure ActionCode(): Text
    begin
        exit ('PAYIN_PAYOUT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    local procedure SelectAccount(JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management")
    var
        GLAccount: Record "G/L Account";
        AccountNo: Text;
    begin
        //-NPR5.38 [295072]
        // IF NOT (PAGE.RUNMODAL(PAGE::"Touch Screen - G/L Accounts", GLAccount) = ACTION::LookupOK) THEN
        //  ERROR ('');
        //
        // Context.SetScope ('/', TRUE);
        // Context.SetContext ('accountno', GLAccount."No.");
        // Context.SetContext ('accountdescription', GLAccount.Name);
        // FrontEnd.SetActionContext (ActionCode, Context);
        JSON.SetScope('/', true);
        JSON.SetScope('parameters',true);
        AccountNo := UpperCase(JSON.GetString('FixedAccountCode',false));
        if AccountNo <> '' then
          GLAccount.Get(AccountNo)
        else if PAGE.RunModal(PAGE::"Touch Screen - G/L Accounts",GLAccount) <> ACTION::LookupOK then
          Error ('');

        JSON.SetScope ('/', true);
        JSON.SetContext ('accountno', GLAccount."No.");
        JSON.SetContext ('accountdescription',GLAccount.Name);
        FrontEnd.SetActionContext (ActionCode,JSON);
        //+NPR5.38 [295072]
    end;

    local procedure RegisterAccountSales(POSSession: Codeunit "POS Session";AccountNo: Code[20];Description: Text;Amount: Decimal;PayOption: Option)
    var
        Line: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
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

        POSSaleLine.GetCurrentSaleLine (Line);
        Line.Description := Description;

        //-NPR5.48 [345292]
        Line.UpdateAmounts (Line);
        //+NPR5.48 [345292]

        Line.Modify ();

        POSSaleLine.RefreshCurrent ();
    end;

    local procedure ApplyReasonCode(ReasonCode: Code[10];var POSSession: Codeunit "POS Session")
    var
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
    begin
        //-NPR5.38 [295072]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        SaleLinePOS.SetSkipCalcDiscount(true);
        SaleLinePOS."Reason Code" := ReasonCode;
        SaleLinePOS.Modify(true);
        //+NPR5.38 [295072]
    end;

    local procedure "--"()
    begin
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin

        JSON.SetScope ('/', true);
        if (not JSON.SetScope ('$'+Path, false)) then
          exit ('');

        exit (JSON.GetString ('input', true));
    end;

    local procedure GetDecimal(JSON: Codeunit "POS JSON Management";Path: Text): Decimal
    begin

        JSON.SetScope ('/', true);
        if (not JSON.SetScope ('$'+Path, false)) then
          exit (0);

        exit (JSON.GetDecimal ('numpad', true));
    end;
}

