codeunit 6150848 "NPR POS Action: Adjust Inv." implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ParametarOptionsLbl: Label 'perform only Negative Adjustment,perform only Positive Adjustment,perform both Negative and Positive Adjustment', Locked = true;
        ActionDescription: Label 'Post Inventory Adjustment directly from POS';
        ParameterFixedReturnReason_NameLbl: Label 'FixedReturnReason';
        ParameterFixedReturnReason_CptLbl: Label 'Fixed Return Reason';
        ParameterFixedReturnReason_DescLbl: Label 'Pre-defined Return Reason';
        ParameterLookupReturnReason_NameLbl: Label 'LookupReturnReason';
        ParameterLookupReturnReason_DescLbl: Label 'Pre-filtered Return Reason list';
        ParameterInputAdjustment_NameLbl: Label 'InputAdjustment';
        ParameterInputAdjustment_CptLbl: Label 'Input Adjustment';
        InventoryQtyLbl: Label 'Adjust Inventory Quantity';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('QtyCaption', InventoryQtyLbl);
        WorkflowConfig.AddTextParameter(ParameterFixedReturnReason_NameLbl, '', ParameterFixedReturnReason_CptLbl, ParameterFixedReturnReason_DescLbl);
        WorkflowConfig.AddBooleanParameter(ParameterLookupReturnReason_NameLbl, false, ParameterLookupReturnReason_NameLbl, ParameterLookupReturnReason_DescLbl);
        WorkflowConfig.AddOptionParameter(
            ParameterInputAdjustment_NameLbl,
            ParametarOptionsLbl,
            SelectStr(3, ParametarOptionsLbl),
            ParameterInputAdjustment_NameLbl,
            ParameterInputAdjustment_CptLbl,
            ParametarOptionsLbl
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin

        case Step of
            'GetInventoryCaption':
                FrontEnd.WorkflowResponse(GetInventoryCaption(SaleLine));
            'AdjustInventory':
                FrontEnd.WorkflowResponse(AdjustInventory(Context, Sale, SaleLine));
        end;
    end;

    local procedure GetReasonCode(Context: Codeunit "NPR POS JSON Helper") ReturnReasonCode: Code[10]
    var
        ReturnReason: Record "Return Reason";
    begin
        if Context.GetStringParameter('FixedReturnReason') <> '' then
            ReturnReasonCode := CopyStr(Context.GetStringParameter('FixedReturnReason'), 1, MaxStrLen(ReturnReasonCode));


        if Context.GetBooleanParameter('LookupReturnReason') then begin
            if ReturnReasonCode <> '' then
                if ReturnReason.Get(ReturnReasonCode) then;
            if PAGE.RunModal(0, ReturnReason) <> ACTION::LookupOK then
                exit;
            ReturnReasonCode := ReturnReason.Code;
        end;
    end;

    local procedure AdjustInventory(Context: Codeunit "NPR POS JSON Helper"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"): JsonObject
    var
        Quantity: Decimal;
        ReturnReasonCode: Code[10];
        POSActionAdjustInventoryBusinessLogic: Codeunit "NPR POS Action: Adjust Inv. B";
    begin
        Quantity := Context.GetDecimal('quantity');
        if Quantity = 0 then
            exit;

        ReturnReasonCode := GetReasonCode(Context);

        Context.SetScopeParameters();
        case Context.GetInteger('InputAdjustment') of
            0:
                Quantity := -Abs(Quantity);
            1:
                Quantity := Abs(Quantity);
        end;

        POSActionAdjustInventoryBusinessLogic.PerformAdjustInventory(Sale, SaleLine, Quantity, ReturnReasonCode);
    end;


    local procedure GetInventoryCaption(POSSaleLine: Codeunit "NPR POS Sale Line") Response: JsonObject
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SaleLinePOS: Record "NPR POS Sale Line";
        SelectItemLbl: Label 'Kindly select the Item to Adjust';
        InventoryLbl: Label 'Inventory: %1 || %2 %3 %4';
    begin

        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) or (SaleLinePOS."No." = '') then
            Error(SelectItemLbl);

        if SaleLinePOS."Variant Code" <> '' then
            ItemVariant.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code");

        Item.Get(SaleLinePOS."No.");
        Item.SetFilter("Variant Filter", SaleLinePOS."Variant Code");
        Item.SetFilter("Location Filter", SaleLinePOS."Location Code");
        Item.CalcFields(Inventory);

        Response.ReadFrom('{}');
        Response.Add('AdjustInventoyCaption', StrSubstNo(InventoryLbl, Item.Inventory, Item."No.", Item.Description, ItemVariant.Description));
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin

        exit(
        //###NPR_INJECT_FROM_FILE:POSActionAdjustInv.js###
'let main=async({workflow:t,context:o,parametars:r,popup:a,captions:e})=>{const{AdjustInventoyCaption:i}=await t.respond("GetInventoryCaption");var n=await a.numpad({title:i,caption:e.QtyCaption});if(n===null)return" ";await t.respond("AdjustInventory",{quantity:n})};'
        );
    end;

}
