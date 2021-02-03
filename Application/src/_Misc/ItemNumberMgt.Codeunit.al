codeunit 6060042 "NPR Item Number Mgt."
{
    var
        ExternalBarcodeErr: Label '%1 is not an External Barcode because it starts with 2.', Comment = '%1 = Barcode';
        InternalBarcodeErr: Label '%1 is not an Internal Barcode because it does not start with 2.', Comment = '%1 = Barcode';

    procedure FindItemInfo(ExternalItemNo: Text[50]; ExternalType: Option All,VendorItemNo,Barcode,CrossReference,AlternativeNo; SkipBlocked: Boolean; var UnitOfMeasure: Code[10]; var VendorNo: Code[20]; var ItemNo: Code[20]; var VariantCode: Code[20]) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemUOM: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        ItemVendor: Record "Item Vendor";
        AlternativeNo: Record "NPR Alternative No.";
        SKU: Record "Stockkeeping Unit";
        UOMCodeSpecified: Boolean;
        VendorNoSpecified: Boolean;
    begin
        if FindItemInfoBlocked(ExternalItemNo,
                               ExternalType,
                               false,
                               UnitOfMeasure,
                               VendorNo,
                               ItemNo,
                               VariantCode) then
            exit(true);
        if not SkipBlocked then
            if FindItemInfoBlocked(ExternalItemNo,
                               ExternalType,
                               true,
                               UnitOfMeasure,
                               VendorNo,
                               ItemNo,
                               VariantCode) then
                exit(true);
        exit(false);
    end;

    local procedure FindItemInfoBlocked(ExternalItemNo: Text[50]; ExternalType: Option All,VendorItemNo,Barcode,CrossReference,AlternativeNo; Blocked: Boolean; var UnitOfMeasure: Code[10]; var VendorNo: Code[20]; var ItemNo: Code[20]; var VariantCode: Code[20]) Found: Boolean
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemUOM: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        ItemVendor: Record "Item Vendor";
        NonstockItem: Record "Nonstock Item";
        AlternativeNo: Record "NPR Alternative No.";
        SKU: Record "Stockkeeping Unit";
        UOMCodeSpecified: Boolean;
        VendorNoSpecified: Boolean;
    begin
        if ExternalItemNo = '' then
            exit(false);
        VendorNoSpecified := VendorNo <> '';
        UOMCodeSpecified := UnitOfMeasure <> '';

        if ExternalType in [ExternalType::All, ExternalType::CrossReference, ExternalType::Barcode] then begin
            if VendorNoSpecified then begin
                //Search Vendor Specific Cross Reference
                ItemCrossReference.SetCurrentKey("Cross-Reference No.");
                ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Vendor);
                ItemCrossReference.SetRange("Cross-Reference Type No.", VendorNo);
                if UOMCodeSpecified then
                    ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', UnitOfMeasure, '');
                ItemCrossReference.SetRange("Cross-Reference No.", ExternalItemNo);
                if ItemCrossReference.FindSet() then
                    repeat
                        if Item.Get(ItemCrossReference."Item No.") then begin
                            if Item.Blocked = Blocked then begin
                                ItemNo := ItemCrossReference."Item No.";
                                VariantCode := ItemCrossReference."Variant Code";
                                if not VendorNoSpecified then begin
                                    if ItemCrossReference."Cross-Reference Type" = ItemCrossReference."Cross-Reference Type"::Vendor then begin
                                        VendorNo := ItemCrossReference."Cross-Reference Type No.";
                                    end else begin
                                        VendorNo := Item."Vendor No.";
                                    end;
                                end;
                                if not UOMCodeSpecified then
                                    UnitOfMeasure := ItemCrossReference."Unit of Measure";
                                exit(true);
                            end;
                        end;
                    until ItemCrossReference.Next() = 0;
            end;
            //Search Cross Reference
            ItemCrossReference.Reset();
            ItemCrossReference.SetCurrentKey("Cross-Reference No.");
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            if UOMCodeSpecified then
                ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', UnitOfMeasure, '');
            ItemCrossReference.SetRange("Cross-Reference No.", ExternalItemNo);
            if ItemCrossReference.FindSet() then
                repeat
                    if Item.Get(ItemCrossReference."Item No.") then begin
                        if Item.Blocked = Blocked then begin
                            ItemNo := ItemCrossReference."Item No.";
                            VariantCode := ItemCrossReference."Variant Code";
                            if not VendorNoSpecified then begin
                                if ItemCrossReference."Cross-Reference Type" = ItemCrossReference."Cross-Reference Type"::Vendor then begin
                                    VendorNo := ItemCrossReference."Cross-Reference Type No.";
                                end else begin
                                    VendorNo := Item."Vendor No.";
                                end;
                            end;
                            if not UOMCodeSpecified then
                                UnitOfMeasure := ItemCrossReference."Unit of Measure";
                            exit(true);
                        end;
                    end;
                until ItemCrossReference.Next() = 0;
        end;

        if ExternalType in [ExternalType::All, ExternalType::AlternativeNo, ExternalType::Barcode] then begin
            //Search Alternative No.
            AlternativeNo.Reset();
            AlternativeNo.SetCurrentKey("Alt. No.", Type);
            AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
            AlternativeNo.SetRange("Alt. No.", ExternalItemNo);
            if AlternativeNo.FindSet() then
                repeat
                    if Item.Get(AlternativeNo.Code) then begin
                        if Item.Blocked = Blocked then begin
                            ItemNo := AlternativeNo.Code;
                            VariantCode := AlternativeNo."Variant Code";
                            if not VendorNoSpecified then begin
                                VendorNo := Item."Vendor No.";
                            end;
                            exit(true);
                        end;
                    end;
                until ItemCrossReference.Next() = 0;
        end;

        if ExternalType in [ExternalType::All, ExternalType::VendorItemNo] then begin
            //Search Item Vendor
            ItemVendor.Reset();
            ItemVendor.SetRange("Vendor Item No.", ExternalItemNo);
            if VendorNoSpecified then
                ItemVendor.SetRange("Vendor No.", VendorNo);
            if ItemVendor.FindSet() then
                repeat
                    if Item.Get(ItemVendor."Item No.") then begin
                        if Item.Blocked = Blocked then begin
                            ItemNo := Item."No.";
                            VariantCode := ItemVendor."Variant Code";
                            if not VendorNoSpecified then begin
                                if ItemVendor."Vendor No." <> '' then
                                    VendorNo := ItemVendor."Vendor No."
                                else
                                    VendorNo := ItemVendor."Vendor No.";
                            end;
                            exit(true);
                        end;
                    end;
                until ItemVendor.Next() = 0;

            //Search SKU
            SKU.Reset();
            SKU.SetRange("Vendor Item No.", ExternalItemNo);
            if SKU.FindSet() then
                repeat
                    if Item.Get(SKU."Item No.") then begin
                        if Item.Blocked = Blocked then begin
                            ItemNo := Item."No.";
                            VariantCode := SKU."Variant Code";
                            if not VendorNoSpecified then begin
                                if SKU."Vendor No." <> '' then
                                    VendorNo := SKU."Vendor No."
                                else
                                    VendorNo := Item."Vendor No.";
                            end;
                            exit(true);
                        end;
                    end;
                until SKU.Next() = 0;

            //Search Item
            Item.Reset();
            Item.SetRange("Vendor Item No.", ExternalItemNo);
            Item.SetRange(Blocked, Blocked);
            if VendorNoSpecified then
                Item.SetRange("Vendor No.", VendorNo);
            if Item.FindFirst() then begin
                ItemNo := Item."No.";
                VariantCode := '';
                if not VendorNoSpecified then
                    VendorNo := Item."Vendor No.";
                exit(true);
            end;

            if VendorNoSpecified then begin
                NonstockItem.SetRange("Vendor No.", VendorNo);
                NonstockItem.SetRange("Vendor Item No.", ExternalItemNo);
                if NonstockItem.FindFirst() then begin
                    ItemNo := NonstockItem."Item No.";
                    exit(ItemNo <> '');
                end;
            end;
        end;
    end;

    procedure GetItemBarcode(ItemNo: Code[20]; VariantCode: Code[20]; UnitOfMeasure: Code[10]; VendorNo: Code[20]) BarCode: Code[20]
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemVendor: Record "Item Vendor";
        AlternativeNo: Record "NPR Alternative No.";
        SKU: Record "Stockkeeping Unit";
    begin
        if not Item.Get(ItemNo) then
            exit('');
        //Barcode: Vendor Specific
        if VendorNo <> '' then begin
            ItemCrossReference.Reset();
            ItemCrossReference.SetRange("Item No.", ItemNo);
            ItemCrossReference.SetRange("Variant Code", VariantCode);
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Vendor);
            ItemCrossReference.SetRange("Cross-Reference Type No.", VendorNo);
            if UnitOfMeasure <> '' then
                ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', Item."Base Unit of Measure", '');
            if ItemCrossReference.FindFirst() then begin
                exit(ItemCrossReference."Cross-Reference No.");
            end;
        end;
        //Barcode: General
        if BarCode = '' then begin
            ItemCrossReference.Reset();
            ItemCrossReference.SetRange("Item No.", ItemNo);
            ItemCrossReference.SetRange("Variant Code", VariantCode);
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            if UnitOfMeasure <> '' then
                ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', Item."Base Unit of Measure", '');
            if ItemCrossReference.FindFirst() then begin
                exit(ItemCrossReference."Cross-Reference No.");
            end else begin
                AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                AlternativeNo.SetRange(Code, ItemNo);
                AlternativeNo.SetRange("Variant Code", VariantCode);
                if AlternativeNo.FindFirst() then begin
                    exit(AlternativeNo."Alt. No.");
                end;
            end;
        end;
    end;

    procedure GetItemItemVendorNo(ItemNo: Code[20]; VariantCode: Code[20]; VendorNo: Code[20]) VendorItemNo: Text[30]
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemVendor: Record "Item Vendor";
        AlternativeNo: Record "NPR Alternative No.";
        SKU: Record "Stockkeeping Unit";
    begin
        if not Item.Get(ItemNo) then
            exit('');

        ItemVendor.Reset();
        ItemVendor.SetRange("Item No.", ItemNo);
        ItemVendor.SetRange("Variant Code", VariantCode);
        ItemVendor.SetRange("Vendor No.", VendorNo);
        if ItemVendor.FindFirst() then
            if ItemVendor."Vendor Item No." <> '' then
                exit(ItemVendor."Vendor Item No.");
        SKU.Reset();
        SKU.SetRange("Item No.", ItemNo);
        SKU.SetFilter("Variant Code", VariantCode);
        SKU.SetFilter("Vendor No.", '%1|%2', VendorNo, '');
        SKU.SetFilter("Vendor Item No.", '<>%1', '');
        if SKU.FindFirst() then
            exit(SKU."Vendor Item No.");

        exit(Item."Vendor Item No.");
    end;

    procedure UpdateBarcode(ItemNo: Code[20]; VariantCode: Code[20]; BarCode: Code[20]; BarCodeType: Option AltNo,CrossReference)
    var
        Item: Record Item;
        ItemCrossReference: Record "Item Cross Reference";
        ItemVariant: Record "Item Variant";
        AlternativeNo: Record "NPR Alternative No.";
    begin
        if BarCode = '' then
            exit;
        case BarCodeType of
            BarCodeType::AltNo:
                begin
                    //Search for Alternative No Based on existing Bar Codes
                    AlternativeNo.Reset();
                    AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                    AlternativeNo.SetRange(Code, ItemNo);
                    AlternativeNo.SetRange("Alt. No.", BarCode);
                    if not AlternativeNo.FindFirst() then begin
                        AlternativeNo.SetRange(Code);
                        if AlternativeNo.FindFirst() then begin
                            //Delete Barcode Linked to another item
                            AlternativeNo.Delete(true);
                        end;
                        AlternativeNo.Init;
                        AlternativeNo.Validate(Type, AlternativeNo.Type::Item);
                        AlternativeNo.Validate(Code, ItemNo);
                        AlternativeNo.Validate("Alt. No.", BarCode);
                        if Item.Get(ItemNo) then begin
                            AlternativeNo."Base Unit of Measure" := Item."Base Unit of Measure";
                            AlternativeNo."Sales Unit of Measure" := Item."Sales Unit of Measure";
                            AlternativeNo."Purch. Unit of Measure" := Item."Purch. Unit of Measure";
                        end;
                        AlternativeNo.Insert(true);
                    end;
                    if AlternativeNo."Variant Code" <> VariantCode then begin
                        AlternativeNo.Validate("Variant Code", VariantCode);
                        AlternativeNo.Modify(true);
                    end;
                end;
            BarCodeType::CrossReference:
                begin
                    //Search for Cross Reference based on existing Bar Codes
                    ItemCrossReference.Reset();
                    ItemCrossReference.SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                    ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                    ItemCrossReference.SetRange("Cross-Reference No.", BarCode);
                    ItemCrossReference.SetRange("Item No.", ItemNo);
                    ItemCrossReference.SetRange("Variant Code", VariantCode);
                    if not ItemCrossReference.FindFirst() then begin
                        ItemCrossReference.SetRange("Item No.");
                        ItemCrossReference.SetRange("Variant Code");
                        if ItemCrossReference.FindFirst() then begin
                            //Delete cross reference Linked to another Item/Variant
                            ItemCrossReference.Delete(true);
                        end;
                        ItemCrossReference.Init();
                        ItemCrossReference.Validate("Item No.", ItemNo);
                        ItemCrossReference.Validate("Variant Code", VariantCode);
                        ItemCrossReference.Validate("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
                        ItemCrossReference.Validate("Cross-Reference No.", BarCode);
                        if ItemCrossReference."Variant Code" <> '' then begin
                            if ItemVariant.Get(ItemNo, VariantCode) then begin
                                ItemCrossReference.Description := ItemVariant.Description;
                            end;
                        end else begin
                            if Item.Get(ItemNo) then begin
                                ItemCrossReference.Description := Item.Description;
                            end;
                        end;
                        ItemCrossReference.Insert(true);
                    end;
                end;
        end;
    end;

    procedure CheckInternalBarCode(BarCode: Code[20])
    begin
        if BarCode <> '' then
            if not IsInternalBarcode(BarCode) then
                Error(StrSubstNo(InternalBarcodeErr, BarCode));
    end;

    procedure CheckExternalBarCode(BarCode: Code[20])
    begin
        if BarCode <> '' then
            if IsInternalBarcode(BarCode) then
                Error(StrSubstNo(ExternalBarcodeErr, BarCode));
    end;

    procedure IsInternalBarcode(BarCode: Code[20]): Boolean
    begin
        if BarCode = '' then
            exit(true);
        if CopyStr(BarCode, 1, 1) <> '2' then
            exit(false);
        exit(true);
    end;
}

