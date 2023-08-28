codeunit 6151004 "NPR POS Action: SavePOSSvSl" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParamConfirmBeforeSave_CptLbl: Label 'Confirm before sale';
        ParamConfirmBeforeSale_DescLbl: Label 'Defines if confirm before sales is needed';
        ParamConfirmText_CptLbl: Label 'Confirm Text';
        ParamConfirmText_DescLbl: Label 'Defines confirm text';
        ParamPrintAfterSave_CptLbl: Label 'Print After Save';
        ParamPrintAfterSave_DescLbl: Label 'Defines if the system is going to print confirmation of saved sale';
        ParamPrintTemplate_CptLbl: Label 'Print Template';
        ParamPrintTemplate_DescLbl: Label 'Defines Print Template for printing after save';
        ParamFullBackup_CptLbl: Label 'Full Backup';
        ParamFullBackup_DescLbl: Label 'Full Backup';
        Text002: Label 'Save current Sale as POS Quote?';
        ActionDescription: Label 'Save POS Sale as POS Quote';
        Text001: Label 'POS Quote';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('ConfirmBeforeSave', true, ParamConfirmBeforeSave_CptLbl, ParamConfirmBeforeSale_DescLbl);
        WorkflowConfig.AddTextParameter('ConfirmText', Text002, ParamConfirmText_CptLbl, ParamConfirmText_DescLbl);
        WorkflowConfig.AddBooleanParameter('PrintAfterSave', false, ParamPrintAfterSave_CptLbl, ParamPrintAfterSave_DescLbl);
        WorkflowConfig.AddTextParameter('PrintTemplate', '', ParamPrintTemplate_CptLbl, ParamPrintTemplate_DescLbl);
        WorkflowConfig.AddBooleanParameter('FullBackup', false, ParamFullBackup_CptLbl, ParamFullBackup_DescLbl);
        WorkflowConfig.AddLabel('ConfirmLabel', Text001);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, true)]
    local procedure OnLookupPrintTemplate(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean)
    var
        RPTemplateHeader: Record "NPR RP Template Header";
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;
        if POSParameterValue.Name <> 'PrintTemplate' then
            exit;
        if POSParameterValue."Data Type" <> POSParameterValue."Data Type"::Text then
            exit;

        Handled := true;

        RPTemplateHeader.SetRange("Table ID", DATABASE::"NPR POS Saved Sale Entry");
        if PAGE.RunModal(0, RPTemplateHeader) = ACTION::LookupOK then
            POSParameterValue.Value := RPTemplateHeader.Code;
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var

    begin
        case Step of
            'save_as_quote':
                SaveAsQuote(Context);
        end;
    end;

    local procedure SaveAsQuote(Context: Codeunit "NPR POS JSON Helper")
    var
        POSQuoteEntry: Record "NPR POS Saved Sale Entry";
        PrintAfterSave: Boolean;
        PrintTemplateCode: Code[20];
        POSActSavePOSSvSlB: Codeunit "NPR POS Action: SavePOSSvSl B";
    begin
        POSActSavePOSSvSlB.SaveSaleAndStartNewSale(POSQuoteEntry);

        PrintAfterSave := Context.GetBooleanParameter('PrintAfterSave');

        if not PrintAfterSave then
            exit;

        PrintTemplateCode := CopyStr(Context.GetStringParameter('PrintTemplate'), 1, MaxStrLen(PrintTemplateCode));

        POSActSavePOSSvSlB.PrintAfterSave(PrintTemplateCode, POSQuoteEntry);
    end;

    local procedure ActionCode(): Code[20]
    begin
        exit(Format(Enum::"NPR POS Workflow"::SAVE_AS_POS_QUOTE));
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSavePOSSvSl.js###
'let main=async({parameters:e,captions:o})=>{if(e.ConfirmBeforeSave){if(await popup.confirm(e.ConfirmText,o.ConfirmLabel,!0,!0))return await workflow.respond("save_as_quote")}else return await workflow.respond("save_as_quote")};'
        );
    end;
}

