table 6150668 "NPRE Item Routing Profile"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Rest. Item Routing Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPRE Item Routing Profiles";
    LookupPageID = "NPRE Item Routing Profiles";

    fields
    {
        field(10; "Code"; Code[20])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(20; Description; Text[50])
        {
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        WaiterPadMgt.ClearAssignedPrintCategories(RecordId);
        WaiterPadMgt.ClearAssignedFlowStatuses(RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
    end;

    trigger OnRename()
    begin
        WaiterPadMgt.MoveAssignedPrintCategories(xRec.RecordId, RecordId);
        WaiterPadMgt.MoveAssignedFlowStatuses(xRec.RecordId, RecordId, FlowStatus."Status Object"::WaiterPadLineMealFlow);
    end;

    var
        FlowStatus: Record "NPRE Flow Status";
        WaiterPadMgt: Codeunit "NPRE Waiter Pad Management";

    procedure AssignedPrintCategoriesAsString(): Text
    begin
        exit(WaiterPadMgt.AssignedPrintCategoriesAsFilterString(RecordId, ''));
    end;

    procedure ShowPrintCategories()
    begin
        TestField(Code);
        WaiterPadMgt.SelectPrintCategories(RecordId);
    end;

    procedure AssignedFlowStatusesAsString(StatusObject: Option): Text
    var
        AssignedFlowStatus: Record "NPRE Assigned Flow Status";
    begin
        exit(WaiterPadMgt.AssignedFlowStatusesAsFilterString(RecordId, StatusObject, AssignedFlowStatus));
    end;

    procedure ShowFlowStatuses(StatusObject: Option)
    var
        AssignedFlowStatus: Record "NPRE Assigned Flow Status";
    begin
        TestField(Code);
        WaiterPadMgt.SelectFlowStatuses(RecordId, StatusObject, AssignedFlowStatus);
    end;
}

