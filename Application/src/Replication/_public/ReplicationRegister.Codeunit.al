codeunit 6014608 "NPR Replication Register"
{
    Access = Public;
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
        MagentoServiceCodeLbl: Label 'Magento_NPAPI V1', Locked = true;
        MagentoServiceNameLbl: Label 'Magento - NP Replication API V1.0';

        #region Item related endpoints data
        ItemsEndPointIDLbl: Label 'GetItems', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/items/?$expand=picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/items/?$expand=picture&$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemsEndPointDescriptionLbl: Label 'Gets Items from related company. ', Locked = true;
        ItemCategoriesEndPointIDLbl: Label 'GetItemCategories', Locked = true;
        ItemCategoriesEndPointDescriptionLbl: Label 'Gets Item Categories from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemCategoriesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemCategories/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemCategoriesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemCategories/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VarGroupsEndPointIDLbl: Label 'GetVarietyGroups', Locked = true;
        VarGroupsEndPointDescriptionLbl: Label 'Gets Variety Groups from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VarGroupsPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VarGroupsPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyGroups/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VarietiesEndPointIDLbl: Label 'GetVarieties', Locked = true;
        VarietiesEndPointDescriptionLbl: Label 'Gets Varieties from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VarietiesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varieties/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VarietiesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varieties/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VarietyTablesEndPointIDLbl: Label 'GetVarietyTables', Locked = true;
        VarietyTablesEndPointDescriptionLbl: Label 'Gets Variety Tables from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VarietyTablesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyTables/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VarietyTablesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyTables/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VarietyValuesEndPointIDLbl: Label 'GetVarietyValues', Locked = true;
        VarietyValuesEndPointDescriptionLbl: Label 'Gets Variety Values from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VarietyValuesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VarietyValuesPathLbl: Label '/navipartner/variety/v1.0/companies(%1)/varietyValues/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemVariantsEndPointIDLbl: Label 'GetItemVariants', Locked = true;
        ItemVariantsEndPointDescriptionLbl: Label 'Gets Item Variants from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemVariantsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemVariants/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemVariantsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemVariants/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemReferencesEndPointIDLbl: Label 'GetItemReferences', Locked = true;
        ItemReferencesEndPointDescriptionLbl: Label 'Gets Item References from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemReferencesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemReferences/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemReferencesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemReferences/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemTranslationsEndPointIDLbl: Label 'GetItemTranslations', Locked = true;
        ItemTranslationsEndPointDescriptionLbl: Label 'Gets Item Translations from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemTranslationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemTranslations/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemTranslationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemTranslations/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemSubstitutionsEndPointIDLbl: Label 'GetItemSubstitutions', Locked = true;
        ItemSubstitutionsEndPointDescriptionLbl: Label 'Gets Item Substitutions from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemSubstitutionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemSubstitutions/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemSubstitutionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemSubstitutions/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemAttributesEndPointIDLbl: Label 'GetItemAttributes', Locked = true;
        ItemAttributesEndPointDescriptionLbl: Label 'Gets Item Attributes from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemAttributesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributes/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemAttributesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributes/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemAttributeValuesEndPointIDLbl: Label 'GetItemAttributeValues', Locked = true;
        ItemAttributeValuesEndPointDescriptionLbl: Label 'Gets Item Attribute Values from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemAttributeValuesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemAttributeValuesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeValues/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemAttributeValueMappingsEndPointIDLbl: Label 'GetItemAttributeValueMappings', Locked = true;
        ItemAttributeValueMappingsEndPointDescriptionLbl: Label 'Gets Item Attribute Value Mappings from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemAttributeValueMappingsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeValueMappings/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemAttributeValueMappingsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeValueMappings/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemAttributeTranslationsEndPointIDLbl: Label 'GetItemAttributeTranslations', Locked = true;
        ItemAttributeTranslationsEndPointDescriptionLbl: Label 'Gets Item Attribute Translations from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemAttributeTranslationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeTranslations/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemAttributeTranslationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeTranslations/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemAttributeValueTranslationsEndPointIDLbl: Label 'GetItemAttributeValueTranslations', Locked = true;
        ItemAttributeValueTranslationsEndPointDescriptionLbl: Label 'Gets Item Attribute Value Translations from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemAttributeValueTranslationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeValueTranslations/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemAttributeValueTranslationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemAttributeValueTranslations/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ManufacturersEndPointIDLbl: Label 'GetManufacturers', Locked = true;
        ManufacturersEndPointDescriptionLbl: Label 'Gets Manufacturers from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ManufacturersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/manufacturers/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ManufacturersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/manufacturers/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        UOMEndPointIDLbl: Label 'GetUnitsOfMeasure', Locked = true;
        UOMEndPointDescriptionLbl: Label 'Gets Units Of Measure from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        UOMPathLbl: Label '/navipartner/core/v1.0/companies(%1)/unitsOfMeasure/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        UOMPathLbl: Label '/navipartner/core/v1.0/companies(%1)/unitsOfMeasure/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ItemsUOMEndPointIDLbl: Label 'GetItemsUOM', Locked = true;
        ItemsUOMEndPointDescriptionLbl: Label 'Gets Items Units Of Measure from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ItemsUOMPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemUnitsOfMeasure/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ItemsUOMPathLbl: Label '/navipartner/core/v1.0/companies(%1)/itemUnitsOfMeasure/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        #endregion

        #region Customer endpoints data
        CustomersEndPointIDLbl: Label 'GetCustomers', Locked = true;
        CustomersEndPointDescriptionLbl: Label 'Gets Customers from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        CustomersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customers/?$expand=picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        CustomersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customers/?$expand=picture&$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        SalePriceListsEndPointIDLbl: Label 'GetSalePriceListHeaders', Locked = true;
        SalePriceListsEndPointDescriptionLbl: Label 'Gets Sales Price List Headers from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        SalePriceListsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceLists/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (replicationCounter gt %2)&$orderby=replicationCounter&$schemaVersion=2.0', Locked = true;
#ELSE
        SalePriceListsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceLists/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (systemRowVersion gt %2)&$orderby=systemRowVersion&$schemaVersion=2.0', Locked = true;
#ENDIF
        SalePriceListLinesEndPointIDLbl: Label 'GetSalePriceListLines', Locked = true;
        SalePriceListLinesEndPointDescriptionLbl: Label 'Gets Sales Price List Lines from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        SalePriceListLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceListLines/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (replicationCounter gt %2)&$orderby=replicationCounter&$schemaVersion=2.0', Locked = true;
#ELSE
        SalePriceListLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/priceListLines/?$filter=(priceType eq Microsoft.NAV.priceType''Sale'') and (systemRowVersion gt %2)&$orderby=systemRowVersion&$schemaVersion=2.0', Locked = true;
#ENDIF
        SalespersonsPurchasersEndPointIDLbl: Label 'GetSalespersons/Purchasers', Locked = true;
        SalespersonsPurchasersEndPointDescriptionLbl: Label 'Gets Salespersons/Purchasers from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        SalespersonsPurchasersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/salespersonsPurchasers/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        SalespersonsPurchasersPathLbl: Label '/navipartner/core/v1.0/companies(%1)/salespersonsPurchasers/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        CustPriceGroupsEndPointIDLbl: Label 'GetCustPriceGroups', Locked = true;
        CustPriceGroupsEndPointDescriptionLbl: Label 'Gets Customer Price Groups from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        CustPriceGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerPriceGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        CustPriceGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerPriceGroups/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        CustDiscGroupsEndPointIDLbl: Label 'GetCustDiscountGroups', Locked = true;
        CustDiscGroupsEndPointDescriptionLbl: Label 'Gets Customer Discount Groups from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        CustDiscGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerDiscountGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        CustDiscGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerDiscountGroups/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        CustPostingGroupsEndPointIDLbl: Label 'GetCustPostingGroups', Locked = true;
        CustPostingGroupsEndPointDescriptionLbl: Label 'Gets Customer Posting Groups from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        CustPostingGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerPostGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        CustPostingGroupsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerPostGroups/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        CustBankAccountsEndPointIDLbl: Label 'GetCustBankAccounts', Locked = true;
        CustBankAccountsEndPointDescriptionLbl: Label 'Gets Customer Bank Accounts from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        CustBankAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerBankAccounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        CustBankAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/customerBankAccounts/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        #endregion

        #region Vendor Endpoints data
        VendorsEndPointIDLbl: Label 'GetVendors', Locked = true;
        VendorsEndPointDescriptionLbl: Label 'Gets Vendors from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VendorsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendors/?$expand=picture&$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VendorsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendors/?$expand=picture&$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VendorBankAccEndPointIDLbl: Label 'GetVendorBankAccounts', Locked = true;
        VendorBankAccEndPointDescriptionLbl: Label 'Gets Vendor Bank Accounts from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VendorBankAccPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorBankAccounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VendorBankAccPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorBankAccounts/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VendorPostGrEndPointIDLbl: Label 'GetVendorPostingGroups', Locked = true;
        VendorPostGrEndPointDescriptionLbl: Label 'Gets Vendor Posting Groups from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        VendorPostGrPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorPostGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VendorPostGrPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorPostGroups/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        VendorItemEndPointIDLbl: Label 'GetVendorItems', Locked = true;
        VendorItemEndPointDescriptionLbl: Label 'Gets Vendor Items from related company.', Locked = true;

#IF (BC17 or BC18 or BC19 or BC20)
        VendorItemPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorItems/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        VendorItemPathLbl: Label '/navipartner/core/v1.0/companies(%1)/vendorItems/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        #endregion

        #region NP RETAIL endpoints data
        PeriodDiscountsEndPointIDLbl: Label 'GetPeriodicDiscountHeaders', Locked = true;
        PeriodDiscountsEndPointDescriptionLbl: Label 'Gets Periodic Discount Headers from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        PeriodDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        PeriodDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscounts/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        PeriodDiscountLinesEndPointIDLbl: Label 'GetPeriodicDiscountLines', Locked = true;
        PeriodDiscountLinesEndPointDescriptionLbl: Label 'Gets Periodic Discount Lines from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        PeriodDiscountLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscountLines/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        PeriodDiscountLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/periodDiscountLines/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MixedDiscountsEndPointIDLbl: Label 'GetMixedDiscounts', Locked = true;
        MixedDiscountsEndPointDescriptionLbl: Label 'Gets Mixed Discounts Headers from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MixedDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscounts/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MixedDiscountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscounts/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MixedDiscountsTIEndPointIDLbl: Label 'GetMixedDisTimeIntervals', Locked = true;
        MixedDiscountsTIEndPointDescriptionLbl: Label 'Gets Mixed Discounts Time Intervals from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MixedDiscountsTIPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountTimeIntervals/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MixedDiscountsTIPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountTimeIntervals/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MixedDiscountsLevelsEndPointIDLbl: Label 'GetMixedDisLevels', Locked = true;
        MixedDiscountsLevelsEndPointDescriptionLbl: Label 'Gets Mixed Discounts Levels from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MixedDiscountsLevelsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountLevels/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MixedDiscountsLevelsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountLevels/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MixedDiscountsLinesEndPointIDLbl: Label 'GetMixedDiscLines', Locked = true;
        MixedDiscountsLinesEndPointDescriptionLbl: Label 'Gets Mixed Discounts Lines from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)

        MixedDiscountsLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountLines/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MixedDiscountsLinesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/mixedDiscountLines/?$filter=systemRowVersion gt %2&$orderby=systemRowVersions', Locked = true;
#ENDIF
        #endregion

        #region DIMENSIONS endpoints data
        DimensionsEndPointIDLbl: Label 'GetDimensions', Locked = true;
        DimensionsEndPointDescriptionLbl: Label 'Gets Dimensions from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        DimensionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/dimensions/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        DimensionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/dimensions/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        DimensionValuesEndPointIDLbl: Label 'GetDimensionValues', Locked = true;
        DimensionValuesEndPointDescriptionLbl: Label 'Gets Dimension Values from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        DimensionValuesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/dimensionValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        DimensionValuesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/dimensionValues/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        DefaultDimensionsEndPointIDLbl: Label 'GetDefaultDimensions', Locked = true;
        DefaultDimensionsEndPointDescriptionLbl: Label 'Gets Default Dimensions from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        DefaultDimensionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/defaultDimensions/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        DefaultDimensionsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/defaultDimensions/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        #endregion

        #region MISC endpoints data
        LocationsEndPointIDLbl: Label 'GetLocations', Locked = true;
        LocationsEndPointDescriptionLbl: Label 'Gets Locations from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        LocationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/locations/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        LocationsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/locations/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        ShipmentMethodsEndPointIDLbl: Label 'GetShipmentMethods', Locked = true;
        ShipmentMethodsEndPointDescriptionLbl: Label 'Gets Shipment Methods from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        ShipmentMethodsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/shipmentMethods/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        ShipmentMethodsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/shipmentMethods/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        PaymentTermsEndPointIDLbl: Label 'GetPaymentTerms', Locked = true;
        PaymentTermsEndPointDescriptionLbl: Label 'Gets Payment Terms from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        PaymentTermsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/paymentTerms/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        PaymentTermsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/paymentTerms/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        PaymentMethodsEndPointIDLbl: Label 'GetPaymentMethods', Locked = true;
        PaymentMethodsEndPointDescriptionLbl: Label 'Gets Payment Methods from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        PaymentMethodsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/paymentMethods/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        PaymentMethodsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/paymentMethods/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        CurrenciesEndPointIDLbl: Label 'GetCurrencies', Locked = true;
        CurrenciesEndPointDescriptionLbl: Label 'Gets Currencies from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        CurrenciesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/currencies/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        CurrenciesPathLbl: Label '/navipartner/core/v1.0/companies(%1)/currencies/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        GLAccountsEndPointIDLbl: Label 'GetGLAccounts', Locked = true;
        GLAccountsEndPointDescriptionLbl: Label 'Gets G/L Accounts from related company.', Locked = true;

#IF (BC17 or BC18 or BC19 or BC20)
        GLAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/glAccountsRead/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        GLAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/glAccounts/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        AuxGLAccountsEndPointIDLbl: Label 'GetAuxGLAccounts', Locked = true;
        AuxGLAccountsEndPointDescriptionLbl: Label 'Gets Aux. G/L Accounts from related company.', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        AuxGLAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/glAccountsRead/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        AuxGLAccountsPathLbl: Label '/navipartner/core/v1.0/companies(%1)/auxGLAccounts/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        #endregion

        #region MAGENTO endpoints data
        MagentoWebSitesEndPointIDLbl: Label 'GetMagentoWebSites', Locked = true;
        MagentoWebSitesEndPointDescriptionLbl: Label 'Gets Magento Web Sites from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoWebSitesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoWebsites/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoWebSitesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoWebsites/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoWebSiteLinksEndPointIDLbl: Label 'GetMagentoWebSiteLinks', Locked = true;
        MagentoWebSiteLinksEndPointDescriptionLbl: Label 'Gets Magento Web Site Links from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoWebSiteLinksPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoWebsiteLinks/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoWebSiteLinksPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoWebsiteLinks/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoStoresEndPointIDLbl: Label 'GetMagentoStores', Locked = true;
        MagentoStoresEndPointDescriptionLbl: Label 'Gets Magento Stores from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoStoresPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoStores/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoStoresPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoStores/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF

        MagentoStoreItemsEndPointIDLbl: Label 'GetMagentoStoreItems', Locked = true;
        MagentoStoreItemsEndPointDescriptionLbl: Label 'Gets Magento Store Items from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoStoreItemsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoStoreItems/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoStoreItemsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoStoreItems/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoPicturesEndPointIDLbl: Label 'GetMagentoPictures', Locked = true;
        MagentoPicturesEndPointDescriptionLbl: Label 'Gets Magento Pictures from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoPicturesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoPictures/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoPicturesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoPictures/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoPictureLinksEndPointIDLbl: Label 'GetMagentoPictureLinks', Locked = true;
        MagentoPictureLinksEndPointDescriptionLbl: Label 'Gets Magento Picture Links from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoPictureLinksPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoPictureLinks/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoPictureLinksPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoPictureLinks/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoCategoriesEndPointIDLbl: Label 'GetMagentoCategories', Locked = true;
        MagentoCategoriesEndPointDescriptionLbl: Label 'Gets Magento Categories from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoCategoriesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoCategories/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoCategoriesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoCategories/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoCategoryLinksEndPointIDLbl: Label 'GetMagentoCategoryLinks', Locked = true;
        MagentoCategoryLinksEndPointDescriptionLbl: Label 'Gets Magento Category Links from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoCategoryLinksPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoCategoryLinks/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoCategoryLinksPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoCategoryLinks/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoBrandsEndPointIDLbl: Label 'GetMagentoBrands', Locked = true;
        MagentoBrandsEndPointDescriptionLbl: Label 'Gets Magento Brands from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoBrandsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoBrands/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoBrandsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoBrands/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoAttributesEndPointIDLbl: Label 'GetMagentoAttributes', Locked = true;
        MagentoAttributesEndPointDescriptionLbl: Label 'Gets Magento Attributes from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoAttributesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributes/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoAttributesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributes/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoAttributeLabelsEndPointIDLbl: Label 'GetMagentoAttribLabels', Locked = true;
        MagentoAttributeLabelsEndPointDescriptionLbl: Label 'Gets Magento Attribute Labels from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoAttributeLabelsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributeLabels/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoAttributeLabelsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributeLabels/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoAttributeSetsEndPointIDLbl: Label 'GetMagentoAttribSets', Locked = true;
        MagentoAttributeSetsEndPointDescriptionLbl: Label 'Gets Magento Attribute Sets from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoAttributeSetsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributeSets/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoAttributeSetsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributeSets/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoAttributeSetValuesEndPointIDLbl: Label 'GetMagentoAttrSetValues', Locked = true;
        MagentoAttributeSetValuesEndPointDescriptionLbl: Label 'Gets Magento Attribute Set Values from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoAttributeSetValuesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributeSetValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoAttributeSetValuesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoAttributeSetValues/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoItemAttributesEndPointIDLbl: Label 'GetMagentoItemAttributes', Locked = true;
        MagentoItemAttributesEndPointDescriptionLbl: Label 'Gets Magento Item Attributes from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoItemAttributesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoItemAttributes/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoItemAttributesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoItemAttributes/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoItemAttributeValuesEndPointIDLbl: Label 'GetMagentoItemAttrVal', Locked = true;
        MagentoItemAttributeValuesEndPointDescriptionLbl: Label 'Gets Magento Item Attribute Values from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoItemAttributeValuesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoItemAttributeValues/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoItemAttributeValuesPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoItemAttributeValues/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
        MagentoDisplayGroupsEndPointIDLbl: Label 'GetMagentoDisplayGrp', Locked = true;
        MagentoDisplayGroupsEndPointDescriptionLbl: Label 'Gets Magento Display Groups from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoDisplayGroupsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoDisplayGroups/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoDisplayGroupsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoDisplayGroups/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF

        MagentoProductRelationsIDLbl: Label 'GetMagentoProductRel', Locked = true;
        MagentoProductRelationsDescriptionLbl: Label 'Gets Magento Product Relations from related company. ', Locked = true;
#IF (BC17 or BC18 or BC19 or BC20)
        MagentoProductRelationsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoProductRelations/?$filter=replicationCounter gt %2&$orderby=replicationCounter', Locked = true;
#ELSE
        MagentoProductRelationsPathLbl: Label '/navipartner/magento/v1.0/companies(%1)/magentoProductRelations/?$filter=systemRowVersion gt %2&$orderby=systemRowVersion', Locked = true;
#ENDIF
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
        BaseURLAPI: Text[250];
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

        // MAGENTO
        sender.RegisterService(MagentoServiceCodeLbl,
            BaseURLAPI, MagentoServiceNameLbl, false, "NPR API Auth. Type"::Basic, Tenant);
        RegisterMagentoServiceEndPoints();
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

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemTranslationsEndPointIDLbl, ItemTranslationsPathLbl,
                    ItemTranslationsEndPointDescriptionLbl, true, 700, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"Item Translation", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemSubstitutionsEndPointIDLbl, ItemSubstitutionsPathLbl,
                    ItemSubstitutionsEndPointDescriptionLbl, true, 800, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"Item Substitution", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ManufacturersEndPointIDLbl, ManufacturersPathLbl,
                    ManufacturersEndPointDescriptionLbl, true, 900, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::Manufacturer, false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemAttributesEndPointIDLbl, ItemAttributesPathLbl,
                    ItemAttributesEndPointDescriptionLbl, true, 1000, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    10000, Database::"Item Attribute", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemAttributeValuesEndPointIDLbl, ItemAttributeValuesPathLbl,
                   ItemAttributeValuesEndPointDescriptionLbl, true, 1010, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                   10000, Database::"Item Attribute Value", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemAttributeValueMappingsEndPointIDLbl, ItemAttributeValueMappingsPathLbl,
                   ItemAttributeValueMappingsEndPointDescriptionLbl, true, 1020, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                   10000, Database::"Item Attribute Value Mapping", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemAttributeTranslationsEndPointIDLbl, ItemAttributeTranslationsPathLbl,
                   ItemAttributeTranslationsEndPointDescriptionLbl, true, 1030, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                   10000, Database::"Item Attribute Translation", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(ItemsServiceCodeLbl, ItemAttributeValueTranslationsEndPointIDLbl, ItemAttributeValueTranslationsPathLbl,
                   ItemAttributeValueTranslationsEndPointDescriptionLbl, true, 1040, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                   10000, Database::"Item Attr. Value Translation", false, false);
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

#IF (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("NPR Blocked"), 'blocked', 0, false, false);
#ELSE
        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(Blocked), 'blocked', 0, false, false);
#ENDIF
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemTranslationSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Translation";
    begin
        if sender."Table ID" <> Database::"Item Translation" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemSubstitutionSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Substitution";
    begin
        if sender."Table ID" <> Database::"Item Substitution" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Quantity Avail. on Shpt. Date"), 'quantityAvailableOnShipmentDate', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterManufacturerSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Manufacturer";
    begin
        if sender."Table ID" <> Database::Manufacturer then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemAttributeSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Attribute";
    begin
        if sender."Table ID" <> Database::"Item Attribute" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("ID"), 'attributeId', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemAttributeValueSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Attribute Value";
    begin
        if sender."Table ID" <> Database::"Item Attribute Value" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Attribute ID"), 'attributeId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo(ID), 'attributeValueId', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemAttributeValueMappingSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Attribute Value Mapping";
    begin
        if sender."Table ID" <> Database::"Item Attribute Value Mapping" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Table ID"), 'tableId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("No."), 'no', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
         Rec.FieldNo("Item Attribute ID"), 'itemAttributeId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
         Rec.FieldNo("Item Attribute Value ID"), 'itemAttributeValueId', 0, false, false);
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemAttributeTranslationSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Attribute Translation";
    begin
        if sender."Table ID" <> Database::"Item Attribute Translation" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Attribute ID"), 'attributeId', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterItemAttributeValueTranslationSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Attr. Value Translation";
    begin
        if sender."Table ID" <> Database::"Item Attr. Value Translation" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
           Rec.FieldNo("Attribute ID"), 'attributeId', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo(ID), 'attributeValueId', 0, false, false);
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

        ServiceEndPoint.RegisterServiceEndPoint(VendServiceCodeLbl, VendorItemEndPointIDLbl, VendorItemPathLbl,
                    VendorItemEndPointDescriptionLbl, true, 700, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                    1000, Database::"Item Vendor", false, false);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterVendorItemSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "Item Vendor";
    begin
        if sender."Table ID" <> Database::"Item Vendor" then
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
        ServiceSetup.SetRange("API Version", MiscServiceCodeLbl);
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

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, GLAccountsEndPointIDLbl, GLAccountsPathLbl,
                            GLAccountsEndPointDescriptionLbl, true, 700, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"G/L Account", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MiscServiceCodeLbl, AuxGLAccountsEndPointIDLbl, AuxGLAccountsPathLbl,
                           AuxGLAccountsEndPointDescriptionLbl, true, 701, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                           1000, Database::"NPR Aux. G/L Account", false, false);
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

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterGLAccountSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "G/L Account";
    begin
        if sender."Table ID" <> Database::"G/L Account" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Name), 'displayName', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Last Modified Date Time"), 'lastModifiedDateTime2', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterAuxGLAccountSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Aux. G/L Account";
    begin
        if sender."Table ID" <> Database::"NPR Aux. G/L Account" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    local procedure RegisterMagentoServiceEndPoints()
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ServiceEndPoint: Record "NPR Replication Endpoint";
    begin
        ServiceSetup.SetRange("API Version", MagentoServiceCodeLbl);
        if ServiceSetup.IsEmpty() then
            exit;

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoWebsitesEndPointIDLbl, MagentoWebsitesPathLbl,
                            MagentoWebsitesEndPointDescriptionLbl, true, 100, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Magento Website", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoWebsiteLinksEndPointIDLbl, MagentoWebsiteLinksPathLbl,
                            MagentoWebsiteLinksEndPointDescriptionLbl, true, 200, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Magento Website Link", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoStoresEndPointIDLbl, MagentoStoresPathLbl,
                            MagentoStoresEndPointDescriptionLbl, true, 300, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                            1000, Database::"NPR Magento Store", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoStoreItemsEndPointIDLbl, MagentoStoreItemsPathLbl,
                           MagentoStoreItemsEndPointDescriptionLbl, true, 310, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                           1000, Database::"NPR Magento Store Item", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoPicturesEndPointIDLbl, MagentoPicturesPathLbl,
                           MagentoPicturesEndPointDescriptionLbl, true, 400, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                           1000, Database::"NPR Magento Picture", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoPictureLinksEndPointIDLbl, MagentoPictureLinksPathLbl,
                           MagentoPictureLinksEndPointDescriptionLbl, true, 500, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                           1000, Database::"NPR Magento Picture Link", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoCategoriesEndPointIDLbl, MagentoCategoriesPathLbl,
                          MagentoCategoriesEndPointDescriptionLbl, true, 600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                          1000, Database::"NPR Magento Category", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoCategoryLinksEndPointIDLbl, MagentoCategoryLinksPathLbl,
                          MagentoCategoryLinksEndPointDescriptionLbl, true, 700, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                          1000, Database::"NPR Magento Category Link", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoBrandsEndPointIDLbl, MagentoBrandsPathLbl,
                          MagentoBrandsEndPointDescriptionLbl, true, 800, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                          1000, Database::"NPR Magento Brand", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoAttributesEndPointIDLbl, MagentoAttributesPathLbl,
                          MagentoAttributesEndPointDescriptionLbl, true, 900, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                          1000, Database::"NPR Magento Attribute", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoAttributeLabelsEndPointIDLbl, MagentoAttributeLabelsPathLbl,
                          MagentoAttributeLabelsEndPointDescriptionLbl, true, 1000, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                          1000, Database::"NPR Magento Attr. Label", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoAttributeSetsEndPointIDLbl, MagentoAttributeSetsPathLbl,
                         MagentoAttributeSetsEndPointDescriptionLbl, true, 1100, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                         1000, Database::"NPR Magento Attribute Set", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoAttributeSetValuesEndPointIDLbl, MagentoAttributeSetValuesPathLbl,
                         MagentoAttributeSetValuesEndPointDescriptionLbl, true, 1200, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                         1000, Database::"NPR Magento Attr. Set Value", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoItemAttributesEndPointIDLbl, MagentoItemAttributesPathLbl,
                         MagentoItemAttributesEndPointDescriptionLbl, true, 1300, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                         1000, Database::"NPR Magento Item Attr.", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoItemAttributeValuesEndPointIDLbl, MagentoItemAttributeValuesPathLbl,
                         MagentoItemAttributeValuesEndPointDescriptionLbl, true, 1400, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                         1000, Database::"NPR Magento Item Attr. Value", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoDisplayGroupsEndPointIDLbl, MagentoDisplayGroupsPathLbl,
                        MagentoDisplayGroupsEndPointDescriptionLbl, true, 1500, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                        1000, Database::"NPR Magento Display Group", false, false);

        ServiceEndPoint.RegisterServiceEndPoint(MagentoServiceCodeLbl, MagentoProductRelationsIDLbl, MagentoProductRelationsPathLbl,
                        MagentoProductRelationsDescriptionLbl, true, 1600, "NPR Replication EndPoint Meth"::"Get BC Generic Data", 0,
                        1000, Database::"NPR Magento Product Relation", false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoWebsiteSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Website";
    begin
        if sender."Table ID" <> Database::"NPR Magento Website" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;


    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoWebsiteLinkSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Website Link";
    begin
        if sender."Table ID" <> Database::"NPR Magento Website Link" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoStoreSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Store";
    begin
        if sender."Table ID" <> Database::"NPR Magento Store" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoStoreItemsSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Store Item";
    begin
        if sender."Table ID" <> Database::"NPR Magento Store Item" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo("Webshop Description"), 'webshopDescription@odata.mediaReadLink', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
         Rec.FieldNo("Webshop Short Desc."), 'webshopShortDesc@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoPictureSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Picture";
    begin
        if sender."Table ID" <> Database::"NPR Magento Picture" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Size (kb)"), 'sizeKb', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
          Rec.FieldNo(Image), 'image@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoPictureLinkSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Picture Link";
    begin
        if sender."Table ID" <> Database::"NPR Magento Picture Link" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoCategorySpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Category";
    begin
        if sender."Table ID" <> Database::"NPR Magento Category" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id1', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Description), 'description@odata.mediaReadLink', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Short Description"), 'shortDescription@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoCategoryLinkSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Category Link";
    begin
        if sender."Table ID" <> Database::"NPR Magento Category Link" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoBrandSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Brand";
    begin
        if sender."Table ID" <> Database::"NPR Magento Brand" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id1', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(Description), 'description@odata.mediaReadLink', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Short Description"), 'shortDescription@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoAttributeSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Attribute";
    begin
        if sender."Table ID" <> Database::"NPR Magento Attribute" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoAttributeLabelSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Attr. Label";
    begin
        if sender."Table ID" <> Database::"NPR Magento Attr. Label" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Text Field"), 'textField@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoAttributeSetSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Attribute Set";
    begin
        if sender."Table ID" <> Database::"NPR Magento Attribute Set" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoAttributeSetValSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Attr. Set Value";
    begin
        if sender."Table ID" <> Database::"NPR Magento Attr. Set Value" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoItemAttributeSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Item Attr.";
    begin
        if sender."Table ID" <> Database::"NPR Magento Item Attr." then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoItemAttributeValSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Item Attr. Value";
    begin
        if sender."Table ID" <> Database::"NPR Magento Item Attr. Value" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo("Long Value"), 'longValue@odata.mediaReadLink', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoDisplayGroupSpecialFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Display Group";
    begin
        if sender."Table ID" <> Database::"NPR Magento Display Group" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Endpoint", 'OnRegisterServiceEndPoint', '', true, true)]
    local procedure RegisterMagentoProductRelationFieldMappings(sender: Record "NPR Replication Endpoint")
    var
        Mapping: Record "NPR Rep. Special Field Mapping";
        Rec: Record "NPR Magento Product Relation";
    begin
        if sender."Table ID" <> Database::"NPR Magento Product Relation" then
            exit;

        Mapping.RegisterSpecialFieldMapping(sender."Service Code", sender."EndPoint ID", sender."Table ID",
            Rec.FieldNo(SystemId), 'id', 0, false, false);
    end;
    #endregion

    [EventSubscriber(ObjectType::Table, Database::"NPR Replication Service Setup", 'OnAfterValidateEvent', 'Error Notify Email Address', true, true)]
    local procedure CreateDefaultEmailTemplate()
    var
        EmailTemplate: Record "NPR E-mail Template Header";
        EmailTemplateLine: Record "NPR E-mail Templ. Line";
        Lines: List of [Text[250]];
        i: Integer;
        ErrorLogUrlTxt: Text[250];
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
        ErrorLogUrlTxt := 'Error Log URL: ';
        ErrorLogUrlTxt += CopyStr(System.GetUrl(ClientType::Web, CompanyName(), ObjectType::Page, Page::"NPR Replication Error Log"),
         1, MaxStrLen(ErrorLogUrlTxt) - StrLen(ErrorLogUrlTxt));
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

        if ReplicationSetup.Findset(true) then
            repeat
                ReplicationSetup."Error Notify Email Address" := '';
                ReplicationSetup.Modify();
            until ReplicationSetup.Next() = 0;
    end;

    local procedure GetAPIServiceURL() BaseURL: Text[250]
    begin
        BaseURL := Copystr(GetUrl(ClientType::Api).TrimEnd('/'), 1, MaxStrLen(BaseURL));
        IF BaseURL.ToLower().Contains('?tenant=') then
            BaseUrl := CopyStr(BaseURL.Remove(BaseURL.ToLower().IndexOf('?tenant='), StrLen(BaseURL) - BaseURL.ToLower().IndexOf('?tenant=') + 1).TrimEnd('/'),
             1, MaxStrLen(BaseURL)); // remove tenant
    end;

    local procedure GetTenant() Tenant: Text[50]
    var
        BaseURL: Text;
    begin
        BaseURL := GetUrl(ClientType::Api);
        IF BaseURL.ToLower().Contains('?tenant=') then
            Tenant := CopyStr(BaseURL.Substring(BaseURL.ToLower().IndexOf('?tenant='), StrLen(BaseURL) - BaseURL.ToLower().IndexOf('?tenant=') + 1).Replace('?tenant=', ''),
             1, MaxStrLen(Tenant))
        Else
            tenant := 'DEFAULT';
    end;

    [BusinessEvent(false)]
#pragma warning disable AA0150
    procedure OnUpdateCustomEndpoints(var Handled: Boolean)
#pragma warning restore
    begin
        // code from customer app subscribes to this event to update endpoints Path: for custom fields we need to have custom api page in customer extension and use that api instead of the standard one.
    end;

}