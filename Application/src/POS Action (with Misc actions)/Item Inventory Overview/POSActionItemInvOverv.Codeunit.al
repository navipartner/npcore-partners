codeunit 6150828 "NPR POS Action: ItemInv Overv." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function opens a page displaying the item inventory per location and variant.';
        ParamAllItemsCaptionLbl: Label 'All Items';
        ParamOnlyCurrentLocCaptionLbl: Label 'Only Current Location';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddBooleanParameter(AllItemsParTxt(), false, ParamAllItemsCaptionLbl, ParamAllItemsCaptionLbl);
        WorkflowConfig.AddBooleanParameter(OnlyCurrentLocParTxt(), false, ParamOnlyCurrentLocCaptionLbl, ParamOnlyCurrentLocCaptionLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionItemInvOverv.js###
'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        SalePOS: Record "NPR POS Sale";
        SalesLinePOS: Record "NPR POS Sale Line";
        BusinessLogicItemInv: Codeunit "NPR POS Action:ItemInv Over-B";
        AllItems: Boolean;
        OnlyCurrentLocation: Boolean;
    begin
        AllItems := Context.GetBooleanParameter(AllItemsParTxt());
        OnlyCurrentLocation := Context.GetBooleanParameter(OnlyCurrentLocParTxt());

        Sale.GetCurrentSale(SalePOS);
        SaleLine.GetCurrentSaleLine(SalesLinePOS);

        BusinessLogicItemInv.OpenItemInventoryOverviewPage(SalePOS, SalesLinePOS, AllItems, OnlyCurrentLocation);
    end;

    local procedure AllItemsParTxt(): Text[30]
    begin
        exit('AllItems');
    end;

    local procedure OnlyCurrentLocParTxt(): Text[30]
    begin
        exit('OnlyCurrentLocation');
    end;
}
