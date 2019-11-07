codeunit 6150859 "POS Action - Doc. Export"
{
    // NPR5.50/MMV /20180319 CASE 300557 New action, based on CU 6150814
    // NPR5.51/MMV /20190605  CASE 357277 Added support for skipping line transfer to POS entry.
    // NPR5.51/ALST/20190705  CASE 357848 function prototype changed
    // NPR5.51/ALST/20190717  CASE 361811 added possibility to restrict amount sign for the action
    // NPR5.52/MMV /20191004 CASE 352473 Added better pdf2nav & send support.
    //                                   Fixed prepayment VAT.
    //                                   Added prepayment amount option.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Export current sale to a standard NAV sales document';
        ERRCUSTNOTSET: Label 'Customer must be set before working with Sales Document.';
        ERRNOSALELINES: Label 'There are no sale lines to export';
        ERR_PREPAY: Label 'Sale was exported correctly but prepayment in new sale failed: %1';
        ERR_PAY: Label 'Sale was exported correctly but payment in new sale failed: %1';
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

    local procedure ActionCode(): Text
    begin
        exit('SALES_DOC_EXP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.5'); //NPR5.52 [352473]
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
                RegisterWorkflowStep('confirm', 'param.ConfirmExport && confirm(labels.confirmTitle, labels.confirmLead).no (abort);');
                RegisterWorkflowStep('extdocno', 'param.AskExtDocNo && input (labels.ExtDocNo).cancel (abort);');
                RegisterWorkflowStep('attention', 'param.AskAttention && input (labels.Attention).cancel (abort);');
        //-NPR5.52 [352473]
            RegisterWorkflowStep('prepaymentPct', 'param.PrepaymentDialog && !param.PrepaymentInputIsAmount && numpad(labels.prepaymentDialogTitle, labels.prepaymentPctLead, param.FixedPrepaymentValue).cancel(abort);');
            RegisterWorkflowStep('prepaymentAmount', 'param.PrepaymentDialog && param.PrepaymentInputIsAmount && numpad(labels.prepaymentDialogTitle, labels.prepaymentAmountLead, param.FixedPrepaymentValue).cancel(abort);');
        //+NPR5.52 [352473]
                RegisterWorkflowStep('exportDocument', 'respond();');
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
        //-NPR5.52 [352473]
            RegisterBooleanParameter('PrepaymentDialog', false);
            RegisterDecimalParameter('FixedPrepaymentValue', 0);
        //+NPR5.52 [352473]
                RegisterBooleanParameter('PrintPrepaymentDocument', false);
                RegisterBooleanParameter('PrintRetailConfirmation', true);
                RegisterBooleanParameter('CheckCustomerCredit', true);
                RegisterBooleanParameter('OpenDocumentAfterExport', false);
                RegisterBooleanParameter('PayAndPostInNextSale', false);
        //-NPR5.52 [352473]
            RegisterBooleanParameter('PrintPayAndPostDocument', false);
        //+NPR5.52 [352473]
                //-NPR5.51 [357277]
                RegisterBooleanParameter('SaveLinesOnPOSEntry', true);
                //+NPR5.51 [357277]
        //-NPR5.52 [352473]
            RegisterBooleanParameter('ForcePricesInclVAT', false);
            RegisterBooleanParameter('PrepaymentInputIsAmount', false);
            RegisterBooleanParameter('SetSend', false);
            RegisterBooleanParameter('SendPrepaymentDocument', false);
            RegisterBooleanParameter('Pdf2NavPrepaymentDocument', false);
            RegisterBooleanParameter('SendPayAndPostDocument', false);
            RegisterBooleanParameter('Pdf2NavPayAndPostDocument', false);
        //+NPR5.52 [352473]
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    var
        UI: Codeunit "POS UI Management";
    begin
        Captions.AddActionCaption(ActionCode, 'ExtDocNo', TextExtDocNoLabel);
        Captions.AddActionCaption(ActionCode, 'Attention', TextAttentionLabel);
        Captions.AddActionCaption(ActionCode, 'confirmTitle', TextConfirmTitle);
        Captions.AddActionCaption(ActionCode, 'confirmLead', TextConfirmLead);
        //-NPR5.52 [352473]
        Captions.AddActionCaption (ActionCode, 'prepaymentDialogTitle', TextPrepaymentTitle);
        Captions.AddActionCaption(ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
        Captions.AddActionCaption (ActionCode, 'prepaymentAmountLead', TextPrepaymentAmountLead);
        //+NPR5.52 [352473]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;
        Handled := true;

        ExportToDocument(Context, POSSession, FrontEnd);
    end;

    local procedure "--"()
    begin
    end;

    local procedure ExportToDocument(Context: JsonObject; POSSession: Codeunit "POS Session"; FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";
        SaleLinePOS: Record "Sale Line POS";
        SalePOS: Record "Sale POS";
        POSSaleLine: Codeunit "POS Sale Line";
        POSSale: Codeunit "POS Sale";
        Customer: Record Customer;
        PrepaymentValue: Decimal;
        SalesHeader: Record "Sales Header";
        PrintPrepayment: Boolean;
        PayAndPost: Boolean;
        PayAndPostPrint: Boolean;
        PrepaymentIsAmount: Boolean;
        PrepaymentSend: Boolean;
        PrepaymentPdf2Nav: Boolean;
        PayAndPostPdf2Nav: Boolean;
        PayAndPostSend: Boolean;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context, FrontEnd);

        //-NPR5.51 [361811]
        //SelectCustomer ends tranzaction
        SalePOS.FindFirst;
        //+NPR5.51 [361811]

        //-NPR5.52 [352473]
        if not SelectCustomer(SalePOS, POSSale) then
        //+NPR5.52 [352473]
            SalePOS.TestField("Customer No.");
        if JSON.GetBooleanParameter('CheckCustomerCredit', true) then
            CheckCustCredit(SalePOS);
        SetReference(SalePOS, JSON);
        //-NPR5.52 [352473]
        SetPricesInclVAT(SalePOS, JSON);
        //+NPR5.52 [352473]
        SetParameters(POSSaleLine, JSON, RetailSalesDocMgt);
        ValidateSale(SalePOS, RetailSalesDocMgt);

        PrepaymentValue := GetPrepaymentValue(JSON);
        //-NPR5.52 [352473]
        PrepaymentIsAmount := JSON.GetBooleanParameter('PrepaymentInputIsAmount', true);
        PrepaymentPdf2Nav := JSON.GetBooleanParameter('Pdf2NavPrepaymentDocument', true);
        PrepaymentSend := JSON.GetBooleanParameter('SendPrepaymentDocument', true);
        PayAndPostPdf2Nav := JSON.GetBooleanParameter('Pdf2NavPayAndPostDocument', true);
        PayAndPostSend := JSON.GetBooleanParameter('SendPayAndPostDocument', true);
        //+NPR5.52 [352473]
        PrintPrepayment := JSON.GetBooleanParameter('PrintPrepaymentDocument', true);
        PayAndPost := JSON.GetBooleanParameter('PayAndPostInNextSale', true);
        PayAndPostPrint := JSON.GetBooleanParameter('PrintPayAndPostDocument', true);
        RetailSalesDocMgt.ProcessPOSSale(SalePOS);

        if PrepaymentValue > 0 then begin
            //End sale, auto start new sale, and insert prepayment line.
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
        //-NPR5.52 [352473]
          HandlePrepayment(POSSession, RetailSalesDocMgt, PrepaymentValue, PrepaymentIsAmount, PrintPrepayment, PrepaymentSend, PrepaymentPdf2Nav, SalePOS);
        //+NPR5.52 [352473]
                //End sale, auto start new sale, and insert payment line.
                POSSession.StartTransaction();
                POSSession.ChangeViewSale();
        //-NPR5.52 [352473]
          HandlePayAndPost(POSSession, RetailSalesDocMgt, PayAndPostPrint, SalePOS, PayAndPostPdf2Nav, PayAndPostSend);
        //+NPR5.52 [352473]
            end else
                //End sale
                POSSale.SelectViewForEndOfSale(POSSession)
    end;

    local procedure ValidateSale(var SalePOS: Record "Sale POS"; var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
    begin
        if not SaleLinesExists(SalePOS) then
            Error(ERRNOSALELINES);

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
        //-NPR5.52 [352473]
        POSSale.RefreshCurrent();
        //+NPR5.52 [352473]
        exit(true);
    end;

    local procedure SetParameters(var POSSaleLine: Codeunit "POS Sale Line"; var JSON: Codeunit "POS JSON Management"; var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
    var
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict;
        DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict;
    begin
        RetailSalesDocMgt.SetAsk(JSON.GetBooleanParameter('SetAsk', true));
        RetailSalesDocMgt.SetPrint(JSON.GetBooleanParameter('SetPrint', true));
        RetailSalesDocMgt.SetInvoice(JSON.GetBooleanParameter('SetInvoice', true));
        RetailSalesDocMgt.SetReceive(JSON.GetBooleanParameter('SetReceive', true));
        RetailSalesDocMgt.SetShip(JSON.GetBooleanParameter('SetShip', true));
        RetailSalesDocMgt.SetSendPostedPdf2Nav(JSON.GetBooleanParameter('SetSendPdf2Nav', true));
        RetailSalesDocMgt.SetRetailPrint(JSON.GetBooleanParameter('PrintRetailConfirmation', true));
        RetailSalesDocMgt.SetAutoReserveSalesLine(JSON.GetBooleanParameter('SetAutoReserveSalesLine', true));
        RetailSalesDocMgt.SetTransferSalesPerson(JSON.GetBooleanParameter('SetTransferSalesperson', true));
        RetailSalesDocMgt.SetTransferPostingsetup(JSON.GetBooleanParameter('SetTransferPostingSetup', true));
        RetailSalesDocMgt.SetTransferDimensions(JSON.GetBooleanParameter('SetTransferDimensions', true));
        RetailSalesDocMgt.SetTransferPaymentMethod(JSON.GetBooleanParameter('SetTransferPaymentMethod', true));
        RetailSalesDocMgt.SetTransferTaxSetup(JSON.GetBooleanParameter('SetTransferTaxSetup', true));
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(JSON.GetBooleanParameter('OpenDocumentAfterExport', true));
        //-NPR5.51 [357277]
        RetailSalesDocMgt.SetDeleteSaleLinesAfterExport(not JSON.GetBooleanParameter('SaveLinesOnPOSEntry', true));
        //+NPR5.51 [357277]
        //-NPR5.52 [352473]
        RetailSalesDocMgt.SetSendDocument(JSON.GetBooleanParameter('SetSend', true));
        //+NPR5.52 [352473]
        RetailSalesDocMgt.SetWriteInAuditRoll(true);

        if JSON.GetBooleanParameter('SetShowCreationMessage', true) then
            RetailSalesDocMgt.SetShowCreationMessage();

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);

        DocumentTypePozitive := JSON.GetIntegerParameter('SetDocumentType', true);
        DocumentTypeNegative := JSON.GetIntegerParameter('SetNegBalDocumentType', true);

        if AmountInclVAT >= 0 then
            case DocumentTypePozitive of
                DocumentTypePozitive::Order:
                    RetailSalesDocMgt.SetDocumentTypeOrder();
                DocumentTypePozitive::Invoice:
                    RetailSalesDocMgt.SetDocumentTypeInvoice();
                DocumentTypePozitive::Quote:
                    RetailSalesDocMgt.SetDocumentTypeQuote();
                DocumentTypePozitive::Restrict:
                    Error(WrongPozitiveSignErr, DocumentTypeNegative);
            end
        else
            case DocumentTypeNegative of
                DocumentTypeNegative::CreditMemo:
                    RetailSalesDocMgt.SetDocumentTypeCreditMemo();
                DocumentTypeNegative::ReturnOrder:
                    RetailSalesDocMgt.SetDocumentTypeReturnOrder();
                DocumentTypeNegative::Restrict:
                    Error(WrongNegativeSignErr, DocumentTypePozitive);
            end;
    end;

    local procedure GetPrepaymentValue(var JSON: Codeunit "POS JSON Management"): Decimal
    begin
        //-NPR5.52 [352473]
        if JSON.GetBooleanParameter('PrepaymentDialog', true) then begin
          if JSON.GetBooleanParameter('PrepaymentInputIsAmount', true) then begin
            exit(GetNumpad(JSON, 'prepaymentAmount'));
          end else begin
            exit(GetNumpad(JSON, 'prepaymentPct'));
          end;
        end else
          exit(JSON.GetDecimalParameter('FixedPrepaymentValue', true));
        //+NPR5.52 [352473]
    end;

    local procedure HandlePrepayment(POSSession: Codeunit "POS Session";RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";PrepaymentValue: Decimal;PrepaymentIsAmount: Boolean;Print: Boolean;Send: Boolean;Pdf2Nav: Boolean;PreviousSalePOS: Record "Sale POS")
    var
        Success: Boolean;
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
    begin
        //An error after sale end, before front end sync, is not allowed.
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        if not SalesHeader.Find then
            exit;

        Commit;
        asserterror
        begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.Validate("Customer Type", PreviousSalePOS."Customer Type");
            SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();

        //-NPR5.52 [352473]
          RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentValue, Print, Send, Pdf2Nav, true, PrepaymentIsAmount);
        //+NPR5.52 [352473]

            POSSession.RequestRefreshData();
            Commit;
            Success := true;
            Error('');
        end;

        if not Success then
            Message(ERR_PREPAY, GetLastErrorText);
    end;

    local procedure HandlePayAndPost(POSSession: Codeunit "POS Session";RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";Print: Boolean;PreviousSalePOS: Record "Sale POS";Pdf2Nav: Boolean;Send: Boolean)
    var
        Success: Boolean;
        SalesHeader: Record "Sales Header";
        POSSale: Codeunit "POS Sale";
        SalePOS: Record "Sale POS";
        RetailSalesDocImpMgt: Codeunit "Retail Sales Doc. Imp. Mgt.";
    begin
        //An error after sale end, before front end sync, is not allowed.
        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);
        if not SalesHeader.Find then
            exit;

        Commit;
        asserterror
        begin
            POSSession.GetSale(POSSale);
            POSSale.GetCurrentSale(SalePOS);
            SalePOS.Validate("Customer Type", PreviousSalePOS."Customer Type");
            SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
            SalePOS.Modify(true);
            POSSale.RefreshCurrent();

        //-NPR5.52 [352473]
          RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, Pdf2Nav, Send, true);
        //+NPR5.52 [352473]

            POSSession.RequestRefreshData();
            Commit;
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
        FormCode.CreateSalesHeader(SalePOS, TempSalesHeader);
        if not POSCheckCrLimit.SalesHeaderPOSCheck(TempSalesHeader) then
            Error('');
    end;

    local procedure SaleLinesExists(SalePOS: Record "Sale POS"): Boolean
    var
        SaleLinePOS: Record "Sale Line POS";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(not SaleLinePOS.IsEmpty);
    end;

    local procedure SetPricesInclVAT(var SalePOS: Record "Sale POS";var JSON: Codeunit "POS JSON Management")
    begin
        //-NPR5.52 [352473]
        if JSON.GetBooleanParameter('ForcePricesInclVAT', true) and (not SalePOS."Prices Including VAT") then begin
          SalePOS.Validate("Prices Including VAT", true);
          SalePOS.Modify(true);
        end;
        //+NPR5.52 [352473]
    end;

    local procedure SetReference(var SalePOS: Record "Sale POS"; var JSON: Codeunit "POS JSON Management")
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

    local procedure GetInput(JSON: Codeunit "POS JSON Management"; Path: Text): Text
    begin
        JSON.SetScope('/', true);
        if (not JSON.SetScope('$' + Path, false)) then
            exit('');

        exit(JSON.GetString('input', true));
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
        //-NPR5.52 [352473]
          'PrepaymentDialog' : Caption := CaptionPrepaymentDlg;
          'FixedPrepaymentValue' : Caption := CaptionFixedPrepaymentValue;
        //+NPR5.52 [352473]
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
        //-NPR5.52 [352473]
          'PrintPayAndPostDocument' : Caption := DescPrintPayAndPost;
        //+NPR5.52 [352473]
            //-NPR5.51 [357277]
            'SaveLinesOnPOSEntry':
                Caption := CaptionSaveLinesOnPOSEntry;
        //+NPR5.51 [357277]
        //-NPR5.52 [352473]
          'ForcePricesInclVAT' : Caption := CaptionForcePricesInclVAT;
          'PrepaymentInputIsAmount' : Caption := CaptionPrepayIsAmount;
          'SetSend' : Caption := CaptionSetSend;
          'SendPrepaymentDocument' : Caption := CaptionSendPrepayDoc;
          'Pdf2NavPrepaymentDocument' : Caption := CaptionPdf2NavPrepayDoc;
          'SendPayAndPostDocument' : Caption := CaptionSendPayAndPost;
          'Pdf2NavPayAndPostDocument' : Caption := CaptionPdf2NavPayAndPost;
        //+NPR5.52 [352473]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', false, false)]
    procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
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
            'PrepaymentPctDialog':
                Caption := DescPrepaymentDlg;
            'FixedPrepaymentPct':
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
            'PrintPayAndPostInvoice':
                Caption := DescPrintPayAndPost;
            //-NPR5.51 [357277]
            'SaveLinesOnPOSEntry':
                Caption := DescSaveLinesOnPOSEntry;
            //+NPR5.51 [357277]
        //-NPR5.52 [352473]
          'ForcePricesInclVAT' : Caption := DescForcePricesInclVAT;
          'PrepaymentInputIsAmount' : Caption := DescPrepayIsAmount;
          'SetSend' : Caption := DescSetSend;
          'SendPrepaymentDocument' : Caption := DescSendPrepayDoc;
          'Pdf2NavPrepaymentDocument' : Caption := DescPdf2NavPrepayDoc;
          'SendPayAndPostDocument' : Caption := DescSendPayAndPost;
          'Pdf2NavPayAndPostDocument' : Caption := DescPdf2NavPayAndPost;
        //+NPR5.52 [352473]
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value"; var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
            exit;

        case POSParameterValue.Name of
            //-NPR5.51 [361811]
            // 'SetDocumentType' : Caption := OptionDocType;
            // 'SetNegBalDocumentType' : Caption := OptionDocType;
            'SetDocumentType':
                Caption := OptionDocTypePozitive;
            'SetNegBalDocumentType':
                Caption := OptionDocTypeNegative;
            //+NPR5.51 [361811]
        end;
    end;
}

