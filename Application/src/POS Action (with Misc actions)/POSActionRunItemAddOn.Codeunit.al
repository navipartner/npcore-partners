codeunit 6151128 "NPR POS Action: Run Item AddOn"
{
    local procedure ActionCode(): Code[20]
    begin
        exit('RUN_ITEM_ADDONS');
    end;

    local procedure BuiltInSaleLine(): Text
    begin
        exit('BUILTIN_SALELINE');
    end;

    local procedure ActionVersion(): Text[30]
    begin
        exit('2.0');
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Action", 'OnDiscoverActions', '', true, true)]
    local procedure OnDiscoverAction(var Sender: Record "NPR POS Action")
    var
        ActionDescriptionLbl: Label 'This built-in action inserts Item AddOns for a selected POS Sale Line', MaxLength = 250;
    begin
        if Sender.DiscoverAction20(ActionCode(), ActionDescriptionLbl, CopyStr(ActionVersion(), 1, 20)) then begin
            Sender.RegisterWorkflow20(
                'let AddonJson = await workflow.respond("GetSalesLineAddonConfigJson");' +
                'if ($context.UserSelectionRequired) {' +
                '  let AddonConfig = JSON.parse(AddonJson);' +
                '  $context.UserSelectedAddons = await popup.configuration(AddonConfig);' +
                '}' +
                'await workflow.respond("SetItemAddons");');

            Sender.RegisterDataSourceBinding(CopyStr(BuiltInSaleLine(), 1, 50));
            Sender.RegisterTextParameter('ItemAddOnNo', '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Workflows 2.0", 'OnAction', '', true, true)]
    local procedure OnAction20("Action": Record "NPR POS Action"; WorkflowStep: Text; Context: Codeunit "NPR POS JSON Management"; POSSession: Codeunit "NPR POS Session"; State: Codeunit "NPR POS WF 2.0: State"; FrontEnd: Codeunit "NPR POS Front End Management"; var Handled: Boolean)
    begin
        if not Action.IsThisAction(ActionCode()) then
            exit;
        Handled := true;

        case WorkflowStep of
            'GetSalesLineAddonConfigJson':
                GenerateItemAddonConfig(POSSession, FrontEnd, Context);
            'SetItemAddons':
                OnActionRunAddOns(POSSession, Context);
        end;
    end;

    local procedure GenerateItemAddonConfig(POSSession: Codeunit "NPR POS Session"; FrontEnd: Codeunit "NPR POS Front End Management"; Context: Codeunit "NPR POS JSON Management")
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
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        BaseLineNo := Context.GetInteger('BaseLineNo');
        if BaseLineNo <> 0 then
            AppliesToLineNo := BaseLineNo
        else begin
            AppliesToLineNo := FindAppliesToLineNo(SaleLinePOS);
            Context.SetContext('BaseLineNo', AppliesToLineNo);
        end;

        SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
        SaleLinePOS.TestField(Type, SaleLinePOS.Type::Item);

        AddOnNo := CopyStr(Context.GetStringParameter('ItemAddOnNo'), 1, MaxStrLen(AddOnNo));
        if AddOnNo = '' then begin
            Item.Get(SaleLinePOS."No.");
            AddOnNo := Item."NPR Item AddOn No.";
            Context.SetContext('CompulsoryAddOn', not ItemAddOnMgt.AttachedIteamAddonLinesExist(SaleLinePOS));
        end;
        if AddOnNo = '' then
            if not LookupItemAddOn(AddOnNo) then
                Error('');

        ItemAddOn.Get(AddOnNo);
        ItemAddOn.TestField(Enabled);
        Context.SetContext('ApplyItemAddOnNo', AddOnNo);

        if not ItemAddOnMgt.UserInterfaceIsRequired(ItemAddOn) then begin
            FrontEnd.WorkflowResponse('{}');
            exit;
        end;
        Context.SetContext('UserSelectionRequired', true);
        ItemAddOnMgt.GenerateItemAddOnConfigJson(SalePOS, SaleLinePOS, ItemAddOn).WriteTo(ItemAddonConfigAsString);
        FrontEnd.WorkflowResponse(ItemAddonConfigAsString);
    end;

    local procedure OnActionRunAddOns(POSSession: Codeunit "NPR POS Session"; Context: Codeunit "NPR POS JSON Management")
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        SaleLinePOS: Record "NPR POS Sale Line";
        ItemAddOnMgt: Codeunit "NPR NpIa Item AddOn Mgt.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        UserSelectionJToken: JsonToken;
        AppliesToLineNo: Integer;
        CompulsoryAddOn: Boolean;
        RequestFrontEndRefresh: Boolean;
        UpdateActiveSaleLine: Boolean;
        ReadingErr: Label 'reading in %1 of %2';
    begin
        AppliesToLineNo := Context.GetIntegerOrFail('BaseLineNo', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        UpdateActiveSaleLine := SaleLinePOS."Line No." <> AppliesToLineNo;
        SaleLinePOS.Get(SaleLinePOS."Register No.", SaleLinePOS."Sales Ticket No.", SaleLinePOS.Date, SaleLinePOS."Sale Type", AppliesToLineNo);
        if SaleLinePOS.Type <> SaleLinePOS.Type::Item then
            exit;
        IF UpdateActiveSaleLine THEN
            POSSaleLine.SetPosition(SaleLinePOS.GetPosition());

        ItemAddOn.Get(Context.GetStringOrFail('ApplyItemAddOnNo', StrSubstNo(ReadingErr, 'OnAction', ActionCode())));
        ItemAddOn.TestField(Enabled);
        CompulsoryAddOn := Context.GetBoolean('CompulsoryAddOn');

        Clear(ItemAddOnMgt);
        if not Context.GetBoolean('UserSelectionRequired') then
            RequestFrontEndRefresh := ItemAddOnMgt.InsertMandatoryPOSAddOnLinesSilent(ItemAddOn, POSSession, AppliesToLineNo, CompulsoryAddOn)
        else begin
            UserSelectionJToken := Context.GetJTokenOrFail('UserSelectedAddons', StrSubstNo(ReadingErr, 'OnAction', ActionCode()));
            if UserSelectionJToken.IsValue then
                if UserSelectionJToken.AsValue().IsNull and not Context.GetBoolean('CompulsoryAddOn') then
                    Error('');
            RequestFrontEndRefresh := ItemAddOnMgt.InsertPOSAddOnLines(ItemAddOn, UserSelectionJToken, POSSession, AppliesToLineNo, CompulsoryAddOn);
        end;

        if RequestFrontEndRefresh then begin
            if ItemAddOnMgt.InsertedWithAutoSplitKey() then begin
                POSSession.ChangeViewSale();  //there is no other way to refresh the lines, so they appear in correct order
                exit;
            end;
            POSSession.RequestRefreshData();
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

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterNameCaption', '', true, false)]
    local procedure OnGetParameterNameCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        CaptionItemAddOnNo: Label 'Item AddOn No.';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ItemAddOnNo':
                Caption := CaptionItemAddOnNo;
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Parameter Value", 'OnGetParameterDescriptionCaption', '', true, false)]
    local procedure OnGetParameterDescriptionCaption(POSParameterValue: Record "NPR POS Parameter Value"; var Caption: Text)
    var
        DescItemAddOnNo: Label 'Specifies Item AddOn No. This value will override Item AddOn selected on Item Cards';
    begin
        if POSParameterValue."Action Code" <> ActionCode() then
            exit;

        case POSParameterValue.Name of
            'ItemAddOnNo':
                Caption := DescItemAddOnNo;
        end;
    end;
}
