codeunit 6150864 "POS Action - Customer Deposit"
{
    // NPR5.50/MMV /20181105 CASE 300557 New action, based on CU 6150806


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Collect customer deposits, optionally applied directly to entries.';
        CAPTION_INVOICENOPROMPT: Label 'Enter document no.';
        CAPTION_AMOUNTPROMPT: Label 'Enter amount to deposit';
        TextDeposit: Label 'Deposit from: %1';
        BalanceIsZero: Label 'Customer balance is 0, there is nothing to add.';
        CAPTION_DEPOSITTYPE: Label 'Deposit Type';
        CAPTION_CUSTOMERVIEW: Label 'Customer Entry View';
        DESC_DEPOSITTYPE: Label 'Select how deposit is entered';
        DESC_CUSTOMERVIEW: Label 'Pre-filtered customer entry view';
        OPTION_DEPOSITTYPE: Label 'Apply To Customer Entries,Invoice No. Prompt,Amount Prompt,Match Amount To Customer Balance';

    local procedure ActionCode(): Text
    begin
        exit ('CUSTOMER_DEPOSIT');
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
            RegisterWorkflowStep('Prompt',
              '(param.DepositType == 1) && input(labels.InvoiceNoPrompt).cancel(abort);' +
              '(param.DepositType == 2) && numpad(labels.AmountPrompt).cancel(abort);');
            RegisterWorkflowStep('CreateDeposit','respond();');
            RegisterWorkflow(false);

            RegisterOptionParameter('DepositType', 'ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance', 'ApplyCustomerEntries');
            RegisterTextParameter('CustomerEntryView', '');
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption (ActionCode, 'InvoiceNoPrompt', CAPTION_INVOICENOPROMPT);
        Captions.AddActionCaption (ActionCode, 'AmountPrompt', CAPTION_AMOUNTPROMPT);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance;
        CustomerEntryView: Text;
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        DepositType := JSON.GetIntegerParameter('DepositType', true);
        CustomerEntryView := JSON.GetStringParameter('CustomerEntryView', true);

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case DepositType of
          DepositType::ApplyCustomerEntries : ApplyCustomerEntries(POSSession, CustomerEntryView);
          DepositType::InvoiceNoPrompt : DocumentNoPrompt(POSSession, JSON);
          DepositType::MatchCustomerBalance : MatchCustomerBalance(POSSession);
          DepositType::AmountPrompt : AmountPrompt(POSSession, JSON);
        end;
        POSSession.RequestRefreshData();
    end;

    local procedure AmountPrompt(POSSession: Codeunit "POS Session";JSON: Codeunit "POS JSON Management")
    var
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Amount: Decimal;
    begin
        SelectCustomer(POSSession);

        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);

        Amount := GetNumpad(JSON, 'Prompt');

        InsertDepositLine(POSSaleLine, SalePOS, Amount);
    end;

    local procedure ApplyCustomerEntries(POSSession: Codeunit "POS Session";CustomerEntryView: Text)
    var
        POSApplyCustomerEntries: Codeunit "POS Apply Customer Entries";
    begin
        SelectCustomer(POSSession);
        POSApplyCustomerEntries.SelectCustomerEntries(POSSession, CustomerEntryView);
    end;

    local procedure DocumentNoPrompt(POSSession: Codeunit "POS Session";JSON: Codeunit "POS JSON Management")
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        POSApplyCustomerEntries: Codeunit "POS Apply Customer Entries";
        InvoiceNo: Text;
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        InvoiceNo := GetInput(JSON, 'Prompt');

        if (InvoiceNo = '') then
          exit;

        POSApplyCustomerEntries.BalanceDocument (POSSession, CustLedgerEntry."Document Type"::Invoice, InvoiceNo, false);
    end;

    local procedure MatchCustomerBalance(POSSession: Codeunit "POS Session")
    var
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
    begin
        SelectCustomer(POSSession);

        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);

        Customer.SetAutoCalcFields("Balance (LCY)");
        Customer.Get (SalePOS."Customer No.");
        Customer.TestField("Balance (LCY)");

        InsertDepositLine(POSSaleLine, SalePOS, Customer."Balance (LCY)");
    end;

    local procedure InsertDepositLine(var POSSaleLine: Codeunit "POS Sale Line";SalePOS: Record "Sale POS";Amount: Decimal)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate("No.", SalePOS."Customer No.");
        SaleLinePOS.Amount := Amount;
        SaleLinePOS."Amount Including VAT" := Amount;
        SaleLinePOS."Unit Price" := Amount;
        SaleLinePOS.Description := StrSubstNo(TextDeposit, SalePOS.Name);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure SelectCustomer(POSSession: Codeunit "POS Session"): Boolean
    var
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Customer: Record Customer;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." <> '' then begin
          SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
          exit(true);
        end;

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
          exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit;
        exit(true);
    end;

    local procedure GetInput(JSON: Codeunit "POS JSON Management";Path: Text): Text
    begin
        JSON.SetScope ('/', true);
        if (not JSON.SetScope ('$'+Path, false)) then
          exit ('');

        exit (JSON.GetString ('input', true));
    end;

    local procedure GetNumpad(JSON: Codeunit "POS JSON Management";Path: Text): Decimal
    begin
        JSON.SetScope ('/', true);
        if (not JSON.SetScope ('$'+Path, false)) then
          exit (0);

        exit (JSON.GetDecimal ('numpad', true));
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'DepositType' : Caption := CAPTION_DEPOSITTYPE;
          'CustomerEntryView' : Caption := CAPTION_CUSTOMERVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'DepositType' : Caption := DESC_DEPOSITTYPE;
          'CustomerEntryView' : Caption := DESC_CUSTOMERVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'DepositType' : Caption := OPTION_DEPOSITTYPE;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'CustomerEntryView' :
            begin
              FilterPageBuilder.AddRecord(CustLedgerEntry.TableCaption, CustLedgerEntry);
              if POSParameterValue.Value <> '' then begin
                CustLedgerEntry.SetView(POSParameterValue.Value);
                FilterPageBuilder.SetView(CustLedgerEntry.TableCaption, CustLedgerEntry.GetView(false));
              end;
              if FilterPageBuilder.RunModal() then
                POSParameterValue.Value := FilterPageBuilder.GetView(CustLedgerEntry.TableCaption, false);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "POS Parameter Value")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'CustomerEntryView' :
            begin
              if POSParameterValue.Value <> '' then
                CustLedgerEntry.SetView(POSParameterValue.Value);
            end;
        end;
    end;
}

