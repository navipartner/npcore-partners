#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248644 "NPR API Restaurant Menu"
{
    Access = Internal;

    procedure GetMenus(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Menu: Record "NPR NPRE Menu";
        JsonArray: Codeunit "NPR JSON Builder";
        RestaurantId: Guid;
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if not Evaluate(RestaurantId, Request.Paths().Get(2)) then
            exit(Response.RespondBadRequest('Invalid restaurantId format'));

        Restaurant.ReadIsolation := IsolationLevel::ReadCommitted;
        if not Restaurant.GetBySystemId(RestaurantId) then
            exit(Response.RespondResourceNotFound());

        Menu.ReadIsolation := IsolationLevel::ReadCommitted;
        Menu.SetRange("Restaurant Code", Restaurant.Code);
        Menu.SetRange(Active, true);

        JsonArray.StartArray();
        if Menu.FindSet() then
            repeat
                JsonArray.StartObject('')
                    .AddProperty('id', Format(Menu.SystemId, 0, 4).ToLower())
                    .AddProperty('code', Menu.Code)
                    .AddProperty('startTime', Menu."Start Time")
                    .AddProperty('endTime', Menu."End Time")
                    .AddProperty('timezone', Menu.Timezone)
                    .AddProperty('active', Menu.Active);
                if Menu."Last Updated" <> 0DT then
                    JsonArray.AddProperty('lastUpdated', Menu."Last Updated");
                JsonArray.EndObject();
            until Menu.Next() = 0;
        JsonArray.EndArray();

        exit(Response.RespondOK(JsonArray.BuildAsArray()));
    end;

    procedure GetMenu(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        Restaurant: Record "NPR NPRE Restaurant";
        Menu: Record "NPR NPRE Menu";
        VATBusPostingGroupRec: Record "VAT Business Posting Group";
        Json: Codeunit "NPR JSON Builder";
        RestaurantId: Guid;
        MenuId: Guid;
        PosUnitCode: Code[10];
        VATBusPostingGroup: Code[20];
    begin
        Request.SkipCacheIfNonStickyRequest(GetTableIds());

        if not Evaluate(RestaurantId, Request.Paths().Get(2)) then
            exit(Response.RespondBadRequest('Invalid restaurantId format'));

        if not Evaluate(MenuId, Request.Paths().Get(4)) then
            exit(Response.RespondBadRequest('Invalid menuId format'));

        if not Restaurant.GetBySystemId(RestaurantId) then
            exit(Response.RespondResourceNotFound());

        if not Menu.GetBySystemId(MenuId) then
            exit(Response.RespondResourceNotFound());

        if Menu."Restaurant Code" <> Restaurant.Code then
            exit(Response.RespondResourceNotFound());

        if not Menu.Active then
            exit(Response.RespondResourceNotFound());

        PosUnitCode := GetPosUnitFromUser();
        if PosUnitCode = '' then
            exit(Response.RespondBadRequest('User has no POS Unit configured'));

        if Request.QueryParams().ContainsKey('vatBusinessPostingGroup') then
#pragma warning disable AA0139 // Intentional: let the Text→Code[20] assignment blow up on >20-char input rather than silently truncating
            VATBusPostingGroup := Request.QueryParams().Get('vatBusinessPostingGroup');
#pragma warning restore AA0139
        if VATBusPostingGroup <> '' then
            if not VATBusPostingGroupRec.Get(VATBusPostingGroup) then
                exit(Response.RespondBadRequest(StrSubstNo('Unknown VAT Business Posting Group ''%1''.', VATBusPostingGroup)));

        Json.StartObject('')
            .AddProperty('id', Format(Menu.SystemId, 0, 4).ToLower())
            .AddProperty('code', Menu.Code)
            .AddProperty('startTime', Menu."Start Time")
            .AddProperty('endTime', Menu."End Time")
            .AddProperty('timezone', Menu.Timezone)
            .AddProperty('active', Menu.Active);
        if Menu."Last Updated" <> 0DT then
            Json.AddProperty('lastUpdated', Menu."Last Updated");

        if not TryBuildMenuContent(Restaurant, Menu, PosUnitCode, VATBusPostingGroup, Json) then
            exit(Response.RespondBadRequest(GetLastErrorText()));

        Json.EndObject();

        exit(Response.RespondOK(Json.Build()));
    end;

    [TryFunction]
    local procedure TryBuildMenuContent(Restaurant: Record "NPR NPRE Restaurant"; Menu: Record "NPR NPRE Menu"; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    begin
        BuildMenuContent(Restaurant, Menu, PosUnitCode, VATBusPostingGroup, Json);
    end;

    local procedure BuildMenuContent(Restaurant: Record "NPR NPRE Restaurant"; Menu: Record "NPR NPRE Menu"; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        MenuCategory: Record "NPR NPRE Menu Category";
    begin
        Json.StartObject('menuContent');

        Json.StartArray('categories');
        MenuCategory.ReadIsolation := IsolationLevel::ReadCommitted;
        MenuCategory.SetRange("Restaurant Code", Restaurant.Code);
        MenuCategory.SetRange("Menu Code", Menu.Code);
        MenuCategory.SetCurrentKey("Sort Key");
        MenuCategory.SetAscending("Sort Key", true);

        if MenuCategory.FindSet() then
            repeat
                BuildCategory(Restaurant, Menu, MenuCategory, PosUnitCode, VATBusPostingGroup, Json);
            until MenuCategory.Next() = 0;
        Json.EndArray();

        Json.StartArray('checkoutUpsellItems');
        BuildCheckoutUpsells(Menu, PosUnitCode, VATBusPostingGroup, Json);
        Json.EndArray();

        Json.StartObject('addonCategories');
        BuildAddonCategories(Json);
        Json.EndObject();

        Json.EndObject();
    end;

    local procedure BuildCategory(Restaurant: Record "NPR NPRE Restaurant"; Menu: Record "NPR NPRE Menu"; MenuCategory: Record "NPR NPRE Menu Category"; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        MenuItem: Record "NPR NPRE Menu Item";
        MenuCatTrans: Record "NPR NPRE Menu Cat. Translation";
    begin
        Json.StartObject('');

        Json.AddProperty('code', MenuCategory."Category Code");
        Json.AddProperty('sortKey', MenuCategory."Sort Key");

        Json.StartObject('title');
        MenuCatTrans.ReadIsolation := IsolationLevel::ReadCommitted;
        MenuCatTrans.SetRange("Restaurant Code", MenuCategory."Restaurant Code");
        MenuCatTrans.SetRange("Menu Code", MenuCategory."Menu Code");
        MenuCatTrans.SetRange("Category Code", MenuCategory."Category Code");
        if MenuCatTrans.FindSet() then
            repeat
                Json.AddProperty(MenuCatTrans."Language Code", MenuCatTrans.Title);
            until MenuCatTrans.Next() = 0;
        Json.EndObject();

        Json.StartObject('description');
        MenuCatTrans.SetRange("Restaurant Code", MenuCategory."Restaurant Code");
        MenuCatTrans.SetRange("Menu Code", MenuCategory."Menu Code");
        MenuCatTrans.SetRange("Category Code", MenuCategory."Category Code");
        if MenuCatTrans.FindSet() then
            repeat
                Json.AddProperty(MenuCatTrans."Language Code", MenuCatTrans.Description);
            until MenuCatTrans.Next() = 0;
        Json.EndObject();

        Json.StartArray('items');
        MenuItem.ReadIsolation := IsolationLevel::ReadCommitted;
        MenuItem.SetRange("Restaurant Code", Restaurant.Code);
        MenuItem.SetRange("Menu Code", Menu.Code);
        MenuItem.SetRange("Category Code", MenuCategory."Category Code");
        MenuItem.SetFilter(Status, '<>%1', MenuItem.Status::"Inactive Hidden");
        MenuItem.SetCurrentKey("Sort Key");
        MenuItem.SetAscending("Sort Key", true);

        if MenuItem.FindSet() then
            repeat
                BuildMenuItem(MenuItem, PosUnitCode, VATBusPostingGroup, Json);
            until MenuItem.Next() = 0;
        Json.EndArray();

        Json.EndObject();
    end;

    local procedure BuildMenuItem(MenuItem: Record "NPR NPRE Menu Item"; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        Item: Record Item;
        MenuItemTrans: Record "NPR NPRE Menu Item Translation";
        PictureHandler: Codeunit "NPR NPREMenuItemPictureHandler";
        UnitPrice: Decimal;
        ImageUrl: Text;
        HasUpsells: Boolean;
    begin
        Json.StartObject('');

        Json.AddProperty('itemCode', MenuItem."Item No.")
            .AddProperty('variantCode', MenuItem."Variant Code")
            .AddProperty('sortKey', MenuItem."Sort Key")
            .AddProperty('status', MenuItem.Status.Names.Get(MenuItem.Status.Ordinals.IndexOf(MenuItem.Status.AsInteger())));

        UnitPrice := GetItemPrice(MenuItem."Item No.", MenuItem."Variant Code", PosUnitCode, VATBusPostingGroup);
        Json.AddProperty('unitPrice', UnitPrice);

        Json.StartObject('title');
        MenuItemTrans.ReadIsolation := IsolationLevel::ReadCommitted;
        MenuItemTrans.SetRange("External System Id", MenuItem.SystemId);
        if MenuItemTrans.FindSet() then
            repeat
                Json.AddProperty(MenuItemTrans."Language Code", MenuItemTrans.Title);
            until MenuItemTrans.Next() = 0;
        Json.EndObject();

        Json.StartObject('descriptionMarkdown');
        MenuItemTrans.Reset();
        MenuItemTrans.SetRange("External System Id", MenuItem.SystemId);
        if MenuItemTrans.FindSet() then
            repeat
                Json.AddProperty(MenuItemTrans."Language Code", MenuItemTrans.GetItemDescription());
            until MenuItemTrans.Next() = 0;
        Json.EndObject();

        Json.StartObject('nutritionMarkdown');
        MenuItemTrans.Reset();
        MenuItemTrans.SetRange("External System Id", MenuItem.SystemId);
        if MenuItemTrans.FindSet() then
            repeat
                Json.AddProperty(MenuItemTrans."Language Code", MenuItemTrans.GetNutritionalInfo());
            until MenuItemTrans.Next() = 0;
        Json.EndObject();

        if PictureHandler.GetPictureUrl(MenuItem.SystemId, Enum::"NPR CloudflareMediaVariants"::MEDIUM, 57600, ImageUrl) then
            Json.AddProperty('imageUrl', ImageUrl);

        if Item.Get(MenuItem."Item No.") and (Item."NPR Item AddOn No." <> '') then begin
            Json.StartArray('addonItems');
            BuildItemAddons(Item."NPR Item AddOn No.", PosUnitCode, VATBusPostingGroup, Json);
            Json.EndArray();
        end;

        HasUpsells := CheckIfHasUpsells(MenuItem.SystemId);
        if HasUpsells then begin
            Json.StartArray('upsellItems');
            BuildItemUpsells(MenuItem.SystemId, PosUnitCode, VATBusPostingGroup, Json);
            Json.EndArray();
        end;

        Json.EndObject();
    end;

    local procedure CheckIfHasUpsells(MenuItemSystemId: Guid): Boolean
    var
        Upsell: Record "NPR NPRE Upsell";
    begin
        Upsell.ReadIsolation := IsolationLevel::ReadCommitted;
        Upsell.SetRange("External Table", Upsell."External Table"::MenuItem);
        Upsell.SetRange("External System Id", MenuItemSystemId);
        exit(not Upsell.IsEmpty());
    end;

    local procedure BuildItemAddons(ItemAddOnNo: Code[20]; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        ItemAddOn: Record "NPR NpIa Item AddOn";
        ItemAddOnLine: Record "NPR NpIa Item AddOn Line";
        ItemAddOnLineOpt: Record "NPR NpIa ItemAddOn Line Opt.";
    begin
        if not ItemAddOn.Get(ItemAddOnNo) then
            exit;

        ItemAddOnLine.ReadIsolation := IsolationLevel::ReadCommitted;
        ItemAddOnLine.SetRange("AddOn No.", ItemAddOnNo);
        ItemAddOnLine.SetFilter(IncludeFromDate, '<=%1', Today());
        ItemAddOnLine.SetFilter(IncludeUntilDate, '=%1|>=%2', 0D, Today());
        ItemAddOnLine.SetCurrentKey("Sort Key");
        ItemAddOnLine.SetAscending("Sort Key", true);

        if ItemAddOnLine.FindSet() then
            repeat
                Json.StartObject('');
                Json.AddProperty('category', ItemAddOnLine."Category Code")
                    .AddProperty('sortKey', ItemAddOnLine."Sort Key")
                    .AddProperty('type', Format(ItemAddOnLine.Type))
                    .AddProperty('mandatory', ItemAddOnLine.Mandatory);

                if ItemAddOnLine.Type = ItemAddOnLine.Type::Quantity then begin
                    BuildAddonItemFromLine(ItemAddOnLine, PosUnitCode, VATBusPostingGroup, Json);
                end else begin
                    Json.StartArray('selectOptions');
                    ItemAddOnLineOpt.ReadIsolation := IsolationLevel::ReadCommitted;
                    ItemAddOnLineOpt.SetRange("AddOn No.", ItemAddOnLine."AddOn No.");
                    ItemAddOnLineOpt.SetRange("AddOn Line No.", ItemAddOnLine."Line No.");
                    ItemAddOnLineOpt.SetCurrentKey("Line No.");
                    ItemAddOnLineOpt.SetAscending("Line No.", true);

                    if ItemAddOnLineOpt.FindSet() then
                        repeat
                            Json.StartObject('');
                            Json.AddProperty('sortKey', ItemAddOnLineOpt."Line No.");
                            BuildAddonItemFromOption(ItemAddOnLineOpt, PosUnitCode, VATBusPostingGroup, Json);
                            Json.EndObject();
                        until ItemAddOnLineOpt.Next() = 0;
                    Json.EndArray();
                end;

                Json.EndObject();
            until ItemAddOnLine.Next() = 0;
    end;

    local procedure BuildAddonItemFromLine(var ItemAddOnLine: Record "NPR NpIa Item AddOn Line"; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        CalculatedPrice: Decimal;
        ItemAddonTranslation: Record "NPR Item Addon Translation";
    begin
        Json.AddProperty('addonNo', ItemAddOnLine."AddOn No.")
            .AddProperty('addonLineNo', ItemAddOnLine."Line No.")
            .AddProperty('fixedQuantity', ItemAddOnLine."Fixed Quantity")
            .AddProperty('quantityPerUnit', ItemAddOnLine."Per Unit")
            .AddProperty('quantity', ItemAddOnLine.Quantity)
            .AddProperty('itemCode', ItemAddOnLine."Item No.")
            .AddProperty('variantCode', ItemAddOnLine."Variant Code");

        if ItemAddOnLine."Use Unit Price" = ItemAddOnLine."Use Unit Price"::Always then
            CalculatedPrice := ItemAddOnLine."Unit Price"
        else if (ItemAddOnLine."Use Unit Price" = ItemAddOnLine."Use Unit Price"::"Non-Zero") and (ItemAddOnLine."Unit Price" <> 0) then
            CalculatedPrice := ItemAddOnLine."Unit Price"
        else
            CalculatedPrice := GetItemPrice(ItemAddOnLine."Item No.", ItemAddOnLine."Variant Code", PosUnitCode, VATBusPostingGroup);

        Json.AddProperty('unitPrice', CalculatedPrice);

        Json.StartObject('description');
        ItemAddonTranslation.SetRange("External Table SystemId", ItemAddOnLine.SystemId);
        if ItemAddonTranslation.FindSet() then
            repeat
                Json.AddProperty(ItemAddonTranslation."Language Code", ItemAddonTranslation.Description);
            until ItemAddonTranslation.Next() = 0;
        Json.EndObject();
    end;

    local procedure BuildAddonItemFromOption(var ItemAddOnLineOpt: Record "NPR NpIa ItemAddOn Line Opt."; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        CalculatedPrice: Decimal;
        ItemAddonTranslation: Record "NPR Item Addon Translation";
    begin
        Json.AddProperty('addonNo', ItemAddOnLineOpt."AddOn No.")
            .AddProperty('addonLineNo', ItemAddOnLineOpt."AddOn Line No.")
            .AddProperty('fixedQuantity', ItemAddOnLineOpt."Fixed Quantity")
            .AddProperty('quantityPerUnit', ItemAddOnLineOpt."Per Unit")
            .AddProperty('quantity', ItemAddOnLineOpt.Quantity)
            .AddProperty('itemCode', ItemAddOnLineOpt."Item No.")
            .AddProperty('variantCode', ItemAddOnLineOpt."Variant Code");

        // Calculate price based on "Use Unit Price" setting
        if ItemAddOnLineOpt."Use Unit Price" = ItemAddOnLineOpt."Use Unit Price"::Always then
            CalculatedPrice := ItemAddOnLineOpt."Unit Price"
        else if (ItemAddOnLineOpt."Use Unit Price" = ItemAddOnLineOpt."Use Unit Price"::"Non-Zero") and (ItemAddOnLineOpt."Unit Price" <> 0) then
            CalculatedPrice := ItemAddOnLineOpt."Unit Price"
        else
            CalculatedPrice := GetItemPrice(ItemAddOnLineOpt."Item No.", ItemAddOnLineOpt."Variant Code", PosUnitCode, VATBusPostingGroup);

        Json.AddProperty('unitPrice', CalculatedPrice);

        Json.StartObject('description');
        ItemAddonTranslation.SetRange("External Table SystemId", ItemAddOnLineOpt.SystemId);
        if ItemAddonTranslation.FindSet() then
            repeat
                Json.AddProperty(ItemAddonTranslation."Language Code", ItemAddonTranslation.Description);
            until ItemAddonTranslation.Next() = 0;
        Json.EndObject();
    end;

    local procedure BuildItemUpsells(MenuItemSystemId: Guid; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        Upsell: Record "NPR NPRE Upsell";
        UpsellMenuItem: Record "NPR NPRE Menu Item";
    begin
        Upsell.ReadIsolation := IsolationLevel::ReadCommitted;
        Upsell.SetRange("External Table", Upsell."External Table"::MenuItem);
        Upsell.SetRange("External System Id", MenuItemSystemId);
        Upsell.SetCurrentKey("Sort Key");
        Upsell.SetAscending("Sort Key", true);

        if Upsell.FindSet() then
            repeat
                if UpsellMenuItem.GetBySystemId(Upsell."Menu Item System Id") then
                    BuildUpsellItem(UpsellMenuItem, Upsell."Sort Key", PosUnitCode, VATBusPostingGroup, Json);
            until Upsell.Next() = 0;
    end;

    local procedure BuildCheckoutUpsells(Menu: Record "NPR NPRE Menu"; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        Upsell: Record "NPR NPRE Upsell";
        UpsellMenuItem: Record "NPR NPRE Menu Item";
    begin
        Upsell.ReadIsolation := IsolationLevel::ReadCommitted;
        Upsell.SetRange("External Table", Upsell."External Table"::Menu);
        Upsell.SetRange("External System Id", Menu.SystemId);
        Upsell.SetCurrentKey("Sort Key");
        Upsell.SetAscending("Sort Key", true);

        if Upsell.FindSet() then
            repeat
                if UpsellMenuItem.GetBySystemId(Upsell."Menu Item System Id") then
                    BuildUpsellItem(UpsellMenuItem, Upsell."Sort Key", PosUnitCode, VATBusPostingGroup, Json);
            until Upsell.Next() = 0;
    end;

    local procedure BuildUpsellItem(MenuItem: Record "NPR NPRE Menu Item"; SortKey: Integer; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]; var Json: Codeunit "NPR JSON Builder")
    var
        MenuItemTrans: Record "NPR NPRE Menu Item Translation";
        PictureHandler: Codeunit "NPR NPREMenuItemPictureHandler";
        UnitPrice: Decimal;
        ImageUrl: Text;
    begin
        Json.StartObject('');

        Json.AddProperty('itemCode', MenuItem."Item No.")
            .AddProperty('variantCode', MenuItem."Variant Code")
            .AddProperty('sortKey', SortKey);

        // Get unit price
        UnitPrice := GetItemPrice(MenuItem."Item No.", MenuItem."Variant Code", PosUnitCode, VATBusPostingGroup);
        Json.AddProperty('unitPrice', UnitPrice);

        // Build title translations
        Json.StartObject('title');
        MenuItemTrans.ReadIsolation := IsolationLevel::ReadCommitted;
        MenuItemTrans.SetRange("External System Id", MenuItem.SystemId);
        if MenuItemTrans.FindSet() then
            repeat
                Json.AddProperty(MenuItemTrans."Language Code", MenuItemTrans.Title);
            until MenuItemTrans.Next() = 0;
        Json.EndObject();

        // Build description markdown translations
        Json.StartObject('descriptionMarkdown');
        MenuItemTrans.Reset();
        MenuItemTrans.SetRange("External System Id", MenuItem.SystemId);
        if MenuItemTrans.FindSet() then
            repeat
                Json.AddProperty(MenuItemTrans."Language Code", MenuItemTrans.GetItemDescription());
            until MenuItemTrans.Next() = 0;
        Json.EndObject();

        // Build nutrition markdown translations
        Json.StartObject('nutritionMarkdown');
        MenuItemTrans.Reset();
        MenuItemTrans.SetRange("External System Id", MenuItem.SystemId);
        if MenuItemTrans.FindSet() then
            repeat
                Json.AddProperty(MenuItemTrans."Language Code", MenuItemTrans.GetNutritionalInfo());
            until MenuItemTrans.Next() = 0;
        Json.EndObject();

        // Get image URL if available (16 hour TTL = 57600 seconds)
        if PictureHandler.GetPictureUrl(MenuItem.SystemId, Enum::"NPR CloudflareMediaVariants"::MEDIUM, 57600, ImageUrl) then
            Json.AddProperty('imageUrl', ImageUrl);

        Json.EndObject();
    end;

    local procedure BuildAddonCategories(var Json: Codeunit "NPR JSON Builder")
    var
        ItemAddOnCategory: Record "NPR NpIa Item AddOn Category";
        ItemAddOnCatTrans: Record "NPR NpIa ItemAddOn Cat. Trans.";
    begin
        ItemAddOnCategory.ReadIsolation := IsolationLevel::ReadCommitted;
        ItemAddOnCategory.SetCurrentKey("Sort Key");
        ItemAddOnCategory.SetAscending("Sort Key", true);

        if ItemAddOnCategory.FindSet() then
            repeat
                Json.StartObject(ItemAddOnCategory.Code);
                Json.AddProperty('sortKey', ItemAddOnCategory."Sort Key");

                // Build title translations
                Json.StartObject('title');
                ItemAddOnCatTrans.ReadIsolation := IsolationLevel::ReadCommitted;
                ItemAddOnCatTrans.SetRange("Category Code", ItemAddOnCategory.Code);
                if ItemAddOnCatTrans.FindSet() then
                    repeat
                        Json.AddProperty(ItemAddOnCatTrans."Language Code", ItemAddOnCatTrans.Title);
                    until ItemAddOnCatTrans.Next() = 0;
                Json.EndObject();

                // Build description translations
                Json.StartObject('description');
                ItemAddOnCatTrans.Reset();
                ItemAddOnCatTrans.SetRange("Category Code", ItemAddOnCategory.Code);
                if ItemAddOnCatTrans.FindSet() then
                    repeat
                        Json.AddProperty(ItemAddOnCatTrans."Language Code", ItemAddOnCatTrans.Description);
                    until ItemAddOnCatTrans.Next() = 0;
                Json.EndObject();

                Json.EndObject();
            until ItemAddOnCategory.Next() = 0;
    end;

    local procedure GetItemPrice(ItemNo: Code[20]; VariantCode: Code[10]; PosUnitCode: Code[10]; VATBusPostingGroup: Code[20]): Decimal
    var
        TempRetailJournalLine: Record "NPR Retail Journal Line" temporary;
    begin
        TempRetailJournalLine.Init();
        TempRetailJournalLine."VAT Bus. Posting Group" := VATBusPostingGroup;
        TempRetailJournalLine.Validate("Register No.", PosUnitCode);
        TempRetailJournalLine.Validate("Item No.", ItemNo);
        TempRetailJournalLine.Validate("Variant Code", VariantCode);
        TempRetailJournalLine.Validate("Quantity for Discount Calc", 1);
        TempRetailJournalLine.Insert();
        exit(TempRetailJournalLine."Unit Price");
    end;

    local procedure GetPosUnitFromUser(): Code[10]
    var
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId()) then
            exit('');

        exit(UserSetup."NPR POS Unit No.");
    end;


    local procedure GetTableIds() TableIds: List of [Integer]
    begin
        TableIds.Add(Database::"NPR NPRE Restaurant");
        TableIds.Add(Database::"NPR NPRE Menu");
        TableIds.Add(Database::"NPR NPRE Menu Category");
        TableIds.Add(Database::"NPR NPRE Menu Cat. Translation");
        TableIds.Add(Database::"NPR NPRE Menu Item");
        TableIds.Add(Database::"NPR NPRE Menu Item Translation");
        TableIds.Add(Database::"NPR NPRE Upsell");
        TableIds.Add(Database::"NPR NpIa Item AddOn");
        TableIds.Add(Database::"NPR NpIa Item AddOn Line");
        TableIds.Add(Database::"NPR NpIa ItemAddOn Line Opt.");
        TableIds.Add(Database::"NPR NpIa Item AddOn Category");
        TableIds.Add(Database::"NPR NpIa ItemAddOn Cat. Trans.");
    end;
}
#endif
