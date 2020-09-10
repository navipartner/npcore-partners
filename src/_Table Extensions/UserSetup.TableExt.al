tableextension 6014454 "NPR User Setup" extends "User Setup"
{
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
        field(6150660; "NPR Backoffice Restaurant Code"; Code[20])
        {
            Caption = 'Backoffice Restaurant Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPRE Restaurant";
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
