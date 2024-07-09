﻿table 6151370 "NPR CS User"
{
    Access = Internal;
    Caption = 'CS User';
    DataClassification = CustomerContent;
    ObsoleteState = Removed;
    ObsoleteTag = '2023-06-28';
    ObsoleteReason = 'Object moved to NP Warehouse App.';

    fields
    {
        field(1; Name; Code[50])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(11; Password; Text[250])
        {
            Caption = 'Password';
            DataClassification = CustomerContent;
            NotBlank = true;

        }
        field(12; "View All Documents"; Boolean)
        {
            Caption = 'View All Documents';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Name)
        {
        }
    }

    fieldgroups
    {
    }


}

