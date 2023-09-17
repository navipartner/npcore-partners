codeunit 6060108 "NPR POS Action: MM BackEnd Fun" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action provides access to backend management function for the member module.';
        ParamMembershipSalesSetupItemNo_CptLbl: Label 'Membership Sales Setup Item Number';
        ParamMembershipSalesSetupItemNo_DescLbl: Label 'Specifies the Membership Sales Setup Item Number';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('MembershipSalesSetupItemNumber', '', ParamMembershipSalesSetupItemNo_CptLbl, ParamMembershipSalesSetupItemNo_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CreateMember':
                CreateMember(Context, Setup);
        end;
    end;

    local procedure CreateMember(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup")
    var
        ItemNumber: Code[20];
        POSActionBackEndB: Codeunit "NPR POS Action: MM BackEnd B";
    begin
        ItemNumber := CopyStr(Context.GetStringParameter('MembershipSalesSetupItemNumber'), 1, MaxStrLen(ItemNumber));
        POSActionBackEndB.CreateMember(ItemNumber, Setup);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionMMBackEndFun.js###
'let main=async({})=>await workflow.respond("CreateMember");'
        );
    end;
}


