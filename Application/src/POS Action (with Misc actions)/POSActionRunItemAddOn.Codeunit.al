codeunit 6151128 "NPR POS Action: Run Item AddOn" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        POSDataMgt: Codeunit "NPR POS Data Management";
        ActionDescription: Label 'This built-in action inserts Item AddOns for a selected POS Sale Line', MaxLength = 250;
        ParamItemAddOn_CptLbl: Label 'Item AddOn No';
        ParamItemAddOn_DescLbl: Label 'Specifies Item AddOn No. This value will override Item AddOn selected on Item Cards';
        ParamSkipItemAvailbCheck_CptLbl: Label 'Skip Item Availability Check';
        ParamSkipItemAvailbCheck_DescLbl: Label 'Enable/Disable skip Item Availability Check';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddTextParameter('ItemAddOnNo', '', ParamItemAddOn_CptLbl, ParamItemAddOn_DescLbl);
        WorkflowConfig.AddBooleanParameter('SkipItemAvailabilityCheck', false, ParamSkipItemAvailbCheck_CptLbl, ParamSkipItemAvailbCheck_DescLbl);
        WorkflowConfig.SetDataSourceBinding(POSDataMgt.POSDataSource_BuiltInSaleLine());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'GetSalesLineAddonConfigJson':
                FrontEnd.WorkflowResponse(GenerateItemAddonConfig(Context));
            'SetItemAddons':
                OnActionRunAddOns(Context);
        end;
    end;

    local procedure GenerateItemAddonConfig(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        Item: Record Item;
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SalePOS: Record "NPR POS Sale";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        AddOnNo: Code[20];
        ItemAddonConfigAsString: Text;
        AppliesToLineNo: Integer;
        BaseLineNo: Integer;
        POSSession: Codeunit "NPR POS Session";
        AddOnNoTxt: Text;
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        If not Context.GetInteger('BaseLineNo', BaseLineNo) then
            BaseLineNo := 0;

        if BaseLineNo <> 0 then
            AppliesToLineNo := BaseLineNo
        else
            AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);

        Response.Add('BaseLineNo', AppliesToLineNo);

        SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
        SaleLinePOS.TestField("Line Type", SaleLinePOS."Line Type"::Item);

        if not Context.GetStringParameter('ItemAddOnNo', AddOnNoTxt) then
            AddOnNo := ''
        else
            AddOnNo := CopyStr(AddOnNoTxt, 1, MaxStrLen(AddOnNo));

        if AddOnNo = '' then begin
            Item.Get(SaleLinePOS."No.");
            AddOnNo := Item."NPR Item Addon No.";
            Response.Add('CompulsoryAddOn', not ItemAddOnMgt.AttachedIteamAddonLinesExist(SaleLinePOS));
        end;
        if AddOnNo = '' then
            if not LookupItemAddOn(AddOnNo) then
                Error('');

        ItemAddOn.Get(AddOnNo);
        ItemAddOn.TestField(Enabled);
        Response.Add('ApplyItemAddOnNo', AddOnNo);

        if not ItemAddOnMgt.UserInterfaceIsRequired(ItemAddOn) then begin
            Response.Add('UserSelectionRequired', false);
            Response.Add('ItemAddonConfigAsString', ItemAddonConfigAsString);
            exit;
        end;

        Response.Add('UserSelectionRequired', true);
        ItemAddOnMgt.GenerateItemAddOnConfigJson(SalePOS, SaleLinePOS, ItemAddOn).WriteTo(ItemAddonConfigAsString);
        Response.Add('ItemAddonConfigAsString', ItemAddonConfigAsString);
    end;


    local procedure FindAppliesToLineNo(SaleLinePOS: Record "NPR POS Sale Line"): Integer
    var
        SaleLinePOSAddOn: Record "NPR NpIa SaleLinePOS AddOn";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
    begin
        ItemAddOnMgt.FilterSaleLinePOS2ItemAddOnPOSLine(SaleLinePOS, SaleLinePOSAddOn);
        if SaleLinePOSAddOn.FindFirst() then
            exit(SaleLinePOSAddOn."Applies-to Line No.");

        if SaleLinePOS.Accessory then
            exit(SaleLinePOS."Main Line No.");

        exit(SaleLinePOS."Line No.");
    end;

    local procedure OnActionRunAddOns(Context: Codeunit "NPR POS JSON Helper")
    var
        UserSelectionJToken: JsonToken;
        AppliesToLineNo: Integer;
        CompulsoryAddOn: Boolean;
        SkipItemAvailabilityCheck: Boolean;
        ApplyItemAddOnNo: Code[20];
        UserSelectionRequired: Boolean;
        POSActRunItemAddOnB: Codeunit "NPR POS Action: RunItemAddOn B";
    begin
        AppliesToLineNo := Context.GetInteger('BaseLineNo');
        ApplyItemAddOnNo := CopyStr(Context.GetString('ApplyItemAddOnNo'), 1, MaxStrLen(ApplyItemAddOnNo));
        if not Context.GetBoolean('CompulsoryAddOn', CompulsoryAddOn) then
            CompulsoryAddOn := false;
        if not Context.GetBooleanParameter('SkipItemAvailabilityCheck', SkipItemAvailabilityCheck) then
            SkipItemAvailabilityCheck := false;
        if not Context.GetBoolean('UserSelectionRequired', UserSelectionRequired) then
            UserSelectionRequired := false;
        if UserSelectionRequired then
            UserSelectionJToken := Context.GetJToken('UserSelectedAddons');

        POSActRunItemAddOnB.RunItemAddOns(AppliesToLineNo, ApplyItemAddOnNo, CompulsoryAddOn, SkipItemAvailabilityCheck, UserSelectionRequired, UserSelectionJToken);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnLookupValue', '', true, false)]
    local procedure OnLookupValue(var POSParameterValue: Record "NPR POS Parameter Value"; Handled: Boolean);
    var
        AddOnNo: Code[20];
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ItemAddOnNo':
                begin
                    AddOnNo := CopyStr(POSParameterValue.Value, 1, MaxStrLen(AddOnNo));
                    if LookupItemAddOn(AddOnNo) then
                        POSParameterValue.Value := AddOnNo;
                end;
        end;
    end;

    local procedure LookupItemAddOn(var AddOnNo: Code[20]): Boolean
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
    begin
        ItemAddOn.FilterGroup(2);
        ItemAddOn.SetRange(Enabled, true);
        ItemAddOn.FilterGroup(0);
        if AddOnNo <> '' then begin
            ItemAddOn."No." := AddOnNo;
            if ItemAddOn.find('=><') then;
        end;
        if Page.RunModal(0, ItemAddOn) = Action::LookupOK then begin
            AddOnNo := ItemAddOn."No.";
            exit(true);
        end;
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnValidateValue', '', true, false)]
    local procedure OnValidateValue(var POSParameterValue: Record "NPR POS Parameter Value")
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLbl: Label '@%1*', Locked = true;
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

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

    local procedure ActionCode(): Code[20]
    begin

        exit(Format(Enum::"NPR POS Workflow"::RUN_ITEM_ADDONS));
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionRunItemAddOn.js###
'let main=async({workflow:e,popup:t,captions:a,context:r})=>{debugger;const{BaseLineNo:n,ApplyItemAddOnNo:o,CompulsoryAddOn:s,UserSelectionRequired:d,ItemAddonConfigAsString:i}=await e.respond("GetSalesLineAddonConfigJson");if(d){let A=JSON.parse(i);UserSelectedAddons=await t.configuration(A),await e.respond("SetItemAddons",{BaseLineNo:n,ApplyItemAddOnNo:o,CompulsoryAddOn:s,UserSelectionRequired:d,UserSelectedAddons})}else await e.respond("SetItemAddons",{BaseLineNo:n,ApplyItemAddOnNo:o,CompulsoryAddOn:s,UserSelectionRequired:d})};'
        );
    end;
}
