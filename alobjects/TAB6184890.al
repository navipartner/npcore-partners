table 6184890 "Storage Type"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Types';
    DataClassification = CustomerContent;
    LookupPageID = "Storage Types";

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
        field(20; "Codeunit"; Integer)
        {
            Caption = 'Codeunit ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Storage Type")
        {
        }
    }

    fieldgroups
    {
    }
}

