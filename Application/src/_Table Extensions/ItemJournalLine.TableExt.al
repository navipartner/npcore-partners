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
    }
}