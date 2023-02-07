codeunit 6151086 "NPR POS Action - Retail Inv." implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for Inventory Lookup using Retail Inventory Set';
        FixedInvCapt: Label 'Fixed Inventory Set Code';
        FixedInvDesc: Label 'Define Fixed Inventory Set Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('FixedInventorySetCode', '', FixedInvCapt, FixedInvDesc);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'ProcessInventorySet':
                OnActionProcessInventorySet(SaleLine, Context);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        EXIT(
        //###NPR_INJECT_FROM_FILE:POSActionRetailInventory.js###
'let main=async({})=>await workflow.respond("ProcessInventorySet");'
        );
    end;

    local procedure OnActionProcessInventorySet(POSSaleLine: Codeunit "NPR POS Sale Line"; Context: Codeunit "NPR POS JSON Helper")
    var
        InventorySetBL: Codeunit "NPR POS Action - Retail Inv. B";
        FixedInventorySetCode: Code[20];
    begin
        FixedInventorySetCode := CopyStr(UpperCase(Context.GetStringParameter('FixedInventorySetCode')), 1, MaxStrLen(FixedInventorySetCode));
        InventorySetBL.ProcessInventorySet(POSSaleLine, FixedInventorySetCode);
    end;
}

