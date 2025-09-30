codeunit 6150785 "NPR POS Action: DE Data Export" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for DE Data Export management.';
        ParamActionNameCaptionLbl: Label 'Action';
        ParamActionNameDescriptionLbl: Label 'Specifies the type of DE Data Export related data you want to display.';
        ParamActionOptionCaptionsLbl: Label 'Open Page,Create';
        ParamActionOptionsLbl: Label 'OpenPage,Create', Locked = true;
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddOptionParameter('Action', ParamActionOptionsLbl, '', ParamActionNameCaptionLbl, ParamActionNameDescriptionLbl, ParamActionOptionCaptionsLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSUnit: Record "NPR POS Unit";
        ParamShowOptions: Option OpenPage,Create;
    begin
        case Context.GetIntegerParameter('Action') of
            ParamShowOptions::OpenPage:
                ShowDEDataExportPage();
            ParamShowOptions::Create:
                begin
                    Setup.GetPOSUnit(POSUnit);
                    CreateAndShowDEDataExport(POSUnit);
                end;
        end;
    end;

    local procedure ShowDEDataExportPage()
    var
        DEDataExports: Page "NPR DE Data Exports";
    begin
        DEDataExports.RunModal();
    end;

    local procedure CreateAndShowDEDataExport(POSUnit: Record "NPR POS Unit")
    var
        DEDataExport: Record "NPR DE Data Export";
        DEPOSUnitAuxInfo: Record "NPR DE POS Unit Aux. Info";
        DEDataExportCard: Page "NPR DE Data Export Card";
    begin
        DEPOSUnitAuxInfo.Get(POSUnit."No.");

        DEDataExport.Init();
        DEDataExport."TSS Code" := DEPOSUnitAuxInfo."TSS Code";
        DEDataExport.Insert(true);
        Commit();

        DEDataExportCard.SetRecord(DEDataExport);
        DEDataExportCard.RunModal();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionDEDataExport.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}