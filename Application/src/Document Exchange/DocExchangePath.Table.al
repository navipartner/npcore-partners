table 6059933 "NPR Doc. Exchange Path"
{
    // NPR5.00/BR /20160804 CASE 244303 Object Created
    // NPR5.26/TJ/20160812 CASE 248831 Added new fields 170 Electronic Format Code and 180 Localization Format Code
    // NPR5.33/BR/20170216 CASE 266527 Added field "Use Export FTP Settings" , "Export Locally"

    Caption = 'Doc. Exchange Path';
    DrillDownPageID = "NPR Doc. Exchange Paths";
    LookupPageID = "NPR Doc. Exchange Paths";
    DataClassification = CustomerContent;

    fields
    {
        field(10; Direction; Option)
        {
            Caption = 'Direction';
            OptionCaption = 'Import,Export';
            OptionMembers = Import,Export;
            DataClassification = CustomerContent;
        }
        field(20; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'All,Customer,Vendor';
            OptionMembers = All,Customer,Vendor;
            DataClassification = CustomerContent;
        }
        field(30; "No."; Code[20])
        {
            Caption = 'No.';
            TableRelation = IF (Type = CONST(Customer)) Customer."No."
            ELSE
            IF (Type = CONST(Vendor)) Vendor."No.";
            DataClassification = CustomerContent;
        }
        field(40; Path; Text[250])
        {
            Caption = 'Path';
            DataClassification = CustomerContent;
        }
        field(50; "Archive Path"; Text[250])
        {
            Caption = 'Archive Path';
            DataClassification = CustomerContent;
        }
        field(60; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;
        }
        field(150; "Unmatched Items Wsht. Template"; Code[10])
        {
            Caption = 'Unmatched Items Wsht. Template';
            Description = 'NPR5.25';
            TableRelation = "NPR Item Worksh. Template";
            DataClassification = CustomerContent;
        }
        field(151; "Unmatched Items Wsht. Name"; Code[10])
        {
            Caption = 'Unmatched Items Wsht. Name';
            Description = 'NPR5.25';
            TableRelation = "NPR Item Worksheet".Name WHERE("Item Template Name" = FIELD("Unmatched Items Wsht. Template"));
            DataClassification = CustomerContent;
        }
        field(155; "Autom. Create Unmatched Items"; Boolean)
        {
            Caption = 'Autom. Create Unmatched Items';
            Description = 'NPR5.25';
            DataClassification = CustomerContent;
        }
        field(160; "Autom. Query Item Information"; Boolean)
        {
            Caption = 'Autom. Query Item Information';
            Description = 'NPR5.25';
            DataClassification = CustomerContent;
        }
        field(170; "Electronic Format Code"; Code[20])
        {
            Caption = 'Electronic Format Code';
            Description = 'NPR5.26';
            TableRelation = "Electronic Document Format".Code;
            DataClassification = CustomerContent;
        }
        field(180; "Localization Format Code"; Boolean)
        {
            Caption = 'Localization Format Code';
            Description = 'NPR5.26';
            DataClassification = CustomerContent;
        }
        field(200; "Use Export FTP Settings"; Boolean)
        {
            Caption = 'Use Export FTP Settings';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
        }
        field(210; "Export Locally"; Boolean)
        {
            Caption = 'Export Locally';
            Description = 'NPR5.33';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; Direction, Type, "No.")
        {
        }
    }

    fieldgroups
    {
    }
}

