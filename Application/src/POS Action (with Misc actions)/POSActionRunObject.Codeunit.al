codeunit 6150820 "NPR POS Action: Run Object"
{
    var
        ActionDescription: Label 'This is a built-in action for running a page';
        ReadingErr: Label 'reading in %1';

    local procedure ActionCode(): Text
    begin
        exit('RUNOBJECT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        with Sender do
            if DiscoverAction(
              ActionCode,
              ActionDescription,
              ActionVersion,
              Type::Generic,
              "Subscriber Instances Allowed"::Multiple)
            then begin
                RegisterWorkflowStep('1', 'respond();');
                RegisterWorkflow(false);
                RegisterTextParameter('MenuFilterCode', '');
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "NPR POS Action"; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        Context: Codeunit "NPR POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        ObjectId: Integer;
        ObjectType: Integer;
        MenuFilterCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        JSON.InitializeJObjectParser(Context, FrontEnd);
        JSON.SetScopeParameters(ActionCode());

        MenuFilterCode := JSON.GetStringOrFail('MenuFilterCode', StrSubstNo(ReadingErr, ActionCode()));
        RunObject(MenuFilterCode, POSSession);
        Handled := true;
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure RunObject(MenuFilterCode: Code[20]; POSSession: Codeunit "NPR POS Session")
    var
        POSMenuFilter: Record "NPR POS Menu Filter";
    begin
        POSMenuFilter.SetFilter("Filter Code", '=%1', MenuFilterCode);
        POSMenuFilter.FindFirst;
        POSMenuFilter.RunObjectWithFilter(POSMenuFilter, POSSession);
    end;
}
