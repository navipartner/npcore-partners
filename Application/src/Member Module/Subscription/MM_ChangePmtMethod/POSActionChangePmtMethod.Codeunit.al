
codeunit 6185064 "NPR POSAction: ChangePmtMethod" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Change Payment Method for membership subscription.';
        EndSaleName: Label 'Try End Sale';
        EndSaleNameDesc: Label 'Try to end the sale after the payment is processed';
        InsertCommentLineName: Label 'Insert Comment Line';
        InsertCommentLineNameDesc: Label 'Insert a comment line in the POS sale when the membership payment method is changed';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter('tryEndSale', true, EndSaleName, EndSaleNameDesc);
        WorkflowConfig.AddBooleanParameter('insertCommentLine', true, InsertCommentLineName, InsertCommentLineNameDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; SaleMgr: codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line"; PaymentLineMgr: codeunit "NPR POS Payment Line"; SetupMgr: codeunit "NPR POS Setup");
    begin
        case Step of
            'ChangePaymentMethod':
                FrontEnd.WorkflowResponse(ChangePaymentMethod(Context, SaleMgr, SaleLineMgr));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionChangePmtMethod.js###
'const main=async({parameters:a})=>{const{success:e}=await workflow.respond("ChangePaymentMethod");e&&a.tryEndSale&&await workflow.run("END_SALE",{parameters:{calledFromWorkflow:"MM_CHANGE_PMT_METHOD",endSaleWithBalancing:!1,startNewSale:!0}})};'
        );
    end;

    local procedure ChangePaymentMethod(Context: codeunit "NPR POS JSON Helper"; SaleMgr: Codeunit "NPR POS Sale"; SaleLineMgr: codeunit "NPR POS Sale Line") Response: JsonObject
    var
        SalePOS: Record "NPR POS Sale";
        ChangePmtMethodB: Codeunit "NPR POSAction:ChangePmtMethodB";
        InsertCommentLine: Boolean;
        Success: Boolean;
    begin
        if not Context.GetBooleanParameter('insertCommentLine', InsertCommentLine) then
            Clear(InsertCommentLine);

        SaleMgr.GetCurrentSale(SalePOS);
        Success := ChangePmtMethodB.ChangePaymentMethod(SalePOS, InsertCommentLine, SaleLineMgr);

        Response.Add('success', Success);
    end;


}
