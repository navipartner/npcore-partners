codeunit 6059980 "NPR POS Action: Switch Regist." implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        POSActSwitchRegB: Codeunit "NPR POS Action: Switch RegistB";

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Switch to a different register';
        FilterByPosUnitGroupName: Label 'FilterByPosUnitGroup';
        FilterByPosUnitGroupDesc: Label 'Pos Unit list will be filtered by selected Pos Unit Group on Salesperson';
        SelectPOSUnitTitleLbl: Label 'Select a POS unit';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);

        WorkflowConfig.AddBooleanParameter('FilterByPosUnitGroup', false, FilterByPosUnitGroupName, FilterByPosUnitGroupDesc);
        WorkflowConfig.AddLabel('selectPOSUnitTitle', SelectPOSUnitTitleLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'is_workflow_disabled':
                begin
                    IsWorkflowDisabled(Context, FrontEnd);
                    exit; 
                end;
            'EnterRegister':
                SwitchToNewRegister(Context, Setup);
            else
                if not OnActionList(Setup, Sale, Context) then
                    exit;
        end;
        InitAndRefreshFrontendSession();
    end;

    local procedure IsWorkflowDisabled(Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        UserSetup: Record "User Setup";
    begin
        if UserSetup.Get(UserId) then
            Context.SetContext('disabled', not UserSetup."NPR Allow Register Switch")
        else
            Context.SetContext('disabled', true);

        FrontEnd.WorkflowResponse(Context.GetContextObject());
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
        exit(
            //###NPR_INJECT_FROM_FILE:POSActionSwitchRegister.js###
            'let isWorkflowDisabled=async({workflow:r})=>{try{return await r.respond("is_workflow_disabled")||!1}catch(t){return console.error("[SwitchRegister] Permission check failed:",t),!0}},main=async({workflow:r,customList:t,toast:i,captions:o})=>{try{const e=await t.setParameters({topic:"POS_UNIT",maxPageSize:50,title:o.selectPOSUnitTitle});if(e){const s=JSON.parse(e).fields?.["1"];if(!s)return" ";await r.respond("EnterRegister",{RegisterNo:s})}else return" "}catch(e){return console.error("[SwitchRegister] Unexpected error:",e),i.error(e?.message||"An unexpected error occurred",{title:"Unable to Complete Action",hideAfter:5})," "}};'
        );
    end;
}

