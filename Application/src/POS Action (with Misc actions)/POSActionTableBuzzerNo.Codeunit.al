codeunit 6150780 "NPR POS Action: TableBuzzerNo"
{
    var
        ActionDescription: Label 'Insert a table buzzer number ';
        Prompt_EnterComment: Label 'Enter Table Buzzer Number';
        BuzzerText: Label 'Table Buzzer %1';
        ReadingErr: Label 'reading in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Sender.Type::Generic,
              Sender."Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input(labels.prompt).respond();}');
                RegisterWorkflowStep('numpad', 'if (param.DialogType == param.DialogType["Numpad"]) {numpad(labels.prompt).respond();}');
                RegisterOptionParameter('DialogType', 'TextField,Numpad', 'TextField');
                RegisterTextParameter('CommentTextPattern', '');
                RegisterWorkflow(false);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        InputPosCommentLine(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'prompt', Prompt_EnterComment);
    end;

    local procedure InputPosCommentLine(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        Line: Record "NPR Sale Line POS";
        SaleLine: Codeunit "NPR POS Sale Line";
        CommentTextPattern: Text;
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        CommentTextPattern := JSON.GetStringParameterOrFail('CommentTextPattern', ActionCode());
        if CommentTextPattern = '' then
            CommentTextPattern := BuzzerText;

        with Line do begin
            Type := Type::Comment;
            Description := StrSubstNo(CommentTextPattern, JSON.GetStringOrFail('value', StrSubstNo(ReadingErr, ActionCode())));
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit('INSERT_TABLE_BUZZER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;
}
