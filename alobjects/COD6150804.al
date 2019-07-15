codeunit 6150804 "POS Action - Switch Register"
{
    // NPR5.38/TSA /20180104  CASE 301340 Added option to control input dialog
    // NPR5.38/MHA /20180115  CASE 302240 Added functions TestAllowRegisterSwitch() and OnValidateRegisterSwitchFilter()
    // NPR5.40/MHA /20180227  CASE 306510 Added Optionvalue "List" to Parameter "DialogType"
    // NPR5.41/MMV /20180410 CASE 307453 Changed implementation of 304310 to prevent double POS menu parse on first initialization.


    trigger OnRun()
    begin
    end;

    var
        ActionDescription: Label 'Switch to a different register';
        Prompt_EnterRegister: Label 'Enter Register';
        Text000: Label 'User %1 is not allowed to Switch to Register %2';
        Text001: Label 'User %1 is not allowed to Switch Register';

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
            //-NPR5.38 [301340]
            // RegisterWorkflowStep('', 'input(labels.prompt).respond();');
            RegisterWorkflowStep ('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input(labels.prompt).respond();}');
            RegisterWorkflowStep ('numpad', 'if (param.DialogType == param.DialogType["Numpad"]) {numpad(labels.prompt).respond();}');
            //-NPR5.40 [306510]
            //RegisterOptionParameter ('DialogType','TextField,Numpad','TextField');
            RegisterWorkflowStep ('list', 'if (param.DialogType == param.DialogType["List"]) {respond();}');
            RegisterOptionParameter ('DialogType','TextField,Numpad,List','TextField');
            //+NPR5.40 [306510]
            //+NPR5.38 [301340]

            RegisterWorkflow(false);
          end;
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150702, 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "POS Caption Management")
    begin
        Captions.AddActionCaption (ActionCode, 'prompt', Prompt_EnterRegister);
    end;

    local procedure ActionCode(): Text
    begin
        exit ('SWITCH_REGISTER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit ('1.1');
    end;

    [EventSubscriber(ObjectType::Codeunit, 6150701, 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "POS Action";WorkflowStep: Text;Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";var Handled: Boolean)
    var
        JSON: Codeunit "POS JSON Management";
        Confirmed: Boolean;
        NewRegisterNo: Code[10];
    begin
        if not Action.IsThisAction(ActionCode) then
          exit;

        //-NPR5.40 [306510]
        //SwitchRegister (Context, POSSession, FrontEnd);
        //Handled := TRUE;
        case WorkflowStep of
          'list':
            begin
              Handled := true;
              OnActionList(Context,POSSession,FrontEnd);
              exit;
            end;
          'textfield','numpad':
            begin
              Handled := true;
              JSON.InitializeJObjectParser (Context, FrontEnd);
              NewRegisterNo := CopyStr(JSON.GetString('value',true),1,MaxStrLen(NewRegisterNo));
              SwitchRegister(Context,POSSession,FrontEnd,NewRegisterNo);
            end;
        end;
        //+NPR5.40 [306510]
    end;

    local procedure OnActionList(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management")
    var
        SalePOS: Record "Sale POS";
        POSSale: Codeunit "POS Sale";
        NewRegisterNo: Code[10];
    begin
        //-NPR5.40 [306510]
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not SelectRegister(SalePOS."Register No.",NewRegisterNo) then
          exit;

        SwitchRegister (Context,POSSession,FrontEnd,NewRegisterNo);
        //+NPR5.40 [306510]
    end;

    local procedure SelectRegister(CurrRegisterNo: Code[10];var NewRegisterNo: Code[10]) LookupOK: Boolean
    var
        Register: Record Register;
        UserSetup: Record "User Setup";
    begin
        //-NPR5.40 [306510]
        UserSetup.Get(UserId);
        if not UserSetup."Allow Register Switch" then
          Error(Text001,UserSetup."User ID");

        Register.FilterGroup(41);
        Register.SetFilter("Register No.",'<>%1',CurrRegisterNo);
        Register.FilterGroup(42);
        Register.SetFilter("Register No.",UserSetup."Register Switch Filter");
        Register.FilterGroup(0);

        LookupOK := PAGE.RunModal(0,Register) = ACTION::LookupOK;
        NewRegisterNo := Register."Register No.";
        exit(LookupOK);
        //+NPR5.40 [306510]
    end;

    local procedure SwitchRegister(Context: DotNet JObject;POSSession: Codeunit "POS Session";FrontEnd: Codeunit "POS Front End Management";NewRegisterNo: Code[10])
    var
        POSUnitIdentity: Codeunit "POS Unit Identity";
        POSUnitIdentityRec: Record "POS Unit Identity";
        Setup: Codeunit "POS Setup";
        Register: Record Register;
    begin
        //-NPR5.40 [306510]
        //JSON.InitializeJObjectParser (Context, FrontEnd);
        //+NPR5.40 [306510]
        //-NPR5.38 [301340]
        //JSON.SetScope ('$', TRUE);
        //NewRegisterNo := JSON.GetString ('input', TRUE);
        //-NPR5.40 [306510]
        //NewRegisterNo := COPYSTR (JSON.GetString ('value', TRUE), 1, MAXSTRLEN (NewRegisterNo));
        //+NPR5.40 [306510]
        //+NPR5.38 [301340]

        //-NPR5.38 [302240]
        TestAllowRegisterSwitch(NewRegisterNo);
        //+NPR5.38 [302240]
        Register.setThisRegisterNo (NewRegisterNo);

        POSSession.GetSetup (Setup);

        POSUnitIdentity.SwitchToPosUnit (POSSession, NewRegisterNo, POSUnitIdentityRec);
        Setup.InitializeUsingPosUnitIdentity (POSUnitIdentityRec);

        //-NPR5.41 [307453]
        //POSSession.InitializeSession ();
        POSSession.InitializeSession (true);
        //+NPR5.41 [307453]
    end;

    local procedure "--- Test"()
    begin
    end;

    local procedure TestAllowRegisterSwitch(RegisterNo: Code[10])
    var
        Register: Record Register;
        UserSetup: Record "User Setup";
    begin
        //-NPR5.38 [302240]
        UserSetup.Get(UserId);
        if not UserSetup."Allow Register Switch" then
          Error(Text000,UserSetup."User ID",RegisterNo);
        if UserSetup."Register Switch Filter" = '' then
          exit;

        Register.Get(RegisterNo);
        Register.SetRecFilter;
        Register.FilterGroup(40);
        Register.SetFilter("Register No.",UserSetup."Register Switch Filter");
        if not Register.FindFirst then
          Error(Text000,UserSetup."User ID",RegisterNo);
        //+NPR5.38 [302240]
    end;

    [EventSubscriber(ObjectType::Table, 91, 'OnAfterValidateEvent', 'Register Switch Filter', true, true)]
    local procedure OnValidateRegisterSwitchFilter(var Rec: Record "User Setup";var xRec: Record "User Setup";CurrFieldNo: Integer)
    var
        Register: Record Register;
    begin
        //-NPR5.38 [302240]
        if Rec."Register Switch Filter" = '' then
          exit;

        Register.SetFilter("Register No.",Rec."Register Switch Filter");
        //+NPR5.38 [302240]
    end;
}

