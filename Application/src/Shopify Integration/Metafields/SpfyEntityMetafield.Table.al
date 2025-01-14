#if not BC17
table 6150951 "NPR Spfy Entity Metafield"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Shopify Entity Metafield';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Entity Metafields";
    LookupPageId = "NPR Spfy Entity Metafields";

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
            AutoIncrement = true;
        }
        field(10; "Table No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Table No.';
        }
        field(20; "BC Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'BC Record ID';
        }
        field(50; "Owner Type"; Enum "NPR Spfy Metafield Owner Type")
        {
            Caption = 'Owner Type';
            DataClassification = CustomerContent;
        }
        field(60; "Metafield ID"; Text[30])
        {
            Caption = 'Metafield ID';
            DataClassification = CustomerContent;
        }
        field(70; "Metafield Key"; Text[80])
        {
            Caption = 'Metafield Key';
            DataClassification = CustomerContent;
        }
        field(80; "Metafield Value"; Text[250])
        {
            Caption = 'Metafield Value';
            DataClassification = CustomerContent;
        }
        field(90; "Metafield Value Version ID"; Text[80])
        {
            Caption = 'Metafield Value Version ID';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "BC Record ID", "Owner Type", "Metafield ID") { }
        key(Key3; "Owner Type", "Metafield ID", "Table No.") { }
    }
}
#endif