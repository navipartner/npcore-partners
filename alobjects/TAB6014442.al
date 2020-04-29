table 6014442 "Touch Screen - Layout"
{
    Caption = 'Touch Screen - Layout';
    LookupPageID = "Touch Screen - Layout List";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(2;Description;Text[30])
        {
            Caption = 'Description';
        }
        field(20;"Resolution Width";Integer)
        {
            Caption = 'Resolution Width';
        }
        field(21;"Resolution Height";Integer)
        {
            Caption = 'Resolution Height';
        }
        field(30;"Button Count Vertical";Integer)
        {
            Caption = 'Button Count Vertical';
        }
        field(31;"Button Count Horizontal";Integer)
        {
            Caption = 'Button Count Horizontal';
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }
}

