codeunit 6150934 "NPR POS Action: Scan Coupon" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This action handles Scan Discount Coupon.';
        ParamReferenceNo_CptLbl: Label 'Reference Number';
        ParamReferenceNo_DescLbl: Label 'Reference No. of a Coupon.';
        ScanCouponPrompt_Lbl: Label 'Scan Coupon';
        CouponTitle_Lbl: Label 'Discount Coupon';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('ReferenceNo', '', ParamReferenceNo_CptLbl, ParamReferenceNo_DescLbl);
        WorkflowConfig.AddLabel('ScanCouponPrompt', ScanCouponPrompt_Lbl);
        WorkflowConfig.AddLabel('CouponTitle', CouponTitle_Lbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
        CouponReferenceNo: Text;
    begin
        case Step of
            'ScanCoupon':
                begin
                    CouponReferenceNo := Context.GetString('CouponCode');
                    CouponMgt.ScanCoupon(POSSession, CouponReferenceNo);
                end;
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionScanCoupon.js###
'let main=async({parameters:e,captions:n,popup:C,context:o})=>{if(e.ReferenceNo)o.CouponCode=e.ReferenceNo;else if(o.CouponCode=await C.input({caption:n.ScanCouponPrompt,title:n.CouponTitle}),!o.CouponCode)return;await workflow.respond("ScanCoupon")};'
        )
    end;
}
