codeunit 6150843 "NPR POS Action: Item Prompt"
{

    var
        ActionDescription: Label 'This action prompts for a numeric item number';
        Title: Label 'We need more information.';
        Caption: Label 'Item Number';

    local procedure ActionCode(): Text
    begin
        exit('ITEM_PROMPT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.1');
    end;

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

            Sender.RegisterWorkflowStep('itemnumber', 'numpad ({title: labels.Title, caption: labels.Caption}).cancel(abort);');
            Sender.RegisterWorkflowStep('invokewf', 'respond();');
            Sender.RegisterWorkflow(false);

        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', true, true)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode(), 'Title', Title);
        Captions.AddActionCaption(ActionCode(), 'Caption', Caption);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        POSAction: Record "NPR POS Action";
        Item: Record Item;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
        JSON.InitializeJObjectParser(Context, FrontEnd);

        if not POSSession.RetrieveSessionAction('ITEM', POSAction) then
            POSAction.Get('ITEM');
        POSAction.SetWorkflowInvocationParameter('itemNo', CopyStr(GetNumpad(JSON, 'itemnumber'), 1, MaxStrLen(Item."No.")), FrontEnd);
        FrontEnd.InvokeWorkflow(POSAction);
    end;

    local procedure GetNumpad(JSON: Codeunit "NPR POS JSON Management"; Path: Text): Text
    begin

        JSON.SetScopeRoot();
        if (not JSON.SetScope('$' + Path)) then
            exit('');

        exit(JSON.GetString('numpad'));
    end;
}

