#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6151026 "NPR NPRE Menu Last Updated Sub"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu", OnBeforeModifyEvent, '', false, false)]
    local procedure MenuOnBeforeModify(var Rec: Record "NPR NPRE Menu")
    begin
        Rec."Last Updated" := CurrentDateTime;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterInsertEvent, '', false, false)]
    local procedure MenuCategoryOnAfterInsert(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterModifyEvent, '', false, false)]
    local procedure MenuCategoryOnAfterModify(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Category", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuCategoryOnAfterDelete(var Rec: Record "NPR NPRE Menu Category")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterInsertEvent, '', false, false)]
    local procedure MenuItemOnAfterInsert(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterModifyEvent, '', false, false)]
    local procedure MenuItemOnAfterModify(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuItemOnAfterDelete(var Rec: Record "NPR NPRE Menu Item")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterInsertEvent, '', false, false)]
    local procedure MenuCatTransOnAfterInsert(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterModifyEvent, '', false, false)]
    local procedure MenuCatTransOnAfterModify(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Cat. Translation", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuCatTransOnAfterDelete(var Rec: Record "NPR NPRE Menu Cat. Translation")
    begin
        UpdateMenuLastUpdated(Rec."Restaurant Code", Rec."Menu Code");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterInsertEvent, '', false, false)]
    local procedure MenuItemTransOnAfterInsert(var Rec: Record "NPR NPRE Menu Item Translation")
    begin
        UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterModifyEvent, '', false, false)]
    local procedure MenuItemTransOnAfterModify(var Rec: Record "NPR NPRE Menu Item Translation")
    begin
        UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Menu Item Translation", OnAfterDeleteEvent, '', false, false)]
    local procedure MenuItemTransOnAfterDelete(var Rec: Record "NPR NPRE Menu Item Translation")
    begin
        UpdateMenuLastUpdatedFromMenuItemTranslation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Upsell", OnAfterInsertEvent, '', false, false)]
    local procedure UpsellOnAfterInsert(var Rec: Record "NPR NPRE Upsell")
    begin
        UpdateMenuLastUpdatedFromUpsell(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Upsell", OnAfterModifyEvent, '', false, false)]
    local procedure UpsellOnAfterModify(var Rec: Record "NPR NPRE Upsell")
    begin
        UpdateMenuLastUpdatedFromUpsell(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NPRE Upsell", OnAfterDeleteEvent, '', false, false)]
    local procedure UpsellOnAfterDelete(var Rec: Record "NPR NPRE Upsell")
    begin
        UpdateMenuLastUpdatedFromUpsell(Rec);
    end;

    // GetItemPrice() returns "Unit Price", not "Discount Price Incl. Vat", so discount tables are out of scope.
    [EventSubscriber(ObjectType::Table, Database::Item, OnBeforeModifyEvent, '', false, false)]
    local procedure ItemOnBeforeModify(var Rec: Record Item)
    var
        OldItem: Record Item;
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        if Rec.IsTemporary() then
            exit;
        if MenuItem.IsEmpty() then
            exit;
        // Must stay OnBeforeModifyEvent - OldItem.Get() reads the pre-modify row from the
        // database, and on OnAfter* every comparison below would be equal.
        OldItem.SetLoadFields("Unit Price", "Price Includes VAT", "VAT Prod. Posting Group",
                              "VAT Bus. Posting Gr. (Price)", "Base Unit of Measure");
        if not OldItem.Get(Rec."No.") then
            exit;
        if not PriceInputChanged(Rec, OldItem) then
            exit;
        CollectAndFlushForItem(Rec."No.");
    end;

    // Reading an unloaded field would force a JIT load on every item modify. The checks are
    // nested rather than and-ed because AL evaluates both sides of and.
    local procedure PriceInputChanged(var Item: Record Item; var OldItem: Record Item): Boolean
    begin
        if Item.AreFieldsLoaded(Item."Unit Price") then
            if Item."Unit Price" <> OldItem."Unit Price" then
                exit(true);
        if Item.AreFieldsLoaded(Item."Price Includes VAT") then
            if Item."Price Includes VAT" <> OldItem."Price Includes VAT" then
                exit(true);
        if Item.AreFieldsLoaded(Item."VAT Prod. Posting Group") then
            if Item."VAT Prod. Posting Group" <> OldItem."VAT Prod. Posting Group" then
                exit(true);
        if Item.AreFieldsLoaded(Item."VAT Bus. Posting Gr. (Price)") then
            if Item."VAT Bus. Posting Gr. (Price)" <> OldItem."VAT Bus. Posting Gr. (Price)" then
                exit(true);
        if Item.AreFieldsLoaded(Item."Base Unit of Measure") then
            if Item."Base Unit of Measure" <> OldItem."Base Unit of Measure" then
                exit(true);
        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterInsertEvent, '', false, false)]
    local procedure PriceListLineOnAfterInsert(var Rec: Record "Price List Line")
    begin
        UpdateMenuLastUpdatedFromPriceListLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterModifyEvent, '', false, false)]
    local procedure PriceListLineOnAfterModify(var Rec: Record "Price List Line")
    begin
        UpdateMenuLastUpdatedFromPriceListLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"Price List Line", OnAfterDeleteEvent, '', false, false)]
    local procedure PriceListLineOnAfterDelete(var Rec: Record "Price List Line")
    begin
        UpdateMenuLastUpdatedFromPriceListLine(Rec);
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", OnBeforeModifyEvent, '', false, false)]
    local procedure VATPostingSetupOnBeforeModify(var Rec: Record "VAT Posting Setup")
    var
        OldVATPostingSetup: Record "VAT Posting Setup";
    begin
        if Rec.IsTemporary() then
            exit;
        OldVATPostingSetup.SetLoadFields("VAT %", "VAT Calculation Type");
        if not OldVATPostingSetup.Get(Rec."VAT Bus. Posting Group", Rec."VAT Prod. Posting Group") then
            exit;
        if (OldVATPostingSetup."VAT %" = Rec."VAT %") and
           (OldVATPostingSetup."VAT Calculation Type" = Rec."VAT Calculation Type")
        then
            exit;
        UpdateAllMenusLastUpdated();
    end;

    // A missing setup row makes the whole menu unbuildable, so adding one repairs the payload.
    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", OnAfterInsertEvent, '', false, false)]
    local procedure VATPostingSetupOnAfterInsert(var Rec: Record "VAT Posting Setup")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateAllMenusLastUpdated();
    end;

    [EventSubscriber(ObjectType::Table, Database::"VAT Posting Setup", OnAfterDeleteEvent, '', false, false)]
    local procedure VATPostingSetupOnAfterDelete(var Rec: Record "VAT Posting Setup")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateAllMenusLastUpdated();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa Item AddOn Line", OnAfterInsertEvent, '', false, false)]
    local procedure ItemAddOnLineOnAfterInsert(var Rec: Record "NPR NpIa Item AddOn Line")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateMenuLastUpdatedForAddOnNo(Rec."AddOn No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa Item AddOn Line", OnAfterModifyEvent, '', false, false)]
    local procedure ItemAddOnLineOnAfterModify(var Rec: Record "NPR NpIa Item AddOn Line")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateMenuLastUpdatedForAddOnNo(Rec."AddOn No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa Item AddOn Line", OnAfterDeleteEvent, '', false, false)]
    local procedure ItemAddOnLineOnAfterDelete(var Rec: Record "NPR NpIa Item AddOn Line")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateMenuLastUpdatedForAddOnNo(Rec."AddOn No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa ItemAddOn Line Opt.", OnAfterInsertEvent, '', false, false)]
    local procedure ItemAddOnLineOptOnAfterInsert(var Rec: Record "NPR NpIa ItemAddOn Line Opt.")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateMenuLastUpdatedForAddOnNo(Rec."AddOn No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa ItemAddOn Line Opt.", OnAfterModifyEvent, '', false, false)]
    local procedure ItemAddOnLineOptOnAfterModify(var Rec: Record "NPR NpIa ItemAddOn Line Opt.")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateMenuLastUpdatedForAddOnNo(Rec."AddOn No.");
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR NpIa ItemAddOn Line Opt.", OnAfterDeleteEvent, '', false, false)]
    local procedure ItemAddOnLineOptOnAfterDelete(var Rec: Record "NPR NpIa ItemAddOn Line Opt.")
    begin
        if Rec.IsTemporary() then
            exit;
        UpdateMenuLastUpdatedForAddOnNo(Rec."AddOn No.");
    end;

    local procedure UpdateMenuLastUpdatedFromPriceListLine(PriceListLine: Record "Price List Line")
    begin
        if PriceListLine.IsTemporary() then
            exit;
        if PriceListLine."Asset Type" <> PriceListLine."Asset Type"::Item then
            exit;
        if PriceListLine."Price Type" <> PriceListLine."Price Type"::Sale then
            exit;
        // Amount Type::Any carries a price as well, so only Discount is excluded.
        if PriceListLine."Amount Type" = PriceListLine."Amount Type"::Discount then
            exit;
        CollectAndFlushForItem(PriceListLine."Asset No.");
    end;

    local procedure UpdateMenuLastUpdatedForAddOnNo(AddOnNo: Code[20])
    var
        TempMenuBuffer: Record "NPR NPRE Menu" temporary;
    begin
        CollectForAddOnNo(AddOnNo, TempMenuBuffer);
        FlushMenuBuffer(TempMenuBuffer);
    end;

    local procedure CollectAndFlushForItem(ItemNo: Code[20])
    var
        MenuItem: Record "NPR NPRE Menu Item";
        TempMenuBuffer: Record "NPR NPRE Menu" temporary;
    begin
        if MenuItem.IsEmpty() then
            exit;
        CollectForItem(ItemNo, TempMenuBuffer);
        FlushMenuBuffer(TempMenuBuffer);
    end;

    local procedure CollectForAddOnNo(AddOnNo: Code[20]; var TempMenuBuffer: Record "NPR NPRE Menu" temporary)
    var
        Item: Record Item;
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        if AddOnNo = '' then
            exit;
        if MenuItem.IsEmpty() then
            exit;
        // Resolves to menu rows directly - CollectForItem would loop on add-ons referencing one another.
        Item.SetLoadFields("No.");
        Item.SetCurrentKey("NPR Item AddOn No.");
        Item.SetRange("NPR Item AddOn No.", AddOnNo);
        if Item.FindSet() then
            repeat
                CollectForMenuItem(Item."No.", TempMenuBuffer);
            until Item.Next() = 0;
    end;

    local procedure CollectForMenuItem(ItemNo: Code[20]; var TempMenuBuffer: Record "NPR NPRE Menu" temporary)
    var
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        MenuItem.SetLoadFields("Restaurant Code", "Menu Code");
        MenuItem.SetCurrentKey("Item No.");
        MenuItem.SetRange("Item No.", ItemNo);
        if MenuItem.FindSet() then
            repeat
                BufferMenu(MenuItem."Restaurant Code", MenuItem."Menu Code", TempMenuBuffer);
            until MenuItem.Next() = 0;
    end;

    local procedure BufferMenu(RestaurantCode: Code[20]; MenuCode: Code[20]; var TempMenuBuffer: Record "NPR NPRE Menu" temporary)
    begin
        if (RestaurantCode = '') or (MenuCode = '') then
            exit;
        TempMenuBuffer.Init();
        TempMenuBuffer."Restaurant Code" := RestaurantCode;
        TempMenuBuffer.Code := MenuCode;
        if TempMenuBuffer.Insert() then;
    end;

    local procedure FlushMenuBuffer(var TempMenuBuffer: Record "NPR NPRE Menu" temporary)
    begin
        if not TempMenuBuffer.FindSet() then
            exit;
        repeat
            UpdateMenuLastUpdated(TempMenuBuffer."Restaurant Code", TempMenuBuffer.Code);
        until TempMenuBuffer.Next() = 0;
    end;

    local procedure CollectForItem(ItemNo: Code[20]; var TempMenuBuffer: Record "NPR NPRE Menu" temporary)
    var
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOpt: Record "NPR NpIa ItemAddOn Line Opt.";
        AddOnNos: List of [Code[20]];
        AddOnNo: Code[20];
    begin
        if ItemNo = '' then
            exit;
        CollectForMenuItem(ItemNo, TempMenuBuffer);

        // The API falls back to the referenced item's price when the add-on line carries none.
        // Each resolution scans Item, so the add-on numbers are collected distinctly first.
        ItemAddOnLine.SetLoadFields("AddOn No.");
        ItemAddOnLine.SetCurrentKey("Item No.");
        ItemAddOnLine.SetRange("Item No.", ItemNo);
        if ItemAddOnLine.FindSet() then
            repeat
                if not AddOnNos.Contains(ItemAddOnLine."AddOn No.") then
                    AddOnNos.Add(ItemAddOnLine."AddOn No.");
            until ItemAddOnLine.Next() = 0;

        ItemAddOnLineOpt.SetLoadFields("AddOn No.");
        ItemAddOnLineOpt.SetCurrentKey("Item No.");
        ItemAddOnLineOpt.SetRange("Item No.", ItemNo);
        if ItemAddOnLineOpt.FindSet() then
            repeat
                if not AddOnNos.Contains(ItemAddOnLineOpt."AddOn No.") then
                    AddOnNos.Add(ItemAddOnLineOpt."AddOn No.");
            until ItemAddOnLineOpt.Next() = 0;

        foreach AddOnNo in AddOnNos do
            CollectForAddOnNo(AddOnNo, TempMenuBuffer);
    end;

    local procedure UpdateAllMenusLastUpdated()
    var
        Menu: Record "NPR NPRE Menu";
    begin
        Menu.ReadIsolation := IsolationLevel::UpdLock;
        if Menu.FindSet(true) then
            repeat
                Menu.Modify();
            until Menu.Next() = 0;
    end;

    local procedure UpdateMenuLastUpdated(RestaurantCode: Code[20]; MenuCode: Code[20])
    var
        Menu: Record "NPR NPRE Menu";
    begin
        if (RestaurantCode = '') or (MenuCode = '') then
            exit;
        Menu.ReadIsolation := IsolationLevel::UpdLock;
        if not Menu.Get(RestaurantCode, MenuCode) then
            exit;
        // MenuOnBeforeModify stamps "Last Updated" on every modify of this table.
        Menu.Modify();
    end;

    local procedure UpdateMenuLastUpdatedFromMenuItemTranslation(MenuItemTranslation: Record "NPR NPRE Menu Item Translation")
    var
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        if not MenuItem.GetBySystemId(MenuItemTranslation."External System Id") then
            exit;
        UpdateMenuLastUpdated(MenuItem."Restaurant Code", MenuItem."Menu Code");
    end;

    local procedure UpdateMenuLastUpdatedFromUpsell(Upsell: Record "NPR NPRE Upsell")
    var
        MenuItem: Record "NPR NPRE Menu Item";
        Menu: Record "NPR NPRE Menu";
    begin
        case Upsell."External Table" of
            Upsell."External Table"::MenuItem:
                begin
                    if not MenuItem.GetBySystemId(Upsell."External System Id") then
                        exit;
                    UpdateMenuLastUpdated(MenuItem."Restaurant Code", MenuItem."Menu Code");
                end;
            Upsell."External Table"::Menu:
                begin
                    if not Menu.GetBySystemId(Upsell."External System Id") then
                        exit;
                    UpdateMenuLastUpdated(Menu."Restaurant Code", Menu.Code);
                end;
        end;
    end;
}
#endif
