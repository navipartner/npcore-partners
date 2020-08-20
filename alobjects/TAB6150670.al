table 6150670 "NPRE Assigned Print Category"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Assigned Print Category';
    DataClassification = CustomerContent;

    fields
    {
        field(10; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
        }
        field(20; "Record ID"; RecordID)
        {
            Caption = 'Record ID';
            DataClassification = CustomerContent;
        }
        field(40; "Print/Prod. Category Code"; Code[20])
        {
            Caption = 'Print/Prod. Category Code';
            DataClassification = CustomerContent;
            NotBlank = true;
            TableRelation = "NPRE Print/Prod. Category";
        }
    }

    keys
    {
        key(Key1; "Table No.", "Record ID", "Print/Prod. Category Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        WaiterPadMgt.ClearAssignedFlowStatuses(RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
    end;

    trigger OnRename()
    begin
        WaiterPadMgt.MoveAssignedFlowStatuses(xRec.RecordId, RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
    end;

    var
        FlowStatus: Record "NPRE Flow Status";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";
}

