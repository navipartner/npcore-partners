codeunit 6150864 "NPR POS Action: Cust. Deposit"
{
    Access = Internal;
    var
        ActionDescription: Label 'Collect customer deposits, optionally applied directly to entries.';
        CAPTION_INVOICENOPROMPT: Label 'Enter document no.';
        CAPTION_AMOUNTPROMPT: Label 'Enter amount to deposit';
        TextDeposit: Label 'Deposit from: %1';
        CAPTION_DEPOSITTYPE: Label 'Deposit Type';
        CAPTION_CUSTOMERVIEW: Label 'Customer Entry View';
        DESC_DEPOSITTYPE: Label 'Select how deposit is entered';
        DESC_CUSTOMERVIEW: Label 'Pre-filtered customer entry view';
        OPTION_DEPOSITTYPE: Label 'Apply To Customer Entries,Invoice No. Prompt,Amount Prompt,Match Amount To Customer Balance,Cr. Memo No. Prompt';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('CUSTOMER_DEPOSIT');
    end;

    local procedure ActionVersion(): Text[30]
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
          Sender."Subscriber Instances Allowed"::Multiple) then begin


            Sender.RegisterWorkflowStep('Prompt',
              '(param.DepositType == 1) && input(labels.InvoiceNoPrompt).cancel(abort);' +
              '(param.DepositType == 2) && numpad(labels.AmountPrompt).cancel(abort);' +
              '(param.DepositType == 4) && input(labels.CrMemoNoPrompt).cancel(abort);');
            Sender.RegisterWorkflowStep('CreateDeposit', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterOptionParameter('DepositType', 'ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt', 'ApplyCustomerEntries');
            Sender.RegisterTextParameter('CustomerEntryView', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'InvoiceNoPrompt', CAPTION_INVOICENOPROMPT);
        Captions.AddActionCaption(ActionCode(), 'AmountPrompt', CAPTION_AMOUNTPROMPT);
        Captions.AddActionCaption(ActionCode(), 'CrMemoNoPrompt', CAPTION_INVOICENOPROMPT);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        DepositType: Option ApplyCustomerEntries,InvoiceNoPrompt,AmountPrompt,MatchCustomerBalance,CrMemoNoPrompt;
        CustomerEntryView: Text;
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);

        DepositType := JSON.GetIntegerParameterOrFail('DepositType', ActionCode());
        CustomerEntryView := JSON.GetStringParameterOrFail('CustomerEntryView', ActionCode());

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        case DepositType of
            DepositType::ApplyCustomerEntries:
                ApplyCustomerEntries(POSSession, CustomerEntryView);
            DepositType::InvoiceNoPrompt:
                DocumentNoPrompt(POSSession, JSON);
            DepositType::MatchCustomerBalance:
                MatchCustomerBalance(POSSession);
            DepositType::AmountPrompt:
                AmountPrompt(POSSession, JSON);
            DepositType::CrMemoNoPrompt:
                CrMemoNoPrompt(POSSession, JSON);
        end;
        POSSession.RequestRefreshData();
    end;

    local procedure AmountPrompt(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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

    local procedure ApplyCustomerEntries(POSSession: Codeunit "NPR POS Session"; CustomerEntryView: Text)
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
    begin
        SelectCustomer(POSSession);
        POSApplyCustomerEntries.SelectCustomerEntries(POSSession, CustomerEntryView);
    end;

    local procedure DocumentNoPrompt(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        InvoiceNo: Text[20];
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        InvoiceNo := CopyStr(GetInput(JSON, 'Prompt'), 1, MaxStrLen(InvoiceNo));

        if (InvoiceNo = '') then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, InvoiceNo, false);
    end;

    local procedure CrMemoNoPrompt(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management")
    var
        POSApplyCustomerEntries: Codeunit "NPR POS Apply Customer Entries";
        CrMemoNo: Text[20];
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CrMemoNo := CopyStr(GetInput(JSON, 'Prompt'), 1, MaxStrLen(CrMemoNo));

        if (CrMemoNo = '') then
            exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::"Credit Memo", CrMemoNo, false);
    end;

    local procedure MatchCustomerBalance(POSSession: Codeunit "NPR POS Session")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
        Customer: Record Customer;
    begin
        SelectCustomer(POSSession);

        POSSession.GetSaleLine(POSSaleLine);
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");
        SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);

        Customer.SetAutoCalcFields("Balance (LCY)");
        Customer.Get(SalePOS."Customer No.");
        Customer.TestField("Balance (LCY)");

        InsertDepositLine(POSSaleLine, SalePOS, Customer."Balance (LCY)");
    end;

    local procedure InsertDepositLine(var POSSaleLine: Codeunit "NPR POS Sale Line"; SalePOS: Record "NPR POS Sale"; Amount: Decimal)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate("No.", SalePOS."Customer No.");
        SaleLinePOS.Quantity := 1;
        SaleLinePOS.Amount := Amount;
        SaleLinePOS."Amount Including VAT" := Amount;
        SaleLinePOS."Unit Price" := Amount;
        SaleLinePOS.Description := StrSubstNo(TextDeposit, SalePOS.Name);
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure SelectCustomer(POSSession: Codeunit "NPR POS Session"): Boolean
    var
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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
        Commit();
        exit(true);
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, ActionCode())));
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit(0);

        exit(JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, ActionCode())));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DepositType':
                Caption := CAPTION_DEPOSITTYPE;
            'CustomerEntryView':
                Caption := CAPTION_CUSTOMERVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DepositType':
                Caption := DESC_DEPOSITTYPE;
            'CustomerEntryView':
                Caption := DESC_CUSTOMERVIEW;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'DepositType':
                Caption := OPTION_DEPOSITTYPE;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        FilterPageBuilder: FilterPageBuilder;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CustomerEntryView':
                begin
                    FilterPageBuilder.AddRecord(CustLedgerEntry.TableCaption, CustLedgerEntry);
                    if POSParameterValue.Value <> '' then begin
                        CustLedgerEntry.SetView(POSParameterValue.Value);
                        FilterPageBuilder.SetView(CustLedgerEntry.TableCaption, CustLedgerEntry.GetView(false));
                    end;
                    if FilterPageBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterPageBuilder.GetView(CustLedgerEntry.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'CustomerEntryView':
                begin
                    if POSParameterValue.Value <> '' then
                        CustLedgerEntry.SetView(POSParameterValue.Value);
                end;
        end;
    end;
}

