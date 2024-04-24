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

        field(30; Default; Boolean)
        {
            DataClassification = CustomerContent;
            Caption = 'Default';

            trigger OnValidate()
            var
                Setup: Record "NPR DocLXCityCardSetup";
                MultipleDefaultSetups: Label 'Only one setup can be default.';
            begin
                if (Default) then begin
                    Setup.SetFilter("Code", '<>%1', Code);
                    Setup.SetFilter(Default, '=%1', true);
                    if (not Setup.IsEmpty) then
                        Error(MultipleDefaultSetups);
                end;
            end;
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