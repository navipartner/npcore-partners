codeunit 6150795 "NPR POS Action - Insert Comm." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
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

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'InsertComment':
                InputPosCommentLine(Context, SaleLine);
        end;
    end;

    local procedure InputPosCommentLine(Context: Codeunit "NPR POS JSON Helper"; SaleLine: codeunit "NPR POS Sale Line")
    var
        Line: Record "NPR POS Sale Line";
        NewDesc: Text[100];
    begin
        NewDesc := CopyStr(Context.GetString('NewDescription'), 1, MaxStrLen(Line.Description));

        Line."Line Type" := Line."Line Type"::Comment;
        Line.Description := NewDesc;

        SaleLine.InsertLine(Line);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionInsertComm.js###
'let main=async({workflow:n,captions:e,parameters:t})=>{let i;if(t.EditDescription==t.EditDescription.Yes?i=await popup.input({caption:e.prompt,value:t.DefaultDescription}):i=t.DefaultDescription,!(i===null||i===""))return await n.respond("InsertComment",{NewDescription:i})};'
        )
    end;
}
