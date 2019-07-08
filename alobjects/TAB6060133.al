table 6060133 "Record Field Type"
{
    Caption = 'Record Field Type';

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
        }
        field(2;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(3;"Field Caption";Text[30])
        {
            Caption = 'Field Caption';
        }
        field(4;Type;Option)
        {
            Caption = 'Type';
            OptionCaption = 'Text,Decimal';
            OptionMembers = Text,Decimal;
        }
        field(5;"Table No.";Integer)
        {
            Caption = 'Table No.';
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

