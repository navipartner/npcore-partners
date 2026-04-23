#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85188 "NPR APIRestMenu Rounding"
{
    // [FEATURE] Restaurant Menu API — per-unit price rounding uses GL Setup "Unit-Amount Rounding Precision"

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;
        _Restaurant: Record "NPR NPRE Restaurant";
        _Menu: Record "NPR NPRE Menu";
        _MenuCategory: Record "NPR NPRE Menu Category";

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RoundsMenuPriceToGLSetupUnitAmountPrecision_WholeUnit()
    var
        GLSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        UnitPrice: Decimal;
    begin
        // [SCENARIO] When GLSetup "Unit-Amount Rounding Precision" = 1.0, menu item price is rounded to whole units.
        Initialize();

        GLSetup.Get();
        GLSetup."Unit-Amount Rounding Precision" := 1.0;
        GLSetup.Modify();

        SetItemUnitPriceAndAddToMenu(89.37);

        UnitPrice := GetFirstMenuItemUnitPrice();

        Assert.AreEqual(89, UnitPrice, 'GLSetup Unit-Amount Rounding Precision 1.0 should round 89.37 to 89');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure RoundsMenuPriceToGLSetupUnitAmountPrecision_FiveCent()
    var
        GLSetup: Record "General Ledger Setup";
        Assert: Codeunit Assert;
        UnitPrice: Decimal;
    begin
        // [SCENARIO] When GLSetup "Unit-Amount Rounding Precision" = 0.05, the output price is a multiple of 0.05.
        // Item.Unit Price is VAT-inclusive per LibraryPOSMasterData default. BC internally stores excl-VAT,
        // so 89.37 incl at 25% VAT is stored as 71.496 excl, rounded to 0.05 = 71.50, re-applied VAT = 89.375,
        // rounded to 0.05 (nearest, half-up) = 89.40.
        Initialize();

        GLSetup.Get();
        GLSetup."Unit-Amount Rounding Precision" := 0.05;
        GLSetup.Modify();

        SetItemUnitPriceAndAddToMenu(89.37);

        UnitPrice := GetFirstMenuItemUnitPrice();

        Assert.AreEqual(89.40, UnitPrice, 'GLSetup Unit-Amount Rounding Precision 0.05 should yield a multiple of 0.05');
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        UserSetup: Record "User Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

        LibraryPOSMasterData.CreatePOSSetup(POSSetup);
        LibraryPOSMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        LibraryPOSMasterData.CreatePOSStore(_POSStore, POSPostingProfile.Code);
        LibraryPOSMasterData.CreatePOSUnit(_POSUnit, _POSStore.Code, POSPostingProfile.Code);
        _POSUnit."POS Type" := _POSUnit."POS Type"::UNATTENDED;
        _POSUnit.Modify();

        if not UserSetup.Get(UserId) then begin
            UserSetup.Init();
            UserSetup."User ID" := CopyStr(UserId, 1, MaxStrLen(UserSetup."User ID"));
            UserSetup.Insert();
        end;
        UserSetup."NPR POS Unit No." := _POSUnit."No.";
        UserSetup.Modify();

        LibraryPOSMasterData.CreateItemForPOSSaleUsage(_Item, _POSUnit, _POSStore);

        LibraryRestaurant.CreateRestaurantSetup(RestaurantSetup);
        LibraryRestaurant.CreateServiceFlowProfile(ServFlowProfile);
        LibraryRestaurant.CreateRestaurant(_Restaurant, ServFlowProfile.Code);
        LibraryRestaurant.CreatePOSRestaurantProfile(POSRestProfile, _Restaurant.Code);

        LibraryRestaurant.CreateItemRoutingProfile(ItemRoutingProfile);
        LibraryRestaurant.LinkItemToRoutingProfile(_Item, ItemRoutingProfile.Code);

        LibraryRestaurant.CreateMenu(_Menu, _Restaurant.Code);
        LibraryRestaurant.CreateMenuCategory(_MenuCategory, _Restaurant.Code, _Menu.Code, 'TEST');

        _Initialized := true;
        Commit();
    end;

    local procedure SetItemUnitPriceAndAddToMenu(UnitPrice: Decimal)
    var
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        MenuItem: Record "NPR NPRE Menu Item";
    begin
        _Item.Find();
        _Item."Unit Price" := UnitPrice;
        _Item.Modify();

        MenuItem.SetRange("Restaurant Code", _Restaurant.Code);
        MenuItem.SetRange("Menu Code", _Menu.Code);
        MenuItem.DeleteAll();

        LibraryRestaurant.CreateMenuItem(MenuItem, _Restaurant.Code, _Menu.Code, _MenuCategory."Category Code", _Item."No.");
        Commit();
    end;

    local procedure GetFirstMenuItemUnitPrice() UnitPrice: Decimal
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        ResponseBody: JsonObject;
        JToken: JsonToken;
        Categories: JsonArray;
        Items: JsonArray;
        CategoryObj: JsonObject;
        ItemObj: JsonObject;
        Path: Text;
    begin
        Path := '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/menu/' + FormatGuid(_Menu.SystemId);
        Response := LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        Assert.IsTrue(ResponseBody.Get('menuContent', JToken), 'Response should contain menuContent');
        Assert.IsTrue(JToken.AsObject().Get('categories', JToken), 'menuContent should contain categories');
        Categories := JToken.AsArray();
        Assert.AreEqual(1, Categories.Count(), 'Expected exactly one category');

        Categories.Get(0, JToken);
        CategoryObj := JToken.AsObject();
        Assert.IsTrue(CategoryObj.Get('items', JToken), 'Category should contain items');
        Items := JToken.AsArray();
        Assert.AreEqual(1, Items.Count(), 'Expected exactly one menu item');

        Items.Get(0, JToken);
        ItemObj := JToken.AsObject();
        Assert.IsTrue(ItemObj.Get('unitPrice', JToken), 'Item should contain unitPrice');
        UnitPrice := JToken.AsValue().AsDecimal();
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
