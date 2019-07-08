codeunit 6150820 "POS Action - Run Object"
{
    // NPR5.33/ANEN  /20170607 CASE 270854 Object created to support function for filtererd menu buttons in transcendance pos.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'This is a built-in action for running a page';
        PageMissingError: Label 'That page was not found.';
        POSSetup: Codeunit "POS Setup";

    local procedure ActionCode(): Text
    begin
        exit ('RUNOBJECT');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.0');
    end;

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "POS Action")
    begin
        with Sender do
          if DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Type::Generic,
            "Subscriber Instances Allowed"::Multiple)
          then begin
            RegisterWorkflowStep('1','respond();');
            RegisterWorkflow(false);
            RegisterTextParameter ('MenuFilterCode', '');
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnBeforeWorkflow', '', false, false)]
    local procedure OnBeforeWorkflow("Action": Record "POS Action";POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        Context: Codeunit "POS JSON Management";
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        Handled := true;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        ObjectId: Integer;
        ObjectType: Integer;
        MenuFilterCode: Code[20];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        JSON.InitializeJObjectParser(Context,FrontEnd);
        JSON.SetScope('parameters',true);

        MenuFilterCode := JSON.GetString('MenuFilterCode', true);
        RunObject(MenuFilterCode, POSSession);
        Handled := true;
    end;

    local procedure "-- Locals --"()
    begin
    end;

    local procedure RunObject(MenuFilterCode: Code[20];POSSession: Codeunit "POS Session")
    var
        POSMenuFilter: Record "POS Menu Filter";
    begin
        POSMenuFilter.SetFilter("Filter Code", '=%1', MenuFilterCode);
        POSMenuFilter.FindFirst;
        POSMenuFilter.RunObjectWithFilter(POSMenuFilter, POSSession);
    end;
}

