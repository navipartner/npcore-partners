codeunit 6150870 "POS Action - Layaway Cancel"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object
    // NPR5.50/MMV /20190613 CASE 300557 Changed application invocation.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Cancel a layaway. Fees can be posted and paid prepayment invoices will be refunded.';
        LAYAWAY_CANCEL_REFUND: Label 'Layaway order credited and deleted.\Refund line has been created for total paid amount minus fees.';
        LAYAWAY_CANCEL: Label 'Layaway order credited and deleted';
        LAYAWAY_REFUND: Label 'Layaway Refund';
        LAYAWAY_CANCEL_LINE: Label 'Layaway of %1 %2 cancelled.';
        ERR_APPLICATION: Label 'Layaway prepayments were credited and sales order %1 was deleted successfully but an error occurred while applying customer entries and calculating amount to refund:\%2';
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';
        CaptionSelectCustomer: Label 'Select Customer';
        CaptionCancellationFee: Label 'Cancellation Fee';
        CaptionSkipFeeInvoice: Label 'Skip Fee Invoice';
        CaptionOrderPayTermsFilter: Label 'Order Payment Term';
        DescSelectCustomer: Label 'Prompt for customer selection if none on sale';
        DescCancellationFee: Label 'Service item to enter in order as cancellation fee';
        DescSkipFeeInvoice: Label 'Skip invoicing of all service items. Can be used to cancel layaways created by mistake, bypassing all fees.';
        DescOrderPayTermsFilter: Label 'Payment Terms to use for filtering layaway orders.';

    local procedure ActionCode(): Text
    begin
        exit ('LAYAWAY_CANCEL');
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
            RegisterWorkflowStep('CancelLayaway','respond();');
            RegisterWorkflow(false);

            RegisterTextParameter('CancellationFeeItemNo', '');
            RegisterTextParameter('OrderPaymentTermsFilter', '');
            RegisterBooleanParameter('SkipFeeInvoice', false); //Can be used to cancel a layaway that was created by accident, where no fees should be invoiced.
            RegisterBooleanParameter('SelectCustomer', true);
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        CancellationFeeItemNo: Text;
        CancellationAmount: Decimal;
        SalesHeader: Record "Sales Header";
        RefundAmount: Decimal;
        ServiceFeeAmount: Decimal;
        OrderPaymentTermsFilter: Text;
        SkipFeeInvoice: Boolean;
        SelectCustomer: Boolean;
        ServiceSalesInvoice: Record "Sales Invoice Header";
        ServiceInvoiceNo: Text;
        CreditMemoNo: Text;
        POSRefundAmount: Decimal;
        Success: Boolean;
        POSSaleLine: Codeunit "POS Sale Line";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        CancellationFeeItemNo := JSON.GetStringParameter('CancellationFeeItemNo', true);
        OrderPaymentTermsFilter := JSON.GetStringParameter('OrderPaymentTermsFilter', true);
        SkipFeeInvoice := JSON.GetBooleanParameter('SkipFeeInvoice', true);
        SelectCustomer := JSON.GetBooleanParameter('SelectCustomer', true);

        if not CheckCustomer(POSSession, SelectCustomer) then
          exit;

        if not SelectOrder(POSSession, SalesHeader, OrderPaymentTermsFilter) then
          exit;

        POSSession.GetSaleLine(POSSaleLine);

        CreditMemoNo := CreditPrepayments(SalesHeader);
        InsertCancellationFeeItem(SalesHeader, CancellationFeeItemNo, SkipFeeInvoice);
        ServiceInvoiceNo := PostServiceInvoice(SalesHeader, SkipFeeInvoice); //COMMITS
        DeleteOrder(SalesHeader);
        InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_CANCEL_LINE, SalesHeader."Document Type", SalesHeader."No."));
        Commit;

        asserterror begin
          ApplyPrepaymentCreditMemoToOpenPrepaymentInvoices(CreditMemoNo, SalesHeader); //COMMITS
          ApplyPrepaymentCreditMemoToServiceInvoice(CreditMemoNo, ServiceInvoiceNo); //COMMITS
          POSRefundAmount := CreatePOSRefundForRemainingCreditMemoAmount(POSSession, CreditMemoNo);

          Commit;
          Success := true;
          Error('');
        end;

        if not Success then
          Error(ERR_APPLICATION, SalesHeader."No.", GetLastErrorText);

        if POSRefundAmount <> 0 then
          Message(LAYAWAY_CANCEL_REFUND)
        else
          Message(LAYAWAY_CANCEL);

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

    local procedure CreditPrepayments(var SalesHeader: Record "Sales Header"): Text
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
    begin
        if RetailSalesDocImpMgt.DocumentIsPartiallyPosted(SalesHeader) then
          Error(ERR_DOCUMENT_POSTED_LINE);

        SalesPostPrepayments.CreditMemo(SalesHeader);

        CustLedgerEntry.SetAutoCalcFields(Amount, "Remaining Amount");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        CustLedgerEntry.SetRange("Document No.", SalesHeader."Last Prepmt. Cr. Memo No.");
        CustLedgerEntry.FindFirst;
        //If customer application method is set to apply to oldest, we error here before anything is committed as we won't be able to apply the credit memo correctly and trust the final refund amount.
        CustLedgerEntry.TestField(Open);
        CustLedgerEntry.TestField(Amount, CustLedgerEntry."Remaining Amount");

        exit(SalesHeader."Last Prepmt. Cr. Memo No.");
    end;

    local procedure InsertCancellationFeeItem(var SalesHeader: Record "Sales Header";CancellationFeeItemNo: Text;Skip: Boolean)
    var
        Item: Record Item;
        SalesLine: Record "Sales Line";
    begin
        if (CancellationFeeItemNo = '') or Skip then
          exit;

        Item.Get(CancellationFeeItemNo);
        Item.TestField(Type, Item.Type::Service);

        SalesHeader.Status := SalesHeader.Status::Open;
        SalesHeader.Modify(true);

        SalesLine."Document No." := SalesHeader."No.";
        SalesLine."Document Type" := SalesHeader."Document Type";
        SalesLine.Type := SalesLine.Type::Item;
        SalesLine.Validate("No.", CancellationFeeItemNo);
        SalesLine.Validate(Quantity, 1);
        SalesLine.Insert(true);
    end;

    local procedure PostServiceInvoice(var SalesHeader: Record "Sales Header";Skip: Boolean): Text
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
        SalesPost: Codeunit "Sales-Post";
    begin
        if Skip then
          exit('');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetFilter("No.", '<>%1', '');
        if SalesLine.FindSet(true) then repeat
          if Item.Get(SalesLine."No.") and (Item.Type = Item.Type::Service) then begin
            SalesLine.Validate("Qty. to Invoice",SalesLine.Quantity);
            SalesLine.Validate("Qty. to Ship",SalesLine.Quantity);
          end else begin
            SalesLine.Validate("Qty. to Invoice",0);
            SalesLine.Validate("Qty. to Ship",0);
          end;
          SalesLine.Modify(true);
        until SalesLine.Next = 0;

        SalesHeader.Invoice := true;
        SalesHeader.Ship := true;
        SalesHeader.Status := SalesHeader.Status::Released;
        SalesHeader.Modify(true);

        SalesPost.Run(SalesHeader);

        if SalesHeader."Last Posting No." = '' then
          exit(SalesHeader."No.");
        exit(SalesHeader."Last Posting No.");
    end;

    local procedure ApplyPrepaymentCreditMemoToOpenPrepaymentInvoices(CreditMemoNo: Text;var SalesHeader: Record "Sales Header")
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        InvoiceFilterString: Text;
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CreditMemoCustLedgerEntry: Record "Cust. Ledger Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        if not SalesCrMemoHeader.Get(CreditMemoNo) then
          exit;

        CreditMemoCustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CreditMemoCustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CreditMemoCustLedgerEntry.SetRange("Document Type", CreditMemoCustLedgerEntry."Document Type"::"Credit Memo");
        CreditMemoCustLedgerEntry.SetRange("Document No.", CreditMemoNo);
        CreditMemoCustLedgerEntry.FindFirst;
        CreditMemoCustLedgerEntry.TestField(Open);

        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        if not SalesInvoiceHeader.FindSet then
          exit;

        repeat
          if InvoiceFilterString <> '' then
            InvoiceFilterString += '|';
          InvoiceFilterString += '''' + SalesInvoiceHeader."No." + '''';
        until SalesInvoiceHeader.Next = 0;

        CustLedgerEntry.SetRange("Applies-to ID", UserId);
        if not CustLedgerEntry.IsEmpty then
          CustLedgerEntry.ModifyAll("Applies-to ID", '', true);
        CustLedgerEntry.Reset;

        CustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CustLedgerEntry.SetRange("Customer No.", SalesHeader."Bill-to Customer No.");
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.SetRange(Positive, true);
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetFilter("Document No.", InvoiceFilterString);

        ApplyCustomerEntry(CreditMemoCustLedgerEntry, CustLedgerEntry);
    end;

    local procedure ApplyPrepaymentCreditMemoToServiceInvoice(CreditMemoNo: Text;ServiceInvoiceNo: Text)
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CreditMemoCustLedgerEntry: Record "Cust. Ledger Entry";
        InvoiceCustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        if not SalesCrMemoHeader.Get(CreditMemoNo) then
          exit;
        if not SalesInvoiceHeader.Get(ServiceInvoiceNo) then
          exit;

        CreditMemoCustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        CreditMemoCustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CreditMemoCustLedgerEntry.SetRange("Document Type", CreditMemoCustLedgerEntry."Document Type"::"Credit Memo");
        CreditMemoCustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CreditMemoCustLedgerEntry.FindFirst;
        if not CreditMemoCustLedgerEntry.Open then
          exit;
        if CreditMemoCustLedgerEntry."Remaining Amount" = 0 then
          exit;

        InvoiceCustLedgerEntry.SetAutoCalcFields("Remaining Amount");
        InvoiceCustLedgerEntry.SetRange("Customer No.", SalesInvoiceHeader."Bill-to Customer No.");
        InvoiceCustLedgerEntry.SetRange("Document Type", InvoiceCustLedgerEntry."Document Type"::Invoice);
        InvoiceCustLedgerEntry.SetRange("Document No.", SalesInvoiceHeader."No.");
        InvoiceCustLedgerEntry.FindFirst;
        if not InvoiceCustLedgerEntry.Open then
          exit;
        if InvoiceCustLedgerEntry."Remaining Amount" = 0 then
          exit;

        CustLedgerEntry.SetRange("Applies-to ID", UserId);
        if not CustLedgerEntry.IsEmpty then
          CustLedgerEntry.ModifyAll("Applies-to ID", '', true);

        ApplyCustomerEntry(CreditMemoCustLedgerEntry, InvoiceCustLedgerEntry);
    end;

    local procedure CreatePOSRefundForRemainingCreditMemoAmount(var POSSession: Codeunit "POS Session";CreditMemoNo: Text): Decimal
    var
        CreditMemoCustLedgerEntry: Record "Cust. Ledger Entry";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
    begin
        if not SalesCrMemoHeader.Get(CreditMemoNo) then
          exit(0);

        CreditMemoCustLedgerEntry.SetAutoCalcFields("Remaining Amt. (LCY)");
        CreditMemoCustLedgerEntry.SetRange("Customer No.", SalesCrMemoHeader."Bill-to Customer No.");
        CreditMemoCustLedgerEntry.SetRange("Document Type", CreditMemoCustLedgerEntry."Document Type"::"Credit Memo");
        CreditMemoCustLedgerEntry.SetRange("Document No.", SalesCrMemoHeader."No.");
        CreditMemoCustLedgerEntry.FindFirst;
        if CreditMemoCustLedgerEntry."Remaining Amt. (LCY)" = 0 then
          exit(0);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Deposit;
        SaleLinePOS.Type := SaleLinePOS.Type::Customer;
        SaleLinePOS.Validate("No.", CreditMemoCustLedgerEntry."Customer No.");
        SaleLinePOS.Validate("Unit Price", CreditMemoCustLedgerEntry."Remaining Amt. (LCY)");
        SaleLinePOS.Validate(Quantity, 1);
        SaleLinePOS."Buffer Document Type" := SaleLinePOS."Buffer Document Type"::Kreditnota;
        SaleLinePOS."Buffer Document No." := SalesCrMemoHeader."No.";
        SaleLinePOS.Description := LAYAWAY_REFUND;
        SaleLinePOS.UpdateAmounts(SaleLinePOS);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);

        exit(CreditMemoCustLedgerEntry."Remaining Amt. (LCY)");
    end;

    local procedure DeleteOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Delete(true);
    end;

    local procedure ApplyCustomerEntry(var ApplyingCustLedgerEntry: Record "Cust. Ledger Entry";var ApplyToCustLedgerEntries: Record "Cust. Ledger Entry")
    var
        CustEntryApplyPostedEntries: Codeunit "CustEntry-Apply Posted Entries";
    begin
        if not ApplyToCustLedgerEntries.FindSet(true) then
          exit;
        repeat
          ApplyToCustLedgerEntries.Validate("Applies-to ID", UserId);
          ApplyToCustLedgerEntries.Validate("Amount to Apply", ApplyToCustLedgerEntries."Remaining Amount");
          ApplyToCustLedgerEntries.Modify(true);
        until ApplyToCustLedgerEntries.Next = 0;

        ApplyingCustLedgerEntry.Validate("Applying Entry", true);
        ApplyingCustLedgerEntry.Validate("Applies-to ID", UserId);
        ApplyingCustLedgerEntry.Validate("Amount to Apply", ApplyingCustLedgerEntry."Remaining Amount");
        CODEUNIT.Run(CODEUNIT::"Cust. Entry-Edit",ApplyingCustLedgerEntry);
        Commit;

        //-#300557 [300557]
        //CustEntryApplyPostedEntries.Apply(ApplyingCustLedgerEntry, '', 0D);
        CODEUNIT.Run(CODEUNIT::"CustEntry-Apply Posted Entries", ApplyingCustLedgerEntry);
        //+#300557 [300557]
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
          'CancellationFeeItemNo' : Caption := CaptionCancellationFee;
          'OrderPaymentTermsFilter' : Caption := CaptionOrderPayTermsFilter;
          'SkipFeeInvoice' : Caption := CaptionSkipFeeInvoice;
          'SelectCustomer' : Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'CancellationFeeItemNo' : Caption := DescCancellationFee;
          'OrderPaymentTermsFilter' : Caption := DescOrderPayTermsFilter;
          'SkipFeeInvoice' : Caption := DescSkipFeeInvoice;
          'SelectCustomer' : Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of

          'CancellationFeeItemNo' :
            begin
              Item.SetRange(Type, Item.Type::Service);
              if PAGE.RunModal(0, Item) = ACTION::LookupOK then
                POSParameterValue.Value := Item."No.";
            end;
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
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'CancellationFeeItemNo' :
            begin
              if POSParameterValue.Value = '' then
                exit;
              Item.Get(POSParameterValue.Value);
              Item.TestField(Type, Item.Type::Service);
            end;
          'OrderPaymentTermsFilter' :
            begin
              if POSParameterValue.Value = '' then
                exit;
              PaymentTerms.Get(POSParameterValue.Value);
            end;
        end;
    end;
}

