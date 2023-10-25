codeunit 6184558 "NPR POS Action: CROParagon Ins" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert a Paragon number for current sale';
        ParagonNumberTitleLbl: Label 'Paragon Bill Number';
        ParagonNumberLbl: Label 'Paragon Number';
        TooLongErr: Label 'Paragon Number cannot have more than 40 characters.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('title', ParagonNumberTitleLbl);
        WorkflowConfig.AddLabel('paragonprompt', ParagonNumberLbl);
        WorkflowConfig.AddLabel('lengtherror', TooLongErr);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'InsertParagonNumber':
                InputAuditParagonNumber(Context, Sale);
        end;
    end;

    local procedure InputAuditParagonNumber(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        CROPOSSale: Record "NPR CRO POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        CROPOSSale."POS Sale SystemId" := POSSale.SystemId;
        CROPOSSale."CRO Paragon Number" := CopyStr(Context.GetString('ParagonNo'), 1, MaxStrLen(CROPOSSale."CRO Paragon Number"));
        if not CROPOSSale.Insert() then
            CROPOSSale.Modify();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionCROParagonIns.js###
        'let main = async ({ workflow, popup, captions }) => {let Paragon = await popup.input({ title: captions.title, caption: captions.paragonprompt});if (Paragon.length > 40) {await popup.error(captions.lengtherror);return(" ");}if (Paragon === null || Paragon === "") return;return await workflow.respond("InsertParagonNumber", { ParagonNo: Paragon });}'
    )
    end;
}