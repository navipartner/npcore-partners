codeunit 6150868 "NPR POS Action: Layaway Create"
{
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
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('LAYAWAY_CREATE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
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
            Sender.RegisterWorkflowStep('DownpaymentPrompt', 'param.PromptDownpayment && numpad(labels.DownpaymentPctTitle, labels.DownpaymentPctLead, param.DownpaymentPercent).cancel (abort);');
            Sender.RegisterWorkflowStep('CreateLayaway', 'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('PromptDownpayment', false);
            Sender.RegisterDecimalParameter('DownpaymentPercent', 0);
            Sender.RegisterTextParameter('CreationFeeItemNo', '');
            Sender.RegisterBooleanParameter('ReserveItems', true);
            Sender.RegisterIntegerParameter('Instalments', 0);
            Sender.RegisterTextParameter('OrderPaymentTerms', '');
            Sender.RegisterTextParameter('PrepaymentPaymentTerms', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'DownpaymentPctTitle', TextDownpaymentPctTitle);
        Captions.AddActionCaption(ActionCode(), 'DownpaymentPctLead', TextDownpaymentPctLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        PaymentTerms: Record "Payment Terms";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        JSON: Codeunit "NPR POS JSON Management";
        POSLayawayMgt: Codeunit "NPR POS Layaway Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        DownpaymentPct: Decimal;
        Instalments: Integer;
        CreationFeeItemNo: Text;
        DownpaymentInvoiceNo: Text;
        OrderPaymentTerms: Text;
        PrepaymentPaymentTerms: Text;
        ReserveItems: Boolean;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        POSSession.RequestRefreshData();

        JSON.InitializeJObjectParser(Context, FrontEnd);
        DownpaymentPct := GetDownpaymentPct(JSON);
        CreationFeeItemNo := JSON.GetStringParameterOrFail('CreationFeeItemNo', ActionCode());
        ReserveItems := JSON.GetBooleanParameterOrFail('ReserveItems', ActionCode());
        Instalments := JSON.GetIntegerParameterOrFail('Instalments', ActionCode());
        OrderPaymentTerms := JSON.GetStringParameterOrFail('OrderPaymentTerms', ActionCode());
        PrepaymentPaymentTerms := JSON.GetStringParameterOrFail('PrepaymentPaymentTerms', ActionCode());

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
        if not SalePOS."Prices Including VAT" then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
        end;
        POSSale.RefreshCurrent();

        InsertCreationFeeItem(POSSession, CreationFeeItemNo);
        ExportToOrderAndEndSale(SalesHeader, POSSession, ReserveItems, OrderPaymentTerms);

        Commit();
        ClearLastError();
        Clear(POSLayawayMgt);
        POSLayawayMgt.SetRunCreateAndPostDownpmtAndLayawayInvoices(DownpaymentPct, PrepaymentPaymentTerms, Instalments);
        if POSLayawayMgt.Run(SalesHeader) then begin
            DownpaymentInvoiceNo := POSLayawayMgt.GetDownpaymentInvoiceNo();
            Commit();
        end else
            Message(ErrorLayaway, GetLastErrorText);

        StartNewSale(POSSession, DownpaymentInvoiceNo);

        POSSession.RequestRefreshData();
    end;

    local procedure InsertCreationFeeItem(var POSSession: Codeunit "NPR POS Session"; CreationFeeItemNo: Text)
    var
        Item: Record Item;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePOS: Record "NPR POS Sale Line";
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

    local procedure ExportToOrderAndEndSale(var SalesHeaderOut: Record "Sales Header"; POSSession: Codeunit "NPR POS Session"; ReserveItems: Boolean; OrderPaymentTerms: Text)
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
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
        RetailSalesDocMgt.ProcessPOSSale(SalePOS);
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeaderOut);
    end;

    local procedure StartNewSale(POSSession: Codeunit "NPR POS Session"; DownpaymentInvoiceNo: Text)
    var
        POSSale: Codeunit "NPR POS Sale";
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

    local procedure HandleDownpayment(var POSSession: Codeunit "NPR POS Session"; DownpaymentInvoiceNo: Text)
    var
        DummySalesHdr: Record "Sales Header";
        POSLayawayMgt: Codeunit "NPR POS Layaway Mgt.";
    begin
        Commit();
        ClearLastError();
        Clear(POSLayawayMgt);
        POSLayawayMgt.SetRunHandleDownpayment(POSSession, DownpaymentInvoiceNo);
        if not POSLayawayMgt.Run(DummySalesHdr) then
            Message(ErrorDownpayment, GetLastErrorText);
    end;

    local procedure SelectCustomer(var SalePOS: Record "NPR POS Sale"): Boolean
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
        Commit();
        exit(true);
    end;

    local procedure GetDownpaymentPct(var JSON: Codeunit "NPR POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanParameterOrFail('PromptDownpayment', ActionCode()) then
            exit(GetNumpad(JSON, 'DownpaymentPrompt'))
        else
            exit(JSON.GetDecimalParameterOrFail('DownpaymentPercent', ActionCode()));
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupParameter(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateParameter(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Item: Record Item;
        PaymentTerms: Record "Payment Terms";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
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
