codeunit 6014441 "NPR Event Subscriber (Item)"
{
    var
        InventorySetup: Record "Inventory Setup";
        RetailSetup: Record "NPR Retail Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        InventorySetupFetched: Boolean;
        RetailSetupFetched: Boolean;
        SalesSetupFetched: Boolean;
        Error_LabelBarcode: Label 'Barcode %1 cannot be selected unless it is present in %2 or %3 for this item.';
        Error_ItemRef: Label 'Bar Code %1 cannot be linked to Item %2 if item %3 exits. ';
        ErrStd: Label 'Item %1 can''t be Group sale as it''s Costing Method is Standard.';
        Text000: Label 'Alternative No. %1 %2 already exists.';
        Error_ItemCrossRef: Label 'Bar Code %1 cannot be linked to Item %2 if item %3 exits. ';
        Text001: Label 'Can''t create number as no product group has been selected.';
        Text005: Label 'You can''t delete %1 %2 as it''s contained in one or more mixed discount lines.';
        Text004: Label 'You can''t delete %1 %2 as it''s contained in one or more period discount lines.';
        Text003: Label 'You can''t delete item %1 as there aren''t any posted entries for it.';
        Text002: Label 'You can''t delete item %1 because it is part of an active sales document.';

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeInsertEvent', '', true, false)]
    local procedure OnBeforeInsertEventLicenseCheck(var Rec: Record Item; RunTrigger: Boolean)
    var
        InvtSetup: Record "Inventory Setup";
        ItemGroup: Record "NPR Item Group";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        TempItem: Record Item temporary;
    begin
        if not RunTrigger then
            exit;

        GetRetailSetup;
        GetSalesSetup;

        if RetailSetup."Item Group on Creation" and (Rec."No." = '') and (Rec."NPR Item Group" = '') then begin
            if PAGE.RunModal(PAGE::"NPR Item Group Tree", ItemGroup) = ACTION::LookupOK then begin
                Rec."NPR Item Group" := ItemGroup."No.";
                if ItemGroup."No. Series" <> '' then begin
                    Rec."No. Series" := ItemGroup."No. Series";
                    InvtSetup.Get;
                    InvtSetup.TestField("Item Nos.");
                    NoSeriesMgt.InitSeries(InvtSetup."Item Nos.", Rec."No. Series", 0D, Rec."No.", Rec."No. Series");
                end;

                if ItemGroup."Config. Template Header" <> '' then
                    if ApplyTemplateToTempItem(Rec, TempItem, ItemGroup."Config. Template Header") then
                        Rec."Price Includes VAT" := TempItem."Price Includes VAT";
            end;
        end;

        if not Rec."NPR Group sale" then
            Rec."Costing Method" := RetailSetup."Costing Method Standard";

        if Rec."Price Includes VAT" and (SalesSetup."VAT Bus. Posting Gr. (Price)" <> '') then
            Rec."VAT Bus. Posting Gr. (Price)" := SalesSetup."VAT Bus. Posting Gr. (Price)";
    end;

    local procedure ApplyTemplateToTempItem(var Item: Record Item; var TempItem: Record Item temporary; ConfigTemplHeaderCode: Code[10]): Boolean
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        RecRef: RecordRef;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
    begin
        if not TempItem.IsTemporary then
            exit(false);

        ConfigTemplateHeader.Get(ConfigTemplHeaderCode);
        TempItem := Item;
        TempItem.Insert;
        RecRef.GetTable(TempItem);
        ConfigTemplateMgt.ApplyTemplateLinesWithoutValidation(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(TempItem);

        exit(true);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, false)]
    local procedure OnAfterInsertEventLicenseCheck(var Rec: Record Item; RunTrigger: Boolean)
    var
        VRTCloneData: Codeunit "NPR Variety Clone Data";
    begin
        if not RunTrigger then
            exit;

        Rec."NPR Primary Key Length" := StrLen(Rec."No.");
        if Rec."NPR Item Group" <> '' then
            Rec.Validate("NPR Item Group");
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyEventLicenseCheck(var Rec: Record Item; var xRec: Record Item)
    begin
        UpdateVendorItemRef(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEventLicenseCheck(var Rec: Record Item; RunTrigger: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        SalesLinePOS: Record "NPR Sale Line POS";
    begin
        if not RunTrigger then
            exit;

        AuditRoll.SetCurrentKey("Sale Type", Type, "No.", Posted);
        AuditRoll.SetRange("Sale Type", AuditRoll."Sale Type"::Sale);
        AuditRoll.SetRange(Type, AuditRoll.Type::Item);
        AuditRoll.SetRange("No.", Rec."No.");
        AuditRoll.SetRange(Posted, false);
        if AuditRoll.FindFirst then
            Error(Text003, Rec."No.");

        SalesLinePOS.SetRange("Sale Type", SalesLinePOS."Sale Type"::Sale);
        SalesLinePOS.SetRange(Type, SalesLinePOS.Type::Item);
        SalesLinePOS.SetRange("No.", Rec."No.");
        if SalesLinePOS.FindFirst then
            Error(Text002, Rec."No.");

        PeriodDiscountLine.SetCurrentKey("Item No.");
        PeriodDiscountLine.SetRange("Item No.", Rec."No.");
        if PeriodDiscountLine.FindFirst then
            Error(Text004, Rec.TableCaption, Rec."No.");

        MixedDiscountLine.SetCurrentKey("No.");
        MixedDiscountLine.SetRange("No.", Rec."No.");
        if MixedDiscountLine.FindFirst then
            Error(Text005, Rec.TableCaption, Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterDeleteEvent', '', true, false)]
    local procedure OnAfterDeleteEventLicenseCheck(var Rec: Record Item; RunTrigger: Boolean)
    var
        AlternativeNo: Record "NPR Alternative No.";
        QtyDiscountLine: Record "NPR Quantity Discount Line";
    begin
        if not RunTrigger then
            exit;

        AlternativeNo.SetRange(Code, Rec."No.");
        AlternativeNo.DeleteAll(true);

        QtyDiscountLine.SetRange("Item No.", Rec."No.");
        QtyDiscountLine.DeleteAll(true);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterRenameEvent', '', true, false)]
    local procedure OnAfterRenameEvent(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        if not RunTrigger then
            exit;

        Rec."NPR Primary Key Length" := StrLen(Rec."No.");
        Rec.Modify;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeValidateEvent', 'No.', true, false)]
    local procedure OnBeforeValidateEventNo(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        Item: Record Item;
        AlternativeNo: Record "NPR Alternative No.";
        Utility: Codeunit "NPR Utility";
    begin
        GetRetailSetup;

        if Rec."No." = '' then
            exit;

        if not Item.Get(Rec."No.") and RetailSetup."EAN-No. at Item Create" then
            if (StrLen(Rec."No.") <= 10) and (StrLen(Rec."No.") >= 5) then
                Rec."No." := Utility.CreateEAN(Rec."No.", '');

        AlternativeNo.SetRange("Alt. No.", Rec."No.");
        AlternativeNo.SetFilter(Code, '<>%1', Rec."No.");
        if AlternativeNo.FindFirst then
            Error(Text000, AlternativeNo."Alt. No.", AlternativeNo.Code);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'No.', true, false)]
    local procedure OnAfterValidateEventNo(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        NFCode: Codeunit "NPR NF Retail Code";
    begin
        ValidateNo(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeValidateEvent', 'Costing Method', true, false)]
    local procedure OnBeforeValidateEventCostingMethod(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        RetailCodeunitCode: Codeunit "NPR Std. Codeunit Code";
    begin
        CheckGroupSale(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Cost', true, false)]
    local procedure OnAfterValidateEventUnitCost(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        RetailTableCode: Codeunit "NPR Std. Table Code";
    begin
        UnitCostValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Last Direct Cost', true, false)]
    local procedure OnAfterValidateEventLastDirectCost(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        RetailTableCode: Codeunit "NPR Std. Table Code";
    begin
        UnitCostValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Item Group', true, false)]
    local procedure OnAfterValidateEventItemGroupLicenseCheck(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        ItemGroup: Record "NPR Item Group";
        RetailTableCode: Codeunit "NPR Std. Table Code";
    begin
        //haven't moved code RetailTableCode.VareTVGOVAfter as it is being used from several places
        if ItemGroup.Get(Rec."NPR Item Group") then
            RetailTableCode.VareTVGOVAfter(Rec, ItemGroup);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Group sale', true, false)]
    local procedure OnAfterValidateEventGroupSaleLicenseCheck(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        RetailCodeunitCode: Codeunit "NPR Std. Codeunit Code";
    begin
        CheckGroupSale(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Group sale', false, false)]
    local procedure OnAfterValidateEventGroupSale(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        ItemCostMgt: Codeunit ItemCostManagement;
    begin
        ItemCostMgt.UpdateUnitCost(Rec, '', '', 0, 0, false, false, true, Rec.FieldNo("NPR Group sale"));
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Label Barcode', false, false)]
    local procedure OnAfterValidateLabelBarcode(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        ItemRef: Record "Item Reference";
        AltNo: Record "NPR Alternative No.";
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        VariantCode: Code[10];
        ItemNo: Code[20];
        ResolvingTable: Integer;
    begin
        if StrLen(Rec."NPR Label Barcode") > 0 then begin
            if BarcodeLibrary.TranslateBarcodeToItemVariant(Rec."NPR Label Barcode", ItemNo, VariantCode, ResolvingTable, false) then
                if (ItemNo = Rec."No.") and (ResolvingTable in [DATABASE::"NPR Alternative No.", DATABASE::"Item Reference"]) then
                    exit;
            Error(Error_LabelBarcode, Rec."NPR Label Barcode", AltNo.TableCaption, ItemRef.TableCaption());
        end;
    end;

    local procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
            exit(true);

        if not RetailSetup.Get then
            exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;

    local procedure GetInventorySetup(): Boolean
    begin
        if InventorySetupFetched then
            exit(true);

        if not InventorySetup.Get then
            exit(false);
        InventorySetupFetched := true;
        exit(true);
    end;

    local procedure GetSalesSetup(): Boolean
    begin
        if SalesSetupFetched then
            exit(true);

        if not SalesSetup.Get then
            exit(false);
        SalesSetupFetched := true;
        exit(true);
    end;

    local procedure CheckGroupSale(var Item: Record Item)
    begin
        if Item."NPR Group sale" then
            if Item."Costing Method" = Item."Costing Method"::Standard then
                Error(ErrStd, Item."No.");
    end;

    local procedure UnitCostValidation(var Item: Record Item)
    begin
        GetRetailSetup();
        if RetailSetup."Staff SalesPrice Calc Codeunit" > 0 then
            CODEUNIT.Run(RetailSetup."Staff SalesPrice Calc Codeunit", Item);
    end;

    procedure ValidateNo(var Rec: Record Item; var xRec: Record Item)
    var
        ItemGroup: Record "NPR Item Group";
        Vendor: Record Vendor;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        Utility: Codeunit "NPR Utility";
        VendorList: Page "Vendor List";
        EndNo: Code[20];
        InternNo: Code[20];
        ISBNBooklandEAN: Code[20];
        Check: Integer;
        Ciffer: Integer;
        i: Integer;
        n: Integer;
        Remainder: Integer;
        Weight: Integer;
    begin
        //made a new function so this EXIT doesn't exit from event subscriber completelly
        if (xRec."No." <> '') and (xRec."No." <> Rec."No.") then
            exit;

        if (CopyStr(Rec."No.", 1, 1) = '*') and (Rec."No." <> '**') then begin
            if StrLen(Rec."No.") > 1 then
                EndNo := CopyStr(Rec."No.", 2, StrLen(Rec."No.") - 1);
            Rec."No." := '*';
            GetRetailSetup();
            ItemGroup.SetRange(Blocked, false);
            if (Rec."NPR Item Group" = '') and RetailSetup."Item Group on Creation" then
                if PAGE.RunModal(PAGE::"NPR Item Group Tree", ItemGroup, ItemGroup."No.") = ACTION::LookupOK then begin
                    Rec."NPR Item Group" := ItemGroup."No.";
                    Clear(Rec."No.");
                end else
                    Error(Text001);
            if (Rec."Vendor No." = '') and RetailSetup."Vendor When Creation" then begin
                VendorList.LookupMode := true;
                if VendorList.RunModal = ACTION::LookupOK then begin
                    VendorList.GetRecord(Vendor);
                    Rec."Vendor No." := Vendor."No.";
                    Clear(Rec."No.");
                end else
                    Error(Text001);
            end;

            RetailSetup.TestField("Internal EAN No. Management");

            if RetailSetup."Itemgroup Pre No. Serie" <> '' then begin
                if EndNo = '' then begin
                    ItemGroup.TestField("No. Series");
                    NoSeriesManagement.InitSeries(ItemGroup."No. Series", xRec."No. Series", 0D, InternNo, Rec."No. Series")
                end else
                    InternNo := EndNo;
                if RetailSetup."EAN No. at 1 star" then
                    Rec."No." := Utility.CreateEAN(Rec."NPR Item Group" + InternNo, '')
                else
                    Rec."No." := Rec."NPR Item Group" + InternNo;
            end else begin
                if RetailSetup."EAN No. at 1 star" then begin
                    if EndNo = '' then begin
                        RetailSetup.TestField("Internal EAN No. Management");
                        NoSeriesManagement.InitSeries(RetailSetup."Internal EAN No. Management", xRec."No. Series", 0D, InternNo, Rec."No. Series")
                    end else
                        InternNo := EndNo;
                    Rec."No." := Utility.CreateEAN(InternNo, '');
                end else begin
                    GetInventorySetup();
                    InventorySetup.TestField("Item Nos.");
                    NoSeriesManagement.InitSeries(InventorySetup."Item Nos.", xRec."No. Series", 0D, Rec."No.", Rec."No. Series");
                    if RetailSetup."Item group in Item no." then
                        Rec."No." := Rec."NPR Item Group" + Rec."No.";
                end;
            end;

            Rec.Validate("NPR Item Group");

            if RetailSetup."Item Description at 1 star" then
                if ItemGroup.Get(Rec."NPR Item Group") then
                    Rec.Description := ItemGroup.Description;
        end;

        if Rec."No." = '**' then begin
            GetRetailSetup();
            if RetailSetup."Use VariaX module" then begin
                Clear(Rec."No.");
                GetInventorySetup();
                InventorySetup.TestField("Item Nos.");
                if RetailSetup."Itemgroup Pre No. Serie" <> '' then begin
                    NoSeriesManagement.InitSeries(ItemGroup."No. Series", xRec."No. Series", 0D, Rec."No.", Rec."No. Series");
                    ItemGroup.TestField("No. Series");
                end else
                    NoSeriesManagement.InitSeries(InventorySetup."Item Nos.", xRec."No. Series", 0D, Rec."No.", Rec."No. Series");

            end else begin
                ItemGroup.SetRange(Blocked, false);
                if (Rec."NPR Item Group" = '') and RetailSetup."Item Group on Creation" then
                    if PAGE.RunModal(PAGE::"NPR Item Group Tree", ItemGroup, ItemGroup."No.") = ACTION::LookupOK then begin
                        Rec."NPR Item Group" := ItemGroup."No.";
                        Rec.Validate("NPR Item Group");
                        Commit;
                        Clear(Rec."No.");
                    end else
                        Error(Text001);
                if (Rec."Vendor No." = '') and RetailSetup."Vendor When Creation" then begin
                    Vendor.SetCurrentKey("Search Name");
                    if PAGE.RunModal(PAGE::"Vendor List", Vendor, Vendor."No.") = ACTION::LookupOK then begin
                        Rec."Vendor No." := Vendor."No.";
                        Clear(Rec."No.");
                    end else
                        Error(Text001);
                end;

                GetInventorySetup();
                InventorySetup.TestField("Item Nos.");
                if RetailSetup."Itemgroup Pre No. Serie" <> '' then begin
                    NoSeriesManagement.InitSeries(ItemGroup."No. Series", xRec."No. Series", 0D, Rec."No.", Rec."No. Series");
                    ItemGroup.TestField("No. Series");
                end else
                    NoSeriesManagement.InitSeries(InventorySetup."Item Nos.", xRec."No. Series", 0D, Rec."No.", Rec."No. Series");
                Rec."No." := Rec."NPR Item Group" + Rec."No.";

                if RetailSetup."Item Description at 2 star" then
                    if ItemGroup.Get(Rec."NPR Item Group") then
                        Rec.Description := ItemGroup.Description;
                Rec.Validate(Description);
            end;
        end;

        Rec.Validate("NPR Item Group");
    end;

    local procedure UpdateVendorItemRef(var Item: Record Item; xItem: Record Item)
    var
        ItemReference: Record "Item Reference";
    begin
        if Item.IsTemporary then
            exit;
        if (Item."Vendor No." = xItem."Vendor No.") and (Item."Vendor Item No." = xItem."Vendor Item No.") then
            exit;

        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Variant Code", '');
        ItemReference.SetRange("Unit of Measure", xItem."Base Unit of Measure");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", xItem."Vendor No.");
        ItemReference.SetRange("Reference No.", xItem."Vendor Item No.");
        ItemReference.DeleteAll(true);

        if (Item."Vendor No." = '') or (Item."Vendor Item No." = '') then
            exit;

        if not ItemReference.Get(Item."No.", '', Item."Base Unit of Measure", ItemReference."Reference Type"::Vendor, Item."Vendor No.", Item."Vendor Item No.") then begin
            ItemReference.Init;
            ItemReference."Item No." := Item."No.";
            ItemReference."Variant Code" := '';
            ItemReference."Unit of Measure" := Item."Base Unit of Measure";
            ItemReference."Reference Type" := ItemReference."Reference Type"::Vendor;
            ItemReference."Reference Type No." := Item."Vendor No.";
            ItemReference."Reference No." := Item."Vendor Item No.";
            ItemReference.Description := '';
            ItemReference.Insert(true);
        end;
    end;
}