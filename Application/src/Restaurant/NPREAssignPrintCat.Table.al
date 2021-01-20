table 6150670 "NPR NPRE Assign. Print Cat."
{
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
            TableRelation = "NPR NPRE Print/Prod. Cat.";
        }
    }

    keys
    {
        key(Key1; "Table No.", "Record ID", "Print/Prod. Category Code")
        {
        }
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
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
}