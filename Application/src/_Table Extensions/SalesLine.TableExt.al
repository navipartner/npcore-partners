tableextension 6014433 "NPR Sales Line" extends "Sales Line"
{
    fields
    {
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
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014407; "NPR Internal"; Boolean)
        {
            Caption = 'Internal';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014408; "NPR Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014409; "NPR Special Price"; Decimal)
        {
            Caption = 'Special Price';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014410; "NPR Color"; Code[20])
        {
            Caption = 'Color';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014411; "NPR Size"; Code[20])
        {
            Caption = 'Size';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014412; "NPR Serial No. not Created"; Code[30])
        {
            Caption = 'Serial No. Not Created';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014413; "NPR Hide Line"; Boolean)
        {
            Caption = 'Hide Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014414; "NPR Main Line"; Boolean)
        {
            Caption = 'Main Line';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014415; "NPR Accessory"; Boolean)
        {
            Caption = 'Accessory';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014416; "NPR Belongs to Item"; Code[20])
        {
            Caption = 'Belongs to Item';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014417; "NPR Belongs to Line No."; Integer)
        {
            Caption = 'Belongs to Line No.';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014418; "NPR Belongs to Item Group"; Code[10])
        {
            Caption = 'Belongs to Item Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014419; "NPR Belongs 2 Item Disc.Group"; Code[10])
        {
            Caption = 'Belongs to Item Disc. Group';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6014420; "NPR MR Anvendt antal"; Decimal)
        {
            Caption = 'MR Used Amount';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = 'Not used.';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT1.00';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059972; "NPR Total Discount Code"; Code[20])
        {
            Caption = 'Total Discount Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Total Discount Header";
        }
        field(6059973; "NPR Total Discount Amount"; Decimal)
        {
            Caption = 'Total Discount Amount';
            DataClassification = CustomerContent;
        }
        field(6059974; "NPR Total Discount Step"; Decimal)
        {
            Caption = 'Total Discount Step';
            DataClassification = CustomerContent;

        }
        field(6059975; "NPR Benefit Item"; Boolean)
        {
            Caption = 'Benefit Item';
            DataClassification = CustomerContent;

        }
        field(6059976; "NPR Disc Amt W/out Total Disc"; Decimal)
        {
            Caption = 'Disc. Amt. Without Total Disc.';
            DataClassification = CustomerContent;

        }

        field(6059977; "NPR Benefit List Code"; Code[20])
        {
            Caption = 'Benefit List Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Item Benefit List Header".Code;

        }
        field(6059978; "NPR Shipment Fee"; Boolean)
        {
            Caption = 'Shipment Fee';
            DataClassification = CustomerContent;

        }
        field(6059979; "NPR Store Ship Profile Code"; Code[20])
        {
            Caption = 'Store Ship Profile Code';
            DataClassification = CustomerContent;

        }
        field(6059980; "NPR Store Ship Prof. Line No."; Integer)
        {
            Caption = 'Store Ship Profile Line No.';
            DataClassification = CustomerContent;

        }
        modify("Location Code")
        {
            trigger OnAfterValidate()
            var
                RSRetailLocalizationMgt: Codeunit "NPR RS R Localization Mgt.";
            begin
                RSRetailLocalizationMgt.GetPriceFromSalesPriceList(Rec);
            end;
        }
    }
}