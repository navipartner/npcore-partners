table 6151166 "NPR UserAccountSetup"
{
    Access = Internal;
    Caption = 'User Account Setup';

    fields
    {
        field(1; PrimaryKey; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(3; RequireUniquePhoneNo; Boolean)
        {
            Caption = 'Require Unique Phone Number';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }
}