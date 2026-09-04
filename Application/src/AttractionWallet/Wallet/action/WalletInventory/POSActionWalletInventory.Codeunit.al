codeunit 6151076 "NPR POSActionWalletInventory" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        IncludeCouponParameterLabel: Label 'Include Coupons', Locked = true;
        ThresholdParameterLabel: Label 'Threshold applicable items', Locked = true;
        ShowInvalidAssetsParameterLabel: Label 'Show Invalid Assets', Locked = true;
        WalletReferenceParameterLabel: Label 'WalletReferenceNo', Locked = true;

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
        SelectRequiredLbl: Label 'Nothing is selected. Pick an entry from the list, or press Cancel to close.';
        InvalidCouponSelectedLbl: Label 'That coupon is no longer valid and cannot be used. Pick a valid coupon, or press Cancel to close.';
        WalletReferenceCaption: Label 'Wallet Reference';
        WalletReferenceDescription: Label 'Reference number of the wallet. Filled in by the POS input box when the action runs from a scan; leave blank to prompt for it.';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter(IncludeCouponParameterLabel, true, IncludeCouponsCaption, IncludeCouponsDescription);
        WorkflowConfig.AddBooleanParameter(ShowInvalidAssetsParameterLabel, false, ShowInvalidAssetsCaption, ShowInvalidAssetsDescription);
        WorkflowConfig.AddIntegerParameter(ThresholdParameterLabel, 30, ThresholdCaption, ThresholdDescription);
        WorkflowConfig.AddTextParameter(WalletReferenceParameterLabel, '', WalletReferenceCaption, WalletReferenceDescription);
        WorkflowConfig.AddLabel('inputReference', InputWalletReferenceLbl);
        WorkflowConfig.AddLabel('selectRequired', SelectRequiredLbl);
        WorkflowConfig.AddLabel('invalidCouponSelected', InvalidCouponSelectedLbl);
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
        NoUsableCouponsLbl: Label 'This wallet has no coupons that can be used.';
        WalletId: Text[100];
        Settings: JsonArray;

        IncludeCoupons: Boolean;
        IncludeInvalidAssets: Boolean;
        CouponsList, InvalidCouponsList : List of [JsonObject];
        AutoSelectedAsset: JsonObject;
        JToken: JsonToken;
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

        // Nothing usable and nothing to show: say so, rather than render a dialog whose only option is "None".
        if (IncludeCoupons and (CouponsList.Count() = 0) and (not (IncludeInvalidAssets and (InvalidCouponsList.Count() > 0)))) then begin
            Response.Add('success', false);
            Response.Add('reason', NoUsableCouponsLbl);
            exit(Response);
        end;

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

        // Exactly one usable coupon: skip the coupon dialog
        if (IncludeCoupons and (CouponsList.Count() = 1) and (not (IncludeInvalidAssets and (InvalidCouponsList.Count() > 0)))) then begin
            CouponsList.Get(1).Get('value', JToken);
            AutoSelectedAsset.Add('couponSection', JToken.AsValue().AsText());
            Response.Add('autoSelectedAsset', AutoSelectedAsset);
        end;
        exit(Response);

    end;

    local procedure ProcessWalletInventorySelection(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        SelectedOption: Text;
        JObject: JsonObject;
        AssetEntryNo: Integer;
        WalletAssetLine: Record "NPR WalletAssetLine";
        SuggestListOfItems: List of [JsonObject];
        NoItemsConfigured: Boolean;
        NoneAtThisStore: Boolean;
        JToken: JsonToken;
        Settings: JsonArray;
        ResponseOk, ResponseFail : JsonObject;
        ItemListThreshold: Integer;
        ItemSectionCaption: Label 'Items';
        ItemGroupCaption: Label 'Items this coupon can be used for';
        DialogTitle: Label 'Add Item for Coupon';
        DialogCaption: Label 'Choose the item to add to the sale for this coupon. The coupon then applies its discount according to its own setup.';
        NoItemsAtThisStoreLbl: Label 'This coupon has no applicable items at this store.';
        NoItemsConfiguredLbl: Label 'Coupon %1 has no applicable items configured.', Comment = '%1 = coupon reference number';
        UnsupportedAssetTypeLbl: Label 'Unsupported asset type.';
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
                    CouponsAppliesToItem(WalletAssetLine.LineTypeReference, ItemListThreshold, SuggestListOfItems, NoItemsConfigured, NoneAtThisStore);

                    // An Item List coupon with no usable item lines would attach, discount nothing and still be
                    // consumed at posting - a setup fault to surface, not a coupon to apply.
                    if (NoItemsConfigured) then begin
                        ResponseFail.Add('reason', StrSubstNo(NoItemsConfiguredLbl, WalletAssetLine.LineTypeReference));
                        exit(ResponseFail);
                    end;

                    if (NoneAtThisStore) then begin
                        ResponseFail.Add('reason', NoItemsAtThisStoreLbl);
                        exit(ResponseFail);
                    end;

                    // Not item-limited, or more applicable items than the threshold lists: apply directly.
                    if (SuggestListOfItems.Count() = 0) then begin
                        ResponseOk.Add('success', true);
                        ResponseOk.Add('selectItem', false);
                        ResponseOk.Add('couponReference', WalletAssetLine.LineTypeReference);
                        ResponseOk.Add('itemReference', '');
                        exit(ResponseOk);
                    end;
                    if (SuggestListOfItems.Count() = 1) then begin
                        // if the coupon only applies to one item, automatically select that item and add coupon to sale line
                        SuggestListOfItems.Get(1).AsToken().AsObject().Get('value', JToken);
                        ResponseOk.Add('success', true);
                        ResponseOk.Add('selectItem', false);
                        ResponseOk.Add('couponReference', WalletAssetLine.LineTypeReference);
                        ResponseOk.Add('itemReference', JToken.AsValue().AsText());
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
                        exit(ResponseOk);
                    end;
                end;
            else
                ResponseFail.Add('reason', UnsupportedAssetTypeLbl);
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
        ResponseFail.Add('success', false);

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


    local procedure CouponsAppliesToItem(CouponReferenceNo: Text; ItemListThreshold: Integer; SuggestListOfItems: List of [JsonObject]; var NoItemsConfigured: Boolean; var NoneAtThisStore: Boolean)
    var
        Coupon: Record "NPR NpDc Coupon";
        CouponType: Record "NPR NpDc Coupon Type";
        CouponApplicableItem: Record "NPR NpDc Coupon List Item";
        Item: Record Item;
        SalePOS: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
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
        CouponApplicableItem.SetFilter("No.", '<>%1', ''); // the Line No. -1 totals row carries no item
        if (CouponApplicableItem.IsEmpty()) then begin
            // Fine for a coupon that is not item-limited; a broken setup for an Item List one.
            NoItemsConfigured := UsesItemListModule(CouponType);
            exit;
        end;

        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        CouponApplicableItem.SetFilter("Offered at POS Store Code", '%1|%2', '', SalePOS."POS Store Code");

        // Item-limited, yet nothing for this store - must not be read as "not limited to any items".
        if (CouponApplicableItem.IsEmpty()) then begin
            NoneAtThisStore := true;
            exit;
        end;

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
        WalletQuery: Query "NPR FindAttractionWallets";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        Coupon: Record "NPR NpDc Coupon";
        Option: JsonObject;
        InvalidLabel: Label '(Invalid)';
        WalletExpired: Label 'The wallet with reference number %1 expired on %2.';
        WalletNotFound: Label 'No valid wallet found with reference number %1.';
        AssetCaption: Text;
    begin

        WalletFacade.FindWalletByReferenceNumber(WalletReferenceNumber, WalletQuery);
        if (WalletQuery.Read()) then begin

            if ((WalletQuery.WalletExpirationDate <> 0DT) and (WalletQuery.WalletExpirationDate < CurrentDateTime())) then
                Error(WalletExpired, WalletReferenceNumber, WalletQuery.WalletExpirationDate);

            WalletFacade.GetWalletAssets(WalletQuery.WalletReferenceNumber, WalletAssets);

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
        end else begin
            Error(WalletNotFound, WalletReferenceNumber);
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


    local procedure UsesItemListModule(CouponType: Record "NPR NpDc Coupon Type"): Boolean
    var
        ApplyItemList: Codeunit "NPR NpDc Module Apply ItemList";
        ValidateItemList: Codeunit "NPR NpDc Module Valid. Item L.";
    begin
        exit((CouponType."Apply Discount Module" = ApplyItemList.ModuleCode()) or (CouponType."Validate Coupon Module" = ValidateItemList.ModuleCode()));
    end;

    #region Ean Box Event Handling
    local procedure ActionCode(): Code[20]
    begin
        exit(CopyStr(Format("NPR POS Workflow"::WALLET_INVENTORY), 1, 20));
    end;

    local procedure EventCodeWalletRef(): Code[20]
    begin
        exit('WALLET_INVENTORY');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'DiscoverEanBoxEvents', '', true, true)]
    local procedure DiscoverEanBoxEvents(var EanBoxEvent: Record "NPR Ean Box Event")
    var
        ModuleNameLbl: Label 'Attraction Wallet';
        DescriptionLbl: Label 'Wallet Reference No.';
    begin
        if EanBoxEvent.Get(EventCodeWalletRef()) then
            exit;

        EanBoxEvent.Init();
        EanBoxEvent.Code := EventCodeWalletRef();
        EanBoxEvent."Module Name" := CopyStr(ModuleNameLbl, 1, MaxStrLen(EanBoxEvent."Module Name"));
        EanBoxEvent.Description := CopyStr(DescriptionLbl, 1, MaxStrLen(EanBoxEvent.Description));
        EanBoxEvent."Action Code" := ActionCode();
        EanBoxEvent."POS View" := EanBoxEvent."POS View"::Sale;
        EanBoxEvent."Event Codeunit" := Codeunit::"NPR POSActionWalletInventory";
        EanBoxEvent.Insert(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Setup Mgt.", 'OnInitEanBoxParameters', '', true, true)]
    local procedure OnInitEanBoxParameters(var Sender: Codeunit "NPR POS Input Box Setup Mgt."; EanBoxEvent: Record "NPR Ean Box Event")
    begin
        if EanBoxEvent.Code <> EventCodeWalletRef() then
            exit;
        Sender.SetNonEditableParameterValues(EanBoxEvent, WalletReferenceParameterLabel, true, '');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Input Box Evt Handler", 'SetEanBoxEventInScope', '', true, true)]
    local procedure SetEanBoxEventInScopeWalletRef(EanBoxSetupEvent: Record "NPR Ean Box Setup Event"; EanBoxValue: Text; var InScope: Boolean)
    var
        WalletExtRef: Record "NPR AttractionWalletExtRef";
        Wallet: Record "NPR AttractionWallet";
    begin
        if EanBoxSetupEvent."Event Code" <> EventCodeWalletRef() then
            exit;

        // Runs for every value entered in the input box, so this is an existence check on indexed keys
        // only (like the coupon event); whether the wallet is blocked/expired is decided when the action runs.
        if StrLen(EanBoxValue) > MaxStrLen(WalletExtRef.ExternalReference) then
            exit;

        WalletExtRef.SetFilter(ExternalReference, '=%1', CopyStr(EanBoxValue, 1, MaxStrLen(WalletExtRef.ExternalReference)));
        if not WalletExtRef.IsEmpty() then begin
            InScope := true;
            exit;
        end;

        if StrLen(EanBoxValue) > MaxStrLen(Wallet.ReferenceNumber) then
            exit;
        Wallet.SetFilter(ReferenceNumber, '=%1', CopyStr(UpperCase(EanBoxValue), 1, MaxStrLen(Wallet.ReferenceNumber)));
        if not Wallet.IsEmpty() then
            InScope := true;
    end;
    #endregion Ean Box Event Handling

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionWalletInventory.js### 
'const main=async({popup:n,captions:r,workflow:s,parameters:u})=>{const o=t=>t!=null&&typeof t!="object"&&String(t)!==""&&String(t)!=="{}",l=u.WalletReferenceNo||await n.input(r.inputReference);if(!l)return;const a=await s.respond("getWalletInventory",{input:l});if(Boolean(a.success)!==!0){await n.message(a.reason);return}let i;if(a.autoSelectedAsset)i=a.autoSelectedAsset;else do{if(i=await n.configuration({title:a.title,caption:a.caption,settings:a.settings}),!i||String(i.couponSection).startsWith("__none__"))return;o(i.couponSection)||(o(i.invalidCouponSection)?await n.message(r.invalidCouponSelected):await n.message(r.selectRequired))}while(!o(i.couponSection));const e=await s.respond("processWalletInventorySelection",{selectedAsset:i});if(Boolean(e.success)!==!0){e.reason&&await n.message(e.reason);return}if(Boolean(e.selectItem)===!0&&e.itemReference===""){let t;do{if(t=await n.configuration({title:e.title,caption:e.caption,settings:e.settings}),!t)return;o(t.itemSection)||await n.message(r.selectRequired)}while(!o(t.itemSection));const c=await s.respond("applyItemAndInventorySelection",{selectedAsset:t,couponReference:e.couponReference});if(Boolean(c.success)!==!0){c.reason&&await n.message(c.reason);return}await s.run("ITEM",{parameters:{SkipItemAvailabilityCheck:!0,itemNo:c.itemReference}}),await s.respond("applyCoupon",{couponReference:e.couponReference});return}Boolean(e.selectItem)!==!0&&e.itemReference!==""&&await s.run("ITEM",{parameters:{SkipItemAvailabilityCheck:!0,itemNo:e.itemReference}}),await s.respond("applyCoupon",{couponReference:e.couponReference})};'
        )
    end;


}
