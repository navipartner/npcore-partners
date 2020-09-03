table 6059779 "NPR Part. Sync Fields Prof."
{
    Caption = 'Partiel Synk. Felt Profiler';
    DataPerCompany = false;

    fields
    {
        field(1; "Synchronisation Profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
            NotBlank = true;
            TableRelation = "NPR Company Sync Profiles"."Synchronisation Profile";
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            NotBlank = true;
            TableRelation = AllObj."Object ID" WHERE("Object Type" = CONST(Table));
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            NotBlank = true;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
        }
        field(5; Value; Text[30])
        {
            Caption = 'Value';
        }
        field(6; FilterType; Option)
        {
            Caption = 'Filter Type';
            OptionCaption = 'Field,Filter,CompanyFilter';
            OptionMembers = "Field","Filter",CompanyFilter;
        }
        field(7; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
        }
        field(8; "To Field No."; Integer)
        {
            Caption = 'To Field No.';
        }
        field(9; "To Field Description"; Text[100])
        {
            Caption = 'To Field Description';
        }
    }

    keys
    {
        key(Key1; "Synchronisation Profile", "Table No.", "Field No.", Value, FilterType, "Company Name")
        {
        }
    }

    fieldgroups
    {
    }
}

