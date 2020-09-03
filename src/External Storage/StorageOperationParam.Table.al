table 6184893 "NPR Storage Operation Param."
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operation Parameters';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Storage Type"; Text[24])
        {
            Caption = 'Storage Type';
            DataClassification = CustomerContent;
        }
        field(10; "Operation Code"; Code[20])
        {
            Caption = 'Operation Code';
            DataClassification = CustomerContent;
        }
        field(20; "Parameter Key"; Integer)
        {
            Caption = 'Key';
            DataClassification = CustomerContent;
        }
        field(30; "Parameter Name"; Text[30])
        {
            Caption = 'Name';
            DataClassification = CustomerContent;
        }
        field(40; "Parameter Value"; Text[250])
        {
            Caption = 'Parametr Value';
            DataClassification = CustomerContent;
        }
        field(50; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(60; "Mandatory For Job Queue"; Boolean)
        {
            Caption = 'Mandatory For Job Queue';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage Type", "Operation Code", "Parameter Key")
        {
        }
    }

    fieldgroups
    {
    }
}

