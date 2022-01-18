codeunit 6014608 "NPR Replication Register"
{
    Permissions =
        tabledata "NPR Replication Service Setup" = rim,
        tabledata "NPR Replication Endpoint" = rim,
        tabledata "NPR Rep. Special Field Mapping" = rim,
        tabledata "NPR E-mail Template Header" = rim,
        tabledata "NPR E-mail Templ. Line" = rim;

    var
        ReplicationErrLogEmailTemplateCode: Label 'REPLICATION_ERR_LOG', Locked = true;
        ItemsServiceCodeLbl: Label 'Item_NPAPI V1', Locked = true;
        ItemsServiceNameLbl: Label 'Item - NP Replication API V1.0';
        CustServiceCodeLbl: Label 'Cust_NPAPI V1', Locked = true;
        CustServiceNameLbl: Label 'Customer - NP Replication API V1.0';
        VendServiceCodeLbl: Label 'Vend_NPAPI V1', Locked = true;
        VendServiceNameLbl: Label 'Vendor - NP Replication API V1.0';
        NPRetailServiceCodeLbl: Label 'Retail_NPAPI V1', Locked = true;
        NPRetailServiceNameLbl: Label 'Retail - NP Replication API V1.0';
        DimensionsServiceCodeLbl: Label 'Dimension_NPAPI V1', Locked = true;
        DimensionsServiceNameLbl: Label 'Dimension - NP Replication API V1.0';
        MiscServiceCodeLbl: Label 'Misc_NPAPI V1', Locked = true;
        MiscServiceNameLbl: Label 'Miscellaneous - NP Replication API V1.0';

        #region Item related endpoints data
        ItemsEndPointIDLbl: Label 'GetItems', Locked = true;
        ItemsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/items/?$expand=picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
        ItemsEndPointDescriptionLbl: Label 'Gets Items from related company. ', Locked = true;

        ItemCategoriesEndPointIDLbl: Label 'GetItemCategories', Locked = true;
        ItemCategoriesEndPointDescriptionLbl: Label 'Gets Item Categories from related company. ', Locked = true;
        ItemCategoriesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemCategories/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        VarGroupsEndPointIDLbl: Label 'GetVarietyGroups', Locked = true;
        VarGroupsEndPointDescriptionLbl: Label 'Gets Variety Groups from related company. ', Locked = true;
        VarGroupsPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        VarietiesEndPointIDLbl: Label 'GetVarieties', Locked = true;
        VarietiesEndPointDescriptionLbl: Label 'Gets Varieties from related company. ', Locked = true;
        VarietiesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varieties/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        VarietyTablesEndPointIDLbl: Label 'GetVarietyTables', Locked = true;
        VarietyTablesEndPointDescriptionLbl: Label 'Gets Variety Tables from related company. ', Locked = true;
        VarietyTablesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyTables/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        VarietyValuesEndPointIDLbl: Label 'GetVarietyValues', Locked = true;
        VarietyValuesEndPointDescriptionLbl: Label 'Gets Variety Values from related company. ', Locked = true;
        VarietyValuesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        ItemVariantsEndPointIDLbl: Label 'GetItemVariants', Locked = true;
        ItemVariantsEndPointDescriptionLbl: Label 'Gets Item Variants from related company. ', Locked = true;
        ItemVariantsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemVariants/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        ItemReferencesEndPointIDLbl: Label 'GetItemReferences', Locked = true;
        ItemReferencesEndPointDescriptionLbl: Label 'Gets Item References from related company. ', Locked = true;
        ItemReferencesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemReferences/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        UOMEndPointIDLbl: Label 'GetUnitsOfMeasure', Locked = true;
        UOMEndPointDescriptionLbl: Label 'Gets Units Of Measure from related company. ', Locked = true;
        UOMPathLbl: Label '/navipartner/core/v1.0/companies(%1)/unitsOfMeasure/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        ItemsUOMEndPointIDLbl: Label 'GetItemsUOM', Locked = true;
        ItemsUOMEndPointDescriptionLbl: Label 'Gets Items Units Of Measure from related company. ', Locked = true;
        ItemsUOMPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemUnitsOfMeasure/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
        #endregion

        #region Customer endpoints data
        CustomersEndPointIDLbl: Label 'GetCustomers', Locked = true;
        CustomersEndPointDescriptionLbl: Label 'Gets Customers from related company.', Locked = true;
        CustomersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customers/?$expand=picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        SalePriceListsEndPointIDLbl: Label 'GetSalePriceListHeaders', Locked = true;
        SalePriceListsEndPointDescriptionLbl: Label 'Gets Sales Price List Headers from related company.', Locked = true;
        SalePriceListsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceLists/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (replicationCounter gt %2)&$orderby=replicationCounter&$schemaVersion=2.0', Locked = true;

        SalePriceListLinesEndPointIDLbl: Label 'GetSalePriceListLines', Locked = true;
        SalePriceListLinesEndPointDescriptionLbl: Label 'Gets Sales Price List Lines from related company.', Locked = true;
        SalePriceListLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceListLines/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (replicationCounter gt %2)&$orderby=replicationCounter&$schemaVersion=2.0', Locked = true;

        SalespersonsPurchasersEndPointIDLbl: Label 'GetSalespersons/Purchasers', Locked = true;
        SalespersonsPurchasersEndPointDescriptionLbl: Label 'Gets Salespersons/Purchasers from related company.', Locked = true;
        SalespersonsPurchasersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/salespersonsPurchasers/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustPriceGroupsEndPointIDLbl: Label 'GetCustPriceGroups', Locked = true;
        CustPriceGroupsEndPointDescriptionLbl: Label 'Gets Customer Price Groups from related company.', Locked = true;
        CustPriceGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerPriceGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustDiscGroupsEndPointIDLbl: Label 'GetCustDiscountGroups', Locked = true;
        CustDiscGroupsEndPointDescriptionLbl: Label 'Gets Customer Discount Groups from related company.', Locked = true;
        CustDiscGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerDiscountGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustPostingGroupsEndPointIDLbl: Label 'GetCustPostingGroups', Locked = true;
        CustPostingGroupsEndPointDescriptionLbl: Label 'Gets Customer Posting Groups from related company.', Locked = true;
        CustPostingGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerPostGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustBankAccountsEndPointIDLbl: Label 'GetCustBankAccounts', Locked = true;
        CustBankAccountsEndPointDescriptionLbl: Label 'Gets Customer Bank Accounts from related company.', Locked = true;
        CustBankAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerBankAccounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
        #endregion

        #region Vendor Endpoints data
        VendorsEndPointIDLbl: Label 'GetVendors', Locked = true;
        VendorsEndPointDescriptionLbl: Label 'Gets Vendors from related company.', Locked = true;
        VendorsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendors/?$expand=picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        VendorBankAccEndPointIDLbl: Label 'GetVendorBankAccounts', Locked = true;
        VendorBankAccEndPointDescriptionLbl: Label 'Gets Vendor Bank Accounts from related company.', Locked = true;
        VendorBankAccPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorBankAccounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        VendorPostGrEndPointIDLbl: Label 'GetVendorPostingGroups', Locked = true;
        VendorPostGrEndPointDescriptionLbl: Label 'Gets Vendor Posting Groups from related company.', Locked = true;
        VendorPostGrPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorPostGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
        #endregion

        #region NP RETAIL endpoints data
        PeriodDiscountsEndPointIDLbl: Label 'GetPeriodicDiscountHeaders', Locked = true;
        PeriodDiscountsEndPointDescriptionLbl: Label 'Gets Periodic Discount Headers from related company.', Locked = true;
        PeriodDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        PeriodDiscountLinesEndPointIDLbl: Label 'GetPeriodicDiscountLines', Locked = true;
        PeriodDiscountLinesEndPointDescriptionLbl: Label 'Gets Periodic Discount Lines from related company.', Locked = true;
        PeriodDiscountLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscountLines/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        MixedDiscountsEndPointIDLbl: Label 'GetMixedDiscounts', Locked = true;
        MixedDiscountsEndPointDescriptionLbl: Label 'Gets Mixed Discounts Headers from related company.', Locked = true;
        MixedDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        MixedDiscountsTIEndPointIDLbl: Label 'GetMixedDisTimeIntervals', Locked = true;
        MixedDiscountsTIEndPointDescriptionLbl: Label 'Gets Mixed Discounts Time Intervals from related company.', Locked = true;
        MixedDiscountsTIPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountTimeIntervals/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        MixedDiscountsLevelsEndPointIDLbl: Label 'GetMixedDisLevels', Locked = true;
        MixedDiscountsLevelsEndPointDescriptionLbl: Label 'Gets Mixed Discounts Levels from related company.', Locked = true;
        MixedDiscountsLevelsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountLevels/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        MixedDiscountsLinesEndPointIDLbl: Label 'GetMixedDiscLines', Locked = true;
        MixedDiscountsLinesEndPointDescriptionLbl: Label 'Gets Mixed Discounts Lines from related company.', Locked = true;
        MixedDiscountsLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountLines/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
        #endregion

        #region DIMENSIONS endpoints data
        DimensionsEndPointIDLbl: Label 'GetDimensions', Locked = true;
        DimensionsEndPointDescriptionLbl: Label 'Gets Dimensions from related company.', Locked = true;
        DimensionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/dimensions/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        DimensionValuesEndPointIDLbl: Label 'GetDimensionValues', Locked = true;
        DimensionValuesEndPointDescriptionLbl: Label 'Gets Dimension Values from related company.', Locked = true;
        DimensionValuesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/dimensionValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        DefaultDimensionsEndPointIDLbl: Label 'GetDefaultDimensions', Locked = true;
        DefaultDimensionsEndPointDescriptionLbl: Label 'Gets Default Dimensions from related company.', Locked = true;
        DefaultDimensionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/defaultDimensions/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        #endregion

        #region MISC endpoints data
        LocationsEndPointIDLbl: Label 'GetLocations', Locked = true;
        LocationsEndPointDescriptionLbl: Label 'Gets Locations from related company.', Locked = true;
        LocationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/locations/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        ShipmentMethodsEndPointIDLbl: Label 'GetShipmentMethods', Locked = true;
        ShipmentMethodsEndPointDescriptionLbl: Label 'Gets Shipment Methods from related company.', Locked = true;
        ShipmentMethodsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/shipmentMethods/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        PaymentTermsEndPointIDLbl: Label 'GetPaymentTerms', Locked = true;
        PaymentTermsEndPointDescriptionLbl: Label 'Gets Payment Terms from related company.', Locked = true;
        PaymentTermsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/paymentTerms/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        PaymentMethodsEndPointIDLbl: Label 'GetPaymentMethods', Locked = true;
        PaymentMethodsEndPointDescriptionLbl: Label 'Gets Payment Methods from related company.', Locked = true;
        PaymentMethodsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/paymentMethods/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CurrenciesEndPointIDLbl: Label 'GetCurrencies', Locked = true;
        CurrenciesEndPointDescriptionLbl: Label 'Gets Currencies from related company.', Locked = true;
        CurrenciesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/currencies/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
    #endregion

    #region Register Service with EndPoints
    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Service Setup", 'OnRegisterService', '', true, true)]
    local procedure OnRegisterService(sender: Record "NPR Replication Service Setup")
    begin
        RegisterServiceWithEndPoints(sender);
    end;

    local procedure RegisterServiceWithEndPoints(sender: Record "NPR Replication Service Setup")
    var
        ReplicationAPI: Codeunit "NPR Replication API";
        BaseURLAPI: Text[100];
        Tenant: Text[50];
    begin
        BaseURLAPI := GetAPIServiceURL();
        Tenant := GetTenant();

        // ITEM
        sender.RegisterService(ItemsServiceCodeLbl,
            BaseURLAPI, ItemsServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterItemServiceEndPoints();
        if sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // CUSTOMER
        sender.RegisterService(CustServiceCodeLbl,
            BaseURLAPI, CustServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterCustServiceEndPoints();
        if sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // VENDOR
        sender.RegisterService(VendServiceCodeLbl,
            BaseURLAPI, VendServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterVendServiceEndPoints();
        if sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // NP RETAIL
        sender.RegisterService(NPRetailServiceCodeLbl,
            BaseURLAPI, NPRetailServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterNPRetailServiceEndPoints();
        if sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // DIMENSIONS
        sender.RegisterService(DimensionsServiceCodeLbl,
            BaseURLAPI, DimensionsServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterDimensionsServiceEndPoints();
        if sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // MISC
        sender.RegisterService(MiscServiceCodeLbl,
            BaseURLAPI, MiscServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterMiscellaneousServiceEndPoints();
        if sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        OnAfterRegisterServices(sender);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterServices(sender: Record "NPR Replication Service Setup")
    begin
    end;
    #endregion

    #region Register Service EndPoints
    local procedure RegisterItemServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", ItemsServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemCategoriesEndPointIDLbl, ItemCategoriesPathLbl,
                            ItemCategoriesEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Item Category", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, UOMEndPointIDLbl, UOMPathLbl,
                    UOMEndPointDescriptionLbl, true, 110, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    1000, Database::"Unit of Measure", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarietiesEndPointIDLbl, VarietiesPathLbl,
                    VarietiesEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    1000, Database::"NPR Variety", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarietyTablesEndPointIDLbl, VarietyTablesPathLbl,
                    VarietyTablesEndPointDescriptionLbl, true, 210, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"NPR Variety Table", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarietyValuesEndPointIDLbl, VarietyValuesPathLbl,
                    VarietyValuesEndPointDescriptionLbl, true, 220, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"NPR Variety Value", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarGroupsEndPointIDLbl, VarGroupsPathLbl,
            VargroupsEndPointDescriptionLbl, true, 230, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
            1000, Database::"NPR Variety Group", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemsEndPointIDLbl, ItemsPathLbl,
                    ItemsEndPointDescriptionLbl, true, 300, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::Item, false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemsUOMEndPointIDLbl, ItemsUOMPathLbl,
            ItemsUOMEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
            10000, Database::"Item Unit of Measure", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemVariantsEndPointIDLbl, ItemVariantsPathLbl,
                    ItemVariantsEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"Item Variant", true, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemReferencesEndPointIDLbl, ItemReferencesPathLbl,
                    ItemReferencesEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"Item Reference", false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemCatSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Category";
    begin
        if sender."Table ID" <> Database::"Item Category" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Description), 'displayName', 0, true, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterUOMSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Unit of Measure";
    begin
        if sender."Table ID" <> Database::"Unit of Measure" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Description), 'displayName', 0, true, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVarietySpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Variety";
    begin
        if sender."Table ID" <> Database::"NPR Variety" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Use in Variant Description"), 'useinVariantDescription', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Pre tag In Variant Description"), 'pretagInVariantDescription', 0, true, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVarietyTableSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Variety Table";
    begin
        if sender."Table ID" <> Database::"NPR Variety Table" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Copy from"), 'copyfrom', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Pre tag In Variant Description"), 'pretagInVariantDescription', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("Pre tag In Variant Description"), 'pretagInVariantDescription', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("Use in Variant Description"), 'useinVariantDescription', 0, true, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVarietyValueSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Variety Value";
    begin
        if sender."Table ID" <> Database::"NPR Variety Value" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVarietyGroupSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Variety Group";
    begin
        if sender."Table ID" <> Database::"NPR Variety Group" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Create Copy of Variety 1 Table"), 'createCopyofVariety1Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Create Copy of Variety 2 Table"), 'createCopyofVariety2Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Create Copy of Variety 3 Table"), 'createCopyofVariety3Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Create Copy of Variety 4 Table"), 'createCopyofVariety4Table', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item";
    begin
        if sender."Table ID" <> Database::"Item" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
        Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("No."), 'number', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Description), 'displayName', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Description 2"), 'displayName2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Price Includes VAT"), 'priceIncludesTax', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Unit of Measure Id"), 'baseUnitOfMeasureId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Base Unit of Measure"), 'baseUnitOfMeasureCode', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Sales Unit of Measure"), 'salesUnitofMeasure', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Purch. Unit of Measure"), 'purchUnitofMeasure', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Default Deferral Template Code"), 'defaultDeferralTemplate', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
         Rec.FieldNo("Scrap %"), 'scrapPct', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("NPR Attribute Set ID"), 'nprAttributeSetID', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Magento Desc."), 'nprMagentoDescription@odata.mediaReadLink', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Magento Short Desc."), 'nprMagentoShortDescription@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemUOMSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Unit of Measure";
    begin
        if sender."Table ID" <> Database::"Item Unit of Measure" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Item No."), 'itemNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Qty. per Unit of Measure"), 'qtyperUnitofMeasure', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemVariantSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Variant";
    begin
        if sender."Table ID" <> Database::"Item Variant" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Item Id"), 'itemId', 0, false, true);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Item No."), 'itemNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 1"), 'variety1', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 1 Table"), 'variety1Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 1 Value"), 'variety1Value', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("NPR Variety 2"), 'variety2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 2 Table"), 'variety2Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 2 Value"), 'variety2Value', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("NPR Variety 3"), 'variety3', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 3 Table"), 'variety3Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 3 Value"), 'variety3Value', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("NPR Variety 4"), 'variety4', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 4 Table"), 'variety4Table', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Variety 4 Value"), 'variety4Value', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Blocked"), 'blocked', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemReferenceSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Reference";
    begin
        if sender."Table ID" <> Database::"Item Reference" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Unit of Measure"), 'unitofMeasure', 0, false, false);
    end;

    local procedure RegisterCustServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", CustServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustPriceGroupsEndPointIDLbl, CustPriceGroupsPathLbl,
                            CustPriceGroupsEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Customer Price Group", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustDiscGroupsEndPointIDLbl, CustDiscGroupsPathLbl,
                            CustDiscGroupsEndPointDescriptionLbl, true, 410, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Customer Discount Group", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustPostingGroupsEndPointIDLbl, CustPostingGroupsPathLbl,
                            CustPostingGroupsEndPointDescriptionLbl, true, 420, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Customer Posting Group", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustomersEndPointIDLbl, CustomersPathLbl,
                            CustomersEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::Customer, false, false);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, SalePriceListsEndPointIDLbl, SalePriceListsPathLbl,
                            SalePriceListsEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            10000, Database::"Price List Header", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, SalePriceListLinesEndPointIDLbl, SalePriceListLinesPathLbl,
                            SalePriceListLinesEndPointDescriptionLbl, true, 610, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            10000, Database::"Price List Line", true, true);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, SalespersonsPurchasersEndPointIDLbl, SalespersonsPurchasersPathLbl,
                            SalespersonsPurchasersEndPointDescriptionLbl, true, 700, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            10000, Database::"Salesperson/Purchaser", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustBankAccountsEndPointIDLbl, CustBankAccountsPathLbl,
                            CustBankAccountsEndPointDescriptionLbl, true, 800, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            10000, Database::"Customer Bank Account", false, false);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterCustPriceGroupSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Customer Price Group";
    begin
        if sender."Table ID" <> Database::"Customer Price Group" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterCustDiscGroupSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Customer Discount Group";
    begin
        if sender."Table ID" <> Database::"Customer Discount Group" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterCustPostingGroupSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Customer Posting Group";
    begin
        if sender."Table ID" <> Database::"Customer Posting Group" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterCustSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record Customer;
    begin
        if sender."Table ID" <> Database::Customer then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("No."), 'number', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(Name), 'displayName', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Name 2"), 'displayName2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Contact Type"), 'type', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Address"), 'addressLine1', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Address 2"), 'addressLine2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("No."), 'number', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(County), 'state', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Country/Region Code"), 'country', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Post Code"), 'postalCode', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("No."), 'number', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Phone No."), 'phoneNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Mobile Phone No."), 'mobilePhoneNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("E-Mail"), 'email', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Home Page"), 'website', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("VAT Registration No."), 'taxRegistrationNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Validate EU Vat Reg. No."), 'validateEUVatRegNo', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Credit Limit (LCY)"), 'creditLimitLCY', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Prepayment %"), 'prepaymentPct', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(Image), 'picture', 0, false, false);

#if BC17
        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           89, 'picture', 0, false, true);
#ENDIF
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterPriceListHeaderSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Price List Header";
    begin
        if sender."Table ID" <> Database::"Price List Header" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Source ID"), 'sourceID', 0, false, false);
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterPriceListLineSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Price List Line";
    begin
        if sender."Table ID" <> Database::"Price List Line" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Source ID"), 'sourceID', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Line Discount %"), 'lineDiscount', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Price Includes VAT"), 'priceIncludesVAT', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterSalespersonPurchSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Salesperson/Purchaser";
    begin
        if sender."Table ID" <> Database::"Salesperson/Purchaser" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Name), 'displayName', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Commission %"), 'commission', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(Image), 'image@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterCustBankAccountSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Customer Bank Account";
    begin
        if sender."Table ID" <> Database::"Customer Bank Account" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    local procedure RegisterVendServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", VendServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(VendServiceCodeLbl, VendorPostGrEndPointIDLbl, VendorPostGrPathLbl,
                    VendorPostGrEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    1000, Database::"Vendor Posting Group", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(VendServiceCodeLbl, VendorsEndPointIDLbl, VendorsPathLbl,
                    VendorsEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    1000, Database::Vendor, false, false);

        ServiceEndPoint.RegisterServiceEndPoint(VendServiceCodeLbl, VendorBankAccEndPointIDLbl, VendorBankAccPathLbl,
                    VendorBankAccEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    1000, Database::"Vendor Bank Account", false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVendorSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Vendor";
    begin
        if sender."Table ID" <> Database::"Vendor" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("No."), 'number', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Name), 'displayName', 0, true, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Name 2"), 'displayName2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(Address), 'addressLine1', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Address 2"), 'addressLine2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(County), 'state', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Country/Region Code"), 'country', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Post Code"), 'postalCode', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Phone No."), 'phoneNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("E-Mail"), 'email', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Home Page"), 'website', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("VAT Registration No."), 'taxRegistrationNumber', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("Prepayment %"), 'prepaymentPct', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("Validate EU Vat Reg. No."), 'validateEUVatRegNo', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo(Image), 'picture', 0, false, false);

#if BC17
        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          89, 'picture', 0, false, true);
#ENDIF
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVendorBankAccSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Vendor Bank Account";
    begin
        if sender."Table ID" <> Database::"Vendor Bank Account" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVendorPostGrSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Vendor Posting Group";
    begin
        if sender."Table ID" <> Database::"Vendor Posting Group" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    local procedure RegisterNPRetailServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", NPRetailServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, PeriodDiscountsEndPointIDLbl, PeriodDiscountsPathLbl,
                            PeriodDiscountsEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Period Discount", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, PeriodDiscountLinesEndPointIDLbl, PeriodDiscountLinesPathLbl,
                           PeriodDiscountLinesEndPointDescriptionLbl, true, 510, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                        1000, Database::"NPR Period Discount Line", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, MixedDiscountsEndPointIDLbl, MixedDiscountsPathLbl,
                            MixedDiscountsEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Mixed Discount", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, MixedDiscountsTIEndPointIDLbl, MixedDiscountsTIPathLbl,
                            MixedDiscountsTIEndPointDescriptionLbl, true, 610, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Mixed Disc. Time Interv.", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, MixedDiscountsLevelsEndPointIDLbl, MixedDiscountsLevelsPathLbl,
                            MixedDiscountsLevelsEndPointDescriptionLbl, true, 620, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Mixed Discount Level", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, MixedDiscountsLinesEndPointIDLbl, MixedDiscountsLinesPathLbl,
                            MixedDiscountsLinesEndPointDescriptionLbl, true, 630, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Mixed Discount Line", false, false);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterPeriodDiscSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Period Discount";
    begin
        if sender."Table ID" <> Database::"NPR Period Discount" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterPeriodDiscLineSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Period Discount Line";
    begin
        if sender."Table ID" <> Database::"NPR Period Discount Line" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Discount %"), 'discount', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMixDiscSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Mixed Discount";
    begin
        if sender."Table ID" <> Database::"NPR Mixed Discount" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Starting date"), 'startingdate', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Starting time"), 'Starting time', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Ending date"), 'endingdate', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Ending time"), 'endingtime', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Created the"), 'createdthe', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Item Discount %"), 'itemDiscount', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Quantity sold"), 'quantitysold', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Total Amount Excl. VAT"), 'totalAmountExclVAT', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Total Amount Excl. VAT"), 'totalAmountExclVAT', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Total Amount Excl. VAT"), 'totalAmountExclVAT', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Total Discount %"), 'totalDiscount', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMixDiscTimeIntervalsLineSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Mixed Disc. Time Interv.";
    begin
        if sender."Table ID" <> Database::"NPR Mixed Disc. Time Interv." then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMixDiscLevelsLineSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Mixed Discount Level";
    begin
        if sender."Table ID" <> Database::"NPR Mixed Discount Level" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Discount %"), 'discount', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMixDiscLinesLineSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Mixed Discount Line";
    begin
        if sender."Table ID" <> Database::"NPR Mixed Discount Line" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Unit cost"), 'unitcost', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Unit price"), 'unitprice', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Unit price incl. VAT"), 'unitpriceinclVAT', 0, false, false);
    end;

    local procedure RegisterDimensionsServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", DimensionsServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(DimensionsServiceCodeLbl, DimensionsEndPointIDLbl, DimensionsPathLbl,
                            DimensionsEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::Dimension, false, false);

        ServiceEndPoint.RegisterServiceEndPoint(DimensionsServiceCodeLbl, DimensionValuesEndPointIDLbl, DimensionValuesPathLbl,
                            DimensionValuesEndPointDescriptionLbl, true, 150, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Dimension Value", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(DimensionsServiceCodeLbl, DefaultDimensionsEndPointIDLbl, DefaultDimensionsPathLbl,
                            DefaultDimensionsEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Default Dimension", false, false);

    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterDimSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Dimension";
    begin
        if sender."Table ID" <> Database::"Dimension" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Name), 'displayName', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Map-to IC Dimension Code"), 'mapToICDimensionCode', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterDimValueSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Dimension Value";
    begin
        if sender."Table ID" <> Database::"Dimension Value" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Name), 'displayName', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Map-to IC Dimension Code"), 'mapToICDimensionCode', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Map-to IC Dimension Value Code"), 'mapToICDimensionValueCode', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterDefaultDimSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Default Dimension";
    begin
        if sender."Table ID" <> Database::"Default Dimension" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Table ID"), 'tableID', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Value Posting"), 'postingValidation', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(ParentId), 'parentId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(DimensionId), 'dimensionId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(DimensionValueId), 'dimensionValueId', 0, false, false);
    end;

    local procedure RegisterMiscellaneousServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", DimensionsServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, LocationsEndPointIDLbl, LocationsPathLbl,
                            LocationsEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::Location, false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, ShipmentMethodsEndPointIDLbl, ShipmentMethodsPathLbl,
                            ShipmentMethodsEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Shipment Method", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, PaymentTermsEndPointIDLbl, PaymentTermsPathLbl,
                            PaymentTermsEndPointDescriptionLbl, true, 300, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Payment Terms", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, PaymentMethodsEndPointIDLbl, PaymentMethodsPathLbl,
                            PaymentMethodsEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"Payment Method", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, CurrenciesEndPointIDLbl, CurrenciesPathLbl,
                            CurrenciesEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::Currency, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterLocationSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record Location;
    begin
        if sender."Table ID" <> Database::Location then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Name), 'displayName', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Name 2"), 'displayName2', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Use ADCS"), 'useADCS', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterShipMethodSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Shipment Method";
    begin
        if sender."Table ID" <> Database::"Shipment Method" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterPaymentTermsSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Payment Terms";
    begin
        if sender."Table ID" <> Database::"Payment Terms" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Discount %"), 'discount', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterPaymentMethodSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Payment Method";
    begin
        if sender."Table ID" <> Database::"Payment Method" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterCurrencySpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record Currency;
    begin
        if sender."Table ID" <> Database::Currency then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Description), 'displayName', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Payment Tolerance %"), 'paymentTolerancePercent', 0, false, false);
    end;

    #endregion

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Service Setup", 'OnAfterValidateEvent', 'Error Notify Email Address', true, true)]
    local procedure CreateDefaultEmailTemplate()
    var
        EmailTemplate: Record "NPR E-mail Template Header";
        EmailTemplateLine: Record "NPR E-mail Templ. Line";
        Lines: List of [Text];
        i: Integer;
        ErrorLogUrlTxt: Text;
    begin
        EmailTemplate.SetRange("Table No.", Database::"NPR Replication Error Log");
        if not EmailTemplate.IsEmpty() then
            exit;

        EmailTemplate.Init();
        EmailTemplate.Code := ReplicationErrLogEmailTemplateCode;
        EmailTemplate.Description := 'Send Replication Error Log';
        EmailTemplate.Subject := 'Data Replication Error';
        EmailTemplate."Table No." := Database::"NPR Replication Error Log";
        EmailTemplate."Fieldnumber Start Tag" := '$(';
        EmailTemplate."Fieldnumber End Tag" := '$)';
        EmailTemplate.Insert();

        Lines.Add('There was an error in the Replication Process.');
        Lines.Add('');
        Lines.Add('Company Name: ' + CompanyName());
        Lines.Add('Error Log Entry No.: $(1$)');
        Lines.Add('API Version: $(10$)');
        Lines.Add('Endpoint Id: $(15$)');
        ErrorLogUrlTxt := 'Error Log URL: ' + System.GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"NPR Replication Error Log");
        if StrLen(ErrorLogUrlTxt) <= MaxStrLen(EmailTemplateLine."Mail Body Line") then
            Lines.Add(ErrorLogUrlTxt);
        Lines.Add('');
        Lines.Add('Error Message:');
        Lines.Add('$(31$)');

        for i := 1 to Lines.Count() do begin
            EmailTemplateLine.Init();
            EmailTemplateLine."E-mail Template Code" := EmailTemplate.Code;
            EmailTemplateLine."Line No." := i * 10000;
            EmailTemplateLine."Mail Body Line" := Lines.Get(i);
            EmailTemplateLine.Insert();
        end;
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR E-mail Template Header", 'OnAfterDeleteEvent', '', true, true)]
    local procedure DeleteRepSetupNotificationEmailAddressOnEmailTemplateDelete(var Rec: Record "NPR E-mail Template Header"; RunTrigger: Boolean)
    var
        ReplicationSetup: Record "NPR Replication Service Setup";
    begin
        if Rec.IsTemporary() then
            exit;

        if Rec.Code <> ReplicationErrLogEmailTemplateCode then
            exit;

        if ReplicationSetup.Findset(true, false) then
            repeat
                ReplicationSetup."Error Notify Email Address" := '';
                ReplicationSetup.Modify();
            until ReplicationSetup.Next() = 0;
    end;

    local procedure GetAPIServiceURL() BaseURL: Text
    begin
        BaseURL := GetUrl(ClientType::Api).TrimEnd('/');
        IF BaseURL.ToLower().Contains('?tenant=') then
            BaseUrl := BaseURL.Remove(BaseURL.ToLower().IndexOf('?tenant='), StrLen(BaseURL) - BaseURL.ToLower().IndexOf('?tenant=') + 1).TrimEnd('/'); // remove tenant
    end;

    local procedure GetTenant() Tenant: Text
    var
        BaseURL: Text;
    begin
        BaseURL := GetUrl(ClientType::Api);
        IF BaseURL.ToLower().Contains('?tenant=') then
            Tenant := BaseURL.Substring(BaseURL.ToLower().IndexOf('?tenant='), StrLen(BaseURL) - BaseURL.ToLower().IndexOf('?tenant=') + 1).Replace('?tenant=', '')
        Else
            tenant := 'DEFAULT'
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    procedure OnUpdateCustomEndpoints(var Handled: Boolean)
#pragma warning restore
    begin
        // code from customer app subscribes to this event to update endpoints Path: for custom fields we need to have custom api page in customer extension and use that api instead of the standard one.
    end;

}