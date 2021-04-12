codeunit 6150870 "NPR POS Action: Layaway Cancel"
{
    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Cancel a layaway. Fees can be posted and paid prepayment invoices will be refunded.';
        LAYAWAY_CANCEL_LINE: Label 'Layaway of %1 %2 cancelled.';
        ERR_APPLICATION: Label 'Layaway prepayments were credited and sales order %1 was deleted successfully but an error occurred while applying customer entries and calculating amount to refund:\%2';
        ERR_DOCUMENT_POSTED_LINE: Label '%1 %2 has partially posted lines. Aborting action.';
        ERR_UNPOSTED_POS_ENTRY: Label '%1 %2, %3 %4 is related to %5 %6 but has not yet been posted.\All related entries must be posted before layaway cancellation.';
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
        exit('LAYAWAY_CANCEL');
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
                RegisterWorkflowStep('CancelLayaway', 'respond();');
                RegisterWorkflow(false);

                RegisterTextParameter('CancellationFeeItemNo', '');
                RegisterTextParameter('OrderPaymentTermsFilter', '');
                RegisterBooleanParameter('SkipFeeInvoice', false); //Can be used to cancel a layaway that was created by accident, where no fees should be invoiced.
                RegisterBooleanParameter('SelectCustomer', true);
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        SalesHeader: Record "Sales Header";
        ServiceSalesInvoice: Record "Sales Invoice Header";
        JSON: Codeunit "NPR POS JSON Management";
        POSLayawayMgt: Codeunit "NPR POS Layaway Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        CancellationFeeItemNo: Text;
        CreditMemoNo: Text;
        OrderPaymentTermsFilter: Text;
        ServiceInvoiceNo: Text;
        CancellationAmount: Decimal;
        RefundAmount: Decimal;
        ServiceFeeAmount: Decimal;
        SelectCustomer: Boolean;
        SkipFeeInvoice: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        CancellationFeeItemNo := JSON.GetStringParameterOrFail('CancellationFeeItemNo', ActionCode());
        OrderPaymentTermsFilter := JSON.GetStringParameterOrFail('OrderPaymentTermsFilter', ActionCode());
        SkipFeeInvoice := JSON.GetBooleanParameterOrFail('SkipFeeInvoice', ActionCode());
        SelectCustomer := JSON.GetBooleanParameterOrFail('SelectCustomer', ActionCode());

        if not CheckCustomer(POSSession, SelectCustomer) then
            exit;

        if not SelectOrder(POSSession, SalesHeader, OrderPaymentTermsFilter) then
            exit;

        CheckForUnpostedLinkedPOSEntries(SalesHeader);

        POSSession.GetSaleLine(POSSaleLine);

        CreditMemoNo := CreditPrepayments(SalesHeader);
        InsertCancellationFeeItem(SalesHeader, CancellationFeeItemNo, SkipFeeInvoice);
        ServiceInvoiceNo := PostServiceInvoice(SalesHeader, SkipFeeInvoice); //COMMITS
        DeleteOrder(SalesHeader);
        InsertCommentLine(POSSaleLine, StrSubstNo(LAYAWAY_CANCEL_LINE, SalesHeader."Document Type", SalesHeader."No."));
        Commit;

        ClearLastError();
        Clear(POSLayawayMgt);
        POSLayawayMgt.SetRunApplyPrepmtCreditMemoAndRefund(POSSession, CreditMemoNo, ServiceInvoiceNo);
        if not POSLayawayMgt.Run(SalesHeader) then
            Error(ERR_APPLICATION, SalesHeader."No.", GetLastErrorText);

        POSSession.RequestRefreshData();
    end;

    local procedure CheckCustomer(POSSession: Codeunit "NPR POS Session"; SelectCustomer: Boolean): Boolean
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

    local procedure SelectOrder(POSSession: Codeunit "NPR POS Session"; var SalesHeader: Record "Sales Header"; OrderPaymentTermsFilter: Text): Boolean
    var
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        SalePOS: Record "NPR POS Sale";
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
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
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

    local procedure InsertCancellationFeeItem(var SalesHeader: Record "Sales Header"; CancellationFeeItemNo: Text; Skip: Boolean)
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

    local procedure PostServiceInvoice(var SalesHeader: Record "Sales Header"; Skip: Boolean): Text
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
        if SalesLine.FindSet(true) then
            repeat
                if Item.Get(SalesLine."No.") and (Item.Type = Item.Type::Service) then begin
                    SalesLine.Validate("Qty. to Invoice", SalesLine.Quantity);
                    SalesLine.Validate("Qty. to Ship", SalesLine.Quantity);
                end else begin
                    SalesLine.Validate("Qty. to Invoice", 0);
                    SalesLine.Validate("Qty. to Ship", 0);
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

    local procedure DeleteOrder(var SalesHeader: Record "Sales Header")
    begin
        SalesHeader.Delete(true);
    end;

    local procedure InsertCommentLine(POSSaleLine: Codeunit "NPR POS Sale Line"; Description: Text)
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
        SaleLinePOS.Type := SaleLinePOS.Type::Comment;
        SaleLinePOS.Description := Description;
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure CheckForUnpostedLinkedPOSEntries(SalesHeader: Record "Sales Header")
    var
        POSEntrySalesDocLink: Record "NPR POS Entry Sales Doc. Link";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        POSEntry: Record "NPR POS Entry";
    begin
        SalesInvoiceHeader.SetRange("Prepayment Order No.", SalesHeader."No.");
        if SalesInvoiceHeader.FindSet then
            repeat
                POSEntrySalesDocLink.SetRange("Sales Document Type", POSEntrySalesDocLink."Sales Document Type"::POSTED_INVOICE);
                POSEntrySalesDocLink.SetRange("Sales Document No", SalesInvoiceHeader."No.");
                if POSEntrySalesDocLink.FindSet then
                    repeat
                        POSEntry.Get(POSEntrySalesDocLink."POS Entry No.");
                        if POSEntry."Post Entry Status" <> POSEntry."Post Entry Status"::Posted then begin
                            Error(ERR_UNPOSTED_POS_ENTRY,
                              POSEntry.TableCaption,
                              POSEntry."Entry No.",
                              POSEntry.FieldCaption("Document No."),
                              POSEntry."Document No.",
                              SalesHeader."Document Type"::Invoice,
                              SalesInvoiceHeader."No.");
                        end;
                    until POSEntrySalesDocLink.Next = 0;
            until SalesInvoiceHeader.Next = 0;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'CancellationFeeItemNo':
                Caption := CaptionCancellationFee;
            'OrderPaymentTermsFilter':
                Caption := CaptionOrderPayTermsFilter;
            'SkipFeeInvoice':
                Caption := CaptionSkipFeeInvoice;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'CancellationFeeItemNo':
                Caption := DescCancellationFee;
            'OrderPaymentTermsFilter':
                Caption := DescOrderPayTermsFilter;
            'SkipFeeInvoice':
                Caption := DescSkipFeeInvoice;
            'SelectCustomer':
                Caption := DescSelectCustomer;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'CancellationFeeItemNo':
                begin
                    Item.SetRange(Type, Item.Type::Service);
                    if PAGE.RunModal(0, Item) = ACTION::LookupOK then
                        POSParameterValue.Value := Item."No.";
                end;
            'OrderPaymentTermsFilter':
                begin
                    if PAGE.RunModal(0, PaymentTerms) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'CancellationFeeItemNo':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Item.Get(POSParameterValue.Value);
                    Item.TestField(Type, Item.Type::Service);
                end;
            'OrderPaymentTermsFilter':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;
}