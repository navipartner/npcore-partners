table 6059779 "NPR Part. Sync Fields Prof."
{
    Caption = 'Partiel Synk. Felt Profiler';
    DataPerCompany = false;
    DataClassification = CustomerContent;
    ObsoleteState = Removed;

    fields
    {
        field(1; "Synchronisation Profile"; Code[20])
        {
            Caption = 'Synchronisation Profile';
            DataClassification = CustomerContent;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
        }
        field(4; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(5; Value; Text[30])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
        field(6; FilterType; Option)
        {
            Caption = 'Filter Type';
            OptionCaption = 'Field,Filter,CompanyFilter';
            OptionMembers = "Field","Filter",CompanyFilter;
            DataClassification = CustomerContent;
        }
        field(7; "Company Name"; Text[30])
        {
            Caption = 'Company Name';
            DataClassification = CustomerContent;
        }
        field(8; "To Field No."; Integer)
        {
            Caption = 'To Field No.';
            DataClassification = CustomerContent;
        }
        field(9; "To Field Description"; Text[100])
        {
            Caption = 'To Field Description';
            DataClassification = CustomerContent;
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

