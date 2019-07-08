table 6151383 "CS Item Seach Handling"
{
    // NPR5.47/CLVA/20180921 CASE 307282 Object created - NP Capture Service
    // NPR5.48/CLVA/20180921 CASE 307282 Added field "Item Variant" and Barcode
    // NPR5.48/JDH /20181109 CASE 334163 Added Captions to above listed fields

    Caption = 'CS Item Seach Handling';

    fields
    {
        field(1;"No.";Code[20])
        {
            Caption = 'No.';
        }
        field(10;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(11;"Description 2";Text[50])
        {
            Caption = 'Description 2';
        }
        field(12;Rank;Integer)
        {
            Caption = 'Rank';
        }
        field(13;"Item Variant";Boolean)
        {
            Caption = 'Item Variant';
        }
        field(14;Barcode;Text[30])
        {
            Caption = 'Barcode';
        }
    }

    keys
    {
        key(Key1;"No.")
        {
        }
        key(Key2;Rank,"No.")
        {
        }
    }

    fieldgroups
    {
    }
}

