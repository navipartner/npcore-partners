codeunit 6150820 "NPR POS Action: Run Object"
{
    var
        ActionDescription: Label 'This is a built-in action for running a page';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Code[20]
    begin
        exit('RUNOBJECT');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('1.0');
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
            Sender.RegisterWorkflowStep('1', 'respond();');
            Sender.RegisterWorkflow(false);
            Sender.RegisterTextParameter('MenuFilterCode', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        MenuFilterCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        MenuFilterCode := CopyStr(JSON.GetStringOrFail('MenuFilterCode', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(MenuFilterCode));
        RunObject(MenuFilterCode, POSSession);
        Handled := true;
    end;

    local procedure RunObject(MenuFilterCode: Code[20]; POSSession: Codeunit "NPR POS Session")
    var
        POSMenuFilter: Record "NPR POS Menu Filter";
    begin
        POSMenuFilter.SetFilter("Filter Code", '=%1', MenuFilterCode);
        POSMenuFilter.FindFirst();
        POSMenuFilter.RunObjectWithFilter(POSMenuFilter, POSSession);
    end;
}
