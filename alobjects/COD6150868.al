codeunit 6150868 "POS Action - Layaway Create"
{
    // NPR5.50/MMV /20181105 CASE 300557 Created object


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Create layaway of sales order via prepayment invoices.';
        TextDownpaymentPctTitle: Label 'Down payment';
        TextDownpaymentPctLead: Label 'Please specify a down payment % to be paid';
        ErrorNoInstalments: Label 'Cannot create layaway with zero instalments';
        ErrorNoSaleLines: Label 'Cannot create layaway with no sales lines';
        ErrorDownpayment: Label 'Downpayment invoice was posted correctly but balancing line could not be automatically created:\ %1';
        ErrorLayaway: Label 'Order was created but layaway invoices could not automatically be posted:\ %1';
        CaptionPromptDownpayment: Label 'Prompt Downpayment';
        CaptionDownpayPct: Label 'Downpayment Percent';
        CaptionCreationFeeItem: Label 'Creation Fee';
        CaptionReserveItems: Label 'Reserve Items';
        CaptionInstalments: Label 'Instalments';
        CaptionOrderPaymentTerms: Label 'Order Payment Terms';
        CaptionPrepaymentPayTerms: Label 'Prepayment Payment Terms';
        DescPromptDownpayment: Label 'Prompt for downpayment percent before creation';
        DescDownpayPct: Label 'Fixed downpayment percent. Is prefilled in dialog if used together';
        DescCreationFeeItem: Label 'Service item to insert as fee upon creation of layaway';
        DescReserveItems: Label 'Reserve items in created sales order. Errors if not possible';
        DescInstalments: Label 'Number of instalments for layaway payment. Set to 1 if no fixed periods';
        DescOrderPaymentTerms: Label 'Payment Terms to use for the created order. Is used for filtering';
        DescPrepayPaymentTerms: Label 'Payment Terms to use for each prepayment invoice. Is used for due date calculation and filtering';

    local procedure ActionCode(): Text
    begin
        exit('LAYAWAY_CREATE');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
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
              Sender."Subscriber Instances Allowed"::Multiple) then begin
                RegisterWorkflowStep('DownpaymentPrompt', 'param.PromptDownpayment && numpad(labels.DownpaymentPctTitle, labels.DownpaymentPctLead, param.DownpaymentPercent).cancel (abort);');
                RegisterWorkflowStep('CreateLayaway', 'respond();');
                RegisterWorkflow(false);

                RegisterBooleanParameter('PromptDownpayment', false);
                RegisterDecimalParameter('DownpaymentPercent', 0);
                RegisterTextParameter('CreationFeeItemNo', '');
                RegisterBooleanParameter('ReserveItems', true);
                RegisterIntegerParameter('Instalments', 0);
                RegisterTextParameter('OrderPaymentTerms', '');
                RegisterTextParameter('PrepaymentPaymentTerms', '');
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'DownpaymentPctTitle', TextDownpaymentPctTitle);
        Captions.AddActionCaption(ActionCode, 'DownpaymentPctLead', TextDownpaymentPctLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        DownpaymentPct: Decimal;
        CreationFeeItemNo: Text;
        ReserveItems: Boolean;
        Instalments: Integer;
        OrderPaymentTerms: Text;
        PrepaymentPaymentTerms: Text;
        SalesHeader: Record "Sales Header";
        DownpaymentInvoiceNo: Text;
        POSSaleLine: Codeunit "POS Sale Line";
        PaymentTerms: Record "Payment Terms";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        Success: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        POSSession.RequestRefreshData();

        JSON.InitializeJObjectParser(Context, FrontEnd);
        DownpaymentPct := GetDownpaymentPct(JSON);
        CreationFeeItemNo := JSON.GetStringParameter('CreationFeeItemNo', true);
        ReserveItems := JSON.GetBooleanParameter('ReserveItems', true);
        Instalments := JSON.GetIntegerParameter('Instalments', true);
        OrderPaymentTerms := JSON.GetStringParameter('OrderPaymentTerms', true);
        PrepaymentPaymentTerms := JSON.GetStringParameter('PrepaymentPaymentTerms', true);

        if Instalments < 1 then
            Error(ErrorNoInstalments);

        POSSession.GetSaleLine(POSSaleLine);
        if POSSaleLine.IsEmpty() then
            Error(ErrorNoSaleLines);

        PaymentTerms.Get(PrepaymentPaymentTerms);
        PaymentTerms.TestField("Due Date Calculation");

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not SelectCustomer(SalePOS) then
            SalePOS.TestField("Customer No.");
        POSSale.RefreshCurrent();

        InsertCreationFeeItem(POSSession, CreationFeeItemNo);
        ExportToOrderAndEndSale(SalesHeader, POSSession, ReserveItems, OrderPaymentTerms);

        Commit;
        asserterror
        begin
            DownpaymentInvoiceNo := CreateAndPostDownpaymentInvoice(SalesHeader, DownpaymentPct, PrepaymentPaymentTerms);
            CreateAndPostLayawayInvoices(SalesHeader, Instalments, PrepaymentPaymentTerms, DownpaymentPct);

            Commit;
            Success := true;
            Error('');
        end;
        if not Success then
            Message(ErrorLayaway, GetLastErrorText);

        StartNewSale(POSSession, DownpaymentInvoiceNo);

        POSSession.RequestRefreshData();
    end;

    local procedure InsertCreationFeeItem(var POSSession: Codeunit "POS Session"; CreationFeeItemNo: Text)
    var
        Item: Record Item;
        POSSaleLine: Codeunit "POS Sale Line";
        SaleLinePOS: Record "Sale Line POS";
    begin
        if CreationFeeItemNo = '' then
            exit;

        Item.Get(CreationFeeItemNo);
        Item.TestField(Type, Item.Type::Service);

        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetNewSaleLine(SaleLinePOS);
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS.Validate("No.", CreationFeeItemNo);
        SaleLinePOS.Validate(Quantity, 1);
        POSSaleLine.InsertLineRaw(SaleLinePOS, false);
    end;

    local procedure ExportToOrderAndEndSale(var SalesHeaderOut: Record "Sales Header"; POSSession: Codeunit "POS Session"; ReserveItems: Boolean; OrderPaymentTerms: Text)
    var
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        POSSale: Codeunit "POS Sale";
        POSSaleLine: Codeunit "POS Sale Line";
        SalePOS: Record "Sale POS";
        SaleLinePOS: Record "Sale Line POS";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);
        SalePOS.Validate("Payment Terms Code", OrderPaymentTerms);
        SalePOS.Modify(true);
        POSSale.RefreshCurrent();
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        RetailSalesDocMgt.SetDocumentTypeOrder();
        RetailSalesDocMgt.SetTransferSalesPerson(true);
        RetailSalesDocMgt.SetTransferPostingsetup(true);
        RetailSalesDocMgt.SetTransferDimensions(true);
        RetailSalesDocMgt.SetTransferPaymentMethod(true);
        RetailSalesDocMgt.SetTransferTaxSetup(true);
        RetailSalesDocMgt.SetAutoReserveSalesLine(ReserveItems);
        RetailSalesDocMgt.SetAsk(false);
        RetailSalesDocMgt.SetPrint(false);
        RetailSalesDocMgt.SetInvoice(false);
        RetailSalesDocMgt.SetReceive(false);
        RetailSalesDocMgt.SetShip(false);
        RetailSalesDocMgt.SetSendPostedPdf2Nav(false);
        RetailSalesDocMgt.SetRetailPrint(true);
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(false);
        RetailSalesDocMgt.SetWriteInAuditRoll(true);

        // TODO: CTRLUPGRADE - Invokes function that involves Event Marshaller
        Error('CTRLUPGRADE');
        /*
        RetailSalesDocMgt.ProcessPOSSale(SalePOS);
        */
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeaderOut);
    end;

    local procedure CreateAndPostDownpaymentInvoice(var SalesHeader: Record "Sales Header"; DownpaymentPct: Decimal; PrepaymentPaymentTerms: Text): Text
    var
        SalesLine: Record "Sales Line";
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
    begin
        SalesHeader.Validate("Prepayment %", 0);
        SalesHeader.Validate("Prepmt. Payment Terms Code", PrepaymentPaymentTerms);
        SalesHeader.Validate("Prepayment Due Date", WorkDate);
        SalesHeader.Modify(true);

        if DownpaymentPct <= 0 then
            exit('');

        SalesLine.SetRange("Document Type", SalesHeader."Document Type");
        SalesLine.SetRange("Document No.", SalesHeader."No.");
        SalesLine.SetRange(Type, SalesLine.Type::Item);
        SalesLine.SetFilter("No.", '<>%1', '');

        if not SalesLine.FindSet(true) then
            exit('');

        repeat
            SalesLine.Validate("Prepayment %", DownpaymentPct);
            SalesLine.Modify(true);
        until SalesLine.Next = 0;

        SalesPostPrepayments.Invoice(SalesHeader);
        SalesHeader.Validate(Status, SalesHeader.Status::Open);
        SalesHeader.Modify(true);
        exit(SalesHeader."Last Prepayment No.");
    end;

    local procedure CreateAndPostLayawayInvoices(var SalesHeader: Record "Sales Header"; Instalments: Integer; PrepaymentPaymentTerms: Text; DownpaymentPct: Decimal)
    var
        InstalmentPct: Decimal;
        SalesLine: Record "Sales Line";
        i: Integer;
        PaymentTerms: Record "Payment Terms";
    begin
        //Split the remaining amount out over X prepayment invoices ie. calculate the percentage.
        //Set the remaining amount on the last instalment so any rounding diff is put onto this one.
        SalesHeader.Validate("Prepmt. Payment Terms Code", PrepaymentPaymentTerms);
        SalesHeader.Modify(true);

        InstalmentPct := (100 - DownpaymentPct) / Instalments;
        PaymentTerms.Get(PrepaymentPaymentTerms);

        for i := 1 to Instalments do begin
            if i > 1 then begin
                SalesHeader.Validate("Prepayment Due Date", CalcDate(PaymentTerms."Due Date Calculation", SalesHeader."Prepayment Due Date"));
                SalesHeader.Modify(true);
            end;
            AppendPrepaymentPctAndPostPrepaymentInvoice(SalesHeader, InstalmentPct, (i = Instalments));
        end;
    end;

    local procedure StartNewSale(POSSession: Codeunit "POS Session"; DownpaymentInvoiceNo: Text)
    var
        POSSale: Codeunit "POS Sale";
    begin
        POSSession.GetSale(POSSale);

        if DownpaymentInvoiceNo <> '' then begin
            //End sale, auto start new sale and insert downpayment line.
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            HandleDownpayment(POSSession, DownpaymentInvoiceNo);
        end else
            //End sale
            POSSale.SelectViewForEndOfSale(POSSession)
    end;

    local procedure HandleDownpayment(var POSSession: Codeunit "POS Session"; DownpaymentInvoiceNo: Text)
    var
        POSApplyCustomerEntries: Codeunit "POS Apply Customer Entries";
        Success: Boolean;
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        Commit;
        asserterror
        begin
            POSApplyCustomerEntries.BalanceDocument(POSSession, CustLedgerEntry."Document Type"::Invoice, DownpaymentInvoiceNo, true);
            Commit;
            Success := true;
            Error('');
        end;

        if not Success then
            Message(ErrorDownpayment, GetLastErrorText);
    end;

    local procedure AppendPrepaymentPctAndPostPrepaymentInvoice(SalesHeader: Record "Sales Header"; PrepaymentPct: Decimal; FullPrepayment: Boolean): Text
    var
        SalesPostPrepayments: Codeunit "Sales-Post Prepayments";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        SalesLine: Record "Sales Line";
    begin
        if FullPrepayment then begin
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            SalesLine.SetRange(Type, SalesLine.Type::Item);
            SalesLine.SetFilter("No.", '<>%1', '');
            if SalesLine.FindSet(true) then
                repeat
                    SalesLine.Validate("Prepayment %", 100);
                    SalesLine.Modify(true);
                until SalesLine.Next = 0;
        end else
            RetailSalesDocMgt.ApplyPrepaymentPercentageToAllLines(SalesHeader, PrepaymentPct, true);

        SalesPostPrepayments.Invoice(SalesHeader);

        if not FullPrepayment then begin
            SalesHeader.Validate(Status, SalesHeader.Status::Open);
            SalesHeader.Modify(true);
        end;

        exit(SalesHeader."Last Prepayment No.");
    end;

    local procedure SelectCustomer(var SalePOS: Record "Sale POS"): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            Customer.Get(SalePOS."Customer No.");
            Customer.TestField("Application Method", Customer."Application Method"::Manual);
            exit(true);
        end;

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Customer.Get(SalePOS."Customer No.");
        Customer.TestField("Application Method", Customer."Application Method"::Manual);
        Commit;
        exit(true);
    end;

    local procedure GetDownpaymentPct(var JSON: Codeunit "POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanParameter('PromptDownpayment', true) then
            exit(GetNumpad(JSON, 'DownpaymentPrompt'))
        else
            exit(JSON.GetDecimalParameter('DownpaymentPercent', true));
    end;

    local procedure GetNumpad(JSON: Codeunit "POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit(0);

        exit(JSON.GetDecimal('numpad', true));
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'PromptDownpayment':
                Caption := CaptionPromptDownpayment;
            'DownpaymentPercent':
                Caption := CaptionDownpayPct;
            'CreationFeeItemNo':
                Caption := CaptionCreationFeeItem;
            'ReserveItems':
                Caption := CaptionReserveItems;
            'Instalments':
                Caption := CaptionInstalments;
            'OrderPaymentTerms':
                Caption := CaptionOrderPaymentTerms;
            'PrepaymentPaymentTerms':
                Caption := CaptionPrepaymentPayTerms;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'PromptDownpayment':
                Caption := DescPromptDownpayment;
            'DownpaymentPercent':
                Caption := DescDownpayPct;
            'CreationFeeItemNo':
                Caption := DescCreationFeeItem;
            'ReserveItems':
                Caption := DescReserveItems;
            'Instalments':
                Caption := DescInstalments;
            'OrderPaymentTerms':
                Caption := DescOrderPaymentTerms;
            'PrepaymentPaymentTerms':
                Caption := DescPrepayPaymentTerms;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "POS Parameter Value"; Handled: Boolean)
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'CreationFeeItemNo':
                begin
                    Item.SetRange(Type, Item.Type::Service);
                    if PAGE.RunModal(0, Item) = ACTION::LookupOK then
                        POSParameterValue.Value := Item."No.";
                end;
            'OrderPaymentTerms':
                begin
                    if PAGE.RunModal(0, PaymentTerms) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentTerms.Code;
                end;
            'PrepaymentPaymentTerms':
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
            'CreationFeeItemNo':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Item.Get(POSParameterValue.Value);
                    Item.TestField(Type, Item.Type::Service);
                end;
            'OrderPaymentTerms':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
            'PrepaymentPaymentTerms':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    PaymentTerms.Get(POSParameterValue.Value);
                end;
        end;
    end;
}

