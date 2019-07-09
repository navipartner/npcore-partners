codeunit 6150869 "POS Action - Layaway Pay"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Pay a layaway prepayment invoice';
        LAYAWAY_REMAINING: Label 'Layaway Remaining Total: %1';
        LAYAWAY_NEXT_DATE: Label 'Layaway Next Due Date: %1';
        LAYAWAY_NEXT_AMOUNT: Label 'Layaway Next Amount: %1';
        LAYAWAY_COMPLETED: Label 'Layaway Fully Paid';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionOrderPayTermsFilter: Label 'Payment Terms Filter';
        CaptionSelectionMethod: Label 'Selection Method';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescOrderPayTermsFilter: Label 'Filter on payment terms for open sales orders.';
        DescSelectionMethod: Label 'Select next prepayment invoice to pay based on due date or manually select from list';
        OptionSelectionMethod: Label 'Next Due,List';

    local procedure ActionCode(): Text
    begin
        exit ('LAYAWAY_PAY');
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
            RegisterWorkflowStep('PayLayawayInvoice','respond();');
            RegisterWorkflow(false);

            RegisterTextParameter('OrderPaymentTermsFilter', '');
            RegisterOptionParameter('SelectionMethod', 'NextDue,List', 'NextDue');
            RegisterBooleanParameter('SelectCustomer', true);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        OrderPaymentTermsFilter: Text;
        SelectionMethod: Integer;
        SelectCustomer: Boolean;
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSApplyCustomerEntries: Codeunit "POS Apply Customer Entries";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        OrderPaymentTermsFilter := JSON.GetStringParameter('OrderPaymentTermsFilter', true);
        SelectionMethod := JSON.GetIntegerParameter('SelectionMethod', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectOrder(POSSession, SalesHeader, OrderPaymentTermsFilter) then
          exit;

        if not SelectPrepaymentInvoice(SalesHeader, SalesInvoiceHeader, SelectionMethod) then
          exit;

        POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, SalesInvoiceHeader."No.", true);
        InsertCompletionLine(POSSession, SalesHeader, SalesInvoiceHeader);
        CreateLayawayComments(POSSession, SalesHeader, SelectionMethod, SalesInvoiceHeader);

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "POS Session";SelectCustomer: Boolean): Boolean
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

        if not SelectCustomer then
          exit(true);

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
          exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        Commit;
        exit(true);
    end;

    local procedure SelectOrder(POSSession: Codeunit "POS Session";var SalesHeader: Record "Sales Header";OrderPaymentTermsFilter: Text): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);

        SalesHeader.SetRange("Payment Terms Code", OrderPaymentTermsFilter);
        if SalePOS."Customer No." <> '' then
          SalesHeader.SetRange("Bill-to Customer No.", SalePOS."Customer No.");
        SalesHeader.SetRange("Document Type", SalesHeader."Document Type"::Order);
        exit(RetailSalesDocImpMgt.SelectSalesDocument(SalesHeader.GetView(false), SalesHeader));
    end;

    local procedure SelectPrepaymentInvoice(SalesHeader: Record "Sales Header";var SalesInvoiceHeader: Record "Sales Invoice Header";SelectionMethod: Integer): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        InvoiceFilterString: Text;
    begin
        if SelectionMethod = 0 then begin
          GetNextDuePrepayment(SalesHeader, SalesInvoiceHeader, 0D, true);
          exit(true);
        end else begin
          SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
          SalesInvoiceHeader.FindSet;
          exit(PAGE.RunModal(PAGE::"POS Prepayment Invoices", SalesInvoiceHeader) = ACTION::LookupOK);
        end;
    end;

    local procedure CreateLayawayComments(var POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";SelectionMethod: Integer;SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        POSSaleLine: Codeunit "POS Sale Line";
        NextInvoice: Record "Sales Invoice Header";
    begin
        if SelectionMethod > 0 then
          exit;

        POSSession.GetSaleLine(POSSaleLine);

        if GetNextDuePrepayment(SalesHeader, NextInvoice, SalesInvoiceHeader."Due Date", false) then begin
          InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_NEXT_DATE, Format(NextInvoice."Due Date")));
          InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_NEXT_AMOUNT, Format(NextInvoice."Amount Including VAT"),0,'<Standard Format,0>'));
          InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_REMAINING, Format(GetTotalRemainingLayawayAmount(SalesHeader, SalesInvoiceHeader."Due Date"),0,'<Standard Format,0>')));
        end else
          InsertCommentLine(POSSaleLine, LAYAWAY_COMPLETED);
    end;

    local procedure InsertCompletionLine(var POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";SalesInvoiceHeader: Record "Sales Invoice Header")
    var
        POSSaleLine: Codeunit "POS Sale Line";
        NextInvoice: Record "Sales Invoice Header";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        if GetNextDuePrepayment(SalesHeader, NextInvoice, SalesInvoiceHeader."Due Date", false) then
          exit;

        RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, false, true);
    end;

    local procedure GetTotalRemainingLayawayAmount(SalesHeader: Record "Sales Header";DueLaterThan: Date): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceFilterString: Text;
        Amount: Decimal;
    begin
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindSet;
        repeat
          if InvoiceFilterString <> '' then
            InvoiceFilterString += '|';
          InvoiceFilterString += '''' + SalesInvoiceHeader."No." + '''';
        until SalesInvoiceHeader.Next = 0;

        CustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetFilter("Document No.", InvoiceFilterString);
        if DueLaterThan <> 0D then
          CustLedgerEntry.SetFilter("Due Date", '>%1', DueLaterThan);

        if CustLedgerEntry.FindSet then repeat
          Amount += CustLedgerEntry."Remaining Amt. (LCY)";
        until CustLedgerEntry.Next = 0;

        exit(Amount);
    end;

    local procedure GetNextDuePrepayment(SalesHeader: Record "Sales Header";var SalesInvoiceHeaderOut: Record "Sales Invoice Header";DueLaterThan: Date;WithError: Boolean): Boolean
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceFilterString: Text;
    begin
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        SalesInvoiceHeader.FindSet;
        repeat
          if InvoiceFilterString <> '' then
            InvoiceFilterString += '|';
          InvoiceFilterString += '''' + SalesInvoiceHeader."No." + '''';
        until SalesInvoiceHeader.Next = 0;

        CustLedgerEntry.SetCurrentKey("Customer No.",Open,Positive,"Due Date","Currency Code");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetFilter("Document No.", InvoiceFilterString);
        if DueLaterThan <> 0D then
          CustLedgerEntry.SetFilter("Due Date", '>%1', DueLaterThan);
        if WithError then
          CustLedgerEntry.FindFirst
        else begin
          if not CustLedgerEntry.FindFirst then
            exit(false);
        end;

        SalesInvoiceHeaderOut.SetAutoCalcFields("Amount Including VAT");
        exit(SalesInvoiceHeaderOut.Get(CustLedgerEntry."Document No."));
    end;

    local procedure InsertCommentLine(POSSaleLine: Codeunit "POS Sale Line";Description: Text)
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS.Description := Description;
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'OrderPaymentTermsFilter' : Caption := CaptionOrderPayTermsFilter;
          'SelectionMethod' : Caption := CaptionSelectionMethod;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'OrderPaymentTermsFilter' : Caption := DescOrderPayTermsFilter;
          'SelectionMethod' : Caption := DescSelectionMethod;
          'SelectCustomer' : Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SelectionMethod' : Caption := OptionSelectionMethod;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'OrderPaymentTermsFilter' :
            begin
              if PAGE.RunModal(0, PaymentTerms) = ACTION::LookupOK then
                POSParameterValue.Value := PaymentTerms.Code;
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "POS Parameter Value")
    var
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'OrderPaymentTermsFilter' :
            begin
              if POSParameterValue.Value <> '' then
                PaymentTerms.Get(POSParameterValue.Value);
            end;
        end;
    end;
}

