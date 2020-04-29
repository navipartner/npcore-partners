table 6184891 "Storage Operation Type"
{
    // NPR5.54/ALST/20200311 CASE 394895 Object created

    Caption = 'Storage Operations';
    LookupPageID = "Storage Operation Types";

    fields
    {
        field(1;"Storage Type";Code[20])
        {
            Caption = 'Storage Type';
        }
        field(10;Description;Text[250])
        {
            Caption = 'Description';
        }
        field(20;"Operation Code";Code[20])
        {
            Caption = 'Operation Code';
        }
    }

    keys
    {
        key(Key1;"Storage Type","Operation Code")
        {
        }
    }

    fieldgroups
    {
    }
}

