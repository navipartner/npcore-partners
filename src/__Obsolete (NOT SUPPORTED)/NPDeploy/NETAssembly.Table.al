table 6014623 "NPR .NET Assembly"
{
    // NPR4.17/VB/20151106 CASE 219641 Object created to support automatic assembly deployment
    // NPR5.00.01/VB/20160126  CASE 232615 Changing DataPerCompany to No
    // NPR5.01/VB/20160223 CASE 234541 Support for storing and using debug information at assembly deployment
    // NPR5.37/MMV /20171019 CASE 293066 Added hash support.

    Caption = '.NET Assembly';
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced with dependency mgt. extension downloading files to add-in NST folder instead of deploying runtime from npdeploy';

    fields
    {
        field(1; "Assembly Name"; Text[250])
        {
            Caption = 'Assembly Name';
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            TableRelation = User."User Name";
            ValidateTableRelation = false;
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; Assembly; BLOB)
        {
            Caption = 'Assembly';
        }
        field(11; "Debug Information"; BLOB)
        {
            Caption = 'Debug Information';
        }
        field(12; "MD5 Hash"; Text[32])
        {
            Caption = 'MD5 Hash';
        }
    }

    keys
    {
        key(Key1; "Assembly Name", "User ID")
        {
        }
    }

    fieldgroups
    {
    }
}

