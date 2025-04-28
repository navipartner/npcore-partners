codeunit 6248343 "NPR POS Action: HUL InsRefSale" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This is a built-in action for entering return receipt information.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        InputOriginalReceiptData(Sale);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionHULInsRefSale.js###
'let main=async({})=>await workflow.respond();'
        )
    end;

    local procedure InputOriginalReceiptData(Sale: Codeunit "NPR POS Sale")
    var
        POSSale: Record "NPR POS Sale";
        HULPOSSale: Record "NPR HU L POS Sale";
        InputDialog: Page "NPR Input Dialog";
        OriginalDate: Date;
        OriginalType: Text;
        OriginalBBOXID: Text;
        OriginalNo: Integer;
        OriginalClosureNo: Integer;
        OriginalDateLbl: Label 'Original Date';
        OriginalTypeLbl: Label 'Original Type (NY - Receipt; SZ - Simplified Invoice)';
        OriginalBBOXIDLbl: Label 'Original BBOX ID';
        OriginalNoLbl: Label 'Original No.';
        OriginalClosureNoLbl: Label 'Original Closure No.';
        OriginalInfoNeededErr: Label 'You must input original receipt information for processing.';
        FoundPOSSale: Boolean;
    begin
        Sale.GetCurrentSale(POSSale);
        OriginalDate := Today();
        OriginalType := 'NY';
        InputDialog.SetInput(1, OriginalDate, OriginalDateLbl);
        InputDialog.SetInput(2, OriginalType, OriginalTypeLbl);
        InputDialog.SetInput(3, OriginalBBOXID, OriginalBBOXIDLbl);
        InputDialog.SetInput(4, OriginalNo, OriginalNoLbl);
        InputDialog.SetInput(5, OriginalClosureNo, OriginalClosureNoLbl);

        if InputDialog.RunModal() <> Action::OK then
            Error(OriginalInfoNeededErr);

        InputDialog.InputDate(1, OriginalDate);
        InputDialog.InputText(2, OriginalType);
        InputDialog.InputText(3, OriginalBBOXID);
        InputDialog.InputInteger(4, OriginalNo);
        InputDialog.InputInteger(5, OriginalClosureNo);

        if (OriginalDate = 0D) or (OriginalType = '') or (OriginalBBOXID = '') or (OriginalNo = 0) or (OriginalClosureNo = 0) then
            Error(OriginalInfoNeededErr);

        FoundPOSSale := HULPOSSale.Get(POSSale.SystemId);
        if not FoundPOSSale then
            HULPOSSale."POS Sale SystemId" := POSSale.SystemId;
        HULPOSSale."Original Date" := OriginalDate;
        HULPOSSale.Validate("Original Type", CopyStr(OriginalType, 1, MaxStrLen(HULPOSSale."Original Type")));
        HULPOSSale."Original BBOX ID" := CopyStr(OriginalBBOXID, 1, MaxStrLen(HULPOSSale."Original BBOX ID"));
        HULPOSSale."Original No." := OriginalNo;
        HULPOSSale."Original Closure No." := OriginalClosureNo;
        if FoundPOSSale then
            HULPOSSale.Modify()
        else
            HULPOSSale.Insert();
        Commit();
    end;
}