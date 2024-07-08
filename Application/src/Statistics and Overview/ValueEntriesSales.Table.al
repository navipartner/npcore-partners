table 6059794 "NPR Value Entries Sales"
{
    Caption = 'Value Entries Sales';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Value Entries Sales";
    LookupPageID = "NPR Value Entries Sales";
    TableType = Temporary;
    Access = Internal;

    fields
    {
        field(1; "Item Ledger Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Item Ledger Entry Type';
            DataClassification = CustomerContent;
        }
        field(2; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(3; "Item No."; Code[20])
        {
            Caption = 'Item No.';
            DataClassification = CustomerContent;
        }
        field(4; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(5; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(6; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
        field(7; "Location Code"; Code[20])
        {
            Caption = 'Location Code';
            DataClassification = CustomerContent;
        }
        field(8; "Salespers./Purch. Code"; Code[20])
        {
            Caption = 'Salespers./Purch. Code';
            DataClassification = CustomerContent;
        }
        field(9; "Cost Amount (Actual)"; Decimal)
        {
            Caption = 'Cost Amount (Actual)';
            DataClassification = CustomerContent;
        }
        field(10; "Sales Amount (Actual)"; Decimal)
        {
            Caption = 'Sales Amount (Actual)';
            DataClassification = CustomerContent;
        }
        field(11; "Line No."; Integer)
        {
            Caption = 'Line No.';
            DataClassification = CustomerContent;
        }

        field(12; "Invoiced Quantity"; Decimal)
        {
            Caption = 'Invoiced Quantity';
            DataClassification = CustomerContent;

        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
        }
    }
}
