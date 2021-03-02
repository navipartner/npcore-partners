codeunit 6150795 "NPR POS Action - Insert Comm."
{
    var
        ActionDescription: Label 'Insert a sales line comment. ';
        Prompt_EnterComment: Label 'Enter Comment';
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
                RegisterWorkflowStep('', 'if (param.EditDescription == param.EditDescription["Yes"]) {input({caption: labels.prompt, value: param.DefaultDescription}).respond();} else {context.value=param.DefaultDescription; respond();}');
                RegisterTextParameter('DefaultDescription', '');
                RegisterOptionParameter('EditDescription', 'Yes,No', 'Yes');
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
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        with Line do begin
            Type := Type::Comment;
            Description := JSON.GetStringOrFail('value', StrSubstNo(ReadingErr, ActionCode()));
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit('INSERT_COMMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;
}
