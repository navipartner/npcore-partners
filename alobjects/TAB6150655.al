table 6150655 "POS NPRE Restaurant Profile"
{
    // NPR5.55/ALPO/20200730 CASE 414938 POS Store/POS Unit - Restaurant link

    Caption = 'POS Restaurant Profile';
    DataClassification = CustomerContent;
    LookupPageID = "POS NPRE Restaurant Profiles";

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Restaurant Code"; Code[20])
        {
            Caption = 'Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPRE Restaurant";
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

