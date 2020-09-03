tableextension 6014454 "NPR User Setup" extends "User Setup"
{
    // NPR7.100.000/LS/220114  : Retail Merge
    //                                       Added fields 6014400
    // NPR5.20/VB  /20160226  CASE 235620 Added field 6014627
    // NPR5.26/MMV /20160905  CASE 242977 Removed field 6014627.
    // NPR5.27/BHR /20160930  CASE 253589 Add lookup to field 'Use register'
    // NPR5.38/MHA /20180115  CASE 302240 Added fields 6014405 "Allow Register Switch" and 6014410 "Register Switch Filter"
    // NPR5.46/MMV /20181003  CASE 290734 Renamed field 6014400 to make its purpose clear when used with transcendence.
    // NPR5.52/ZESO/20190925  CASE 358656 Added Field Anonymize Customers
    // NPR5.54/TSA /20200221 CASE 392247 Added field "Block Role Center"
    fields
    {
        field(6014400; "NPR Backoffice Register No."; Code[10])
        {
            Caption = 'Backoffice Register No.';
            DataClassification = CustomerContent;
            Description = 'NPR7.100.000';
            TableRelation = "NPR Register";
        }
        field(6014405; "NPR Allow Register Switch"; Boolean)
        {
            Caption = 'Allow Register Switch';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            TableRelation = "NPR Register";
            //This property is currently not supported
            //TestTableRelation = false;
            ValidateTableRelation = false;
        }
        field(6014410; "NPR Register Switch Filter"; Text[100])
        {
            Caption = 'Register Switch Filter';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
        }
        field(6151060; "NPR Anonymize Customers"; Boolean)
        {
            Caption = 'Anonymize Customers';
            DataClassification = CustomerContent;
            Description = 'NPR5.52';
        }
        field(6151070; "NPR Block Role Center"; Boolean)
        {
            Caption = 'Block Role Center';
            DataClassification = CustomerContent;
        }
    }
}

