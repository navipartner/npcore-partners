codeunit 6014441 "NPR Event Subscriber (Item)"
{
    var
        InventorySetup: Record "Inventory Setup";
        SalesSetup: Record "Sales & Receivables Setup";
        InventorySetupFetched: Boolean;
        RetailSetupFetched: Boolean;
        SalesSetupFetched: Boolean;
        Error_LabelBarcode: Label 'Barcode %1 cannot be selected unless it is present in %2 for this item.';
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
        RetailItemSetup: Record "NPR Retail Item Setup";
        InvtSetup: Record "Inventory Setup";
        ItemGroup: Record "NPR Item Group";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        TempItem: Record Item temporary;
    begin
        if not RunTrigger then
            exit;

        GetSalesSetup;
        RetailItemSetup.Get();

        if RetailItemSetup."Item Group on Creation" and (Rec."No." = '') and (Rec."NPR Item Group" = '') then begin
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
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        SalesLinePOS: Record "NPR Sale Line POS";
        POSEntry: Record "NPR POS Entry";
    begin
        if not RunTrigger then
            exit;

        POSEntry.SetRange("Customer No.", Rec."No.");
        POSEntry.SetRange("Post Entry Status", POSEntry."Post Entry Status"::Unposted);
        if POSEntry.FindFirst() then
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
        QtyDiscountLine: Record "NPR Quantity Discount Line";
    begin
        if not RunTrigger then
            exit;

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

    [EventSubscriber(ObjectType::Table, 27, 'OnBeforeValidateEvent', 'Costing Method', true, false)]
    local procedure OnBeforeValidateEventCostingMethod(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    begin
        CheckGroupSale(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Unit Cost', true, false)]
    local procedure OnAfterValidateEventUnitCost(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
    begin
        UnitCostValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'Last Direct Cost', true, false)]
    local procedure OnAfterValidateEventLastDirectCost(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
    begin
        UnitCostValidation(Rec);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Item Group', true, false)]
    local procedure OnAfterValidateEventItemGroupLicenseCheck(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
    var
        ItemGroup: Record "NPR Item Group";
    begin
        if ItemGroup.Get(Rec."NPR Item Group") then
            ItemGroup.SetupItemFromGroup(Rec, ItemGroup);
    end;

    [EventSubscriber(ObjectType::Table, 27, 'OnAfterValidateEvent', 'NPR Group sale', true, false)]
    local procedure OnAfterValidateEventGroupSaleLicenseCheck(var Rec: Record Item; var xRec: Record Item; CurrFieldNo: Integer)
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
    var
        StaffSetup: Record "NPR Staff Setup";
    begin
        StaffSetup.Get();
        if StaffSetup."Staff SalesPrice Calc Codeunit" > 0 then
            Codeunit.Run(StaffSetup."Staff SalesPrice Calc Codeunit", Item);
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