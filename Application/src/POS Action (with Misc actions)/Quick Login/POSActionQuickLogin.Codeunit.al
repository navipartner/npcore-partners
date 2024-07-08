codeunit 6150845 "NPR POS Action: Quick Login" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescriptionLbl: Label 'Quick Login - change Salesperson on current POS Sale';
        FixedSalesPersoneParam_CptLbl: Label 'Fixed Salesperson Code';
        FixedSalesPersoneParam_DescLbl: Label 'Specifies Fixed Salesperson Code';
        SalesPersLookupParam_CptLbl: Label 'Lookup Salesperson Code';
        SalesPersLookupParam_DescLbl: Label 'Specifies Lookup Salesperson Code';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);

        WorkflowConfig.AddTextParameter('FixedSalespersonCode', '', FixedSalesPersoneParam_CptLbl, FixedSalesPersoneParam_DescLbl);
        WorkflowConfig.AddBooleanParameter('LookupSalespersonCode', true, SalesPersLookupParam_CptLbl, SalesPersLookupParam_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSActBusinessLog: Codeunit "NPR POS Action: Quick Login B.";
        SalespersonCode: Code[20];
        LookupSalespersonCode: Boolean;
    begin
        SalespersonCode := CopyStr(Context.GetStringParameter('FixedSalespersonCode'), 1, MaxStrLen(SalespersonCode));
        LookupSalespersonCode := Context.GetBooleanParameter('LookupSalespersonCode');

        if (SalespersonCode <> '') and LookupSalespersonCode then begin
            POSActBusinessLog.OnActionLookupSalespersonCode(SalespersonCode, Sale);
            exit;
        end;     
        if SalespersonCode <> '' then
            POSActBusinessLog.ApplySalespersonCode(SalespersonCode, Sale);
        if LookupSalespersonCode then
            POSActBusinessLog.OnActionLookupSalespersonCode(SalespersonCode, Sale);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
            //###NPR_INJECT_FROM_FILE:POSActionQuickLogin.js###
            'let main=async({})=>await workflow.respond();'
        )
    end;
}
