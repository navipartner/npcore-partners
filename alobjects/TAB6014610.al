table 6014610 "Retail Campaign Header"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign
    // NPR5.38.01/JKL /20180129  CASE 289017 Added Fields Distribution Group, Campaign No.

    Caption = 'Retail Campaign Header';
    DrillDownPageID = "Retail Campaigns";
    LookupPageID = "Retail Campaigns";

    fields
    {
        field(1;"Code";Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
        }
        field(5;Description;Text[50])
        {
            Caption = 'Description';
        }
        field(50;"Distribution Group";Code[20])
        {
            Caption = 'Distribution Group';
            TableRelation = "Distribution Group".Code;
        }
        field(70;"Requested Delivery Date";Date)
        {
            Caption = 'Requested Delivery Date';
        }
        field(5050;"Campaign No.";Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;
        }
    }

    keys
    {
        key(Key1;"Code")
        {
        }
    }

    fieldgroups
    {
    }

    var
        DimMgt: Codeunit DimensionManagement;
        Text000: Label 'You may have changed a dimension.\\Do you want to update the lines?';
}

