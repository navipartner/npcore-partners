codeunit 6184626 "NPR POS Action: BG SIS Audit" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for showing BG Audit Log data.';
        ParamShowNameCaptionLbl: Label 'Show';
        ParamShowNameDescriptionLbl: Label 'Specifies the type of BG Audit Log related data you want to display.';
        ParamShowOptionCaptionsLbl: Label 'All,All Fiscalized,All Non-Fiscalized,Last Transaction';
        ParamShowOptionsLbl: Label 'All,AllFiscalized,AllNonFiscalized,LastTransaction', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Show', ParamShowOptionsLbl, '', ParamShowNameCaptionLbl, ParamShowNameDescriptionLbl, ParamShowOptionCaptionsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        ShowBGSISAuditLog(Context.GetIntegerParameter('Show'));
    end;

    local procedure ShowBGSISAuditLog(Show: Option All,AllFiscalized,AllNonFiscalized,LastTransaction)
    var
        BGSISPOSAuditLogAux, BGSISPOSAuditLogAux2 : Record "NPR BG SIS POS Audit Log Aux.";
        BGSISPOSAuditLogAuxPage: Page "NPR BG SIS POS Audit Log Aux.";
    begin
        BGSISPOSAuditLogAux.FilterGroup(10);

        case Show of
            Show::AllFiscalized:
                BGSISPOSAuditLogAux.SetFilter("Receipt Timestamp", '<>%1', '');
            Show::AllNonFiscalized:
                BGSISPOSAuditLogAux.SetRange("Receipt Timestamp", '');
            Show::LastTransaction:
                begin
                    BGSISPOSAuditLogAux2.SetLoadFields("Audit Entry Type", "Audit Entry No.");
                    BGSISPOSAuditLogAux2.SetFilter("Receipt Timestamp", '<>%1', '');
                    BGSISPOSAuditLogAux2.FindLast();

                    BGSISPOSAuditLogAux.SetRange("Audit Entry Type", BGSISPOSAuditLogAux2."Audit Entry Type");
                    BGSISPOSAuditLogAux.SetRange("Audit Entry No.", BGSISPOSAuditLogAux2."Audit Entry No.");
                end;
        end;

        BGSISPOSAuditLogAux.FilterGroup(0);
        BGSISPOSAuditLogAuxPage.SetTableView(BGSISPOSAuditLogAux);
        BGSISPOSAuditLogAuxPage.RunModal();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISAudit.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
