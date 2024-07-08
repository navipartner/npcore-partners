tableextension 6014410 "NPR VAT Posting Setup" extends "VAT Posting Setup"
{
    fields
    {
        field(6014400; "NPR VAT Report Mapping"; Code[20])
        {
            DataClassification = CustomerContent;
            Caption = 'VAT Report Mapping';
            TableRelation = "NPR VAT Report Mapping";
        }
        field(6014401; "NPR Base % For Full VAT"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Base % For Full VAT';
            DecimalPlaces = 0 : 5;
            MaxValue = 100;
            MinValue = 0;
        }
    }
    keys
    {
        key(NPRKey; "NPR VAT Report Mapping") { }
    }
}