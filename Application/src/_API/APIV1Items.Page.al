page 6014501 "NPR APIV1 - Items"
{
    APIGroup = 'core';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    DelayedInsert = true;
    EntityName = 'item';
    EntitySetName = 'items';
    EntityCaption = 'Item';
    EntitySetCaption = 'Items';
    Extensible = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Item;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }

                field(number; "No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Description)
                {
                    Caption = 'DisplayName';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Description));
                    end;
                }

                field(displayName2; Rec."Description 2")
                {
                    Caption = 'DisplayName2';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Description 2"));
                    end;
                }
                field(type; Type)
                {
                    Caption = 'Type';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Type));
                    end;
                }

                field(allowInvoiceDisc; Rec."Allow Invoice Disc.")
                {
                    Caption = 'Allow Invoice Disc.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Allow Invoice Disc."));
                    end;
                }

                field(priceProfitCalculation; Rec."Price/Profit Calculation")
                {
                    Caption = 'Price/Profit Calculation';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Price/Profit Calculation"));
                    end;
                }

                field(vendorNo; Rec."Vendor No.")
                {
                    Caption = 'Vendor No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor No."));
                    end;
                }

                field(vendorItemNo; Rec."Vendor Item No.")
                {
                    Caption = 'Vendor Item No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Vendor Item No."));
                    end;
                }
                field(itemCategoryId; "Item Category Id")
                {
                    Caption = 'Item Category Id';

                    trigger OnValidate()
                    begin
                        if "Item Category Id" = BlankGUID then
                            "Item Category Code" := ''
                        else begin
                            if not ItemCategory.GetBySystemId("Item Category Id") then
                                Error(ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr);

                            "Item Category Code" := ItemCategory.Code;
                        end;

                        RegisterFieldSet(FieldNo("Item Category Code"));
                        RegisterFieldSet(FieldNo("Item Category Id"));
                    end;
                }
                field(itemCategoryCode; "Item Category Code")
                {
                    Caption = 'Item Category Code';

                    trigger OnValidate()
                    begin
                        if ItemCategory.Code <> '' then begin
                            if ItemCategory.Code <> "Item Category Code" then
                                Error(ItemCategoriesValuesDontMatchErr);
                            exit;
                        end;

                        if "Item Category Code" = '' then
                            "Item Category Id" := BlankGUID
                        else begin
                            if not ItemCategory.Get("Item Category Code") then
                                Error(ItemCategoryCodeDoesNotMatchATaxGroupErr);

                            "Item Category Id" := ItemCategory.SystemId;
                        end;
                    end;
                }
                field(blocked; Blocked)
                {
                    Caption = 'Blocked';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Blocked));
                    end;
                }
                field(gtin; GTIN)
                {
                    Caption = 'GTIN';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(GTIN));
                    end;
                }
                field(inventory; InventoryValue)
                {
                    Caption = 'Inventory';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo(Inventory));
                    end;
                }
                field(unitPrice; "Unit Price")
                {
                    Caption = 'Unit Price';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit Price"));
                    end;
                }

                field(unitListPrice; Rec."Unit List Price")
                {
                    Caption = 'Unit List Price';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit List Price"));
                    end;
                }
                field(priceIncludesTax; "Price Includes VAT")
                {
                    Caption = 'Price Includes Tax';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Price Includes VAT"));
                    end;
                }
                field(unitCost; "Unit Cost")
                {
                    Caption = 'Unit Cost';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit Cost"));
                    end;
                }

                field(standardCost; Rec."Standard Cost")
                {
                    Caption = 'Standard Cost';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Standard Cost"));
                    end;
                }

                field(lastDirectCost; Rec."Last Direct Cost")
                {
                    Caption = 'Last Direct Cost';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Last Direct Cost"));
                    end;
                }

                field(taxGroupId; "Tax Group Id")
                {
                    Caption = 'Tax Group Id';

                    trigger OnValidate()
                    begin
                        if "Tax Group Id" = BlankGUID then
                            "Tax Group Code" := ''
                        else begin
                            if not TaxGroup.GetBySystemId("Tax Group Id") then
                                Error(TaxGroupIdDoesNotMatchATaxGroupErr);

                            "Tax Group Code" := TaxGroup.Code;
                        end;

                        RegisterFieldSet(FieldNo("Tax Group Code"));
                        RegisterFieldSet(FieldNo("Tax Group Id"));
                    end;
                }
                field(taxGroupCode; "Tax Group Code")
                {
                    Caption = 'Tax Group Code';

                    trigger OnValidate()
                    begin
                        if TaxGroup.Code <> '' then begin
                            if TaxGroup.Code <> "Tax Group Code" then
                                Error(TaxGroupValuesDontMatchErr);
                            exit;
                        end;

                        if "Tax Group Code" = '' then
                            "Tax Group Id" := BlankGUID
                        else begin
                            if not TaxGroup.Get("Tax Group Code") then
                                Error(TaxGroupCodeDoesNotMatchATaxGroupErr);

                            "Tax Group Id" := TaxGroup.SystemId;
                        end;

                        RegisterFieldSet(FieldNo("Tax Group Code"));
                        RegisterFieldSet(FieldNo("Tax Group Id"));
                    end;
                }

                field(tariffNo; Rec."Tariff No.")
                {
                    Caption = 'Tariff No.';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Tariff No."));
                    end;
                }
                field(baseUnitOfMeasureId; "Unit of Measure Id")
                {
                    Caption = 'Base Unit Of Measure Id';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Unit of Measure Id"));
                    end;
                }
                field(baseUnitOfMeasureCode; "Base Unit of Measure")
                {
                    Caption = 'Base Unit Of Measure Code';

                    trigger OnValidate()
                    begin
                        RegisterFieldSet(FieldNo("Base Unit of Measure"));
                    end;
                }

                field(salesUnitofMeasure; Rec."Sales Unit of Measure")
                {
                    Caption = 'Sales Unit of Measure';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Sales Unit of Measure"));
                    end;
                }

                field(purchUnitofMeasure; Rec."Purch. Unit of Measure")
                {
                    Caption = 'Purch. Unit of Measure';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Purch. Unit of Measure"));
                    end;
                }

                field(costingMethod; Rec."Costing Method")
                {
                    Caption = 'Costing Method';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Costing Method"));
                    end;
                }
                field(reserve; Rec.Reserve)
                {
                    Caption = 'Reserve';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo(Reserve));
                    end;
                }

                field(manufacturerCode; Rec."Manufacturer Code")
                {
                    Caption = 'Manufacturer Code';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Manufacturer Code"));
                    end;
                }

                field(shelfNo; Rec."Shelf No.")
                {
                    Caption = 'Shelf No.';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Shelf No."));
                    end;
                }

                field(genProdPostingGroup; Rec."Gen. Prod. Posting Group")
                {
                    Caption = 'Gen. Prod. Posting Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Gen. Prod. Posting Group"));
                    end;
                }
                field(vatProdPostingGroup; Rec."VAT Prod. Posting Group")
                {
                    Caption = 'VAT Prod. Posting Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Prod. Posting Group"));
                    end;
                }

                field(vatBusPostingGrPrice; Rec."VAT Bus. Posting Gr. (Price)")
                {
                    Caption = 'VAT Bus. Posting Gr. (Price)';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("VAT Bus. Posting Gr. (Price)"));
                    end;
                }
                field(inventoryPostingGroup; Rec."Inventory Posting Group")
                {
                    Caption = 'Inventory Posting Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Inventory Posting Group"));
                    end;
                }
                field(globalDimension1Code; Rec."Global Dimension 1 Code")
                {
                    Caption = 'Global Dimension 1 Code';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Global Dimension 1 Code"));
                    end;
                }
                field(globalDimension2Code; Rec."Global Dimension 2 Code")
                {
                    Caption = 'Global Dimension 2 Code';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Global Dimension 2 Code"));
                    end;
                }

                field(defaultDeferralTemplate; Rec."Default Deferral Template Code")
                {
                    Caption = 'Default Deferral Template Code';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Default Deferral Template Code"));
                    end;
                }

                field(itemDiscGroup; Rec."Item Disc. Group")
                {
                    Caption = 'Item Discount Group';
                    trigger OnValidate()
                    begin
                        RegisterFieldSet(Rec.FieldNo("Item Disc. Group"));
                    end;
                }
                field(nprGroupSale; Rec."NPR Group sale")
                {
                    Caption = 'Group sale';
                }

                field(nprExplodeBomAuto; Rec."NPR Explode BOM auto")
                {
                    Caption = 'Explode BOM auto';
                }

                field(nprGuaranteeVoucher; Rec."NPR Guarantee voucher")
                {
                    Caption = 'Guarantee voucher';
                }

                field(nprItemBrand; Rec."NPR Item Brand")
                {
                    Caption = 'Item Brand';
                }

                field(nprTicketType; Rec."NPR Ticket Type")
                {
                    Caption = 'Ticket Type';
                }

                field(nprItemAddOnNo; Rec."NPR Item AddOn No.")
                {
                    Caption = 'Item AddOn No.';
                }

                field(nprMagentoItem; Rec."NPR Magento Item")
                {
                    Caption = 'Magento Item';
                }

                field(nprMagentoStatus; Rec."NPR Magento Status")
                {
                    Caption = 'Magento Status';
                }

                field(nprAttributeSetID; Rec."NPR Attribute Set ID")
                {
                    Caption = 'NPR Attribute Set ID';
                }

                field(nprMagentoDescription; Rec."NPR Magento Description")
                {
                    Caption = 'Magento Description';
                }

                field(nprMagentoName; Rec."NPR Magento Name")
                {
                    Caption = 'Magento Name';
                }
                field(nprMagentoShortDescription; Rec."NPR Magento Short Description")
                {
                    Caption = 'Magento Short Description';
                }
                field(nprMagentoBrand; Rec."NPR Magento Brand")
                {
                    Caption = 'Magento Brand';
                }
                field(nprSeoLink; Rec."NPR Seo Link")
                {
                    Caption = 'Seo Link';
                }
                field(nprMetaTitle; Rec."NPR Meta Title")
                {
                    Caption = 'Meta Title';
                }
                field(nprMetaDescription; Rec."NPR Meta Description")
                {
                    Caption = 'Meta Description';
                }
                field(nprProductNewFrom; Rec."NPR Product New From")
                {
                    Caption = 'roduct New From';
                }
                field(nprProductNewTo; Rec."NPR Product New To")
                {
                    Caption = 'Product New To';
                }
                field(nprSpecialPrice; Rec."NPR Special Price")
                {
                    Caption = 'Special Price';
                }
                field(nprSpecialPricenprFrom; Rec."NPR Special Price From")
                {
                    Caption = 'Special Price From';
                }
                field(nprSpecialPriceTo; Rec."NPR Special Price To")
                {
                    Caption = 'Special Price To';
                }
                field(nprFeaturedFrom; Rec."NPR Featured From")
                {
                    Caption = 'Featured From';
                }
                field(nprFeaturedTo; Rec."NPR Featured To")
                {
                    Caption = 'Featured To';
                }
                field(nprBackorder; Rec."NPR Backorder")
                {
                    Caption = 'Backorder';
                }
                field(nprDisplayOnly; Rec."NPR Display Only")
                {
                    Caption = 'Display Only';
                }

                field(nprVarietyGroup; Rec."NPR Variety Group")
                {
                    Caption = 'Variety Group';
                }

                field(nprVariety1; Rec."NPR Variety 1")
                {
                    Caption = 'Variety 1';
                }

                field(nprVariety1Table; Rec."NPR Variety 1 Table")
                {
                    Caption = 'Variety 1 Table';
                }

                field(nprVariety2; Rec."NPR Variety 2")
                {
                    Caption = 'Variety 2';
                }

                field(nprVariety2Table; Rec."NPR Variety 2 Table")
                {
                    Caption = 'Variety 2 Table';
                }

                field(nprVariety3; Rec."NPR Variety 3")
                {
                    Caption = 'Variety 3';
                }

                field(nprVariety3Table; Rec."NPR Variety 3 Table")
                {
                    Caption = 'Variety 3 Table';
                }

                field(nprVariety4; Rec."NPR Variety 4")
                {
                    Caption = 'Variety 4';
                }

                field(nprVariety4Table; Rec."NPR Variety 4 Table")
                {
                    Caption = 'Variety  4 Table';
                }

                part(baseUnitOfMeasure; "NPR APIV1 - Units of Measure")
                {
                    // TO DO: waiting platform version 6.3 property: Caption = 'Unit Of Measure';
                    //Multiplicity = ZeroOrOne;
                    CaptionML = ENU = 'Multiplicity=ZeroOrOne';
                    EntityName = 'unitOfMeasure';
                    EntitySetName = 'unitsOfMeasure';
                    SubPageLink = SystemId = Field("Unit of Measure Id");
                }
                part(picture; "NPR APIV1 - Pictures")
                {
                    // TO DO: waiting platform version 6.3 property: Caption = 'Picture';;
                    //Multiplicity = ZeroOrOne;
                    CaptionML = ENU = 'Multiplicity=ZeroOrOne';
                    EntityName = 'picture';
                    EntitySetName = 'pictures';
                    SubPageLink = Id = Field(SystemId), "Parent Type" = const(2);
                }
                part(defaultDimensions; "NPR APIV1 - Default Dimensions")
                {
                    Caption = 'Default Dimensions';
                    EntityName = 'defaultDimension';
                    EntitySetName = 'defaultDimensions';
                    SubPageLink = ParentId = Field(SystemId), "Parent Type" = const(2);
                }
                part(itemVariants; "NPR APIV1 - Item Variants")
                {
                    Caption = 'Variants';
                    EntityName = 'itemVariant';
                    EntitySetName = 'itemVariants';
                    //SubPageLink = "Item Id" = field(SystemId);
                    SubPageLink = "Item No." = field("No.");
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }

                field(replicationCounter; Rec."NPR Replication Counter")
                {
                    Caption = 'replicationCounter', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnInit()
    begin
        CurrentTransactionType := TransactionType::Update;
    end;

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        if TempFieldSet.Get(Database::Item, FieldNo(Inventory)) then
            Error(InventoryCannotBeChangedInAPostRequestErr);

        GraphCollectionMgtItem.InsertItem(Rec, TempFieldSet);

        SetCalculatedFields();
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    var
        Item: Record Item;
    begin

        if TempFieldSet.Get(Database::Item, FieldNo(Inventory)) then
            UpdateInventory();

        Item.GetBySystemId(SystemId);

        if "No." = Item."No." then
            Modify(true)
        else begin
            Item.TransferFields(Rec, false);
            Item.Rename("No.");
            TransferFields(Item, true);
        end;

        SetCalculatedFields();

        exit(false);
    end;

    trigger OnOpenPage()
    begin
        SetAutoCalcFields(Inventory);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        ClearCalculatedFields();
    end;

    var
        TempFieldSet: Record 2000000041 temporary;
        ItemCategory: Record "Item Category";
        TaxGroup: Record "Tax Group";
        GraphCollectionMgtItem: Codeunit "Graph Collection Mgt - Item";
        InventoryValue: Decimal;
        BlankGUID: Guid;
        TaxGroupValuesDontMatchErr: Label 'The tax group values do not match to a specific Tax Group.';
        TaxGroupIdDoesNotMatchATaxGroupErr: Label 'The "taxGroupId" does not match to a Tax Group.', Comment = 'taxGroupId is a field name and should not be translated.';
        TaxGroupCodeDoesNotMatchATaxGroupErr: Label 'The "taxGroupCode" does not match to a Tax Group.', Comment = 'taxGroupCode is a field name and should not be translated.';
        ItemCategoryIdDoesNotMatchAnItemCategoryGroupErr: Label 'The "itemCategoryId" does not match to a specific Item Category group.', Comment = 'itemCategoryId is a field name and should not be translated.';
        ItemCategoriesValuesDontMatchErr: Label 'The item categories values do not match to a specific item category.';
        ItemCategoryCodeDoesNotMatchATaxGroupErr: Label 'The "itemCategoryCode" does not match to a Item Category.', Comment = 'itemCategoryCode is a field name and should not be translated.';
        InventoryCannotBeChangedInAPostRequestErr: Label 'Inventory cannot be changed during on insert.';

    local procedure SetCalculatedFields()
    begin
        // Inventory
        InventoryValue := Inventory;
    end;

    local procedure ClearCalculatedFields()
    begin
        Clear(SystemId);
        Clear(InventoryValue);
        TempFieldSet.DeleteAll();
    end;

    local procedure UpdateInventory()
    var
        ItemJnlLine: Record "Item Journal Line";
        ItemJnlPostLine: Codeunit "Item Jnl.-Post Line";
    begin
        calcfields(Inventory);
        if Inventory = InventoryValue then
            exit;
        ItemJnlLine.Init();
        ItemJnlLine.Validate("Posting Date", Today());
        ItemJnlLine."Document No." := "No.";

        if Inventory < InventoryValue then
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Positive Adjmt.")
        else
            ItemJnlLine.Validate("Entry Type", ItemJnlLine."Entry Type"::"Negative Adjmt.");

        ItemJnlLine.Validate("Item No.", "No.");
        ItemJnlLine.Validate(Description, Description);
        ItemJnlLine.Validate(Quantity, Abs(InventoryValue - Inventory));

        ItemJnlPostLine.RunWithCheck(ItemJnlLine);
        Get("No.");
    end;

    local procedure RegisterFieldSet(FieldNo: Integer)
    begin
        if TempFieldSet.Get(Database::Item, FieldNo) then
            exit;

        TempFieldSet.Init();
        TempFieldSet.TableNo := Database::Item;
        TempFieldSet.Validate("No.", FieldNo);
        TempFieldSet.Insert(true);
    end;
}

