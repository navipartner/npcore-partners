page 6150874 "NPR Waiterpad Flow Stat. Step"
{
    Extensible = False;
    Caption = 'Waiterpad Flow Statuses';
    DeleteAllowed = false;
    PageType = ListPart;
    SourceTable = "NPR NPRE Flow status";
    SourceTableTemporary = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code to identify this status.';
                    ApplicationArea = NPRRetail;
                }
                field("Status Object"; Rec."Status Object")
                {
                    Editable = false;
                    ToolTip = 'Specifies the object this status is applicable for.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies a text that describes the status.';
                    ApplicationArea = NPRRetail;
                }
                field("Available in Front-End"; Rec."Available in Front-End")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether this status is visible in restaurant view.';
                }
                field(Color; Rec.Color)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the color of the status in restaurant view.';
                }
                field("Status Color Priority"; Rec."Status Color Priority")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the priority this status takes, when defining table colors in restaurant view. Higher number means higher priority.';
                }
                field("Icon Class"; Rec."Icon Class")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the icon of the status in restaurant view.';
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec."Status Object" := Rec."Status Object"::WaiterPad;
    end;

    internal procedure CopyLiveData()
    var
        FlowStatus: Record "NPR NPRE Flow status";
    begin
        Rec.DeleteAll();

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPad);
        if FlowStatus.FindSet() then
            repeat
                Rec := FlowStatus;
                if not Rec.Insert() then
                    Rec.Modify();
            until FlowStatus.Next() = 0;
    end;

    internal procedure CopyTempWaiterPadStatuses(var FlowStatus: Record "NPR NPRE Flow status")
    begin
        if Rec.FindSet() then
            repeat
                FlowStatus := Rec;
                if not FlowStatus.Insert() then
                    FlowStatus.Modify();
            until Rec.Next() = 0;
    end;

    internal procedure WaiterpadFlowStatusesToCreate(): Boolean
    begin
        exit(Rec.FindSet());
    end;

    internal procedure CreateWaiterpadFlowStatuses()
    var
        FlowStatus: Record "NPR NPRE Flow status";
    begin
        if Rec.FindSet() then
            repeat
                FlowStatus := Rec;
                if not FlowStatus.Insert() then
                    FlowStatus.Modify();
            until Rec.Next() = 0;
    end;
}
