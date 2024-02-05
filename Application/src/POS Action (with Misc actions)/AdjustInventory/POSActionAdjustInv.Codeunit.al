codeunit 6150848 "NPR POS Action: Adjust Inv." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParametarOptionsLbl: Label 'perform only Negative Adjustment,perform only Positive Adjustment,perform both Negative and Positive Adjustment', Locked = true;
        ActionDescription: Label 'Post Inventory Adjustment directly from POS';
        ParameterFixedReturnReason_CptLbl: Label 'Fixed Return Reason';
        ParameterFixedReturnReason_DescLbl: Label 'Pre-defined Return Reason';
        ParameterLookupReturnReason_NameLbl: Label 'LookupReturnReason';
        ParameterLookupReturnReason_DescLbl: Label 'Pre-filtered Return Reason list';
        ParameterInputAdjustment_NameLbl: Label 'InputAdjustment';
        ParameterInputAdjustment_CptLbl: Label 'Input Adjustment';
        InventoryQtyLbl: Label 'Adjust Inventory Quantity';
        ReasonDescCptLbl: Label 'Custom Return Reason Description';
        ReasonDescDescLbl: Label 'Add custom Return Reason Description with Reason Code';
        AddReasonDescLbl: Label 'Return Reason Description';
        InventoryAdjustmentUnitOfMeasureOptionsLbl: Label 'Purchase Unit of Measure,Sales Unit of Measure,Base Unit of Measure,Ask';
        ParameterInventoryAdjustmentUnitOfMeasure_CptLbl: Label 'Adjustment Unit of Measure';
        ParameterInventoryAdjustmentUnitOfMeasure_DescLbl: Label 'Specifies the unit of measure that is going to be used for the adjustment';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('QtyCaption', InventoryQtyLbl);
        WorkflowConfig.AddLabel('ReasonCodeCpt', AddReasonDescLbl);
        WorkflowConfig.AddTextParameter('FixedReturnReason', '', ParameterFixedReturnReason_CptLbl, ParameterFixedReturnReason_DescLbl);
        WorkflowConfig.AddBooleanParameter('LookupReturnReason', false, ParameterLookupReturnReason_NameLbl, ParameterLookupReturnReason_DescLbl);
        WorkflowConfig.AddOptionParameter(
            'InputAdjustment',
            ParametarOptionsLbl,
#pragma warning disable AA0139
            SelectStr(3, ParametarOptionsLbl),
#pragma warning restore 
            ParameterInputAdjustment_NameLbl,
            ParameterInputAdjustment_CptLbl,
            ParametarOptionsLbl
        );
        WorkflowConfig.AddBooleanParameter('CustomReasonDescription', false, ReasonDescCptLbl, ReasonDescDescLbl);
        WorkflowConfig.AddOptionParameter('AdjustmentUnitOfMeasure',
                                          InventoryAdjustmentUnitOfMeasureOptionsLbl,
#pragma warning disable AA0139
                                          SelectStr(1, InventoryAdjustmentUnitOfMeasureOptionsLbl),
#pragma warning restore AA0139
                                          ParameterInventoryAdjustmentUnitOfMeasure_CptLbl,
                                          ParameterInventoryAdjustmentUnitOfMeasure_DescLbl,
                                          InventoryAdjustmentUnitOfMeasureOptionsLbl);

    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

        case Step of
            'GetInventorySettings':
                FrontEnd.WorkflowResponse(GetInventorySettings(Context, SaleLine));
            'GetReasonCode':
                FrontEnd.WorkflowResponse(GetReasonCode(Context));
            'AdjustInventory':
                FrontEnd.WorkflowResponse(AdjustInventory(Context, Sale, SaleLine));
        end;
    end;

    local procedure GetReasonCode(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        ReturnReason: Record "Return Reason";
        ReturnReasonCode: Code[10];
    begin
        if Context.GetStringParameter('FixedReturnReason') <> '' then
            ReturnReasonCode := CopyStr(Context.GetStringParameter('FixedReturnReason'), 1, MaxStrLen(ReturnReasonCode));

        if Context.GetBooleanParameter('LookupReturnReason') then begin
            if ReturnReasonCode <> '' then
                if ReturnReason.Get(ReturnReasonCode) then;
            if PAGE.RunModal(0, ReturnReason) = ACTION::LookupOK then
                ReturnReasonCode := ReturnReason.Code;
        end;
        Context.SetContext('reasonCode', ReturnReasonCode);
        Context.SetContext('defaultDescription', ReturnReason.Description);
    end;

    local procedure AdjustInventory(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    var
        Quantity: Decimal;
        ReturnReasonCode: Code[10];
        UnitOfMeasureText: Text;
        ReturnReasonTxt: Text;
        CustomDescription: Text;
        POSActionAdjustInventoryBusinessLogic: Codeunit "NPR POS Action: Adjust Inv. B";
    begin
        Quantity := Context.GetDecimal('quantity');
        if not Context.GetString('unitOfMeasureCode', UnitOfMeasureText) then
            UnitOfMeasureText := '';

        if Quantity = 0 then
            exit;
        IF Context.GetString('reasonCode', ReturnReasonTxt) then
            ReturnReasonCode := CopyStr(ReturnReasonTxt, 1, MaxStrLen(ReturnReasonCode));
        IF not Context.GetString('customDescription', CustomDescription) then
            CustomDescription := '';

        Context.SetScopeParameters();
        case Context.GetInteger('InputAdjustment') of
            0:
                Quantity := -Abs(Quantity);
            1:
                Quantity := Abs(Quantity);
        end;
#pragma warning disable AA0139
        POSActionAdjustInventoryBusinessLogic.PerformAdjustInventory(Sale, SaleLine, Quantity, UnitOfMeasureText, ReturnReasonCode, CopyStr(CustomDescription, 1, 100));
#pragma warning restore AA0139
    end;


    local procedure GetInventorySettings(Context: Codeunit "NPR POS JSON Helper"; POSSaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SaleLinePOS: Record "NPR POS Sale Line";
        SelectItemLbl: Label 'Kindly select the Item to Adjust';
        InventoryLbl: Label 'Inventory: %1 || %2 %3 %4';
        UnitOfMeasureCode: Code[10];
    begin

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item) or (SaleLinePOS."No." = '') then
            Error(SelectItemLbl);

        if SaleLinePOS."Variant Code" <> '' then
            ItemVariant.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");

        case Context.GetIntegerParameter('AdjustmentUnitOfMeasure') of
            0:
                UnitOfMeasureCode := Item."Purch. Unit of Measure";
            1:
                UnitOfMeasureCode := Item."Sales Unit of Measure";
            2:
                UnitOfMeasureCode := Item."Base Unit of Measure";
        end;

        Item.SetFilter("Variant Filter", SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter", SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        Response.Add('AdjustInventoyCaption', StrSubstNo(InventoryLbl, Item.Inventory, Item."No.", Item.Description, ItemVariant.Description));
        Response.Add('UnitOfMeasureAssignmentPopUpSettings', CreateUnitOfMeasureAssignmentPopUpSettings(SaleLinePOS));
        Response.Add('UnitOfMeasureCode', UnitOfMeasureCode);
    end;

    local procedure CreateUnitOfMeasureAssignmentPopUpSettings(SaleLinePOS: Record "NPR POS Sale Line") PopUpJosnObject: JsonObject;
    var
        ItemUnitofMeasure: Record "Item Unit of Measure";
        OptionJsonArray: JsonArray;
        OptionSettingsJsonArray: JsonArray;
        OptionJsonObject: JsonObject;
        OptionSettingsJsonObject: JsonObject;
        RadioOptionsJsonObject: JsonObject;
        RadioOptionsJsonArray: JsonArray;
        SelectUnitOfMeasureTitleLbl: Label 'Select unit of measure';
        UnitOfMeasuresLbl: Label 'Unit of Measures';
    begin
        ItemUnitofMeasure.Reset();
        ItemUnitofMeasure.SetRange("Item No.", SaleLinePOS."No.");
        ItemUnitofMeasure.SetLoadFields("Item No.", Code);
        if ItemUnitofMeasure.FindSet() then
            repeat
                Clear(RadioOptionsJsonObject);
                RadioOptionsJsonObject.Add('caption', ItemUnitofMeasure.Code);
                RadioOptionsJsonObject.Add('value', ItemUnitofMeasure.Code);
                RadioOptionsJsonArray.Add(RadioOptionsJsonObject);
            until ItemUnitofMeasure.Next() = 0;

        Clear(OptionSettingsJsonObject);
        OptionSettingsJsonObject.Add('type', 'radio');
        OptionSettingsJsonObject.Add('id', 'unitOfMeasure');
        OptionSettingsJsonObject.Add('caption', ' ');
        OptionSettingsJsonObject.Add('options', RadioOptionsJsonArray);

        OptionSettingsJsonArray.Add(OptionSettingsJsonObject);

        Clear(OptionJsonObject);
        OptionJsonObject.Add('caption', UnitOfMeasuresLbl);
        OptionJsonObject.Add('type', 'group');
        OptionJsonObject.Add('expanded', 'true');
        OptionJsonObject.Add('settings', OptionSettingsJsonArray);

        OptionJsonArray.Add(OptionJsonObject);

        PopUpJosnObject.Add('caption', ' ');
        PopUpJosnObject.Add('title', SelectUnitOfMeasureTitleLbl);
        PopUpJosnObject.Add('settings', OptionJsonArray);
    end;

    local procedure GetActionScript(): Text
    begin

        exit(
        //###NPR_INJECT_FROM_FILE:POSActionAdjustInv.js###
'let main=async({workflow:t,context:d,parameters:e,popup:n,captions:i})=>{debugger;var{AdjustInventoyCaption:o,UnitOfMeasureAssignmentPopUpSettings:r,UnitOfMeasureCode:a}=await t.respond("GetInventorySettings");if(e.AdjustmentUnitOfMeasure==3){var s=await n.configuration(r);if(s===null)return;a=s.unitOfMeasure}var u=await n.numpad({title:o,caption:i.QtyCaption});if(u===null)return" ";await t.respond("GetReasonCode"),t.context.reasonCode&&e.CustomReasonDescription&&(t.context.customDescription=await n.input({caption:i.ReasonCodeCpt,value:t.context.defaultDescription})),await t.respond("AdjustInventory",{quantity:u,unitOfMeasureCode:a})};'
        );
    end;

}
