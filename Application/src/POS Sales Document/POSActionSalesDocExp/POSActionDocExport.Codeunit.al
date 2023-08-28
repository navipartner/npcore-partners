codeunit 6150859 "NPR POS Action: Doc. Export" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Export current sale to a standard NAV sales document';
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
        CaptionTransferTaxSetup: Label 'Transfer Tax Setup';
        CaptionAutoResrvSalesLine: Label 'Auto Reserve Sales Line';
        CaptionSendPdf2Nav: Label 'Send PDF2NAV';
        CaptionRetailPrint: Label 'Retail Confirmation Print';
        CaptionOpenDoc: Label 'Open Document';
        CaptionCheckCustCredit: Label 'Check Customer Credit Error';
        CaptionWarningCustCredit: Label 'Check Customer Credit Warning';
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
        DescTransferPostingSetup: Label 'Transfer general, VAT and specific posting groups from POS sale to exported document. Please note that deactivating this can lead to differencies in VAT calculation between the POS sale and the exported document.';
        DescTransferDim: Label 'Transfer dimensions from sale to exported document';
        DescTransferTaxSetup: Label 'Transfer tax setup from sale to exported document';
        DescAutoResrvSalesLine: Label 'Automatically reserve items on exported document';
        DescSendPdf2Nav: Label 'Handle document output via PDF2NAV';
        DescRetailPrint: Label 'Print receipt confirming exported document';
        DescOpenDoc: Label 'Open sales document page after export is done';
        DescCheckCustCredit: Label 'Check the customer credit before export is done, returns an error';
        DescWarningCheckCustCredit: Label 'Check the customer credit before export is done, returns a warning';
        CaptionPrintPrepaymentDoc: Label 'Print Prepayment Document';
        DescPrintPrepaymentDoc: Label 'Print standard prepayment document after posting.';
        CaptionPayAndPostNext: Label 'Pay&Post Immediately';
        CaptionPrintPayAndPost: Label ' PrintPay&Post';
        DescPayAndPostNext: Label 'Insert a full payment line for the exported document in the next sale.';
        DescPrintPayAndPost: Label 'Print the document of the Pay&Post operation in next sale.';
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
        OptionUseLocationFrom: Label '<Undefined>,POS Store,POS Sale,Specific Location';
        CaptionUseSpecLocationCode: Label 'Use Specific Location Code';
        DescUseSpecLocationCode: Label 'Select location code to be used for sales document, if parameter ''Use Location From'' is set to ''Specific Location''';
        CaptionSendICOrderConfirmation: Label 'Send IC Order Cnfmn.';
        DescSendICOrderConfirmation: Label 'Send intercompany order confirmation immediately after sales document has been created. ';
        CaptionPaymentMethodCode: Label 'Payment Method Code';
        DescPaymentMethodCode: Label 'Select Payment Method Code to be used for sales document';
        CaptionCustomerTableView: Label 'Customer Table View';
        CaptionCustomerLookupPage: Label 'Customer Lookup Page';
        DescCustomerTableView: Label 'Pre-filtered customer list';
        DescCustomerLookupPage: Label 'Custom customer lookup page';
        CaptionEnforceCustomerFilter: Label 'Enforce Customer Filter';
        DescEnforceCustomerFilter: Label 'Enforce that the selected customer is within the defined filter in "CustomerTableView"';
        CaptionPaymentMethodCodeFrom: Label 'Use Payment Method Code From';
        DescPaymentMethodCodeFrom: Label 'Select source of payment method code for sales document';
        CaptionPrintProformaInvoice: Label 'Print Pro Forma Invoice';
        OptionNameSetDocumentType: Label 'Order,Invoice,Quote,Restrict,BlanketOrder', Locked = true;
        OptionCptSetDocumentType: Label 'Order,Invoice,Quote,Restrict,Blanket Order';
        OptionNameSetNegBalDocumentType: Label 'ReturnOrder,CreditMemo,Restrict', Locked = true;
        OptionCptSetNegBalDocumentType: Label 'Return Order,Credit Memo,Restrict';
        OptionNameUseLocationFrom: Label '<Undefined>,POS Store,POS Sale,SpecificLocation', Locked = true;
        OptionNamePaymentMethCodeFrom: Label 'Sales Header Default,Force Blank Code,Specific Payment Method Code', Locked = true;
        OptionCptPaymentMethCodeFrom: Label 'Sales Header Default,Force Blank Code,Specific Payment Method Code';
        CaptioneGroupCodesEnabled: Label 'Group Codes Enabled';
        DescGroupCodesEnabled: Label 'Enables the use of group codes in the sales document export';
        CaptionGroupCode: Label 'Group Code';
        DescGroupCode: Label 'Specifies the group code that is going to be assigned to the exported sales document';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('SetAsk', false, CaptionAskOperation, DescAskOperation);
        WorkflowConfig.AddBooleanParameter('SetPrint', false, CaptionPrint, DescPrint);
        WorkflowConfig.AddBooleanParameter('SetInvoice', false, CaptionInvoice, DescInvoice);
        WorkflowConfig.AddBooleanParameter('SetReceive', false, CaptionReceive, DescReceive);
        WorkflowConfig.AddBooleanParameter('SetShip', false, CaptionShip, DescShip);
        WorkflowConfig.AddOptionParameter('SetDocumentType',
                                        OptionNameSetDocumentType,
#pragma warning disable AA0139
                                        SelectStr(1, OptionNameSetDocumentType),
# pragma warning restore
                                        CaptionDocType,
                                        DescDocType,
                                        OptionCptSetDocumentType);
        WorkflowConfig.AddOptionParameter('SetNegBalDocumentType',
                                        OptionNameSetNegBalDocumentType,
#pragma warning disable AA0139
                                        SelectStr(1, OptionNameSetNegBalDocumentType),
# pragma warning restore
                                        CaptionNegDocType,
                                        DescNegDocType,
                                        OptionCptSetNegBalDocumentType);
        WorkflowConfig.AddBooleanParameter('SetShowCreationMessage', false, CaptionCreationMsg, DescCreationMsg);
        WorkflowConfig.AddBooleanParameter('SetTransferPostingSetup', true, CaptionTransferPostingSetup, DescTransferPostingSetup);
        WorkflowConfig.AddBooleanParameter('SetAutoReserveSalesLine', false, CaptionAutoResrvSalesLine, DescAutoResrvSalesLine);
        WorkflowConfig.AddBooleanParameter('SetSendPdf2Nav', false, CaptionSendPdf2Nav, DescSendPdf2Nav);
        WorkflowConfig.AddBooleanParameter('AskExtDocNo', false, CaptionAskExtDocNo, DescAskExtDocNo);
        WorkflowConfig.AddBooleanParameter('AskAttention', false, CaptionAskAttention, DescAskAttention);
        WorkflowConfig.AddBooleanParameter('AskYourRef', false, CaptionAskYourRef, DescAskYourRef);
        WorkflowConfig.AddBooleanParameter('SetTransferSalesperson', true, CaptionTransferSalesperson, DescTransferSalesperson);
        WorkflowConfig.AddBooleanParameter('SetTransferDimensions', true, CaptionTransferDim, DescTransferDim);
        WorkflowConfig.AddBooleanParameter('SetTransferTaxSetup', true, CaptionTransferTaxSetup, DescTransferTaxSetup);
        WorkflowConfig.AddBooleanParameter('ConfirmExport', true, CaptionConfirm, DescConfirm);
        WorkflowConfig.AddBooleanParameter('PrepaymentDialog', false, CaptionPrepaymentDlg, DescPrepaymentDlg);
        WorkflowConfig.AddDecimalParameter('FixedPrepaymentValue', 0, CaptionFixedPrepaymentValue, DescFixedPrepaymentPct);
        WorkflowConfig.AddBooleanParameter('PrintPrepaymentDocument', false, CaptionPrintPrepaymentDoc, DescPrintPrepaymentDoc);
        WorkflowConfig.AddBooleanParameter('PrintRetailConfirmation', true, CaptionRetailPrint, DescRetailPrint);
        WorkflowConfig.AddBooleanParameter('CheckCustomerCredit', false, CaptionCheckCustCredit, DescCheckCustCredit);
        WorkflowConfig.AddBooleanParameter('CheckCustomerCreditWarning', true, CaptionWarningCustCredit, DescWarningCheckCustCredit);
        WorkflowConfig.AddBooleanParameter('OpenDocumentAfterExport', false, CaptionOpenDoc, DescOpenDoc);
        WorkflowConfig.AddBooleanParameter('PayAndPostInNextSale', false, CaptionPayAndPostNext, DescPayAndPostNext);
        WorkflowConfig.AddBooleanParameter('PrintPayAndPostDocument', false, CaptionPrintPayAndPost, DescPrintPayAndPost);
        WorkflowConfig.AddBooleanParameter('ForcePricesInclVAT', false, CaptionForcePricesInclVAT, DescForcePricesInclVAT);
        WorkflowConfig.AddBooleanParameter('PrepaymentInputIsAmount', false, CaptionPrepayIsAmount, DescPrepayIsAmount);
        WorkflowConfig.AddBooleanParameter('SetSend', false, CaptionSetSend, DescSetSend);
        WorkflowConfig.AddBooleanParameter('SendPrepaymentDocument', false, CaptionSendPrepayDoc, DescSendPrepayDoc);
        WorkflowConfig.AddBooleanParameter('Pdf2NavPrepaymentDocument', false, CaptionPdf2NavPrepayDoc, DescPdf2NavPrepayDoc);
        WorkflowConfig.AddBooleanParameter('SendPayAndPostDocument', false, CaptionSendPayAndPost, DescSendPayAndPost);
        WorkflowConfig.AddBooleanParameter('Pdf2NavPayAndPostDocument', false, CaptionPdf2NavPayAndPost, DescPdf2NavPayAndPost);
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, CaptionSelectCustomer, DescSelectCustomer);
        WorkflowConfig.AddBooleanParameter('ShowDocumentPaymentMenu', false, CaptionDocPaymentMenu, DescDocPaymentMenu);
        WorkflowConfig.AddBooleanParameter('BlockEmptySale', true, CaptionBlockEmptySale, DescBlockEmptySale);
        WorkflowConfig.AddOptionParameter('UseLocationFrom',
                        OptionNameUseLocationFrom,
#pragma warning disable AA0139
                        SelectStr(2, OptionNameUseLocationFrom),
# pragma warning restore
                        CaptionUseLocationFrom,
                        DescUseLocationFrom,
                        OptionUseLocationFrom);
        WorkflowConfig.AddTextParameter('UseSpecLocationCode', '', CaptionUseSpecLocationCode, DescUseSpecLocationCode);
        WorkflowConfig.AddBooleanParameter('SendICOrderConfirmation', false, CaptionSendICOrderConfirmation, DescSendICOrderConfirmation);
        WorkflowConfig.AddOptionParameter('PaymentMethodCodeFrom',
                        OptionNamePaymentMethCodeFrom,
#pragma warning disable AA0139
                        SelectStr(1, OptionNamePaymentMethCodeFrom),
# pragma warning restore
                        CaptionPaymentMethodCodeFrom,
                        DescPaymentMethodCodeFrom,
                        OptionCptPaymentMethCodeFrom);
        WorkflowConfig.AddTextParameter('PaymentMethodCode', '', CaptionPaymentMethodCode, DescPaymentMethodCode);
        WorkflowConfig.AddTextParameter('CustomerTableView', '', CaptionCustomerTableView, DescCustomerTableView);
        WorkflowConfig.AddIntegerParameter('CustomerLookupPage', 0, CaptionCustomerLookupPage, DescCustomerLookupPage);
        WorkflowConfig.AddBooleanParameter('EnforceCustomerFilter', false, CaptionEnforceCustomerFilter, DescEnforceCustomerFilter);
        WorkflowConfig.AddBooleanParameter('SetPrintProformaInvoice', false, CaptionPrintProformaInvoice, CaptionPrintProformaInvoice);
        WorkflowConfig.AddBooleanParameter('GroupCodesEnabled', false, CaptioneGroupCodesEnabled, DescGroupCodesEnabled);
        WorkflowConfig.AddTextParameter('GroupCode', '', CaptionGroupCode, DescGroupCode);
        //labels
        WorkflowConfig.AddLabel('ExtDocNo', TextExtDocNoLabel);
        WorkflowConfig.AddLabel('Attention', TextAttentionLabel);
        WorkflowConfig.AddLabel('YourRef', TextYourRefLabel);
        WorkflowConfig.AddLabel('confirmTitle', TextConfirmTitle);
        WorkflowConfig.AddLabel('confirmLead', TextConfirmLead);
        WorkflowConfig.AddLabel('prepaymentDialogTitle', TextPrepaymentTitle);
        WorkflowConfig.AddLabel('prepaymentPctLead', TextPrepaymentPctLead);
        WorkflowConfig.AddLabel('prepaymentAmountLead', TextPrepaymentAmountLead);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'preparePreWorkflows':
                FrontEnd.WorkflowResponse(PreparePreWorkflows(Context, Sale));
            'exportDocument':
                FrontEnd.WorkflowResponse(ExportSalesDoc(Context, Sale, SaleLine));
            'endSaleAndDocumentPayment':
                FrontEnd.WorkflowResponse(DocumentPayment(Context, Sale));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDocExport.js###
'let main=async({workflow:r,parameters:t,captions:e})=>{debugger;let y,n,o,i;if(t.ConfirmExport&&!await popup.confirm(e.confirmLead,e.confirmTitle)||t.AskExtDocNo&&(o=await popup.input(e.ExtDocNo),o===null)||t.AskAttention&&(n=await popup.input(e.Attention),n===null)||t.AskYourRef&&(i=await popup.input(e.YourRef),i===null))return;const{preWorkflows:u}=await r.respond("preparePreWorkflows");if(u)for(const f of Object.entries(u)){let[m,c]=f;m&&await r.run(m,{parameters:c})}const{createdSalesHeader:l,createdSalesHeaderDocumentType:d,additionalParameters:p}=await r.respond("exportDocument",{extDocNo:o,attention:n,yourref:i});let a;p.prompt_prepayment?p.prepayment_is_amount?a=await popup.numpad(e.prepaymentAmountLead,e.prepaymentDialogTitle):a=await popup.numpad(e.prepaymentPctLead,e.prepaymentDialogTitle):a=t.FixedPrepaymentValue,await r.respond("endSaleAndDocumentPayment",{additionalParameters:p,createdSalesHeader:l,createdSalesHeaderDocumentType:d,prepaymentAmt:a})};'
        )
    end;

    local procedure ExportSalesDoc(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject;
    var
        RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.";
        SalePOS: Record "NPR POS Sale";
        SalesHeader: Record "Sales Header";
        CustomerTableView: Text;
    begin
        Sale.GetCurrentSale(SalePOS);
        SalePOS.TestField("Customer No.");

        SetReference(SalePOS, Context);
        SetPricesInclVAT(SalePOS, Context);
        SetGroupCode(SalePOS,
                     Context);

        SetParameters(SalePOS, SaleLine, Context, RetailSalesDocMgt);
        ValidateSale(SalePOS, RetailSalesDocMgt, Context, CustomerTableView);

        Sale.RefreshCurrent();
        RetailSalesDocMgt.ProcessPOSSale(Sale);

        Commit();

        RetailSalesDocMgt.GetCreatedSalesHeader(SalesHeader);

        Response.Add('createdSalesHeader', SalesHeader."No.");
        Response.Add('createdSalesHeaderDocumentType', SalesHeader."Document Type".AsInteger());
        SetPaymentParameters(Context, SalesHeader, Response);
    end;

    local procedure DocumentPayment(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"): JsonObject;
    var
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
        SalePOS: Record "NPR POS Sale";
        CreatedSalesHeader: Text;
        POSSession: Codeunit "NPR POS Session";
        POSActionDocExportB: Codeunit "NPR POS Action: Doc. ExportB";
        CreatedDocTypeIndex: Integer;
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
        POSSalesDocumentPost: Enum "NPR POS Sales Document Post";
    begin
        Sale.GetCurrentSale(SalePOS);
        CreatedSalesHeader := Context.GetString('createdSalesHeader');
        CreatedDocTypeIndex := Context.GetInteger('createdSalesHeaderDocumentType');
        if SalesHeader.Get(CreatedDocTypeIndex, CreatedSalesHeader) then;
        PrepaymentValue := Context.GetDecimal('prepaymentAmt');

        ReadAdditionalParameters(Context, PrepaymentIsAmount, PayAndPost, FullPosting);

        PrepaymentPdf2Nav := Context.GetBooleanParameter('Pdf2NavPrepaymentDocument');
        PrepaymentSend := Context.GetBooleanParameter('SendPrepaymentDocument');
        PayAndPostPdf2Nav := Context.GetBooleanParameter('Pdf2NavPayAndPostDocument');
        PayAndPostSend := Context.GetBooleanParameter('SendPayAndPostDocument');
        PrintPrepayment := Context.GetBooleanParameter('PrintPrepaymentDocument');
        PayAndPostPrint := Context.GetBooleanParameter('PrintPayAndPostDocument');
        if PrepaymentValue > 0 then begin
            //End sale, auto start new sale, and insert prepayment line.
            POSSession.StartTransaction();
            POSSession.ChangeViewSale();
            POSSalesDocumentPost := POSAsyncPosting.GetPOSSalePostingMandatoryFlow(SalePOS."POS Store Code");
            POSActionDocExportB.HandlePrepayment(POSSession, SalesHeader, PrepaymentValue, PrepaymentIsAmount, PrintPrepayment, PrepaymentSend, PrepaymentPdf2Nav, POSSalesDocumentPost);
        end else
            if PayAndPost then begin
                //End sale, auto start new sale, and insert payment line.
                POSSession.StartTransaction();
                POSSession.ChangeViewSale();
                POSSalesDocumentPost := POSAsyncPosting.GetPOSSalePostingMandatoryFlow(SalePOS."POS Store Code");
                POSActionDocExportB.HandlePayAndPost(POSSession, SalesHeader, PayAndPostPrint, PayAndPostPdf2Nav, PayAndPostSend, FullPosting, POSSalesDocumentPost);
            end else begin
                //End sale
                Sale.SelectViewForEndOfSale();
            end;
    end;

    local procedure PreparePreWorkflows(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") Response: JsonObject
    begin
        Response.Add('preWorkflows', AddPreWorkflowsToRun(Context, Sale));
    end;

    local procedure AddPreWorkflowsToRun(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale") PreWorkflows: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        NPRPOSActionDocExpEvents: Codeunit "NPR POS Action Doc Exp Events";
    begin
        Sale.GetCurrentSale(SalePOS);
        if SalePOS."Customer No." = '' then
            AddCustomerWorkflow(Context, PreWorkflows);
        NPRPOSActionDocExpEvents.OnAddPreWorkflowsToRun(Context, SalePOS, PreWorkflows);
    end;

    local procedure AddCustomerWorkflow(Context: Codeunit "NPR POS JSON Helper"; var PreWorkflows: JsonObject)
    var
        ActionParameters: JsonObject;
        CustomerTableView: Text;
        CustomerLookupPage: Integer;
    begin
        if not Context.GetBooleanParameter('SelectCustomer') then
            exit;

        CustomerTableView := Context.GetStringParameter('CustomerTableView');
        CustomerLookupPage := Context.GetIntegerParameter('CustomerLookupPage');

        ActionParameters.Add('CustomerTableView', CustomerTableView);
        ActionParameters.Add('CustomerLookupPage', CustomerLookupPage);
        ActionParameters.Add('CheckCustomerBalance', false);
        ActionParameters.Add('CustomerNo', '');
        ActionParameters.Add('Operation', 'Attach');

        PreWorkflows.Add('CUSTOMER_SELECT', ActionParameters);
    end;

    local procedure SetPaymentParameters(Context: Codeunit "NPR POS JSON Helper"; SalesHeader: Record "Sales Header"; var Response: JsonObject)
    var
        Choice: Integer;
        RetailSalesDocImpMgt: Codeunit "NPR Sales Doc. Imp. Mgt.";
        PAYMENT_OPTION: Label 'No Payment,Prepayment Percent,Prepayment Amount,Pay & Post';
        PAYMENT_OPTION_SPLIT: Label 'No Payment,Prepayment Percent,Prepayment Amount,Split Pay & Post,Full Pay & Post';
        PAYMENT_OPTION_DESC: Label 'Select document payment';
        Parameters: JsonObject;
    begin
        if SalesHeader.Get(SalesHeader."Document Type", SalesHeader."No.") then begin //If document has been posted/deleted, we cannot pay parts of it.
            if Context.GetBooleanParameter('ShowDocumentPaymentMenu') then begin
                if RetailSalesDocImpMgt.DocumentIsSetToFullPosting(SalesHeader) then
                    Choice := StrMenu(PAYMENT_OPTION, 1, PAYMENT_OPTION_DESC)
                else
                    Choice := StrMenu(PAYMENT_OPTION_SPLIT, 1, PAYMENT_OPTION_DESC);

                case Choice of
                    0,  //Cancelled
                    1: //None
                        begin
                            Parameters.Add('prompt_prepayment', false);
                            Parameters.Add('prepayment_is_amount', false);
                            Parameters.Add('pay_and_post', false);
                            Parameters.Add('full_posting', false);
                        end;
                    2: //Prepayment Percent
                        begin
                            Parameters.Add('prompt_prepayment', true);
                            Parameters.Add('prepayment_is_amount', false);
                            Parameters.Add('pay_and_post', false);
                            Parameters.Add('full_posting', false);
                        end;
                    3: //Prepayment Amount
                        begin
                            Parameters.Add('prompt_prepayment', true);
                            Parameters.Add('prepayment_is_amount', true);
                            Parameters.Add('pay_and_post', false);
                            Parameters.Add('full_posting', false);
                        end;
                    4: //Payment + post
                        begin
                            Parameters.Add('prompt_prepayment', false);
                            Parameters.Add('prepayment_is_amount', false);
                            Parameters.Add('pay_and_post', true);
                            Parameters.Add('full_posting', false);
                        end;
                    5: //Full payment + post
                        begin
                            Parameters.Add('prompt_prepayment', false);
                            Parameters.Add('prepayment_is_amount', false);
                            Parameters.Add('pay_and_post', true);
                            Parameters.Add('full_posting', true);
                        end;
                end;
            end else begin
                Parameters.Add('pay_and_post', Context.GetBooleanParameter('PayAndPostInNextSale'));
                Parameters.Add('prompt_prepayment', Context.GetBooleanParameter('PrepaymentDialog'));
                Parameters.Add('prepayment_is_amount', Context.GetBooleanParameter('PrepaymentInputIsAmount'));
                Parameters.Add('full_posting', false);
            end;
        end else begin
            Parameters.Add('prompt_prepayment', false);
            Parameters.Add('prepayment_is_amount', false);
            Parameters.Add('pay_and_post', false);
            Parameters.Add('full_posting', false);
        end;
        Response.Add('additionalParameters', Parameters);
    end;

    local procedure ValidateSale(var SalePOS: Record "NPR POS Sale"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt."; Context: Codeunit "NPR POS JSON Helper"; CustomerTableView: Text)
    var
        POSActionDocExportB: Codeunit "NPR POS Action: Doc. ExportB";
    begin
        if Context.GetBooleanParameter('BlockEmptySale') then
            POSActionDocExportB.SaleLinesExists(SalePOS);

        if CustomerTableView <> '' then
            if Context.GetBooleanParameter('EnforceCustomerFilter') then
                POSActionDocExportB.CheckCustomer(SalePOS, CustomerTableView);

        RetailSalesDocMgt.TestSalePOS(SalePOS);
    end;

    local procedure SetParameters(SalePOS: Record "NPR POS Sale"; var POSSaleLine: Codeunit "NPR POS Sale Line"; Context: Codeunit "NPR POS JSON Helper"; var RetailSalesDocMgt: Codeunit "NPR Sales Doc. Exp. Mgt.")
    var
        POSActionDocExportB: Codeunit "NPR POS Action: Doc. ExportB";
        POSAsyncPosting: Codeunit "NPR POS Async. Posting Mgt.";
        AmountExclVAT: Decimal;
        VATAmount: Decimal;
        AmountInclVAT: Decimal;
        DocumentTypePozitive: Option "Order",Invoice,Quote,Restrict,"Blanket Order";
        DocumentTypeNegative: Option ReturnOrder,CreditMemo,Restrict;
        LocationSource: Option Undefined,"POS Store","POS Sale",SpecificLocation;
        PaymentMethodCodeSource: Option "Sales Header Default","Force Blank Code","Specific Payment Method Code";
        SpecificLocationCode: Code[10];
        PaymentMethodCode: Code[10];
    begin
        RetailSalesDocMgt.SetAsk(Context.GetBooleanParameter('SetAsk'));
        RetailSalesDocMgt.SetPrint(Context.GetBooleanParameter('SetPrint'));
        RetailSalesDocMgt.SetInvoice(Context.GetBooleanParameter('SetInvoice'));
        RetailSalesDocMgt.SetReceive(Context.GetBooleanParameter('SetReceive'));
        RetailSalesDocMgt.SetShip(Context.GetBooleanParameter('SetShip'));
        RetailSalesDocMgt.SetSendPostedPdf2Nav(Context.GetBooleanParameter('SetSendPdf2Nav'));
        RetailSalesDocMgt.SetRetailPrint(Context.GetBooleanParameter('PrintRetailConfirmation'));
        RetailSalesDocMgt.SetAutoReserveSalesLine(Context.GetBooleanParameter('SetAutoReserveSalesLine'));
        RetailSalesDocMgt.SetTransferSalesPerson(Context.GetBooleanParameter('SetTransferSalesperson'));
        RetailSalesDocMgt.SetTransferPostingsetup(Context.GetBooleanParameter('SetTransferPostingSetup'));
        RetailSalesDocMgt.SetTransferDimensions(Context.GetBooleanParameter('SetTransferDimensions'));
        RetailSalesDocMgt.SetTransferTaxSetup(Context.GetBooleanParameter('SetTransferTaxSetup'));
        RetailSalesDocMgt.SetOpenSalesDocAfterExport(Context.GetBooleanParameter('OpenDocumentAfterExport'));
        RetailSalesDocMgt.SetSendDocument(Context.GetBooleanParameter('SetSend'));
        RetailSalesDocMgt.SetSendICOrderConf(Context.GetBooleanParameter('SendICOrderConfirmation'));
        RetailSalesDocMgt.SetCustomerCreditCheck(Context.GetBooleanParameter('CheckCustomerCredit'));
        RetailSalesDocMgt.SetWarningCustomerCreditCheck(Context.GetBooleanParameter('CheckCustomerCreditWarning'));
        RetailSalesDocMgt.SetPrintProformaInvoice(Context.GetBooleanParameter('SetPrintProformaInvoice'));

        RetailSalesDocMgt.SetAsyncPosting(POSAsyncPosting.AsyncPostingEnabled(SalePOS."POS Store Code"));

        if Context.GetBooleanParameter('SetShowCreationMessage') then
            RetailSalesDocMgt.SetShowCreationMessage();

        POSSaleLine.CalculateBalance(AmountExclVAT, VATAmount, AmountInclVAT);

        DocumentTypePozitive := Context.GetIntegerParameter('SetDocumentType');
        DocumentTypeNegative := Context.GetIntegerParameter('SetNegBalDocumentType');
        POSActionDocExportB.SetDocumentType(AmountInclVAT, RetailSalesDocMgt, DocumentTypePozitive, DocumentTypeNegative);

        LocationSource := Context.GetIntegerParameter('UseLocationFrom');
        SpecificLocationCode := CopyStr(Context.GetStringParameter('UseSpecLocationCode'), 1, MaxStrLen(SpecificLocationCode));
        POSActionDocExportB.SetLocationSource(RetailSalesDocMgt, LocationSource, SpecificLocationCode);

        PaymentMethodCodeSource := Context.GetIntegerParameter('PaymentMethodCodeFrom');
        PaymentMethodCode := CopyStr(Context.GetStringParameter('PaymentMethodCode'), 1, MaxStrLen(PaymentMethodCode));
        POSActionDocExportB.SetPaymentMethodCode(RetailSalesDocMgt, PaymentMethodCodeSource, PaymentMethodCode);
    end;

    local procedure SetPricesInclVAT(var SalePOS: Record "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper")
    begin
        if Context.GetBooleanParameter('ForcePricesInclVAT') and (not SalePOS."Prices Including VAT") then begin
            SalePOS.Validate("Prices Including VAT", true);
            SalePOS.Modify(true);
        end;
    end;

    local procedure SetReference(var SalePOS: Record "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper")
    var
        POSActionDocExportB: Codeunit "NPR POS Action: Doc. ExportB";
        ExtDocNo: Text;
        Attention: Text;
        YourRef: Text;
        AttentionValueLengthOverflowErr: Label 'The value entered in the Attention field exceeds the maximum allowed size of field %1. Reduce the entered value to %2 characters.', Comment = '%1=SalePOS.FieldCaption("Contact No.");%2=MaxStrLen(SalePOS."Contact No.")';
    begin
        if Context.GetString('extDocNo', ExtDocNo) then;
        if Context.GetString('attention', Attention) then;
        if Context.GetString('yourref', YourRef) then;

        if StrLen(Attention) > MaxStrLen(SalePOS."Contact No.") then
            Error(AttentionValueLengthOverflowErr, SalePOS.FieldCaption("Contact No."), MaxStrLen(SalePOS."Contact No."));

# pragma warning disable AA0139
        if POSActionDocExportB.SetInputs(ExtDocNo, Attention, YourRef, SalePOS) then
# pragma warning restore
            SalePOS.Modify(true);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', false, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        Location: Record Location;
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        NPRGroupCodeUtils: Codeunit "NPR Group Code Utils";
        FilterBuilder: FilterPageBuilder;
    begin
        if POSParameterValue."Action Code" <> 'SALES_DOC_EXP' then
            exit;

        case POSParameterValue.Name of
            'UseSpecLocationCode':
                begin
                    Location.FilterGroup(2);
                    Location.SetRange("Use As In-Transit", false);
                    Location.FilterGroup(0);
                    if Page.RunModal(0, Location) = Action::LookupOK then
                        POSParameterValue.Value := Location.Code;
                end;
            'PaymentMethodCode':
                begin
                    if Page.RunModal(0, PaymentMethod) = Action::LookupOK then
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
            'GroupCode':
                NPRGroupCodeUtils.LookUpGroupCodeValue(POSParameterValue.Value);

        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', false, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        Location: Record Location;
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        NPRGroupCode: Record "NPR Group Code";
        PageId: Integer;
        PageMetadata: Record "Page Metadata";
    begin
        if POSParameterValue."Action Code" <> 'SALES_DOC_EXP' then
            exit;

        case POSParameterValue.Name of
            'UseSpecLocationCode':
                begin
                    if POSParameterValue.Value = '' then
                        exit;
                    Location.SetRange("Use As In-Transit", false);
                    Location.SetFilter(Code, CopyStr(POSParameterValue.Value, 1, MaxStrLen(Location.Code)));
                    Location.FindFirst();
                end;
            'PaymentMethodCode':
                begin
                    if POSParameterValue.Value <> '' then
                        PaymentMethod.Get(POSParameterValue.Value);
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
            'GroupCode':
                begin
                    if POSParameterValue.Value <> '' then begin
                        NPRGroupCode.Get(POSParameterValue.Value);
                    end;
                end;
        end;
    end;



    local procedure ReadAdditionalParameters(Context: Codeunit "NPR POS JSON Helper"; var PrepaymentIsAmount: Boolean; var PayAndPost: Boolean; var FullPosting: Boolean)
    var
        JSObj: JsonObject;
        ContextObj: JsonObject;
        JToken: JsonToken;
    begin
        Context.GetJObject(ContextObj);
        if ContextObj.Get('additionalParameters', JToken) then begin
            JSObj := JToken.AsObject();
            if JSObj.Get('prepayment_is_amount', JToken) then
                PrepaymentIsAmount := JToken.AsValue().AsBoolean();
            if JSObj.Get('pay_and_post', JToken) then
                PayAndPost := JToken.AsValue().AsBoolean();
            if JSObj.Get('full_posting', JToken) then
                FullPosting := JToken.AsValue().AsBoolean();
        end;
    end;
    #region UnpackGroupCodeSetup
    local procedure UnpackGroupCodeSetup(Context: Codeunit "NPR POS JSON Helper";
                                         var GroupCodesEnabled: Boolean;
                                         var GroupCode: Code[20])
    begin
        GroupCodesEnabled := Context.GetBooleanParameter('GroupCodesEnabled');
#pragma warning disable AA0139
        GroupCode := Context.GetStringParameter('GroupCode');
#pragma warning restore
    end;
    #endregion UnpackGroupCodeSetup

    #region SelectGroupCode
    local procedure SelectGroupCode(GroupCodesEnabled: Boolean;
                                       var GroupCode: Code[20])
    var
        NPRGroupCode: Record "NPR Group Code";
    begin

        if not GroupCodesEnabled then begin
            GroupCode := '';
            exit;
        end;

        if GroupCode <> '' then
            exit;

        Clear(NPRGroupCode);

        If Page.RunModal(0, NPRGroupCode) <> Action::LookupOK then
            exit;

        GroupCode := NPRGroupCode.Code;

    end;
    #endregion SelectGroupCode

    #region SetGroupCode
    local procedure SetGroupCode(var SalePOS: Record "NPR POS Sale";
                                    Context: Codeunit "NPR POS JSON Helper")
    var
        GroupCodesEnabled: Boolean;
        GroupCode: Code[20];
    begin
        UnpackGroupCodeSetup(Context,
                             GroupCodesEnabled,
                             GroupCode);

        SetGroupCode(SalePOS,
                     GroupCodesEnabled,
                     GroupCode);

    end;
    #endregion SetGroupCode


    #region SetGroupCode
    internal procedure SetGroupCode(var SalePOS: Record "NPR POS Sale";
                                    GroupCodesEnabled: Boolean;
                                    GroupCode: Code[20])
    begin
        SelectGroupCode(GroupCodesEnabled,
                        GroupCode);

        UpdateGroupCodeInSalesTransaction(SalePOS,
                                          GroupCode);

    end;
    #endregion SetGroupCode


    #region UpdateGroupCodeInSalesTransaction
    local procedure UpdateGroupCodeInSalesTransaction(var SalePOS: Record "NPR POS Sale";
                                                         GroupCode: Code[20])
    begin
        if SalePOS."Group Code" = GroupCode then
            exit;

        SalePOS.Validate("Group Code", GroupCode);
        SalePOS.Modify(true);
    end;
    #endregion UpdateGroupCodeInSalesTransaction
}
