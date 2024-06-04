codeunit 6151031 "NPR POS Action Set Serial No" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for inserting a serial no into the current pos sale line';
        ItemTracking_InstrLbl: Label 'Enter serial number now and press OK. Press Cancel to enter serial number later.';
        ItemTracking_LeadLbl: Label 'This item requires serial number, enter serial number.';
        ItemTracking_TitleLbl: Label 'Enter Serial Number';
        ParamSelectSerialNo_CaptionLbl: Label 'Select Serial No.';
        ParamSelectSerialNo_DescLbl: Label 'Enable/Disable select Serial No. from the list';
        ParamSelectSerialNoListEmptyInput_CaptionLbl: Label 'Select Serial No. List/Input';
        ParamSelectSerialNoListEmptyInput_DescLbl: Label 'Enable/Disable select Serial No. from the list after empty input.';
    begin
        WorkflowConfig.SetNonBlockingUI();
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('itemTracking_title', ItemTracking_TitleLbl);
        WorkflowConfig.AddLabel('itemTracking_lead', ItemTracking_LeadLbl);
        WorkflowConfig.AddLabel('itemTracking_instructions', ItemTracking_InstrLbl);
        WorkflowConfig.AddBooleanParameter('SelectSerialNo', false, ParamSelectSerialNo_CaptionLbl, ParamSelectSerialNo_DescLbl);
        WorkflowConfig.AddBooleanParameter('SelectSerialNoListEmptyInput', false, ParamSelectSerialNoListEmptyInput_CaptionLbl, ParamSelectSerialNoListEmptyInput_DescLbl);
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
            'AssignSerialNo':
                AssignSerialNo(SaleLine,
                               Context,
                               Setup);
        end;
    end;
    #region CheckLineTracking
    local procedure CheckLineTracking(POSSaleLine: Codeunit "NPR POS Sale Line") ResponseJsonObject: JsonObject
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRPOSActionSetSerialNoB: Codeunit "NPR POS Action Set Serial No B";
        HasSerialNo: Boolean;
        RequiresSerialNo: Boolean;
        UseSpecificTracking: Boolean;
        SerialNoAssignedLbl: Label 'Serial No. %1 has been assigned to item no.: %2. Do you want to change it?';
        ConfirmMessageText: text;
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        NPRPOSActionSetSerialNoB.CheckLineTracking(SaleLinePOS,
                                                   RequiresSerialNo,
                                                   UseSpecificTracking,
                                                   HasSerialNo);

        if HasSerialNo then
            ConfirmMessageText := StrSubstNo(SerialNoAssignedLbl,
                                             SaleLinePOS."Serial No.",
                                             SaleLinePOS."No.");

        ResponseJsonObject.Add('hasSerialNo', HasSerialNo);
        ResponseJsonObject.Add('hasSerialNoResponseMessage', ConfirmMessageText);
        ResponseJsonObject.Add('requiresSerialNo', RequiresSerialNo);
        ResponseJsonObject.Add('useSpecificTracking', UseSpecificTracking);

    end;
    #endregion CheckLineTracking

    // #region AssignSerialNo
    local procedure AssignSerialNo(SaleLine: Codeunit "NPR POS Sale Line";
                                   Context: Codeunit "NPR POS JSON Helper";
                                   Setup: Codeunit "NPR POS Setup")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NPRPOSActionSetSerialNoB: Codeunit "NPR POS Action Set Serial No B";
        SerialNoInput: Text[50];
        SerialSelectionFromList: Boolean;
        ValidateSerialSelectionFromList: Boolean;
        SelectSerialNoListEmptyInput: Boolean;
    begin
        if Context.GetBooleanParameter('SelectSerialNo', SerialSelectionFromList) then;
        if Context.GetBooleanParameter('SelectSerialNoListEmptyInput', SelectSerialNoListEmptyInput) then;
#pragma warning disable AA0139
        if Context.HasProperty('SerialNoInput') then
            SerialNoInput := Context.GetString('SerialNoInput');
#pragma warning restore AA0139

        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        ValidateSerialSelectionFromList := (SelectSerialNoListEmptyInput and SerialSelectionFromList and (SerialNoInput = '')) or (SerialSelectionFromList and not SelectSerialNoListEmptyInput);
        NPRPOSActionSetSerialNoB.AssignSerialNo(SalelinePOS,
                                                SerialNoInput,
                                                ValidateSerialSelectionFromList,
                                                Setup);
    end;
    // #endregion AssignSerialNo

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSetSerialNo.js###
'let main=async({workflow:e,context:r,scope:s,popup:t,parameters:i,captions:a})=>{const{hasSerialNo:n,hasSerialNoResponseMessage:c,requiresSerialNo:S,useSpecificTracking:l}=await e.respond("CheckLineTracking");if(n&&!await t.confirm(c)||(!i.SelectSerialNo||!l||i.SelectSerialNo&&i.SelectSerialNoListEmptyInput)&&(e.context.SerialNoInput=await t.input({title:a.itemTracking_title,caption:a.itemTracking_lead}),e.context.SerialNoInput===null))return"";await e.respond("AssignSerialNo")};'
        )
    end;


}
