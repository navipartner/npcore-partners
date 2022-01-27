table 6014517 "NPR Insurance Category"
{
    Access = Internal;
    Caption = 'Insurance Category';
    LookupPageID = "NPR Insurance Category";
    DataClassification = CustomerContent;

    fields
    {
        field(1; Kategori; Code[50])
        {
            Caption = 'Category';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(2; "Calculation Type"; Option)
        {
            Caption = 'Calculation Type';
            OptionCaption = 'Amount incl. VAT,Unit Price';
            OptionMembers = "Amount incl. VAT","Unit Price";
            DataClassification = CustomerContent;
        }
        field(3; "Insurance Type"; Code[10])
        {
            Caption = 'Insurance Type';
            DataClassification = CustomerContent;
        }
        field(4; "Duration in months"; Integer)
        {
            Caption = 'Duration in months';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Kategori)
        {
        }
    }

    fieldgroups
    {
    }
}

