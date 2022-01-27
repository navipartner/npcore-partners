table 6151383 "NPR CS Item Search Handl."
{
    Access = Internal;

    Caption = 'CS Item Seach Handling';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Object moved to NP Warehouse App.';


    fields
    {
        field(1; "No."; Code[20])
        {
            Caption = 'No.';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(11; "Description 2"; Text[50])
        {
            Caption = 'Description 2';
            DataClassification = CustomerContent;
        }
        field(12; Rank; Integer)
        {
            Caption = 'Rank';
            DataClassification = CustomerContent;
        }
        field(13; "Item Variant"; Boolean)
        {
            Caption = 'Item Variant';
            DataClassification = CustomerContent;
        }
        field(14; Barcode; Text[30])
        {
            Caption = 'Barcode';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "No.")
        {
        }
        key(Key2; Rank, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

