codeunit 6150795 "POS Action - Insert Comment"
{
    // NPR5.36/TSA /20170830 CASE 288574 Added DefaultDescription parameter and increase version


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Insert a sales line comment. ';
        Prompt_EnterComment: Label 'Enter Comment';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
          then begin
            //-NPR5.36 [288574]
            //RegisterWorkflowStep('', 'input(labels.prompt).respond();');
            RegisterWorkflowStep ('', 'if (param.EditDescription == param.EditDescription["Yes"]) {input({caption: labels.prompt, value: param.DefaultDescription}).respond();} else {context.value=param.DefaultDescription; respond();}');
            RegisterTextParameter ('DefaultDescription', '');
            RegisterOptionParameter ('EditDescription','Yes,No','Yes');
            RegisterWorkflow(false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        InputPosCommentLine (Context, POSSession, FrontEnd);
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'prompt', Prompt_EnterComment);
    end;

    local procedure InputPosCommentLine(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        JSON: Codeunit "POS JSON Management";
        Line: Record "Sale Line POS";
        SaleLine: Codeunit "POS Sale Line";
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        with Line do begin
          Type := Type::Comment;
          Description := JSON.GetString ('value', true);
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit ('INSERT_COMMENT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
    end;
}

