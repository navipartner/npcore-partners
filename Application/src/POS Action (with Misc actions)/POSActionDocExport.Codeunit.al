codeunit 6150859 "NPR POS Action: Doc. Export"
{
    var
        ActionDescription: Label 'Export current sale to a standard NAV sales document';
        ERRCUSTNOTSET: Label 'Customer must be set before working with Sales Document.';
        ERRNOSALELINES: Label 'There are no sale lines to export';
        ERR_PREPAY: Label 'Sale was exported correctly but prepayment in new sale failed: %1';
        ERR_PAY: Label 'Sale was exported correctly but payment in new sale failed: %1';
        PAYMENT_OPTION: Label 'No Payment,Prepayment Percent,Prepayment Amount,Pay & Post';
        PAYMENT_OPTION_SPLIT: Label 'No Payment,Prepayment Percent,Prepayment Amount,Split Pay & Post,Full Pay & Post';
        PAYMENT_OPTION_DESC: Label 'Select document payment';
        TextExtDocNoLabel: Label 'Enter External Document No.:';
        TextAttentionLabel: Label 'Enter Attention:';
        TextConfirmTitle: Label 'Confirm action';
        TextConfirmLead: Label 'Export active sale to NAV sales document?';
        TextPrepaymentTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid after export';
        TextPrepaymentAmountLead: Label 'Please specify prepayment amount to be paid after export';
        CaptionAskExtDocNo: Label 'Prompt External Doc. No.';
        CaptionAskAttention: Label 'Prompt Attention';
        CaptionConfirm: Label 'Confirm Export';
        CaptionAskOperation: Label 'Ask Doc. Operation';
        CaptionPrint: Label 'Standard Print';
        CaptionInvoice: Label 'Invoice';
        CaptionPost: Label 'Post';
        CaptionReceive: Label 'Receive';
        CaptionShip: Label 'Ship';
        CaptionDocType: Label 'Document Type';
        CaptionNegDocType: Label 'Negative Document Type';
        CaptionOrderType: Label 'Order Type';
        CaptionCreationMsg: Label 'Show Creation Message';
        CaptionPrepaymentDlg: Label 'Prompt Prepayment';
        CaptionFixedPrepaymentValue: Label 'Fixed Prepayment Value';
        CaptionTransferSalesperson: Label 'Transfer Salesperson';
        CaptionTransferPostingSetup: Label 'Transfer Posting Setup';
        CaptionTransferDim: Label 'Transfer Dimensions';
        CaptionTransferPaymentMethod: Label 'Transfer Payment Method';
        CaptionTransferTaxSetup: Label 'Transfer Tax Setup';
        CaptionTransferTranscData: Label 'Transfer Transaction Data';
        CaptionAutoResrvSalesLine: Label 'Auto Reserve Sales Line';
        CaptionSendPdf2Nav: Label 'Send PDF2NAV';
        CaptionRetailPrint: Label 'Retail Confirmation Print';
        CaptionOpenDoc: Label 'Open Document';
        CaptionCheckCustCredit: Label 'Check Customer Credit';
        DescAskExtDocNo: Label 'Ask user to input external document number';
        DescAskAttention: Label 'Ask user to input attention';
        DescConfirm: Label 'Ask user to confirm before any export is performed';
        DescAskOperation: Label 'Ask user to select posting type';
        DescPrint: Label 'Print standard NAV report after export & posting is done';
        DescInvoice: Label 'Invoice exported document';
        DescPost: Label 'Post exported document';
        DescReceive: Label 'Receive exported document';
        DescShip: Label 'Ship exported sales document';
        DescDocType: Label 'Sales Document to create on positive sales balance';
        DescNegDocType: Label 'Sales Document to create on negative sales balance';
        DescOrderType: Label 'Order type of exported document';
        DescCreationMsg: Label 'Show message confirming sales document created';
        DescPrepaymentDlg: Label 'Ask user for prepayment percentage. Will be paid in new sale.';
        DescFixedPrepaymentPct: Label 'Prepayment percentage to use either silently or as dialog default value.';
        DescTransferSalesperson: Label 'Transfer salesperson from sale to exported document';
        DescTransferPostingSetup: Label 'Transfer posting setup from sale to exported document';
        DescTransferDim: Label 'Transfer dimensions from sale to exported document';
        DescTransferPaymentMethod: Label 'Transfer payment method from sale to exported document';
        DescTransferTaxSetup: Label 'Transfer tax setup from sale to exported document';
        DescTransferTranscData: Label 'Transfer transaction data from sale to exported document';
        DescAutoResrvSalesLine: Label 'Automatically reserve items on exported document';
        DescSendPdf2Nav: Label 'Handle document output via PDF2NAV';
        DescRetailPrint: Label 'Print receipt confirming exported document';
        DescOpenDoc: Label 'Open sales document page after export is done';
        DescCheckCustCredit: Label 'Check the customer credit before export is done';
        OptionDocTypePozitive: Label 'Order,Invoice,Quote,Restrict';
        OptionDocTypeNegative: Label 'Return Order,Credit Memo,Restrict';
        OptionOrderType: Label 'Not Set,Order,Lending';
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
        OptionUseLocationFrom: Label 'POS Store,POS Sale Header,Specific Location';
        CaptionUseSpecLocationCode: Label 'Use Specific Location Code';
        DescUseSpecLocationCode: Label 'Select location code to be used for sales document, if parameter ''Use Location From'' is set to ''Specific Location''';
        SpecLocationCodeMustBeSpecified: Label 'POS Action''s parameter ''Use Location From'' is set to ''Specific Location''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''Use Specific Location Code'')';
        CaptionSendICOrderConfirmation: Label 'Send IC Order Cnfmn.';
        DescSendICOrderConfirmation: Label 'Send intercompany order confirmation immediately after sales document has been created. ';
        ReadingErr: Label 'reading in %1 of %2';


    local procedure ActionCode(): Text
    begin
        exit('SALES_DOC_EXP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.9');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
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
            Sender.RegisterBooleanParameter('SetTransferSalesperson', true);
            Sender.RegisterBooleanParameter('SetTransferDimensions', true);
            Sender.RegisterBooleanParameter('SetTransferPaymentMethod', true);
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
            Sender.RegisterOptionParameter('UseLocationFrom', 'Register,POS Store,POS Sale,SpecificLocation', 'Register');
            Sender.RegisterTextParameter('UseSpecLocationCode', '');
            Sender.RegisterBooleanParameter('SendICOrderConfirmation', false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    var
        UI: Codeunit "NPR POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'ExtDocNo', TextExtDocNoLabel);
        Captions.AddActionCaption(ActionCode, 'Attention', TextAttentionLabel);
        Captions.AddActionCaption(ActionCode, 'confirmTitle', TextConfirmTitle);
        Captions.AddActionCaption(ActionCode, 'confirmLead', TextConfirmLead);
        Captions.AddActionCaption(ActionCode, 'prepaymentDialogTitle', TextPrepaymentTitle);
        Captions.AddActionCaption(ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
        Captions.AddActionCaption(ActionCode, 'prepaymentAmountLead', TextPrepaymentAmountLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
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
        SaleLinePOS: Record "NPR Sale Line POS";
        SalePOS: Record "NPR Sale POS";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.ClearActionState();
        POSSession.BeginAction(ActionCode());
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);

        SalePOS.FindFirst;

        if (JSON.GetBooleanParameter('SelectCustomer')) then begin
            if not SelectCustomer(SalePOS, POSSale) then
                SalePOS.TestField("Customer No.");
        end;
        SetReference(SalePOS, JSON);
        SetPricesInclVAT(SalePOS, JSON);
        SetParameters(POSSaleLine, JSON, RetailSalesDocMgt);
        ValidateSale(SalePOS, RetailSalesDocMgt, JSON);

        RetailSalesDocMgt.ProcessPOSSale(SalePOS);

        Commit;

        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        POSSession.StoreActionState('CreatedSalesHeader', SalesHeader);
        SetPaymentParameters(POSSession, JSON, FrontEnd, SalesHeader);
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

    local procedure SetPaymentParameters(POSSession: Codeunit "NPR POS Session"; JSON: Codeunit "NPR POS JSON Management"; FrontEnd: Codeunit "NPR POS Front End Management"; SalesHeader: Record "Sales Header")
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

    local procedure ValidateSale(var SalePOS: Record "NPR Sale POS"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; JSON: Codeunit "NPR POS JSON Management")
    begin
        if JSON.GetBooleanParameterOrFail('BlockEmptySale', ActionCode()) then begin
            if not SaleLinesExists(SalePOS) then
                Error(ERRNOSALELINES);
        end;

        RetailSalesDocMgt.TestSalePOS(SalePOS);
    end;

    local procedure SelectCustomer(var SalePOS: Record "NPR Sale POS"; POSSale: Codeunit "NPR POS Sale"): Boolean
    var
        Customer: Record Customer;
    begin
        if SalePOS."Customer No." <> '' then begin
            SalePOS.TestField("Customer Type", SalePOS."Customer Type"::Ord);
            exit(true);
        end;

        if PAGE.RunModal(0, Customer) <> ACTION::LookupOK then
            exit(false);

        SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
        SalePOS.Validate("Customer No.", Customer."No.");
        SalePOS.Modify(true);
        Commit;
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
        LocationSource: Option Register,"POS Store","POS Sale",SpecificLocation;
        SpecificLocationCode: Code[10];
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
        RetailSalesDocMgt.SetTransferPaymentMethod(JSON.GetBooleanParameterOrFail('SetTransferPaymentMethod', ActionCode()));
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

        LocationSource := JSON.GetIntegerParameterOrFail('UseLocationFrom', ActionCode());
        SpecificLocationCode := JSON.GetStringParameter('UseSpecLocationCode');
        if (LocationSource = LocationSource::SpecificLocation) and (SpecificLocationCode = '') then
            Error(SpecLocationCodeMustBeSpecified);
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
        Commit;
        if not HandlePayment.HandlePrepaymentTransactional(POSSession, SalesHeader, PrepaymentValue, PrepaymentIsAmount, Print, Send, Pdf2Nav, HandlePayment) then
            Message(ERR_PREPAY, GetLastErrorText);
        POSSession.RequestRefreshData();
    end;

    local procedure HandlePayAndPost(POSSession: Codeunit "NPR POS Session"; SalesHeader: Record "Sales Header"; Print: Boolean; Pdf2Nav: Boolean; Send: Boolean; FullPosting: Boolean)
    var
        HandlePayment: Codeunit "NPR POS Doc. Export Try Pay";
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all
        Commit;
        if not HandlePayment.HandlePayAndPostTransactional(POSSession, SalesHeader, Print, Pdf2Nav, Send, FullPosting, HandlePayment) then
            Message(ERR_PAY, GetLastErrorText);
        POSSession.RequestRefreshData();
    end;

    local procedure SaleLinesExists(SalePOS: Record "NPR Sale POS"): Boolean
    var
        SaleLinePOS: Record "NPR Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(not SaleLinePOS.IsEmpty);
    end;

    local procedure SetPricesInclVAT(var SalePOS: Record "NPR Sale POS"; var JSON: Codeunit "NPR POS JSON Management")
    begin
        if JSON.GetBooleanParameterOrFail('ForcePricesInclVAT', ActionCode()) and (not SalePOS."Prices Including VAT") then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
        end;
    end;

    local procedure SetReference(var SalePOS: Record "NPR Sale POS"; var JSON: Codeunit "NPR POS JSON Management")
    var
        ExtDocNo: Text;
        Attention: Text;
    begin
        ExtDocNo := GetInput(JSON, 'extdocno');
        if (ExtDocNo <> '') then begin
            SalePOS.Validate(Reference, CopyStr(ExtDocNo, 1, MaxStrLen(SalePOS.Reference)));
            SalePOS.Modify(true);
        end;

        Attention := GetInput(JSON, 'attention');
        if (Attention <> '') then begin
            SalePOS.Validate("Contact No.", CopyStr(Attention, 1, MaxStrLen(SalePOS."Contact No.")));
            SalePOS.Modify(true);
        end;
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', false, false)]
    procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'AskExtDocNo':
                Caption := CaptionAskExtDocNo;
            'AskAttention':
                Caption := CaptionAskAttention;
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
            //-NPR5.53 [377510]
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
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            'AskExtDocNo':
                Caption := DescAskExtDocNo;
            'AskAttention':
                Caption := DescAskAttention;
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
            //-NPR5.53 [377510]
            'SelectCustomer':
                Caption := DescSelectCustomer;
            'ShowDocumentPaymentMenu':
                Caption := DescDocPaymentMenu;
            'BlockEmptySale':
                Caption := DescBlockEmptySale;
            'UseLocationFrom':
                Caption := DescUseLocationFrom;
            'UseSpecLocationCode':
                Caption := DescUseSpecLocationCode;
            'SendICOrderConfirmation':
                Caption := DescSendICOrderConfirmation;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
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

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
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
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
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
                    Location.Find;
                end;
        end;
    end;
}
