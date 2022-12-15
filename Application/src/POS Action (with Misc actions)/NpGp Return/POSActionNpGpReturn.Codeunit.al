codeunit 6151169 "NPR POS Action: NpGp Return" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActionNpGpReturnB: Codeunit "NPR POS Action: NpGp Return B";

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Return item based on its global cross reference number';
        TitleCaption: Label 'Return Item by Reference';
        RefNoPromptCaption: Label 'Cross Reference No.';
        ParamShowFullSale_CptLbl: Label 'Show Full Sale';
        ParamShowFullSale_DescLbl: Label 'Enable/Disable popup widows with Sale details';
        ParamReferenceBarCode_CptLbl: Label 'Reference Barcode';
        ParamReferenceBarCode_DescCpt: Label 'Specifies the predefined Reference Barcode';
        ParamExpReturnOrder_CptLbl: Label 'Export Return Order';
        ParamExpReturnOrder_DescLbl: Label 'Enable/Disable Export Return Order';
        ParamShowReturnOrd_CptLbl: Label 'Show Return Order';
        ParamShowReturnOrd_DescLbl: Label 'Enable/Disable Show Return Order';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', TitleCaption);
        WorkflowConfig.AddLabel('refprompt', RefNoPromptCaption);

        WorkflowConfig.AddBooleanParameter('ShowFullSale', false, ParamShowFullSale_CptLbl, ParamShowFullSale_DescLbl);
        WorkflowConfig.AddTextParameter('ReferenceBarcode', '', ParamReferenceBarCode_CptLBl, ParamReferenceBarCode_DescCpt);
        WorkflowConfig.AddBooleanParameter('ExportReturnOrd', false, ParamExpReturnOrder_CptLbl, ParamExpReturnOrder_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowReturnOrd', false, ParamShowReturnOrd_CptLbl, ParamShowReturnOrd_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'PromptForReason':
                FrontEnd.WorkflowResponse(SelectReturnReason());
            'handle':
                HandleReq(Context);
            'ExportReturnOrder':
                ExportSalesDoc(Context, FrontEnd);

        end;
    end;

    local procedure ExportSalesDoc(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAction: Record "NPR POS Action";
        Invoice: Boolean;
        NegBalDocType: Option ReturnOrder,CreditMemo,Restrict;
        ForcePricesIncVAT: Boolean;
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
        PrintProforma: Boolean;
    begin
        If not POSAction.Get('SALES_DOC_EXP') then
            exit;

        Invoice := false;
        NegBalDocType := NegBalDocType::ReturnOrder;
        ForcePricesIncVAT := false;
        Ask := false;
        Print := false;
        Receive := false;
        Ship := false;
        TransferPostingSetup := false;
        SendPdf2Nav := false;
        ExtDocNo := false;
        Attention := false;
        TransferSalesperson := false;
        TransferDimensions := true; //always transfer dimensions (POS Sale or imported document)
        TransferTaxSetup := false;
        ConfirmExport := true;
        PrepaymentDialog := false;
        SendICOrderConfirmation := false;
        BlockEmptySale := false;
        ShowDocumentPaymentMenu := false;
        Pdf2NavPayAndPostDocument := false;
        SendPayAndPostDocument := false;
        SetSend := false;
        PrepaymentInputIsAmount := false;
        ForcePricesInclVAT := false;
        PrintPayAndPostDocument := false;
        PayAndPostInNextSale := false;
        OpenDocumentAfterExport := Context.GetBooleanParameter('ShowReturnOrd');
        CheckCustomerCreditWarning := false;
        CheckCustomerCredit := false;
        PrintRetailConfirmation := false;
        PrintPrepaymentDocument := false;
        Pdf2NavPrepaymentDocument := false;
        SendPrepaymentDocument := false;
        EnforceCustomerFilter := false;
        PaymentMethodCode := '';
        UseSpecLocationCode := '';
        PaymentMethodCodeSource := PaymentMethodCodeSource::"Sales Header Default";
        DocumentTypePositive := DocumentTypePositive::Order;
        LocationSource := LocationSource::"POS Store";
        FixedPrepaymentValue := 0;
        PrintProforma := false;

        POSAction.SetWorkflowInvocationParameterUnsafe('SelectCustomer', false);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetNegBalDocumentType', NegBalDocType);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetShowCreationMessage', true);
        POSAction.SetWorkflowInvocationParameterUnsafe('ForcePricesInclVAT', ForcePricesIncVAT);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetAsk', Ask);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetPrint', Print);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetInvoice', Invoice);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetReceive', Receive);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetShip', Ship);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetTransferPostingSetup', TransferPostingSetup);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetAutoReserveSalesLine', false);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetSendPdf2Nav', SendPdf2Nav);
        POSAction.SetWorkflowInvocationParameterUnsafe('AskExtDocNo', ExtDocNo);
        POSAction.SetWorkflowInvocationParameterUnsafe('AskAttention', Attention);
        POSAction.SetWorkflowInvocationParameterUnsafe('AskYourRef', YouRef);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetTransferSalesperson', TransferSalesperson);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetTransferDimensions', TransferDimensions);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetTransferTaxSetup', TransferTaxSetup);
        POSAction.SetWorkflowInvocationParameterUnsafe('ConfirmExport', ConfirmExport);
        POSAction.SetWorkflowInvocationParameterUnsafe('PrepaymentDialog', PrepaymentDialog);
        POSAction.SetWorkflowInvocationParameterUnsafe('FixedPrepaymentValue', FixedPrepaymentValue);
        POSAction.SetWorkflowInvocationParameterUnsafe('PrintPrepaymentDocument', PrintPrepaymentDocument);
        POSAction.SetWorkflowInvocationParameterUnsafe('PrintRetailConfirmation', PrintRetailConfirmation);
        POSAction.SetWorkflowInvocationParameterUnsafe('CheckCustomerCredit', CheckCustomerCredit);
        POSAction.SetWorkflowInvocationParameterUnsafe('CheckCustomerCreditWarning', CheckCustomerCreditWarning);
        POSAction.SetWorkflowInvocationParameterUnsafe('OpenDocumentAfterExport', OpenDocumentAfterExport);
        POSAction.SetWorkflowInvocationParameterUnsafe('PayAndPostInNextSale', PayAndPostInNextSale);
        POSAction.SetWorkflowInvocationParameterUnsafe('PrintPayAndPostDocument', PrintPayAndPostDocument);
        POSAction.SetWorkflowInvocationParameterUnsafe('ForcePricesInclVAT', ForcePricesInclVAT);
        POSAction.SetWorkflowInvocationParameterUnsafe('PrepaymentInputIsAmount', PrepaymentInputIsAmount);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetSend', SetSend);
        POSAction.SetWorkflowInvocationParameterUnsafe('SendPrepaymentDocument', SendPrepaymentDocument);
        POSAction.SetWorkflowInvocationParameterUnsafe('Pdf2NavPrepaymentDocument', Pdf2NavPrepaymentDocument);
        POSAction.SetWorkflowInvocationParameterUnsafe('SendPayAndPostDocument', SendPayAndPostDocument);
        POSAction.SetWorkflowInvocationParameterUnsafe('Pdf2NavPayAndPostDocument', Pdf2NavPayAndPostDocument);
        POSAction.SetWorkflowInvocationParameterUnsafe('SelectCustomer', false);
        POSAction.SetWorkflowInvocationParameterUnsafe('ShowDocumentPaymentMenu', ShowDocumentPaymentMenu);
        POSAction.SetWorkflowInvocationParameterUnsafe('BlockEmptySale', BlockEmptySale);
        POSAction.SetWorkflowInvocationParameterUnsafe('UseLocationFrom', LocationSource);
        POSAction.SetWorkflowInvocationParameterUnsafe('UseSpecLocationCode', UseSpecLocationCode);
        POSAction.SetWorkflowInvocationParameterUnsafe('SendICOrderConfirmation', SendICOrderConfirmation);
        POSAction.SetWorkflowInvocationParameterUnsafe('PaymentMethodCodeFrom', PaymentMethodCodeSource);
        POSAction.SetWorkflowInvocationParameterUnsafe('PaymentMethodCode', PaymentMethodCode);
        POSAction.SetWorkflowInvocationParameterUnsafe('CustomerTableView', '');
        POSAction.SetWorkflowInvocationParameterUnsafe('CustomerLookupPage', 0);
        POSAction.SetWorkflowInvocationParameterUnsafe('EnforceCustomerFilter', EnforceCustomerFilter);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetDocumentType', DocumentTypePositive);
        POSAction.SetWorkflowInvocationParameterUnsafe('SetPrintProformaInvoice', PrintProforma);

        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure HandleReq(Context: Codeunit "NPR POS JSON Helper")
    var
        TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary;
        TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary;
        TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary;
        POSSession: Codeunit "NPR POS Session";
    begin
        POSActionNpGpReturnB.CheckSetup(POSSession);
        FindReference(Context, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine);
        CreateGlobalReverseSale(Context, TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine);

        POSSession.ChangeViewSale();

    end;

    local procedure SelectReturnReason() Response: JsonObject
    var
        ReturnReason: Record "Return Reason";
        ReasonRequiredErr: Label 'You must choose a return reason';
    begin
        if (PAGE.RunModal(PAGE::"NPR TouchScreen: Ret. Reasons", ReturnReason) = ACTION::LookupOK) then begin
            Response.ReadFrom('{}');
            Response.Add('ReturnReasonCode', ReturnReason.Code);
        end else
            Error(ReasonRequiredErr);
    end;

    local procedure FindReference(Context: Codeunit "NPR POS JSON Helper"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry" temporary; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary)
    var
        ReferenceNumber: Text;
        FullSale: Boolean;
    begin
        ReferenceNumber := Context.GetString('ReferenceBarcode');
        FullSale := Context.GetBooleanParameter('ShowFullSale');

        POSActionNpGpReturnB.FindGlobalSaleByReferenceNo(CopyStr(ReferenceNumber, 1, 50), TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine, FullSale);
    end;

    local procedure CreateGlobalReverseSale(Context: Codeunit "NPR POS JSON Helper"; var TempNpGpPOSSalesLine: Record "NPR NpGp POS Sales Line" temporary; var TempNpGpPOSSalesEntry: Record "NPR NpGp POS Sales Entry"; var TempNpGpPOSPaymentLine: Record "NPR NpGp POS Payment Line" temporary)
    var
        ReturnReasonCode: Code[10];
        FullSale: Boolean;
    begin
        FullSale := Context.GetBooleanParameter('ShowFullSale');
        ReturnReasonCode := CopyStr(Context.GetString('ReturnReasonCode'), 1, MaxStrLen(ReturnReasonCode));

        POSActionNpGpReturnB.CreateGlobalReverseSale(TempNpGpPOSSalesLine, TempNpGpPOSSalesEntry, TempNpGpPOSPaymentLine, ReturnReasonCode, FullSale);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        EANDescriptionCaption: Label 'Handles return of global exchange label';
        ModuleNameCaption: Label 'Global exchange';
    begin
        if not EanBoxEvent.Get(EventCodeExchLabel()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := EventCodeExchLabel();
            EanBoxEvent."Module Name" := ModuleNameCaption;
            EanBoxEvent.Description := EANDescriptionCaption;
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CODEUNIT::"NPR POS Action: NpGp Return";
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if EanBoxEvent.Code = EventCodeExchLabel() then
            Sender.SetNonEditableParameterValues(EanBoxEvent, 'ReferenceBarcode', true, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeGlobalExchLabel(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeExchLabel() then
            exit;

        InScope := (CopyStr(EanBoxValue, StrLen(EanBoxValue) - 1, 2) = 'XX') and (StrLen(EanBoxValue) > 2);
    end;

    local procedure EventCodeExchLabel(): Code[20]
    begin
        exit('GLOBAL_EXCHANGE');
    end;

    procedure ActionCode(): Text
    begin
        exit(Format(enum::"NPR POS Workflow"::CROSS_REF_RETURN));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionNpGpReturn.js###
'let main=async({workflow:e,context:o,popup:r,parameters:t,captions:n})=>{if(t.ReferenceBarcode===""&&(e.context.ReferenceBarcode=await r.input({title:n.title,caption:n.refprompt}),e.context.ReferenceBarcode===null))return;const{ReturnReasonCode:a}=await e.respond("PromptForReason");await e.respond("handle",{ReturnReasonCode:a}),t.ExportReturnOrd&&await e.respond("ExportReturnOrder")};'
        );
    end;
}

