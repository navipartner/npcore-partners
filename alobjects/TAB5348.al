tableextension 50041 tableextension50041 extends "CRM Product" 
{
    // Dynamics CRM Version: 7.1.0.2040
    // NPR5.43/ZESO/20180618  CASE 313117  Adding new fields for CRM Integration WARNING: Dont remove it (Used in Mapping table Integration Field Mapping - Is not used directly in code anywhere)
    Caption = 'CRM Product';
    fields
    {
        modify(ProductId)
        {
            Caption = 'Product';
        }
        modify(DefaultUoMScheduleId)
        {
            Caption = 'Unit Group';
        }
        modify(OrganizationId)
        {
            Caption = 'Organization';
        }
        modify(Name)
        {
            Caption = 'Name';
        }
        modify(DefaultUoMId)
        {
            Caption = 'Default Unit';
        }
        modify(PriceLevelId)
        {
            Caption = 'Default Price List';
        }
        modify(Description)
        {
            Caption = 'Description';
        }
        modify(ProductTypeCode)
        {
            Caption = 'Product Type';
            OptionCaption = 'Sales Inventory,Miscellaneous Charges,Services,Flat Fees';
        }
        modify(ProductUrl)
        {
            Caption = 'URL';
        }
        modify(Price)
        {
            Caption = 'List Price';
        }
        modify(IsKit)
        {
            Caption = 'Is Kit';
        }
        modify(ProductNumber)
        {
            Caption = 'Product ID';
        }
        modify(Size)
        {
            Caption = 'Size';
        }
        modify(CurrentCost)
        {
            Caption = 'Current Cost';
        }
        modify(StockVolume)
        {
            Caption = 'Stock Volume';
        }
        modify(StandardCost)
        {
            Caption = 'Standard Cost';
        }
        modify(StockWeight)
        {
            Caption = 'Stock Weight';
        }
        modify(QuantityDecimal)
        {
            Caption = 'Decimals Supported';
        }
        modify(QuantityOnHand)
        {
            Caption = 'Quantity On Hand';
        }
        modify(IsStockItem)
        {
            Caption = 'Stock Item';
        }
        modify(SupplierName)
        {
            Caption = 'Supplier Name';
        }
        modify(VendorName)
        {
            Caption = 'Vendor';
        }
        modify(VendorPartNumber)
        {
            Caption = 'Vendor Name';
        }
        modify(CreatedOn)
        {
            Caption = 'Created On';
        }
        modify(ModifiedOn)
        {
            Caption = 'Modified On';
        }
        modify(CreatedBy)
        {
            Caption = 'Created By';
        }
        modify(StateCode)
        {
            Caption = 'Status';
            OptionCaption = 'Active,Retired,Draft,Under Revision';
        }
        modify(ModifiedBy)
        {
            Caption = 'Modified By';
        }
        modify(StatusCode)
        {
            Caption = 'Status Reason';
            OptionCaption = ' ,Active,Retired,Draft,Under Revision';
        }
        modify(VersionNumber)
        {
            Caption = 'Version Number';
        }
        modify(DefaultUoMIdName)
        {
            Caption = 'DefaultUoMIdName';
        }
        modify(DefaultUoMScheduleIdName)
        {
            Caption = 'DefaultUoMScheduleIdName';
        }
        modify(PriceLevelIdName)
        {
            Caption = 'PriceLevelIdName';
        }
        modify(CreatedByName)
        {
            Caption = 'CreatedByName';
        }
        modify(ModifiedByName)
        {
            Caption = 'ModifiedByName';
        }
        modify(OrganizationIdName)
        {
            Caption = 'OrganizationIdName';
        }
        modify(OverriddenCreatedOn)
        {
            Caption = 'Record Created On';
        }
        modify(TransactionCurrencyId)
        {
            Caption = 'Currency';
        }
        modify(ExchangeRate)
        {
            Caption = 'Exchange Rate';
        }
        modify(UTCConversionTimeZoneCode)
        {
            Caption = 'UTC Conversion Time Zone Code';
        }
        modify(ImportSequenceNumber)
        {
            Caption = 'Import Sequence Number';
        }
        modify(TimeZoneRuleVersionNumber)
        {
            Caption = 'Time Zone Rule Version Number';
        }
        modify(TransactionCurrencyIdName)
        {
            Caption = 'TransactionCurrencyIdName';
        }
        modify("CurrentCost_Base")
        {
            Caption = 'Current Cost (Base)';
        }
        modify("Price_Base")
        {
            Caption = 'List Price (Base)';
        }
        modify("StandardCost_Base")
        {
            Caption = 'Standard Cost (Base)';
        }
        modify(CreatedOnBehalfBy)
        {
            Caption = 'Created By (Delegate)';
        }
        modify(CreatedOnBehalfByName)
        {
            Caption = 'CreatedOnBehalfByName';
        }
        modify(ModifiedOnBehalfBy)
        {
            Caption = 'Modified By (Delegate)';
        }
        modify(ModifiedOnBehalfByName)
        {
            Caption = 'ModifiedOnBehalfByName';
        }
        modify(EntityImageId)
        {
            Caption = 'Entity Image Id';
        }
        modify(ProcessId)
        {
            Caption = 'Process';
        }
        modify(StageId)
        {
            Caption = 'Process Stage';
        }
        modify(ParentProductId)
        {
            Caption = 'Parent';
        }
        modify(ParentProductIdName)
        {
            Caption = 'ParentProductIdName';
        }
        modify(ProductStructure)
        {
            Caption = 'Product Structure';
            OptionCaption = 'Product,Product Family,Product Bundle';
        }
        modify(VendorID)
        {
            Caption = 'Vendor ID';
        }
        modify(TraversedPath)
        {
            Caption = 'Traversed Path';
        }
        modify(ValidFromDate)
        {
            Caption = 'Valid From';
        }
        modify(ValidToDate)
        {
            Caption = 'Valid To';
        }
        modify(HierarchyPath)
        {
            Caption = 'Hierarchy Path';
        }
        field(6014401;nav_no;Text[20])
        {
            Caption = 'No.';
            ExternalName = 'nav_no';
            ExternalType = 'String';
        }
        field(6014402;nav_description;Text[50])
        {
            Caption = 'Description';
            ExternalName = 'nav_description';
            ExternalType = 'String';
        }
        field(6014403;nav_description2;Text[50])
        {
            Caption = 'Description 2';
            ExternalName = 'nav_description2';
            ExternalType = 'String';
        }
        field(6014404;nav_itemdiscgroup;Text[20])
        {
            Caption = 'Item Disc. Group';
            ExternalName = 'nav_itemdiscgroup';
            ExternalType = 'String';
        }
        field(6014405;nav_unitprice;Decimal)
        {
            Caption = 'Unit Price';
            ExternalName = 'nav_unitprice';
            ExternalType = 'Decimal';
        }
        field(6014406;nav_inventory;Decimal)
        {
            Caption = 'Inventory';
            ExternalName = 'nav_inventory';
            ExternalType = 'Decimal';
        }
        field(6014407;nav_netinvoicedqty;Decimal)
        {
            Caption = 'Net Invoiced Qty.';
            ExternalName = 'nav_netinvoicedqty';
            ExternalType = 'Decimal';
        }
        field(6014408;nav_netchange;Decimal)
        {
            Caption = 'Net Change';
            ExternalName = 'nav_netchange';
            ExternalType = 'Decimal';
        }
        field(6014409;nav_salesqty;Decimal)
        {
            Caption = 'Sales (Qty.)';
            ExternalName = 'nav_salesqty';
            ExternalType = 'Decimal';
        }
        field(6014410;nav_positiveadjmtqty;Decimal)
        {
            Caption = 'Positive Adjmt. (Qty.)';
            ExternalName = 'nav_positiveadjmtqty';
            ExternalType = 'Decimal';
        }
        field(6014411;nav_crossvarietyno;Option)
        {
            Caption = 'Cross Variety No';
            ExternalName = 'nav_crossvarietyno';
            ExternalType = 'Picklist';
            InitValue = " ";
            OptionCaption = ' ,Variety1,Variety2,Variety3,Variety4';
            OptionOrdinalValues = -1,808630000,808630001,808630002,808630003;
            OptionMembers = " ",Variety1,Variety2,Variety3,Variety4;
        }
        field(6014412;nav_genprodpostinggroup;Text[10])
        {
            Caption = 'Gen. Prod. Posting Group';
            ExternalName = 'nav_genprodpostinggroup';
            ExternalType = 'String';
        }
        field(6014413;nav_itemgroup;Text[10])
        {
            Caption = 'Item Group';
            ExternalName = 'nav_itemgroup';
            ExternalType = 'String';
        }
        field(6014414;nav_itemstatus;Text[10])
        {
            Caption = 'Item Status';
            ExternalName = 'nav_itemstatus';
            ExternalType = 'String';
        }
        field(6014415;nav_magentoname;Text[250])
        {
            Caption = 'Magento Name';
            ExternalName = 'nav_magentoname';
            ExternalType = 'String';
        }
        field(6014416;nav_magentostatus;Option)
        {
            Caption = 'Magento Status';
            ExternalName = 'nav_magentostatus';
            ExternalType = 'Picklist';
            InitValue = " ";
            OptionCaption = ' ,Active,Inactive';
            OptionOrdinalValues = -1,808630000,808630001;
            OptionMembers = " ",Active,Inactive;
        }
        field(6014417;nav_salesunitofmeasure;Text[10])
        {
            Caption = 'Sales Unit of Measure';
            ExternalName = 'nav_salesunitofmeasure';
            ExternalType = 'String';
        }
        field(6014418;nav_type;Option)
        {
            Caption = 'Type';
            ExternalName = 'nav_type';
            ExternalType = 'Picklist';
            InitValue = " ";
            OptionCaption = ' ,Inventory,Service';
            OptionOrdinalValues = -1,808630000,808630001;
            OptionMembers = " ",Inventory,Service;
        }
        field(6014419;nav_vatbuspostinggrprice;Text[10])
        {
            Caption = 'VAT Bus. Posting Gr. (Price)';
            ExternalName = 'nav_vatbuspostinggrprice';
            ExternalType = 'String';
        }
        field(6014420;nav_vatprodpostinggroup;Text[10])
        {
            Caption = 'VAT Prod. Posting Group';
            ExternalName = 'nav_vatprodpostinggroup';
            ExternalType = 'String';
        }
        field(6014421;nav_baseunitofmeasure;Text[10])
        {
            Caption = 'Base Unit of Measure';
            ExternalName = 'nav_baseunitofmeasure';
            ExternalType = 'String';
        }
    }
}

