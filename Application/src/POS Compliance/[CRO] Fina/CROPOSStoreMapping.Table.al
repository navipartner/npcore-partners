table 6151270 "NPR CRO POS Store Mapping"
{
    Access = Internal;
    Caption = 'CRO POS Store Mapping';
    DataClassification = CustomerContent;
    LookupPageId = "NPR CRO POS Store Mapping";
    DrillDownPageId = "NPR CRO POS Store Mapping";

    fields
    {
        field(1; "POS Store Code"; Code[10])
        {
            Caption = 'POS Store Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR POS Store";
            NotBlank = true;
        }
        field(2; "Bill No. Series"; Code[20])
        {
            Caption = 'Bill No. Series';
            DataClassification = CustomerContent;
            TableRelation = "No. Series";
        }
    }

    keys
    {
        key(PK; "POS Store Code")
        {
            Clustered = true;
        }
    }
}