table 6184891 "Storage Operation Type"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operations';
    DataClassification = CustomerContent;
    LookupPageID = "Storage Operation Types";

    fields
    {
        field(1; "Storage Type"; Code[20])
        {
            Caption = 'Storage Type';
            DataClassification = CustomerContent;
        }
        field(10; Description; Text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(20; "Operation Code"; Code[20])
        {
            Caption = 'Operation Code';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage Type", "Operation Code")
        {
        }
    }

    fieldgroups
    {
    }
}

