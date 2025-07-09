codeunit 6184645 "NPR POS Action Set Vch Ref No" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built in function sets the reference no. of a voucher in a POS Sale';
        CustomReferenceNoCaptionLbl: Label 'Reference No.';
        CustomReferenceNoTitleLbl: Label 'Please scan a reference no.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('referenceNoCaption', CustomReferenceNoCaptionLbl);
        WorkflowConfig.AddLabel('referenceNoTitle', CustomReferenceNoTitleLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        AssignReferenceNo(Context, SaleLine);
    end;

    local procedure AssignReferenceNo(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSActionSetVchRefNoB: Codeunit "NPR POS Action Set Vch Ref NoB";
        NpRvVoucherMgt: Codeunit "NPR NpRv Voucher Mgt.";
        ReferenceNo: Text;
    begin
        Context.GetString('referenceNo', ReferenceNo);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        NpRvVoucherMgt.OnBeforeProcessScannedVoucherReferenceNo(ReferenceNo);
#pragma warning disable AA0139
        POSActionSetVchRefNoB.AssignReferenceNo(SaleLinePOS, '', ReferenceNo);
#pragma warning restore AA0139
    end;

    internal procedure ActionCode(): Text[20]
    begin
        exit('SET_VOUCHER_REF_NO');
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSetVchRefNo.js###
'let main=async({workflow:n,popup:t,captions:e})=>{debugger;let r=await t.input({title:e.referenceNoTitle,caption:e.referenceNoCaption});r!==null&&await n.respond("",{referenceNo:r})};'
        )
    end;
}

