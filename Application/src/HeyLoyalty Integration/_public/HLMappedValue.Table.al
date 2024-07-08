table 6059839 "NPR HL Mapped Value"
{
    Access = Public;
    Caption = 'HeyLoyalty Mapped Value';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            DataClassification = CustomerContent;
            AutoIncrement = true;
        }
        field(2; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(3; "BC Record ID"; RecordId)
        {
            Caption = 'BC Record ID';
            DataClassification = CustomerContent;
        }
        field(4; "Attached to Field No."; Integer)
        {
            Caption = 'Attached to Field No.';
            DataClassification = CustomerContent;
        }
        field(10; Value; Text[100])
        {
            Caption = 'Value';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(RelationFromNavTables; "Table No.", "BC Record ID", "Attached to Field No.") { }
        key(MappedRecordSearch; "Table No.", "Attached to Field No.", Value) { }
    }
}