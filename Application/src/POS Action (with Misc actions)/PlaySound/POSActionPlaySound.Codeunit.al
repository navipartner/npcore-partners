codeunit 6150786 "NPR POS Action - Play Sound" implements "NPR IPOS Workflow"
{
    Access = Internal;
    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::PLAY_SOUND));
    end;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Plays back an audio file from provided Url';
        ParamAudioFileUrlCaption_Lbl: Label 'Audio File Url';
        ParamAudioFileUrlDesc_Lbl: Label 'Url of the audio file to be played back';
        ParamMessageHeaderCaption_Lbl: Label 'Message Header';
        ParamMessageHeaderDesc_Lbl: Label 'Define message heading text';
        ParamMessageTextCaption_Lbl: Label 'Message Text';
        ParamMessageTextDesc_Lbl: Label 'Define message detailed text';
        ParamShowMessageCaption_Lbl: Label 'Show Message';
        ParamShowMessageDesc_Lbl: Label 'Set if you want to show a message to user';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('AudioFileUrl', '', ParamAudioFileUrlCaption_Lbl, ParamAudioFileUrlDesc_Lbl);
        WorkflowConfig.AddBooleanParameter('ShowMessage', false, ParamShowMessageCaption_Lbl, ParamShowMessageDesc_Lbl);
        WorkflowConfig.AddTextParameter('MessageText', '', ParamMessageTextCaption_Lbl, ParamMessageTextDesc_Lbl);
        WorkflowConfig.AddTextParameter('MessageHeader', '', ParamMessageHeaderCaption_Lbl, ParamMessageHeaderDesc_Lbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

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
            EanBoxEvent.Code := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent.Code));
            EanBoxEvent."Module Name" := EanBoxEventModuleName;
            EanBoxEvent.Description := CopyStr(EanBoxEventDesc, 1, MaxStrLen(EanBoxEvent.Description));
            EanBoxEvent."Action Code" := CopyStr(ActionCode(), 1, MaxStrLen(EanBoxEvent."Action Code"));
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

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionPlaySound.js###
'let main=async({parameters:i,context:l,captions:o})=>{if(i.AudioFileUrl){var e=new Audio(i.AudioFileUrl);e.play()}i.ShowMessage&&i.MessageText.length>0&&await popup.message(i.MessageText,i.MessageHeader)};'
        );
    end;
}
