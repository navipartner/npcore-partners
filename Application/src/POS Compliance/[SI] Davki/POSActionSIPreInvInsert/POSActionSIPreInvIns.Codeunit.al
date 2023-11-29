codeunit 6184559 "NPR POS Action: SIPreInv Ins." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert Prenumbered Invoice Book''s information for current sale';
        SetNumberTitleLbl: Label 'Invoice Number';
        SerialNumberTitleLbl: Label 'Serial Number';
        SetNumberLbl: Label 'Sales Book Invoice Number';
        SerialNumberLbl: Label 'Sales Book Serial Number';
        SetLengthErr: Label 'Invoice Number length cannot exceed 20 digits.';
        SerialLengthErr: Label 'Serial Number length cannot exceed 40 characters.';
        ValueEmptyErr: Label 'You must input a value!';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('setnumbertitle', SetNumberTitleLbl);
        WorkflowConfig.AddLabel('serialnumbertitle', SerialNumberTitleLbl);
        WorkflowConfig.AddLabel('setnumberprompt', SetNumberLbl);
        WorkflowConfig.AddLabel('serialnumberprompt', SerialNumberLbl);
        WorkflowConfig.AddLabel('setlengtherror', SetLengthErr);
        WorkflowConfig.AddLabel('seriallengtherror', SerialLengthErr);
        WorkflowConfig.AddLabel('valueemptyerror', ValueEmptyErr);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        case Step of
            'InsertSetSerialNumbers':
                InputAuditPreInvoiceNumbers(Context, Sale);
        end;
    end;

    local procedure InputAuditPreInvoiceNumbers(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        SIPOSSale: Record "NPR SI POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        SIPOSSale."POS Sale SystemId" := POSSale.SystemId;
        SIPOSSale."SI Set Number" := CopyStr(Context.GetString('SetNumberNo'), 1, MaxStrLen(SIPOSSale."SI Set Number"));
        SIPOSSale."SI Serial Number" := CopyStr(Context.GetString('SerialNumberNo'), 1, MaxStrLen(SIPOSSale."SI Serial Number"));
        if not SIPOSSale.Insert() then
            SIPOSSale.Modify();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSIPreInvIns.js###
        'let main = async ({ workflow, popup, captions }) => {let SetNumber = await popup.input({ title: captions.setnumbertitle, caption: captions.setnumberprompt});if (SetNumber.length>20){await popup.error(captions.setlengtherror);return(" ");}let SerialNumber = await popup.input({ title: captions.serialnumbertitle, caption: captions.serialnumberprompt});if (SerialNumber.length>40){await popup.error(captions.seriallengtherror);return(" ");}if (SetNumber === null || SetNumber === "" || SerialNumber === null || SerialNumber === "") return;return await workflow.respond("InsertSetSerialNumbers", { SetNumberNo: SetNumber, SerialNumberNo: SerialNumber });}'
    )
    end;
}