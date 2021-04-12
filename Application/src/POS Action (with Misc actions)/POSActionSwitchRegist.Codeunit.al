codeunit 6150804 "NPR POS Action: Switch Regist."
{
    var
        ActionDescription: Label 'Switch to a different register';
        Prompt_EnterRegister: Label 'Enter Register';
        Text000: Label 'User %1 is not allowed to Switch to Register %2';
        Text001: Label 'User %1 is not allowed to Switch Register';
        ReadingErr: Label 'reading in %1';

    [EventSubscriber(ObjectType::Table, 6150703, 'OnDiscoverActions', '', false, false)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    begin
        if Sender.DiscoverAction(
            ActionCode,
            ActionDescription,
            ActionVersion,
            Sender.Type::Generic,
            Sender."Subscriber Instances Allowed"::Multiple)
        then begin
            Sender.RegisterWorkflowStep('textfield', 'if (param.DialogType == param.DialogType["TextField"]) {input(labels.prompt).respond();}');
            Sender.RegisterWorkflowStep('numpad', 'if (param.DialogType == param.DialogType["Numpad"]) {numpad(labels.prompt).respond();}');
            Sender.RegisterWorkflowStep('list', 'if (param.DialogType == param.DialogType["List"]) {respond();}');
            Sender.RegisterOptionParameter('DialogType', 'TextField,Numpad,List', 'TextField');

            Sender.RegisterWorkflow(false);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS UI Management", 'OnInitializeCaptions', '', false, false)]
    local procedure OnInitializeCaptions(Captions: Codeunit "NPR POS Caption Management")
    begin
        Captions.AddActionCaption(ActionCode, 'prompt', Prompt_EnterRegister);
    end;

    local procedure ActionCode(): Text
    begin
        exit('SWITCH_REGISTER');
    end;

    local procedure ActionVersion(): Text
    begin
        exit('1.2');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS JavaScript Interface", 'OnAction', '', false, false)]
    local procedure OnAction("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    var
        JSON: Codeunit "NPR POS JSON Management";
        Confirmed: Boolean;
        NewRegisterNo: Code[10];
    begin
        if not Action.IsThisAction(ActionCode) then
            exit;

        case WorkflowStep of
            'list':
                begin
                    Handled := true;
                    OnActionList(Context, POSSession, FrontEnd);
                    exit;
                end;
            'textfield', 'numpad':
                begin
                    Handled := true;
                    JSON.InitializeJObjectParser(Context, FrontEnd);
                    NewRegisterNo := CopyStr(JSON.GetStringOrFail('value', StrSubstNo(ReadingErr, ActionCode())), 1, MaxStrLen(NewRegisterNo));
                    SwitchRegister(Context, POSSession, FrontEnd, NewRegisterNo);
                end;
        end;
    end;

    local procedure OnActionList(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        NewRegisterNo: Code[10];
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not SelectRegister(SalePOS."Register No.", NewRegisterNo) then
            exit;

        SwitchRegister(Context, POSSession, FrontEnd, NewRegisterNo);
    end;

    local procedure SelectRegister(CurrUnitNo: Code[10]; var NewUnitNo: Code[10]) LookupOK: Boolean
    var
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        if not UserSetup."NPR Allow Register Switch" then
            Error(Text001, UserSetup."User ID");

        POSUnit.FilterGroup(41);
        POSUnit.SetFilter("No.", '<>%1', CurrUnitNo);
        POSUnit.FilterGroup(42);
        POSUnit.SetFilter("No.", UserSetup."NPR Register Switch Filter");
        POSUnit.FilterGroup(0);

        LookupOK := PAGE.RunModal(0, POSUnit) = ACTION::LookupOK;
        NewUnitNo := POSUnit."No.";
        exit(LookupOK);
    end;

    local procedure SwitchRegister(Context: JsonObject; POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; NewUnitNo: Code[10])
    var
        POSUnitIdentity: Codeunit "NPR POS Unit Identity";
        POSUnitIdentityRec: Record "NPR POS Unit Identity";
        Setup: Codeunit "NPR POS Setup";
        POSUnit: Record "NPR POS Unit";
    begin
        TestAllowUnitSwitch(NewUnitNo);
        POSUnit.SetThisUnitNo(NewUnitNo);

        POSSession.GetSetup(Setup);

        POSUnitIdentity.SwitchToPosUnit(POSSession, NewUnitNo, POSUnitIdentityRec);
        Setup.InitializeUsingPosUnitIdentity(POSUnitIdentityRec);

        POSSession.InitializeSession(true);
    end;

    local procedure TestAllowUnitSwitch(UnitNo: Code[10])
    var
        PSOUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
    begin
        UserSetup.Get(UserId);
        if not UserSetup."NPR Allow Register Switch" then
            Error(Text000, UserSetup."User ID", UnitNo);
        if UserSetup."NPR Register Switch Filter" = '' then
            exit;

        PSOUnit.Get(UnitNo);
        PSOUnit.SetRecFilter;
        PSOUnit.FilterGroup(40);
        PSOUnit.SetFilter("No.", UserSetup."NPR Register Switch Filter");
        if not PSOUnit.FindFirst() then
            Error(Text000, UserSetup."User ID", UnitNo);
    end;

    [EventSubscriber(ObjectType::Table, Database::"User Setup", 'OnAfterValidateEvent', 'NPR Register Switch Filter', true, true)]
    local procedure OnValidateRegisterSwitchFilter(var Rec: Record "User Setup"; var xRec: Record "User Setup"; CurrFieldNo: Integer)
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if Rec."NPR Register Switch Filter" = '' then
            exit;

        POSUnit.SetFilter("No.", Rec."NPR Register Switch Filter");
    end;
}
