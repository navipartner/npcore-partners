codeunit 6059876 "NPR POS Action: Reverse Sale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Creates POS Sales Line from document and exports POS Sales Line to new document';
        ParamSelectCust_CptLbl: Label 'Select Customer';
        ParamSelectCust_DescLbl: Label 'Enable/Disable customer selection';
        ParamSalesDocViewString_CptLbl: Label 'Posted Sales Invoice View String';
        ParamSalesDocViewString_DescLbl: Label 'Pre-filtered Posted Sales Invoice View';
        ParamLocationFrom_CptLbl: Label 'Location From';
        ParamLocationFrom_DescLbl: Label 'Pre-filtered location option';
        ParamLocationFrom_OptionsLbl: Label 'POS Store,Location Filter Parameter', Locked = true;
        ParamLocationFrom_OptionsCptLbl: Label 'POS Store, Location Filter Parameter';
        ParamLocation_CptLbl: Label 'Location Filter';
        ParamLocation_DescLbl: Label 'Pre-filtered location';
        ParamConfirmDiscAmt_CptLbl: Label 'Confirm Invoice Discount Amount';
        ParamConfirmDiscAmt_DescLbl: Label 'Enable/Disable Invoice Discount Amount confirmation';
        ParamEnableSalesPersonFromInv_CptLbl: Label 'SalesPerson From Invoice';
        ParamEnableSalesPersonFromInv_DescLbl: Label 'Enable/Disable SalesPerson From Invoice';
        ParamNegativeValues_CptLbl: Label 'Negative Values';
        ParamNegativeValues_DescLbl: Label 'Reverse values from Posted Sales Invoice';
        ParamCopyAppliesToInvoice_CptLbl: Label 'Copy Invoice No. to Imported from Invoice No.';
        ParamCopyAppliesToInvoice_DescLbl: Label 'Enable/Disable copy Invoice No. to Imported from Invoice No.';
        ParamShowMsg_CptLbl: Label 'Show Import Message';
        ParamShowMsg_DescLbl: Label 'Specifies if POS Lines creation message will be shown';
        ParamPost_CptLbl: Label 'Post Document';
        ParamPost_DescLbl: Label 'Specifies if export Document will be posted';
        ParamShowExpMsg_CptLbl: Label 'Show Message';
        ParamShowExpMsg_DescLbl: Label 'Specifies if Export Document creation message will be shown';
        ParamAsk_CptLbl: Label 'Ask Doc. Operation';
        ParamAsk_DescLbl: Label 'Ask user to select posting type';
        ParamSetPrint_CptLbl: Label 'Standard Print';
        ParamSetPrint_DescLbl: Label 'Print standard NAV report after export & posting is done';
        ParamReceive_CptLbl: Label 'Receive';
        ParamReceive_DescLbl: Label 'Receive exported document';
        ParamShip_CptLbl: Label 'Receive';
        ParamShip_DescLbl: Label 'Receive exported document';
        ParamTransferPostingSetup_CptLbl: Label 'Transfer Posting Setup';
        ParamTransferPostingSetup_DescLbl: Label 'Transfer posting setup from sale to exported document';
        ParamSendPDF2NAV_CptLbl: Label 'Send PDF2NAV';
        ParamSendPDF2NAV_DescLbl: Label 'Handle document output via PDF2NAV';
        ParamAskEctDocNo_CptLbl: Label 'Prompt External Doc. No.';
        ParamAskEctDocNo_DescLbl: Label 'Ask user to input external document number';
        ParamAskAttention_CptLbl: Label 'Prompt Attention';
        ParamAskAttention_DescLbl: Label 'Ask user to input attention';
        ParamAskYourRef_CptLbl: Label 'Prompt Your Reference';
        ParamAskYourRef_DescLbl: Label 'Ask user to input ''Your Reference''';
        ParamTransferSalesperson_CptLbl: Label 'Transfer Salesperson';
        ParamTransferSalesperson_DescLbl: Label 'Transfer salesperson from sale to exported document';
        ParamTransferDim_CptLbl: Label 'Transfer Dimensions';
        ParamTransferDim_DescLbl: Label 'Transfer dimensions from sale to exported document';
        ParamTransferTaxSetup_CptLbl: Label 'Transfer Tax Setup';
        ParamTransferTaxSetup_DescLbl: Label 'Transfer tax setup from sale to exported document';
        ParamConfirmExport_CptLbl: Label 'Confirm Export';
        ParamConfirmExport_DescLbl: Label 'Ask user to confirm before any export is performed';
        ParamPromptPrepayment_CptLbl: Label 'Prompt Prepayment';
        ParamPromptPrepayment_DescLbl: Label 'Ask user for prepayment percentage. Will be paid in new sale.';
        ParamPrintPrepaymentDoc_CptLbl: Label 'Print Prepayment Document';
        ParamPrintPrepaymentDoc_DescLbl: Label 'Print standard prepayment document after posting.';
        ParamRetailConfPrint_CptLbl: Label 'Retail Confirmation Print';
        ParamRetailConfPrint_DescLbl: Label 'Print receipt confirming exported document';
        ParamCheckCustomerCredit_CptLbl: Label 'Check Customer Credit Error';
        ParamCheckCustomerCredit_DescLbl: Label 'Check the customer credit before export is done, returns an error';
        ParamWarningCustCredit_CptLbl: Label 'Check Customer Credit Warning';
        ParamWarningCustCredit_DescLbl: Label 'Check the customer credit before export is done, returns a warning';
        ParamOpenDoc_CptLbl: Label 'Open Document';
        ParamOpenDoc_DescLbl: Label 'Open sales document page after export is done';
        ParamPayAndPostNext_CptLbl: Label 'Pay&Post Immediately';
        ParamPayAndPostNext_DescLbl: Label 'Insert a full payment line for the exported document in the next sale.';
        ParamPrintPayAndPost_CptLbl: Label 'Print Pay And Post Document';
        ParamPrintPayAndPost_DescLbl: Label 'Print the document of the Pay&Post operation in next sale.';
        ParamForcePricesInclVAT_CptLbl: Label 'Force Prices Including VAT';
        ParamForcePricesInclVAT_DescLbl: Label 'Force Prices Including VAT on exported document';
        ParamPrepayIsAmount_CptLbl: Label 'Prepayment Amount Input';
        ParamPrepayIsAmount_DescLbl: Label 'Input prepayment amount instead of percent in prompt';
        ParamSetSend_CptLbl: Label 'Send Document';
        ParamSetSend_DescLbl: Label 'Output NAV report after export & posting, via document sending profiles';
        ParamSendPrepayDoc_CptLbl: Label 'Send Prepayment Document';
        ParamSendPrepayDoc_DescLbl: Label 'Output prepayment NAV report via document sending profiles, after payment in new sale';
        ParamPdf2NavPrepayDoc_CptLbl: Label 'Prepayment PDF2NAV';
        ParamPdf2NavPrepayDoc_DescLbl: Label 'Output prepayment NAV report via PDF2NAV, after payment in new sale';
        ParamSendPayAndPost_CptLbl: Label 'Pay&Post Send Document';
        ParamSendPayAndPost_DescLbl: Label 'Output NAV report via document sending profiles, after payment in new sale';
        ParamPdf2NavPayAndPost_CptLbl: Label 'Pay&Post PDF2NAV';
        ParamPdf2NavPayAndPost_DescLbl: Label 'Output NAV report via PDF2NAV, after payment in new sale';
        ParamBlockEmptySale_CptLbl: Label 'Block Empty Sale';
        ParamBlockEmptySale_DescLbl: Label 'Block creation of document if sale is empty';
        ParamDocPaymentMenu_CptLbl: Label 'Show Payment Menu';
        ParamDocPaymentMenu_DescLbl: Label 'Prompt with different payment methods for handling in new sale, after export is done.';
        ParamUseSpecLocationCode_CptLbl: Label 'Use Specific Location Code';
        ParamUseSpecLocationCode_DescLbl: Label 'Select location code to be used for sales document, if parameter ''%1'' is set to ''%2''', Comment = 'Select location code to be used for sales document, if parameter ''Use Location From'' is set to ''Specific Location''';
        ParamSendICOrderConfirmation_CptLbl: Label 'Send IC Order Cnfmn.';
        ParamSendICOrderConfirmation_DescLbl: Label 'Send intercompany order confirmation immediately after sales document has been created. ';
        ParamEnforceCustomerFilter_CptLbl: Label 'Enforce Customer Filter';
        ParamEnforceCustomerFilter_DescLbl: Label 'Enforce that the selected customer is within the defined filter in "CustomerTableView"';
        ParamFixedPrepaymentValue_CptLbl: Label 'Fixed Prepayment Value';
        ParamFixedPrepaymentPct_DescLbl: Label 'Prepayment percentage to use either silently or as dialog default value.';
        ParamPaymentMethodCode_CptLbl: Label 'Payment Method Code';
        ParamPaymentMethodCode_DescLbl: Label 'Select Payment Method Code to be used for sales document';
        ParamPaymentMethodCodeFromOptins_CptLbl: Label 'Sales Header Default,Force Blank Code,Specific Payment Method Code';
        ParamPaymentMethodCodeFrom_OptLbl: Label 'Sales Header Default,Force Blank Code,Specific Payment Method Code', Locked = true;
        ParamPaymentMethodCodeFrom_CptLbl: Label 'Use Payment Method Code From';
        ParamPaymentMethodCodeFrom_DescLbl: Label 'Select source of payment method code for sales document';
        ParamSetDocumentType_CptLbl: Label 'Document Type';
        ParamSetDocumentType_DescLbl: Label 'Sales Document to create on positive sales balance';
        ParamSetDocumentTypeOptions_CptLbl: Label 'Order,Invoice,Quote,Restrict';
        ParamSetDocumentType_OptLbl: Label 'Order,Invoice,Quote,Restrict', Locked = true;
        ParamSetNegDocumentType_CptLbl: Label 'Negative Document Type';
        ParamSetNegDocumentType_DescLbl: Label 'Sales Document to create on negative sales balance';
        ParamSetNegDocumentTypeOptions_Lbl: Label 'ReturnOrder,CreditMemo,Restrict', Locked = true;
        ParamSetNegDocumentTypeOptions_CptLbl: Label 'Return Order,Credit Memo,Restrict';
        ParamProformaInv_CptLbl: Label 'Set Print Proforma Invoice';
        ParamProformaInv_DescLbl: Label 'Set Print Proforma Invoice for export document';
        TakePhotoLbl: Label 'Take photo';
        TakePhotoDesc: Label 'Specifies if the user has to insert photo.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('SelectCustomer', true, ParamSelectCust_CptLbl, ParamSelectCust_DescLbl);
        WorkflowConfig.AddTextParameter('SalesDocViewString', '', ParamSalesDocViewString_CptLbl, ParamSalesDocViewString_DescLbl);
        WorkflowConfig.AddOptionParameter('LocationFrom',
                                          ParamLocationFrom_OptionsLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamLocationFrom_OptionsLbl),
#pragma warning restore 
                                          ParamLocationFrom_CptLbl,
                                          ParamLocationFrom_DescLbl,
                                          ParamLocationFrom_OptionsCptLbl);
        WorkflowConfig.AddOptionParameter('PaymentMethodCodeFrom',
                                           ParamPaymentMethodCodeFrom_OptLbl,
#pragma warning disable AA0139
                                           SelectStr(1, ParamPaymentMethodCodeFrom_OptLbl),
#pragma warning restore 
                                           ParamPaymentMethodCodeFrom_CptLbl,
                                           ParamPaymentMethodCodeFrom_DescLbl,
                                           ParamPaymentMethodCodeFromOptins_CptLbl);
        WorkflowConfig.AddTextParameter('LocationFilter', '', ParamLocation_CptLbl, ParamLocation_DescLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmInvDiscAmt', false, ParamConfirmDiscAmt_CptLbl, ParamConfirmDiscAmt_DescLbl);
        WorkflowConfig.AddBooleanParameter('SalesPersonFromInv', false, ParamEnableSalesPersonFromInv_CptLbl, ParamEnableSalesPersonFromInv_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowImportMessage', false, ParamShowMsg_CptLbl, ParamShowMsg_DescLbl);
        WorkflowConfig.AddBooleanParameter('NegativeValues', false, ParamNegativeValues_CptLbl, ParamNegativeValues_DescLbl);
        WorkflowConfig.AddBooleanParameter('CopyAppliesToInvoice', false, ParamCopyAppliesToInvoice_CptLbl, ParamCopyAppliesToInvoice_DescLbl);
        WorkflowConfig.AddBooleanParameter('Post', false, ParamPost_CptLbl, ParamPost_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowExportMessage', false, ParamShowExpMsg_CptLbl, ParamShowExpMsg_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetAsk', false, ParamAsk_CptLbl, ParamAsk_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetPrint', false, ParamSetPrint_CptLbl, ParamSetPrint_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetReceive', false, ParamReceive_CptLbl, ParamReceive_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetShip', false, ParamShip_CptLbl, ParamShip_DescLbl);
        WorkflowConfig.AddOptionParameter('SetDocumentType',
                                           ParamSetDocumentType_OptLbl,
#pragma warning disable AA0139
                                           SelectStr(1, ParamSetDocumentType_OptLbl),
#pragma warning restore 
                                           ParamSetDocumentType_CptLbl,
                                           ParamSetDocumentType_DescLbl,
                                           ParamSetDocumentTypeOptions_CptLbl);
        WorkflowConfig.AddOptionParameter('SetNegBalDocumentType',
                                           ParamSetNegDocumentTypeOptions_Lbl,
#pragma warning disable AA0139
                                           SelectStr(1, ParamSetNegDocumentTypeOptions_Lbl),
#pragma warning restore 
                                           ParamSetNegDocumentType_CptLbl,
                                           ParamSetNegDocumentType_DescLbl,
                                           ParamSetNegDocumentTypeOptions_CptLbl);
        WorkflowConfig.AddBooleanParameter('SetTransferPostingSetup', true, ParamTransferPostingSetup_CptLbl, ParamTransferPostingSetup_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetSendPdf2Nav', false, ParamSendPDF2NAV_CptLbl, ParamSendPDF2NAV_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskExtDocNo', false, ParamAskEctDocNo_CptLbl, ParamAskEctDocNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskAttention', false, ParamAskAttention_CptLbl, ParamAskAttention_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskYourRef', false, ParamAskYourRef_CptLbl, ParamAskYourRef_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetTransferSalesperson', true, ParamTransferSalesperson_CptLbl, ParamTransferSalesperson_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetTransferDimensions', true, ParamTransferDim_CptLbl, ParamTransferDim_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetTransferTaxSetup', true, ParamTransferTaxSetup_CptLbl, ParamTransferTaxSetup_DescLbl);
        WorkflowConfig.AddBooleanParameter('ConfirmExport', true, ParamConfirmExport_CptLbl, ParamConfirmExport_DescLbl);
        WorkflowConfig.AddBooleanParameter('PrepaymentDialog', false, ParamPromptPrepayment_CptLbl, ParamPromptPrepayment_DescLbl);
        WorkflowConfig.AddDecimalParameter('FixedPrepaymentValue', 0, ParamFixedPrepaymentValue_CptLbl, ParamFixedPrepaymentPct_DescLbl);
        WorkflowConfig.AddBooleanParameter('PrintPrepaymentDocument', false, ParamPrintPrepaymentDoc_CptLbl, ParamPrintPrepaymentDoc_DescLbl);
        WorkflowConfig.AddBooleanParameter('PrintRetailConfirmation', true, ParamRetailConfPrint_CptLbl, ParamRetailConfPrint_DescLbl);
        WorkflowConfig.AddBooleanParameter('CheckCustomerCredit', false, ParamCheckCustomerCredit_CptLbl, ParamCheckCustomerCredit_DescLbl);
        WorkflowConfig.AddBooleanParameter('CheckCustomerCreditWarning', true, ParamWarningCustCredit_CptLbl, ParamWarningCustCredit_DescLbl);
        WorkflowConfig.AddBooleanParameter('OpenDocumentAfterExport', false, ParamOpenDoc_CptLbl, ParamOpenDoc_DescLbl);
        WorkflowConfig.AddBooleanParameter('PayAndPostInNextSale', false, ParamPayAndPostNext_CptLbl, ParamPayAndPostNext_DescLbl);
        WorkflowConfig.AddBooleanParameter('PrintPayAndPostDocument', false, ParamPrintPayAndPost_CptLbl, ParamPrintPayAndPost_DescLbl);
        WorkflowConfig.AddBooleanParameter('ForcePricesInclVAT', false, ParamForcePricesInclVAT_CptLbl, ParamForcePricesInclVAT_DescLbl);
        WorkflowConfig.AddBooleanParameter('PrepaymentInputIsAmount', false, ParamPrepayIsAmount_CptLbl, ParamPrepayIsAmount_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetSend', false, ParamSetSend_CptLbl, ParamSetSend_DescLbl);
        WorkflowConfig.AddBooleanParameter('SendPrepaymentDocument', false, ParamSendPrepayDoc_CptLbl, ParamSendPrepayDoc_DescLbl);
        WorkflowConfig.AddBooleanParameter('Pdf2NavPrepaymentDocument', false, ParamPdf2NavPrepayDoc_CptLbl, ParamPdf2NavPrepayDoc_DescLbl);
        WorkflowConfig.AddBooleanParameter('SendPayAndPostDocument', false, ParamSendPayAndPost_CptLbl, ParamSendPayAndPost_DescLbl);
        WorkflowConfig.AddBooleanParameter('Pdf2NavPayAndPostDocument', false, ParamPdf2NavPayAndPost_CptLbl, ParamPdf2NavPayAndPost_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowDocumentPaymentMenu', false, ParamDocPaymentMenu_CptLbl, ParamDocPaymentMenu_DescLbl);
        WorkflowConfig.AddBooleanParameter('BlockEmptySale', true, ParamBlockEmptySale_CptLbl, ParamBlockEmptySale_DescLbl);
        WorkflowConfig.AddTextParameter('UseSpecLocationCode', '', ParamUseSpecLocationCode_CptLbl, ParamUseSpecLocationCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('SendICOrderConfirmation', false, ParamSendICOrderConfirmation_CptLbl, ParamSendICOrderConfirmation_DescLbl);
        WorkflowConfig.AddTextParameter('PaymentMethodCode', '', ParamPaymentMethodCode_CptLbl, ParamPaymentMethodCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('EnforceCustomerFilter', false, ParamEnforceCustomerFilter_CptLbl, ParamEnforceCustomerFilter_DescLbl);
        WorkflowConfig.AddBooleanParameter('SetPrintProformaInvoice', false, ParamProformaInv_CptLbl, ParamProformaInv_DescLbl);
        WorkflowConfig.AddBooleanParameter(TakePhotoParLbl, false, TakePhotoLbl, TakePhotoDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case step of
            'import_sales_doc':
                FrontEnd.WorkflowResponse(ImportSalesDoc(Sale, Context));
            'export_SalesDoc':
                FrontEnd.WorkflowResponse(ExportSalesDoc(Sale, Context));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionReverseSale.js###
'let main=async({workflow:a})=>{const{parameters:e}=await a.respond("import_sales_doc");await a.run("IMPORT_POSTED_INV",{parameters:e});const{expParameters:t}=await a.respond("export_SalesDoc");await a.run("SALES_DOC_EXP",{parameters:t})};'
        )
    end;

    local procedure ImportSalesDoc(Sale: codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSAction: Record "NPR POS Action";
        POSActionTakePhotoB: Codeunit "NPR POS Action Take Photo B";
        SelectCustomer: Boolean;
        ConfirmInvDiscAmt: Boolean;
        LocationSource: Option "POS Store","Location Filter Parameter";
        LocationFilter: Text;
        SalesDocViewString: Text;
        SalesPersonFromInv: Boolean;
        NegativeValues: Boolean;
        AppliesToInvoice: Boolean;
        ShowMsg: Boolean;
        TransferDim: Boolean;
        Parameters: JsonObject;
    begin
        If not POSAction.Get('IMPORT_POSTED_INV') then
            exit;

        TakePhotoEnabled := Context.GetBooleanParameter(TakePhotoParLbl);
        if TakePhotoEnabled then
            POSActionTakePhotoB.TakePhoto(Sale);
        SelectCustomer := Context.GetBooleanParameter('SelectCustomer');
        SalesDocViewString := Context.GetStringParameter('SalesDocViewString');
        LocationSource := Context.GetIntegerParameter('LocationFrom');
        LocationFilter := Context.GetStringParameter('LocationFilter');
        SalesPersonFromInv := Context.GetBooleanParameter('SalesPersonFromInv');
        ConfirmInvDiscAmt := Context.GetBooleanParameter('ConfirmInvDiscAmt');
        NegativeValues := Context.GetBooleanParameter('NegativeValues');
        AppliesToInvoice := Context.GetBooleanParameter('CopyAppliesToInvoice');
        ShowMsg := Context.GetBooleanParameter('ShowImportMessage');
        TransferDim := Context.GetBooleanParameter('SetTransferDimensions');

        Parameters.Add('SelectCustomer', SelectCustomer);
        Parameters.Add('SalesDocViewString', SalesDocViewString);
        Parameters.Add('LocationFrom', LocationSource);
        Parameters.Add('LocationFilter', LocationFilter);
        Parameters.Add('SalesPersonFromInv', SalesPersonFromInv);
        Parameters.Add('ConfirmInvDiscAmt', ConfirmInvDiscAmt);
        Parameters.Add('NegativeValues', NegativeValues);
        Parameters.Add('CopyAppliesToInvoice', AppliesToInvoice);
        Parameters.Add('ShowMessage', ShowMsg);
        Parameters.Add('TransferDimensions', not TransferDim); //if TransferDimension from sale is set to false, then TransferDimensions from Imported document

        Response.Add('parameters', Parameters);
    end;

    local procedure ExportSalesDoc(Sale: codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper") Response: JsonObject;
    var
        POSAction: Record "NPR POS Action";
        POSActionTakePhotoB: Codeunit "NPR POS Action Take Photo B";
        Invoice: Boolean;
        ShowMsg: Boolean;
        NegBalDocType: Option ReturnOrder,CreditMemo,Restrict;
        Ask: Boolean;
        Print: Boolean;
        Receive: Boolean;
        Ship: Boolean;
        TransferPostingSetup: Boolean;
        SendPdf2Nav: Boolean;
        ExtDocNo: Boolean;
        Attention: Boolean;
        YouRef: Boolean;
        TransferSalesperson: Boolean;
        PrepaymentDialog: Boolean;
        ConfirmExport: Boolean;
        TransferTaxSetup: Boolean;
        TransferDimensions: Boolean;
        SendICOrderConfirmation: Boolean;
        BlockEmptySale: Boolean;
        ShowDocumentPaymentMenu: Boolean;
        Pdf2NavPayAndPostDocument: Boolean;
        SendPayAndPostDocument: Boolean;
        SetSend: Boolean;
        PrepaymentInputIsAmount: Boolean;
        ForcePricesInclVAT: Boolean;
        PrintPayAndPostDocument: Boolean;
        PayAndPostInNextSale: Boolean;
        OpenDocumentAfterExport: Boolean;
        CheckCustomerCreditWarning: Boolean;
        CheckCustomerCredit: Boolean;
        PrintRetailConfirmation: Boolean;
        PrintPrepaymentDocument: Boolean;
        Pdf2NavPrepaymentDocument: Boolean;
        SendPrepaymentDocument: Boolean;
        EnforceCustomerFilter: Boolean;
        PaymentMethodCode: Text;
        UseSpecLocationCode: Text;
        PaymentMethodCodeSource: Option "Sales Header Default","Force Blank Code","Specific Payment Method Code";
        DocumentTypePositive: Option "Order",Invoice,Quote,Restrict;
        LocationSource: Option Undefined,"POS Store","POS Sale",SpecificLocation;
        FixedPrepaymentValue: Decimal;
        Parameters: JsonObject;
        PrintProforma: Boolean;
    begin
        If not POSAction.Get('SALES_DOC_EXP') then
            exit;

        TakePhotoEnabled := Context.GetBooleanParameter(TakePhotoParLbl);
        if TakePhotoEnabled then
            POSActionTakePhotoB.CheckIfPhotoIsTaken(Sale);
        Invoice := Context.GetBooleanParameter('Post');
        ShowMsg := Context.GetBooleanParameter('ShowExportMessage');
        NegBalDocType := Context.GetIntegerParameter('SetNegBalDocumentType');
        ForcePricesInclVAT := Context.GetBooleanParameter('ForcePricesInclVAT');
        Ask := Context.GetBooleanParameter('SetAsk');
        Print := Context.GetBooleanParameter('SetPrint');
        Receive := Context.GetBooleanParameter('SetReceive');
        Ship := Context.GetBooleanParameter('SetShip');
        TransferPostingSetup := Context.GetBooleanParameter('SetTransferPostingSetup');
        SendPdf2Nav := Context.GetBooleanParameter('SetSendPdf2Nav');
        ExtDocNo := Context.GetBooleanParameter('AskExtDocNo');
        Attention := Context.GetBooleanParameter('AskAttention');
        TransferSalesperson := Context.GetBooleanParameter('SetTransferSalesperson');
        TransferDimensions := true; //always transfer dimensions (POS Sale or imported document)
        TransferTaxSetup := Context.GetBooleanParameter('SetTransferTaxSetup');
        ConfirmExport := Context.GetBooleanParameter('ConfirmExport');
        PrepaymentDialog := Context.GetBooleanParameter('PrepaymentDialog');
        SendICOrderConfirmation := Context.GetBooleanParameter('SendICOrderConfirmation');
        BlockEmptySale := Context.GetBooleanParameter('BlockEmptySale');
        ShowDocumentPaymentMenu := Context.GetBooleanParameter('ShowDocumentPaymentMenu');
        Pdf2NavPayAndPostDocument := Context.GetBooleanParameter('Pdf2NavPayAndPostDocument');
        SendPayAndPostDocument := Context.GetBooleanParameter('SendPayAndPostDocument');
        SetSend := Context.GetBooleanParameter('SetSend');
        PrepaymentInputIsAmount := Context.GetBooleanParameter('PrepaymentInputIsAmount');
        ForcePricesInclVAT := Context.GetBooleanParameter('ForcePricesInclVAT');
        PrintPayAndPostDocument := Context.GetBooleanParameter('PrintPayAndPostDocument');
        PayAndPostInNextSale := Context.GetBooleanParameter('PayAndPostInNextSale');
        OpenDocumentAfterExport := Context.GetBooleanParameter('OpenDocumentAfterExport');
        CheckCustomerCreditWarning := Context.GetBooleanParameter('CheckCustomerCreditWarning');
        CheckCustomerCredit := Context.GetBooleanParameter('CheckCustomerCredit');
        PrintRetailConfirmation := Context.GetBooleanParameter('PrintRetailConfirmation');
        PrintPrepaymentDocument := Context.GetBooleanParameter('PrintPrepaymentDocument');
        Pdf2NavPrepaymentDocument := Context.GetBooleanParameter('Pdf2NavPrepaymentDocument');
        SendPrepaymentDocument := Context.GetBooleanParameter('SendPrepaymentDocument');
        EnforceCustomerFilter := Context.GetBooleanParameter('EnforceCustomerFilter');
        PaymentMethodCode := Context.GetStringParameter('PaymentMethodCode');
        UseSpecLocationCode := Context.GetStringParameter('UseSpecLocationCode');
        PaymentMethodCodeSource := Context.GetIntegerParameter('PaymentMethodCodeFrom');
        DocumentTypePositive := Context.GetIntegerParameter('SetDocumentType');
        LocationSource := Context.GetIntegerParameter('LocationFrom');
        if LocationSource = LocationSource::Undefined then
            LocationSource := LocationSource::"POS Store";
        FixedPrepaymentValue := Context.GetDecimalParameter('FixedPrepaymentValue');
        PrintProforma := Context.GetBooleanParameter('SetPrintProformaInvoice');

        Parameters.Add('SelectCustomer', false);
        Parameters.Add('SetNegBalDocumentType', NegBalDocType);
        Parameters.Add('SetShowCreationMessage', ShowMsg);
        Parameters.Add('SetAsk', Ask);
        Parameters.Add('SetPrint', Print);
        Parameters.Add('SetInvoice', Invoice);
        Parameters.Add('SetReceive', Receive);
        Parameters.Add('SetShip', Ship);
        Parameters.Add('SetTransferPostingSetup', TransferPostingSetup);
        Parameters.Add('SetAutoReserveSalesLine', false);
        Parameters.Add('SetSendPdf2Nav', SendPdf2Nav);
        Parameters.Add('AskExtDocNo', ExtDocNo);
        Parameters.Add('AskAttention', Attention);
        Parameters.Add('AskYourRef', YouRef);
        Parameters.Add('SetTransferSalesperson', TransferSalesperson);
        Parameters.Add('SetTransferDimensions', TransferDimensions);
        Parameters.Add('SetTransferTaxSetup', TransferTaxSetup);
        Parameters.Add('ConfirmExport', ConfirmExport);
        Parameters.Add('PrepaymentDialog', PrepaymentDialog);
        Parameters.Add('FixedPrepaymentValue', FixedPrepaymentValue);
        Parameters.Add('PrintPrepaymentDocument', PrintPrepaymentDocument);
        Parameters.Add('PrintRetailConfirmation', PrintRetailConfirmation);
        Parameters.Add('CheckCustomerCredit', CheckCustomerCredit);
        Parameters.Add('CheckCustomerCreditWarning', CheckCustomerCreditWarning);
        Parameters.Add('OpenDocumentAfterExport', OpenDocumentAfterExport);
        Parameters.Add('PayAndPostInNextSale', PayAndPostInNextSale);
        Parameters.Add('PrintPayAndPostDocument', PrintPayAndPostDocument);
        Parameters.Add('ForcePricesInclVAT', ForcePricesInclVAT);
        Parameters.Add('PrepaymentInputIsAmount', PrepaymentInputIsAmount);
        Parameters.Add('SetSend', SetSend);
        Parameters.Add('SendPrepaymentDocument', SendPrepaymentDocument);
        Parameters.Add('Pdf2NavPrepaymentDocument', Pdf2NavPrepaymentDocument);
        Parameters.Add('SendPayAndPostDocument', SendPayAndPostDocument);
        Parameters.Add('Pdf2NavPayAndPostDocument', Pdf2NavPayAndPostDocument);
        Parameters.Add('ShowDocumentPaymentMenu', ShowDocumentPaymentMenu);
        Parameters.Add('BlockEmptySale', BlockEmptySale);
        Parameters.Add('UseLocationFrom', LocationSource);
        Parameters.Add('UseSpecLocationCode', UseSpecLocationCode);
        Parameters.Add('SendICOrderConfirmation', SendICOrderConfirmation);
        Parameters.Add('PaymentMethodCodeFrom', PaymentMethodCodeSource);
        Parameters.Add('PaymentMethodCode', PaymentMethodCode);
        Parameters.Add('CustomerTableView', '');
        Parameters.Add('CustomerLookupPage', 0);
        Parameters.Add('EnforceCustomerFilter', EnforceCustomerFilter);
        Parameters.Add('SetDocumentType', DocumentTypePositive);
        Parameters.Add('SetPrintProformaInvoice', PrintProforma);

        Response.Add('expParameters', Parameters);
    end;

    var
        TakePhotoEnabled: Boolean;
        TakePhotoParLbl: Label 'TakePhoto', Locked = true;
}
