page 6059770 "NPR NaviDocs Comment Subpage"
{

    Caption = 'Comments';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    RefreshOnActivate = true;
    SourceTable = "Activity Log";
    SourceTableTemporary = true;
    SourceTableView = SORTING("Activity Date");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Activity Date"; Rec."Activity Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activity Date field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Activity Message"; Rec."Activity Message")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Activity Message field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Description field';
                }
            }
        }
    }

    procedure SetData(NaviDocsEntry: Record "NPR NaviDocs Entry"; UseActivityLog: Boolean)
    var
        NaviDocsEntryComment: Record "NPR NaviDocs Entry Comment";
        ActivityLog: Record "Activity Log";
    begin
        if not Rec.IsTemporary then
            exit;
        Rec.DeleteAll;
        if UseActivityLog then begin
            ActivityLog.SetRange("Record ID", NaviDocsEntry.RecordId);
            if ActivityLog.FindSet then
                repeat
                    Rec := ActivityLog;
                    Rec.Insert;
                until ActivityLog.Next = 0;
        end else begin
            NaviDocsEntryComment.SetRange("Entry No.", NaviDocsEntry."Entry No.");
            if NaviDocsEntryComment.FindSet then
                repeat
                    Rec.Init;
                    Rec.ID := NaviDocsEntryComment."Line No.";
                    Rec."Record ID" := NaviDocsEntry.RecordId;
                    Rec."Activity Date" := CreateDateTime(NaviDocsEntryComment."Insert Date", NaviDocsEntryComment."Insert Time");
                    Rec."User ID" := NaviDocsEntryComment."User ID";
                    if NaviDocsEntryComment.Warning then
                        Rec.Status := Rec.Status::Failed
                    else
                        Rec.Status := Rec.Status::Success;
                    Rec."Activity Message" := NaviDocsEntryComment.Description;
                    Rec.Insert(true);
                until NaviDocsEntryComment.Next = 0;
        end;
        CurrPage.Update(false);
    end;
}

