table 6184860 "NPR Azure Storage API Setup"
{
    Caption = 'Azure Storage API Setup';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteReason = 'Not used';

    fields
    {
        field(1; "Account Name"; Text[24])
        {
            Caption = 'Azure Account Name';
            DataClassification = CustomerContent;
        }
        field(5; "Account Description"; Text[250])
        {
            Caption = 'Azure Account Description';
            DataClassification = CustomerContent;
        }
        field(10; "Access Key"; Guid)
        {
            Caption = 'Shared Access Key';
            DataClassification = CustomerContent;
            Description = 'Storage account -> Settings section -> Access keys -> key1 or key2';
        }
        field(20; "Admin Key"; Guid)
        {
            Caption = 'Search App Admin Key';
            DataClassification = CustomerContent;
            Description = 'Search Service -> Settings section -> Keys -> "Primary admin key" or "Secondary admin key"';
        }
        field(30; Timeout; Integer)
        {
            Caption = 'Timeout';
            DataClassification = CustomerContent;
            Description = 'Miliseconds. Accounts are set up per region, might affect request timeout threshold';
        }
        field(40; "Storage On Server"; Text[250])
        {
            Caption = 'Server files location';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Account Name")
        {
        }
    }

    fieldgroups
    {
    }
}
