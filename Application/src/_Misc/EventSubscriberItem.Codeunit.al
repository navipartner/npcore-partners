codeunit 6014441 "NPR Event Subscriber (Item)"
{
    trigger OnRun()
    begin
    end;

    var
        RetailSetup: Record "NPR Retail Setup";
        RetailSetupFetched: Boolean;
        InventorySetup: Record "Inventory Setup";
        InventorySetupFetched: Boolean;
        SalesSetup: Record "Sales & Receivables Setup";
        SalesSetupFetched: Boolean;
        Error_LabelBarcode: Label 'Barcode %1 cannot be selected unless it is present in %2 or %3 for this item.';
        Error_ItemCrossRef: Label 'Bar Code %1 cannot be linked to Item %2 if item %3 exits. ';
        ErrStd: Label 'Item %1 can''t be Group sale as it''s Costing Method is Standard.';
        Text000: Label 'Alternative No. %1 %2 already exists.';
        Text001: Label 'Can''t create number as no product group has been selected.';
        Text002: Label 'You can''t delete item %1 because it is part of an active sales document.';
        Text003: Label 'You can''t delete item %1 as there aren''t any posted entries for it.';
        Text004: Label 'You can''t delete %1 %2 as it''s contained in one or more period discount lines.';
        Text005: Label 'You can''t delete %1 %2 as it''s contained in one or more mixed discount lines.';

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeInsertEvent', '', true, false)]
    local procedure OnBeforeInsertEventLicenseCheck(var Rec: Record Item; RunTrigger: Boolean)
    var
        ItemGroup: Record "NPR Item Group";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        InvtSetup: Record "Inventory Setup";
        TempItem: Record Item temporary;
    begin
        Rec."NPR Last Changed at" := CurrentDateTime;
        Rec."NPR Last Changed by" := CopyStr(UserId, 1, MaxStrLen(Rec."NPR Last Changed by"));
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

        Rec."Last Date Modified" := Today;
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

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeModifyEvent', '', true, false)]
    local procedure OnBeforeModifyEventLicenseCheck(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        Rec."NPR Last Changed at" := CurrentDateTime;
        Rec."NPR Last Changed by" := CopyStr(UserId, 1, MaxStrLen(Rec."NPR Last Changed by"));
        if not RunTrigger then
            exit;

        Rec."Last Date Modified" := Today;
        Rec."NPR Primary Key Length" := StrLen(Rec."No."); //this line shouldn't be needed as primary key length can't be changed in modify trigger
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterModifyEvent', '', true, true)]
    local procedure OnAfterModifyEventLicenseCheck(var Rec: Record Item; var xRec: Record Item)
    begin
        UpdateVendorItemCrossRef(Rec, xRec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeDeleteEvent', '', true, false)]
    local procedure OnBeforeDeleteEventLicenseCheck(var Rec: Record Item; RunTrigger: Boolean)
    var
        AuditRoll: Record "NPR Audit Roll";
        SalesLinePOS: Record "NPR Sale Line POS";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
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
        Utility: Codeunit "NPR Utility";
        AlternativeNo: Record "NPR Alternative No.";
        Item: Record Item;
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
        RetailTableCode: Codeunit "NPR Std. Table Code";
        ItemGroup: Record "NPR Item Group";
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
        BarcodeLibrary: Codeunit "NPR Barcode Library";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        AltNo: Record "NPR Alternative No.";
        ItemCrossRef: Record "Item Cross Reference";
    begin
        if StrLen(Rec."NPR Label Barcode") > 0 then begin
            if BarcodeLibrary.TranslateBarcodeToItemVariant(Rec."NPR Label Barcode", ItemNo, VariantCode, ResolvingTable, false) then
                if (ItemNo = Rec."No.") and (ResolvingTable in [DATABASE::"NPR Alternative No.", DATABASE::"Item Cross Reference"]) then
                    exit;
            Error(Error_LabelBarcode, Rec."NPR Label Barcode", AltNo.TableCaption, ItemCrossRef.TableCaption);
        end;
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterRenameEvent', '', true, true)]
    local procedure OnAfterRenameItemCheckCrossRef(var Rec: Record Item; var xRec: Record Item; RunTrigger: Boolean)
    begin
        CheckCrossRefFromItem(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterInsertEvent', '', true, true)]
    local procedure OnAfterInsertItemCheckCrossRef(var Rec: Record Item; RunTrigger: Boolean)
    begin
        CheckCrossRefFromItem(Rec."No.");
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterInsertEvent', '', false, false)]
    local procedure OnAfterInsertCrossRefCheckCrossRef(var Rec: Record "Item Cross Reference"; RunTrigger: Boolean)
    begin
        CheckCrossRef(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterModifyEvent', '', false, false)]
    local procedure OnAfterModifyCrossRefCheckCrossRef(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; RunTrigger: Boolean)
    begin
        CheckCrossRef(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 5717, 'OnAfterRenameEvent', '', false, false)]
    local procedure OnAfterRenameCrossRefCheckCrossRef(var Rec: Record "Item Cross Reference"; var xRec: Record "Item Cross Reference"; RunTrigger: Boolean)
    begin
        CheckCrossRef(Rec);
    end;

    local procedure CheckCrossRefFromItem(ItemNumber: Code[20])
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
    begin
        exit;

        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SetRange("Cross-Reference No.", ItemNumber);
        ItemCrossReference.SetRange("Discontinue Bar Code", false);
        ItemCrossReference.SetFilter("Item No.", '<>%1', ItemNumber);
        if ItemCrossReference.FindFirst then
            Error(Error_ItemCrossRef, ItemCrossReference."Cross-Reference No.", ItemCrossReference."Item No.", ItemNumber);
    end;

    local procedure CheckCrossRef(ItemCrossReference: Record "Item Cross Reference")
    var
        Item: Record Item;
    begin
        exit;

        if StrLen(ItemCrossReference."Cross-Reference No.") > MaxStrLen(Item."No.") then
            exit;
        if ItemCrossReference."Item No." = ItemCrossReference."Cross-Reference No." then
            exit;
        if ItemCrossReference."Discontinue Bar Code" then
            exit;

        Item.SetRange("No.", ItemCrossReference."Cross-Reference No.");
        if not Item.FindFirst then
            exit;
        Error(Error_ItemCrossRef, ItemCrossReference."Cross-Reference No.", ItemCrossReference."Item No.", Item."No.");
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
        VendorList: Page "Vendor List";
        InternNo: Code[20];
        Utility: Codeunit "NPR Utility";
        ISBNBooklandEAN: Code[20];
        i: Integer;
        n: Integer;
        Check: Integer;
        Weight: Integer;
        Ciffer: Integer;
        Remainder: Integer;
        EndNo: Code[20];
        NoSeriesManagement: Codeunit NoSeriesManagement;
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

        if IsEan13(Rec."No.") then
            Rec."NPR Label Barcode" := Rec."No.";
        Rec.Validate("NPR Item Group");
    end;

    local procedure IsEan13(Input: Text): Boolean
    begin
        if StrLen(Input) <> 13 then
            exit(false);

        if DelChr(Input, '=', '0123456789') <> '' then
            exit(false);

        exit(StrCheckSum(Input, '1313131313131') = 0);
    end;

    local procedure UpdateVendorItemCrossRef(var Item: Record Item; xItem: Record Item)
    var
        ItemCrossReference: Record "Item Cross Reference";
    begin
        if Item.IsTemporary then
            exit;
        if (Item."Vendor No." = xItem."Vendor No.") and (Item."Vendor Item No." = xItem."Vendor Item No.") then
            exit;

        ItemCrossReference.SetRange("Item No.", Item."No.");
        ItemCrossReference.SetRange("Variant Code", '');
        ItemCrossReference.SetRange("Unit of Measure", xItem."Base Unit of Measure");
        ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Vendor);
        ItemCrossReference.SetRange("Cross-Reference Type No.", xItem."Vendor No.");
        ItemCrossReference.SetRange("Cross-Reference No.", xItem."Vendor Item No.");
        ItemCrossReference.DeleteAll(true);

        if (Item."Vendor No." = '') or (Item."Vendor Item No." = '') then
            exit;

        if not ItemCrossReference.Get(Item."No.", '', Item."Base Unit of Measure", ItemCrossReference."Cross-Reference Type"::Vendor, Item."Vendor No.", Item."Vendor Item No.") then begin
            ItemCrossReference.Init;
            ItemCrossReference."Item No." := Item."No.";
            ItemCrossReference."Variant Code" := '';
            ItemCrossReference."Unit of Measure" := Item."Base Unit of Measure";
            ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::Vendor;
            ItemCrossReference."Cross-Reference Type No." := Item."Vendor No.";
            ItemCrossReference."Cross-Reference No." := Item."Vendor Item No.";
            ItemCrossReference.Description := '';
            ItemCrossReference.Insert(true);
        end;
    end;
}