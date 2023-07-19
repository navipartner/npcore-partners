codeunit 6150780 "NPR POS Action: TableBuzzerNo" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'Insert a table buzzer number';
        DialogTypeParam_OptLbl: Label 'TextField,Numpad', Locked = true;
        DialogTypeParam_OptCptLbl: Label 'TextField,Numpad';
        DialogTypeParam_CptLbl: Label 'Dialog Type';
        DialogTypeParam_DescLbl: Label 'Specifies Dialog Type';
        ComTextPatterParam_Cptbl: Label 'Comment Text Pattern';
        ComTextPatterParam_Descbl: Label 'Specifies Comment Text Pattern';
        Prompt_EnterComment: Label 'Enter Table Buzzer Number';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.AddOptionParameter(
            'DialogType',
            DialogTypeParam_OptLbl,
#pragma warning disable AA0139
            SelectStr(1, DialogTypeParam_OptLbl),
#pragma warning restore 
            DialogTypeParam_CptLbl,
            DialogTypeParam_DescLbl,
            DialogTypeParam_OptCptLbl);
        WorkflowConfig.AddTextParameter('CommentTextPattern', '', ComTextPatterParam_Cptbl, ComTextPatterParam_Descbl);
        WorkflowConfig.AddLabel('prompt', Prompt_EnterComment);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionTableBuzzerNo.js###
'let main=async({workflow:t,captions:p,parameters:i,context:a})=>{i.DialogType==i.DialogType.TextField?a.input=await popup.input({caption:p.prompt}):a.input=await popup.numpad({caption:p.prompt}),await t.respond()};'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        OnActionInsertTableBuzzer(Context, SaleLine);
    end;

    local procedure OnActionInsertTableBuzzer(Context: Codeunit "NPR POS JSON Helper"; SaleLine: Codeunit "NPR POS Sale Line")
    var
        BusinessLogic: Codeunit "NPR POS Act:TableBuzzerNo BL";
        CommentTextPattern: Text;
        InputText: Text;
    begin
        CommentTextPattern := Context.GetStringParameter('CommentTextPattern');
        InputText := Context.GetString('input');
        BusinessLogic.InputPosCommentLine(SaleLine, CommentTextPattern, InputText);
    end;
}
