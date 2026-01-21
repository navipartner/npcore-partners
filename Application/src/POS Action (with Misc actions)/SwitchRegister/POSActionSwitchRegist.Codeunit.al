codeunit 6059980 "NPR POS Action: Switch Regist." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActSwitchRegB: Codeunit "NPR POS Action: Switch RegistB";
        NewPOSSwitchRegister: Codeunit "NPR New POS Sw. Regis. Feature";

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Switch to a different register';
        EnterRegisterPromptLbl: Label 'Enter Register';
        ParameterDialogType_OptionNameLbl: Label 'TextField,Numpad,List', Locked = true;
        ParameterDialogType_OptionCaptionsLbl: Label 'TextField,Numpad,List';
        ParameterDialogType_NameLbl: Label 'DialogType';
        FilterByPosUnitGroupName: Label 'FilterByPosUnitGroup';
        FilterByPosUnitGroupDesc: Label 'Pos Unit list will be filtered by selected Pos Unit Group on Salesperson';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);

        if not NewPOSSwitchRegister.IsFeatureEnabled() then begin
            WorkflowConfig.AddOptionParameter('DialogType',
#pragma warning disable AA0139
                ParameterDialogType_OptionNameLbl,
                SelectStr(1, ParameterDialogType_OptionNameLbl),
#pragma warning restore
                ParameterDialogType_NameLbl,
                ParameterDialogType_NameLbl,
                ParameterDialogType_OptionCaptionsLbl);
        end;
        WorkflowConfig.AddBooleanParameter('FilterByPosUnitGroup', false, FilterByPosUnitGroupName, FilterByPosUnitGroupDesc);
        WorkflowConfig.AddLabel('registerprompt', EnterRegisterPromptLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'EnterRegister':
                SwitchToNewRegister(Context, Setup);
            else
                if not OnActionList(Setup, Sale, Context) then
                    exit;
        end;
        InitAndRefreshFrontendSession();
    end;

    internal procedure SwitchToNewRegister(Context: Codeunit "NPR POS JSON Helper"; Setup: Codeunit "NPR POS Setup")
    var
        NewRegisterNo: Code[10];
    begin
        NewRegisterNo := CopyStr(Context.GetString('RegisterNo'), 1, MaxStrLen(NewRegisterNo));
        POSActSwitchRegB.SwitchRegister(NewRegisterNo, Setup);
    end;

    local procedure OnActionList(Setup: Codeunit "NPR POS Setup"; POSSale: Codeunit "NPR POS Sale"; Context: Codeunit "NPR POS JSON Helper"): Boolean
    var
        FilterByPosUnitGroupValue: Boolean;
    begin
        Context.GetBooleanParameter('FilterByPosUnitGroup', FilterByPosUnitGroupValue);
        exit(POSActSwitchRegB.OnActionList(Setup, POSSale, FilterByPosUnitGroupValue));
    end;

    local procedure InitAndRefreshFrontendSession()
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.InitializeSession(true);
        POSSession.RequestFullRefresh();
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

    local procedure GetActionScript(): Text
    begin
        if NewPOSSwitchRegister.IsFeatureEnabled() then
            EXIT(
                //###NPR_INJECT_FROM_FILE:POSActionSwitchRegisterCustomList.js###
                'let main=async({workflow:r,customList:s,toast:n})=>{try{const e=await s.setParameters({topic:"POS_UNIT",maxPageSize:50});if(e){const t=JSON.parse(e).fields?.["1"];if(!t)return" ";await r.respond("EnterRegister",{RegisterNo:t})}else return" "}catch(e){return console.error("[SwitchRegister] Unexpected error:",e),n.error(e?.message||"An unexpected error occurred",{title:"Unable to Complete Action",hideAfter:5})," "}};'
            );

        EXIT(
            //###NPR_INJECT_FROM_FILE:POSActionSwitchRegister.js###
            'let main=async({workflow:a,parameters:n,popup:i,captions:r})=>{const t={TextField:0,Numpad:1,List:2};switch(n._parameters.DialogType){case t.TextField:var e=await i.input({caption:r.registerprompt});if(e===null)return" ";await a.respond("EnterRegister",{RegisterNo:e});break;case t.Numpad:var e=await i.numpad({caption:r.registerprompt});if(e===null)return" ";await a.respond("EnterRegister",{RegisterNo:e});break;case t.List:await a.respond();break}};'
        );
    end;
}

