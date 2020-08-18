codeunit 6150786 "POS Action - Play Sound"
{
    // NPR5.55/ALPO/20200514 CASE 401942 POS Action to play a sound (to be used as Ean Box event)


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'An action to play an audio file from Url';

    local procedure ActionCode(): Text
    begin
        exit('PLAY_SOUND');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', true, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
              ActionCode(),
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('PlaySoundAndDisplayMessage',
              'if (param.AudioFileUrl) {' +
              '  var audio = new Audio(param.AudioFileUrl);' +
              '  audio.play();' +
              '}' +
              'if (param.ShowMessage) {' +
              '  if (param.MessageText.length > 0) {' +
              '    message(param.MessageHeader,param.MessageText);' +
              '  };' +
              '}');
            RegisterWorkflow(false);

            RegisterTextParameter('AudioFileUrl','');
            RegisterBooleanParameter('ShowMessage',false);
            RegisterTextParameter('MessageText','');
            RegisterTextParameter('MessageHeader','You might want to know...');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', true, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: JsonObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    var
        CaptionAudioFileUrl: Label 'Audio File Url';
        CaptionMessageHeader: Label 'Message Header';
        CaptionMessageText: Label 'Message Text';
        CaptionShowMessage: Label 'Show Message';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'AudioFileUrl' : Caption := CaptionAudioFileUrl;
          'ShowMessage' : Caption := CaptionShowMessage;
          'MessageText' : Caption := CaptionMessageText;
          'MessageHeader' : Caption := CaptionMessageHeader;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6150705, 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "POS Parameter Value";var Caption: Text)
    var
        DescAudioFileUrl: Label 'An Url to an audio file to be played back';
        DescMessageHeader: Label 'Define message heading text';
        DescMessageText: Label 'Define message detailed text';
        DescShowMessage: Label 'Set if you want to show a message to user';
    begin
        if POSParameterValue."Action Code" <> ActionCode then
          exit;

        case POSParameterValue.Name of
          'AudioFileUrl' : Caption := DescAudioFileUrl;
          'ShowMessage' : Caption := DescShowMessage;
          'MessageText' : Caption := DescMessageText;
          'MessageHeader' : Caption := DescMessageHeader;
        end;
    end;

    local procedure "--- Ean Box Event Handling"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "Ean Box Event")
    var
        EanBoxEventDesc: Label 'Plays an audio file from an Url';
        EanBoxEventModuleName: Label 'Global';
    begin
        if not EanBoxEvent.Get(ActionCode()) then begin
          EanBoxEvent.Init;
          EanBoxEvent.Code := ActionCode();
          EanBoxEvent."Module Name" := EanBoxEventModuleName;
          EanBoxEvent.Description := CopyStr(EanBoxEventDesc,1,MaxStrLen(EanBoxEvent.Description));
          EanBoxEvent."Action Code" := ActionCode();
          EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
          EanBoxEvent."Event Codeunit" := CurrCodeunitID();
          EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060105, 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "Ean Box Setup Mgt.";EanBoxEvent: Record "Ean Box Event")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6060107, 'SetEanBoxEventInScope', '', true, false)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "Ean Box Setup Event";EanBoxValue: Text;var InScope: Boolean)
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
          exit;

        InScope := true;
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(CODEUNIT::"POS Action - Play Sound");
    end;
}

