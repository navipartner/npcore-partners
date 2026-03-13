codeunit 6151076 "NPR POSActionWalletInventory" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        IncludeCouponParameterLabel: Label 'Include Coupons', Locked = true;
        ThresholdParameterLabel: Label 'Threshold applicable items', Locked = true;
        ShowInvalidAssetsParameterLabel: Label 'Show Invalid Assets', Locked = true;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action shows the inventory of the wallet, allowing the user to select an asset from the wallet to add to the sale line.';
        IncludeCouponsCaption: Label 'Include coupons';
        IncludeCouponsDescription: Label 'When enabled, coupons in the wallet will be included in the inventory list.';
        ShowInvalidAssetsCaption: Label 'Show invalid assets';
        ShowInvalidAssetsDescription: Label 'When enabled, assets that are no longer valid (e.g. expired coupons) will be shown in the inventory list with an (Invalid) tag.';
        InputWalletReferenceLbl: Label 'Input Wallet Reference';
        ThresholdCaption: Label 'Threshold for showing applicable items';
        ThresholdDescription: Label 'Do not show a list when the number of applicable items for a coupon exceeds this threshold';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter(IncludeCouponParameterLabel, true, IncludeCouponsCaption, IncludeCouponsDescription);
        WorkflowConfig.AddBooleanParameter(ShowInvalidAssetsParameterLabel, false, ShowInvalidAssetsCaption, ShowInvalidAssetsDescription);
        WorkflowConfig.AddIntegerParameter(ThresholdParameterLabel, 30, ThresholdCaption, ThresholdDescription);
        WorkflowConfig.AddLabel('inputReference', InputWalletReferenceLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'getWalletInventory':
                FrontEnd.WorkflowResponse(GetWalletInventory(Context));

            'processWalletInventorySelection':
                FrontEnd.WorkflowResponse(ProcessWalletInventorySelection(Context));

            'applyItemAndInventorySelection':
                FrontEnd.WorkflowResponse(ApplyItemAndInventorySelection(Context));

            'applyCoupon':
                ApplyCoupon(Context);

            else
                Error('Unknown workflow step %1, This is a programming error, please contact support.', Step);
        end;
    end;

    local procedure GetWalletInventory(Context: Codeunit "NPR POS JSON Helper") Response: JsonObject
    var
        NoReferenceLbl: Label 'No wallet reference provided.';
        DialogTitle: Label 'Wallet Inventory';
        DialogCaption: Label 'Select an asset from the wallet to apply to the sale.';
        WalletId: Text[100];
        Settings: JsonArray;

        IncludeCoupons: Boolean;
        IncludeInvalidAssets: Boolean;
        CouponsList, InvalidCouponsList : List of [JsonObject];
        CouponSectionCaption: Label 'Coupons';
        InvalidCouponSectionCaption: Label 'Invalid Coupons';
        CouponGroupCaption: Label 'List of Available Coupons';
        InvalidCouponGroupCaption: Label 'List of Invalid Coupons';
    begin

        if (not Context.HasProperty('input')) then
            Error(NoReferenceLbl);

        IncludeCoupons := Context.GetBooleanParameter(IncludeCouponParameterLabel);
        IncludeInvalidAssets := Context.GetBooleanParameter(ShowInvalidAssetsParameterLabel);

        WalletId := CopyStr(Context.GetString('input'), 1, MaxStrLen(WalletId));
        GetWalletAssets(WalletId, CouponsList, InvalidCouponsList);

        if (IncludeCoupons) then begin
            Settings.Add(AddSection(CouponSectionCaption, CouponGroupCaption, 'couponSection', true, CouponsList));
            if (IncludeInvalidAssets) then
                Settings.Add(AddSection(InvalidCouponSectionCaption, InvalidCouponGroupCaption, 'invalidCouponSection', false, InvalidCouponsList));
        end;

        Response.Add('success', true);
        Response.Add('reason', '');
        Response.Add('title', DialogTitle + ' - ' + WalletId);
        Response.Add('caption', DialogCaption);
        Response.Add('settings', Settings);
        exit(Response);

    end;

    local procedure ProcessWalletInventorySelection(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        SelectedOption: Text;
        JObject: JsonObject;
        AssetEntryNo: Integer;
        WalletAssetLine: Record "NPR WalletAssetLine";
        SuggestListOfItems: List of [JsonObject];
        JToken: JsonToken;
        Settings: JsonArray;
        ResponseOk, ResponseFail : JsonObject;
        ItemListThreshold: Integer;
        ItemSectionCaption: Label 'Items';
        ItemGroupCaption: Label 'List of Available Items for the Selected Coupon';
        DialogTitle: Label 'Coupon Application';
        DialogCaption: Label 'Select an item from the list to add to the sale.';
    begin
        ResponseFail.Add('success', false);

        ItemListThreshold := Context.GetIntegerParameter(ThresholdParameterLabel);

        if (not Context.HasProperty('selectedAsset')) then
            Error('Selection is required. This is a programming error, please contact support.');

        SelectedOption := Context.GetString('selectedAsset');
        if SelectedOption.Contains('__none__') then
            exit(ResponseFail);

        JObject.ReadFrom(SelectedOption);
        if (not JObject.Contains('couponSection')) then
            exit(ResponseFail);

        JObject.Get('couponSection', JToken);
        AssetEntryNo := JToken.AsValue().AsInteger();

        if (not WalletAssetLine.Get(AssetEntryNo)) then
            exit(ResponseFail);

        case WalletAssetLine.Type of
            WalletAssetLine.Type::COUPON:
                begin
                    CouponsAppliesToItem(WalletAssetLine.LineTypeReference, ItemListThreshold, SuggestListOfItems);

                    if (SuggestListOfItems.Count() = 0) then begin
                        ResponseOk.Add('success', true);
                        ResponseOk.Add('selectItem', false);
                        ResponseOk.Add('couponReference', WalletAssetLine.LineTypeReference);
                        ResponseOk.Add('itemReference', '');
                        ResponseOk.Add('reason', 'The selected coupon is not limited to any items.');
                        exit(ResponseOk);
                    end;
                    if (SuggestListOfItems.Count() = 1) then begin
                        // if the coupon only applies to one item, automatically select that item and add coupon to sale line
                        SuggestListOfItems.Get(1).AsToken().AsObject().Get('value', JToken);
                        ResponseOk.Add('success', true);
                        ResponseOk.Add('selectItem', false);
                        ResponseOk.Add('couponReference', WalletAssetLine.LineTypeReference);
                        ResponseOk.Add('itemReference', JToken.AsValue().AsText());
                        ResponseOk.Add('reason', 'Only one applicable item found for the selected coupon, automatically applying to that item.');
                        exit(ResponseOk);
                    end;
                    if (SuggestListOfItems.Count() > 1) then begin
                        // if the coupon applies to multiple items, ask user to select which item to apply to
                        Settings.Add(AddSection(ItemSectionCaption, ItemGroupCaption, 'itemSection', true, SuggestListOfItems));
                        ResponseOk.Add('success', true);
                        ResponseOk.Add('selectItem', true);
                        ResponseOk.Add('itemReference', '');
                        ResponseOk.Add('couponReference', WalletAssetLine.LineTypeReference);
                        ResponseOk.Add('title', DialogTitle + ' - ' + WalletAssetLine.LineTypeReference);
                        ResponseOk.Add('caption', DialogCaption);
                        ResponseOk.Add('settings', Settings);
                        ResponseOk.Add('reason', 'Multiple applicable items found for the selected coupon, please select one.');
                        exit(ResponseOk);
                    end;
                end;
            else
                ResponseFail.Add('reason', 'Unsupported asset type.');
        end;

        exit(ResponseFail);
    end;

    local procedure ApplyItemAndInventorySelection(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        SelectedOption: Text;
        JObject: JsonObject;
        ItemNo: Code[20];
        CouponReference: Text;
        JToken: JsonToken;
        ResponseOk, ResponseFail : JsonObject;
    begin
        if (not Context.HasProperty('selectedAsset')) then
            Error('Selection is required. This is a programming error, please contact support.');

        if (not Context.HasProperty('couponReference')) then
            Error('Coupon reference is required. This is a programming error, please contact support.');

        SelectedOption := Context.GetString('selectedAsset');
        if SelectedOption.Contains('__none__') then
            exit(ResponseFail);

        JObject.ReadFrom(SelectedOption);
        if (not JObject.Contains('itemSection')) then
            exit(ResponseFail);

        JObject.Get('itemSection', JToken);
        ItemNo := CopyStr(JToken.AsValue().AsText(), 1, MaxStrLen(ItemNo));

        CouponReference := Context.GetString('couponReference');

        ResponseOk.Add('success', true);
        ResponseOk.Add('reason', '');
        ResponseOk.Add('itemReference', ItemNo);
        ResponseOk.Add('couponReference', CouponReference);

        exit(ResponseOk);
    end;

    local procedure ApplyCoupon(Context: Codeunit "NPR POS JSON Helper")
    var
        CouponReference: Text;
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        POSSession: Codeunit "NPR POS Session";
    begin
        CouponReference := Context.GetString('couponReference');
        CouponMgt.ScanCoupon(POSSession, CouponReference);
    end;


    local procedure CouponsAppliesToItem(CouponReferenceNo: Text; ItemListThreshold: Integer; SuggestListOfItems: List of [JsonObject])
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        CouponApplicableItem: Record "NPR NpDc Coupon List Item";
        Item: Record Item;
        ItemOption: JsonObject;
    begin
        // find the list of item this coupon can be applied to, from coupon setup
        // loop through the list and add to ListOfItems in the format of {"caption": "Item Name (Item No.)", "value": "Item No."}
        Coupon.SetFilter("Reference No.", '=%1', CopyStr(UpperCase(CouponReferenceNo), 1, MaxStrLen(Coupon."Reference No.")));
        if (not Coupon.FindFirst()) then
            exit;

        if (not CouponType.Get(Coupon."Coupon Type")) then
            exit;

        CouponApplicableItem.SetFilter("Coupon Type", '=%1', CouponType."Code");
        if (CouponApplicableItem.Count() > ItemListThreshold) then
            exit;

        if (CouponApplicableItem.FindSet()) then
            repeat
                Clear(ItemOption);
                if (CouponApplicableItem.Type = CouponApplicableItem.Type::Item) then begin
                    if (Item.Get(CouponApplicableItem."No.")) then begin
                        ItemOption.Add('caption', StrSubstNo('%1 (%2)', Item.Description, Item."No."));
                        ItemOption.Add('value', Item."No.");
                        SuggestListOfItems.Add(ItemOption);
                    end;
                end else begin
                    // Only handle the pure item category case for showing what a coupon can be applied to
                    Clear(SuggestListOfItems);
                    exit;
                end;
            until CouponApplicableItem.Next() = 0;

    end;


    local procedure GetWalletAssets(WalletReferenceNumber: Text[100]; var CouponsList: List of [JsonObject]; var InvalidCouponsList: List of [JsonObject])
    var
        WalletAssets: Query "NPR AttractionWalletAssets";
        Wallet: Query "NPR FindAttractionWallets";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        Coupon: Record "NPR NpDc Coupon";
        Option: JsonObject;
        InvalidLabel: Label '(Invalid)';
        AssetCaption: Text;
    begin

        WalletFacade.FindWalletByReferenceNumber(WalletReferenceNumber, Wallet);
        if (Wallet.Read()) then begin
            WalletFacade.GetWalletAssets(Wallet.WalletReferenceNumber, WalletAssets);

            while (WalletAssets.Read()) do begin
                Clear(Option);

                case WalletAssets.AssetType of
                    WalletAssets.AssetType::COUPON:
                        begin
                            AssetCaption := StrSubstNo('%1 (%2)', WalletAssets.AssetDescription, WalletAssets.AssetReferenceNumber);

                            Coupon.SetFilter("Reference No.", '=%1', CopyStr(UpperCase(WalletAssets.AssetReferenceNumber), 1, MaxStrLen(Coupon."Reference No.")));
                            if (Coupon.FindFirst()) then
                                AssetCaption := StrSubstNo('%1 (%2)', Coupon.Description, WalletAssets.AssetReferenceNumber);

                            if (TryValidateCoupon(WalletAssets.AssetReferenceNumber)) then begin
                                Option.Add('caption', AssetCaption);
                                Option.Add('value', Format(WalletAssets.AssetEntryNo));
                                CouponsList.Add(Option)
                            end else begin
                                Option.Add('caption', StrSubstNo('%1 %2', AssetCaption, InvalidLabel));
                                Option.Add('value', Format(WalletAssets.AssetEntryNo));
                                InvalidCouponsList.Add(Option);
                            end;

                        end;
                end;
            end;
        end;
    end;

    local procedure AddSection(SectionCaption: Text; GroupCaption: Text; GroupId: Text; Expanded: Boolean; AvailableOptions: List of [JsonObject]): JsonObject
    var
        Section, Options, RadioControl, NoneOption : JsonObject;
        SettingsArray, RadioOptionsArray : JsonArray;
        JToken: JsonToken;
        OptionObj: JsonObject;
        i: Integer;
        LabelNone: Label 'None';
        NoneValue: Text;
    begin

        NoneValue := '__none__' + Format(CreateGuid(), 0, 4).ToLower();

        if (not Expanded) then
            if (AvailableOptions.Count() = 0) then
                exit(Section);

        NoneOption.Add('caption', LabelNone);
        NoneOption.Add('value', NoneValue);
        if (AvailableOptions.Count() = 0) then
            RadioOptionsArray.Add(NoneOption);

        for i := 1 to AvailableOptions.Count() do begin
            Clear(Options);
            OptionObj := AvailableOptions.Get(i);
            if (OptionObj.Get('caption', JToken)) then
                Options.Add('caption', JToken.AsValue().AsText());
            if (OptionObj.Get('value', JToken)) then
                Options.Add('value', JToken.AsValue().AsText());
            RadioOptionsArray.Add(Options);
        end;

        RadioControl.Add('type', 'radio');
        RadioControl.Add('id', GroupId);
        RadioControl.Add('caption', GroupCaption);
        RadioControl.Add('vertical', true);
        //RadioControl.Add('value', NoneValue);
        RadioControl.Add('options', RadioOptionsArray);
        SettingsArray.Add(RadioControl);

        Section.Add('type', 'group');
        Section.Add('caption', StrSubstNo('%1 (%2)', SectionCaption, AvailableOptions.Count()));
        Section.Add('expanded', Expanded);
        Section.Add('settings', SettingsArray);

        exit(Section);
    end;

    [TryFunction]
    local procedure TryValidateCoupon(ReferenceNo: Text)
    var
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        Coupon: Record "NPR NpDc Coupon";
        POSSession: Codeunit "NPR POS Session";
    begin
        CouponMgt.ValidateCoupon(POSSession, ReferenceNo, Coupon);
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionWalletInventory.js### 
'const main=async({popup:n,captions:c,workflow:t})=>{const i=await n.input(c.inputReference);if(!i)return;const s=await t.respond("getWalletInventory",{input:i});if(!s.success){await n.message(s.reason);return}const r=await n.configuration({title:s.title,caption:s.caption,settings:s.settings});if(r===null)return;const e=await t.respond("processWalletInventorySelection",{selectedAsset:r});if(!e.success){e.reason&&await n.message(e.reason);return}if(e.selectItem&&e.itemReference===""){const o=await n.configuration({title:e.title,caption:e.caption,settings:e.settings});if(o===null)return;const a=await t.respond("applyItemAndInventorySelection",{selectedAsset:o,couponReference:e.couponReference});if(!a.success){a.reason&&await n.message(a.reason);return}await t.run("ITEM",{parameters:{SkipItemAvailabilityCheck:!0,itemNo:a.itemReference}}),await t.respond("applyCoupon",{couponReference:e.couponReference});return}!e.selectItem&&e.itemReference!==""&&await t.run("ITEM",{parameters:{SkipItemAvailabilityCheck:!0,itemNo:e.itemReference}}),await t.respond("applyCoupon",{couponReference:e.couponReference})};'
        )
    end;


}