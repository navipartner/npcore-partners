codeunit 6151076 "NPR POSActionWalletInventory" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action shows the inventory of the wallet, allowing the user to select an asset from the wallet to add to the sale line.';
        IncludeCouponsCaption: Label 'Include coupons';
        IncludeCouponsDescription: Label 'When enabled, coupons in the wallet will be included in the inventory list.';
        ShowInvalidAssetsCaption: Label 'Show invalid assets';
        ShowInvalidAssetsDescription: Label 'When enabled, assets that are no longer valid (e.g. expired coupons) will be shown in the inventory list with an (Invalid) tag.';
        InputWalletReferenceLbl: Label 'Input Wallet Reference';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('Include Coupons', true, IncludeCouponsCaption, IncludeCouponsDescription);
        WorkflowConfig.AddBooleanParameter('Show Invalid Assets', false, ShowInvalidAssetsCaption, ShowInvalidAssetsDescription);
        WorkflowConfig.AddLabel('inputReference', InputWalletReferenceLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'getWalletInventory':
                FrontEnd.WorkflowResponse(GetWalletInventory(Context));

            'processWalletInventorySelection':
                ProcessWalletInventorySelection(Context);

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

        IncludeCoupons := Context.GetBooleanParameter('Include Coupons');
        IncludeInvalidAssets := Context.GetBooleanParameter('Show Invalid Assets');

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

    local procedure ProcessWalletInventorySelection(Context: Codeunit "NPR POS JSON Helper")
    var
        SelectedOption: Text;
        JObject: JsonObject;
        AssetEntryNo: Integer;
        CouponMgt: Codeunit "NPR NpDc Coupon Mgt.";
        POSSession: Codeunit "NPR POS Session";
        WalletAssetLine: Record "NPR WalletAssetLine";
        JToken: JsonToken;
    begin
        if (not Context.HasProperty('selection')) then
            Error('Selection is required. This is a programming error, please contact support.');

        SelectedOption := Context.GetString('selection');
        if SelectedOption.Contains('__none__') then
            exit;

        // Entry No. is primary key of the asset,
        JObject.ReadFrom(SelectedOption);
        if (not JObject.Contains('couponSection')) then
            exit;

        // AssetEntryNo := JObject.GetInteger('couponSection');
        JObject.Get('couponSection', JToken);
        AssetEntryNo := JToken.AsValue().AsInteger();

        if (not WalletAssetLine.Get(AssetEntryNo)) then
            exit;

        case WalletAssetLine.Type of
            WalletAssetLine.Type::COUPON:
                CouponMgt.ScanCoupon(POSSession, WalletAssetLine.LineTypeReference);
            else
                Error('Unsupported asset type selected. This is a programming error, please contact support.');
        end;

    end;

    local procedure GetWalletAssets(WalletReferenceNumber: Text[100]; var CouponsList: List of [JsonObject]; var InvalidCouponsList: List of [JsonObject])
    var
        WalletAssets: Query "NPR AttractionWalletAssets";
        Wallet: Query "NPR FindAttractionWallets";
        WalletFacade: Codeunit "NPR AttractionWalletFacade";
        Option: JsonObject;
        InvalidLabel: Label '(Invalid)';
    begin

        WalletFacade.FindWalletByReferenceNumber(WalletReferenceNumber, Wallet);
        if (Wallet.Read()) then begin
            WalletFacade.GetWalletAssets(Wallet.WalletReferenceNumber, WalletAssets);

            while (WalletAssets.Read()) do begin
                Clear(Option);

                case WalletAssets.AssetType of
                    WalletAssets.AssetType::COUPON:
                        begin
                            if (TryValidateCoupon(WalletAssets.AssetReferenceNumber)) then begin
                                Option.Add('caption', WalletAssets.AssetDescription + ' (' + WalletAssets.AssetReferenceNumber + ')');
                                Option.Add('value', Format(WalletAssets.AssetEntryNo));
                                CouponsList.Add(Option)
                            end else begin
                                Option.Add('caption', WalletAssets.AssetDescription + ' (' + WalletAssets.AssetReferenceNumber + ') ' + InvalidLabel);
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
'const main=async({popup:n,captions:a,workflow:t})=>{const i=await n.input(a.inputReference);if(!i)return;const e=await t.respond("getWalletInventory",{input:i});if(!e.success){await n.message(e.reason);return}const s=await n.configuration({title:e.title,caption:e.caption,settings:e.settings});s!==null&&await t.respond("processWalletInventorySelection",{selection:s})};'
        )
    end;


}