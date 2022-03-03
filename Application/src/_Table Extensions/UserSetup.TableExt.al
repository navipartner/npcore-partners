tableextension 6014454 "NPR User Setup" extends "User Setup"
{
    fields
    {
        field(6014401; "NPR POS Unit No."; Code[10])
        {
            Caption = 'POS Unit No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Unit";
        }
        field(6014405; "NPR Allow Register Switch"; Boolean)
        {
            Caption = 'Allow POS Unit Switch';
            DataClassification = CustomerContent;
            Description = 'NPR5.38';
            TableRelation = "NPR POS Unit";
            ValidateTableRelation = false;
        }
        field(6060150; "NPR MM Allow MS Entry Edit"; Boolean)
        {
            Caption = 'Allow Membership Entry Edit';
            DataClassification = CustomerContent;
        }
        field(6014410; "NPR Register Switch Filter"; Text[100])
        {
            Caption = 'POS Unit Switch Filter';
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
    }
}