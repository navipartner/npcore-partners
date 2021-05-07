codeunit 6150786 "NPR POS Action - Play Sound"
{
    local procedure ActionCode(): Text
    begin
        exit('PLAY_SOUND');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This built in function allows to play back an audio file from provided Url.', MaxLength = 250;
        DefaultMessageHdrLbl: Label 'You might want to know...', MaxLength = 250;
    begin
        if Sender.DiscoverAction(
            ActionCode(),
            ActionDescriptionLbl,
            ActionVersion(),
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('PlaySoundAndDisplayMessage',
              'if (param.AudioFileUrl) {' +
              '  var audio = new Audio(param.AudioFileUrl);' +
              '  audio.play();' +
              '}' +
              'if (param.ShowMessage) {' +
              '  if (param.MessageText.length > 0) {' +
              '    message(param.MessageHeader,param.MessageText);' +
              '  };' +
              '}');
            Sender.RegisterWorkflow(false);

            Sender.RegisterTextParameter('AudioFileUrl', '');
            Sender.RegisterBooleanParameter('ShowMessage', false);
            Sender.RegisterTextParameter('MessageText', '');
            Sender.RegisterTextParameter('MessageHeader', DefaultMessageHdrLbl);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', true, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionAudioFileUrl: Label 'Audio File Url';
        CaptionMessageHeader: Label 'Message Header';
        CaptionMessageText: Label 'Message Text';
        CaptionShowMessage: Label 'Show Message';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'AudioFileUrl':
                Caption := CaptionAudioFileUrl;
            'ShowMessage':
                Caption := CaptionShowMessage;
            'MessageText':
                Caption := CaptionMessageText;
            'MessageHeader':
                Caption := CaptionMessageHeader;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescAudioFileUrl: Label 'Url of the audio file to be played back';
        DescMessageHeader: Label 'Define message heading text';
        DescMessageText: Label 'Define message detailed text';
        DescShowMessage: Label 'Set if you want to show a message to user';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'AudioFileUrl':
                Caption := DescAudioFileUrl;
            'ShowMessage':
                Caption := DescShowMessage;
            'MessageText':
                Caption := DescMessageText;
            'MessageHeader':
                Caption := DescMessageHeader;
        end;
    end;

    #region Ean Box Event Handling
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        EanBoxEventDesc: Label 'Plays back an audio file from provided Url';
        EanBoxEventModuleName: Label 'Global';
    begin
        if not EanBoxEvent.Get(ActionCode()) then begin
            EanBoxEvent.Init();
            EanBoxEvent.Code := ActionCode();
            EanBoxEvent."Module Name" := EanBoxEventModuleName;
            EanBoxEvent.Description := CopyStr(EanBoxEventDesc, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := ActionCode();
            EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
            EanBoxEvent."Event Codeunit" := CurrCodeunitID();
            EanBoxEvent.Insert(true);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, false)]
    local procedure SetEanBoxEventInScope(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    begin
        if EanBoxSetupEvent."Event Code" <> ActionCode() then
            exit;

        InScope := true;
    end;

    local procedure CurrCodeunitID(): Integer
    begin
        exit(Codeunit::"NPR POS Action - Play Sound");
    end;
    #endregion Ean Box Event Handling
}