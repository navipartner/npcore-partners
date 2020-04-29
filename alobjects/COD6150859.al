codeunit 6150859 "POS Action - Doc. Export"
{
    // NPR5.50/MMV /20180319 CASE 300557 New action, based on CU 6150814
    // NPR5.51/MMV /20190605  CASE 357277 Added support for skipping line transfer to POS entry.
    // NPR5.51/ALST/20190705  CASE 357848 function prototype changed
    // NPR5.51/ALST/20190717  CASE 361811 added possibility to restrict amount sign for the action
    // NPR5.52/MMV /20191004 CASE 352473 Added better pdf2nav & send support.
    //                                   Fixed prepayment VAT.
    //                                   Added prepayment amount option.
    // NPR5.53/TJ  /20191126 CASE 313966 Using translated text constants for error messages
    // NPR5.53/MMV /20191219 CASE 377510 Rolled back #357277.
    //                                   Added new param for exporting with blank customer, selected manually later in card page.
    //                                   Moved prompts for payment of exported document to after export.
    // NPR5.54/ALPO/20200228 CASE 392239 Possibility to use location code from POS store, POS sale or specific location as an alternative to using location from Register


    trigger OnRun()
    begin
    end;

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
        OptionUseLocationFrom: Label 'Cash Register,POS Store,POS Sale Header,Specific Location';
        CaptionUseSpecLocationCode: Label 'Use Specific Location Code';
        DescUseSpecLocationCode: Label 'Select location code to be used for sales document, if parameter ''Use Location From'' is set to ''Specific Location''';
        SpecLocationCodeMustBeSpecified: Label 'POS Action''s parameter ''Use Location From'' is set to ''Specific Location''. You must specify location code to be used for sale document as a parameter of the POS action (the parameter name is ''Use Specific Location Code'')';

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_EXP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.8'); //NPR5.54 [392239]
        exit ('1.7'); //-+NPR5.53 [377510]
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
            RegisterWorkflowStep('confirm', 'param.ConfirmExport && confirm(labels.confirmTitle, labels.confirmLead).no (abort);');
            RegisterWorkflowStep('extdocno',  'param.AskExtDocNo && input (labels.ExtDocNo).cancel (abort);');
            RegisterWorkflowStep('attention', 'param.AskAttention && input (labels.Attention).cancel (abort);');

            RegisterWorkflowStep('exportDocument', 'respond();');

        //-NPR5.53 [377510]
            RegisterWorkflowStep('endSaleAndDocumentPayment',
                                                    'if (context.prompt_prepayment) {' +
                                                       'context.prepayment_is_amount && numpad(labels.prepaymentDialogTitle, labels.prepaymentAmountLead, param.FixedPrepaymentValue);' +
                                                       '!context.prepayment_is_amount && numpad(labels.prepaymentDialogTitle, labels.prepaymentPctLead, param.FixedPrepaymentValue);' +
                                                    '}' +
                                                    'respond();');
        //+NPR5.53 [377510]
            RegisterWorkflow(false);

            RegisterBooleanParameter('SetAsk', false);
            RegisterBooleanParameter('SetPrint', false);
            RegisterBooleanParameter('SetInvoice', false);
            RegisterBooleanParameter('SetReceive', false);
            RegisterBooleanParameter('SetShip', false);
            RegisterOptionParameter('SetDocumentType', 'Order,Invoice,Quote,Restrict', 'Order');
            RegisterOptionParameter('SetNegBalDocumentType', 'ReturnOrder,CreditMemo,Restrict', 'ReturnOrder');
            RegisterBooleanParameter('SetShowCreationMessage', false);
            RegisterBooleanParameter('SetTransferPostingSetup', true);
            RegisterBooleanParameter('SetAutoReserveSalesLine', false);
            RegisterBooleanParameter('SetSendPdf2Nav', false);
            RegisterBooleanParameter('AskExtDocNo', false);
            RegisterBooleanParameter('AskAttention', false);
            RegisterBooleanParameter('SetTransferSalesperson', true);
            RegisterBooleanParameter('SetTransferDimensions', true);
            RegisterBooleanParameter('SetTransferPaymentMethod', true);
            RegisterBooleanParameter('SetTransferTaxSetup', true);
            RegisterBooleanParameter('ConfirmExport', true);
            RegisterBooleanParameter('PrepaymentDialog', false);
            RegisterDecimalParameter('FixedPrepaymentValue', 0);
            RegisterBooleanParameter('PrintPrepaymentDocument', false);
            RegisterBooleanParameter('PrintRetailConfirmation', true);
            RegisterBooleanParameter('CheckCustomerCredit', true);
            RegisterBooleanParameter('OpenDocumentAfterExport', false);
            RegisterBooleanParameter('PayAndPostInNextSale', false);
            RegisterBooleanParameter('PrintPayAndPostDocument', false);
            RegisterBooleanParameter('ForcePricesInclVAT', false);
            RegisterBooleanParameter('PrepaymentInputIsAmount', false);
            RegisterBooleanParameter('SetSend', false);
            RegisterBooleanParameter('SendPrepaymentDocument', false);
            RegisterBooleanParameter('Pdf2NavPrepaymentDocument', false);
            RegisterBooleanParameter('SendPayAndPostDocument', false);
            RegisterBooleanParameter('Pdf2NavPayAndPostDocument', false);
        //-NPR5.53 [377510]
            RegisterBooleanParameter('SelectCustomer', true);
            RegisterBooleanParameter('ShowDocumentPaymentMenu', false);
            RegisterBooleanParameter('BlockEmptySale', true);
        //+NPR5.53 [377510]
            //-NPR5.54 [392239]
            RegisterOptionParameter('UseLocationFrom', 'Register,POS Store,POS Sale,SpecificLocation', 'Register');
            RegisterTextParameter('UseSpecLocationCode','');
            //+NPR5.54 [392239]
          end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption (ActionCode, 'ExtDocNo', TextExtDocNoLabel);
        Captions.AddActionCaption (ActionCode, 'Attention', TextAttentionLabel);
        Captions.AddActionCaption (ActionCode, 'confirmTitle', TextConfirmTitle);
        Captions.AddActionCaption (ActionCode, 'confirmLead', TextConfirmLead);
        Captions.AddActionCaption (ActionCode, 'prepaymentDialogTitle', TextPrepaymentTitle);
        Captions.AddActionCaption (ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
        Captions.AddActionCaption (ActionCode, 'prepaymentAmountLead', TextPrepaymentAmountLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        //-NPR5.53 [377510]
        case WorkflowStep of
          'exportDocument' : ExportToDocument(Context, POSSession, FrontEnd);
          'endSaleAndDocumentPayment' : DocumentPayment(Context, POSSession, FrontEnd);
        end;
        //+NPR5.53 [377510]
    end;

    local procedure "--"()
    begin
    end;

    local procedure ExportToDocument(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSession.ClearActionState();
        POSSession.BeginAction(ActionCode());
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context,FrontEnd);

        SalePOS.FindFirst;

        //-NPR5.53 [377510]
        if (JSON.GetBooleanParameter('SelectCustomer', true)) then begin
        //+NPR5.53 [377510]
          if not SelectCustomer(SalePOS, POSSale) then
            SalePOS.TestField("Customer No.");
        end;
        if JSON.GetBooleanParameter('CheckCustomerCredit', true) then
          CheckCustCredit(SalePOS);
        SetReference(SalePOS, JSON);
        SetPricesInclVAT(SalePOS, JSON);
        SetParameters(POSSaleLine, JSON, RetailSalesDocMgt);
        ValidateSale(SalePOS, RetailSalesDocMgt, JSON);

        RetailSalesDocMgt.ProcessPOSSale(SalePOS);

        //-NPR5.53 [377510]
        Commit;

        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        POSSession.StoreActionState('CreatedSalesHeader', SalesHeader);
        SetPaymentParameters(POSSession, JSON, FrontEnd, SalesHeader);
        //+NPR5.53 [377510]
    end;

    local procedure DocumentPayment(Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
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
        POSSale: Codeunit "POS Sale";
        RecRef: RecordRef;
    begin
        POSSession.GetSale(POSSale);
        POSSession.RetrieveActionStateRecordRef('CreatedSalesHeader', RecRef);
        RecRef.SetTable(SalesHeader);

        JSON.InitializeJObjectParser(Context,FrontEnd);

        PrepaymentValue := GetPrepaymentValue(JSON);
        JSON.SetScopeRoot(true);

        PrepaymentIsAmount := JSON.GetBoolean('prepayment_is_amount', true);
        PayAndPost := JSON.GetBoolean('pay_and_post', true);
        FullPosting := JSON.GetBoolean('full_posting', true);

        PrepaymentPdf2Nav := JSON.GetBooleanParameter('Pdf2NavPrepaymentDocument', true);
        PrepaymentSend := JSON.GetBooleanParameter('SendPrepaymentDocument', true);
        PayAndPostPdf2Nav := JSON.GetBooleanParameter('Pdf2NavPayAndPostDocument', true);
        PayAndPostSend := JSON.GetBooleanParameter('SendPayAndPostDocument', true);
        PrintPrepayment := JSON.GetBooleanParameter('PrintPrepaymentDocument', true);
        PayAndPostPrint := JSON.GetBooleanParameter('PrintPayAndPostDocument', true);

        if PrepaymentValue > 0 then begin
          //End sale, auto start new sale, and insert prepayment line.
          POSSession.StartTransaction();
          POSSession.ChangeViewSale();
          HandlePrepayment(POSSession, SalesHeader, PrepaymentValue, PrepaymentIsAmount, PrintPrepayment, PrepaymentSend, PrepaymentPdf2Nav);
        end else if PayAndPost then begin
          //End sale, auto start new sale, and insert payment line.
          POSSession.StartTransaction();
          POSSession.ChangeViewSale();
          HandlePayAndPost(POSSession, SalesHeader, PayAndPostPrint, PayAndPostPdf2Nav, PayAndPostSend, FullPosting);
        end else begin
          //End sale
          POSSale.SelectViewForEndOfSale(POSSession);
        end;
        //+NPR5.53 [377510]
    end;

    local procedure SetPaymentParameters(POSSession: Codeunit "POS Session";JSON: Codeunit "POS JSON Management";FrontEnd: Codeunit "POS Front End Management";SalesHeader: Record "Sales Header")
    var
        Choice: Integer;
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
    begin
        //-NPR5.53 [377510]
        if SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin //If document has been posted/deleted, we cannot pay parts of it.
          if JSON.GetBooleanParameter('ShowDocumentPaymentMenu', true) then begin
            if RetailSalesDocImpMgt.DocumentIsSetToFullPosting(SalesHeader) then
              Choice := StrMenu(PAYMENT_OPTION, 1, PAYMENT_OPTION_DESC)
            else
              Choice := StrMenu(PAYMENT_OPTION_SPLIT, 1, PAYMENT_OPTION_DESC);

            case Choice of
              0,  //Cancelled
              1 : //None
                begin
                  JSON.SetContext('prompt_prepayment', false);
                  JSON.SetContext('prepayment_is_amount', false);
                  JSON.SetContext('pay_and_post', false);
                  JSON.SetContext('full_posting', false);
                end;
              2 : //Prepayment Percent
                begin
                  JSON.SetContext('prompt_prepayment', true);
                  JSON.SetContext('prepayment_is_amount', false);
                  JSON.SetContext('pay_and_post', false);
                  JSON.SetContext('full_posting', false);
                end;
              3 : //Prepayment Amount
                begin
                  JSON.SetContext('prompt_prepayment', true);
                  JSON.SetContext('prepayment_is_amount', true);
                  JSON.SetContext('pay_and_post', false);
                  JSON.SetContext('full_posting', false);
                end;
              4 : //Payment + post
                begin
                  JSON.SetContext('prompt_prepayment', false);
                  JSON.SetContext('prepayment_is_amount', false);
                  JSON.SetContext('pay_and_post', true);
                  JSON.SetContext('full_posting', false);
                end;
              5 : //Full payment + post
                begin
                  JSON.SetContext('prompt_prepayment', false);
                  JSON.SetContext('prepayment_is_amount', false);
                  JSON.SetContext('pay_and_post', true);
                  JSON.SetContext('full_posting', true);
                end;
            end;
          end else begin
            JSON.SetContext('pay_and_post', JSON.GetBooleanParameter('PayAndPostInNextSale', true));
            JSON.SetContext('prompt_prepayment', JSON.GetBooleanParameter('PrepaymentDialog', true));
            JSON.SetContext('prepayment_is_amount', JSON.GetBooleanParameter('PrepaymentInputIsAmount', true));
            JSON.SetContext('full_posting', false);
          end;
        end else begin
          JSON.SetContext('prompt_prepayment', false);
          JSON.SetContext('prepayment_is_amount', false);
          JSON.SetContext('pay_and_post', false);
          JSON.SetContext('full_posting', false);
        end;

        FrontEnd.SetActionContext(ActionCode(),JSON);
        //+NPR5.53 [377510]
    end;

    local procedure ValidateSale(var SalePOS: Record "Sale POS";var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";JSON: Codeunit "POS JSON Management")
    begin
        //-NPR5.53 [377510]
        if JSON.GetBooleanParameter('BlockEmptySale', true) then begin
        //+NPR5.53 [377510]
          if not SaleLinesExists(SalePOS) then
            Error (ERRNOSALELINES);
        end;

        RetailSalesDocMgt.TestSalePOS(SalePOS);
    end;

    local procedure SelectCustomer(var SalePOS: Record "Sale POS";POSSale: Codeunit "POS Sale"): Boolean
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

    local procedure SetParameters(var POSSaleLine: Codeunit "POS Sale Line";var JSON: Codeunit "POS JSON Management";var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
    var
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict;
        DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict;
        LocationSource: Option Register,"POS Store","POS Sale",SpecificLocation;
        SpecificLocationCode: Code[10];
    begin
        RetailSalesDocMgt.SetAsk( JSON.GetBooleanParameter('SetAsk', true) );
        RetailSalesDocMgt.SetPrint( JSON.GetBooleanParameter('SetPrint', true) );
        RetailSalesDocMgt.SetInvoice( JSON.GetBooleanParameter('SetInvoice', true) );
        RetailSalesDocMgt.SetReceive( JSON.GetBooleanParameter('SetReceive', true) );
        RetailSalesDocMgt.SetShip( JSON.GetBooleanParameter('SetShip', true) );
        RetailSalesDocMgt.SetSendPostedPdf2Nav(JSON.GetBooleanParameter('SetSendPdf2Nav',true));
        RetailSalesDocMgt.SetRetailPrint(JSON.GetBooleanParameter('PrintRetailConfirmation',true));
        RetailSalesDocMgt.SetAutoReserveSalesLine( JSON.GetBooleanParameter('SetAutoReserveSalesLine', true) );
        RetailSalesDocMgt.SetTransferSalesPerson( JSON.GetBooleanParameter('SetTransferSalesperson', true) );
        RetailSalesDocMgt.SetTransferPostingsetup( JSON.GetBooleanParameter('SetTransferPostingSetup', true) );
        RetailSalesDocMgt.SetTransferDimensions( JSON.GetBooleanParameter('SetTransferDimensions', true) );
        RetailSalesDocMgt.SetTransferPaymentMethod( JSON.GetBooleanParameter('SetTransferPaymentMethod', true) );
        RetailSalesDocMgt.SetTransferTaxSetup( JSON.GetBooleanParameter('SetTransferTaxSetup', true) );
        RetailSalesDocMgt.SetOpenSalesDocAfterExport( JSON.GetBooleanParameter('OpenDocumentAfterExport', true) );
        RetailSalesDocMgt.SetSendDocument(JSON.GetBooleanParameter('SetSend', true));
        RetailSalesDocMgt.SetWriteInAuditRoll(true);

        if JSON.GetBooleanParameter('SetShowCreationMessage', true) then
          RetailSalesDocMgt.SetShowCreationMessage();

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);

        DocumentTypePozitive := JSON.GetIntegerParameter('SetDocumentType',true);
        DocumentTypeNegative := JSON.GetIntegerParameter('SetNegBalDocumentType',true);

        if AmountInclVAT >= 0 then
          case DocumentTypePozitive of
            DocumentTypePozitive::Order :
                RetailSalesDocMgt.SetDocumentTypeOrder();
            DocumentTypePozitive::Invoice :
                RetailSalesDocMgt.SetDocumentTypeInvoice();
            DocumentTypePozitive::Quote :
                RetailSalesDocMgt.SetDocumentTypeQuote();
            DocumentTypePozitive::Restrict:
              //-NPR5.53 [313966]
              //ERROR(WrongPozitiveSignErr,DocumentTypeNegative);
              Error(WrongPozitiveSignErr,SelectStr(DocumentTypeNegative + 1,OptionDocTypeNegative));
              //+NPR5.53 [313966]
          end
        else
          case DocumentTypeNegative of
            DocumentTypeNegative::CreditMemo :
                RetailSalesDocMgt.SetDocumentTypeCreditMemo();
            DocumentTypeNegative::ReturnOrder :
                RetailSalesDocMgt.SetDocumentTypeReturnOrder();
            DocumentTypeNegative::Restrict:
              //-NPR5.53 [313966]
              //ERROR(WrongNegativeSignErr,DocumentTypePozitive);
              Error(WrongNegativeSignErr,SelectStr(DocumentTypePozitive + 1,OptionDocTypePozitive));
              //+NPR5.53 [313966]
          end;

        //-NPR5.54 [392239]
        LocationSource := JSON.GetIntegerParameter('UseLocationFrom',true);
        SpecificLocationCode := JSON.GetStringParameter('UseSpecLocationCode',false);
        if (LocationSource = LocationSource::SpecificLocation) and (SpecificLocationCode = '') then
          Error(SpecLocationCodeMustBeSpecified);
        RetailSalesDocMgt.SetLocationSource(LocationSource,SpecificLocationCode);
        //+NPR5.54 [392239]
    end;

    local procedure GetPrepaymentValue(var JSON: Codeunit "POS JSON Management"): Decimal
    begin
        //-NPR5.53 [377510]
        if JSON.GetBoolean('prompt_prepayment', true) then begin
          exit(GetNumpad(JSON, 'endSaleAndDocumentPayment'));
        end else begin
        //+NPR5.53 [377510]
          exit(JSON.GetDecimalParameter('FixedPrepaymentValue', true));
        end;
    end;

    local procedure HandlePrepayment(POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";PrepaymentValue: Decimal;PrepaymentIsAmount: Boolean;Print: Boolean;Send: Boolean;Pdf2Nav: Boolean)
    var
        Success: Boolean;
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all

        Commit;
        asserterror begin
        //-NPR5.53 [377510]
          SalesHeader.LockTable;
          if SalesHeader.Find then begin
        //+NPR5.53 [377510]
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
        //-NPR5.53 [377510]
            SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        //+NPR5.53 [377510]
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();

            RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, true, PrepaymentIsAmount);

            POSSession.RequestRefreshData();
            Commit;
          end;

          Success := true;
          Error('');
        end;

        if not Success then
          Message(ERR_PREPAY, GetLastErrorText);
    end;

    local procedure HandlePayAndPost(POSSession: Codeunit "POS Session";SalesHeader: Record "Sales Header";Print: Boolean;Pdf2Nav: Boolean;Send: Boolean;FullPosting: Boolean)
    var
        Success: Boolean;
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
    begin
        //An error after sale end, before front end sync, is not allowed so we catch all

        Commit;
        asserterror begin
        //-NPR5.53 [377510]
          SalesHeader.LockTable;
          if SalesHeader.Find then begin

            if FullPosting then begin
              RetailSalesDocImpMgt.SetDocumentToFullPosting(SalesHeader)
            end;
        //+NPR5.53 [377510]

            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
        //-NPR5.53 [377510]
            SalePOS."Customer Type" := SalePOS."Customer Type"::Ord;
            SalePOS.Validate("Customer No.", SalesHeader."Bill-to Customer No.");
        //+NPR5.53 [377510]
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();

            RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, Pdf2Nav, Send, true);

            POSSession.RequestRefreshData();
            Commit;
          end;
          Success := true;
          Error('');
        end;

        if not Success then
          Message(ERR_PAY, GetLastErrorText);
    end;

    local procedure CheckCustCredit(SalePOS: Record "Sale POS")
    var
        RetailSetup: Record "Retail Setup";
        TempSalesHeader: Record "Sales Header" temporary;
        FormCode: Codeunit "Retail Form Code";
        POSCheckCrLimit: Codeunit "POS-Check Cr. Limit";
    begin
        FormCode.CreateSalesHeader(SalePOS,TempSalesHeader);
        if not POSCheckCrLimit.SalesHeaderPOSCheck(TempSalesHeader) then
          Error('');
    end;

    local procedure SaleLinesExists(SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.",SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.",SalePOS."Sales Ticket No.");
        exit( not SaleLinePOS.IsEmpty );
    end;

    local procedure SetPricesInclVAT(var SalePOS: Record "Sale POS";var JSON: Codeunit "POS JSON Management")
    begin
        if JSON.GetBooleanParameter('ForcePricesInclVAT', true) and (not SalePOS."Prices Including VAT") then begin
          SalePOS.Validate("Prices Including VAT", true);
          SalePOS.Modify(true);
        end;
    end;

    local procedure SetReference(var SalePOS: Record "Sale POS";var JSON: Codeunit "POS JSON Management")
    var
        ExtDocNo: Text;
        Attention: Text;
    begin
        ExtDocNo := GetInput (JSON, 'extdocno');
        if (ExtDocNo <> '') then begin
          SalePOS.Validate(Reference, CopyStr (ExtDocNo, 1, MaxStrLen (SalePOS.Reference)));
          SalePOS.Modify(true);
        end;

        Attention := GetInput (JSON, 'attention');
        if (Attention <> '') then begin
          SalePOS.Validate ("Contact No.", CopyStr (Attention, 1, MaxStrLen (SalePOS."Contact No.")));
          SalePOS.Modify(true);
        end;
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
          'AskExtDocNo' : Caption := CaptionAskExtDocNo;
          'AskAttention' : Caption := CaptionAskAttention;
          'ConfirmExport' : Caption := CaptionConfirm;
          'SetAsk' : Caption := CaptionAskOperation;
          'SetPrint' : Caption := CaptionPrint;
          'SetInvoice' : Caption := CaptionInvoice;
          'SetReceive' : Caption := CaptionReceive;
          'SetShip' : Caption := CaptionShip;
          'SetDocumentType' : Caption := CaptionDocType;
          'SetNegBalDocumentType' : Caption := CaptionNegDocType;
          'SetShowCreationMessage' : Caption := CaptionCreationMsg;
          'PrepaymentDialog' : Caption := CaptionPrepaymentDlg;
          'FixedPrepaymentValue' : Caption := CaptionFixedPrepaymentValue;
          'SetTransferSalesperson' : Caption := CaptionTransferSalesperson;
          'SetTransferPostingSetup' : Caption := CaptionTransferPostingSetup;
          'SetTransferDimensions' : Caption := CaptionTransferDim;
          'SetTransferPaymentMethod' : Caption := CaptionTransferPaymentMethod;
          'SetTransferTaxSetup' : Caption := CaptionTransferTaxSetup;
          'SetAutoReserveSalesLine' : Caption := CaptionAutoResrvSalesLine;
          'SetSendPdf2Nav' : Caption := CaptionSendPdf2Nav;
          'PrintRetailConfirmation' : Caption := CaptionRetailPrint;
          'CheckCustomerCredit' : Caption := CaptionCheckCustCredit;
          'PrintPrepaymentDocument' : Caption := CaptionPrintPrepaymentDoc;
          'OpenDocumentAfterExport' : Caption := CaptionOpenDoc;
          'PayAndPostInNextSale' : Caption := CaptionPayAndPostNext;
          'PrintPayAndPostInvoice' : Caption := CaptionPrintPayAndPost;
          'SaveLinesOnPOSEntry' : Caption := CaptionSaveLinesOnPOSEntry;
          'ForcePricesInclVAT' : Caption := CaptionForcePricesInclVAT;
          'PrepaymentInputIsAmount' : Caption := CaptionPrepayIsAmount;
          'SetSend' : Caption := CaptionSetSend;
          'SendPrepaymentDocument' : Caption := CaptionSendPrepayDoc;
          'Pdf2NavPrepaymentDocument' : Caption := CaptionPdf2NavPrepayDoc;
          'SendPayAndPostDocument' : Caption := CaptionSendPayAndPost;
          'Pdf2NavPayAndPostDocument' : Caption := CaptionPdf2NavPayAndPost;
        //-NPR5.53 [377510]
          'SelectCustomer' : Caption := CaptionSelectCustomer;
          'ShowDocumentPaymentMenu' : Caption := CaptionDocPaymentMenu;
          'BlockEmptySale' : Caption := CaptionBlockEmptySale;
        //+NPR5.53 [377510]
          //-NPR5.54 [392239]
          'UseLocationFrom': Caption :=  CaptionUseLocationFrom;
          'UseSpecLocationCode': Caption := CaptionUseSpecLocationCode;
          //+NPR5.54 [392239]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'AskExtDocNo' : Caption := DescAskExtDocNo;
          'AskAttention' : Caption := DescAskAttention;
          'ConfirmExport' : Caption := DescConfirm;
          'SetAsk' : Caption := DescAskOperation;
          'SetPrint' : Caption := DescPrint;
          'SetInvoice' : Caption := DescInvoice;
          'SetReceive' : Caption := DescReceive;
          'SetShip' : Caption := DescShip;
          'SetDocumentType' : Caption := DescDocType;
          'SetNegBalDocumentType' : Caption := DescNegDocType;
          'SetShowCreationMessage' : Caption := DescCreationMsg;
          'PrepaymentDialog' : Caption := DescPrepaymentDlg;
          'FixedPrepaymentValue' : Caption := DescFixedPrepaymentPct;
          'SetTransferSalesperson' : Caption := DescTransferSalesperson;
          'SetTransferPostingSetup' : Caption := DescTransferPostingSetup;
          'SetTransferDimensions' : Caption := DescTransferDim;
          'SetTransferPaymentMethod' : Caption := DescTransferPaymentMethod;
          'SetTransferTaxSetup' : Caption := DescTransferTaxSetup;
          'SetAutoReserveSalesLine' : Caption := DescAutoResrvSalesLine;
          'SetSendPdf2Nav' : Caption := DescSendPdf2Nav;
          'PrintRetailConfirmation' : Caption := DescRetailPrint;
          'CheckCustomerCredit' : Caption := DescCheckCustCredit;
          'PrintPrepaymentDocument' : Caption := DescPrintPrepaymentDoc;
          'OpenDocumentAfterExport' : Caption := DescOpenDoc;
          'PayAndPostInNextSale' : Caption := DescPayAndPostNext;
          'PrintPayAndPostDocument' : Caption := DescPrintPayAndPost;
          'SaveLinesOnPOSEntry' : Caption := DescSaveLinesOnPOSEntry;
          'ForcePricesInclVAT' : Caption := DescForcePricesInclVAT;
          'PrepaymentInputIsAmount' : Caption := DescPrepayIsAmount;
          'SetSend' : Caption := DescSetSend;
          'SendPrepaymentDocument' : Caption := DescSendPrepayDoc;
          'Pdf2NavPrepaymentDocument' : Caption := DescPdf2NavPrepayDoc;
          'SendPayAndPostDocument' : Caption := DescSendPayAndPost;
          'Pdf2NavPayAndPostDocument' : Caption := DescPdf2NavPayAndPost;
        //-NPR5.53 [377510]
          'SelectCustomer' : Caption := DescSelectCustomer;
          'ShowDocumentPaymentMenu' : Caption := DescDocPaymentMenu;
          'BlockEmptySale' : Caption := DescBlockEmptySale;
        //+NPR5.53 [377510]
          //-NPR5.54 [392239]
          'UseLocationFrom': Caption :=  DescUseLocationFrom;
          'UseSpecLocationCode': Caption := DescUseSpecLocationCode;
          //+NPR5.54 [392239]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SetDocumentType' : Caption := OptionDocTypePozitive;
          'SetNegBalDocumentType' : Caption := OptionDocTypeNegative;
          'UseLocationFrom': Caption :=  OptionUseLocationFrom;  //NPR5.54 [392239]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "POS Parameter Value";Handled: Boolean)
    var
        Location: Record Location;
    begin
        //-NPR5.54 [392239]
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;

        case POSParameterValue.Name of
          'UseSpecLocationCode': begin
            Location.FilterGroup(2);
            Location.SetRange("Use As In-Transit",false);
            Location.FilterGroup(0);
            if PAGE.RunModal(0,Location) = ACTION::LookupOK then
              POSParameterValue.Value := Location.Code;
          end;
        end;
        //+NPR5.54 [392239]
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "POS Parameter Value")
    var
        Location: Record Location;
    begin
        //-NPR5.54 [392239]
        if POSParameterValue."Action Code" <> ActionCode() then
          exit;

        case POSParameterValue.Name of
          'UseSpecLocationCode': begin
            if POSParameterValue.Value = '' then
              exit;
            Location.SetRange("Use As In-Transit",false);
            Location.Code := CopyStr(POSParameterValue.Value,1,MaxStrLen(Location.Code));
            Location.Find;
          end;
        end;
        //+NPR5.54 [392239]
    end;
}

