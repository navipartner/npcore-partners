table 6060004 "GIM - Setup"
{
    Caption = 'GIM - Setup';

    fields
    {
        field(1;"Primary Key";Code[10])
        {
            Caption = 'Primary Key';
        }
        field(10;"Import Document Nos.";Code[10])
        {
            Caption = 'Import Document Nos.';
            TableRelation = "No. Series";
        }
        field(20;"Sender E-mail";Text[250])
        {
            Caption = 'Sender E-mail';
        }
        field(30;"Mailing Templates";Option)
        {
            Caption = 'Mailing Templates';
            OptionCaption = 'GIM,NAVI';
            OptionMembers = GIM,NAVI;
        }
    }

    keys
    {
        key(Key1;"Primary Key")
        {
        }
    }

    fieldgroups
    {
    }
}

