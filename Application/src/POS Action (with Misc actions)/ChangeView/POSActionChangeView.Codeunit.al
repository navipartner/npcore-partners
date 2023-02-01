codeunit 6150724 "NPR POS Action - Change View" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Changes the current view.';
        ParamViewCode_CptLbl: Label 'View Code';
        ParamViewCode_DescLbl: Label 'Specifies View Code';
        ParamViewType_OptLbl: Label 'Login,Sale,Payment,Balance,Locked', Locked = true;
        ParamViewType_CptLbl: Label 'View Type';
        ParamViewType_DescLbl: Label 'Specifies View Type';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('ViewCode', '', ParamViewCode_CptLbl, ParamViewCode_DescLbl);
        WorkflowConfig.AddOptionParameter('ViewType',
                                           ParamViewType_OptLbl,
#pragma warning disable AA0139
                                           SelectStr(1, ParamViewType_OptLbl),
#pragma warning restore 
                                           ParamViewType_CptLbl,
                                           ParamViewType_DescLbl,
                                           ParamViewType_OptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'ChangeView':
                ChangeView(Context);
        end;
    end;

    local procedure ChangeView(Context: Codeunit "NPR POS JSON Helper")
    var
        ViewType: Option Login,Sale,Payment,Balance,Locked;
        ViewCode: Code[10];
        POSActionChangeViewB: Codeunit "NPR POS Action: Change View-B";
    begin
        ViewType := Context.GetIntegerParameter('ViewType');
        ViewCode := CopyStr(Context.GetStringParameter('ViewCode'), 1, 10);

        POSActionChangeViewB.ChangeView(ViewType, ViewCode);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionChangeView.js###
'let main=async({})=>{await workflow.respond("ChangeView")};'
        )
    end;
}
