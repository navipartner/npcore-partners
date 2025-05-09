tableextension 6014427 "NPR Item" extends Item
{
    fields
    {
        modify("Item Category Code")
        {
            trigger OnAfterValidate()
            var
                ItemCategory: Record "Item Category";
                ItemCategoryMgt: Codeunit "NPR Item Category Mgt.";
            begin
                if Rec.IsTemporary() then
                    exit;

                if Rec."Item Category Code" = xRec."Item Category Code" then
                    exit;

                if not ItemCategory.Get(Rec."Item Category Code") then
                    exit;

                ItemCategoryMgt.SetupItemFromCategory(Rec, ItemCategory);

                Rec.Validate("Base Unit of Measure");
            end;
        }
        modify(GTIN)
        {
            trigger OnAfterValidate()
            var
                NPRVarietyCloneData: Codeunit "NPR Variety Clone Data";
            begin
                NPRVarietyCloneData.InsertItemRef(Rec."No.", '', GTIN, Enum::"Item Reference Type"::"Bar Code", '');
            end;
        }

        modify("Base Unit Of Measure")
        {
            trigger OnAfterValidate()
            var
                NPRPOSIUOMUtils: Codeunit "NPR POS IUOM Utils";
            begin
                if Rec."Base Unit Of Measure" <> xRec."Base Unit Of Measure" then
                    NPRPOSIUOMUtils.CheckIfBaseUnitOfMeasureBlocked(Rec);
            end;
        }

        field(6014400; "NPR Item Group"; Code[10])
        {
            Caption = 'Item Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Using Item Category Code instead.';
        }
        field(6014401; "NPR Group sale"; Boolean)
        {
            Caption = 'Various item sales';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ItemCostMgt: Codeunit ItemCostManagement;
            begin
                ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, Rec.FieldNo("NPR Group sale"));
            end;
        }
        field(6014408; "NPR Season"; Code[10])
        {
            Caption = 'Season';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won"t be used anymore';
        }
        field(6014410; "NPR Label Barcode"; Code[50])
        {
            Caption = 'Label barcode';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(6014418; "NPR Explode BOM auto"; Boolean)
        {
            Caption = 'Auto-explode BOM';
            DataClassification = CustomerContent;
        }
        field(6014419; "NPR Guarantee voucher"; Boolean)
        {
            Caption = 'Guarantee Voucher';
            DataClassification = CustomerContent;
        }
        field(6014424; "NPR Cannot edit unit price"; Boolean)
        {
            Caption = 'Can''t edit unit price';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014428; "NPR Primary Key Length"; Integer)
        {
            Caption = 'Primary Key Length';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014435; "NPR Last Changed at"; DateTime)
        {
            Caption = 'Last Changed at';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(6014440; "NPR Last Changed by"; Code[50])
        {
            Caption = 'Last Changed by';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(6014500; "NPR Second-hand number"; Code[20])
        {
            Caption = 'Second-hand number';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014502; "NPR Condition"; Option)
        {
            Caption = 'Condition';
            DataClassification = CustomerContent;
            OptionCaption = 'New,Mint,Mint boxed,A,B,C,D,E,F,B+';
            OptionMembers = New,Mint,"Mint boxed",A,B,C,D,E,F,"B+";
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'This field won"t be used anymore';
        }
        field(6014503; "NPR Second-hand"; Boolean)
        {
            Caption = 'Second-hand';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014504; "NPR Guarantee Index"; Option)
        {
            Caption = 'Guarantee Index';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Move to Warranty';
            OptionMembers = " ","Flyt til garanti kar.";
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014506; "NPR Has Accessories"; Boolean)
        {
            CalcFormula = Exist("NPR Accessory/Spare Part" WHERE(Code = FIELD("No.")));
            Caption = 'Has Accessories';
            FieldClass = FlowField;
        }
        field(6014508; "NPR Insurrance category"; Code[50])
        {
            Caption = 'Insurance Section';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014509; "NPR Item Brand"; Code[20])
        {
            Caption = 'Item brand';
            DataClassification = CustomerContent;
        }
        field(6014512; "NPR No Print on Reciept"; Boolean)
        {
            Caption = 'No Print on Reciept';
            DataClassification = CustomerContent;
        }
        field(6014513; "NPR Print Tags"; Text[100])
        {
            Caption = 'Print Tags';
            DataClassification = CustomerContent;
        }
        field(6014514; "NPR NPRE Item Routing Profile"; Code[20])
        {
            Caption = 'Rest. Item Routing Profile';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Item Routing Profile";
        }
        field(6014609; "NPR Has Variants"; Boolean)
        {
            CalcFormula = Exist("Item Variant" WHERE("Item No." = FIELD("No.")));
            Caption = 'Has Variants';
            FieldClass = FlowField;
        }
        field(6014625; "NPR Std. Sales Qty."; Decimal)
        {
            Caption = 'Std. Sales Qty.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(6014630; "NPR Blocked on Pos"; Boolean)
        {
            Caption = 'Blocked on Pos';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014635; "NPR Sale Blocked"; Boolean)
        {
            Caption = 'Sale Blocked';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014640; "NPR Purchase Blocked"; Boolean)
        {
            Caption = 'Purchase Blocked';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014641; "NPR Custom Discount Blocked"; Boolean)
        {
            Caption = 'Custom Discount Blocked';
            DataClassification = CustomerContent;
        }
        field(6014642; "NPR Shelf Label Type"; Code[50])
        {
            Caption = 'Shelf Label Type';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used';
        }
        field(6059784; "NPR Ticket Type"; Code[10])
        {
            Caption = 'Ticket Type';
            DataClassification = CustomerContent;
            TableRelation = "NPR TM Ticket Type";

            trigger OnValidate()
            begin
                if Rec."NPR Ticket Type" <> '' then
                    Rec."NPR Visibility" := Rec."NPR Visibility"::Hidden;
            end;
        }
        field(6059785; "NPR POS Admit Action"; Enum "NPR TM POS Admit Action")
        {
            Caption = 'POS Admit Action';
            DataClassification = CustomerContent;
        }
        field(6150937; "NPR CreateAttractionWallet"; Boolean)
        {
            Caption = 'Create Attraction Wallet';
            DataClassification = CustomerContent;
        }

        field(6059970; "NPR Variety 1"; Code[10])
        {
            Caption = 'Variety 1';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(6059971; "NPR Variety 1 Table"; Code[40])
        {
            Caption = 'Variety 1 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 1"));
        }
        field(6059973; "NPR Variety 2"; Code[10])
        {
            Caption = 'Variety 2';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(6059974; "NPR Variety 2 Table"; Code[40])
        {
            Caption = 'Variety 2 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 2"));
        }
        field(6059976; "NPR Variety 3"; Code[10])
        {
            Caption = 'Variety 3';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(6059977; "NPR Variety 3 Table"; Code[40])
        {
            Caption = 'Variety 3 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 3"));
        }
        field(6059979; "NPR Variety 4"; Code[10])
        {
            Caption = 'Variety 4';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety";
        }
        field(6059980; "NPR Variety 4 Table"; Code[40])
        {
            Caption = 'Variety 4 Table';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Table".Code WHERE(Type = FIELD("NPR Variety 4"));
        }
        field(6059981; "NPR Cross Variety No."; Option)
        {
            Caption = 'Cross Variety No.';
            DataClassification = CustomerContent;
            OptionCaption = 'Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = Variety1,Variety2,Variety3,Variety4;
        }
        field(6059982; "NPR Variety Group"; Code[20])
        {
            Caption = 'Variety Group';
            DataClassification = CustomerContent;
            TableRelation = "NPR Variety Group";
        }
        field(6060054; "NPR Item Status"; Code[10])
        {
            Caption = 'Item Status';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Status";
        }
        field(6151125; "NPR Item AddOn No."; Code[20])
        {
            Caption = 'Item AddOn No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR NpIa Item AddOn";
        }
        field(6151400; "NPR Magento Item"; Boolean)
        {
            Caption = 'Magento Item';
            DataClassification = CustomerContent;
        }
        field(6151405; "NPR Magento Status"; Option)
        {
            BlankZero = true;
            Caption = 'Magento Status';
            DataClassification = CustomerContent;
            InitValue = Active;
            OptionCaption = ',Active,Inactive';
            OptionMembers = ,Active,Inactive;
        }
        field(6151410; "NPR Attribute Set ID"; Integer)
        {
            Caption = 'Attribute Set ID';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Attribute Set";
        }
        field(6151415; "NPR Magento Description"; BLOB)
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(6151416; "NPR Magento Desc."; Media)
        {
            Caption = 'Magento Description';
            DataClassification = CustomerContent;
        }
        field(6151420; "NPR Magento Name"; Text[250])
        {
            Caption = 'Magento Name';
            DataClassification = CustomerContent;
        }
        field(6151425; "NPR Magento Short Description"; BLOB)
        {
            Caption = 'Magento Short Description';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Use Media instead of Blob type.';
        }
        field(6151426; "NPR Magento Short Desc."; Media)
        {
            Caption = 'Magento Short Description';
            DataClassification = CustomerContent;
        }
        field(6151430; "NPR Magento Brand"; Code[20])
        {
            Caption = 'Magento Brand';
            DataClassification = CustomerContent;
            TableRelation = "NPR Magento Brand";
        }
        field(6151435; "NPR Seo Link"; Text[250])
        {
            Caption = 'Seo Link';
            DataClassification = CustomerContent;
        }
        field(6151440; "NPR Meta Title"; Text[100])
        {
            Caption = 'Meta Title';
            DataClassification = CustomerContent;
        }
        field(6151445; "NPR Meta Description"; Text[250])
        {
            Caption = 'Meta Description';
            DataClassification = CustomerContent;
        }
        field(6151447; "NPR Meta Keywords"; Text[250])
        {
            Caption = 'Meta Keywords';
            DataClassification = CustomerContent;
        }
        field(6151450; "NPR Product New From"; Date)
        {
            Caption = 'Product New From';
            DataClassification = CustomerContent;
        }
        field(6151455; "NPR Product New To"; Date)
        {
            Caption = 'Product New To';
            DataClassification = CustomerContent;
        }
        field(6151460; "NPR Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
        }
        field(6151465; "NPR Special Price From"; Date)
        {
            Caption = 'Special Price From';
            DataClassification = CustomerContent;
        }
        field(6151470; "NPR Special Price To"; Date)
        {
            Caption = 'Special Price To';
            DataClassification = CustomerContent;
        }
        field(6151475; "NPR Featured From"; Date)
        {
            Caption = 'Featured From';
            DataClassification = CustomerContent;
        }
        field(6151480; "NPR Featured To"; Date)
        {
            Caption = 'Featured To';
            DataClassification = CustomerContent;
        }
        field(6151485; "NPR Backorder"; Boolean)
        {
            Caption = 'Backorder';
            DataClassification = CustomerContent;
        }
        field(6151490; "NPR Display Only"; Boolean)
        {
            Caption = 'Display Only';
            DataClassification = CustomerContent;
        }
        field(6151493; "NPR Visibility"; Enum "NPR Mag. Store Item Visibility")
        {
            Caption = 'Visibility';
            DataClassification = CustomerContent;
        }
        field(6151495; "NPR Custom Options"; Integer)
        {
            CalcFormula = Count("NPR Magento Item Custom Option" WHERE("Item No." = FIELD("No."),
                                                                    Enabled = CONST(true)));
            Caption = 'Custom Options';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6151496; "NPR Has Mixed Discount"; Boolean)
        {
            Caption = 'Has Mixed Discount';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR Mixed Discount Line" where("No." = field("No.")));
            Editable = false;
        }
        field(6151497; "NPR Has Quantity Discount"; Boolean)
        {
            Caption = 'Has Quantity Discount';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR Quantity Discount Line" where("Item No." = field("No.")));
            Editable = false;
        }
        field(6151498; "NPR Has Period Discount"; Boolean)
        {
            Caption = 'Has Period Discount';
            FieldClass = FlowField;
            CalcFormula = Exist("NPR Period Discount Line" where("Item No." = field("No.")));
            Editable = false;
        }
        field(6151500; "NPR Magento Pict. Variety Type"; Option)
        {
            Caption = 'Magento Picture Variety Type';
            DataClassification = CustomerContent;
            OptionCaption = 'None,Variety 1,Variety 2,Variety 3,Variety 4';
            OptionMembers = "None","Variety 1","Variety 2","Variety 3","Variety 4";
        }
        field(6151501; "NPR Display only Text"; text[250])
        {
            Caption = 'Display Only Text';
            DataClassification = CustomerContent;
        }

        field(6151510; "NPR Main Item/Variation"; enum "NPR Main Item/Variation")
        {
            Caption = 'Main Item/Variation';
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(6151511; "NPR Main Item No."; Code[20])
        {
            Caption = 'Main Item No.';
            DataClassification = CustomerContent;
            TableRelation = Item."No.";

            trigger OnValidate()
            var
                MainItemVariationMgt: Codeunit "NPR Main Item Variation Mgt.";
                CannotChangeManuallyErr: Label 'The field "%2" cannot be changed manually.', Comment = 'Main Item No. field caption';
            begin
                if xRec."NPR Main Item No." = "NPR Main Item No." then
                    exit;
                TestField("NPR Main Item/Variation", "NPR Main Item/Variation"::" ");
                if xRec."NPR Main Item No." <> '' then
                    Error(CannotChangeManuallyErr, FieldCaption("NPR Main Item No."));
                if "NPR Main Item No." <> '' then
                    MainItemVariationMgt.AddAsVariation(Rec, "NPR Main Item No.");
            end;
        }
        field(6151479; "NPR Replication Counter"; BigInteger)
        {
            Caption = 'Replication Counter';
            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#if not BC17
        field(6151550; "NPR Purchasing Code"; Code[10])
        {
            Caption = 'Purchasing Code';
            DataClassification = CustomerContent;
            TableRelation = Purchasing;
        }
        field(6151551; "NPR Spfy Safety Stock Quantity"; Decimal)
        {
            Caption = 'Shopify Safety Stock Quantity';
            DataClassification = CustomerContent;
            DecimalPlaces = 0 : 5;
            MinValue = 0;
        }
        field(6151552; "NPR Spfy Store Filter"; Code[20])
        {
            Caption = 'Shopify Store Filter';
            FieldClass = FlowFilter;
            TableRelation = "NPR Spfy Store".Code;
        }
        field(6151553; "NPR Spfy Synced Item"; Boolean)
        {
            Caption = 'Shopify Item';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR Spfy Store-Item Link" where(Type = const(Item),
                                                                "Item No." = field("No."),
                                                                "Variant Code" = const(''),
                                                                "Shopify Store Code" = field("NPR Spfy Store Filter"),
                                                                "Synchronization Is Enabled" = const(true)));
        }
        field(6151554; "NPR Spfy Synced Item (Planned)"; Boolean)
        {
            Caption = 'Shopify Item (Planned)';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = exist("NPR Spfy Store-Item Link" where(Type = const(Item),
                                                                "Item No." = field("No."),
                                                                "Variant Code" = const(''),
                                                                "Shopify Store Code" = field("NPR Spfy Store Filter"),
                                                                "Synchronization Is Enabled" = const(false),
                                                                "Sync. to this Store" = const(true)));
        }
        field(6151555; "NPR Do Not Track Inventory"; Boolean)
        {
            Caption = 'Do Not Track Inventory';
            Editable = false;
            FieldClass = FlowField;
            CalcFormula = lookup("NPR Spfy Item Variant Modif."."Do Not Track Inventory" where("Item No." = field("No."),
                                                                "Variant Code" = const(''),
                                                                "Shopify Store Code" = field("NPR Spfy Store Filter")));
        }
#endif
    }
    keys
    {
        key("NPR Key1"; "NPR Group sale", "NPR Item Group")
        {
#IF BC17 or BC18 or BC19 or BC20
            Enabled = false;
            //Obsoleting keys generates an error when using CurrentKeyIndex with RecRef.
            //See details: https://github.com/microsoft/AL/issues/6734
#ELSE
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
#ENDIF
        }
        key("NPR Key2"; "NPR Primary Key Length")
        {
#IF BC17 or BC18 or BC19 or BC20
            Enabled = false;
#ELSE
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used anymore.';
#ENDIF
        }
        key("NPR Key3"; "NPR Replication Counter")
        {
            ObsoleteState = Pending;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Replaced by SystemRowVersion';
        }
#IF NOT (BC17 or BC18 or BC19 or BC20)
        key("NPR Key4"; SystemRowVersion)
        {
        }
#ENDIF
        key(MainItemVariationLinks; "NPR Main Item No.", "NPR Main Item/Variation")
        {
        }
    }

    trigger OnAfterInsert()
    begin
        SalesSetup.GetRecordOnce();

        if Rec."Price Includes VAT" and (SalesSetup."VAT Bus. Posting Gr. (Price)" <> '') then
            Rec."VAT Bus. Posting Gr. (Price)" := SalesSetup."VAT Bus. Posting Gr. (Price)";

        if Rec."Item Category Code" <> '' then
            Rec.Validate("Item Category Code");

        if Rec."NPR Ticket Type" <> '' then
            Rec."NPR Visibility" := Rec."NPR Visibility"::Hidden;

        Rec.Modify();
    end;

    trigger OnAfterModify()
    begin
        UpdateVendorItemRef(Rec, xRec);
    end;

    trigger OnBeforeDelete()
    var
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        SalesLinePOS: Record "NPR POS Sale Line";
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        MixDiscLineNotEmptyErr: Label 'You can''t delete %1 %2 as it''s contained in one or more mixed discount lines.';
        PerDiscLineNotEmptyErr: Label 'You can''t delete %1 %2 as it''s contained in one or more period discount lines.';
        POSEntryNotEmptyErr: Label 'You can''t delete item %1 becase it has unposted entries in POS Entry table.';
        SalesLinePOSNotEmptyErr: Label 'You can''t delete item %1 because it is part of an active sales document.';
    begin
        POSEntrySalesLine.SetRange("No.", Rec."No.");
        POSEntrySalesLine.SetRange(Type, POSEntrySalesLine.Type::Item);
        POSEntrySalesLine.SetLoadFields(Type, "POS Entry No.", "No.");
        if POSEntrySalesLine.FindSet() then
            repeat
                POSEntry.SetRange("Entry No.", POSEntrySalesLine."POS Entry No.");
                POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
                if not POSEntry.IsEmpty() then
                    Error(POSEntryNotEmptyErr, Rec."No.");

                POSEntrySalesLine.SetRange("POS Entry No.", POSEntrySalesLine."POS Entry No.");
                POSEntrySalesLine.FindLast();
                POSEntrySalesLine.SetRange("POS Entry No.");
            until POSEntrySalesLine.Next() = 0;

        SalesLinePOS.SetRange("Line Type", SalesLinePOS."Line Type"::Item);
        SalesLinePOS.SetRange("No.", Rec."No.");
        if not SalesLinePOS.IsEmpty() then
            Error(SalesLinePOSNotEmptyErr, Rec."No.");

        PeriodDiscountLine.SetCurrentKey("Item No.");
        PeriodDiscountLine.SetRange("Item No.", Rec."No.");
        if not PeriodDiscountLine.IsEmpty() then
            Error(PerDiscLineNotEmptyErr, Rec.TableCaption, Rec."No.");

        MixedDiscountLine.SetCurrentKey("No.");
        MixedDiscountLine.SetRange("No.", Rec."No.");
        if not MixedDiscountLine.IsEmpty() then
            Error(MixDiscLineNotEmptyErr, Rec.TableCaption, Rec."No.");
    end;

    trigger OnAfterDelete()
    var
        QtyDiscountLine: Record "NPR Quantity Discount Line";
    begin
        QtyDiscountLine.SetRange("Item No.", Rec."No.");
        QtyDiscountLine.DeleteAll(true);
    end;

    var
        SalesSetup: Record "Sales & Receivables Setup";

    local procedure UpdateVendorItemRef(var Item: Record Item; xItem: Record Item)
    begin
        if Item.IsTemporary() then
            exit;

        if (Item."Vendor No." = xItem."Vendor No.") and (Item."Vendor Item No." = xItem."Vendor Item No.") then
            exit;

        DeleteItemReference(Item, xItem);

        if (Item."Vendor No." = '') or (Item."Vendor Item No." = '') then
            exit;

        CreateItemRef(Item);
    end;

    local procedure DeleteItemReference(Item: Record Item; xItem: Record Item)
    var
        IsHandled: Boolean;
        ItemReference: Record "Item Reference";
    begin
        IsHandled := false;
        OnBeforeDeleteItemRef(ItemReference, IsHandled);
        if IsHandled then
            exit;

        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Variant Code", '');
        ItemReference.SetRange("Unit of Measure", xItem."Base Unit of Measure");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", xItem."Vendor No.");
        ItemReference.SetRange("Reference No.", xItem."Vendor Item No.");
        ItemReference.DeleteAll(true);
    end;

    local procedure CreateItemRef(var Item: Record Item)
    var
        ItemReference: Record "Item Reference";
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCreateItemRef(ItemReference, IsHandled);
        If IsHandled then
            exit;

        if not ItemReference.Get(Item."No.", '', Item."Base Unit of Measure", ItemReference."Reference Type"::Vendor, Item."Vendor No.", Item."Vendor Item No.") then begin
            ItemReference.Init();
            ItemReference."Item No." := Item."No.";
            ItemReference."Variant Code" := '';
            ItemReference."Unit of Measure" := Item."Base Unit of Measure";
            ItemReference."Reference Type" := ItemReference."Reference Type"::Vendor;
            ItemReference."Reference Type No." := Item."Vendor No.";
            ItemReference."Reference No." := Item."Vendor Item No.";
            ItemReference.Description := '';
            OnBeforeInsertItemRef(ItemReference);
            ItemReference.Insert(true);
        end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertItemRef(var ItemReference: Record "Item Reference")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeDeleteItemRef(var ItemReference: Record "Item Reference"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCreateItemRef(var ItemReference: Record "Item Reference"; var IsHandled: Boolean)
    begin
    end;

#pragma warning disable AL0432
    [Obsolete('Rollback of Auxiliary Item table back to Item table extension', '2023-06-28')]
    procedure NPR_GetAuxItem(var AuxItem: Record "NPR Auxiliary Item")
    begin
    end;

    [Obsolete('Rollback of Auxiliary Item table back to Item table extension', '2023-06-28')]
    procedure NPR_GetAuxItem(var AuxItem: Record "NPR Auxiliary Item"; Force: Boolean)
    begin
    end;
#pragma warning restore
}
