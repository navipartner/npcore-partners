table 6151383 "NPR CS Item Search Handl."
{
    // NPR5.47/CLVA/20180921 CASE 307282 Object created - NP Capture Service
    // NPR5.48/CLVA/20180921 CASE 307282 Added field "Item Variant" and Barcode
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions to above listed fields

    Caption = 'CS Item Seach Handling';
    DataClassification = CustomerContent;

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

