codeunit 6014444 "NPR Event Subscriber (Purch)"
{
    var
        RetailSetup: Record "NPR Retail Setup";
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

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'NPR Gift Voucher', true, false)]
    local procedure OnAfterValidateEventGiftVoucher(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        GiftVoucher: Record "NPR Gift Voucher";
        UpdateDirectUnitCostQst: Label '%1 on %2 is %3. Do You want to update %4 on %5 with %3?',
                               Comment = '%1=GiftVoucher.FieldCaption(Amount);%2=GiftVoucher.TableCaption();%3=GiftVoucher.Amount;%4=PurchLine.FieldCaption("Amount Including VAT");%5=PurchLine.TableCaption()';
    begin
        if Rec."NPR Gift Voucher" <> '' then begin
            Rec.TestField(Type, Rec.Type::"G/L Account");
            Rec."NPR Credit Note" := '';
            GiftVoucher.Get(Rec."NPR Gift Voucher");
            GiftVoucher.TestField(Status, GiftVoucher.Status::Open);
            if GiftVoucher.Amount <> Rec."Amount Including VAT" then
                if Confirm(StrSubstNo(UpdateDirectUnitCostQst,
                  GiftVoucher.FieldCaption(Amount), GiftVoucher.TableCaption(),
                  GiftVoucher.Amount, Rec.FieldCaption("Amount Including VAT"), Rec.TableCaption())) then begin
                    Rec."Direct Unit Cost" := GiftVoucher.Amount;
                    Rec."Direct Unit Cost" := Rec."Direct Unit Cost" / 1 + (Rec."VAT %" / 100);
                    Rec.Validate("Direct Unit Cost", Round(Rec."Direct Unit Cost"));
                end;
        end;
    end;

    [EventSubscriber(ObjectType::Table, 39, 'OnAfterValidateEvent', 'NPR Credit Note', true, false)]
    local procedure OnAfterValidateEventCreditNote(var Rec: Record "Purchase Line"; var xRec: Record "Purchase Line"; CurrFieldNo: Integer)
    var
        CreditVoucher: Record "NPR Credit Voucher";
        UpdateDirectUnitCostQst: Label '%1 on %2 is %3. Do You want to update %4 on %5 with %3?',
        Comment = '%1=CreditVoucher.FieldCaption(Amount);%2=CreditVoucher.TableCaption();%3=CreditVoucher.Amount;%4=PurchLine.FieldCaption("Amount Including VAT");%5=PurchLine.TableCaption()';
    begin
        if Rec."NPR Credit Note" <> '' then begin
            Rec.TestField(Type, Rec.Type::"G/L Account");
            Rec."NPR Gift Voucher" := '';
            CreditVoucher.Get(Rec."NPR Credit Note");
            CreditVoucher.TestField(Status, CreditVoucher.Status::Open);
            if CreditVoucher.Amount <> Rec."Amount Including VAT" then
                if Confirm(StrSubstNo(UpdateDirectUnitCostQst,
                  CreditVoucher.FieldCaption(Amount), CreditVoucher.TableCaption(),
                  CreditVoucher.Amount, Rec.FieldCaption("Amount Including VAT"), Rec.TableCaption())) then begin
                    Rec."Direct Unit Cost" := CreditVoucher.Amount;
                    Rec."Direct Unit Cost" := Rec."Direct Unit Cost" / 1 + (Rec."VAT %" / 100);
                    Rec.Validate("Direct Unit Cost", Round(Rec."Direct Unit Cost"));
                end;
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

