codeunit 6248687 "NPR POS Action: BG SIS Return" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Insert Receipt Information for Return Sale';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        InsertReturnInfo(Sale);
    end;

    local procedure InsertReturnInfo(Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        BGSISPOSSale: Record "NPR BG SIS POS Sale";
        InputDialog: Page "NPR Input Dialog";
        ReceiptDate: Date;
        ReceiptTime: Time;
        ReturnFPMemoryNo: Text;
        ReturnFPDeviceNo: Text;
        ReturnExtReceiptCounter: Code[50];
        ReturnGrandReceiptNo: Text;
        ReceiptDateLbl: Label 'Receipt Date';
        ReceiptTimeLbl: Label 'Receipt Time';
        ReturnFPMemoryNoLbl: Label 'Fiscal Printer Memory No.';
        ReturnFPDeviceNoLbl: Label 'Fiscal Printer Device No.';
        ReturnExtReceiptCounterLbl: Label 'Extended Receipt Counter';
        ReturnGrandReceiptNoLbl: Label 'Grand Receipt No.';
        AllReceiptInfoNeededErr: Label 'You must input all return receipt data.';
        DateTimeFormatLbl: Label '%1;%2', Comment = '%1 = Date, %2 = Time', Locked = true;
        FoundPOSSale: Boolean;
    begin
        Sale.GetCurrentSale(POSSale);
        ReceiptDate := Today();
        ReceiptTime := DT2Time(CurrentDateTime());
        InputDialog.SetInput(1, ReceiptDate, ReceiptDateLbl);
        InputDialog.SetInput(2, ReceiptTime, ReceiptTimeLbl);
        InputDialog.SetInput(3, ReturnFPMemoryNo, ReturnFPMemoryNoLbl);
        InputDialog.SetInput(4, ReturnFPDeviceNo, ReturnFPDeviceNoLbl);
        InputDialog.SetInput(5, ReturnExtReceiptCounter, ReturnExtReceiptCounterLbl);
        InputDialog.SetInput(6, ReturnGrandReceiptNo, ReturnGrandReceiptNoLbl);

        if InputDialog.RunModal() <> Action::OK then
            exit;

        InputDialog.InputDate(1, ReceiptDate);
        InputDialog.InputTime(2, ReceiptTime);
        InputDialog.InputText(3, ReturnFPMemoryNo);
        InputDialog.InputText(4, ReturnFPDeviceNo);
        InputDialog.InputCodeValue(5, ReturnExtReceiptCounter);
        InputDialog.InputText(6, ReturnGrandReceiptNo);

        if (ReceiptDate = 0D) or (ReceiptTime = 0T) or (ReturnFPMemoryNo = '') or (ReturnGrandReceiptNo = '') then
            Error(AllReceiptInfoNeededErr);

        FoundPOSSale := BGSISPOSSale.Get(POSSale.SystemId);
        if not FoundPOSSale then
            BGSISPOSSale."POS Sale SystemId" := POSSale.SystemId;

        BGSISPOSSale."Return Receipt Timestamp" := CopyStr(StrSubstNo(DateTimeFormatLbl, Format(ReceiptTime, 0, '<Seconds,2>,<Minutes,2>,<Hours24,2><Filler Character,0>'), Format(ReceiptDate, 0, '<Day,2>,<Month,2>,<Year,2>')), 1, MaxStrLen(BGSISPOSSale."Return Receipt Timestamp"));
        BGSISPOSSale."Return FP Memory No." := CopyStr(ReturnFPMemoryNo, 1, MaxStrLen(BGSISPOSSale."Return FP Memory No."));
        BGSISPOSSale."Return Grand Receipt No." := CopyStr(ReturnGrandReceiptNo, 1, MaxStrLen(BGSISPOSSale."Return Grand Receipt No."));

        if ReturnFPDeviceNo <> '' then
            BGSISPOSSale."Return FP Device No." := CopyStr(ReturnFPDeviceNo, 1, MaxStrLen(BGSISPOSSale."Return FP Device No."));

        if ReturnExtReceiptCounter <> '' then
            BGSISPOSSale."Return Ext. Receipt Counter" := CopyStr(ReturnExtReceiptCounter, 1, MaxStrLen(BGSISPOSSale."Return Ext. Receipt Counter"));

        if FoundPOSSale then
            BGSISPOSSale.Modify()
        else
            BGSISPOSSale.Insert();
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionBGSISReturn.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
