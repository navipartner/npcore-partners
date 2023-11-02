codeunit 6184580 "NPR POSAction SS PrintReceipt" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for printing a receipt for the previous transaction intended for self-service usage.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        BusinessLogicRun: Codeunit "NPR POS Action: Print Rcpt.-B";
        SettingOption: Option "Last Receipt","Last Receipt Large","Choose Receipt","Choose Receipt Large","Last Receipt and Balance","Last Receipt and Balance Large","Last Balance","Last Balance Large";
        ReceiptListFilterOption: Option "None","POS Store","POS Unit",Salesperson;
        SelectionDialogType: Option TextField,List;
        PresetTableView: Text;
        ManualReceiptNo: Code[20];
        ObfuscationMethod: Option None,MI;
        PrintTickets: Boolean;
        PrintMemberships: Boolean;
        PrintRetailVoucher: Boolean;
        PrintTerminalReceipt: Boolean;
        PrintTaxFreeVoucher: Boolean;
    begin

        SettingOption := SettingOption::"Last Receipt";
        ReceiptListFilterOption := ReceiptListFilterOption::"POS Unit";
        PresetTableView := '';
        SelectionDialogType := SelectionDialogType::List;
        ManualReceiptNo := '';
        ObfuscationMethod := ObfuscationMethod::None;

        PrintTickets := false;
        PrintMemberships := false;
        PrintRetailVoucher := false;
        PrintTerminalReceipt := true;
        PrintTaxFreeVoucher := false;

        BusinessLogicRun.PrintReceipt(SettingOption,
                                    ReceiptListFilterOption,
                                    PresetTableView,
                                    SelectionDialogType,
                                    ManualReceiptNo,
                                    ObfuscationMethod,
                                    PrintTickets,
                                    PrintMemberships,
                                    PrintRetailVoucher,
                                    PrintTerminalReceipt,
                                    PrintTaxFreeVoucher);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSPrintReceipt.js###
'let main=async({workflow:a})=>{await a.respond("")};'
        );
    end;
}
