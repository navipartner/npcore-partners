codeunit 6014444 "NPR Event Subscriber (Purch)"
{
    var
        RetailSetup: Record "NPR NP Retail Setup";
        RetailSetupFetched: Boolean;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Vendor Item No.', true, false)]
    local procedure OnBeforeValidateEventVendorItemNo(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        PurchLine: Record "Purchase Line";
        PurchHeader: Record "Purchase Header";
        ItemWorksheetPurchIntegr: Codeunit "NPR Item Works. Purch. Integr.";
        VendorItemNoNotCreatedErr: Label 'Vendor Item No. %1 was not created on vendor.', Comment = '%1=PurchLine."Vendor Item No."';
        CreatedItemNo: Code[20];
        CreatedVariantCode: Code[10];
    begin
        if CurrFieldNo = Rec.FieldNo("Vendor Item No.") then begin
            GetRetailSetup();
            PurchHeader.Get(Rec."Document Type", Rec."Document No.");
            Item.SetCurrentKey("Vendor No.", "Vendor Item No.");
            if RetailSetup."Check Purchase Lines if vendor" then
                Item.SetFilter("Vendor No.", PurchHeader."Buy-from Vendor No.");
            if Rec."Vendor Item No." <> '' then begin
                Item.SetFilter("Vendor Item No.", '%1', '@' + Rec."Vendor Item No.");
                if Item.FindFirst() then begin
                    if Rec."No." <> Item."No." then begin
                        PurchLine := Rec;
                        PurchLine.Validate("No.", Item."No.");
                        PurchLine."Vendor Item No." := Item."Vendor Item No.";
                        Rec := PurchLine;
                    end;
                end else
                    if ItemWorksheetPurchIntegr.CreateItemFromWorksheet(PurchHeader."Buy-from Vendor No.", Rec."Vendor Item No.", CreatedItemNo, CreatedVariantCode) then begin
                        PurchLine := Rec;
                        PurchLine.Validate("No.", CreatedItemNo);
                        PurchLine.Validate("Variant Code", CreatedVariantCode);
                        PurchLine."Vendor Item No." := Rec."Vendor Item No.";
                        Rec := PurchLine;
                    end else
                        Error(VendorItemNoNotCreatedErr, Rec."Vendor Item No.");
            end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnBeforeValidateEvent', 'Vendor Item No.', false, false)]
    local procedure OnBeforeValidateEventVendorItemNo2(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        Item: Record Item;
        ItemVend: Record "Item Vendor";
    begin
        if CurrFieldNo in [Rec.FieldNo("Item Reference No."), Rec.FieldNo("No."), Rec.FieldNo("Variant Code"), Rec.FieldNo("Location Code")] then begin
            Rec.TestField("No.");
            Item.Get(Rec."No.");
            ItemVend.Init();
            ItemVend."Vendor No." := Rec."Buy-from Vendor No.";
            ItemVend."Variant Code" := Rec."Variant Code";
            Item.FindItemVend(ItemVend, Rec."Location Code");
            if (ItemVend."Vendor Item No." = '') and (Item."Vendor Item No." <> '') then
                Rec."Vendor Item No." := Item."Vendor Item No.";
        end;
    end;

    local procedure GetRetailSetup(): Boolean
    begin
        if RetailSetupFetched then
            exit(true);

        if not RetailSetup.Get() then
            exit(false);
        RetailSetupFetched := true;
        exit(true);
    end;
}

