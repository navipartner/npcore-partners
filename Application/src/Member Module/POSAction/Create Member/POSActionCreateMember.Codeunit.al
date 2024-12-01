codeunit 6014660 "NPR POS Action Create Member" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action creates and assigns the membership to current sales.', MaxLength = 250;
        ParamMembSalesSetupItemNo_CptLbl: Label 'Membership Sales Setup Item No.';
        ParamMembSalesSetupItemNo_DescLbl: Label 'Defines Membership Sales Setup Item No.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('MembershipSalesSetupItemNumber', '', ParamMembSalesSetupItemNo_CptLbl, ParamMembSalesSetupItemNo_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'CreateMember':
                CreateMembershipWrapper(Sale, Context);
        end;
    end;

    local procedure CreateMembershipWrapper(POSSale: Codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper")
    var
        MembershipSalesSetupItemNumber: Code[20];
        POSActCreateMembershipB: Codeunit "NPR POS Action Create Member B";
    begin
        MembershipSalesSetupItemNumber := CopyStr(Context.GetStringParameter('MembershipSalesSetupItemNumber'), 1, 20);

        POSActCreateMembershipB.CreateMembershipWrapper(POSSale, MembershipSalesSetupItemNumber);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionCreateMember.js###
'const main=async({workflow:n})=>{await n.respond("CreateMember"),await n.respond("TermsAndConditions")};'
        );
    end;
}
