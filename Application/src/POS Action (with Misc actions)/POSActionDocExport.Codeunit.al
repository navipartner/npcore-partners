codeunit 6150859 "NPR POS Action: Doc. Export"
{
    var
        ActionDescription: Label 'Export current sale to a standard NAV sales document';
        ERRNOSALELINES: Label 'There are no sale lines to export';
        ERR_PREPAY: Label 'Sale was exported correctly but prepayment in new sale failed: %1';
        ERR_PAY: Label 'Sale was exported correctly but payment in new sale failed: %1';
        ERR_CUSTOMER_NOT_IN_FILTER: Label 'The customer with Customer No. %1 is not within the filter defined in the POS Action parameters', Comment = '%1 = Customer No.';
        PAYMENT_OPTION: Label 'No Payment,Prepayment Percent,Prepayment Amount,Pay & Post';
        PAYMENT_OPTION_SPLIT: Label 'No Payment,Prepayment Percent,Prepayment Amount,Split Pay & Post,Full Pay & Post';
        PAYMENT_OPTION_DESC: Label 'Select document payment';
        TextExtDocNoLabel: Label 'Enter External Document No.';
        TextAttentionLabel: Label 'Enter Attention';
        TextYourRefLabel: Label 'Enter a value for the field ''Your Reference''';
        TextConfirmTitle: Label 'Confirm action';
        TextConfirmLead: Label 'Export active sale to NAV sales document?';
        TextPrepaymentTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid after export';
        TextPrepaymentAmountLead: Label 'Please specify prepayment amount to be paid after export';
        CaptionAskExtDocNo: Label 'Prompt External Doc. No.';
        CaptionAskAttention: Label 'Prompt Attention';
        CaptionAskYourRef: Label 'Prompt Your Reference';
        CaptionConfirm: Label 'Confirm Export';
        CaptionAskOperation: Label 'Ask Doc. Operation';
        CaptionPrint: Label 'Standard Print';
        CaptionInvoice: Label 'Invoice';
        CaptionReceive: Label 'Receive';
        CaptionShip: Label 'Ship';
        CaptionDocType: Label 'Document Type';
        CaptionNegDocType: Label 'Negative Document Type';
        CaptionCreationMsg: Label 'Show Creation Message';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment';
        CaptionFixedPrepaymentValue: Label 'Fixed Prepayment Value';
        CaptionTransferSalesperson: Label 'Transfer Salesperson';
        CaptionTransferPostingSetup: Label 'Transfer Posting Setup';
        CaptionTransferDim: Label 'Transfer Dimensions';
        CaptionTransferPaymentMethod: Label 'Transfer Payment Method';
        CaptionTransferTaxSetup: Label 'Transfer Tax Setup';
        CaptionAutoResrvSalesLine: Label 'Auto Reserve Sales Line';
        CaptionSendPdf2Nav: Label 'Send PDF2NAV';
        CaptionRetailPrint: Label 'Retail Confirmation Print';
        CaptionOpenDoc: Label 'Open Document';
        CaptionCheckCustCredit: Label 'Check Customer Credit';

        DescAskExtDocNo: Label 'Ask user to input external document number';
        DescAskAttention: Label 'Ask user to input attention';
        DescAskYourRef: Label 'Ask user to input ''Your Reference''';
        DescConfirm: Label 'Ask user to confirm before any export is performed';
        DescAskOperation: Label 'Ask user to select posting type';
        DescPrint: Label 'Print standard NAV report after export & posting is done';
        DescInvoice: Label 'Invoice exported document';
        DescReceive: Label 'Receive exported document';
        DescShip: Label 'Ship exported sales document';
        DescDocType: Label 'Sales Document to create on positive sales balance';
        DescNegDocType: Label 'Sales Document to create on negative sales balance';
        DescCreationMsg: Label 'Show message confirming sales document created';
        DescPrepaymentDlg: Label 'Ask user for prepayment percentage. Will be paid in new sale.';
        DescFixedPrepaymentPct: Label 'Prepayment percentage to use either silently or as dialog default value.';
        DescTransferSalesperson: Label 'Transfer salesperson from sale to exported document';
        DescTransferPostingSetup: Label 'Transfer posting setup from sale to exported document';
        DescTransferDim: Label 'Transfer dimensions from sale to exported document';
        DescTransferPaymentMethod: Label 'Transfer payment method from sale to exported document';
        DescTransferTaxSetup: Label 'Transfer tax setup from sale to exported document';
        DescAutoResrvSalesLine: Label 'Automatically reserve items on exported document';
        DescSendPdf2Nav: Label 'Handle document output via PDF2NAV';
        DescRetailPrint: Label 'Print receipt confirming exported document';
        DescOpenDoc: Label 'Open sales document page after export is done';
        DescCheckCustCredit: Label 'Check the customer credit before export is done';
        OptionDocTypePozitive: Label 'Order,Invoice,Quote,Restrict';
        OptionDocTypeNegative: Label 'Return Order,Credit Memo,Restrict';
        CaptionPrintPrepaymentDoc: Label 'Print Prepayment Document';
        DescPrintPrepaymentDoc: Label 'Print standard prepayment document after posting.';
        CaptionPayAndPostNext: Label 'Pay&Post Immediately';
        CaptionPrintPayAndPost: Label 'Pay&Post Print';
        DescPayAndPostNext: Label 'Insert a full payment line for the exported document in the next sale.';
        DescPrintPayAndPost: Label 'Print the document of the Pay&Post operation in next sale.';
        DescSaveLinesOnPOSEntry: Label 'Save exported sale lines on POS Entry';
        CaptionSaveLinesOnPOSEntry: Label 'Save POS Entry Lines';
        WrongNegativeSignErr: Label 'Amount must be positive for: %1';
        WrongPozitiveSignErr: Label 'Amount must be negative for: %1';
        CaptionForcePricesInclVAT: Label 'Force Prices Including VAT';
        DescForcePricesInclVAT: Label 'Force Prices Including VAT on exported document';
        CaptionPrepayIsAmount: Label 'Prepayment Amount Input';
        DescPrepayIsAmount: Label 'Input prepayment amount instead of percent in prompt';
        CaptionSetSend: Label 'Send Document';
        DescSetSend: Label 'Output NAV report after export & posting, via document sending profiles';
        CaptionSendPrepayDoc: Label 'Send Prepayment Document';
        DescSendPrepayDoc: Label 'Output prepayment NAV report via document sending profiles, after payment in new sale';
        CaptionPdf2NavPrepayDoc: Label 'Prepayment PDF2NAV';
        DescPdf2NavPrepayDoc: Label 'Output prepayment NAV report via PDF2NAV, after payment in new sale';
        CaptionSendPayAndPost: Label 'Pay&Post Send Document';
        DescSendPayAndPost: Label 'Output NAV report via document sending profiles, after payment in new sale';
        CaptionPdf2NavPayAndPost: Label 'Pay&Post PDF2NAV';
        DescPdf2NavPayAndPost: Label 'Output NAV report via PDF2NAV, after payment in new sale';
        CaptionSelectCustomer: Label 'Select Customer';
        DescSelectCustomer: Label 'Force selection of customer if missing from sale.';
        CaptionBlockEmptySale: Label 'Block Empty Sale';
        DescBlockEmptySale: Label 'Block creation of document if sale is empty';
        CaptionDocPaymentMenu: Label 'Show Payment Menu';
        DescDocPaymentMenu: Label 'Prompt with different payment methods for handling in new sale, after export is done.';
        CaptionUseLocationFrom: Label 'Use Location From';
        DescUseLocationFrom: Label 'Select source to get location code from for sales document';
        OptionUseLocationFrom: Label '<Undefined>,POS Store,POS Sale Header,Specific Location';
        CaptionUseSpecLocationCode: Label 'Use Specific Location Code';
        DescUseSpecLocationCode: Label 'Select location code to be used for sales document, if parameter ''%1'' is set to ''%2''', Comment = 'Select location code to be used for sales document, if parameter ''Use Location From'' is set to ''Specific Location''';
        LocationSourceMustBeSpecified: Label 'POS Action''s parameter ''%1'' cannot be set to ''%2'' value', Comment = 'POS Action''s parameter ''Use Location From'' cannot be set to ''<Undefined>'' value';
        SpecLocationCodeMustBeSpecified: Label 'POS Action''s parameter ''%1'' is set to ''%2''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''%3'')', Comment = 'POS Action''s parameter ''Use Location From'' is set to ''Specific Location''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''Use Specific Location Code'')';
        CaptionSendICOrderConfirmation: Label 'Send IC Order Cnfmn.';
        DescSendICOrderConfirmation: Label 'Send intercompany order confirmation immediately after sales document has been created. ';
        ReadingErr: Label 'reading in %1 of %2';
        CaptionPaymentMethodCode: Label 'Payment Method Code';
        DescPaymentMethodCode: Label 'Select Payment Method Code to be used for sales document';
        CaptionCustomerTableView: Label 'Customer Table View';
        CaptionCustomerLookupPage: Label 'Customer Lookup Page';
        DescCustomerTableView: Label 'Pre-filtered customer list';
        DescCustomerLookupPage: Label 'Custom customer lookup page';
        CaptionEnforceCustomerFilter: Label 'Enforce Customer Filter';
        DescEnforceCustomerFilter: Label 'Enforce that the selected customer is within the defined filter in "CustomerTableView"';

    local procedure ActionCode(): Code[20]
    begin
        exit('SALES_DOC_EXP');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.14');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('confirm', 'param.ConfirmExport && confirm(labels.confirmTitle, labels.confirmLead).no (abort);');
            Sender.RegisterWorkflowStep('extdocno', 'param.AskExtDocNo && input (labels.ExtDocNo).cancel (abort);');
            Sender.RegisterWorkflowStep('attention', 'param.AskAttention && input (labels.Attention).cancel (abort);');
            Sender.RegisterWorkflowStep('yourref', 'param.AskYourRef && input (labels.YourRef).cancel (abort);');

            Sender.RegisterWorkflowStep('exportDocument', 'respond();');

            Sender.RegisterWorkflowStep('endSaleAndDocumentPayment',
                'if (context.prompt_prepayment) {' +
                    'context.prepayment_is_amount && numpad(labels.prepaymentDialogTitle, labels.prepaymentAmountLead, param.FixedPrepaymentValue);' +
                    '!context.prepayment_is_amount && numpad(labels.prepaymentDialogTitle, labels.prepaymentPctLead, param.FixedPrepaymentValue);' +
                '}' +
                'respond();');
            Sender.RegisterWorkflow(false);

            Sender.RegisterBooleanParameter('SetAsk', false);
            Sender.RegisterBooleanParameter('SetPrint', false);
            Sender.RegisterBooleanParameter('SetInvoice', false);
            Sender.RegisterBooleanParameter('SetReceive', false);
            Sender.RegisterBooleanParameter('SetShip', false);
            Sender.RegisterOptionParameter('SetDocumentType', 'Order,Invoice,Quote,Restrict', 'Order');
            Sender.RegisterOptionParameter('SetNegBalDocumentType', 'ReturnOrder,CreditMemo,Restrict', 'ReturnOrder');
            Sender.RegisterBooleanParameter('SetShowCreationMessage', false);
            Sender.RegisterBooleanParameter('SetTransferPostingSetup', true);
            Sender.RegisterBooleanParameter('SetAutoReserveSalesLine', false);
            Sender.RegisterBooleanParameter('SetSendPdf2Nav', false);
            Sender.RegisterBooleanParameter('AskExtDocNo', false);
            Sender.RegisterBooleanParameter('AskAttention', false);
            Sender.RegisterBooleanParameter('AskYourRef', false);
            Sender.RegisterBooleanParameter('SetTransferSalesperson', true);
            Sender.RegisterBooleanParameter('SetTransferDimensions', true);
            Sender.RegisterBooleanParameter('SetTransferTaxSetup', true);
            Sender.RegisterBooleanParameter('ConfirmExport', true);
            Sender.RegisterBooleanParameter('PrepaymentDialog', false);
            Sender.RegisterDecimalParameter('FixedPrepaymentValue', 0);
            Sender.RegisterBooleanParameter('PrintPrepaymentDocument', false);
            Sender.RegisterBooleanParameter('PrintRetailConfirmation', true);
            Sender.RegisterBooleanParameter('CheckCustomerCredit', true);
            Sender.RegisterBooleanParameter('OpenDocumentAfterExport', false);
            Sender.RegisterBooleanParameter('PayAndPostInNextSale', false);
            Sender.RegisterBooleanParameter('PrintPayAndPostDocument', false);
            Sender.RegisterBooleanParameter('ForcePricesInclVAT', false);
            Sender.RegisterBooleanParameter('PrepaymentInputIsAmount', false);
            Sender.RegisterBooleanParameter('SetSend', false);
            Sender.RegisterBooleanParameter('SendPrepaymentDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavPrepaymentDocument', false);
            Sender.RegisterBooleanParameter('SendPayAndPostDocument', false);
            Sender.RegisterBooleanParameter('Pdf2NavPayAndPostDocument', false);
            Sender.RegisterBooleanParameter('SelectCustomer', true);
            Sender.RegisterBooleanParameter('ShowDocumentPaymentMenu', false);
            Sender.RegisterBooleanParameter('BlockEmptySale', true);
            Sender.RegisterOptionParameter('UseLocationFrom', '<Undefined>,POS Store,POS Sale,SpecificLocation', 'POS Store');
            Sender.RegisterTextParameter('UseSpecLocationCode', '');
            Sender.RegisterBooleanParameter('SendICOrderConfirmation', false);
            Sender.RegisterTextParameter('PaymentMethodCode', '');
            Sender.RegisterTextParameter('CustomerTableView', '');
            Sender.RegisterIntegerParameter('CustomerLookupPage', 0);
            Sender.RegisterBooleanParameter('EnforceCustomerFilter', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'ExtDocNo', TextExtDocNoLabel);
        Captions.AddActionCaption(ActionCode(), 'Attention', TextAttentionLabel);
        Captions.AddActionCaption(ActionCode(), 'YourRef', TextYourRefLabel);
        Captions.AddActionCaption(ActionCode(), 'confirmTitle', TextConfirmTitle);
        Captions.AddActionCaption(ActionCode(), 'confirmLead', TextConfirmLead);
        Captions.AddActionCaption(ActionCode(), 'prepaymentDialogTitle', TextPrepaymentTitle);
        Captions.AddActionCaption(ActionCode(), 'prepaymentPctLead', TextPrepaymentPctLead);
        Captions.AddActionCaption(ActionCode(), 'prepaymentAmountLead', TextPrepaymentAmountLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        case WorkflowStep of
            'exportDocument':
                ExportToDocument(Context, POSSession, FrontEnd);
            'endSaleAndDocumentPayment':
                DocumentPayment(Context, POSSession, FrontEnd);
        end;
    end;

    local procedure ExportToDocument(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SalePOS: Record "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        CustomerTableView: Text;
        CustomerLookupPage: Integer;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.ClearActionState();
        POSSession.BeginAction(ActionCode());
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);

        SalePOS.FindFirst();

        if (JSON.GetBooleanParameter('SelectCustomer')) then begin
            CustomerTableView := JSON.GetStringParameterOrFail('CustomerTableView', ActionCode());
            CustomerLookupPage := JSON.GetIntegerParameterOrFail('CustomerLookupPage', ActionCode());

            if not SelectCustomer(SalePOS, POSSale, CustomerTableView, CustomerLookupPage) then
                SalePOS.TestField("Customer No.");
        end;
        SetReference(SalePOS, JSON);
        SetPricesInclVAT(SalePOS, JSON);
        SetParameters(POSSaleLine, JSON, RetailSalesDocMgt);
        ValidateSale(SalePOS, RetailSalesDocMgt, JSON);

        RetailSalesDocMgt.ProcessPOSSale(SalePOS);

        Commit();

        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        POSSession.StoreActionState('CreatedSalesHeader', SalesHeader);
        SetPaymentParameters(JSON, FrontEnd, SalesHeader);
    end;

    local procedure DocumentPayment(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        PayAndPost: Boolean;
        PayAndPostPrint: Boolean;
        PrepaymentIsAmount: Boolean;
        PrepaymentSend: Boolean;
        PrepaymentPdf2Nav: Boolean;
        PayAndPostPdf2Nav: Boolean;
        PayAndPostSend: Boolean;
        PrepaymentValue: Decimal;
        PrintPrepayment: Boolean;
        FullPosting: Boolean;
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "NPR POS Sale";
        RecRef: RecordRef;
    begin
        POSSession.GetSale(POSSale);
        POSSession.RetrieveActionStateRecordRef('CreatedSalesHeader', RecRef);
        RecRef.SetTable(SalesHeader);

        JSON.InitializeJObjectParser(Context, FrontEnd);

        PrepaymentValue := GetPrepaymentValue(JSON);
        JSON.SetScopeRoot();

        PrepaymentIsAmount := JSON.GetBooleanOrFail('prepayment_is_amount', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        PayAndPost := JSON.GetBooleanOrFail('pay_and_post', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        FullPosting := JSON.GetBooleanOrFail('full_posting', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));

        PrepaymentPdf2Nav := JSON.GetBooleanParameterOrFail('Pdf2NavPrepaymentDocument', ActionCode());
        PrepaymentSend := JSON.GetBooleanParameterOrFail('SendPrepaymentDocument', ActionCode());
        PayAndPostPdf2Nav := JSON.GetBooleanParameterOrFail('Pdf2NavPayAndPostDocument', ActionCode());
        PayAndPostSend := JSON.GetBooleanParameterOrFail('SendPayAndPostDocument', ActionCode());
        PrintPrepayment := JSON.GetBooleanParameterOrFail('PrintPrepaymentDocument', ActionCode());
        PayAndPostPrint := JSON.GetBooleanParameterOrFail('PrintPayAndPostDocument', ActionCode());
        if PrepaymentValue > 0 then begin
            //End sale, auto start new sale, and insert prepayment line.
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            HandlePrepayment(POSSession, SalesHeader, PrepaymentValue, PrepaymentIsAmount, PrintPrepayment, PrepaymentSend, PrepaymentPdf2Nav);
        end else
            if PayAndPost then begin
                //End sale, auto start new sale, and insert payment line.
                POSSession.StartTransaction();
                POSSession.ChangeViewSale();
                HandlePayAndPost(POSSession, SalesHeader, PayAndPostPrint, PayAndPostPdf2Nav, PayAndPostSend, FullPosting);
            end else begin
                //End sale
                POSSale.SelectViewForEndOfSale(POSSession);
            end;
    end;

    local procedure SetPaymentParameters(JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; SalesHeader: Record "Sales Header")
    var
        Choice: Integer;
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
    begin
        if SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin //If document has been posted/deleted, we cannot pay parts of it.
            if JSON.GetBooleanParameterOrFail('ShowDocumentPaymentMenu', ActionCode()) then begin
                if RetailSalesDocImpMgt.DocumentIsSetToFullPosting(SalesHeader) then
                    Choice := StrMenu(PAYMENT_OPTION, 1, PAYMENT_OPTION_DESC)
                else
                    Choice := StrMenu(PAYMENT_OPTION_SPLIT, 1, PAYMENT_OPTION_DESC);

                case Choice of
                    0,  //Cancelled
                    1: //None
                        begin
                            JSON.SetContext('prompt_prepayment', false);
                            JSON.SetContext('prepayment_is_amount', false);
                            JSON.SetContext('pay_and_post', false);
                            JSON.SetContext('full_posting', false);
                        end;
                    2: //Prepayment Percent
                        begin
                            JSON.SetContext('prompt_prepayment', true);
                            JSON.SetContext('prepayment_is_amount', false);
                            JSON.SetContext('pay_and_post', false);
                            JSON.SetContext('full_posting', false);
                        end;
                    3: //Prepayment Amount
                        begin
                            JSON.SetContext('prompt_prepayment', true);
                            JSON.SetContext('prepayment_is_amount', true);
                            JSON.SetContext('pay_and_post', false);
                            JSON.SetContext('full_posting', false);
                        end;
                    4: //Payment + post
                        begin
                            JSON.SetContext('prompt_prepayment', false);
                            JSON.SetContext('prepayment_is_amount', false);
                            JSON.SetContext('pay_and_post', true);
                            JSON.SetContext('full_posting', false);
                        end;
                    5: //Full payment + post
                        begin
                            JSON.SetContext('prompt_prepayment', false);
                            JSON.SetContext('prepayment_is_amount', false);
                            JSON.SetContext('pay_and_post', true);
                            JSON.SetContext('full_posting', true);
                        end;
                end;
            end else begin
                JSON.SetContext('pay_and_post', JSON.GetBooleanParameterOrFail('PayAndPostInNextSale', ActionCode()));
                JSON.SetContext('prompt_prepayment', JSON.GetBooleanParameterOrFail('PrepaymentDialog', ActionCode()));
                JSON.SetContext('prepayment_is_amount', JSON.GetBooleanParameterOrFail('PrepaymentInputIsAmount', ActionCode()));
                JSON.SetContext('full_posting', false);
            end;
        end else begin
            JSON.SetContext('prompt_prepayment', false);
            JSON.SetContext('prepayment_is_amount', false);
            JSON.SetContext('pay_and_post', false);
            JSON.SetContext('full_posting', false);
        end;

        FrontEnd.SetActionContext(ActionCode(), JSON);
    end;

    local procedure ValidateSale(var SalePOS: Record "NPR POS Sale"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; JSON: Codeunit "NPR POS JSON Management")
    var
        CustomerTableView: Text;
        Customer: Record Customer;
    begin
        if JSON.GetBooleanParameterOrFail('BlockEmptySale', ActionCode()) then begin
            if not SaleLinesExists(SalePOS) then
                Error(ERRNOSALELINES);
        end;

        CustomerTableView := JSON.GetStringParameterOrFail('CustomerTableView', ActionCode());
        if CustomerTableView <> '' then begin
            if JSON.GetBooleanParameterOrFail('EnforceCustomerFilter', ActionCode()) then begin
                Customer.SetView(CustomerTableView);
                Customer.FilterGroup(40);
                Customer.SetRange("No.", SalePOS."Customer No.");
                if Customer.IsEmpty then
                    Error(ERR_CUSTOMER_NOT_IN_FILTER, SalePOS."Customer No.");
            end;
        end;

        RetailSalesDocMgt.TestSalePOS(SalePOS);
    end;

    local procedure SelectCustomer(var SalePOS: Record "NPR POS Sale"; POSSale: Codeunit "NPR POS Sale"; CustomerTableView: Text; CustomerLookupPage: Integer): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            exit(true);
        end;

        if CustomerTableView <> '' then
            Customer.SetView(CustomerTableView);

        if PAGE.RunModal(CustomerLookupPage, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Commit();
        POSSale.RefreshCurrent();
        exit(true);
    end;

    local procedure SetParameters(var POSSaleLine: Codeunit "NPR POS Sale Line"; var JSON: Codeunit "NPR POS JSON Management"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict;
        DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict;
        LocationSource: Option Undefined,"POS Store","POS Sale",SpecificLocation;
        SpecificLocationCode: Code[10];
        PaymentMethodCode: Code[10];
    begin
        RetailSalesDocMgt.SetAsk(JSON.GetBooleanParameterOrFail('SetAsk', ActionCode()));
        RetailSalesDocMgt.SetPrint(JSON.GetBooleanParameterOrFail('SetPrint', ActionCode()));
        RetailSalesDocMgt.SetInvoice(JSON.GetBooleanParameterOrFail('SetInvoice', ActionCode()));
        RetailSalesDocMgt.SetReceive(JSON.GetBooleanParameterOrFail('SetReceive', ActionCode()));
        RetailSalesDocMgt.SetShip(JSON.GetBooleanParameterOrFail('SetShip', ActionCode()));
        RetailSalesDocMgt.SetSendPostedPdf2Nav(JSON.GetBooleanParameterOrFail('SetSendPdf2Nav', ActionCode()));
        RetailSalesDocMgt.SetRetailPrint(JSON.GetBooleanParameterOrFail('PrintRetailConfirmation', ActionCode()));
        RetailSalesDocMgt.SetAutoReserveSalesLine(JSON.GetBooleanParameterOrFail('SetAutoReserveSalesLine', ActionCode()));
        RetailSalesDocMgt.SetTransferSalesPerson(JSON.GetBooleanParameterOrFail('SetTransferSalesperson', ActionCode()));
        RetailSalesDocMgt.SetTransferPostingsetup(JSON.GetBooleanParameterOrFail('SetTransferPostingSetup', ActionCode()));
        RetailSalesDocMgt.SetTransferDimensions(JSON.GetBooleanParameterOrFail('SetTransferDimensions', ActionCode()));
        RetailSalesDocMgt.SetTransferTaxSetup(JSON.GetBooleanParameterOrFail('SetTransferTaxSetup', ActionCode()));
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(JSON.GetBooleanParameterOrFail('OpenDocumentAfterExport', ActionCode()));
        RetailSalesDocMgt.SetSendDocument(JSON.GetBooleanParameterOrFail('SetSend', ActionCode()));
        RetailSalesDocMgt.SetSendICOrderConf(JSON.GetBooleanParameter('SendICOrderConfirmation'));
        RetailSalesDocMgt.SetCustomerCreditCheck(JSON.GetBooleanParameter('CheckCustomerCredit'));

        if JSON.GetBooleanParameterOrFail('SetShowCreationMessage', ActionCode()) then
            RetailSalesDocMgt.SetShowCreationMessage();

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);

        DocumentTypePozitive := JSON.GetIntegerParameterOrFail('SetDocumentType', ActionCode());
        DocumentTypeNegative := JSON.GetIntegerParameterOrFail('SetNegBalDocumentType', ActionCode());
        SetDocumentType(AmountInclVAT, RetailSalesDocMgt, DocumentTypePozitive, DocumentTypeNegative);

        LocationSource := JSON.GetIntegerParameterOrFail('UseLocationFrom', ActionCode());
        SpecificLocationCode := COPYSTR(JSON.GetStringParameter('UseSpecLocationCode'), 1, MaxStrLen(SpecificLocationCode));
        SetLocationSource(RetailSalesDocMgt, LocationSource, SpecificLocationCode);

        PaymentMethodCode := COPYSTR(JSON.GetStringParameter('PaymentMethodCode'), 1, MaxStrLen(PaymentMethodCode));
        RetailSalesDocMgt.SetPaymentMethod(PaymentMethodCode);
    end;

    procedure SetDocumentType(AmountInclVAT: Decimal; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict; DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict)
    begin
        if AmountInclVAT >= 0 then
            case DocumentTypePozitive of
                DocumentTypePozitive::Order:
                    RetailSalesDocMgt.SetDocumentTypeOrder();
                DocumentTypePozitive::Invoice:
                    RetailSalesDocMgt.SetDocumentTypeInvoice();
                DocumentTypePozitive::Quote:
                    RetailSalesDocMgt.SetDocumentTypeQuote();
                DocumentTypePozitive::Restrict:
                    Error(WrongPozitiveSignErr, SelectStr(DocumentTypeNegative + 1, OptionDocTypeNegative));
            end
        else
            case DocumentTypeNegative of
                DocumentTypeNegative::CreditMemo:
                    RetailSalesDocMgt.SetDocumentTypeCreditMemo();
                DocumentTypeNegative::ReturnOrder:
                    RetailSalesDocMgt.SetDocumentTypeReturnOrder();
                DocumentTypeNegative::Restrict:
                    Error(WrongNegativeSignErr, SelectStr(DocumentTypePozitive + 1, OptionDocTypePozitive));
            end;
    end;

    procedure SetLocationSource(var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; LocationSource: Option Undefined,"POS Store","POS Sale",SpecificLocation; SpecificLocationCode: Code[10])
    begin
        if LocationSource = LocationSource::Undefined then
            Error(LocationSourceMustBeSpecified, CaptionUseLocationFrom, SelectStr(LocationSource + 1, OptionUseLocationFrom));

        if (LocationSource = LocationSource::SpecificLocation) and (SpecificLocationCode = '') then
            Error(SpecLocationCodeMustBeSpecified, CaptionUseLocationFrom, SelectStr(LocationSource + 1, OptionUseLocationFrom), CaptionUseSpecLocationCode);

        RetailSalesDocMgt.SetLocationSource(LocationSource, SpecificLocationCode);
    end;

    local procedure GetPrepaymentValue(var JSON: Codeunit "NPR POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanOrFail('prompt_prepayment', StrSubstNo(ReadingErr, 'GetPrepaymentValue', ActionCode())) then begin
            exit(GetNumpad(JSON, 'endSaleAndDocumentPayment'));
        end else begin
            exit(JSON.GetDecimalParameterOrFail('FixedPrepaymentValue', ActionCode()));
        end;
    end;

    local procedure HandlePrepayment(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; PrepaymentValue: Decimal; PrepaymentIsAmount: Boolean; Print: Boolean; Send: Boolean; Pdf2Nav: Boolean)
    var
        HandlePayment: Codeunit "NPR POS Doc. Export Try Pay";
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all
        Commit();
        if not HandlePayment.HandlePrepaymentTransactional(POSSession, SalesHeader, PrepaymentValue, PrepaymentIsAmount, Print, Send, Pdf2Nav, HandlePayment) then
            Message(ERR_PREPAY, GetLastErrorText);
        POSSession.RequestRefreshData();
    end;

    local procedure HandlePayAndPost(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; FullPosting: Boolean)
    var
        HandlePayment: Codeunit "NPR POS Doc. Export Try Pay";
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all
        Commit();
        if not HandlePayment.HandlePayAndPostTransactional(POSSession, SalesHeader, Print, Pdf2Nav, Send, FullPosting, HandlePayment) then
            Message(ERR_PAY, GetLastErrorText);
        POSSession.RequestRefreshData();
    end;

    local procedure SaleLinesExists(SalePOS: Record "NPR POS Sale"): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(not SaleLinePOS.IsEmpty());
    end;

    local procedure SetPricesInclVAT(var SalePOS: Record "NPR POS Sale"; var JSON: Codeunit "NPR POS JSON Management")
    begin
        if JSON.GetBooleanParameterOrFail('ForcePricesInclVAT', ActionCode()) and (not SalePOS."Prices Including VAT") then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
        end;
    end;

    local procedure SetReference(var SalePOS: Record "NPR POS Sale"; var JSON: Codeunit "NPR POS JSON Management")
    var
        ExtDocNo: Text;
        Attention: Text;
        YourRef: Text;
        ModifyRec: Boolean;
    begin
        ExtDocNo := GetInput(JSON, 'extdocno');
        if (ExtDocNo <> '') then begin
            SalePOS.Validate("External Document No.", CopyStr(ExtDocNo, 1, MaxStrLen(SalePOS."External Document No.")));
            ModifyRec := true;
        end;

        Attention := GetInput(JSON, 'attention');
        if (Attention <> '') then begin
            SalePOS.Validate("Contact No.", CopyStr(Attention, 1, MaxStrLen(SalePOS."Contact No.")));
            ModifyRec := true;
        end;

        YourRef := GetInput(JSON, 'yourref');
        if (YourRef <> '') then begin
            SalePOS.Validate(Reference, CopyStr(YourRef, 1, MaxStrLen(SalePOS.Reference)));
            ModifyRec := true;
        end;

        if ModifyRec then
            SalePOS.Modify(true);
    end;

    local procedure GetInput(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetStringOrFail('input', StrSubstNo(ReadingErr, 'GetInput', ActionCode())));
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Decimal
    begin
        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit(0);

        exit(JSON.GetDecimalOrFail('numpad', StrSubstNo(ReadingErr, 'GetNumpad', ActionCode())));
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', false, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'AskExtDocNo':
                Caption := CaptionAskExtDocNo;
            'AskAttention':
                Caption := CaptionAskAttention;
            'AskYourRef':
                Caption := CaptionAskYourRef;
            'ConfirmExport':
                Caption := CaptionConfirm;
            'SetAsk':
                Caption := CaptionAskOperation;
            'SetPrint':
                Caption := CaptionPrint;
            'SetInvoice':
                Caption := CaptionInvoice;
            'SetReceive':
                Caption := CaptionReceive;
            'SetShip':
                Caption := CaptionShip;
            'SetDocumentType':
                Caption := CaptionDocType;
            'SetNegBalDocumentType':
                Caption := CaptionNegDocType;
            'SetShowCreationMessage':
                Caption := CaptionCreationMsg;
            'PrepaymentDialog':
                Caption := CaptionPrepaymentDlg;
            'FixedPrepaymentValue':
                Caption := CaptionFixedPrepaymentValue;
            'SetTransferSalesperson':
                Caption := CaptionTransferSalesperson;
            'SetTransferPostingSetup':
                Caption := CaptionTransferPostingSetup;
            'SetTransferDimensions':
                Caption := CaptionTransferDim;
            'SetTransferPaymentMethod':
                Caption := CaptionTransferPaymentMethod;
            'SetTransferTaxSetup':
                Caption := CaptionTransferTaxSetup;
            'SetAutoReserveSalesLine':
                Caption := CaptionAutoResrvSalesLine;
            'SetSendPdf2Nav':
                Caption := CaptionSendPdf2Nav;
            'PrintRetailConfirmation':
                Caption := CaptionRetailPrint;
            'CheckCustomerCredit':
                Caption := CaptionCheckCustCredit;
            'PrintPrepaymentDocument':
                Caption := CaptionPrintPrepaymentDoc;
            'OpenDocumentAfterExport':
                Caption := CaptionOpenDoc;
            'PayAndPostInNextSale':
                Caption := CaptionPayAndPostNext;
            'PrintPayAndPostInvoice':
                Caption := CaptionPrintPayAndPost;
            'SaveLinesOnPOSEntry':
                Caption := CaptionSaveLinesOnPOSEntry;
            'ForcePricesInclVAT':
                Caption := CaptionForcePricesInclVAT;
            'PrepaymentInputIsAmount':
                Caption := CaptionPrepayIsAmount;
            'SetSend':
                Caption := CaptionSetSend;
            'SendPrepaymentDocument':
                Caption := CaptionSendPrepayDoc;
            'Pdf2NavPrepaymentDocument':
                Caption := CaptionPdf2NavPrepayDoc;
            'SendPayAndPostDocument':
                Caption := CaptionSendPayAndPost;
            'Pdf2NavPayAndPostDocument':
                Caption := CaptionPdf2NavPayAndPost;
            'SelectCustomer':
                Caption := CaptionSelectCustomer;
            'ShowDocumentPaymentMenu':
                Caption := CaptionDocPaymentMenu;
            'BlockEmptySale':
                Caption := CaptionBlockEmptySale;
            'UseLocationFrom':
                Caption := CaptionUseLocationFrom;
            'UseSpecLocationCode':
                Caption := CaptionUseSpecLocationCode;
            'SendICOrderConfirmation':
                Caption := CaptionSendICOrderConfirmation;
            'PaymentMethodCode':
                Caption := CaptionPaymentMethodCode;
            'CustomerTableView':
                Caption := CaptionCustomerTableView;
            'CustomerLookupPage':
                Caption := CaptionCustomerLookupPage;
            'EnforceCustomerFilter':
                Caption := CaptionEnforceCustomerFilter;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', false, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'AskExtDocNo':
                Caption := DescAskExtDocNo;
            'AskAttention':
                Caption := DescAskAttention;
            'AskYourRef':
                Caption := DescAskYourRef;
            'ConfirmExport':
                Caption := DescConfirm;
            'SetAsk':
                Caption := DescAskOperation;
            'SetPrint':
                Caption := DescPrint;
            'SetInvoice':
                Caption := DescInvoice;
            'SetReceive':
                Caption := DescReceive;
            'SetShip':
                Caption := DescShip;
            'SetDocumentType':
                Caption := DescDocType;
            'SetNegBalDocumentType':
                Caption := DescNegDocType;
            'SetShowCreationMessage':
                Caption := DescCreationMsg;
            'PrepaymentDialog':
                Caption := DescPrepaymentDlg;
            'FixedPrepaymentValue':
                Caption := DescFixedPrepaymentPct;
            'SetTransferSalesperson':
                Caption := DescTransferSalesperson;
            'SetTransferPostingSetup':
                Caption := DescTransferPostingSetup;
            'SetTransferDimensions':
                Caption := DescTransferDim;
            'SetTransferPaymentMethod':
                Caption := DescTransferPaymentMethod;
            'SetTransferTaxSetup':
                Caption := DescTransferTaxSetup;
            'SetAutoReserveSalesLine':
                Caption := DescAutoResrvSalesLine;
            'SetSendPdf2Nav':
                Caption := DescSendPdf2Nav;
            'PrintRetailConfirmation':
                Caption := DescRetailPrint;
            'CheckCustomerCredit':
                Caption := DescCheckCustCredit;
            'PrintPrepaymentDocument':
                Caption := DescPrintPrepaymentDoc;
            'OpenDocumentAfterExport':
                Caption := DescOpenDoc;
            'PayAndPostInNextSale':
                Caption := DescPayAndPostNext;
            'PrintPayAndPostDocument':
                Caption := DescPrintPayAndPost;
            'SaveLinesOnPOSEntry':
                Caption := DescSaveLinesOnPOSEntry;
            'ForcePricesInclVAT':
                Caption := DescForcePricesInclVAT;
            'PrepaymentInputIsAmount':
                Caption := DescPrepayIsAmount;
            'SetSend':
                Caption := DescSetSend;
            'SendPrepaymentDocument':
                Caption := DescSendPrepayDoc;
            'Pdf2NavPrepaymentDocument':
                Caption := DescPdf2NavPrepayDoc;
            'SendPayAndPostDocument':
                Caption := DescSendPayAndPost;
            'Pdf2NavPayAndPostDocument':
                Caption := DescPdf2NavPayAndPost;
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'ShowDocumentPaymentMenu':
                Caption := DescDocPaymentMenu;
            'BlockEmptySale':
                Caption := DescBlockEmptySale;
            'UseLocationFrom':
                Caption := DescUseLocationFrom;
            'UseSpecLocationCode':
                Caption := StrSubstNo(DescUseSpecLocationCode, CaptionUseLocationFrom, SelectStr(4, OptionUseLocationFrom));
            'SendICOrderConfirmation':
                Caption := DescSendICOrderConfirmation;
            'PaymentMethodCode':
                Caption := DescPaymentMethodCode;
            'CustomerTableView':
                Caption := DescCustomerTableView;
            'CustomerLookupPage':
                Caption := DescCustomerLookupPage;
            'EnforceCustomerFilter':
                Caption := DescEnforceCustomerFilter;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterOptionStringCaption', '', false, false)]
    local procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'SetDocumentType':
                Caption := OptionDocTypePozitive;
            'SetNegBalDocumentType':
                Caption := OptionDocTypeNegative;
            'UseLocationFrom':
                Caption := OptionUseLocationFrom;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        PaymentMethod: Record "Payment Method";
        FilterBuilder: FilterPageBuilder;
        Customer: Record Customer;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'UseSpecLocationCode':
                begin
                    Location.FilterGroup(2);
                    Location.SetRange("Use As In-Transit", false);
                    Location.FilterGroup(0);
                    if PAGE.RunModal(0, Location) = ACTION::LookupOK then
                        POSParameterValue.Value := Location.Code;
                end;
            'PaymentMethodCode':
                begin
                    if PAGE.RunModal(0, PaymentMethod) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentMethod.Code;
                end;
            'CustomerTableView':
                begin
                    FilterBuilder.AddRecord(Customer.TableCaption, Customer);
                    if POSParameterValue.Value <> '' then begin
                        Customer.SetView(POSParameterValue.Value);
                        FilterBuilder.SetView(Customer.TableCaption, Customer.GetView(false));
                    end;
                    if FilterBuilder.RunModal() then
                        POSParameterValue.Value := CopyStr(FilterBuilder.GetView(Customer.TableCaption, false), 1, MaxStrLen(POSParameterValue.Value));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        PageId: Integer;
        PageMetadata: Record "Page Metadata";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'UseSpecLocationCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Location.SetRange("Use As In-Transit", false);
                    Location.Code := CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code));
                    Location.Find();
                end;
            'PaymentMethodCode':
                begin
                    if PAGE.RunModal(0, PaymentMethod) = ACTION::LookupOK then
                        POSParameterValue.Value := PaymentMethod.Code;
                end;
            'CustomerTableView':
                begin
                    if POSParameterValue.Value <> '' then
                        Customer.SetView(POSParameterValue.Value);
                end;
            'CustomerLookupPage':
                begin
                    if (POSParameterValue.Value in ['', '0']) then
                        exit;
                    Evaluate(PageId, POSParameterValue.Value);
                    PageMetadata.SetRange(ID, PageId);
                    PageMetadata.SetRange(SourceTable, Database::Customer);
                    PageMetadata.FindFirst();
                end;
        end;
    end;
}
