#if not BC17
table 6151178 "NPR Spfy ID/Task Buffer"
{
    Access = Internal;
    Caption = 'Shopify Owner ID/Task Buffer';
    DataClassification = CustomerContent;
    TableType = Temporary;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Entry No.';
        }
        field(10; "Record Value"; Text[50])
        {
            DataClassification = CustomerContent;
            Caption = 'Record Value';
        }
        field(20; "Nc Task Entry No."; BigInteger)
        {
            Caption = 'Nc Task Entry No.';
            DataClassification = CustomerContent;
            TableRelation = "NPR Nc Task"."Entry No.";
        }
        field(30; "Related Record ID"; RecordId)
        {
            DataClassification = CustomerContent;
            Caption = 'Related Record ID';
        }
    }
    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(BySKU; "Record Value") { }
    }

    procedure RecordValueExists(RecordValue: Text[50]): Boolean
    begin
        SetRange("Record Value", RecordValue);
        exit(FindFirst());
    end;

    procedure AddEntry(RecordValue: Text[50]; NcTaskEntryNo: BigInteger; RelatedRecordID: RecordId)
    begin
        Reset();
        if FindLast() then
            "Entry No." += 1
        else
            "Entry No." := 0;
        Init();
        "Record Value" := RecordValue;
        "Nc Task Entry No." := NcTaskEntryNo;
        "Related Record ID" := RelatedRecordID;
        Insert();
    end;
}
#endif