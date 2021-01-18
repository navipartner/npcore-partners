xmlport 6060041 "NPR Item Worksh. Line Web Imp."
{
    Caption = 'Item Worksheet Line Web Import';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/InsertItemWorksheetLine';
    UseDefaultNamespace = true;
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;

    schema
    {
        textelement(itemworksheetlines)
        {
            textelement(InsertItemWorksheetLine)
            {
                textattribute(messageid)
                {
                    Occurrence = Optional;
                }
                textelement(importoptiontxt)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(combinevarietiestxt)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(actionifvariantunknowntxt)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(actionifvarietyunknowtxt)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                tableelement("Item Worksheet Line"; "NPR Item Worksheet Line")
                {
                    MinOccurs = Zero;
                    UseTemporary = true;
                    XmlName = 'ItemWorksheetLine';
                    fieldelement(ItemNo; "Item Worksheet Line"."Item No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Description; "Item Worksheet Line".Description)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Description2; "Item Worksheet Line"."Description 2")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ItemCategory; "Item Worksheet Line"."Item Category Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ProductGroup; "Item Worksheet Line"."Product Group Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VendorItemNo; "Item Worksheet Line"."Vendor Item No.")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(VATRegNo)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(TariffNo)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UnitPrice; "Item Worksheet Line"."Sales Price")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SalesPriceCurrencyCode; "Item Worksheet Line"."Sales Price Currency Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DirectUnitCost; "Item Worksheet Line"."Direct Unit Cost")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PurchasePriceCurrencyCode; "Item Worksheet Line"."Purchase Price Currency Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VendorNo; "Item Worksheet Line"."Vendor No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ItemGroup; "Item Worksheet Line"."Item Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VarietyGroup; "Item Worksheet Line"."Variety Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety1; "Item Worksheet Line"."Variety 1")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety2; "Item Worksheet Line"."Variety 2")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety3; "Item Worksheet Line"."Variety 3")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Variety4; "Item Worksheet Line"."Variety 4")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(RecommendedRetailPrice; "Item Worksheet Line"."Recommended Retail Price")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(InternalBarcode; "Item Worksheet Line"."Internal Bar Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(VendorsBarcode; "Item Worksheet Line"."Vendors Bar Code")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute1)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute2)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute3)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute4)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute5)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute6)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute7)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute8)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute9)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attribute10)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Attributes)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        tableelement(tempattributelookupvalue; "NPR Attribute Lookup Value")
                        {
                            MinOccurs = Zero;
                            UseTemporary = true;
                            XmlName = 'Attribute';
                            fieldattribute(Code; TempAttributeLookupValue."Attribute Code")
                            {
                            }
                            fieldelement(Value; TempAttributeLookupValue."Attribute Value Name")
                            {
                            }
                        }
                    }
                    fieldelement(No2; "Item Worksheet Line"."No. 2")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Type; "Item Worksheet Line".Type)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ItemDiscGroup; "Item Worksheet Line"."Item Disc. Group")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(AllowInvoiceDisc)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Allow Invoice Disc." := FindBooleanOptionValue(AllowInvoiceDisc);
                        end;
                    }
                    fieldelement(StatisticsGroup; "Item Worksheet Line"."Statistics Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CommissionGroup; "Item Worksheet Line"."Commission Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PriceProfitCalculation; "Item Worksheet Line"."Price/Profit Calculation")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Profit; "Item Worksheet Line"."Profit %")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(LeadTimeCalculation; "Item Worksheet Line"."Lead Time Calculation")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ReorderPoint; "Item Worksheet Line"."Reorder Point")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MaximumInventory; "Item Worksheet Line"."Maximum Inventory")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ReorderQuantity; "Item Worksheet Line"."Reorder Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UnitListPrice; "Item Worksheet Line"."Unit List Price")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DutyDue; "Item Worksheet Line"."Duty Due %")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DutyCode; "Item Worksheet Line"."Duty Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UnitsperParcel; "Item Worksheet Line"."Units per Parcel")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(UnitVolume; "Item Worksheet Line"."Unit Volume")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Durability; "Item Worksheet Line".Durability)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(FreightType; "Item Worksheet Line"."Freight Type")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DutyUnitConversion; "Item Worksheet Line"."Tariff No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CountryRegionPurchasedCode; "Item Worksheet Line"."Country/Region Purchased Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BudgetQuantity; "Item Worksheet Line"."Budget Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BudgetedAmount; "Item Worksheet Line"."Budgeted Amount")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BudgetProfit; "Item Worksheet Line"."Budget Profit")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Blocked)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line".Blocked := FindBooleanOptionValue(Blocked);
                        end;
                    }
                    textelement(PriceIncludesVAT)
                    {
                        MinOccurs = Zero;

                        trigger OnBeforePassVariable()
                        begin
                            "Item Worksheet Line"."Price Includes VAT" := FindBooleanOptionValue(PriceIncludesVAT);
                        end;
                    }
                    fieldelement(CountryRegionofOriginCode; "Item Worksheet Line"."VAT Bus. Posting Group")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(AutomaticExtTexts)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Automatic Ext. Texts" := FindBooleanOptionValue(AutomaticExtTexts);
                        end;
                    }
                    fieldelement(Reserve; "Item Worksheet Line".Reserve)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(StockoutWarning; "Item Worksheet Line"."Stockout Warning")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PreventNegativeInventory; "Item Worksheet Line"."Prevent Negative Inventory")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(AssemblyPolicy; "Item Worksheet Line"."Assembly Policy")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(GTIN; "Item Worksheet Line".GTIN)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(LotSize; "Item Worksheet Line"."Lot Size")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SerialNos; "Item Worksheet Line"."Serial Nos.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Scrap; "Item Worksheet Line"."Scrap %")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(InventoryValueZero)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Inventory Value Zero" := FindBooleanOptionValue(InventoryValueZero);
                        end;
                    }
                    fieldelement(DiscreteOrderQuantity; "Item Worksheet Line"."Discrete Order Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MinimumOrderQuantity; "Item Worksheet Line"."Minimum Order Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MaximumOrderQuantity; "Item Worksheet Line"."Maximum Order Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SafetyStockQuantity; "Item Worksheet Line"."Safety Stock Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(OrderMultiple; "Item Worksheet Line"."Order Multiple")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SafetyLeadTime; "Item Worksheet Line"."Safety Lead Time")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(FlushingMethod; "Item Worksheet Line"."Flushing Method")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ReplenishmentSystem; "Item Worksheet Line"."Replenishment System")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ReorderingPolicy; "Item Worksheet Line"."Reordering Policy")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(IncludeInventory)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Include Inventory" := FindBooleanOptionValue(IncludeInventory);
                        end;
                    }
                    fieldelement(ManufacturingPolicy; "Item Worksheet Line"."Manufacturing Policy")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ReschedulingPeriod; "Item Worksheet Line"."Rescheduling Period")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(LotAccumulationPeriod; "Item Worksheet Line"."Lot Accumulation Period")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DampenerPeriod; "Item Worksheet Line"."Dampener Period")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(DampenerQuantity; "Item Worksheet Line"."Dampener Quantity")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(OverflowLevel; "Item Worksheet Line"."Overflow Level")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ServiceItemGroup; "Item Worksheet Line"."Service Item Group")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ItemTrackingCode; "Item Worksheet Line"."Item Tracking Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(LotNos; "Item Worksheet Line"."Lot Nos.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ExpirationCalculation; "Item Worksheet Line"."Expiration Calculation")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SpecialEquipmentCode; "Item Worksheet Line"."Special Equipment Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PutawayTemplateCode; "Item Worksheet Line"."Put-away Template Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PutawayUnitofMeasureCode; "Item Worksheet Line"."Put-away Unit of Measure Code")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PhysInvtCountingPeriodCod; "Item Worksheet Line"."Phys Invt Counting Period Code")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(UseCrossDocking)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Use Cross-Docking" := FindBooleanOptionValue(UseCrossDocking);
                        end;
                    }
                    textelement(Groupsale)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Group sale" := FindBooleanOptionValue(Groupsale);
                        end;
                    }
                    textelement(Properties)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ItemSalesPrize)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ProgramNo)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Season; "Item Worksheet Line".Season)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Assortment)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(LabelBarcode; "Item Worksheet Line"."Label Barcode")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Auto)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Outofstock)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Printquantity)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Labelsperitem)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ExplodeBOMauto)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Explode BOM auto" := FindBooleanOptionValue(ExplodeBOMauto);
                        end;
                    }
                    textelement(Guaranteevoucher)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Guarantee voucher" := FindBooleanOptionValue(Guaranteevoucher);
                        end;
                    }
                    textelement(ISBN)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Cannoteditunitprice)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Cannot edit unit price" := FindBooleanOptionValue(Cannoteditunitprice);
                        end;
                    }
                    textelement(LabelDate)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Openquarryunitcost)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Secondhandnumber; "Item Worksheet Line"."Second-hand number")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Condition; "Item Worksheet Line".Condition)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Secondhand)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Second-hand" := FindBooleanOptionValue(Secondhand);
                        end;
                    }
                    fieldelement(GuaranteeIndex; "Item Worksheet Line"."Guarantee Index")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(HandOutItemNo)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(Insurrancecategory; "Item Worksheet Line"."Insurrance category")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ItemBrand; "Item Worksheet Line"."Item Brand")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Model)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(TypeRetail; "Item Worksheet Line"."Type Retail")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(NoPrintonReciept)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."No Print on Reciept" := FindBooleanOptionValue(NoPrintonReciept);
                        end;
                    }
                    fieldelement(PrintTags; "Item Worksheet Line"."Print Tags")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(BasisNumber)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ChangequantitybyPhotoorder)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Change quantity by Photoorder" := FindBooleanOptionValue(ChangequantitybyPhotoorder);
                        end;
                    }
                    textelement(PictureExtention)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ItemType)
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ItemWeightitemref)
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(StdSalesQty; "Item Worksheet Line"."Std. Sales Qty.")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(BlockedonPos)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Blocked on Pos" := FindBooleanOptionValue(BlockedonPos);
                        end;
                    }
                    fieldelement(TicketType; "Item Worksheet Line"."Ticket Type")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MagentoStatus; "Item Worksheet Line"."Magento Status")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Backorder)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line".Backorder := FindBooleanOptionValue(Backorder);
                        end;
                    }
                    fieldelement(ProductNewFrom; "Item Worksheet Line"."Product New From")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ProductNewTo; "Item Worksheet Line"."Product New To")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(AttributeSetID; "Item Worksheet Line"."Attribute Set ID")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SpecialPrice; "Item Worksheet Line"."Special Price")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SpecialPriceFrom; "Item Worksheet Line"."Special Price From")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SpecialPriceTo; "Item Worksheet Line"."Special Price To")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MagentoBrand; "Item Worksheet Line"."Magento Brand")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(DisplayOnly)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Display Only" := FindBooleanOptionValue(DisplayOnly);
                        end;
                    }
                    textelement(MagentoItem)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line"."Magento Item" := FindBooleanOptionValue(MagentoItem);
                        end;
                    }
                    fieldelement(MagentoName; "Item Worksheet Line"."Magento Name")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SeoLink; "Item Worksheet Line"."Seo Link")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MetaTitle; "Item Worksheet Line"."Meta Title")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(MetaDescription; "Item Worksheet Line"."Meta Description")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(FeaturedFrom; "Item Worksheet Line"."Featured From")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(FeaturedTo; "Item Worksheet Line"."Featured To")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(RoutingNo; "Item Worksheet Line"."Routing No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(ProductionBOMNo; "Item Worksheet Line"."Production BOM No.")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(OverheadRate; "Item Worksheet Line"."Overhead Rate")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(OrderTrackingPolicy; "Item Worksheet Line"."Order Tracking Policy")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(Critical)
                    {
                        MinOccurs = Zero;

                        trigger OnAfterAssignVariable()
                        begin
                            "Item Worksheet Line".Critical := FindBooleanOptionValue(Critical);
                        end;
                    }
                    fieldelement(CommonItemNo; "Item Worksheet Line"."Common Item No.")
                    {
                        MinOccurs = Zero;
                    }
                    textelement(ValidateLine)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(SalesPriceStartingDate; "Item Worksheet Line"."Sales Price Start Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PurchasePriceStartingDate; "Item Worksheet Line"."Purchase Price Start Date")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomText1; "Item Worksheet Line"."Custom Text 1")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomText2; "Item Worksheet Line"."Custom Text 2")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomText3; "Item Worksheet Line"."Custom Text 3")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomText4; "Item Worksheet Line"."Custom Text 4")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomText5; "Item Worksheet Line"."Custom Text 5")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomPrice1; "Item Worksheet Line"."Custom Price 1")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomPrice2; "Item Worksheet Line"."Custom Price 2")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomPrice3; "Item Worksheet Line"."Custom Price 3")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomPrice4; "Item Worksheet Line"."Custom Price 4")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(CustomPrice5; "Item Worksheet Line"."Custom Price 5")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(BaseUnitofMeasure; "Item Worksheet Line"."Base Unit of Measure")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(SalesUnitofMeasure; "Item Worksheet Line"."Sales Unit of Measure")
                    {
                        MinOccurs = Zero;
                    }
                    fieldelement(PurchUnitofMeasure; "Item Worksheet Line"."Purch. Unit of Measure")
                    {
                        MinOccurs = Zero;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        TempLineNo := TempLineNo + 10000;
                        "Item Worksheet Line"."Line No." := TempLineNo;
                    end;
                }
            }
            tableelement(Integer; Integer)
            {
                AutoReplace = false;
                AutoSave = false;
                AutoUpdate = false;
                MaxOccurs = Once;
                MinOccurs = Zero;
                SourceTableView = SORTING(Number) ORDER(Ascending) WHERE(Number = CONST(1));
                XmlName = 'return';
                textelement(ReturnValue)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
            }
        }
    }

    requestpage
    {
        Caption = 'Item Worksheet Line Web Import';
    }

    trigger OnPreXmlPort()
    begin
        TempLineNo := 0;
    end;

    var
        TempLineNo: Integer;

    procedure GetMessageID(): Text[50]
    begin
        exit(messageid);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit('Testfile');
    end;

    procedure SetItemWorksheetLineResult(ParReturnValue: Text)
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin
        ReturnValue := ParReturnValue;
    end;

    local procedure FindBooleanOptionValue(InputText: Text): Integer
    begin
        case UpperCase(InputText) of
            'TRUE', 'YES', '1':
                exit(1);
            'FALSE', 'NO', '0':
                exit(0);
            else
                exit(3);
        end;
    end;
}

