﻿codeunit 6151287 "NPR POSAction: SS Idle Timeout" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function handles idle timeout in self service POS';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSSession: Codeunit "NPR POS Session";
    begin
        case Step of
            'IdleTimeout':
                Frontend.WorkflowResponse(ChangeToLoginScreen(POSSession, Setup));
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSIdleTimeout.js###
'let main=async({})=>await workflow.respond("IdleTimeout");'
        )
    end;

    procedure ChangeToLoginScreen(POSSession: Codeunit "NPR POS Session"; POSSetup: codeunit "NPR POS Setup"): JsonObject
    var
        POSCreateEntry: Codeunit "NPR POS Create Entry";
    begin
        POSCreateEntry.InsertUnitLockEntry(POSSetup.GetPOSUnitNo(), POSSetup.Salesperson());
        POSSession.ChangeViewLogin();
    end;
}

