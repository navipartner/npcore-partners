codeunit 6150722 "NPR POS Action: Text Enter"
{
    var
        ActionDescription: Label 'This is a built-in action for completing the TextEnter request passed from the front end (when user presses enter in a supported text box)';
        Text001: Label 'Control %1 has just sent an %2 event, but it appears that events for this control are not handled.';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('TEXT_ENTER');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        Sender.DiscoverAction(
          ActionCode(),
          ActionDescription,
          ActionVersion(),
          Sender.Type::BackEnd,
          Sender."Subscriber Instances Allowed"::Single);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        EanBoxEventHandler: Codeunit "NPR POS Input Box Evt Handler";
        ControlId: Text;
        Value: Text;
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        ControlId := JSON.GetString('id');
        if (ControlId = '') then
            ControlId := '<blank>';

        Value := JSON.GetStringOrFail('value', StrSubstNo(ReadingErr, ActionCode()));

        case ControlId of
            'EanBox':
                EanBoxEventHandler.InvokeEanBox(Value, Context, POSSession, FrontEnd);
            'PaymentBox':
                ;
            else
                FrontEnd.ReportBugAndThrowError(StrSubstNo(Text001, ControlId, ActionCode()));
        end;

        Handled := true;
    end;
}
