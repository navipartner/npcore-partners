codeunit 6060042 "NPR Item Number Mgt."
{
    // NPR4.18\BR\20160209  CASE 182391 Object Created
    // NPR4.21\JDH\20160219 CASE 234022 function IsInternalBarcode made global
    // NPR5.23\BR\20160601  CASE 242498 Fix error when retrieving sku
    // NPR5.25\BR \20160701 CASE 242306 Fix error in cross reference
    // NPR5.29\BR \20161209 CASE 260757 Fill description of Barcode
    // NPR5.46\TJ \20180913 CASE 327174 Searching Nonstock Item as well based on VendorItemNo and VendorNo


    trigger OnRun()
    begin
    end;

    var
        Text001: Label '%1 is not an Internal Barcode because it does not start with 2.';
        Text002: Label '%1 is not an External Barcode because it starts with 2.';

    procedure FindItemInfo(ExternalItemNo: Text[50]; ExternalType: Option All,VendorItemNo,Barcode,CrossReference,AlternativeNo; SkipBlocked: Boolean; var UnitOfMeasure: Code[10]; var VendorNo: Code[20]; var ItemNo: Code[20]; var VariantCode: Code[20]) Found: Boolean
    var
        Item: Record Item;
        SKU: Record "Stockkeeping Unit";
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVendor: Record "Item Vendor";
        AlternativeNo: Record "NPR Alternative No.";
        UOMCodeSpecified: Boolean;
        VendorNoSpecified: Boolean;
    begin
        //Check unblocked
        if FindItemInfoBlocked(ExternalItemNo,
                               ExternalType,
                               false,
                               UnitOfMeasure,
                               VendorNo,
                               ItemNo,
                               VariantCode) then
            exit(true);
        if not SkipBlocked then
            //Check blocked
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
        SKU: Record "Stockkeeping Unit";
        ItemVariant: Record "Item Variant";
        ItemUOM: Record "Item Unit of Measure";
        ItemCrossReference: Record "Item Cross Reference";
        ItemVendor: Record "Item Vendor";
        AlternativeNo: Record "NPR Alternative No.";
        UOMCodeSpecified: Boolean;
        VendorNoSpecified: Boolean;
        NonstockItem: Record "Nonstock Item";
    begin
        if ExternalItemNo = '' then
            exit(false);
        VendorNoSpecified := VendorNo <> '';
        UOMCodeSpecified := UnitOfMeasure <> '';

        if ExternalType in [ExternalType::All, ExternalType::CrossReference, ExternalType::Barcode] then begin
            if VendorNoSpecified then begin
                //Search Vendor Specific Cross Reference
                ItemCrossReference.Reset;
                ItemCrossReference.SetCurrentKey("Cross-Reference No.");
                ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Vendor);
                ItemCrossReference.SetRange("Cross-Reference Type No.", VendorNo);
                if UOMCodeSpecified then
                    ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', UnitOfMeasure, '');
                ItemCrossReference.SetRange("Cross-Reference No.", ExternalItemNo);
                if ItemCrossReference.FindSet then
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
                    until ItemCrossReference.Next = 0;
            end;
            //Search Cross Reference
            ItemCrossReference.Reset;
            ItemCrossReference.SetCurrentKey("Cross-Reference No.");
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            if UOMCodeSpecified then
                ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', UnitOfMeasure, '');
            ItemCrossReference.SetRange("Cross-Reference No.", ExternalItemNo);
            if ItemCrossReference.FindSet then
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
                until ItemCrossReference.Next = 0;
        end;

        if ExternalType in [ExternalType::All, ExternalType::AlternativeNo, ExternalType::Barcode] then begin
            //Search Alternative No.
            AlternativeNo.Reset;
            AlternativeNo.SetCurrentKey("Alt. No.", Type);
            AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
            AlternativeNo.SetRange("Alt. No.", ExternalItemNo);
            if AlternativeNo.FindSet then
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
                until ItemCrossReference.Next = 0;
        end;

        if ExternalType in [ExternalType::All, ExternalType::VendorItemNo] then begin
            //Search Item Vendor
            ItemVendor.Reset;
            ItemVendor.SetRange("Vendor Item No.", ExternalItemNo);
            if VendorNoSpecified then
                ItemVendor.SetRange("Vendor No.", VendorNo);
            if ItemVendor.FindSet then
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
                //-NPR5.23 [242498]
                //UNTIL SKU.NEXT = 0;
                until ItemVendor.Next = 0;
            //+NPR5.23 [242498]

            //Search SKU
            SKU.Reset;
            SKU.SetRange("Vendor Item No.", ExternalItemNo);
            if SKU.FindSet then
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
                until SKU.Next = 0;

            //Search Item
            Item.Reset;
            Item.SetRange("Vendor Item No.", ExternalItemNo);
            Item.SetRange(Blocked, Blocked);
            if VendorNoSpecified then
                Item.SetRange("Vendor No.", VendorNo);
            if Item.FindFirst then begin
                ItemNo := Item."No.";
                VariantCode := '';
                if not VendorNoSpecified then
                    VendorNo := Item."Vendor No.";
                exit(true);
            end;

            //-NPR5.46 [327174]
            if VendorNoSpecified then begin
                NonstockItem.SetRange("Vendor No.", VendorNo);
                NonstockItem.SetRange("Vendor Item No.", ExternalItemNo);
                if NonstockItem.FindFirst then begin
                    ItemNo := NonstockItem."Item No.";
                    exit(ItemNo <> '');
                end;
            end;
            //+NPR5.46 [327174]
        end;
    end;

    procedure GetItemBarcode(ItemNo: Code[20]; VariantCode: Code[20]; UnitOfMeasure: Code[10]; VendorNo: Code[20]) BarCode: Code[20]
    var
        Item: Record Item;
        AlternativeNo: Record "NPR Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        SKU: Record "Stockkeeping Unit";
        ItemVendor: Record "Item Vendor";
    begin
        if not Item.Get(ItemNo) then
            exit('');
        //Barcode: Vendor Specific
        if VendorNo <> '' then begin
            ItemCrossReference.Reset;
            ItemCrossReference.SetRange("Item No.", ItemNo);
            ItemCrossReference.SetRange("Variant Code", VariantCode);
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::Vendor);
            ItemCrossReference.SetRange("Cross-Reference Type No.", VendorNo);
            if UnitOfMeasure <> '' then
                ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', Item."Base Unit of Measure", '');
            if ItemCrossReference.FindFirst then begin
                exit(ItemCrossReference."Cross-Reference No.");
            end;
        end;
        //Barcode: General
        if BarCode = '' then begin
            ItemCrossReference.Reset;
            ItemCrossReference.SetRange("Item No.", ItemNo);
            ItemCrossReference.SetRange("Variant Code", VariantCode);
            ItemCrossReference.SetRange("Cross-Reference Type", ItemCrossReference."Cross-Reference Type"::"Bar Code");
            if UnitOfMeasure <> '' then
                ItemCrossReference.SetFilter("Unit of Measure", '%1|%2', Item."Base Unit of Measure", '');
            if ItemCrossReference.FindFirst then begin
                exit(ItemCrossReference."Cross-Reference No.");
            end else begin
                AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                AlternativeNo.SetRange(Code, ItemNo);
                AlternativeNo.SetRange("Variant Code", VariantCode);
                if AlternativeNo.FindFirst then begin
                    exit(AlternativeNo."Alt. No.");
                end;
            end;
        end;
    end;

    procedure GetItemItemVendorNo(ItemNo: Code[20]; VariantCode: Code[20]; VendorNo: Code[20]) VendorItemNo: Text[30]
    var
        Item: Record Item;
        AlternativeNo: Record "NPR Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        SKU: Record "Stockkeeping Unit";
        ItemVendor: Record "Item Vendor";
    begin
        if not Item.Get(ItemNo) then
            exit('');

        //Item vendor
        ItemVendor.Reset;
        ItemVendor.SetRange("Item No.", ItemNo);
        ItemVendor.SetRange("Variant Code", VariantCode);
        ItemVendor.SetRange("Vendor No.", VendorNo);
        if ItemVendor.FindFirst then
            if ItemVendor."Vendor Item No." <> '' then
                exit(ItemVendor."Vendor Item No.");

        //SKU
        //+NPR5.23 [242498]
        //IF SKU.GET(ItemNo,VariantCode) THEN
        // IF (VendorNo = '') OR (SKU."Vendor No." = VendorNo) THEN
        //  IF SKU."Vendor Item No." <> '' THEN
        SKU.Reset;
        SKU.SetRange("Item No.", ItemNo);
        SKU.SetFilter("Variant Code", VariantCode);
        SKU.SetFilter("Vendor No.", '%1|%2', VendorNo, '');
        SKU.SetFilter("Vendor Item No.", '<>%1', '');
        if SKU.FindFirst then
            //+NPR5.23 [242498];
            exit(SKU."Vendor Item No.");

        //Item
        exit(Item."Vendor Item No.");
    end;

    procedure UpdateBarcode(ItemNo: Code[20]; VariantCode: Code[20]; BarCode: Code[20]; BarCodeType: Option AltNo,CrossReference)
    var
        AlternativeNo: Record "NPR Alternative No.";
        ItemCrossReference: Record "Item Cross Reference";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
    begin
        if BarCode = '' then
            exit;
        case BarCodeType of
            BarCodeType::AltNo:
                begin
                    with AlternativeNo do begin
                        //Search for Alternative No Based on existing Bar Codes
                        Reset;
                        SetRange(Type, Type::Item);
                        SetRange(Code, ItemNo);
                        SetRange("Alt. No.", BarCode);
                        if not FindFirst then begin
                            SetRange(Code);
                            if FindFirst then begin
                                //Delete Barcode Linked to another item
                                Delete(true);
                            end;
                            Init;
                            Validate(Type, Type::Item);
                            Validate(Code, ItemNo);
                            Validate("Alt. No.", BarCode);
                            if Item.Get(ItemNo) then begin
                                "Base Unit of Measure" := Item."Base Unit of Measure";
                                "Sales Unit of Measure" := Item."Sales Unit of Measure";
                                "Purch. Unit of Measure" := Item."Purch. Unit of Measure";
                            end;
                            Insert(true);
                        end;
                        if "Variant Code" <> VariantCode then begin
                            Validate("Variant Code", VariantCode);
                            Modify(true);
                        end;
                    end;
                end;
            BarCodeType::CrossReference:
                begin
                    //Search for Cross Reference based on existing Bar Codes
                    with ItemCrossReference do begin
                        Reset;
                        SetCurrentKey("Cross-Reference Type", "Cross-Reference No.");
                        SetRange("Cross-Reference Type", "Cross-Reference Type"::"Bar Code");
                        SetRange("Cross-Reference No.", BarCode);
                        SetRange("Item No.", ItemNo);
                        //-NPR5.25
                        //SETRANGE("Variant Code",ItemNo);
                        SetRange("Variant Code", VariantCode);
                        //+NPR5.25
                        if not FindFirst then begin
                            SetRange("Item No.");
                            SetRange("Variant Code");
                            if FindFirst then begin
                                //Delete cross reference Linked to another Item/Variant
                                Delete(true);
                            end;
                            Init;
                            Validate("Item No.", ItemNo);
                            Validate("Variant Code", VariantCode);
                            Validate("Cross-Reference Type", "Cross-Reference Type"::"Bar Code");
                            Validate("Cross-Reference No.", BarCode);
                            //-NPR5.29 [260757]
                            if "Variant Code" <> '' then begin
                                if ItemVariant.Get(ItemNo, VariantCode) then begin
                                    Description := ItemVariant.Description;
                                end;
                            end else begin
                                if Item.Get(ItemNo) then begin
                                    Description := Item.Description;
                                end;
                            end;
                            //+NPR5.29 [260757]
                            Insert(true);
                        end;
                    end;
                end;
        end;
    end;

    procedure CheckInternalBarCode(BarCode: Code[20])
    begin
        if BarCode <> '' then
            if not IsInternalBarcode(BarCode) then
                Error(StrSubstNo(Text001, BarCode));
    end;

    procedure CheckExternalBarCode(BarCode: Code[20])
    begin
        if BarCode <> '' then
            if IsInternalBarcode(BarCode) then
                Error(StrSubstNo(Text002, BarCode));
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

