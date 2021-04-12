table 6014610 "NPR Retail Campaign Header"
{
    // NPR5.38.01/MHA /20171220  CASE 299436 Object created - Retail Campaign
    // NPR5.38.01/JKL /20180129  CASE 289017 Added Fields Distribution Group, Campaign No.
    // MAG2.26/MHA /20200507  CASE 401235 Added field 6151414 "Magento Category Id"

    Caption = 'Retail Campaign Header';
    DrillDownPageID = "NPR Retail Campaigns";
    LookupPageID = "NPR Retail Campaigns";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;
            DataClassification = CustomerContent;
        }
        field(5; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(50; "Distribution Group"; Code[20])
        {
            Caption = 'Distribution Group';
            TableRelation = "NPR Distrib. Group".Code;
            DataClassification = CustomerContent;
        }
        field(70; "Requested Delivery Date"; Date)
        {
            Caption = 'Requested Delivery Date';
            DataClassification = CustomerContent;
        }
        field(5050; "Campaign No."; Code[20])
        {
            Caption = 'Campaign No.';
            TableRelation = Campaign;
            DataClassification = CustomerContent;
        }
        field(6151414; "Magento Category Id"; Code[20])
        {
            Caption = 'Magento Category Id';
            Description = 'MAG2.26';
            TableRelation = "NPR Magento Category";
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

}

