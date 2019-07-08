codeunit 6150780 "POS Action - Table Buzzer No"
{
    // NPR5.36/TSA /20170904 CASE 288568 Added option to control input dialo
    // NPR5.43/THRO/20180531 CASE 317458 Added option to control Comment text


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Insert a table buzzer number ';
        Prompt_EnterComment: Label 'Enter Table Buzzer Number';
        BuzzerText: Label 'Table Buzzer %1';

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
            //-NPR5.36 [288568]
            //RegisterWorkflowStep('', 'input(labels.prompt).respond();');
            RegisterWorkflowStep ('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input(labels.prompt).respond();}');
            RegisterWorkflowStep ('numpad', 'if (param.DialogType == param.DialogType["Numpad"]) {numpad(labels.prompt).respond();}');
            RegisterOptionParameter ('DialogType','TextField,Numpad','TextField');
            //+NPR5.36 [288568]
            //-NPR5.43 [317458]
            RegisterTextParameter('CommentTextPattern','');
            //+NPR5.43 [317458]
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
        CommentTextPattern: Text;
    begin
        JSON.InitializeJObjectParser(Context,FrontEnd);

        //-NPR5.43 [317458]
        CommentTextPattern := JSON.GetStringParameter('CommentTextPattern',true);
        if CommentTextPattern = '' then
          CommentTextPattern := BuzzerText;
        //+NPR5.43 [317458]

        with Line do begin
          Type := Type::Comment;
        //-NPR5.43 [317458]
          Description := StrSubstNo (CommentTextPattern, JSON.GetString ('value', true));
        //+NPR5.43 [317458]
        end;

        POSSession.GetSaleLine(SaleLine);
        SaleLine.InsertLine(Line);

        POSSession.RequestRefreshData();
    end;

    local procedure ActionCode(): Text
    begin
        exit ('INSERT_TABLE_BUZZER');
    end;

    local procedure ActionVersion(): Text
    begin
        //-NPR5.43 [317458]
        exit ('1.2');
        //+NPR5.43 [317458]
    end;
}

