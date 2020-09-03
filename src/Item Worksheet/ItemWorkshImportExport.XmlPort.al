xmlport 6060040 "NPR Item Worksh. Import/Export"
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created

    Caption = 'Item Worksheet Import/Export';

    schema
    {
        textelement(Root)
        {
            tableelement("Item Worksheet"; "NPR Item Worksheet")
            {
                XmlName = 'ItemWorksheet';
                fieldelement(TemplateName; "Item Worksheet"."Item Template Name")
                {
                }
                fieldelement(Name; "Item Worksheet".Name)
                {
                }
                fieldelement(Description; "Item Worksheet".Description)
                {
                    MinOccurs = Zero;
                }
                fieldelement(VendorNo; "Item Worksheet"."Vendor No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(CurrencyCode; "Item Worksheet"."Currency Code")
                {
                    MinOccurs = Zero;
                }
                tableelement("Item Worksheet Line"; "NPR Item Worksheet Line")
                {
                    LinkFields = "Worksheet Template Name" = FIELD("Item Template Name"), "Worksheet Name" = FIELD(Name);
                    LinkTable = "Item Worksheet";
                    XmlName = 'ItemWorksheetLine';
                    fieldelement(LineNo; "Item Worksheet Line"."Line No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Action; "Item Worksheet Line".Action)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ExistingItemNo; "Item Worksheet Line"."Existing Item No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ItemNo; "Item Worksheet Line"."Item No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VendorItemNo; "Item Worksheet Line"."Vendor Item No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(InternalBarcode; "Item Worksheet Line"."Internal Bar Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VendorNo; "Item Worksheet Line"."Vendor No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Description; "Item Worksheet Line".Description)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CurrencyCode; "Item Worksheet Line"."Currency Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DirectUnitCost; "Item Worksheet Line"."Direct Unit Cost")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UnitPrice; "Item Worksheet Line"."Sales Price")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UseVariant; "Item Worksheet Line"."Use Variant")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BaseUnitOfMeasure; "Item Worksheet Line"."Base Unit of Measure")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(InventoryPostingGroup; "Item Worksheet Line"."Inventory Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CostingMethod; "Item Worksheet Line"."Costing Method")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VendorBarCode; "Item Worksheet Line"."Vendors Bar Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VATBusinessPostingGroup; "Item Worksheet Line"."VAT Bus. Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VATBusinessPostingGroupPrice; "Item Worksheet Line"."VAT Bus. Posting Gr. (Price)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(GenProdPostingGroup; "Item Worksheet Line"."Gen. Prod. Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(NoSeries; "Item Worksheet Line"."No. Series")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(TaxGroupCode; "Item Worksheet Line"."Tax Group Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VATProdPostingGroup; "Item Worksheet Line"."VAT Prod. Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(GlobalDimension1Code; "Item Worksheet Line"."Global Dimension 1 Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(GlobalDimension2Code; "Item Worksheet Line"."Global Dimension 2 Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety1; "Item Worksheet Line"."Variety 1")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety1TableBase; "Item Worksheet Line"."Variety 1 Table (Base)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CreateCopyofVariety1Table; "Item Worksheet Line"."Create Copy of Variety 1 Table")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety1TableNew; "Item Worksheet Line"."Variety 1 Table (New)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety2; "Item Worksheet Line"."Variety 2")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety2TableBase; "Item Worksheet Line"."Variety 2 Table (Base)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CreateCopyofVariety2Table; "Item Worksheet Line"."Create Copy of Variety 2 Table")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety2TableNew; "Item Worksheet Line"."Variety 2 Table (New)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety3; "Item Worksheet Line"."Variety 3")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety3TableBase; "Item Worksheet Line"."Variety 3 Table (Base)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CreateCopyofVariety3Table; "Item Worksheet Line"."Create Copy of Variety 3 Table")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety3TableNew; "Item Worksheet Line"."Variety 3 Table (New)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety4; "Item Worksheet Line"."Variety 4")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety4TableBase; "Item Worksheet Line"."Variety 4 Table (Base)")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CreateCopyofVariety4Table; "Item Worksheet Line"."Create Copy of Variety 4 Table")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety4TableNew; "Item Worksheet Line"."Variety 4 Table (New)")
                    {
                        MinOccurs = Zero;
                    }
                    tableelement("Item Worksheet Variant Line"; "NPR Item Worksh. Variant Line")
                    {
                        LinkFields = "Worksheet Template Name" = FIELD("Worksheet Template Name"), "Worksheet Name" = FIELD("Worksheet Name"), "Worksheet Line No." = FIELD("Line No.");
                        LinkTable = "Item Worksheet Line";
                        MinOccurs = Zero;
                        XmlName = 'ItemWorksheetVariantLine';
                        fieldelement(LineNo; "Item Worksheet Variant Line"."Line No.")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Level; "Item Worksheet Variant Line".Level)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Action; "Item Worksheet Variant Line".Action)
                        {
                        }
                        fieldelement(ExistingVariantCode; "Item Worksheet Variant Line"."Existing Variant Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(VariantCode; "Item Worksheet Variant Line"."Variant Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(InternalBarCode; "Item Worksheet Variant Line"."Internal Bar Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(SalesPrice; "Item Worksheet Variant Line"."Sales Price")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(DirectUnitCost; "Item Worksheet Variant Line"."Direct Unit Cost")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(VendorBarCode; "Item Worksheet Variant Line"."Vendors Bar Code")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety1; "Item Worksheet Variant Line"."Variety 1")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety1Table; "Item Worksheet Variant Line"."Variety 1 Table")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety1Value; "Item Worksheet Variant Line"."Variety 1 Value")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety2; "Item Worksheet Variant Line"."Variety 2")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety2Table; "Item Worksheet Variant Line"."Variety 2 Table")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety2Value; "Item Worksheet Variant Line"."Variety 2 Value")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety3; "Item Worksheet Variant Line"."Variety 3")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety3Table; "Item Worksheet Variant Line"."Variety 3 Table")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety3Value; "Item Worksheet Variant Line"."Variety 3 Value")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety4; "Item Worksheet Variant Line"."Variety 4")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety4Table; "Item Worksheet Variant Line"."Variety 4 Table")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(Variety4Value; "Item Worksheet Variant Line"."Variety 4 Value")
                        {
                            MinOccurs = Zero;
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Item Worksheet Import/Export';

        layout
        {
        }

        actions
        {
        }
    }
}

