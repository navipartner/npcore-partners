codeunit 6184797 "NPR POS Action Set Lot No" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for inserting a Lot No. no into the current pos sale line';
        ItemLotNo_InstrLbl: Label 'Enter Lot No. now and press OK. Press Cancel to enter Lot No. later.';
        ItemLotNo_LeadLbl: Label 'This item requires Lot No., enter Lot No.';
        ItemLotNo_TitleLbl: Label 'Enter Lot No.';
        ParamSelectLotNo_CaptionLbl: Label 'Select Lot No.';
        ParamSelectLotNo_DescLbl: Label 'Choose option for selecting Lot No. from the list';
        ParamSelectLotNoOptionsLbl: Label 'NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput', Locked = true;
        ParamSelectLotNoOptionsLbl_CaptionLbl: Label 'NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput';
    begin
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('itemLotNo_title', ItemLotNo_TitleLbl);
        WorkflowConfig.AddLabel('itemLotNo_lead', ItemLotNo_LeadLbl);
        WorkflowConfig.AddLabel('itemLotNo_instructions', ItemLotNo_InstrLbl);
        WorkflowConfig.AddOptionParameter('SelectLotNo',
                                        ParamSelectLotNoOptionsLbl,
#pragma warning disable AA0139
                                        SelectStr(1, ParamSelectLotNoOptionsLbl),
#pragma warning restore AA0139
                                        ParamSelectLotNo_CaptionLbl,
                                        ParamSelectLotNo_DescLbl,
                                        ParamSelectLotNoOptionsLbl_CaptionLbl);
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
        LotSelectionFromListOption: Option NoSelection,SelectLotNoFromList,SelectLotNoFromListAfterInput;
    begin
        LotSelectionFromListOption := Context.GetIntegerParameter('SelectLotNo');
#pragma warning disable AA0139
        if Context.HasProperty('LotNoInput') then
            LotNoInput := Context.GetString('LotNoInput');
#pragma warning restore AA0139

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        case LotSelectionFromListOption of
            LotSelectionFromListOption::NoSelection:
                    LotNoSelectionFromList := false;
            LotSelectionFromListOption::SelectLotNoFromList:
                    LotNoSelectionFromList := true;
            LotSelectionFromListOption::SelectLotNoFromListAfterInput:
                    LotNoSelectionFromList := (LotNoInput = '');
        end;

        NPRPOSActionSetLotNoB.AssignLotNo(SalelinePOS,
                                                LotNoInput,
                                                Setup,
                                                LotNoSelectionFromList);
    end;
    // #endregion AssignLotNo

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSetLotNo.js###
'let main=async({workflow:t,context:s,scope:L,popup:e,parameters:i,captions:o})=>{const{hasLotNo:n,hasLotNoResponseMessage:a,requiresLotNo:N,useSpecificTracking:c}=await t.respond("CheckLineTracking");if(n&&!await e.confirm(a)||(i.SelectLotNo==0||i.SelectLotNo==2||!c)&&(t.context.LotNoInput=await e.input({title:o.itemLotNo_title,caption:o.itemLotNo_lead}),t.context.LotNoInput===null))return"";await t.respond("AssignLotNo")};'
        )
    end;


}
