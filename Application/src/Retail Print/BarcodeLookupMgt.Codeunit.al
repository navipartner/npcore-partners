codeunit 6014403 "NPR Barcode Lookup Mgt."
{
    var
        ItemWithItemRefNoNotFoundErr: Label 'There are no items with reference: %1', Comment = '%1=TempItemRefNo';
        Text001: Label 'Status should not be %1.';

    procedure TranslateBarcodeToItemVariant(Barcode: Text[50]; var ItemNo: Code[20]; var VariantCode: Code[10]; var ResolvingTable: Integer; AllowDiscontinued: Boolean) Found: Boolean
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
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

        if (StrLen(Barcode) <= MaxStrLen(Item."No.")) then begin
            if (Item.Get(UpperCase(Barcode))) then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        if (StrLen(Barcode) <= MaxStrLen(Item."Vendor Item No.")) then begin
            Item.SetCurrentKey("Vendor Item No.", "Vendor No.");
            Item.SetRange("Vendor Item No.", Barcode);
            if Item.FindFirst() then begin
                ResolvingTable := DATABASE::Item;
                ItemNo := Item."No.";
                exit(true);
            end;
        end;

        exit(false);
    end;

    procedure GetItemVariantBarcode(var Barcode: Text[50]; ItemNo: Code[20]; VariantCode: Code[10]; var ResolvingTable: Integer; AllowDiscontinued: Boolean): Boolean
    var
        ItemReference: Record "Item Reference";
        Item: Record Item;
    begin
        Barcode := '';
        ResolvingTable := 0;

        if (StrLen(ItemNo) <= MaxStrLen(ItemReference."Item No.")) and (StrLen(VariantCode) <= MaxStrLen(ItemReference."Variant Code")) then begin
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetRange("Item No.", ItemNo);
            ItemReference.SetRange("Variant Code", VariantCode);
            if ItemReference.FindFirst() then begin
                Barcode := ItemReference."Reference No.";
                ResolvingTable := DATABASE::"Item Reference";
                exit(true);
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
        GetTransferHeader(Rec);
        ReturnedItemRef.Init();
        if Rec."NPR Cross-Reference No." <> '' then begin
            ICRLookupTransferItem(Rec, ReturnedItemRef);
            Rec.Validate("Item No.", ReturnedItemRef."Item No.");
            if ReturnedItemRef."Variant Code" <> '' then
                Rec.Validate("Variant Code", ReturnedItemRef."Variant Code");
            if ReturnedItemRef."Unit of Measure" <> '' then
                Rec.Validate("Unit of Measure Code", ReturnedItemRef."Unit of Measure");
        end;
        Rec."NPR Cross-Reference No." := ReturnedItemRef."Reference No.";
        if ReturnedItemRef.Description <> '' then
            Rec.Description := ReturnedItemRef.Description;
    end;

    local procedure GetTransferHeader(var TransferLine2: Record "Transfer Line")
    var
        TransHeader: Record "Transfer Header";
    begin
        TransferLine2.TestField("Document No.");
        if TransferLine2."Document No." <> TransHeader."No." then
            TransHeader.Get(TransferLine2."Document No.");

        TransHeader.TestField("Shipment Date");
        TransHeader.TestField("Receipt Date");
        TransHeader.TestField("Transfer-from Code");
        TransHeader.TestField("Transfer-to Code");
        TransHeader.TestField("In-Transit Code");
        TransferLine2."In-Transit Code" := TransHeader."In-Transit Code";
        TransferLine2."Transfer-from Code" := TransHeader."Transfer-from Code";
        TransferLine2."Transfer-to Code" := TransHeader."Transfer-to Code";
        TransferLine2."Shipment Date" := TransHeader."Shipment Date";
        TransferLine2."Receipt Date" := TransHeader."Receipt Date";
        TransferLine2."Shipping Agent Code" := TransHeader."Shipping Agent Code";
        TransferLine2."Shipping Agent Service Code" := TransHeader."Shipping Agent Service Code";
        TransferLine2."Shipping Time" := TransHeader."Shipping Time";
        TransferLine2."Outbound Whse. Handling Time" := TransHeader."Outbound Whse. Handling Time";
        TransferLine2."Inbound Whse. Handling Time" := TransHeader."Inbound Whse. Handling Time";
        TransferLine2.Status := TransHeader.Status;
    end;

    procedure EnterTransferItemCrossRef(var TransferLine: Record "Transfer Line")
    var
        ItemReference: Record "Item Reference";
        ItemVariant: Record "Item Variant";
        Item: Record Item;
        Found: Boolean;
    begin
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
        ItemReference: Record "Item Reference";
        TempItemRefNo: Text;
        TransferLine: Record "Transfer Line";
    begin
        TransferLine.Copy(TransferLine2);
        TempItemRefNo := TransferLine2."NPR Cross-Reference No.";
        ItemReference.Reset();
        ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.");
        ItemReference.SetRange("Reference No.", TransferLine."NPR Cross-Reference No.");
        ItemReference.SetFilter("Reference Type No.", '%1', '');
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");

        ItemReference.SetRange("Item No.", TransferLine."Item No.");
        if not ItemReference.Find('-') then begin
            ItemReference.SetRange("Item No.");
            if not ItemReference.Find('-') then begin
                Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo)
            end;
            if ItemReference.Next() <> 0 then begin
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

    [EventSubscriber(ObjectType::Codeunit, 6014403, 'CallItemReferenceNoLookUp', '', true, false)]
    local procedure ItemReferenceNoLookUp(var Sender: Codeunit "NPR Barcode Lookup Mgt."; var TransferLine3: Record "Transfer Line")
    var
        ItemReference3: Record "Item Reference";
    begin
        GetTransferHeader(TransferLine3);
        ItemReference3.Reset();
        ItemReference3.SetCurrentKey("Reference Type", "Reference Type No.");
        ItemReference3.SetFilter("Reference Type", '%1', ItemReference3."Reference Type"::" ");
        ItemReference3.SetFilter("Reference Type No.", '%1', '');
        if PAGE.RunModal(PAGE::"Item Reference List", ItemReference3) = ACTION::LookupOK then
            TransferLine3.Validate("NPR Cross-Reference No.", ItemReference3."Reference No.");
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

    [EventSubscriber(ObjectType::Codeunit, 6014403, 'CallItemRefNoLookupMixDiscount', '', false, false)]
    local procedure ItemRefNoLookupMixDiscount(var Sender: Codeunit "NPR Barcode Lookup Mgt."; var MixedDiscountLine: Record "NPR Mixed Discount Line")
    var
        ItemReference2: Record "Item Reference";
    begin
        if MixedDiscountLine."Disc. Grouping Type" <> MixedDiscountLine."Disc. Grouping Type"::Item then
            exit;
        GetMixedDiscountHeader(MixedDiscountLine);
        ItemReference2.Reset();
        ItemReference2.SetCurrentKey("Reference Type", "Reference Type No.");
        ItemReference2.SetFilter("Reference Type", '%1', ItemReference2."Reference Type"::"Bar Code");
        ItemReference2.SetFilter("Reference Type No.", '%1', '');
        if PAGE.RunModal(PAGE::"Item Reference List", ItemReference2) = ACTION::LookupOK then begin
            MixedDiscountLine."No." := ItemReference2."Item No.";
            MixedDiscountLine.Validate("Cross-Reference No.", ItemReference2."Reference No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6014412, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnAfterValidateItemRefMixDiscount(var Rec: Record "NPR Mixed Discount Line"; var xRec: Record "NPR Mixed Discount Line"; CurrFieldNo: Integer)
    var
        ReturnedItemRef: Record "Item Reference";
    begin
        ReturnedItemRef.Init();
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
        MixedDiscountLine: Record "NPR Mixed Discount Line";
        ItemReference: Record "Item Reference";
        TempItemRefNo: Text;
    begin
        MixedDiscountLine.Copy(MixedDiscountLine2);
        if MixedDiscountLine."Disc. Grouping Type" = MixedDiscountLine."Disc. Grouping Type"::Item then begin
            TempItemRefNo := MixedDiscountLine2."Cross-Reference No.";
            ItemReference.Reset();
            ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.");
            ItemReference.SetRange("Reference No.", MixedDiscountLine."Cross-Reference No.");
            ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
            ItemReference.SetFilter("Reference Type No.", '%1', '');
            ItemReference.SetRange("Item No.", MixedDiscountLine."No.");
            if not ItemReference.Find('-') then begin
                ItemReference.SetRange("Item No.");
                if not ItemReference.Find('-') then begin
                    Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo)
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

    [EventSubscriber(ObjectType::Codeunit, 6014403, 'CallItemRefNoLookupPeriodicDiscount', '', false, false)]
    local procedure ItemRefNoLookupPeriodicDiscount(var Sender: Codeunit "NPR Barcode Lookup Mgt."; var PeriodDiscountLine: Record "NPR Period Discount Line")
    var
        ItemReference2: Record "Item Reference";
    begin
        GetPeriodicDiscountHeader(PeriodDiscountLine);
        ItemReference2.Reset();
        ItemReference2.SetCurrentKey("Reference Type", "Reference Type No.");
        ItemReference2.SetFilter("Reference Type", '%1', ItemReference2."Reference Type"::"Bar Code");
        ItemReference2.SetFilter("Reference Type No.", '%1', '');
        if PAGE.RunModal(PAGE::"Item Reference List", ItemReference2) = ACTION::LookupOK then begin
            PeriodDiscountLine."Item No." := ItemReference2."Item No.";
            PeriodDiscountLine.Validate("Cross-Reference No.", ItemReference2."Reference No.");
        end;
    end;

    [EventSubscriber(ObjectType::Table, 6014414, 'OnAfterValidateEvent', 'Cross-Reference No.', false, false)]
    local procedure OnAfterValidateItemRefPeriodicDiscount(var Rec: Record "NPR Period Discount Line"; var xRec: Record "NPR Period Discount Line"; CurrFieldNo: Integer)
    var
        ReturnedItemRef: Record "Item Reference";
    begin
        ReturnedItemRef.Init();
        if Rec."Cross-Reference No." <> '' then begin
            ICRLookupPeriodicDiscount(Rec, ReturnedItemRef);
            Rec.Validate("Item No.", ReturnedItemRef."Item No.");
            if ReturnedItemRef."Variant Code" <> '' then
                Rec.Validate("Variant Code", ReturnedItemRef."Variant Code");
        end;
        Rec."Cross-Reference No." := ReturnedItemRef."Reference No.";
        if ReturnedItemRef.Description <> '' then
            Rec.Description := ReturnedItemRef.Description;
    end;

    procedure ICRLookupPeriodicDiscount(var PeriodDiscountLine2: Record "NPR Period Discount Line"; var ReturnedItemRef: Record "Item Reference")
    var
        PeriodDiscountLine: Record "NPR Period Discount Line";
        ItemReference: Record "Item Reference";
        TempItemRefNo: Text;
    begin
        PeriodDiscountLine.Copy(PeriodDiscountLine2);
        TempItemRefNo := PeriodDiscountLine2."Cross-Reference No.";
        ItemReference.Reset();
        ItemReference.SetCurrentKey("Reference No.", "Reference Type", "Reference Type No.");
        ItemReference.SetRange("Reference No.", PeriodDiscountLine."Cross-Reference No.");
        ItemReference.SetRange("Reference Type", ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetFilter("Reference Type No.", '%1', '');
        ItemReference.SetRange("Item No.", PeriodDiscountLine."Item No.");
        if not ItemReference.Find('-') then begin
            ItemReference.SetRange("Item No.");
            if not ItemReference.Find('-') then begin
                Error(ItemWithItemRefNoNotFoundErr, TempItemRefNo)
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

