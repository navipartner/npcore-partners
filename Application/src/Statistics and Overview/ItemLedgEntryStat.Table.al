table 6059795 "NPR Item Ledg Entry Stat"
{
    Extensible = false;
    Access = Internal;
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; RowNo; Integer)
        {
            Caption = 'Row No.';
            DataClassification = CustomerContent;
        }
        field(10; "Entry Type"; Enum "Item Ledger Entry Type")
        {
            Caption = 'Entry Type';
            DataClassification = CustomerContent;
        }
        field(20; "Posting Date"; Date)
        {
            Caption = 'Posting Date';
            DataClassification = CustomerContent;
        }
        field(30; "Global Dimension 1 Code"; Code[20])
        {
            Caption = 'Global Dimension 1 Code';
            DataClassification = CustomerContent;
        }
        field(35; "Global Dimension 2 Code"; Code[20])
        {
            Caption = 'Global Dimension 2 Code';
            DataClassification = CustomerContent;
        }
      
        field(40; "Source No."; Code[20])
        {
            Caption = 'Source No.';
            DataClassification = CustomerContent;
        }
        field(45; "Item Category Code"; Code[20])
        {
            Caption = 'Item Category Code';
            DataClassification = CustomerContent;
        }
        field(70; "Vendor No."; Code[20])
        {
            Caption = 'Vendor No.';
            DataClassification = CustomerContent;
        }
        field(80; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DataClassification = CustomerContent;
        }


    }

    keys
    {
        key(PK; RowNo)
        {
            Clustered = true;
        }
    }
}