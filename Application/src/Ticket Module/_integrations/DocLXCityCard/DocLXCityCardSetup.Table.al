table 6150821 "NPR DocLXCityCardSetup"
{

    Caption = 'City Card City Setup';
    DataClassification = CustomerContent;
    Access = Internal;

    fields
    {
        field(1; "Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Code';
        }

        field(10; City; Enum "NPR DocLXCities")
        {
            DataClassification = CustomerContent;
            Caption = 'City';
        }

        field(20; Environment; Option)
        {
            DataClassification = CustomerContent;
            Caption = 'Environment';
            OptionCaption = 'Demo,Production';
            OptionMembers = DEMO,PRODUCTION;
        }
    }

    keys
    {
        key(Key1; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, City, Environment)
        {
        }
    }

}