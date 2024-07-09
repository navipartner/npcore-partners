tableextension 6014452 "NPR Item Journal Line" extends "Item Journal Line"
{
    fields
    {
        field(6014401; "NPR Group Sale"; Boolean)
        {
            Caption = 'Group Sale';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014402; "NPR Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(6014404; "NPR Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
        }
        field(6014405; "NPR Discount Code"; Code[20])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014407; "NPR Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014408; "NPR Item Group No."; Code[10])
        {
            Caption = 'Item Group No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014413; "NPR Register Number"; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014414; "NPR Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6059970; "NPR Is Master"; Boolean)
        {
            Caption = 'Is Master';
            DataClassification = CustomerContent;
            Description = 'VRT';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6059971; "NPR Master Line No."; Integer)
        {
            Caption = 'Master Line No.';
            DataClassification = CustomerContent;
            Description = 'VRT';
            ObsoleteState = Removed;
            ObsoleteTag = '2023-06-28';
            ObsoleteReason = '"NPR Master Line Map" used instead.';
        }
        field(6151440; "NPR Sales Channel"; Code[20])
        {
            Caption = 'Sales Channel';
            DataClassification = CustomerContent;
            TableRelation = "NPR MM Loyalty Sales Channel".Code;
        }
    }
}
