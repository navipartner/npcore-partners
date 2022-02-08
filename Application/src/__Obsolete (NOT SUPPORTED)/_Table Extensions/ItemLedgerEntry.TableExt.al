tableextension 6014431 "NPR Item Ledger Entry" extends "Item Ledger Entry"
{
    fields
    {
        field(6014401; "NPR Group Sale"; Boolean)
        {
            Caption = 'Group Sale';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014405; "NPR Discount Type"; Option)
        {
            Caption = 'Discount Type';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            OptionCaption = ' ,Period,Mixed,Multiple Unit,Salesperson Discount,Inventory,Photo Work,Rounding,Combination,Customer';
            OptionMembers = " ",Period,Mixed,"Multiple Unit","Salesperson Discount",Inventory,"Photo Work",Rounding,Combination,Customer;
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014406; "NPR Discount Code"; Code[30])
        {
            Caption = 'Discount Code';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014407; "NPR Item Group No."; Code[10])
        {
            Caption = 'Item Group No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014408; "NPR Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014413; "NPR Register Number"; Code[20])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014414; "NPR Salesperson Code"; Code[20])
        {
            Caption = 'Salesperson Code';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014416; "NPR Document Time"; Time)
        {
            Caption = 'Document Time';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
        field(6014417; "NPR Document Date and Time"; DateTime)
        {
            Caption = 'Document Date and Time';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
            ObsoleteState = Removed;
            ObsoleteReason = 'Using auxiliary table ("NPR Aux. Item Ledger Entry").';
        }
    }
}