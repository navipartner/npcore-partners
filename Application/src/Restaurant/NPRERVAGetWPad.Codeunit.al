﻿codeunit 6150680 "NPR NPRE RVA: Get WPad" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        NotFoundErr: Label 'The waiter pad "%1", was not found.';

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action transfer provided Waiter Pad to POS Sale and selects sales view.';
        ParamWaiterPadCode_CptLbl: Label 'Waiter Pad Code';
        ParamWaiterPadCode_DescLbl: Label 'Selected waiter pad code.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddTextParameter('WaiterPadCode', '', ParamWaiterPadCode_CptLbl, ParamWaiterPadCode_DescLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSSession: Codeunit "NPR POS Session";
        WaiterPadCode: Code[20];
    begin
        WaiterPadCode := CopyStr(Context.GetStringParameter('WaiterPadCode'), 1, MaxStrLen(WaiterPadCode));

        LoadWaiterPad(POSSession, FrontEnd, WaiterPadCode);
        SelectSalesView(POSSession);
    end;

    procedure LoadWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; WaiterPadCode: Code[20]);
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if not NPREWaiterPad.Get(WaiterPadCode) then begin
            Message(NotFoundErr, WaiterPadCode);
            exit;
        end;

        NPREWaiterPadPOSMgt.GetSaleFromWaiterPadToPOS(NPREWaiterPad, POSSession);
    end;

    procedure RequestWaiterPad(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; WaiterPadCode: Code[20]);
    var
        NPREWaiterPad: Record "NPR NPRE Waiter Pad";
        NPREFrontendAssistant: Codeunit "NPR NPRE Frontend Assistant";
    begin
        if not NPREWaiterPad.Get(WaiterPadCode) then begin
            Message(NotFoundErr, WaiterPadCode);
            exit;
        end;

        NPREFrontendAssistant.RefreshWaiterPadContent(POSSession, FrontEnd, WaiterPadCode);
    end;

    local procedure SelectSalesView(POSSession: Codeunit "NPR POS Session");
    begin
        POSSession.ChangeViewSale();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:NPRERVAGetWPad.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}
