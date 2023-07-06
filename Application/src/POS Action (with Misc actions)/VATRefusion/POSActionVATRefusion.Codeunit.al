codeunit 6150816 "NPR POSAction: VAT Refusion" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built in function for handling VAT refussion.';
        ParamPaymentTypePOSCode_CptLbl: Label 'Payment Type POS Code';
        ParamPaymentTypePOSCode_DescLbl: Label 'Payment type used for VAT refusion';
        ParamPAskForConfirm_CptLbl: Label 'Ask For Confirm';
        ParamAskForConfirm_DescLbl: Label 'If this parameter is enabled you will need to confirm VAT fusion before taking action.';
        LabelConfirmRefussionTitle_Lbl: Label 'Confirm VAT Refussion';
        LabelConfrmRefussionLead_Lbl: Label 'VAT Refussion payment of amount %1 are being added.\\Press Yes to add refussion payment. Press No to abort.';
        LabelRefussionNotPosTitle_Lbl: Label 'VAT Refussion is not possible';
        LabelRefussionNotPosLead_Lbl: Label 'VAT Amount can not be zero for VAT Refussion';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('PaymentTypePOSCode', '', ParamPaymentTypePOSCode_CptLbl, ParamPaymentTypePOSCode_DescLbl);
        WorkflowConfig.AddBooleanParameter('AskForConfirm', false, ParamPAskForConfirm_CptLbl, ParamAskForConfirm_DescLbl);
        WorkflowConfig.AddLabel('confirmRefussionTitle', LabelConfirmRefussionTitle_Lbl);
        WorkflowConfig.AddLabel('confirmRefussionLead', LabelConfrmRefussionLead_Lbl);
        WorkflowConfig.AddLabel('informRefussionNotPossibleTitle', LabelRefussionNotPosTitle_Lbl);
        WorkflowConfig.AddLabel('informRefussionNotPossibleLead', LabelRefussionNotPosLead_Lbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'onBeforeRefusion':
                OnBeforeRefussion(Context);
            'doRefussion':
                OnDoRefussion(Context);
        end;
    end;

    local procedure OnBeforeRefussion(Context: codeunit "NPR POS JSON Helper")
    var
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        NPRPOSPaymentMethod: Record "NPR POS Payment Method";
        POSSale: Codeunit "NPR POS Sale";
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        VATRefusionB: Codeunit "NPR POSAction: VAT Refusion-B";
        TotalVATOnSale: Decimal;
    begin
        Context.SetScopeRoot();

        //Calc VAT amount before
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        TotalVATOnSale := VATRefusionB.CalcVATFromSale(SalePOS);

        //Check pos payment type
        POSSession.GetPaymentLine(POSPaymentLine);
        NPRPOSPaymentMethod.Get(Context.GetStringParameter('PaymentTypePOSCode'));

        VATRefusionB.ValidateMinMaxAmount(NPRPOSPaymentMethod, TotalVATOnSale);

        Context.SetContext('VATAmount', TotalVATOnSale);
    end;


    local procedure OnDoRefussion(Context: codeunit "NPR POS JSON Helper")
    var
        VATRefusionB: Codeunit "NPR POSAction: VAT Refusion-B";
        PaymentTypeCode: Code[10];
        AmountInclVAT: Decimal;
    begin
        Context.SetScopeRoot();
        PaymentTypeCode := CopyStr(Context.GetStringParameter('PaymentTypePOSCode'), 1, MaxStrLen(PaymentTypeCode));
        AmountInclVAT := Context.GetDecimal('VATAmount');

        VATRefusionB.DoRefusion(PaymentTypeCode, AmountInclVAT);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionVATRefusion.js###
'let main=async({workflow:s,parameters:o,context:e,popup:n,captions:i,respond:r})=>{if(await s.respond("onBeforeRefusion"),!(o.AskForConfirm==!0&&e.VATAmount!=0&&(result=await n.confirm({caption:i.confirmRefussionTitle,label:i.confirmRefussionLead.replace("%1",e.VATAmount)}),!result))){if(e.VATAmount==0){await n.message({caption:i.informRefussionNotPossibleTitle,label:i.informRefussionNotPossibleLead});return}e.VATAmount!=0&&await s.respond("doRefussion")}};'
        )
    end;
}

