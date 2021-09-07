codeunit 6014608 "NPR Replication Register"
{
    Access = Internal;

    var
        ItemsServiceCodeLbl: Label 'Item_NPAPI V1', Locked = true;
        ItemsServiceNameLbl: Label 'Item - NP Replication API V1.0';
        CustServiceCodeLbl: Label 'Cust_NPAPI V1', Locked = true;
        CustServiceNameLbl: Label 'Customer - NP Replication API V1.0';
        NPRetailServiceCodeLbl: Label 'Retail_NPAPI V1', Locked = true;
        NPRetailServiceNameLbl: Label 'Retail - NP Replication API V1.0';
        DimensionsServiceCodeLbl: Label 'Dimension_NPAPI V1', Locked = true;
        DimensionsServiceNameLbl: Label 'Dimension - NP Replication API V1.0';
        MiscServiceCodeLbl: Label 'Misc_NPAPI V1', Locked = true;
        MiscServiceNameLbl: Label 'Miscellaneous - NP Replication API V1.0';

        #region Item related endpoints data
        ItemsEndPointIDLbl: Label 'GetItems', Locked = true;

        ItemsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/items/?$expand=unitOfMeasure,defaultDimensions,itemVariants,picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
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

        CustomersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customers/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        SalePriceListsEndPointIDLbl: Label 'GetSalePriceListHeaders', Locked = true;

        SalePriceListsEndPointDescriptionLbl: Label 'Gets Sales Price List Headers from related company.', Locked = true;

        SalePriceListsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceLists/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (replicationCounter gt %2)&$orderby=replicationCounter$schemaVersion=2.0', Locked = true;

        SalePriceListLinesEndPointIDLbl: Label 'GetSalePriceListLines', Locked = true;

        SalePriceListLinesEndPointDescriptionLbl: Label 'Gets Sales Price List Lines from related company.', Locked = true;

        SalePriceListLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceListLines/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (replicationCounter gt %2)&$orderby=replicationCounter$schemaVersion=2.0', Locked = true;

        SalespersonsPurchasersEndPointIDLbl: Label 'GetSalespersons/Purchasers', Locked = true;

        SalespersonsPurchasersEndPointDescriptionLbl: Label 'Gets Salespersons/Purchasers from related company.', Locked = true;

        SalespersonsPurchasersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/salespersonsPurchasers/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustPriceGroupsEndPointIDLbl: Label 'GetCustPriceGroups', Locked = true;

        CustPriceGroupsEndPointDescriptionLbl: Label 'Gets Customer Price Groups from related company.', Locked = true;

        CustPriceGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/custPriceGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustDiscGroupsEndPointIDLbl: Label 'GetCustDiscountGroups', Locked = true;

        CustDiscGroupsEndPointDescriptionLbl: Label 'Gets Customer Discount Groups from related company.', Locked = true;

        CustDiscGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/custDiscountGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        CustPostingGroupsEndPointIDLbl: Label 'GetCustPostingGroups', Locked = true;

        CustPostingGroupsEndPointDescriptionLbl: Label 'Gets Customer Posting Groups from related company.', Locked = true;

        CustPostingGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/custPostingGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
        #endregion

        #region NP RETAIL endpoints data
        PeriodDiscountsEndPointIDLbl: Label 'GetPeriodicDiscounts', Locked = true;

        PeriodDiscountsEndPointDescriptionLbl: Label 'Gets Periodic Discounts Header and Lines from related company.', Locked = true;

        PeriodDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscounts/?$expand=periodDiscountLines&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

        MixedDiscountsEndPointIDLbl: Label 'GetMixedDiscounts', Locked = true;

        MixedDiscountsEndPointDescriptionLbl: Label 'Gets Mixed Discounts Header and Lines from related company.', Locked = true;

        MixedDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscounts/?$expand=mixedDiscountTimeIntervals,mixedDiscountLevels,mixedDiscountLines&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;

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
    begin
        // ITEM
        sender.RegisterService(ItemsServiceCodeLbl,
            GetAPIServiceURL(), ItemsServiceNameLbl, false, "NPR Replication API Auth. Type"::Basic, 'DEFAULT');
        RegisterItemServiceEndPoints();
        IF sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // CUSTOMER
        sender.RegisterService(CustServiceCodeLbl,
            GetAPIServiceURL(), CustServiceNameLbl, false, "NPR Replication API Auth. Type"::Basic, 'DEFAULT');
        RegisterCustServiceEndPoints();
        IF sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // NP RETAIL
        sender.RegisterService(NPRetailServiceCodeLbl,
            GetAPIServiceURL(), NPRetailServiceNameLbl, false, "NPR Replication API Auth. Type"::Basic, 'DEFAULT');
        RegisterNPRetailServiceEndPoints();
        IF sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // DIMENSIONS
        sender.RegisterService(DimensionsServiceCodeLbl,
            GetAPIServiceURL(), DimensionsServiceNameLbl, false, "NPR Replication API Auth. Type"::Basic, 'DEFAULT');
        RegisterDimensionsServiceEndPoints();
        IF sender.Enabled then begin
            ReplicationAPI.RegisterNcImportType(sender."API Version");
            ReplicationAPI.ScheduleJobQueueEntry(sender);
        end;

        // MISC
        sender.RegisterService(MiscServiceCodeLbl,
            GetAPIServiceURL(), MiscServiceNameLbl, false, "NPR Replication API Auth. Type"::Basic, 'DEFAULT');
        RegisterMiscellaneousServiceEndPoints();
        IF sender.Enabled then begin
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

    [IntegrationEvent(false, false)]
    local procedure OnAfterRegisterServiceEndPoint(sender: Record "NPR Replication Endpoint")
    begin
    end;


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
                            ItemCategoriesEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get Item Categories", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, UOMEndPointIDLbl, UOMPathLbl,
                    UOMEndPointDescriptionLbl, true, 110, "NPR Replication EndPoint Meth"::"Get Units of Measure", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarietiesEndPointIDLbl, VarietiesPathLbl,
                    VarietiesEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get Varieties", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarietyTablesEndPointIDLbl, VarietyTablesPathLbl,
                    VarietyTablesEndPointDescriptionLbl, true, 210, "NPR Replication EndPoint Meth"::"Get Variety Tables", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarietyValuesEndPointIDLbl, VarietyValuesPathLbl,
                    VarietyValuesEndPointDescriptionLbl, true, 220, "NPR Replication EndPoint Meth"::"Get Variety Values", 0, 10000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, VarGroupsEndPointIDLbl, VarGroupsPathLbl,
            VargroupsEndPointDescriptionLbl, true, 230, "NPR Replication EndPoint Meth"::"Get Variety Groups", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemsEndPointIDLbl, ItemsPathLbl,
                    ItemsEndPointDescriptionLbl, true, 300, "NPR Replication EndPoint Meth"::"Get Items", 0, 10000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemsUOMEndPointIDLbl, ItemsUOMPathLbl,
            ItemsUOMEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get Items Units of Measure", 0, 10000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemVariantsEndPointIDLbl, ItemVariantsPathLbl,
                    ItemVariantsEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get Item Variants", 0, 10000);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemReferencesEndPointIDLbl, ItemReferencesPathLbl,
                    ItemReferencesEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get Item References", 0, 10000);

        OnAfterRegisterServiceEndPoint(ServiceEndPoint);
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
                            CustPriceGroupsEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get Customer Price Groups", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustDiscGroupsEndPointIDLbl, CustDiscGroupsPathLbl,
                            CustDiscGroupsEndPointDescriptionLbl, true, 410, "NPR Replication EndPoint Meth"::"Get Customer Discount Groups", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustPostingGroupsEndPointIDLbl, CustPostingGroupsPathLbl,
                           CustPostingGroupsEndPointDescriptionLbl, true, 420, "NPR Replication EndPoint Meth"::"Get Customer Posting Groups", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, CustomersEndPointIDLbl, CustomersPathLbl,
                            CustomersEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get Customers", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, SalePriceListsEndPointIDLbl, SalePriceListsPathLbl,
                            SalePriceListsEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get Price List Headers", 0, 10000);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, SalePriceListLinesEndPointIDLbl, SalePriceListLinesPathLbl,
                            SalePriceListLinesEndPointDescriptionLbl, true, 610, "NPR Replication EndPoint Meth"::"Get Price List Lines", 0, 10000);

        ServiceEndPoint.RegisterServiceEndPoint(CustServiceCodeLbl, SalespersonsPurchasersEndPointIDLbl, SalespersonsPurchasersPathLbl,
                            SalespersonsPurchasersEndPointDescriptionLbl, true, 700, "NPR Replication EndPoint Meth"::"Get Salespersons/Purchasers", 0, 10000);

        OnAfterRegisterServiceEndPoint(ServiceEndPoint);
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
                            PeriodDiscountsEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get Periodic Discounts", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(NPRetailServiceCodeLbl, MixedDiscountsEndPointIDLbl, MixedDiscountsPathLbl,
                            MixedDiscountsEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get Mixed Discounts", 0, 1000);

        OnAfterRegisterServiceEndPoint(ServiceEndPoint);
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
                           DimensionsEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get Dimensions", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(DimensionsServiceCodeLbl, DimensionValuesEndPointIDLbl, DimensionValuesPathLbl,
                           DimensionValuesEndPointDescriptionLbl, true, 150, "NPR Replication EndPoint Meth"::"Get Dimension Values", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(DimensionsServiceCodeLbl, DefaultDimensionsEndPointIDLbl, DefaultDimensionsPathLbl,
                           DefaultDimensionsEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get Default Dimensions", 0, 1000);

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
                          LocationsEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get Locations", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, ShipmentMethodsEndPointIDLbl, ShipmentMethodsPathLbl,
                          ShipmentMethodsEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get Shipment Methods", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, PaymentTermsEndPointIDLbl, PaymentTermsPathLbl,
                          PaymentTermsEndPointDescriptionLbl, true, 300, "NPR Replication EndPoint Meth"::"Get Payment Terms", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, PaymentMethodsEndPointIDLbl, PaymentMethodsPathLbl,
                          PaymentMethodsEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get Payment Methods", 0, 1000);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, CurrenciesEndPointIDLbl, CurrenciesPathLbl,
                          CurrenciesEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get Currencies", 0, 1000);

    end;
    #endregion

    local procedure GetAPIServiceURL(): Text
    begin
        Exit(GetUrl(ClientType::Api).TrimEnd('/'));
    end;
}

