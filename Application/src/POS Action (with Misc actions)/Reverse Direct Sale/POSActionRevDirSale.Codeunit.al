codeunit 6150798 "NPR POS Action: Rev. Dir. Sale" implements "NPR IPOS Workflow"
{
    Access = Internal;
    Description = 'POS Action: Reverse Direct Sale';

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Refund / Reverse Sale. This action will prompt for a receipt no and recreate the sales with reversed quantity.';
        ParamItemCondition_CptLbl: Label 'Item Condition';
        ParamItemCondition_DescLbl: Label 'Defines item condition';
        ParamItemCondition_OptLbl: Label 'Mint,Used,Not Suitable for Resale', Locked = true;
        ParamItemCondition_OptCptLbl: Label 'Mint, Used, Not Suitable for Resale';
        ParamObfucationMethod_CptLbl: Label 'Obfucation Method';
        ParamObfucationMethod_DescLbl: Label 'Defines obfucation method';
        ParamObfucationMethod_OptLbl: Label 'None,MI', Locked = true;
        ParamObfucationMethod_OptCptLbl: Label 'None, MI';
        ParamCopyHdrDim_CptLbl: Label 'Copy Header Dimensions';
        ParamCopyHdrDim_DescLbl: Label 'Defines if header dimenions will be copied';
        ParamCopyLineDim_CptLbl: Label 'Copy Line Dimensions';
        ParamCopyLineDim_DescLbl: Label 'Defines if line dimenions will be copied';
        ParamPayLines_CptLbl: Label 'Include Payment Lines';
        ParamPayLines_DescLbl: Label 'Include/Disclude Payment Lines';
        Title: Label 'Reverse Sale';
        ReceiptPrompt: Label 'Receipt Number';
        ReasonPrompt: Label 'Return Reason';
        TooLongErr: Label 'Receipt Number cannot have more than 20 characters.';
        TakePhotoLbl: Label 'Take photo';
        TakePhotoDesc: Label 'Specifies if the user has to insert photo.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', Title);
        WorkflowConfig.AddLabel('receiptprompt', ReceiptPrompt);
        WorkflowConfig.AddLabel('reasonprompt', ReasonPrompt);
        WorkflowConfig.AddLabel('lengtherror', TooLongErr);
        WorkflowConfig.AddOptionParameter(
                       'ItemCondition',
                       ParamItemCondition_OptLbl,
#pragma warning disable AA0139
                       SelectStr(2, ParamItemCondition_OptLbl),
#pragma warning restore 
                       ParamItemCondition_CptLbl,
                       ParamItemCondition_DescLbl,
                       ParamItemCondition_OptCptLbl);
        WorkflowConfig.AddOptionParameter(
                       'ObfucationMethod',
                       ParamObfucationMethod_OptLbl,
#pragma warning disable AA0139
                       SelectStr(1, ParamObfucationMethod_OptLbl),
#pragma warning restore 
                       ParamObfucationMethod_CptLbl,
                       ParamObfucationMethod_DescLbl,
                       ParamObfucationMethod_OptCptLbl);
        WorkflowConfig.AddBooleanParameter('CopyHeaderDimensions', false, ParamCopyHdrDim_CptLbl, ParamCopyHdrDim_DescLbl);
        WorkflowConfig.AddBooleanParameter('IncludePaymentLines', false, ParamPayLines_CptLbl, ParamPayLines_DescLbl);
        WorkflowConfig.AddBooleanParameter(TakePhotoParLbl, false, TakePhotoLbl, TakePhotoDesc);
        WorkflowConfig.AddBooleanParameter('CopyLineDimensions', true, ParamCopyLineDim_CptLbl, ParamCopyLineDim_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
    begin
        case Step of
            'reason':
                FrontEnd.WorkflowResponse(GetReason(Sale, Context, Setup));
            'SelectReturnReason':
                FrontEnd.WorkflowResponse(SelectReturnReason());
            'handle':
                HendleReverse(Sale, Context, Setup);
        end;
    end;

    local procedure GetReason(Sale: codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup"): Boolean
    var
        POSUnit: Record "NPR POS Unit";
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSActionTakePhotoB: Codeunit "NPR POS Action Take Photo B";
    begin
        TakePhotoEnabled := Context.GetBooleanParameter(TakePhotoParLbl);
        if TakePhotoEnabled then
            POSActionTakePhotoB.TakePhoto(Sale);
        Setup.GetPOSUnit(POSUnit);
        POSAuditProfile.Get(POSUnit."POS Audit Profile");
        exit(POSAuditProfile."Require Item Return Reason");
    end;

    local procedure HendleReverse(Sale: codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup")
    var
        SalesTicketNo: Code[20];
        ObfucationMethod: Option "None",MI;
        CopyHeaderDim: Boolean;
        CopyLineDimensions: Boolean;
        ReturnReasonCode: Code[20];
        IncludePaymentLines: Boolean;
        POSActionRevDirSaleB: Codeunit "NPR POS Action: Rev.Dir.Sale B";
        POSActionTakePhotoB: Codeunit "NPR POS Action Take Photo B";
    begin
        SalesTicketNo := CopyStr(UpperCase(Context.GetString('receipt')), 1, MaxStrLen(SalesTicketNo));
        ObfucationMethod := Context.GetIntegerParameter('ObfucationMethod');
        CopyHeaderDim := Context.GetBooleanParameter('CopyHeaderDimensions');
        ReturnReasonCode := CopyStr(Context.GetString('ReturnReasonCode'), 1, MaxStrLen(ReturnReasonCode));
        IncludePaymentLines := Context.GetBooleanParameter('IncludePaymentLines');
        CopyLineDimensions := Context.GetBooleanParameter('CopyLineDimensions');

        TakePhotoEnabled := Context.GetBooleanParameter(TakePhotoParLbl);
        if TakePhotoEnabled then
            POSActionTakePhotoB.CheckIfPhotoIsTaken(Sale);
        OnBeforeHendleReverse(Setup, SalesTicketNo);
        POSActionRevDirSaleB.HendleReverse(SalesTicketNo, ObfucationMethod, CopyHeaderDim, ReturnReasonCode, IncludePaymentLines, CopyLineDimensions);
    end;

    local procedure SelectReturnReason() Response: Text
    var
        ReturnReason: Record "Return Reason";
        ReasonRequired: Label 'You must choose a return reason.';
    begin
        if (PAGE.RunModal(PAGE::"NPR TouchScreen: Ret. Reasons", ReturnReason) = ACTION::LookupOK) then
            Response := ReturnReason.Code
        else
            Error(ReasonRequired);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionRevDirSale.js###
'let main=async({workflow:e,context:i,scope:c,popup:n,parameters:p,captions:t})=>{if(e.context.receipt=await n.input({title:t.title,caption:t.receiptprompt}),e.context.receipt!==null){if(e.context.receipt.length>50)return await n.error(t.lengtherror)," ";var a=await e.respond("reason");if(a){var r=await e.respond("SelectReturnReason");if(r===null)return}else var r="";await e.respond("handle",{PromptForReason:a,ReturnReasonCode:r})}};'
        );
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeHendleReverse(Setup: Codeunit "NPR POS Setup"; var SalesTicketNo: Code[20])
    begin
    end;

    var
        TakePhotoEnabled: Boolean;
        TakePhotoParLbl: Label 'TakePhoto', Locked = true;
}
