codeunit 6059783 "NPR POS Item-Check Avail."
{
    Access = Internal;
    EventSubscriberInstance = Manual;

    #region Availability check
    procedure DefineScopeAndCheckAvailability(POSSession: Codeunit "NPR POS Session"; AskConfirmation: Boolean): Boolean
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        exit(DefineScopeAndCheckAvailability(SalePOS, AskConfirmation));
    end;

    procedure DefineScopeAndCheckAvailability(SalePOS: Record "NPR POS Sale"; AskConfirmation: Boolean): Boolean
    var
        Scope: Record "NPR POS Sale Line";
    begin
        GetAvailabilityCheckScope(SalePOS, Scope);
        exit(CheckAvailability_PosSale(SalePOS, Scope, AskConfirmation));
    end;

    procedure CheckAvailability_PosSale(SalePOS: Record "NPR POS Sale"; AskConfirmation: Boolean): Boolean
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        exit(CheckAvailability_PosSale(SalePOS, SaleLinePOS, AskConfirmation));
    end;

    procedure CheckAvailability_PosSale(SalePOS: Record "NPR POS Sale"; var Scope: Record "NPR POS Sale Line"; AskConfirmation: Boolean): Boolean
    var
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        TempPosItemAvailability: Record "NPR POS Item Availability" temporary;
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.Copy(Scope);
        SaleLinePOS.SetRange(Type, SaleLinePOS.type::Item);
        SaleLinePOS.SetFilter("No.", '<>%1', '');
        SaleLinePOS.SetFilter("Quantity (Base)", '>%1', 0);
        if SaleLinePOS.IsEmpty() then
            exit(true);

        SalePOS.TestField("Register No.");
        GetPosInvtProfile(SalePOS."Register No.", PosInventoryProfile);
        if not (PosInventoryProfile."Stockout Warning" or IgnoreProfile) then
            exit(true);

        SaleLinePOS.FindSet();
        repeat
            if not TempPosItemAvailability.Get(SaleLinePOS."No.", SaleLinePOS."Variant Code", SaleLinePOS."Location Code") then
                if not CheckItemAvailable(SaleLinePOS, 0, 0, PosInventoryProfile, TempPosItemAvailability) then
                    TempPosItemAvailability.Insert();
        until SaleLinePOS.Next() = 0;

        AvailabilityIssuesFound := not TempPosItemAvailability.IsEmpty();
        if not AvailabilityIssuesFound then
            exit(true);

        exit(RaiseNotAvailableEvent(TempPosItemAvailability, Scope, PosInventoryProfile, false, AskConfirmation));
    end;

    procedure CheckAvailability_PosSaleLine(SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line"; AskConfirmation: Boolean): Boolean
    var
        PosInventoryProfile: Record "NPR POS Inventory Profile";
        TempPosItemAvailability: Record "NPR POS Item Availability" temporary;
    begin
        if (SaleLinePOS.Type <> SaleLinePOS.Type::Item) or (SaleLinePOS."No." = '') or (SaleLinePOS."Quantity (Base)" <= 0) then
            exit(true);
        SaleLinePOS.TestField("Register No.");
        GetPosInvtProfile(SaleLinePOS."Register No.", PosInventoryProfile);
        if CheckItemAvailable(SaleLinePOS, SaleLinePOS."Quantity (Base)", xSaleLinePOS."Quantity (Base)", PosInventoryProfile, TempPosItemAvailability) then
            exit(true);

        AvailabilityIssuesFound := true;
        TempPosItemAvailability.Insert();
        SaleLinePOS.SetRecFilter();
        exit(RaiseNotAvailableEvent(TempPosItemAvailability, SaleLinePOS, PosInventoryProfile, true, AskConfirmation));
    end;

    local procedure CheckItemAvailable(SaleLinePOS: Record "NPR POS Sale Line"; CurrQtyBase: Decimal; xCurrQtyBase: Decimal; PosInventoryProfile: Record "NPR POS Inventory Profile"; var PosItemAvailability: Record "NPR POS Item Availability"): Boolean
    var
        ItemCheckAvail: Codeunit "Item-Check Avail.";
    begin
        if not (PosInventoryProfile."Stockout Warning" or IgnoreProfile) then
            exit(true);
        if not ItemCheckAvail.ShowWarningForThisItem(SaleLinePOS."No.") then
            exit(true);

        if xCurrQtyBase < 0 then
            xCurrQtyBase := 0;

        PosItemAvailability.Init();
        PosItemAvailability."Item No." := SaleLinePOS."No.";
        PosItemAvailability."Variant Code" := SaleLinePOS."Variant Code";
        PosItemAvailability."Location Code" := SaleLinePOS."Location Code";
        PosItemAvailability."Unit of Measure Code" := SaleLinePOS."Unit of Measure Code";
        PosItemAvailability."Qty. per Unit of Measure" := SaleLinePOS."Qty. per Unit of Measure";
        PosItemAvailability.Description := SaleLinePOS.Description;

        PosItemAvailability."Available Inventory (Base)" := CalcAvailableInventory(SaleLinePOS, false);
        PosItemAvailability."Avail. Inventory, Other (Base)" := CalcAvailableInventory(SaleLinePOS, true);
        PosItemAvailability."Current Quantity (Base)" := CurrQtyBase;
        PosItemAvailability."Gross Requirement (Base)" := CalcGrossRequirement(SaleLinePOS) + CurrQtyBase - xCurrQtyBase;
        PosItemAvailability."Inventory Shortage (Base)" := PosItemAvailability."Available Inventory (Base)" - PosItemAvailability."Gross Requirement (Base)";
        PosItemAvailability.CalcFromBaseQuantities();
        PosItemAvailability."Inventory Shortage" := PosItemAvailability."Available Inventory" - PosItemAvailability."Gross Requirement";

        exit(PosItemAvailability."Inventory Shortage" >= 0);
    end;

    local procedure CalcAvailableInventory(SaleLinePOS: Record "NPR POS Sale Line"; AllOtherLocations: Boolean): Decimal
    var
        Item: Record Item;
        UnpostedPosItemEntries: Query "NPR Unposted POS Item Entries";
        UnpostedPosQtyBase: Decimal;
    begin
        Item.Get(SaleLinePOS."No.");
        if AllOtherLocations then
            Item.SetFilter("Location Filter", '<>%1', SaleLinePOS."Location Code")
        else
            Item.SetRange("Location Filter", SaleLinePOS."Location Code");
        Item.SetRange("Variant Filter", SaleLinePOS."Variant Code");
        Item.CalcFields(Inventory, "Qty. on Sales Order");

        UnpostedPosItemEntries.SetRange(Item_No, SaleLinePOS."No.");
        UnpostedPosItemEntries.SetRange(Variant_Code, SaleLinePOS."Variant Code");
        if AllOtherLocations then
            UnpostedPosItemEntries.SetFilter(Location_Code, '<>%1', SaleLinePOS."Location Code")
        else
            UnpostedPosItemEntries.SetRange(Location_Code, SaleLinePOS."Location Code");
        UnpostedPosItemEntries.Open();
        while UnpostedPosItemEntries.Read() do
            UnpostedPosQtyBase += UnpostedPosItemEntries.Sum_Quantity_Base;

        exit(Item.Inventory - Item."Qty. on Sales Order" - UnpostedPosQtyBase);
    end;

    local procedure CalcGrossRequirement(SaleLinePOS: Record "NPR POS Sale Line"): Decimal
    begin
        SaleLinePOS.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("No.", SaleLinePOS."No.");
        SaleLinePOS.SetRange("Variant Code", SaleLinePOS."Variant Code");
        SaleLinePOS.SetRange("Location Code", SaleLinePOS."Location Code");
        SaleLinePOS.SetFilter("Quantity (Base)", '>%1', 0);
        SaleLinePOS.CalcSums("Quantity (Base)");
        exit(SaleLinePOS."Quantity (Base)");
    end;

    procedure GetPosInvtProfile(POSSession: Codeunit "NPR POS Session"; var PosInventoryProfile: Record "NPR POS Inventory Profile"): Boolean
    var
        PosUnit: Record "NPR POS Unit";
        Setup: Codeunit "NPR POS Setup";
    begin
        POSSession.GetSetup(Setup);
        Setup.GetPOSUnit(PosUnit);
        exit(GetPosInvtProfile(PosUnit, PosInventoryProfile));
    end;

    local procedure GetPosInvtProfile(PosUnitNo: Code[10]; var PosInventoryProfile: Record "NPR POS Inventory Profile"): Boolean
    var
        PosUnit: Record "NPR POS Unit";
    begin
        if PosUnitNo = '' then begin
            Clear(PosInventoryProfile);
            exit;
        end;

        PosUnit.Get(PosUnitNo);
        exit(GetPosInvtProfile(PosUnit, PosInventoryProfile));
    end;

    local procedure GetPosInvtProfile(PosUnit: Record "NPR POS Unit"; var PosInventoryProfile: Record "NPR POS Inventory Profile"): Boolean
    begin
        exit(PosUnit.GetProfile(PosInventoryProfile));
    end;

    local procedure RaiseNotAvailableEvent(var PosItemAvailability: Record "NPR POS Item Availability"; var Scope: Record "NPR POS Sale Line"; PosInventoryProfile: Record "NPR POS Inventory Profile"; ShowCurrentLineQty: Boolean; AskConfirmation: Boolean) Confirmed: Boolean
    var
        PosItemAvailCheckPage: Page "NPR POS Item Avail. Check";
        HeadingTxt: Text;
        ItemNoTxt: Text;
        Handled: Boolean;
        ConfirmLbl: Label ' Are you sure you want to continue?';
        ItemWithVariantLbl: Label '%1/%2', Comment = '%1 - Item No., %2 - Variant Code', Locked = true;
        NotificationMsg_MultipleItems: Label 'The available inventory for some of the items included in the sale is lower than the entered quantity at the location.';
        NotificationMsg_SingleItem: Label 'The available inventory for item %1 is lower than the entered quantity at this location.', Comment = '%1 - Item No.';
    begin
        if PosItemAvailability.IsEmpty() then
            exit(true);
        OnItemNotAvailable(PosItemAvailability, Scope, PosInventoryProfile, AskConfirmation, Handled, Confirmed);
        if Handled then
            exit;

        if PosItemAvailability.Count = 1 then begin
            PosItemAvailability.FindFirst();
            if PosItemAvailability."Variant Code" <> '' then
                ItemNoTxt := StrSubstNo(ItemWithVariantLbl, PosItemAvailability."Item No.", PosItemAvailability."Variant Code")
            else
                ItemNoTxt := PosItemAvailability."Item No.";
            HeadingTxt := StrSubstNo(NotificationMsg_SingleItem, ItemNoTxt);
        end else
            HeadingTxt := NotificationMsg_MultipleItems;
        if AskConfirmation then
            HeadingTxt := HeadingTxt + ConfirmLbl;

        Clear(PosItemAvailCheckPage);
        PosItemAvailCheckPage.SetHeading(HeadingTxt);
        PosItemAvailCheckPage.SetAvailabilityCheckDetails(PosItemAvailability, ShowCurrentLineQty);

        Commit();
        if not AskConfirmation then begin
            PosItemAvailCheckPage.RunModal();
            Confirmed := true;
        end else begin
            PosItemAvailCheckPage.LookupMode(true);
            Confirmed := PosItemAvailCheckPage.RunModal() = Action::LookupOK;
        end;
    end;

    procedure SetIgnoreProfile(Set: Boolean)
    begin
        IgnoreProfile := Set;
    end;

    procedure GetAvailabilityIssuesFound(): Boolean
    begin
        exit(AvailabilityIssuesFound);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnItemNotAvailable(var PosItemAvailability: Record "NPR POS Item Availability"; var Scope: Record "NPR POS Sale Line"; PosInventoryProfile: Record "NPR POS Inventory Profile"; AskConfirmation: Boolean; var Handled: Boolean; var Confirmed: Boolean)
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Item-Check Avail.", 'OnBeforeShowWarningForThisItem', '', true, false)]
    local procedure DefineWithIgnoreItemAvailNotificationSetup(Item: Record Item; var ShowWarning: Boolean; var IsHandled: Boolean)
    begin
        IsHandled := true;
        ShowWarning := ShowWarningForThisItem(Item);
    end;

    local procedure ShowWarningForThisItem(Item: Record Item): Boolean
    var
        SalesSetup: Record "Sales & Receivables Setup";
    begin
        if Item.IsNonInventoriableType() then
            exit(false);

        case Item."Stockout Warning" of
            Item."Stockout Warning"::No:
                exit(false);
            Item."Stockout Warning"::Yes:
                exit(true);
            Item."Stockout Warning"::Default:
                begin
                    SalesSetup.Get();
                    if SalesSetup."Stockout Warning" then
                        exit(true);
                    exit(false);
                end;
        end;
    end;
    #endregion

    #region Scope handling
    procedure SetxDataset(POSSession: Codeunit "NPR POS Session")
    var
        SalePOS: Record "NPR POS Sale";
        POSSale: Codeunit "NPR POS Sale";
    begin
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(SalePOS);
        SetxDataset(SalePOS);
    end;

    procedure SetxDataset(SalePOS: Record "NPR POS Sale")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SetxDataset(SaleLinePOS);
    end;

    procedure SetxDataset(var SaleLinePOS: Record "NPR POS Sale Line")
    begin
        Clear(TempxSaleLinePOS);
        TempxSaleLinePOS.DeleteAll();
        if SaleLinePOS.FindSet() then
            repeat
                TempxSaleLinePOS := SaleLinePOS;
                TempxSaleLinePOS.Insert();
            until SaleLinePOS.Next() = 0;
    end;

    local procedure GetAvailabilityCheckScope(SalePOS: Record "NPR POS Sale"; var Scope: Record "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        if not (SaleLinePOS.IsEmpty() or TempxSaleLinePOS.IsEmpty()) then begin
            SaleLinePOS.FindSet();
            repeat
                TempxSaleLinePOS := SaleLinePOS;
                SaleLinePOS.Mark(not TempxSaleLinePOS.Find());
                if not SaleLinePOS.Mark() then
                    SaleLinePOS.Mark(IsEligibleForAvailabilityCheck(SaleLinePOS, TempxSaleLinePOS));
            until SaleLinePOS.Next() = 0;
            SaleLinePOS.MarkedOnly(true);
        end;

        Clear(Scope);
        Scope.Copy(SaleLinePOS);
    end;

    local procedure IsEligibleForAvailabilityCheck(SaleLinePOS: Record "NPR POS Sale Line"; xSaleLinePOS: Record "NPR POS Sale Line"): Boolean
    begin
        exit(
            (SaleLinePOS."No." <> xSaleLinePOS."No.") or
            (SaleLinePOS."Variant Code" <> xSaleLinePOS."Variant Code") or
            (SaleLinePOS."Location Code" <> xSaleLinePOS."Location Code") or
            (SaleLinePOS."Quantity (Base)" <> xSaleLinePOS."Quantity (Base)")
        );
    end;
    #endregion
    var
        TempxSaleLinePOS: Record "NPR POS Sale Line" temporary;
        AvailabilityIssuesFound: Boolean;
        IgnoreProfile: Boolean;
}