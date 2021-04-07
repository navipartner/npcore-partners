tableextension 6014433 "NPR Sales Line" extends "Sales Line"
{
    fields
    {
        modify("Unit Price")
        {
            trigger OnAfterValidate()
            begin
                NPRCalcItemGroupUnitCost();
            end;
        }
        modify("VAT Prod. Posting Group")
        {
            trigger OnAfterValidate()
            begin
                NPRCalcItemGroupUnitCost();
            end;
        }
        field(6014404; "NPR Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Campaign,Mix,Quantity,Manual,"BOM List","Photo work",Rounding,Combination,Customer;
        }
        field(6014405; "NPR Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
        }
        field(6014406; "NPR Part of product line"; Code[10])
        {
            Caption = 'Part of product line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014407; "NPR Internal"; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
        }
        field(6014408; "NPR Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014409; "NPR Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
        }
        field(6014410; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014411; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014412; "NPR Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. Not Created';
            DataClassification = CustomerContent;
        }
        field(6014413; "NPR Hide Line"; Boolean)
        {
            Caption = 'Hide Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014414; "NPR Main Line"; Boolean)
        {
            Caption = 'Main Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Accessory"; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014416; "NPR Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014417; "NPR Belongs to Line No."; Integer)
        {
            Caption = 'Belongs to Line No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014418; "NPR Belongs to Item Group"; Code[10])
        {
            Caption = 'Belongs to Item Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014419; "NPR Belongs 2 Item Disc.Group"; Code[10])
        {
            Caption = 'Belongs to Item Disc. Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
        }
        field(6014420; "NPR MR Anvendt antal"; Decimal)
        {
            Caption = 'MR Used Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used.';
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
    }


    procedure NPRCalcItemGroupUnitCost(): Boolean
    var
        SalesHeader: Record "Sales Header";
        Item: Record Item;
        VATPercent: Decimal;
    begin
        if (Rec.Type <> Rec.Type::Item) or (Rec."Profit %" = 0) then
            exit(false);

        Item.Get(Rec."No.");
        if not (Item."NPR Group sale" or (Item."Unit Cost" = 0)) then
            exit(false);

        SalesHeader.Get(Rec."Document Type", Rec."Document No.");

        if SalesHeader."Prices Including VAT" then
            VATPercent := Rec."VAT %";

        Rec.Validate("Unit Cost (LCY)", ((1 - Rec."Profit %" / 100) * Rec."Unit Price" / (1 + VATPercent / 100)) * Rec."Qty. per Unit of Measure");

        exit(true);
    end;
}