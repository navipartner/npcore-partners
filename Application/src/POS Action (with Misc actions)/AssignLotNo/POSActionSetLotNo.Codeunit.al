codeunit 6184797 "NPR POS Action Set Lot No" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for inserting a Lot No. no into the current pos sale line';
        ItemLotNo_InstrLbl: Label 'Enter Lot No. now and press OK. Press Cancel to enter Lot No. later.';
        ItemLotNo_LeadLbl: Label 'This item requires Lot No., enter Lot No.';
        ItemLotNo_TitleLbl: Label 'Enter Lot No.';
    begin
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('itemLotNo_title', ItemLotNo_TitleLbl);
        WorkflowConfig.AddLabel('itemLotNo_lead', ItemLotNo_LeadLbl);
        WorkflowConfig.AddLabel('itemLotNo_instructions', ItemLotNo_InstrLbl);
    end;

    procedure RunWorkflow(Step: Text;
                          Context: codeunit "NPR POS JSON Helper";
                          FrontEnd: codeunit "NPR POS Front End Management";
                          Sale: codeunit "NPR POS Sale";
                          SaleLine: codeunit "NPR POS Sale Line";
                          PaymentLine: codeunit "NPR POS Payment Line";
                          Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'CheckLineTracking':
                FrontEnd.WorkflowResponse(CheckLineTracking(SaleLine));
            'AssignLotNo':
                AssignLotNo(SaleLine,
                               Context,
                               Setup);
        end;
    end;
    #region CheckLineTracking
    local procedure CheckLineTracking(POSSaleLine: Codeunit "NPR POS Sale Line") ResponseJsonObject: JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRPOSActionSetLotNoB: Codeunit "NPR POS Action Set Lot No B";
        HasLotNo: Boolean;
        RequiresLotNo: Boolean;
        UseSpecificTracking: Boolean;
        LotNoAssignedLbl: Label 'Lot No. %1 has been assigned to item no.: %2. Do you want to change it?';
        ConfirmMessageText: text;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        NPRPOSActionSetLotNoB.CheckLineTracking(SaleLinePOS,
                                                   RequiresLotNo,
                                                   UseSpecificTracking,
                                                   HasLotNo);

        if HasLotNo then
            ConfirmMessageText := StrSubstNo(LotNoAssignedLbl,
                                             SaleLinePOS."Lot No.",
                                             SaleLinePOS."No.");

        ResponseJsonObject.Add('hasLotNo', HasLotNo);
        ResponseJsonObject.Add('hasLotNoResponseMessage', ConfirmMessageText);
        ResponseJsonObject.Add('requiresLotNo', RequiresLotNo);
        ResponseJsonObject.Add('useSpecificTracking', UseSpecificTracking);
    end;
    #endregion CheckLineTracking

    // #region AssignLotNo
    local procedure AssignLotNo(SaleLine: Codeunit "NPR POS Sale Line";
                                   Context: Codeunit "NPR POS JSON Helper";
                                   Setup: Codeunit "NPR POS Setup")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRPOSActionSetLotNoB: Codeunit "NPR POS Action Set Lot No B";
        LotNoInput: Text[50];
        LotNoSelectionFromList: Boolean;
    begin
        if Context.GetBooleanParameter('SelectLotNo', LotNoSelectionFromList) then;
#pragma warning disable AA0139
        if Context.HasProperty('LotNoInput') then
            LotNoInput := Context.GetString('LotNoInput');
#pragma warning restore AA0139

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        NPRPOSActionSetLotNoB.AssignLotNo(SalelinePOS,
                                                LotNoInput,
                                                Setup);
    end;
    // #endregion AssignSerialNo

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSetLotNo.js###
'let main=async({workflow:t,context:c,scope:r,popup:e,parameters:L,captions:i})=>{const{hasLotNo:n,hasLotNoResponseMessage:a,requiresLotNo:o,useSpecificTracking:s}=await t.respond("CheckLineTracking");if(n&&!await e.confirm(a)||(o||!s)&&(t.context.LotNoInput=await e.input({title:i.itemLotNo_title,caption:i.itemLotNo_lead}),t.context.LotNoInput===null))return"";await t.respond("AssignLotNo")};'
        )
    end;


}
