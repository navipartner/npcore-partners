table 6014697 "Embedded Video Buffer"
{
    // NPR5.37/MHA /20171009  CASE 289471 Object created - Display Embedded Videos

    Caption = 'Embedded Video Buffer';

    fields
    {
        field(1;"Module Code";Code[20])
        {
            Caption = 'Module Code';
            NotBlank = true;
        }
        field(5;"Line No.";Integer)
        {
            Caption = 'Line No.';
        }
        field(10;"Module Name";Text[50])
        {
            Caption = 'Module Name';
        }
        field(15;Columns;Integer)
        {
            Caption = 'Columns';
            InitValue = 1;
            MinValue = 1;
        }
        field(50;"Video Html";Text[250])
        {
            Caption = 'Video Html';
        }
        field(55;"Width (px)";Integer)
        {
            Caption = 'Width (px)';
        }
        field(60;"Height (px)";Integer)
        {
            Caption = 'Height (px)';
        }
    }

    keys
    {
        key(Key1;"Module Code","Line No.")
        {
        }
    }

    fieldgroups
    {
    }
}

