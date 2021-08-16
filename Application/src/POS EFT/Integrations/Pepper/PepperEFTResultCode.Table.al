table 6184489 "NPR Pepper EFT Result Code"
{
    // NPR5.20/BR  /20160316  CASE 231481 Object Created
    // NPR5.28/BR  /20161128  CASE 259563 Added field for "Open Terminal and Retry"
    // NPR5.30/BR  /20170113  CASE 263458 Renamed Object from Pepper to EFT, added Fields Integration Type and Transaction Subtype fields, changed field Result Code to Code
    // NPR5.46/MMV /20180714 CASE 290734 Renamed

    Caption = 'Pepper EFT Result Code';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR Pepper EFT Result Codes";
    LookupPageID = "NPR Pepper EFT Result Codes";

    fields
    {
        field(5; "Integration Type"; Code[20])
        {
            Caption = 'Integration Type';
            DataClassification = CustomerContent;
        }
        field(10; "Transaction Type Code"; Code[10])
        {
            Caption = 'Transaction Type Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper EFT Trx Type".Code WHERE("Integration Type" = FIELD("Integration Type"));
        }
        field(15; "Transaction Subtype Code"; Code[10])
        {
            Caption = 'Transaction Subtype Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR Pepper EFT Trx Subtype".Code WHERE("Integration Type Code" = FIELD("Integration Type"),
                                                                         "Transaction Type Code" = FIELD("Transaction Type Code"));
        }
        field(20; "Code"; Integer)
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
        }
        field(30; Description; Text[50])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(35; "Long Description"; Text[250])
        {
            Caption = 'Long Description';
            DataClassification = CustomerContent;
        }
        field(40; Successful; Boolean)
        {
            Caption = 'Successful';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                //-NPR5.28 [259563]
                if Successful then
                    TestField("Open Terminal and Retry", false);
                //+NPR5.28 [259563]
            end;
        }
        field(50; "Open Terminal and Retry"; Boolean)
        {
            Caption = 'Open Terminal and Retry';
            DataClassification = CustomerContent;
            Description = 'NPR5.31';

            trigger OnValidate()
            begin
                //-NPR5.28 [259563]
                if "Open Terminal and Retry" then
                    TestField(Successful, false);
                //+NPR5.28 [259563]
            end;
        }
    }

    keys
    {
        key(Key1; "Integration Type", "Transaction Type Code", "Transaction Subtype Code", "Code")
        {
        }
    }

    fieldgroups
    {
    }
}

