tableextension 6014435 "NPR Purchase Line" extends "Purchase Line"
{
    fields
    {
        modify("Vendor Item No.")
        {

            trigger OnBeforeValidate()
            var
                Item: Record Item;
                ItemVend: Record "Item Vendor";
                PurchLine: Record "Purchase Line";
                PurchHeader: Record "Purchase Header";
                ItemWorksheetPurchIntegr: Codeunit "NPR Item Works. Purch. Integr.";
                CreatedItemNo: Code[20];
                CreatedVariantCode: Code[10];
                VendorItemNoNotCreatedErr: Label 'Vendor Item No. %1 was not created on vendor.', Comment = '%1=PurchLine."Vendor Item No."';
            begin
                case true of
                    (CurrFieldNo = Rec.FieldNo("Vendor Item No.")):
                        if Rec."Vendor Item No." <> '' then begin
                            PurchHeader.Get(Rec."Document Type", Rec."Document No.");
                            Item.SetCurrentKey("Vendor No.", "Vendor Item No.");
                            Item.SetFilter("Vendor No.", PurchHeader."Buy-from Vendor No.");
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
                    (CurrFieldNo in [Rec.FieldNo("Item Reference No."), Rec.FieldNo("No."), Rec.FieldNo("Variant Code"), Rec.FieldNo("Location Code")]):
                        begin
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
            end;

        }
        field(6014400; "NPR Gift Voucher"; Code[20])
        {
            Caption = 'Gift Voucher';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014401; "NPR Credit Note"; Code[20])
        {
            Caption = 'Credit Note';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014402; "NPR Sendt"; Boolean)
        {
            Caption = 'Sendt';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014405; "NPR Compaign Order"; Boolean)
        {
            Caption = 'Campaign Order';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014410; "NPR Procure Quantity"; Decimal)
        {
            Caption = 'Procure Quantity';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014411; "NPR Gift Voucher no."; Code[20])
        {
            Caption = 'Gift Voucher no.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Gift voucher won''t be used anymore.';
            ObsoleteTag = 'NPR Gift Voucher';
        }
        field(6014412; "NPR Credit Note No."; Code[20])
        {
            Caption = 'Credit Note No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014413; "NPR Former Order No."; Code[20])
        {
            Caption = 'Former Order No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014414; "NPR Accessory"; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014415; "NPR Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014416; "NPR Belongs to Line No."; Integer)
        {
            Caption = 'Belongs to Line No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014420; "NPR Exchange Label"; Code[13])
        {
            Caption = 'Exchange Label';
            DataClassification = CustomerContent;
            Description = 'NPR5.49';
            ObsoleteState = Removed;
            ObsoleteReason = 'Moved to "NPR Aux. Purchase Line".';
        }
        field(6014602; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014603; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014606; "NPR Create"; Code[20])
        {
            Caption = 'Create';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014607; "NPR Label"; Boolean)
        {
            Caption = 'Label';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014608; "NPR Hide Line"; Boolean)
        {
            Caption = 'Hide Line';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6014609; "NPR Main Line"; Boolean)
        {
            Caption = 'Main Line';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used anymore.';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6151051; "NPR Retail Replenishment No."; Integer)
        {
            Caption = 'Retail Replenisment No.';
            DataClassification = CustomerContent;
            Description = 'NPR5.38.01';
            ObsoleteState = Removed;
            ObsoleteReason = '"NPR Distrib. Table Map" used instead.';
        }
    }
}

