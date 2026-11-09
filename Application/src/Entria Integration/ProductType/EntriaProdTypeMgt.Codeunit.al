codeunit 6184704 "NPR Entria Prod. Type Mgt."
{
    Access = Internal;

    procedure GetProductType(var Item: Record Item; var SetupProductTypes: Dictionary of [Code[20], Text]; var SetupProductTypesLoaded: Boolean): Text
    var
        EcomVirtualItemMgt: Codeunit "NPR Ecom Virtual Item Mgt";
        ProductType: Text;
    begin
        if Item."NPR CreateAttractionWallet" then
            exit('ATTRACTION_PACKAGE');
        if EcomVirtualItemMgt.IsTicketLine(Item) then
            exit('TICKET');
        if not SetupProductTypesLoaded then begin
            LoadSetupProductTypes(SetupProductTypes);
            SetupProductTypesLoaded := true;
        end;
        if SetupProductTypes.Get(Item."No.", ProductType) then
            exit(ProductType);
        exit('ITEM');
    end;

    // Setup-derived types for the whole request. An item keeps the first type added, so the call order sets the precedence.
    local procedure LoadSetupProductTypes(var SetupProductTypes: Dictionary of [Code[20], Text])
    var
        TempMembersAlterSetup: Record "NPR MM Members. Alter. Setup" temporary;
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        ItemNos: List of [Code[20]];
    begin
        EcomCreateMMShipImpl.CollectMembershipSaleItemNos(ItemNos);
        AddSetupProductTypes(SetupProductTypes, ItemNos, 'MEMBERSHIP');
        EcomCreateMMShipImpl.CollectMembershipAlterationSetup(TempMembersAlterSetup);
        TempMembersAlterSetup.SetRange("Alteration Type", TempMembersAlterSetup."Alteration Type"::RENEW);
        AddAlterationProductTypes(SetupProductTypes, TempMembersAlterSetup, 'MEMBERSHIP_RENEW');
        TempMembersAlterSetup.SetRange("Alteration Type", TempMembersAlterSetup."Alteration Type"::EXTEND);
        AddAlterationProductTypes(SetupProductTypes, TempMembersAlterSetup, 'MEMBERSHIP_EXTEND');
        TempMembersAlterSetup.SetRange("Alteration Type", TempMembersAlterSetup."Alteration Type"::UPGRADE);
        AddAlterationProductTypes(SetupProductTypes, TempMembersAlterSetup, 'MEMBERSHIP_UPGRADE');
        TempMembersAlterSetup.SetRange("Alteration Type", TempMembersAlterSetup."Alteration Type"::AUTORENEW);
        AddAlterationProductTypes(SetupProductTypes, TempMembersAlterSetup, 'MEMBERSHIP_AUTORENEW');
        TempMembersAlterSetup.SetRange("Alteration Type", TempMembersAlterSetup."Alteration Type"::REGRET);
        AddAlterationProductTypes(SetupProductTypes, TempMembersAlterSetup, 'MEMBERSHIP_REGRET');
        TempMembersAlterSetup.SetRange("Alteration Type", TempMembersAlterSetup."Alteration Type"::CANCEL);
        AddAlterationProductTypes(SetupProductTypes, TempMembersAlterSetup, 'MEMBERSHIP_CANCEL');
        Clear(ItemNos);
        EcomCreateCouponImpl.CollectCouponItemNos(ItemNos);
        AddSetupProductTypes(SetupProductTypes, ItemNos, 'COUPON');
    end;

    local procedure AddSetupProductTypes(var SetupProductTypes: Dictionary of [Code[20], Text]; ItemNos: List of [Code[20]]; ProductType: Text)
    var
        ItemNo: Code[20];
    begin
        foreach ItemNo in ItemNos do
            if (ItemNo <> '') and not SetupProductTypes.ContainsKey(ItemNo) then
                SetupProductTypes.Add(ItemNo, ProductType);
    end;

    local procedure AddAlterationProductTypes(var SetupProductTypes: Dictionary of [Code[20], Text]; var TempMembersAlterSetup: Record "NPR MM Members. Alter. Setup" temporary; ProductType: Text)
    begin
        if TempMembersAlterSetup.FindSet() then
            repeat
                if (TempMembersAlterSetup."Sales Item No." <> '') and not SetupProductTypes.ContainsKey(TempMembersAlterSetup."Sales Item No.") then
                    SetupProductTypes.Add(TempMembersAlterSetup."Sales Item No.", ProductType);
            until TempMembersAlterSetup.Next() = 0;
    end;

    procedure GetMembershipSaleItemNo(SystemId: Guid): Code[20]
    var
        MMMembersSalesSetup: Record "NPR MM Members. Sales Setup";
        EcomCreateMMShipImpl: Codeunit "NPR EcomCreateMMShipImpl";
    begin
        EcomCreateMMShipImpl.SetMembershipSaleItemFilter(MMMembersSalesSetup);
        MMMembersSalesSetup.SetRange(SystemId, SystemId);
        MMMembersSalesSetup.ReadIsolation := IsolationLevel::ReadCommitted;
        MMMembersSalesSetup.SetLoadFields("No.");
        if not MMMembersSalesSetup.FindFirst() then
            exit('');
        exit(MMMembersSalesSetup."No.");
    end;

    procedure GetMembershipAlterationItemNo(SystemId: Guid): Code[20]
    var
        MMMembersAlterSetup: Record "NPR MM Members. Alter. Setup";
    begin
        MMMembersAlterSetup.ReadIsolation := IsolationLevel::ReadCommitted;
        MMMembersAlterSetup.SetLoadFields("Sales Item No.");
        if not MMMembersAlterSetup.GetBySystemId(SystemId) then
            exit('');
        exit(MMMembersAlterSetup."Sales Item No.");
    end;

    procedure GetWalletCouponItemNo(SystemId: Guid): Code[20]
    var
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        EcomCreateCouponImpl.SetWalletCouponSetupFilter(WalletCouponSetup);
        WalletCouponSetup.SetRange(SystemId, SystemId);
        WalletCouponSetup.ReadIsolation := IsolationLevel::ReadCommitted;
        WalletCouponSetup.SetLoadFields(TriggerOnItemNo);
        if not WalletCouponSetup.FindFirst() then
            exit('');
        exit(WalletCouponSetup.TriggerOnItemNo);
    end;

    procedure GetEcomSaleCouponItemNo(SystemId: Guid): Code[20]
    var
        EcomSaleCouponLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        EcomCreateCouponImpl.SetEcomSaleCouponLineFilter(EcomSaleCouponLine, '');
        EcomSaleCouponLine.SetRange(SystemId, SystemId);
        EcomSaleCouponLine.ReadIsolation := IsolationLevel::ReadCommitted;
        EcomSaleCouponLine.SetLoadFields("No.");
        if not EcomSaleCouponLine.FindFirst() then
            exit('');
        exit(EcomSaleCouponLine."No.");
    end;

    procedure GetEnabledCouponTypeCode(SystemId: Guid): Code[20]
    var
        CouponType: Record "NPR NpDc Coupon Type";
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
    begin
        EcomCreateCouponImpl.SetEnabledCouponTypeFilter(CouponType);
        CouponType.SetRange(SystemId, SystemId);
        CouponType.ReadIsolation := IsolationLevel::ReadCommitted;
        CouponType.SetLoadFields(Code);
        if CouponType.FindFirst() then
            exit(CouponType.Code);
        exit('');
    end;

    /// <summary>Adds the items of the coupon type's wallet and ecom rows to the buffer.</summary>
    procedure AddCouponTypeItemNos(var TempItemChange: Record "NPR Inventory Item Change" temporary; CouponTypeCode: Code[20])
    var
        WalletCouponSetup: Record "NPR WalletCouponSetup";
        EcomSaleCouponLine: Record "NPR NpDc Iss.OnEcomSale S.Line";
        EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
        ItemChangeMgt: Codeunit "NPR Inventory Item Change Mgt.";
    begin
        if CouponTypeCode = '' then
            exit;
        // No lock, as for the Entria flag. A concurrent child row is marked by its own subscriber, but a sync between its commit and ours can return its item with the old type (accepted race).
        EcomCreateCouponImpl.SetWalletCouponSetupFilter(WalletCouponSetup);
        WalletCouponSetup.SetRange("Coupon Type", CouponTypeCode);
        WalletCouponSetup.ReadIsolation := IsolationLevel::ReadCommitted;
        WalletCouponSetup.SetLoadFields(TriggerOnItemNo);
        if WalletCouponSetup.FindSet() then
            repeat
                ItemChangeMgt.AddItemNo(TempItemChange, WalletCouponSetup.TriggerOnItemNo);
            until WalletCouponSetup.Next() = 0;

        EcomCreateCouponImpl.SetEcomSaleCouponLineFilter(EcomSaleCouponLine, '');
        EcomSaleCouponLine.SetRange("Coupon Type", CouponTypeCode);
        EcomSaleCouponLine.ReadIsolation := IsolationLevel::ReadCommitted;
        EcomSaleCouponLine.SetLoadFields("No.");
        if EcomSaleCouponLine.FindSet() then
            repeat
                ItemChangeMgt.AddItemNo(TempItemChange, EcomSaleCouponLine."No.");
            until EcomSaleCouponLine.Next() = 0;
    end;

    /// <summary>Marks the Entria products in the buffer as changed. Other item numbers are skipped.</summary>
    procedure MarkEntriaItemsChanged(var TempItemChange: Record "NPR Inventory Item Change" temporary)
    var
        Item: Record Item;
        TempEntriaItemChange: Record "NPR Inventory Item Change" temporary;
        ItemChangeMgt: Codeunit "NPR Inventory Item Change Mgt.";
    begin
        Item.ReadIsolation := IsolationLevel::ReadCommitted;
        Item.SetLoadFields("NPR Entria Product");
        // Every flag is read before this call touches a change row. Change rows touched earlier in the transaction stay locked.
        if TempItemChange.FindSet() then
            repeat
                if Item.Get(TempItemChange."Item No.") then
                    if Item."NPR Entria Product" then
                        ItemChangeMgt.AddItemNo(TempEntriaItemChange, TempItemChange."Item No.");
            until TempItemChange.Next() = 0;
        ItemChangeMgt.MarkItemsChanged(TempEntriaItemChange);
    end;
}
