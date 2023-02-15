codeunit 6151285 "NPR SS Action - Item AddOn" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function sets the item addon values';
        CaptionItemAddOnNo: Label 'Item AddOn No.';
        DescItemAddOnNo: Label 'Specifies Item AddOn No.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('ItemAddOnNo', '', CaptionItemAddOnNo, DescItemAddOnNo);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    var
        ItemAddOnBLogic: Codeunit "NPR SS Action - Item AddOn-BL";
    begin
        case Step of
            'GetSalesLineAddonConfigJson':
                FrontEnd.WorkflowResponse(GetAddonConfigJson(Context, Sale, SaleLine));
            'SetItemAddons':
                ItemAddOnBLogic.UpdateOrder(Context, Sale, SaleLine);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:SSActionItemAddOn.js###
'let main=async({workflow:e,context:d,popup:n})=>{let a=await e.respond("GetSalesLineAddonConfigJson"),s=JSON.parse(a);d.userSelectedAddons=await n.configuration(s),d.userSelectedAddons&&await e.respond("SetItemAddons")};'
        );
    end;

    procedure GetAddonConfigJson(Context: Codeunit "NPR POS JSON Helper"; POSSale: Codeunit "NPR POS Sale"; POSSaleLine: Codeunit "NPR POS Sale Line") JsonText: Text
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnBLogic: Codeunit "NPR SS Action - Item AddOn-BL";
    begin
        POSSale.GetCurrentSale(SalePOS);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (not ItemAddOn.Get(Context.GetStringParameter('ItemAddOnNo'))) then begin
            if (SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item) then
                exit;
            if (not Item.Get(SaleLinePOS."No.")) then
                exit;
            if (not ItemAddOn.Get(Item."NPR Item AddOn No.")) then
                exit;
        end;

        ItemAddOnBLogic.GenerateAddonConfigJson(POSSale, SaleLinePOS, ItemAddOn).WriteTo(JsonText);

        exit(JsonText);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
    var
        ItemAddOnBLogic: Codeunit "NPR SS Action - Item AddOn-BL";
        AddOnNo: Code[20];
    begin
        case POSParameterValue.Name of
            'ItemAddOnNo':
                begin
                    AddOnNo := CopyStr(POSParameterValue.Value, 1, MaxStrLen(AddOnNo));
                    if ItemAddOnBLogic.LookupItemAddOn(AddOnNo) then
                        POSParameterValue.Value := AddOnNo;
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLbl: Label '@%1*', Locked = true;
    begin
        case POSParameterValue.Name of
            'ItemAddOnNo':
                begin
                    if POSParameterValue.Value = '' then
                        exit;

                    ItemAddOn.SetRange(Enabled, true);
                    ItemAddOn."No." := CopyStr(POSParameterValue.Value, 1, MaxStrLen(ItemAddOn."No."));
                    if not ItemAddOn.Find() then begin
                        ItemAddOn.SetFilter("No.", CopyStr(StrSubstNo(ItemAddOnLbl, POSParameterValue.Value), 1, MaxStrLen(ItemAddOn."No.")));
                        ItemAddOn.FindFirst();
                    end;
                    POSParameterValue.Value := ItemAddOn."No.";
                end;
        end;
    end;
}

