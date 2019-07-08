table 6151532 "Nc Endpoint Trigger Link"
{
    // NC2.01\BR\20160921  CASE 248630 Object created

    Caption = 'Nc Endpoint Trigger Link';
    DrillDownPageID = "Nc Endpoint Trigger Links";
    LookupPageID = "Nc Endpoint Trigger Links";

    fields
    {
        field(20;"Endpoint Code";Code[20])
        {
            Caption = 'Endpoint Code';
            TableRelation = "Nc Endpoint";
        }
        field(30;"Trigger Code";Code[20])
        {
            Caption = 'Trigger Code';
            TableRelation = "Nc Trigger";
        }
    }

    keys
    {
        key(Key1;"Endpoint Code","Trigger Code")
        {
        }
        key(Key2;"Trigger Code")
        {
        }
    }

    fieldgroups
    {
    }
}

