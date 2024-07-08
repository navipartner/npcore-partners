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
        ParamAskReturnReason_CptLbl: Label 'Ask Return Reason';
        ParamAskReturnReason_DescLbl: Label 'Enable/Disable Return Reason';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', TitleCaption);
        WorkflowConfig.AddLabel('refprompt', RefNoPromptCaption);

        WorkflowConfig.AddBooleanParameter('ShowFullSale', false, ParamShowFullSale_CptLbl, ParamShowFullSale_DescLbl);
        WorkflowConfig.AddTextParameter('ReferenceBarcode', '', ParamReferenceBarCode_CptLBl, ParamReferenceBarCode_DescCpt);
        WorkflowConfig.AddBooleanParameter('ExportReturnOrd', false, ParamExpReturnOrder_CptLbl, ParamExpReturnOrder_DescLbl);
        WorkflowConfig.AddBooleanParameter('ShowReturnOrd', false, ParamShowReturnOrd_CptLbl, ParamShowReturnOrd_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskReturnReason', true, ParamAskReturnReason_CptLbl, ParamAskReturnReason_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'PromptForReason':
                FrontEnd.WorkflowResponse(SelectReturnReason());
            'handle':
                HandleReq(Context);
            'ExportPurchaseReturnOrder':
                ExportPurchaseReturnOrder(Context, Sale);
        end;
    end;

    local procedure ExportPurchaseReturnOrder(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        ShowReturnOrd: Boolean;
    begin
        ShowReturnOrd := Context.GetBooleanParameter('ShowReturnOrd');

        POSActionNpGpReturnB.ExportPurchaseReturnOrder(Sale, ShowReturnOrd);
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
        AskReturnReason: Boolean;
    begin
        FullSale := Context.GetBooleanParameter('ShowFullSale');
        AskReturnReason := Context.GetBooleanParameter('AskReturnReason');
        if AskReturnReason then
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
'let main=async({workflow:e,context:d,popup:r,parameters:n,captions:t})=>{debugger;if(!(n.ReferenceBarcode===""&&(e.context.ReferenceBarcode=await r.input({title:t.title,caption:t.refprompt}),e.context.ReferenceBarcode===null))){if(n.AskReturnReason){const{ReturnReasonCode:a}=await e.respond("PromptForReason");await e.respond("handle",{ReturnReasonCode:a})}else await e.respond("handle");n.ExportReturnOrd&&await e.respond("ExportPurchaseReturnOrder")}};'
        );
    end;
}

