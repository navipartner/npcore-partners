table 6184505 "EFT Aux Operation"
{
    // NPR5.46/MMV /20181008 CASE 290734 Created object

    Caption = 'EFT Aux Operation';
    DrillDownPageID = "EFT Auxiliary Operations";
    LookupPageID = "EFT Auxiliary Operations";

    fields
    {
        field(1;"Integration Type";Code[20])
        {
            Caption = 'Integration Type';
        }
        field(2;"Auxiliary ID";Integer)
        {
            Caption = 'Auxiliary ID';
        }
        field(3;Description;Text[50])
        {
            Caption = 'Description';
        }
    }

    keys
    {
        key(Key1;"Integration Type","Auxiliary ID")
        {
        }
    }

    fieldgroups
    {
    }
}

