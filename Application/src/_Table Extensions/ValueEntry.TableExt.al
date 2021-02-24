tableextension 6014447 "NPR Value Entry" extends "Value Entry"
{
    fields
    {
        field(6014401; "NPR Group Sale"; Boolean)
        {
            Caption = 'Group Sale';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014407; "NPR Item Group No."; Code[20])
        {
            Caption = 'Item Group No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014408; "NPR Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = Vendor;
        }
        field(6014409; "NPR Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
        }
        field(6014410; "NPR Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014413; "NPR Register No."; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
        }
        field(6014414; "NPR Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = "Salesperson/Purchaser";
        }
        field(6014415; "NPR Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
            Description = 'NPR5.43,NPR5.48';
        }
        field(6014416; "NPR Document Date and Time"; DateTime)
        {
            Caption = 'Document Date and Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
    }
}

