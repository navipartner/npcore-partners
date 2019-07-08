codeunit 6150859 "POS Action - Doc. Export"
{
    // NPR5.50/MMV /20180319 CASE 300557 New action, based on CU 6150814


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Export current sale to a standard NAV sales document';
        ERRDOCTYPE: Label 'Wrong Document Type. Document Type is set to %1. It must be one of %2, %3, %4, %5 or %6';
        ERRORDERTYPE: Label 'Wrong Order Type. Order Type is set to %1. It must be one of %2, %3, %4.';
        ERRCUSTNOTSET: Label 'Customer must be set before working with Sales Document.';
        ERRNOSALELINES: Label 'There are no sale lines to export';
        ERR_PREPAY: Label 'Sale was exported correctly but prepayment in new sale failed: %1';
        ERR_PAY: Label 'Sale was exported correctly but payment in new sale failed: %1';
        TextExtDocNoLabel: Label 'Enter External Document No.:';
        TextAttentionLabel: Label 'Enter Attention:';
        TextConfirmTitle: Label 'Confirm action';
        TextConfirmLead: Label 'Export active sale to NAV sales document?';
        TextPrepaymentPctTitle: Label 'Prepayment';
        TextPrepaymentPctLead: Label 'Please specify prepayment % to be paid after export';
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
        CaptionPrepaymentDlg: Label 'Prompt Prepayment Percentage';
        CaptionFixedPrepaymentPct: Label 'Fixed Prepayment Percentage';
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
        OptionDocType: Label 'Order,Invoice,Return Order,Credit Memo';
        OptionOrderType: Label 'Not Set,Order,Lending';
        CaptionPrintPrepaymentDoc: Label 'Print Prepayment Document';
        DescPrintPrepaymentDoc: Label 'Print standard prepayment document after posting.';
        CaptionPayAndPostNext: Label 'Pay&Post Immediately';
        CaptionPrintPayAndPost: Label 'Pay&Post Print';
        DescPayAndPostNext: Label 'Insert a full payment line for the exported document in the next sale.';
        DescPrintPayAndPost: Label 'Print the standard document of the Pay&Post operation in next sale.';

    local procedure ActionCode(): Text
    begin
        exit ('SALES_DOC_EXP');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
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
            RegisterWorkflowStep('prepaymentPct', 'param.PrepaymentPctDialog && numpad(labels.prepaymentPctTitle, labels.prepaymentPctLead, param.FixedPrepaymentPct).cancel (abort);');
            RegisterWorkflowStep('exportDocument', 'respond();');
            RegisterWorkflow(false);

            RegisterBooleanParameter('SetAsk', false);
            RegisterBooleanParameter('SetPrint', false);
            RegisterBooleanParameter('SetInvoice', false);
            RegisterBooleanParameter('SetReceive', false);
            RegisterBooleanParameter('SetShip', false);
            RegisterOptionParameter('SetDocumentType', 'Order,Invoice,ReturnOrder,CreditMemo,Quote', 'Order');
            RegisterOptionParameter('SetNegBalDocumentType', 'Order,Invoice,ReturnOrder,CreditMemo,Quote', 'ReturnOrder');
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
            RegisterBooleanParameter('PrepaymentPctDialog', false);
            RegisterDecimalParameter('FixedPrepaymentPct', 0);
            RegisterBooleanParameter('PrintPrepaymentDocument', false);
            RegisterBooleanParameter('PrintRetailConfirmation', true);
            RegisterBooleanParameter('CheckCustomerCredit', true);
            RegisterBooleanParameter('OpenDocumentAfterExport', false);
            RegisterBooleanParameter('PayAndPostInNextSale', false);
            RegisterBooleanParameter('PrintPayAndPostInvoice', false);
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
        Captions.AddActionCaption (ActionCode, 'prepaymentPctTitle', TextPrepaymentPctTitle);
        Captions.AddActionCaption (ActionCode, 'prepaymentPctLead', TextPrepaymentPctLead);
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet npNetJObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;

        ExportToDocument(Context, POSSession,FrontEnd);
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
        PrepaymentPct: Decimal;
        SalesHeader: Record "Sales Header";
        PrintPrepayment: Boolean;
        PayAndPost: Boolean;
        PrintPayAndPost: Boolean;
    begin
        POSSession.GetSale(POSSale);
        POSSession.GetSaleLine(POSSaleLine);
        POSSale.GetCurrentSale(SalePOS);

        JSON.InitializeJObjectParser(Context,FrontEnd);

        if not SelectCustomer(SalePOS) then
          SalePOS.TestField("Customer No.");
        if JSON.GetBooleanParameter('CheckCustomerCredit', true) then
          CheckCustCredit(SalePOS);
        SetReference(SalePOS, JSON);
        SetParameters(POSSaleLine, JSON, RetailSalesDocMgt);
        ValidateSale(SalePOS, RetailSalesDocMgt);

        PrepaymentPct := GetPrepaymentPct(JSON);
        PrintPrepayment := JSON.GetBooleanParameter('PrintPrepaymentDocument', true);
        PayAndPost := JSON.GetBooleanParameter('PayAndPostInNextSale', true);
        PrintPayAndPost := JSON.GetBooleanParameter('PrintPayAndPostInvoice', true);

        RetailSalesDocMgt.ProcessPOSSale(SalePOS);

        if PrepaymentPct > 0 then begin
          //End sale, auto start new sale, and insert prepayment line.
          POSSession.StartTransaction();
          POSSession.ChangeViewSale();
          HandlePrepayment(POSSession, RetailSalesDocMgt, PrepaymentPct, PrintPrepayment, SalePOS);
        end else if PayAndPost then begin
          //End sale, auto start new sale, and insert payment line.
          POSSession.StartTransaction();
          POSSession.ChangeViewSale();
          HandlePayAndPost(POSSession, RetailSalesDocMgt, PrintPayAndPost, SalePOS);
        end else
          //End sale
          POSSale.SelectViewForEndOfSale(POSSession)
    end;

    local procedure ValidateSale(var SalePOS: Record "Sale POS";var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
    begin
        if not SaleLinesExists(SalePOS) then
          Error (ERRNOSALELINES);

        RetailSalesDocMgt.TestSalePOS(SalePOS);
    end;

    local procedure SelectCustomer(var SalePOS: Record "Sale POS"): Boolean
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
        exit(true);
    end;

    local procedure SetParameters(var POSSaleLine: Codeunit "POS Sale Line";var JSON: Codeunit "POS JSON Management";var RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.")
    var
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        DocumentType: Option "Order",Invoice,ReturnOrder,CreditMemo,Quote;
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
        RetailSalesDocMgt.SetWriteInAuditRoll(true);

        if JSON.GetBooleanParameter('SetShowCreationMessage', true) then
          RetailSalesDocMgt.SetShowCreationMessage();

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);
        if AmountInclVAT >= 0 then
          DocumentType := JSON.GetIntegerParameter('SetDocumentType', true)
        else
          DocumentType := JSON.GetIntegerParameter('SetNegBalDocumentType', true);

        case DocumentType of
          DocumentType::Order :
              RetailSalesDocMgt.SetDocumentTypeOrder();
          DocumentType::Invoice :
              RetailSalesDocMgt.SetDocumentTypeInvoice();
          DocumentType::CreditMemo :
              RetailSalesDocMgt.SetDocumentTypeCreditMemo();
          DocumentType::ReturnOrder :
              RetailSalesDocMgt.SetDocumentTypeReturnOrder();
          DocumentType::Quote :
              RetailSalesDocMgt.SetDocumentTypeQuote();
          else
            Error(ERRDOCTYPE, Format(DocumentType), Format(DocumentType::Order), Format(DocumentType::Invoice), Format(DocumentType::CreditMemo), Format(DocumentType::ReturnOrder), Format(DocumentType::Quote) );
        end;
    end;

    local procedure GetPrepaymentPct(var JSON: Codeunit "POS JSON Management"): Decimal
    begin
        if JSON.GetBooleanParameter('PrepaymentPctDialog', true) then
          exit(GetNumpad(JSON, 'prepaymentPct'))
        else
          exit(JSON.GetDecimalParameter('FixedPrepaymentPct', true));
    end;

    local procedure HandlePrepayment(POSSession: Codeunit "POS Session";RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";PrepaymentPct: Decimal;PrintPrepaymentInvoice: Boolean;PreviousSalePOS: Record "Sale POS")
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
        asserterror begin
          POSSession.GetSale(POSSale);
          POSSale.GetCurrentSale(SalePOS);
          SalePOS.Validate("Customer Type", PreviousSalePOS."Customer Type");
          SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
          SalePOS.Modify(true);
          POSSale.RefreshCurrent();

          RetailSalesDocMgt.CreatePrepaymentLine(POSSession, SalesHeader, PrepaymentPct, PrintPrepaymentInvoice, true);

          POSSession.RequestRefreshData();
          Commit;
          Success := true;
          Error('');
        end;

        if not Success then
          Message(ERR_PREPAY, GetLastErrorText);
    end;

    local procedure HandlePayAndPost(POSSession: Codeunit "POS Session";RetailSalesDocMgt: Codeunit "Retail Sales Doc. Mgt.";Print: Boolean;PreviousSalePOS: Record "Sale POS")
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
        asserterror begin
          POSSession.GetSale(POSSale);
          POSSale.GetCurrentSale(SalePOS);
          SalePOS.Validate("Customer Type", PreviousSalePOS."Customer Type");
          SalePOS.Validate("Customer No.", PreviousSalePOS."Customer No.");
          SalePOS.Modify(true);
          POSSale.RefreshCurrent();

          RetailSalesDocImpMgt.SalesDocumentAmountToPOS(POSSession, SalesHeader, true, true, true, Print, true);

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
          'PrepaymentPctDialog' : Caption := CaptionPrepaymentDlg;
          'FixedPrepaymentPct' : Caption := CaptionFixedPrepaymentPct;
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
          'PrepaymentPctDialog' : Caption := DescPrepaymentDlg;
          'FixedPrepaymentPct' : Caption := DescFixedPrepaymentPct;
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
          'PrintPayAndPostInvoice' : Caption := DescPrintPayAndPost;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterOptionStringCaption', '', false, false)]
    procedure OnGetParameterOptionStringCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'SetDocumentType' : Caption := OptionDocType;
          'SetNegBalDocumentType' : Caption := OptionDocType;
        end;
    end;
}

