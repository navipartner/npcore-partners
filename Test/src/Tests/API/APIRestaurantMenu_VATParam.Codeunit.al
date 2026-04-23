#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 85198 "NPR APIRestMenu VATParam"
{
    // [FEATURE] Restaurant Menu API — optional vatBusinessPostingGroup query param overrides VAT for price calc

    Subtype = Test;

    var
        _Initialized: Boolean;
        _POSUnit: Record "NPR POS Unit";
        _POSStore: Record "NPR POS Store";
        _Item: Record Item;
        _Restaurant: Record "NPR NPRE Restaurant";
        _Menu: Record "NPR NPRE Menu";
        _MenuCategory: Record "NPR NPRE Menu Category";
        _AltVATBusGroupCode: Code[20];

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure OverridesVATViaQueryParam()
    var
        Assert: Codeunit Assert;
        DefaultPrice: Decimal;
        OverriddenPrice: Decimal;
    begin
        // [SCENARIO] When ?vatBusinessPostingGroup=<alt> is provided, the API uses the alternate VAT setup.
        Initialize();
        SetItemPriceAndAddToMenu(125.00);

        DefaultPrice := GetUnitPrice('');
        OverriddenPrice := GetUnitPrice(_AltVATBusGroupCode);

        Assert.AreNotEqual(DefaultPrice, OverriddenPrice, 'Price should differ when VAT group is overridden');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure BlankQueryParamUsesDefault()
    var
        Assert: Codeunit Assert;
        PriceNoParam: Decimal;
        PriceBlankParam: Decimal;
    begin
        // [SCENARIO] Blank ?vatBusinessPostingGroup= is equivalent to not specifying the parameter.
        Initialize();
        SetItemPriceAndAddToMenu(125.00);

        PriceNoParam := GetUnitPrice('');
        PriceBlankParam := GetUnitPriceWithRawQueryParam('');

        Assert.AreEqual(PriceNoParam, PriceBlankParam, 'Blank query param should match no-param behavior');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure InvalidVATBusinessPostingGroupReturns400()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        Assert: Codeunit Assert;
        Response: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Path: Text;
        StatusCode: Integer;
    begin
        // [SCENARIO] An unknown vatBusinessPostingGroup returns 400 Bad Request.
        Initialize();
        SetItemPriceAndAddToMenu(125.00);

        QueryParams.Add('vatBusinessPostingGroup', 'NOTREAL');
        Path := '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/menu/' + FormatGuid(_Menu.SystemId);
        Response := LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Unknown VAT group should fail');

        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Unknown VAT Business Posting Group should return 400');
    end;

    [Test]
    [TestPermissions(TestPermissions::Disabled)]
    procedure MissingVATPostingSetupReportsOffendingItem()
    var
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        VATBusGroupNoSetup: Record "VAT Business Posting Group";
        Response: JsonObject;
        ResponseBody: JsonObject;
        Body: JsonObject;
        QueryParams: Dictionary of [Text, Text];
        Headers: Dictionary of [Text, Text];
        JToken: JsonToken;
        Path: Text;
        StatusCode: Integer;
        ErrorText: Text;
    begin
        // [SCENARIO] An existing VAT Bus. Posting Group that has NO VAT Posting Setup for the menu item's VAT Prod. Posting Group
        //             returns 400 with an error text that names the offending item — exercising the per-item error path that
        //             replaced the prior pre-validation loop.
        Initialize();
        SetItemPriceAndAddToMenu(125.00);

        LibraryERM.CreateVATBusinessPostingGroup(VATBusGroupNoSetup);
        Commit();

        QueryParams.Add('vatBusinessPostingGroup', VATBusGroupNoSetup.Code);
        Path := '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/menu/' + FormatGuid(_Menu.SystemId);
        Response := LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParams, Headers);

        Assert.IsFalse(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Missing VAT Posting Setup should fail');

        Response.Get('statusCode', JToken);
        StatusCode := JToken.AsValue().AsInteger();
        Assert.AreEqual(400, StatusCode, 'Missing VAT Posting Setup should return 400');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        if ResponseBody.Get('message', JToken) then
            ErrorText := JToken.AsValue().AsText();
        Assert.IsTrue(StrPos(ErrorText, _Item."No.") > 0, StrSubstNo('Error text should name the offending item (%1), got: %2', _Item."No.", ErrorText));
    end;

    local procedure Initialize()
    var
        LibraryPOSMasterData: Codeunit "NPR Library - POS Master Data";
        LibraryRestaurant: Codeunit "NPR Library - Restaurant";
        LibraryNPRetailAPI: Codeunit "NPR Library - NPRetail API";
        LibraryERM: Codeunit "Library - ERM";
        ItemRoutingProfile: Record "NPR NPRE Item Routing Profile";
        POSPostingProfile: Record "NPR POS Posting Profile";
        POSSetup: Record "NPR POS Setup";
        POSRestProfile: Record "NPR POS NPRE Rest. Profile";
        ServFlowProfile: Record "NPR NPRE Serv.Flow Profile";
        RestaurantSetup: Record "NPR NPRE Restaurant Setup";
        UserSetup: Record "User Setup";
        AltVATBusGroup: Record "VAT Business Posting Group";
        AltVATPostingSetup: Record "VAT Posting Setup";
        GLSetup: Record "General Ledger Setup";
    begin
        if _Initialized then
            exit;

        LibraryNPRetailAPI.CreateAPIPermission(UserSecurityId(), CompanyName(), 'NPR API Restaurant');

        GLSetup.Get();
        GLSetup."Unit-Amount Rounding Precision" := 0.01;
        GLSetup.Modify();

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

        LibraryERM.CreateVATBusinessPostingGroup(AltVATBusGroup);
        _AltVATBusGroupCode := AltVATBusGroup.Code;
        LibraryERM.CreateVATPostingSetup(AltVATPostingSetup, _AltVATBusGroupCode, _Item."VAT Prod. Posting Group");
        AltVATPostingSetup."VAT %" := 0;
        AltVATPostingSetup."VAT Calculation Type" := AltVATPostingSetup."VAT Calculation Type"::"Normal VAT";
        AltVATPostingSetup."VAT Identifier" := 'ZERO';
        AltVATPostingSetup."Sales VAT Account" := LibraryERM.CreateGLAccountNo();
        AltVATPostingSetup."Purchase VAT Account" := LibraryERM.CreateGLAccountNo();
        AltVATPostingSetup.Modify();

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

    local procedure SetItemPriceAndAddToMenu(UnitPrice: Decimal)
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

    local procedure GetUnitPrice(VATBusGroup: Code[20]) UnitPrice: Decimal
    begin
        if VATBusGroup = '' then
            UnitPrice := GetUnitPriceWithRawQueryParam('NONE')
        else
            UnitPrice := GetUnitPriceWithRawQueryParam(VATBusGroup);
    end;

    local procedure GetUnitPriceWithRawQueryParam(QueryParamValue: Text) UnitPrice: Decimal
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
        if QueryParamValue <> 'NONE' then
            QueryParams.Add('vatBusinessPostingGroup', QueryParamValue);

        Path := '/restaurant/' + FormatGuid(_Restaurant.SystemId) + '/menu/' + FormatGuid(_Menu.SystemId);
        Response := LibraryNPRetailAPI.CallApi('GET', Path, Body, QueryParams, Headers);
        Assert.IsTrue(LibraryNPRetailAPI.IsSuccessStatusCode(Response), 'Get menu should succeed');

        ResponseBody := LibraryNPRetailAPI.GetResponseBody(Response);
        ResponseBody.Get('menuContent', JToken);
        JToken.AsObject().Get('categories', JToken);
        Categories := JToken.AsArray();
        Categories.Get(0, JToken);
        CategoryObj := JToken.AsObject();
        CategoryObj.Get('items', JToken);
        Items := JToken.AsArray();
        Items.Get(0, JToken);
        ItemObj := JToken.AsObject();
        ItemObj.Get('unitPrice', JToken);
        UnitPrice := JToken.AsValue().AsDecimal();
    end;

    local procedure FormatGuid(Id: Guid): Text
    begin
        exit(Format(Id, 0, 4).ToLower());
    end;
}
#endif
