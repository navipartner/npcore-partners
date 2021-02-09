codeunit 6014528 "NPR Barcode Library"
{
    // Barcode Handling.
    // (Partially) By Thea Rasmussen.
    // 
    // "GenerateBarcode(BarCode : Code[20],VAR TempBlob : Record TempBlob)"
    //   Creates an image file containing the barcode.
    // 
    // "Init(BarCode : Code[20])"
    //   Initiates all the values. If none are set by the properties then default values are set.
    // 
    // "SetBarcodeType(BarcodeTypeTextIn : Code[10])"
    //   Code options for BarcodeType:'EAN13','CODE39','QR'.

    var
        BarCodeType: DotNet NPRNetBarCodeType;
        BarCodeSettings: DotNet NPRNetBarcodeSettings;
        BarCodeGenerator: DotNet NPRNetBarCodeGenerator;
        Image: DotNet NPRNetImage;
        Text007: Label 'Import';
        Text009: Label 'All Files (*.*)|*.*';
        ImageFormat: DotNet NPRNetImageFormat;
        "-- Global": Integer;
        SizeX: Decimal;
        SizeY: Decimal;
        DpiX: Decimal;
        DpiY: Decimal;
        RotateAngle: Integer;
        BarcodeTypeText: Code[10];
        TempItemRefNo: Code[50];
        ItemWithItemRefNoNotFoundErr: Label 'There are no items with reference: %1', Comment = '%1=TempItemRefNo';
        TransferLine: Record "Transfer Line";
        Found: Boolean;
        NoAA: Boolean;
        NoBarcodeText: Boolean;
        Text001: Label 'Status should not be %1.';

    local procedure "-- Print Functions"()
    begin
    end;

    procedure GenerateBarcode(BarCode: Code[20]; var TempBlob: Codeunit "Temp Blob")
    var
        MemoryStream: DotNet NPRNetMemoryStream;
        OutStream: OutStream;
    begin
        Initialize(BarCode);

        BarCodeGenerator := BarCodeGenerator.BarCodeGenerator(BarCodeSettings);
        BarCodeSettings.ApplyKey('3YOZI-9N0S5-RD239-JN9R0-WCGL8');
        Image := BarCodeGenerator.GenerateImage();

        MemoryStream := MemoryStream.MemoryStream;
        Image.Save(MemoryStream, ImageFormat.Png);
        Clear(TempBlob);
        TempBlob.CreateOutStream(OutStream);
        CopyStream(OutStream, MemoryStream);
    end;

    local procedure Initialize(BarCode: Code[20])
    begin
        BarCodeSettings := BarCodeSettings.BarcodeSettings();
        BarCodeSettings.Data := BarCode;

        if SizeX <> 0 then BarCodeSettings.X := SizeX;
        if SizeY <> 0 then BarCodeSettings.Y := SizeY;
        if DpiX <> 0 then BarCodeSettings.DpiX := DpiX;
        if DpiY <> 0 then BarCodeSettings.DpiY := DpiY;
        if RotateAngle <> 0 then BarCodeSettings.Rotate := RotateAngle;
        //-NPR5.27
        BarCodeSettings.ShowText := not NoBarcodeText;
        BarCodeSettings.UseAntiAlias := not NoAA;
        //+NPR5.27

        case UpperCase(BarcodeTypeText) of
            'EAN13':
                BarCodeSettings.Type := BarCodeType.EAN13;
            'CODE39':
                BarCodeSettings.Type := BarCodeType.Code39;
            //-NPR5.27
            'QR':
                BarCodeSettings.Type := BarCodeType.QRCode;
            //+NPR5.27
            //-NPR5.29 [245881]
            'CODE128':
                BarCodeSettings.Type := BarCodeType.Code128;
            //+NPR5.29 [245881]
            else begin
                    if StrLen(BarCode) = 13 then
                        BarCodeSettings.Type := BarCodeType.EAN13
                    else
                        BarCodeSettings.Type := BarCodeType.Code39;
                end;
        end;
    end;

    procedure SetSizeX(Size: Decimal)
    begin
        SizeX := Size;
    end;

    procedure SetSizeY(Size: Decimal)
    begin
        SizeY := Size;
    end;

    procedure SetDpiX(X: Integer)
    begin
        DpiX := X;
    end;

    procedure SetDpiY(Y: Integer)
    begin
        DpiY := Y;
    end;

    procedure Rotate(RotateAngleIn: Integer)
    begin
        RotateAngle := RotateAngleIn;
    end;

    procedure SetBarcodeType(BarcodeTypeTextIn: Code[10])
    begin
        BarcodeTypeText := BarcodeTypeTextIn;
    end;

    procedure SetAntiAliasing(UseAntiAliasingIn: Boolean)
    begin
        //-NPR5.27
        NoAA := not UseAntiAliasingIn;
        //+NPR5.27
    end;

    procedure SetShowText(ShowTextIn: Boolean)
    begin
        //-NPR5.27
        NoBarcodeText := not ShowTextIn;
        //+NPR5.27
    end;

    local procedure "-- Lookup Functions"()
    begin
    end;

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer; AllowDiscontinued: Boolean) Found: Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        AlternativeNo: Record "NPR Alternative No.";
        ItemVariant: Record "Item Variant";
    begin
        ResolvingTable := 0;
        ItemNo := '';
        VariantCode := '';
        if (Barcode = '') then exit(false);


        if (StrLen(Barcode) <= MaxStrLen(ItemReference."Reference No.")) then begin
            ItemReference.SetCurrentKey("Reference Type", "Reference No.");
            ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference No.", '=%1', UpperCase(Barcode));
            if not AllowDiscontinued then
                ItemReference.SetFilter("Discontinue Bar Code", '=%1', false);
            if ItemReference.FindFirst() then begin
                if (not Item.Get(ItemReference."Item No.")) then
                    exit(false);
                if (ItemReference."Variant Code" <> '') then
                    if (not ItemVariant.Get(ItemReference."Item No.", ItemReference."Variant Code")) then
                        exit(false);
                ResolvingTable := DATABASE::"Item Reference";
                ItemNo := ItemReference."Item No.";
                VariantCode := ItemReference."Variant Code";
                exit(true);
            end;
        end;

        with AlternativeNo do begin
            if (StrLen(Barcode) <= MaxStrLen("Alt. No.")) then begin
                SetCurrentKey("Alt. No.", Type);
                SetFilter("Alt. No.", '=%1', UpperCase(Barcode));
                SetFilter(Type, '=%1', Type::Item);
                if not AllowDiscontinued then
                    SetFilter(Discontinue, '=%1', false);
                if (FindFirst()) then begin
                    if (Item.Get(Code) = false) then
                        exit(false);
                    if ("Variant Code" <> '') then
                        if (ItemVariant.Get(Code, "Variant Code") = false) then
                            exit(false);
                    ResolvingTable := DATABASE::"NPR Alternative No.";
                    ItemNo := Code;
                    VariantCode := "Variant Code";
                    exit(true);
                end;
            end;
        end;

        if (StrLen(Barcode) <= MaxStrLen(Item."No.")) then begin
            if (Item.Get(UpperCase(Barcode))) then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        with Item do begin
            if (StrLen(Barcode) <= MaxStrLen("Vendor Item No.")) then begin
                SetCurrentKey("Vendor Item No.", "Vendor No.");
                SetRange("Vendor Item No.", Barcode);
                if FindFirst() then begin
                    ResolvingTable := DATABASE::Item;
                    ItemNo := "No.";
                    exit(true);
                end;
            end;
        end;

        exit(false);
    end;

    procedure GetItemVariantBarcode(var Barcode: Text[50]; ItemNo: Code[20]; VariantCode: Code[10]; var ResolvingTable: Integer; AllowDiscontinued: Boolean): Boolean
    var
        AlternativeNo: Record "NPR Alternative No.";
        ItemReference: Record "Item Reference";
        Item: Record Item;
    begin
        Barcode := '';
        ResolvingTable := 0;

        if (VariantCode = '') and Item.Get(ItemNo) then
            if Item."NPR Label Barcode" <> '' then begin
                Barcode := Item."NPR Label Barcode";
                ResolvingTable := DATABASE::Item;
                exit(true);
            end;

        if (StrLen(ItemNo) <= MaxStrLen(ItemReference."Item No.")) and (StrLen(VariantCode) <= MaxStrLen(ItemReference."Variant Code")) then begin
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Item No.", ItemNo);
            ItemReference.SetRange("Variant Code", VariantCode);
            if not AllowDiscontinued then
                ItemReference.SetRange("Discontinue Bar Code", false);
            if ItemReference.FindFirst() then begin
                Barcode := ItemReference."Reference No.";
                ResolvingTable := DATABASE::"Item Reference";
                exit(true);
            end;
        end;

        with AlternativeNo do begin
            if (StrLen(ItemNo) <= MaxStrLen(Code)) and (StrLen(VariantCode) <= MaxStrLen("Variant Code")) then begin
                SetRange(Type, Type::Item);
                SetRange(Code, ItemNo);
                SetRange("Variant Code", VariantCode);
                if not AllowDiscontinued then
                    SetRange(Discontinue, false);
                if FindFirst then begin
                    Barcode := "Alt. No.";
                    ResolvingTable := DATABASE::"NPR Alternative No.";
                    exit(true);
                end;
            end;
        end;

        if (VariantCode = '') and Item.Get(ItemNo) then begin
            Barcode := ItemNo;
            ResolvingTable := DATABASE::Item;
            exit(true);
        end;

        exit(false);
    end;

    [EventSubscriber(ObjectType::Table, 5741, 'OnAfterValidateEvent', 'NPR Cross-Reference No.', false, false)]
    local procedure ResolveBarcodeTransferLine(var Rec: Record "Transfer Line"; var xRec: Record "Transfer Line"; CurrFieldNo: Integer)
    var
        ReturnedItemRef: Record "Item Reference";
    begin
        with Rec do begin
            GetTransferHeader(Rec);
            ReturnedItemRef.Init;
            if "NPR Cross-Reference No." <> '' then begin
                ICRLookupTransferItem(Rec, ReturnedItemRef);
                Validate("Item No.", ReturnedItemRef."Item No.");
                if ReturnedItemRef."Variant Code" <> '' then
                    Validate("Variant Code", ReturnedItemRef."Variant Code");
                if ReturnedItemRef."Unit of Measure" <> '' then
                    Validate("Unit of Measure Code", ReturnedItemRef."Unit of Measure");
            end;
            "NPR Cross-Reference No." := ReturnedItemRef."Reference No.";
            if ReturnedItemRef.Description <> '' then
                Description := ReturnedItemRef.Description;
        end;
    end;

    local procedure GetTransferHeader(var TransferLine2: Record "Transfer Line")
    var
        TransHeader: Record "Transfer Header";
    begin
        with TransferLine2 do begin
            TestField("Document No.");
            if "Document No." <> TransHeader."No." then
                TransHeader.Get("Document No.");

            TransHeader.TestField("Shipment Date");
            TransHeader.TestField("Receipt Date");
            TransHeader.TestField("Transfer-from Code");
            TransHeader.TestField("Transfer-to Code");
            TransHeader.TestField("In-Transit Code");
            "In-Transit Code" := TransHeader."In-Transit Code";
            "Transfer-from Code" := TransHeader."Transfer-from Code";
            "Transfer-to Code" := TransHeader."Transfer-to Code";
            "Shipment Date" := TransHeader."Shipment Date";
            "Receipt Date" := TransHeader."Receipt Date";
            "Shipping Agent Code" := TransHeader."Shipping Agent Code";
            "Shipping Agent Service Code" := TransHeader."Shipping Agent Service Code";
            "Shipping Time" := TransHeader."Shipping Time";
            "Outbound Whse. Handling Time" := TransHeader."Outbound Whse. Handling Time";
            "Inbound Whse. Handling Time" := TransHeader."Inbound Whse. Handling Time";
            Status := TransHeader.Status;
        end;
    end;

    procedure EnterTransferItemCrossRef(var TransferLine: Record "Transfer Line")
    var
        AlternativeNo: Record "NPR Alternative No.";
        ItemReference: Record "Item Reference";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
    begin
        //-NPR5.23 [242315]
        with TransferLine do
            ItemReference.Reset();
        ItemReference.SetRange("Item No.", TransferLine."Item No.");
        ItemReference.SetRange("Variant Code", TransferLine."Variant Code");
        ItemReference.SetRange("Unit of Measure", TransferLine."Unit of Measure Code");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        if ItemReference.Find('-') then
            Found := true
        else begin
            ItemReference.SetRange("Reference No.");
            Found := ItemReference.Find('-');
        end;

        if not Found then begin
            AlternativeNo.Reset;
            AlternativeNo.SetCurrentKey(Code);
            AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
            AlternativeNo.SetRange(AlternativeNo.Code, TransferLine."Item No.");
            AlternativeNo.SetRange("Variant Code", TransferLine."Variant Code");
            if AlternativeNo.FindFirst then begin
                ItemReference."Item No." := AlternativeNo.Code;
                ItemReference."Reference No." := AlternativeNo."Alt. No.";
                ItemReference."Variant Code" := AlternativeNo."Variant Code";
                ItemReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
                if ItemVariant.Get(TransferLine."Item No.", TransferLine."Variant Code") then
                    ItemReference.Description := ItemVariant.Description;
                Found := true;
            end;
        end;

        if Found then begin
            TransferLine."NPR Cross-Reference No." := ItemReference."Reference No.";
            TransferLine."Unit of Measure Code" := ItemReference."Unit of Measure";
            if ItemReference.Description <> '' then begin
                TransferLine.Description := ItemReference.Description;
            end;
        end else begin
            if TransferLine."Variant Code" <> '' then begin
                ItemVariant.Get(TransferLine."Item No.", TransferLine."Variant Code");
                TransferLine.Description := ItemVariant.Description;
            end else begin
                Item.Get(TransferLine."Item No.");
                TransferLine.Description := Item.Description;
            end;
        end;
    end;

    procedure ICRLookupTransferItem(var TransferLine2: Record "Transfer Line"; var ReturnedItemRef: Record "Item Reference")
    var
        AlternativeNo: Record "NPR Alternative No.";
        ItemReference: Record "Item Reference";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
    begin
        TransferLine.Copy(TransferLine2);
        TempItemRefNo := TransferLine2."NPR Cross-Reference No.";
        ItemReference.Reset();
        ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.", "Discontinue Bar Code");
        ItemReference.SetRange("Reference No.", TransferLine."NPR Cross-Reference No.");
        ItemReference.SetRange("Discontinue Bar Code", false);
        ItemReference.SetFilter("Reference Type No.", '%1', '');
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");

        ItemReference.SetRange("Item No.", TransferLine."Item No.");
        if not ItemReference.Find('-') then begin
            ItemReference.SetRange("Item No.");
            if not ItemReference.Find('-') then begin
                AlternativeNo.Reset;
                AlternativeNo.SetCurrentKey("Alt. No.", Type);
                AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                AlternativeNo.SetRange("Alt. No.", TransferLine2."NPR Cross-Reference No.");
                if AlternativeNo.FindFirst then begin
                    ItemReference."Item No." := AlternativeNo.Code;
                    ItemReference."Reference No." := AlternativeNo."Alt. No.";
                    ItemReference."Variant Code" := AlternativeNo."Variant Code";
                    ItemReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                    ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
                    if ItemVariant.Get(TransferLine2."Item No.", TransferLine2."Variant Code") then
                        ItemReference.Description := ItemVariant.Description;
                end else begin
                    Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo)
                end;
            end;
            if ItemReference.Next <> 0 then begin
                ItemReference.SetRange("Reference Type No.", '');
                if ItemReference.Find('-') then
                    if ItemReference.Next() <> 0 then begin
                        ItemReference.SetRange("Reference Type No.");
                        if TryAskUserForItemRef(ItemReference, TempItemRefNo) then;
                    end;
            end;
        end;
        ReturnedItemRef.Copy(ItemReference);
    end;

    [TryFunction]
    local procedure TryAskUserForItemRef(var ItemReference: Record "Item Reference"; EnterItemRefNo: Code[50])
    begin
        ItemReference.SetRange("Reference Type No.");
        if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) <> ACTION::LookupOK
        then
            Error(ItemWithItemRefNoNotFoundErr, EnterItemRefNo);
    end;

    [IntegrationEvent(TRUE, FALSE)]
    procedure CallItemReferenceNoLookUp(var TransferLine3: Record "Transfer Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014528, 'CallItemReferenceNoLookUp', '', true, false)]
    local procedure ItemReferenceNoLookUp(var Sender: Codeunit "NPR Barcode Library"; var TransferLine3: Record "Transfer Line")
    var
        ItemReference3: Record "Item Reference";
    begin
        with TransferLine3 do begin
            GetTransferHeader(TransferLine3);
            ItemReference3.Reset;
            ItemReference3.SetCurrentKey("Reference Type", "Reference Type No.");
            ItemReference3.SetFilter("Reference Type", '%1', ItemReference3."Reference Type"::" ");
            ItemReference3.SetFilter("Reference Type No.", '%1', '');
            if PAGE.RunModal(PAGE::"Item Reference List", ItemReference3) = ACTION::LookupOK then
                Validate("NPR Cross-Reference No.", ItemReference3."Reference No.");
        end;
    end;

    local procedure GetMixedDiscountHeader(var MixedDiscountLine: Record "NPR Mixed Discount Line")
    var
        MixedDiscount: Record "NPR Mixed Discount";
    begin
        MixedDiscount.Get(MixedDiscountLine.Code);
        if MixedDiscount.Status = MixedDiscount.Status::Active then
            Error(Text001, MixedDiscount.Status::Active);

    end;

    [IntegrationEvent(TRUE, false)]
    procedure CallItemRefNoLookupMixDiscount(var MixedDiscountLine: Record "NPR Mixed Discount Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014528, 'CallItemRefNoLookupMixDiscount', '', false, false)]
    local procedure ItemRefNoLookupMixDiscount(var Sender: Codeunit "NPR Barcode Library"; var MixedDiscountLine: Record "NPR Mixed Discount Line")
    var
        ItemReference2: Record "Item Reference";
    begin
        with MixedDiscountLine do begin
            if "Disc. Grouping Type" <> "Disc. Grouping Type"::Item then
                exit;
            GetMixedDiscountHeader(MixedDiscountLine);
            ItemReference2.Reset;
            ItemReference2.SetCurrentKey("Reference Type", "Reference Type No.");
            ItemReference2.SetFilter("Reference Type", '%1', ItemReference2."Reference Type"::"Bar Code");
            ItemReference2.SetFilter("Reference Type No.", '%1', '');
            if PAGE.RunModal(PAGE::"Item Reference List", ItemReference2) = ACTION::LookupOK then begin
                "No." := ItemReference2."Item No.";
                Validate("Cross-Reference No.", ItemReference2."Reference No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6014412, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnAfterValidateItemRefMixDiscount(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; CurrFieldNo: Integer)
    var
        ReturnedItemRef: Record "Item Reference";
    begin
        ReturnedItemRef.Init;
        if Rec."Cross-Reference No." <> '' then begin
            ICRLookupMixedDiscount(Rec, ReturnedItemRef);
            Rec.Validate("No.", ReturnedItemRef."Item No.");
            if ReturnedItemRef."Variant Code" <> '' then
                Rec.Validate("Variant Code", ReturnedItemRef."Variant Code");
        end;
        Rec."Cross-Reference No." := ReturnedItemRef."Reference No.";
        if ReturnedItemRef.Description <> '' then
            Rec.Description := ReturnedItemRef.Description;
    end;

    procedure ICRLookupMixedDiscount(var MixedDiscountLine2: Record "NPR Mixed Discount Line"; var ReturnedItemRef: Record "Item Reference")
    var
        AlternativeNo: Record "NPR Alternative No.";
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        ItemReference: Record "Item Reference";
        ItemVariant: Record "Item Variant";
    begin
        MixedDiscountLine.Copy(MixedDiscountLine2);
        if MixedDiscountLine."Disc. Grouping Type" = MixedDiscountLine."Disc. Grouping Type"::Item then begin
            TempItemRefNo := MixedDiscountLine2."Cross-Reference No.";
            ItemReference.Reset();
            ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.", "Discontinue Bar Code");
            ItemReference.SetRange("Reference No.", MixedDiscountLine."Cross-Reference No.");
            ItemReference.SetRange("Discontinue Bar Code", false);
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference Type No.", '%1', '');
            ItemReference.SetRange("Item No.", MixedDiscountLine."No.");
            if not ItemReference.Find('-') then begin
                ItemReference.SetRange("Item No.");
                if not ItemReference.Find('-') then begin
                    AlternativeNo.Reset;
                    AlternativeNo.SetCurrentKey("Alt. No.", Type);
                    AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                    AlternativeNo.SetRange("Alt. No.", MixedDiscountLine2."Cross-Reference No.");
                    if AlternativeNo.FindFirst then begin
                        ItemReference."Item No." := AlternativeNo.Code;
                        ItemReference."Reference No." := AlternativeNo."Alt. No.";
                        ItemReference."Variant Code" := AlternativeNo."Variant Code";
                        ItemReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                        ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
                        if ItemVariant.Get(MixedDiscountLine2."No.", MixedDiscountLine2."Variant Code") then
                            ItemReference.Description := ItemVariant.Description;
                    end else begin
                        Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo)
                    end;
                end;
                if ItemReference.Next <> 0 then begin
                    ItemReference.SetRange("Reference Type No.", '');
                    if ItemReference.Find('-') then
                        if ItemReference.Next <> 0 then begin
                            ItemReference.SetRange("Reference Type No.");
                            if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) <> ACTION::LookupOK
                            then
                                Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo);
                        end;
                end;
            end;
            ReturnedItemRef.Copy(ItemReference);
        end;
    end;

    local procedure GetPeriodicDiscountHeader(var PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        PeriodDiscount: Record "NPR Period Discount";
    begin
        PeriodDiscount.Get(PeriodDiscountLine.Code);
        if PeriodDiscount.Status = PeriodDiscount.Status::Active then
            Error(Text001, PeriodDiscount.Status::Active);
    end;

    [IntegrationEvent(TRUE, false)]
    procedure CallItemRefNoLookupPeriodicDiscount(var PeriodDiscountLine: Record "NPR Period Discount Line")
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014528, 'CallItemRefNoLookupPeriodicDiscount', '', false, false)]
    local procedure ItemRefNoLookupPeriodicDiscount(var Sender: Codeunit "NPR Barcode Library"; var PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        ItemReference2: Record "Item Reference";
    begin
        with PeriodDiscountLine do begin
            GetPeriodicDiscountHeader(PeriodDiscountLine);
            ItemReference2.Reset;
            ItemReference2.SetCurrentKey("Reference Type", "Reference Type No.");
            ItemReference2.SetFilter("Reference Type", '%1', ItemReference2."Reference Type"::"Bar Code");
            ItemReference2.SetFilter("Reference Type No.", '%1', '');
            if PAGE.RunModal(PAGE::"Item Reference List", ItemReference2) = ACTION::LookupOK then begin
                "Item No." := ItemReference2."Item No.";
                Validate("Cross-Reference No.", ItemReference2."Reference No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6014414, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnAfterValidateItemRefPeriodicDiscount(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; CurrFieldNo: Integer)
    var
        ReturnedItemRef: Record "Item Reference";
    begin
        with Rec do begin
            ReturnedItemRef.Init;
            if "Cross-Reference No." <> '' then begin
                ICRLookupPeriodicDiscount(Rec, ReturnedItemRef);
                Validate("Item No.", ReturnedItemRef."Item No.");
                if ReturnedItemRef."Variant Code" <> '' then
                    Validate("Variant Code", ReturnedItemRef."Variant Code");
            end;
            "Cross-Reference No." := ReturnedItemRef."Reference No.";
            if ReturnedItemRef.Description <> '' then
                Description := ReturnedItemRef.Description;
        end;
    end;

    procedure ICRLookupPeriodicDiscount(var PeriodDiscountLine2: Record "NPR Period Discount Line"; var ReturnedItemRef: Record "Item Reference")
    var
        AlternativeNo: Record "NPR Alternative No.";
        PeriodDiscountLine: Record "NPR Period Discount Line";
        ItemReference: Record "Item Reference";
        ItemVariant: Record "Item Variant";
    begin
        PeriodDiscountLine.Copy(PeriodDiscountLine2);
        TempItemRefNo := PeriodDiscountLine2."Cross-Reference No.";
        ItemReference.Reset();
        ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.", "Discontinue Bar Code");
        ItemReference.SetRange("Reference No.", PeriodDiscountLine."Cross-Reference No.");
        ItemReference.SetRange("Discontinue Bar Code", false);
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetFilter("Reference Type No.", '%1', '');
        ItemReference.SetRange("Item No.", PeriodDiscountLine."Item No.");
        if not ItemReference.Find('-') then begin
            ItemReference.SetRange("Item No.");
            if not ItemReference.Find('-') then begin
                AlternativeNo.Reset;
                AlternativeNo.SetCurrentKey("Alt. No.", Type);
                AlternativeNo.SetRange(Type, AlternativeNo.Type::Item);
                AlternativeNo.SetRange("Alt. No.", PeriodDiscountLine2."Cross-Reference No.");
                if AlternativeNo.FindFirst then begin
                    ItemReference."Item No." := AlternativeNo.Code;
                    ItemReference."Reference No." := AlternativeNo."Alt. No.";
                    ItemReference."Variant Code" := AlternativeNo."Variant Code";
                    ItemReference."Unit of Measure" := AlternativeNo."Base Unit of Measure";
                    ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
                    if ItemVariant.Get(PeriodDiscountLine2."Item No.", PeriodDiscountLine2."Variant Code") then
                        ItemReference.Description := ItemVariant.Description;
                end else begin
                    Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo)
                end;
            end;
            if ItemReference.Next() <> 0 then begin
                ItemReference.SetRange("Reference Type No.", '');
                if ItemReference.Find('-') then
                    if ItemReference.Next() <> 0 then begin
                        ItemReference.SetRange("Reference Type No.");
                        if PAGE.RunModal(PAGE::"Item Reference List", ItemReference) <> ACTION::LookupOK
                        then
                            Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo);
                    end;
            end;
        end;
        ReturnedItemRef.Copy(ItemReference);
    end;
}

