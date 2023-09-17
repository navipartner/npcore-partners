codeunit 6150698 "NPR POSAction: Ch.Resp.Cent." implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'Change Responsibility Center on current POS Sale';
        FixedRespCenterParam_CptLbl: Label 'Fixed Resp Center';
        FixedRespCenterParam_DescLbl: Label 'Specifies Fixed Responsibility Center';
        RespCenterLookupParam_CptLbl: Label 'Lookup Resp Center';
        RespCenterLookupParam_DescLbl: Label 'Specifies Lookup Responsibility Center';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

        WorkflowConfig.AddTextParameter('FixedRespCenter', '', FixedRespCenterParam_CptLbl, FixedRespCenterParam_DescLbl);
        WorkflowConfig.AddBooleanParameter('LookupRespCenter', true, RespCenterLookupParam_CptLbl, RespCenterLookupParam_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        BusinessLogic: Codeunit "NPR POS Act:Change Resp Cent B";
        RespCenter: Code[10];
        LookupRespCenter: Boolean;
    begin
        RespCenter := CopyStr(Context.GetStringParameter('FixedRespCenter'), 1, MaxStrLen(RespCenter));
        LookupRespCenter := Context.GetBooleanParameter('LookupRespCenter');

        if LookupRespCenter then begin
            BusinessLogic.OnActionLookupRespCenter(RespCenter, Sale);
            exit;
        end;
        if RespCenter <> '' then
            BusinessLogic.ApplyRespCenterCode(RespCenter, Sale);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
            //###NPR_INJECT_FROM_FILE:POSActionChangeRespCenter.js###
            'let main=async({})=>await workflow.respond();'
        )
    end;

}