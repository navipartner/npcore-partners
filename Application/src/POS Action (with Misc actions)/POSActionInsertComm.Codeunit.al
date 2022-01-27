codeunit 6150795 "NPR POS Action - Insert Comm."
{
    Access = Internal;
    var
        ActionDescription: Label 'Insert a sales line comment. ';
        Prompt_EnterComment: Label 'Enter Comment';
        ReadingErr: Label 'reading in %1';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescription,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('', 'if (param.EditDescription == param.EditDescription["Yes"]) {input({caption: labels.prompt, value: param.DefaultDescription}).respond();} else {context.value=param.DefaultDescription; respond();}');
            Sender.RegisterTextParameter('DefaultDescription', '');
            Sender.RegisterOptionParameter('EditDescription', 'Yes,No', 'Yes');
            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        InputPosCommentLine(Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'prompt', Prompt_EnterComment);
    end;

    local procedure InputPosCommentLine(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        JSON: Codeunit "NPR POS JSON Management";
        Line: Record "NPR POS Sale Line";
        SaleLine: Codeunit "NPR POS Sale Line";
    begin
        JSON.InitializeJObjectParser(Context, FrontEnd);

        Line.Type := Line.Type::Comment;
        Line.Description := CopyStr(JSON.GetStringOrFail('value', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(Line.Description));

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit('INSERT_COMMENT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.1');
    end;
}
