codeunit 6059980 "NPR POS Action: Switch Regist." implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Switch to a different register';
        EnterRegisterPromptLbl: Label 'Enter Register';
        ParameterDialogType_OptionNameLbl: Label 'TextField,Numpad,List', Locked = true;
        ParameterDialogType_OptionCaptionsLbl: Label 'TextField,Numpad,List';
        ParameterDialogType_NameLbl: Label 'DialogType';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('DialogType',
            ParameterDialogType_OptionNameLbl,
            SelectStr(1, ParameterDialogType_OptionNameLbl),
            ParameterDialogType_NameLbl,
            ParameterDialogType_NameLbl,
            ParameterDialogType_OptionCaptionsLbl);
        WorkflowConfig.AddLabel('registerprompt', EnterRegisterPromptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'EnterRegister':
                FrontEnd.WorkflowResponse(SwitchToNewRegister(Context, Setup));
            else
                FrontEnd.WorkflowResponse(OnActionList(Setup));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        EXIT(
        //###NPR_INJECT_FROM_FILE:POSActionSwitchRegister.js###
'let main=async({workflow:a,parameters:n,popup:i,captions:r})=>{const t={TextField:0,Numpad:1,List:2};switch(n._parameters.DialogType){case t.TextField:var e=await i.input({caption:r.registerprompt});if(e===null)return" ";await a.respond("EnterRegister",{RegisterNo:e});break;case t.Numpad:var e=await i.numpad({caption:r.registerprompt});if(e===null)return" ";await a.respond("EnterRegister",{RegisterNo:e});break;case t.List:await a.respond();break}};'
        );
    end;

    internal procedure SwitchToNewRegister(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup"): JsonObject
    var
        NewRegisterNo: Code[10];
    begin
        NewRegisterNo := CopyStr(Context.GetString('RegisterNo'), 1, MaxStrLen(NewRegisterNo));
        SwitchRegister(NewRegisterNo, Setup);
    end;

    local procedure TestAllowUnitSwitch(UnitNo: Code[10])
    var
        PSOUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        Text000: Label 'User %1 is not allowed to Switch to Register %2';
    begin
        UserSetup.Get(UserId);
        if not UserSetup."NPR Allow Register Switch" then
            Error(Text000, UserSetup."User ID", UnitNo);
        if UserSetup."NPR Register Switch Filter" = '' then
            exit;

        PSOUnit.Get(UnitNo);
        PSOUnit.SetRecFilter();
        PSOUnit.FilterGroup(40);
        PSOUnit.SetFilter("No.", UserSetup."NPR Register Switch Filter");
        if not PSOUnit.FindFirst() then
            Error(Text000, UserSetup."User ID", UnitNo);
    end;


    local procedure OnActionList(Setup: Codeunit "NPR POS Setup"): JsonObject
    var
        POSSession: Codeunit "NPR POS Session";
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
        NewRegisterNo: Code[10];
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        if not SelectRegister(SalePOS."Register No.", NewRegisterNo) then
            exit;
        SwitchRegister(NewRegisterNo, Setup);
    end;

    local procedure SelectRegister(CurrUnitNo: Code[10]; var NewUnitNo: Code[10]) LookupOK: Boolean
    var
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
        Text001: Label 'User %1 is not allowed to Switch Register';
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

    internal procedure SwitchRegister(RegisterNo: code[10]; Setup: Codeunit "NPR POS Setup")
    var
        UserSetup: Record "User Setup";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
    begin
        TestAllowUnitSwitch(RegisterNo);

        UserSetup.Get(UserId);
        UserSetup.Validate("NPR POS Unit No.", RegisterNo);
        UserSetup.Modify();

        POSUnit.Get(RegisterNo);
        Setup.SetPOSUnit(POSUnit);
        POSSession.InitializeSession(true);
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

