﻿table 6014614 "NPR DotNet Assembly"
{
    Access = Internal;
    Caption = '.NET Assembly';
    DataPerCompany = false;
    ObsoleteState = Removed;
    ObsoleteTag = '2024-02-28';
    ObsoleteReason = 'No longer used';


    fields
    {
        field(1; "Assembly Name"; Text[250])
        {
            Caption = 'Assembly Name';
            DataClassification = CustomerContent;
        }
        field(2; "User ID"; Code[50])
        {
            Caption = 'User ID';
            DataClassification = EndUserIdentifiableInformation;
        }
        field(10; Assembly; BLOB)
        {
            Caption = 'Assembly';
            DataClassification = CustomerContent;
        }
        field(11; "Debug Information"; BLOB)
        {
            Caption = 'Debug Information';
            DataClassification = CustomerContent;
        }
        field(12; "MD5 Hash"; Text[32])
        {
            Caption = 'MD5 Hash';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Assembly Name", "User ID")
        {
        }
    }
}