table 6014625 "NPR Dependency Mgt. Setup"
{
    Access = Internal;
    Caption = 'Dependency Management Setup';
    DataPerCompany = false;
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "OData URL"; Text[250])
        {
            Caption = 'Managed Dependency OData URL';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(11; Username; Text[30])
        {
            Caption = 'Managed Dependency Username';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(12; Password; BLOB)
        {
            Caption = 'Managed Dependency Password';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(13; Configured; Boolean)
        {
            Caption = 'Managed Dependency Configured';
            Editable = false;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(14; "Accept Statuses"; Option)
        {
            Caption = 'Accept Dependency Statuses';
            OptionCaption = 'Released,Staging (incl. Released),Testing (incl. Staging and Released)';
            OptionMembers = Released,Staging,Testing;
            DataClassification = CustomerContent;
        }
        field(15; "Tag Filter"; Code[250])
        {
            Caption = 'Tag Filter';
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(16; "Tag Filter Comparison Operator"; Option)
        {
            Caption = 'Tag Filter Comparison Operator';
            OptionCaption = 'Any,All';
            OptionMembers = Any,All;
            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Not used';
        }
        field(17; "Disable Deployment"; Boolean)
        {
            Caption = 'Disable Deployment';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
        }
    }
}

