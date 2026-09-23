table 6059914 "NPR Spfy Task"
{
    Access = Internal;
    Caption = 'Shopify Task';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; BigInteger)
        {
            Caption = 'Entry No.';
            AutoIncrement = true;
            Editable = false;
        }
        field(2; Type; Enum "NPR Spfy Task Op")
        {
            Caption = 'Type';
            Editable = false;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            Editable = false;
        }
        field(4; "Table Name"; Text[250])
        {
            CalcFormula = Lookup(AllObjWithCaption."Object Caption" WHERE("Object Type" = CONST(Table),
                                                                           "Object ID" = FIELD("Table No.")));
            Caption = 'Table Name';
            Editable = false;
            FieldClass = FlowField;
        }
        field(6; "Log Date"; DateTime)
        {
            Caption = 'Log Date';
            Editable = false;
        }
        field(7; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
        }
        field(8; "Record Value"; Text[50])
        {
            Caption = 'Record Value';
            Editable = false;
        }
        field(9; "Store Code"; Code[20])
        {
            Caption = 'Store Code';
            TableRelation = "NPR Spfy Store".Code;
        }
        field(10; "Not Before Date-Time"; DateTime)
        {
            Caption = 'Not Before Date-Time';
        }
        field(20; State; Enum "NPR Spfy Task State")
        {
            Caption = 'State';
            Editable = false;
        }
        field(21; Attempts; Integer)
        {
            Caption = 'Attempts';
            Editable = false;
        }
        field(22; "Claimed At"; DateTime)
        {
            Caption = 'Claimed At';
            Editable = false;
        }
        field(23; "Claimed By Server Instance"; Integer)
        {
            Caption = 'Claimed By Server Instance';
            Editable = false;
        }
        field(24; "Claimed By Session"; Integer)
        {
            Caption = 'Claimed By Session';
            Editable = false;
        }
        field(25; "Dispatch Id"; Guid)
        {
            Caption = 'Dispatch Id';
            Editable = false;
        }
        field(26; "Waiting Since"; DateTime)
        {
            Caption = 'Waiting Since';
            Editable = false;
        }
        field(27; "Waiting Reason"; Text[250])
        {
            Caption = 'Waiting Reason';
            Editable = false;
        }
        field(29; "Completed At"; DateTime)
        {
            Caption = 'Completed At';
            Editable = false;
        }
        field(30; "Migrated From NC Entry No."; BigInteger)
        {
            Caption = 'Migrated From NC Entry No.';
            Editable = false;
        }
        field(100; Response; Blob)
        {
            Caption = 'Response';
        }
        field(110; "Data Output"; Blob)
        {
            Caption = 'Sent Request';
        }
        field(120; "Last Processing Started at"; DateTime)
        {
            Caption = 'Last Processing Started at';
            Editable = false;
        }
        field(121; "Last Processing Completed at"; DateTime)
        {
            Caption = 'Last Processing Completed at';
            Editable = false;
        }
        field(122; "Last Processing Duration"; Decimal)
        {
            Caption = 'Last Processing Duration (sec.)';
            Editable = false;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
        key(Ready; "Store Code", State, "Not Before Date-Time")
        {
        }
        key(Retention; State, "Completed At")
        {
        }
        key(Dedup; "Table No.", "Store Code", "Record Value", State)
        {
        }
        key(MigratedFrom; "Migrated From NC Entry No.")
        {
        }
    }

    trigger OnDelete()
    var
        SpfyTagMgt: Codeunit "NPR Spfy Tag Mgt.";
    begin
        SpfyTagMgt.RemoveSpfyTaskTagUpdateRequests("Entry No.");
    end;
}
