codeunit 6150820 "NPR POS Action: Run Object" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for running a Object';
        ParamMenuFilterCode_Name_CaptionLbl: Label 'Menu Filter Code';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter(ParamMenuFilterCode_Name(), '', ParamMenuFilterCode_Name_CaptionLbl, ParamMenuFilterCode_Name_CaptionLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionRunObject.js###
'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Run Object-B";
        POSSession: Codeunit "NPR POS Session";
        MenuFilterCode: Code[20];
    begin
        Evaluate(MenuFilterCode, Context.GetStringParameter(ParamMenuFilterCode_Name()));
        BusinessLogicRun.RunObject(MenuFilterCode, POSSession);
    end;

    local procedure ParamMenuFilterCode_Name(): Text[20]
    begin
        exit('MenuFilterCode');
    end;
}
