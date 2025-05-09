﻿table 6151562 "NPR NpXml Api Header"
{
    Access = Internal;
    Caption = 'NpXml Api Header';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Xml Template Code"; Code[20])
        {
            Caption = 'Xml Template Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPR NpXml Template";

            ValidateTableRelation = false;
        }
        field(5; Name; Text[250])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; Value; Text[250])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Xml Template Code", Name)
        {
        }
    }
}

