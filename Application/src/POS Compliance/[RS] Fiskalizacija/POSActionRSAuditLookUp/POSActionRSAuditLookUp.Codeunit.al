codeunit 6150956 "NPR POS Action: RSAudit Lookup" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for displaying RS Audit transactions log.';
        ParameterShow_NameCaptionLbl: Label 'Show';
        ParameterShow_NameDescriptionLbl: Label 'Specifies the type of RS Audit related data you want to display.';
        ParameterShow_OptionCaptionsLbl: Label 'All,All Fiscalised,All Non-Fiscalised,Last Transaction';
        ParameterShow_OptionsLbl: Label 'All,AllFiscalised,AllNonFiscalised,LastTransaction', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter(
            ParameterShow_Name(),
            ParameterShow_OptionsLbl,
#pragma warning disable AA0139
            SelectStr(1, ParameterShow_OptionsLbl),
#pragma warning restore
            ParameterShow_NameCaptionLbl,
            ParameterShow_NameDescriptionLbl,
            ParameterShow_OptionCaptionsLbl
        );
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionRSAuditLookUp.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction;
    begin
        ParameterShow := Context.GetIntegerParameter(ParameterShow_Name());
        case ParameterShow of
            ParameterShow::All:
                ShowAllRSAuditLog(ParameterShow);
            ParameterShow::AllFiscalised:
                ShowAllRSAuditLog(ParameterShow);
            ParameterShow::AllNonFiscalised:
                ShowAllRSAuditLog(ParameterShow);
            ParameterShow::LastTransaction:
                ShowLastRSAuditLog();
        end;
    end;

    local procedure ParameterShow_Name(): Text[30]
    begin
        exit('Show');
    end;

    local procedure ShowAllRSAuditLog(ParameterShow: Option All,AllFiscalised,AllNonFiscalised,LastTransaction)
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfoPage: Page "NPR RS POS Audit Log Aux. Info";
    begin
        case ParameterShow of
            ParameterShow::AllFiscalised:
                RSPOSAuditLogAuxInfo.SetFilter(Journal, '<>%1', '');
            ParameterShow::AllNonFiscalised:
                RSPOSAuditLogAuxInfo.SetFilter(Journal, '%1', '');
        end;
        RSPOSAuditLogAuxInfoPage.SetTableView(RSPOSAuditLogAuxInfo);
        RSPOSAuditLogAuxInfoPage.RunModal();
    end;

    local procedure ShowLastRSAuditLog()
    var
        RSPOSAuditLogAuxInfo: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfo2: Record "NPR RS POS Audit Log Aux. Info";
        RSPOSAuditLogAuxInfoPage: Page "NPR RS POS Audit Log Aux. Info";
    begin
        RSPOSAuditLogAuxInfo.SetLoadFields("Audit Entry Type", "Audit Entry No.");
        RSPOSAuditLogAuxInfo.SetFilter(Journal, '<>%1', '');
        RSPOSAuditLogAuxInfo.FindLast();
        RSPOSAuditLogAuxInfo2.SetRange("Audit Entry Type", RSPOSAuditLogAuxInfo."Audit Entry Type");
        RSPOSAuditLogAuxInfo2.SetRange("Audit Entry No.", RSPOSAuditLogAuxInfo."Audit Entry No.");
        RSPOSAuditLogAuxInfoPage.SetTableView(RSPOSAuditLogAuxInfo2);
        RSPOSAuditLogAuxInfoPage.RunModal();
    end;
}
