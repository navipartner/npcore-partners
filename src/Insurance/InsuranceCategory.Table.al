table 6014517 "NPR Insurance Category"
{
    Caption = 'Insurance Category';
    LookupPageID = "NPR Insurance Category";

    fields
    {
        field(1; Kategori; Code[50])
        {
            Caption = 'Category';
            NotBlank = true;
        }
        field(2; "Calculation Type"; Option)
        {
            Caption = 'Calculation Type';
            OptionCaption = 'Amount incl. VAT,Unit Price';
            OptionMembers = "Amount incl. VAT","Unit Price";
        }
        field(3; "Insurance Type"; Code[10])
        {
            Caption = 'Insurance Type';
        }
        field(4; "Duration in months"; Integer)
        {
            Caption = 'Duration in months';
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

