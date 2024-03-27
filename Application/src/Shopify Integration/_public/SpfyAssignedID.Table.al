#if not BC17
table 6150813 "NPR Spfy Assigned ID"
{
    Access = Public;
    DataClassification = CustomerContent;
    Caption = 'Assigned Shopify ID';
    LookupPageId = "NPR Spfy Assigned IDs";
    DrillDownPageId = "NPR Spfy Assigned IDs";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
        }
        field(3; "BC Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'BC Record ID';
        }
        field(4; "Shopify ID Type"; Enum "NPR Spfy ID Type")
        {
            DataClassification = CustomerContent;
            Caption = 'Shopify ID Type';
        }
        field(5; "Shopify ID"; Text[30])
        {
            DataClassification = CustomerContent;
            Caption = 'Shopify ID';
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(RelationFromBCTables; "Table No.", "BC Record ID", "Shopify ID Type") { }
        key(DuplicateSearch; "Table No.", "Shopify ID Type", "Shopify ID") { }
        key(FindWhereUsed; "Shopify ID Type", "Shopify ID") { }
    }
}
#endif