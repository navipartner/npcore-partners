codeunit 6014426 "NPR Std. Table Code"
{

    var
        RetailSetup: Record "NPR Retail Setup";
        RetailSetupFetched: Boolean;

    procedure VareTVGOVAfter(var VItem: Record Item; var ItemGroup: Record "NPR Item Group")
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimension2: Record "Default Dimension";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateManagement: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin
        with VItem do begin
            GetRetailSetup;

            ItemGroup.TestField("VAT Bus. Posting Group");
            ItemGroup.TestField("Gen. Prod. Posting Group");
            ItemGroup.TestField("VAT Prod. Posting Group");
            if Type <> ItemGroup.Type then begin
                Validate(Type, ItemGroup.Type);
            end;
            if ItemGroup.Type <> ItemGroup.Type::Service then
                ItemGroup.TestField("Inventory Posting Group");
            ItemGroup.TestField(Blocked, false);
            ItemGroup.TestField("Main Item Group", false);
            Validate("Gen. Prod. Posting Group", ItemGroup."Gen. Prod. Posting Group");
            "VAT Prod. Posting Group" := ItemGroup."VAT Prod. Posting Group";
            "VAT Bus. Posting Gr. (Price)" := ItemGroup."VAT Bus. Posting Group";
            "Tax Group Code" := ItemGroup."Tax Group Code";

            Validate("Inventory Posting Group", ItemGroup."Inventory Posting Group");

            Validate("Reordering Policy", ItemGroup."Reordering Policy");
            Validate("Item Disc. Group", ItemGroup."Item Discount Group");
            Validate("NPR Guarantee Index", ItemGroup."Warranty File");
            Validate("NPR Guarantee voucher", ItemGroup.Warranty);
            Validate(VItem."Tariff No.", ItemGroup."Tarif No.");
            if (RetailSetup."Item Description at 1 star") and (Description = '') then Validate(Description, ItemGroup.Description);
            "Costing Method" := ItemGroup."Costing Method";
            "NPR Insurrance category" := ItemGroup."Insurance Category";

            DefaultDimension2.SetRange("Table ID", DATABASE::Item);
            DefaultDimension2.SetRange("No.", "No.");
            DefaultDimension2.DeleteAll;
            DefaultDimension.SetRange("Table ID", DATABASE::"NPR Item Group");
            DefaultDimension.SetRange("No.", "NPR Item Group");
            if DefaultDimension.FindSet then
                repeat
                    DefaultDimension2 := DefaultDimension;
                    DefaultDimension2."Table ID" := DATABASE::Item;
                    DefaultDimension2."No." := "No.";
                    DefaultDimension2.Insert;
                until DefaultDimension.Next = 0;

            "Global Dimension 1 Code" := ItemGroup."Global Dimension 1 Code";
            "Global Dimension 2 Code" := ItemGroup."Global Dimension 2 Code";

            if not ItemUnitofMeasure.Get("No.", ItemGroup."Base Unit of Measure") and (ItemGroup."Base Unit of Measure" <> '') then begin
                ItemUnitofMeasure."Item No." := "No.";
                ItemUnitofMeasure.Code := ItemGroup."Base Unit of Measure";
                ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
                if ItemUnitofMeasure.Insert then;
            end;

            if not ItemUnitofMeasure.Get("No.", ItemGroup."Sales Unit of Measure") and (ItemGroup."Sales Unit of Measure" <> '') then begin
                ItemUnitofMeasure."Item No." := "No.";
                ItemUnitofMeasure.Code := ItemGroup."Sales Unit of Measure";
                ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
                if ItemUnitofMeasure.Insert then;
            end;

            if not ItemUnitofMeasure.Get("No.", ItemGroup."Purch. Unit of Measure") and (ItemGroup."Purch. Unit of Measure" <> '') then begin
                ItemUnitofMeasure."Item No." := "No.";
                ItemUnitofMeasure.Code := ItemGroup."Purch. Unit of Measure";
                ItemUnitofMeasure."Qty. per Unit of Measure" := 1;
                if ItemUnitofMeasure.Insert then;
            end;

            if "Base Unit of Measure" <> ItemGroup."Base Unit of Measure" then begin
                Validate("Base Unit of Measure", ItemGroup."Base Unit of Measure");
                Validate("Sales Unit of Measure", ItemGroup."Sales Unit of Measure");
                Validate("Sales Unit of Measure", ItemGroup."Purch. Unit of Measure");
            end;

            if ItemGroup."Variety Group" <> '' then
                Validate("NPR Variety Group", ItemGroup."Variety Group");

            if ItemGroup."Config. Template Header" <> '' then begin
                if ConfigTemplateHeader.Get(ItemGroup."Config. Template Header") then begin
                    RecRef.GetTable(VItem);
                    ConfigTemplateManagement.UpdateRecord(ConfigTemplateHeader, RecRef);
                    VItem.Get(VItem."No.");
                end;
            end;
        end;

    end;

    procedure ItemJnlLineCrossReferenceOV(var ItemJournalLine: Record "Item Journal Line"; var xItemJournalLine: Record "Item Journal Line")
    var
        ItemReference: Record "Item Reference";
        ItemReferenceNotFoundErr: Label 'There are no items with reference: %1', Comment = '%1=ItemJournalLine."Item Reference No."';
    begin
        ItemReference.Init;
        if ItemJournalLine."Item Reference No." <> '' then begin
            ItemReference.Reset;
            ItemReference.SetCurrentKey(
                "Reference No.", "Reference Type", "Reference Type No.", "Discontinue Bar Code");
            ItemReference.SetRange("Reference No.", ItemJournalLine."Item Reference No.");
            ItemReference.SetRange("Discontinue Bar Code", false);
            ItemReference.SetRange("Item No.", ItemJournalLine."Item No.");
            if not ItemReference.Find('-') then begin
                ItemReference.SetRange("Item No.");
                if not ItemReference.Find('-') then
                    Error(ItemReferenceNotFoundErr, ItemJournalLine."Item Reference No.");
                if GuiAllowed and (ItemReference.Next <> 0) then begin
                    ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");  // Bar Code have highest priority
                    if ItemReference.Find('-') then begin
                        if ItemReference.Next <> 0 then begin
                            if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) <> ACTION::LookupOK
                            then
                                Error(ItemReferenceNotFoundErr, ItemJournalLine."Item Reference No.");
                        end;
                    end else begin
                        ItemReference.SetRange("Reference Type");
                        if ItemReference.Find('-') then
                            if ItemReference.Next <> 0 then begin
                                if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) <> ACTION::LookupOK
                                then
                                    Error(ItemReferenceNotFoundErr, ItemJournalLine."Item Reference No.");
                            end;
                    end;
                end;
            end;
            if ItemJournalLine."Item No." <> ItemReference."Item No." then
                ItemJournalLine.Validate("Item No.", ItemReference."Item No.");
            if ItemReference."Variant Code" <> '' then
                ItemJournalLine.Validate("Variant Code", ItemReference."Variant Code");

            if ItemReference."Unit of Measure" <> '' then
                ItemJournalLine.Validate("Unit of Measure Code", ItemReference."Unit of Measure");
        end;

        ItemJournalLine."Item Reference No." := ItemReference."Reference No.";

        if ItemReference.Description <> '' then
            ItemJournalLine.Description := ItemReference.Description;
    end;

    procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
            exit(true);

        if not RetailSetup.Get then
            exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;

    procedure UpdateGlobalDimCode(GlobalDimCodeNo: Integer; "Table ID": Integer; "No.": Code[20]; NewDimValue: Code[20])
    begin
        case "Table ID" of
            //+NPR7.000.000
            //-NPR5.53 [371956]-revoked
            //DATABASE::Register :
            //  UpdateRegisterGlobalDimCode(GlobalDimCodeNo,"No.",NewDimValue);
            //+NPR5.53 [371956]-revoked
            DATABASE::"NPR Payment Type POS":
                UpdatePaymentTypePOSGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Item Group":
                UpdateItemGroupGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Mixed Discount":
                UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Period Discount":
                UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR Quantity Discount Header":
                UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            //-NPR7.000.000
            //-NPR5.53 [371956]
            DATABASE::"NPR POS Store":
                UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            DATABASE::"NPR POS Unit":
                UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
            //+NPR5.53 [371956]
            //-NPR5.53 [380609]
            DATABASE::"NPR NPRE Seating":
                UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo, "No.", NewDimValue);
        //+NPR5.53 [380609]
        end;
    end;

    procedure UpdatePaymentTypePOSGlobalDimCode(GlobalDimCodeNo: Integer; PaymentTypeNo: Code[20]; NewDimValue: Code[20])
    var
        PaymentTypePOS: Record "NPR Payment Type POS";
    begin
        if PaymentTypePOS.Get(PaymentTypeNo) then begin
            case GlobalDimCodeNo of
                1:
                    PaymentTypePOS."Global Dimension 1 Code" := NewDimValue;
                2:
                    PaymentTypePOS."Global Dimension 2 Code" := NewDimValue;
            end;
            PaymentTypePOS.Modify(true);
        end;
    end;

    procedure UpdateItemGroupGlobalDimCode(GlobalDimCodeNo: Integer; ItemGroupNo: Code[20]; NewDimValue: Code[20])
    var
        ItemGroup: Record "NPR Item Group";
    begin
        if ItemGroup.Get(ItemGroupNo) then begin
            case GlobalDimCodeNo of
                1:
                    ItemGroup."Global Dimension 1 Code" := NewDimValue;
                2:
                    ItemGroup."Global Dimension 2 Code" := NewDimValue;
            end;
            ItemGroup.Modify(true);
        end;
    end;

    procedure UpdateMixedDiscountGlobalDimCode(GlobalDimCodeNo: Integer; MixedDiscountNo: Code[20]; NewDimValue: Code[20])
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        if MixedDiscount.Get(MixedDiscountNo) then begin
            case GlobalDimCodeNo of
                1:
                    MixedDiscount."Global Dimension 1 Code" := NewDimValue;
                2:
                    MixedDiscount."Global Dimension 2 Code" := NewDimValue;
            end;
            MixedDiscount.Modify(true);
        end;
    end;

    procedure UpdatePeriodDiscountGlobalDimCode(GlobalDimCodeNo: Integer; PeriodDiscountNo: Code[20]; NewDimValue: Code[20])
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        if PeriodDiscount.Get(PeriodDiscountNo) then begin
            case GlobalDimCodeNo of
                1:
                    PeriodDiscount."Global Dimension 1 Code" := NewDimValue;
                2:
                    PeriodDiscount."Global Dimension 2 Code" := NewDimValue;
            end;
            PeriodDiscount.Modify(true);
        end;
    end;

    procedure UpdateQuantityDiscountGlobalDimCode(GlobalDimCodeNo: Integer; QuantityDiscountNo: Code[20]; NewDimValue: Code[20])
    var
        QuantityDiscount: Record "NPR Quantity Discount Header";
    begin
        if QuantityDiscount.Get(QuantityDiscountNo) then begin
            case GlobalDimCodeNo of
                1:
                    QuantityDiscount."Global Dimension 1 Code" := NewDimValue;
                2:
                    QuantityDiscount."Global Dimension 2 Code" := NewDimValue;
            end;
            QuantityDiscount.Modify(true);
        end;
    end;

    local procedure UpdatePOSStoreGlobalDimCode(GlobalDimCodeNo: Integer; POSStoreCode: Code[20]; NewDimValue: Code[20])
    var
        POSStore: Record "NPR POS Store";
    begin
        //-NPR5.53 [371956]
        if POSStore.Get(POSStoreCode) then begin
            case GlobalDimCodeNo of
                1:
                    POSStore."Global Dimension 1 Code" := NewDimValue;
                2:
                    POSStore."Global Dimension 2 Code" := NewDimValue;
            end;
            POSStore.Modify(true);
        end;
        //+NPR5.53 [371956]
    end;

    local procedure UpdatePOSUnitGlobalDimCode(GlobalDimCodeNo: Integer; POSUnitNo: Code[20]; NewDimValue: Code[20])
    var
        POSUnit: Record "NPR POS Unit";
    begin
        //-NPR5.53 [371956]
        if POSUnit.Get(POSUnitNo) then begin
            case GlobalDimCodeNo of
                1:
                    POSUnit."Global Dimension 1 Code" := NewDimValue;
                2:
                    POSUnit."Global Dimension 2 Code" := NewDimValue;
            end;
            POSUnit.Modify(true);
        end;
        //+NPR5.53 [371956]
    end;

    local procedure UpdateNPRESeatingGlobalDimCode(GlobalDimCodeNo: Integer; SeatingCode: Code[20]; NewDimValue: Code[20])
    var
        NPRESeating: Record "NPR NPRE Seating";
    begin
        //-NPR5.53 [380609]
        SeatingCode := CopyStr(SeatingCode, 1, MaxStrLen(NPRESeating.Code));
        if NPRESeating.Get(SeatingCode) then begin
            case GlobalDimCodeNo of
                1:
                    NPRESeating."Global Dimension 1 Code" := NewDimValue;
                2:
                    NPRESeating."Global Dimension 2 Code" := NewDimValue;
            end;
            NPRESeating.Modify(true);
        end;
        //+NPR5.53 [380609]
    end;
}

