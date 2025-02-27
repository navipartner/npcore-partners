#if not BC17
table 6151049 "NPR Spfy Tag Update Request"
{
    Access = Internal;
    Extensible = false;
    Caption = 'Shopify Tag Update Request';
    DataClassification = CustomerContent;
    DrillDownPageId = "NPR Spfy Tag Update Requests";
    LookupPageId = "NPR Spfy Tag Update Requests";

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
        field(30; Source; Option)
        {
            Caption = 'Source';
            DataClassification = CustomerContent;
            OptionMembers = "Item Category";
            OptionCaption = 'Item Category';
        }
        field(40; "Nc Task Entry No."; BigInteger)
        {
            Caption = 'Nc Task Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task"."Entry No.";
        }
        field(50; Type; Option)
        {
            Caption = 'Type';
            DataClassification = CustomerContent;
            OptionMembers = "Add","Remove";
            OptionCaption = 'Add, Remove';
        }
        field(80; "Tag Value"; Text[100])
        {
            Caption = 'Tag Value';
            DataClassification = CustomerContent;
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Table No.", "BC Record ID", Type) { }
        key(Key3; "Table No.", "BC Record ID", "Tag Value") { }
        key(Key4; "Nc Task Entry No.") { }
    }
}
#endif