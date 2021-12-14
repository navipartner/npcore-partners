table 6014607 "NPR Auth. Param. Buffer"
{
    Caption = 'Authorization Parameters Buffer';
    DataClassification = SystemMetadata;
    TableType = Temporary;

    fields
    {
        field(1; PK; Code[10])
        {
            Caption = 'Basic UserName';
            DataClassification = SystemMetadata;
        }

        field(4; "Auth. Type"; Enum "NPR API Auth. Type")
        {
            Caption = 'Authorization Type';
            DataClassification = SystemMetadata;
        }

        field(5; "Basic UserName"; Code[100])
        {
            Caption = 'Basic UserName';
            DataClassification = CustomerContent;
        }

        field(10; "Basic Password Key"; GUID)
        {
            Caption = 'Basic Password Key';
            DataClassification = CustomerContent;
        }

        field(15; "OAuth Setup Code"; Code[20])
        {
            Caption = 'OAuth Setup Code';
            DataClassification = CustomerContent;
        }

        field(20; "Custom Auth."; Text[250])
        {
            Caption = 'Custom Authorization';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; PK)
        {
            Clustered = true;
        }
    }

}
