codeunit 6150795 "NPR POS Action - Insert Comm." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert a sales line comment. ';
        ParamDefaultDesc_CptLbl: Label 'Default Description';
        ParamDefaultDesc_DescLbl: Label 'Specifies Default Description';
        ParamEditDesc_CptLbl: Label 'Edit Description';
        ParamEditDesc_DescLbl: Label 'Enable/Disable Description edit';
        ParamEditDesc_OptLbl: Label 'Yes,No', Locked = true;
        ParamEditDesc_OptCptLbl: Label 'Yes,No';
        Prompt_EnterComment: Label 'Enter Comment';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('DefaultDescription', '', ParamDefaultDesc_CptLbl, ParamDefaultDesc_DescLbl);
        WorkflowConfig.AddOptionParameter('EditDescription',
                                          ParamEditDesc_OptLbl,
#pragma warning disable AA0139
                                          SelectStr(1, ParamEditDesc_OptLbl),
#pragma warning restore 
                                          ParamEditDesc_CptLbl,
                                          ParamEditDesc_DescLbl,
                                          ParamEditDesc_OptCptLbl);
        WorkflowConfig.AddLabel('prompt', Prompt_EnterComment);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        POSSaleLine: Record "NPR POS Sale Line";
        BusinessLogic: Codeunit "NPR POS Action - Insert Comm B";
        CommentDescription: Text[100];
    begin
        CommentDescription := CopyStr(Context.GetString('NewDescription'), 1, MaxStrLen(POSSaleLine.Description));

        case Step of
            'InsertComment':
                BusinessLogic.InputPosCommentLine(CommentDescription, SaleLine);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionInsertComm.js###
'let main=async({workflow:n,captions:e,parameters:t})=>{let i;if(t.EditDescription==t.EditDescription.Yes?i=await popup.input({caption:e.prompt,value:t.DefaultDescription}):i=t.DefaultDescription,!(i===null||i===""))return await n.respond("InsertComment",{NewDescription:i})};'
        )
    end;
}
