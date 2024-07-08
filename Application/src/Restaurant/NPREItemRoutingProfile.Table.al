table 6150668 "NPR NPRE Item Routing Profile"
{
    Access = Internal;
    Caption = 'Rest. Item Routing Profile';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR NPRE Item Routing Profiles";
    LookupPageID = "NPR NPRE Item Routing Profiles";

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
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
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
        FlowStatus: Record "NPR NPRE Flow Status";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";

    procedure AssignedPrintCategoriesAsString(): Text
    begin
        exit(WaiterPadMgt.AssignedPrintCategoriesAsFilterString(RecordId, ''));
    end;

    procedure ShowPrintCategories()
    begin
        TestField(Code);
        WaiterPadMgt.SelectPrintCategories(RecordId);
    end;

    procedure AssignedFlowStatusesAsString(StatusObject: Enum "NPR NPRE Status Object"): Text
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        exit(WaiterPadMgt.AssignedFlowStatusesAsFilterString(RecordId, StatusObject, AssignedFlowStatus));
    end;

    procedure ShowFlowStatuses(StatusObject: Enum "NPR NPRE Status Object")
    var
        AssignedFlowStatus: Record "NPR NPRE Assigned Flow Status";
    begin
        TestField(Code);
        WaiterPadMgt.SelectFlowStatuses(RecordId, StatusObject, AssignedFlowStatus);
    end;
}
