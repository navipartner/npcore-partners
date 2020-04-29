page 6059770 "NaviDocs Comment Subpage"
{
    // NPR5.30/THRO/20170209 CASE 243998 Logging in Activity Log - Source table changed + added function SetData

    Caption = 'Comments';
    DeleteAllowed = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = ListPart;
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
                field("Activity Date";"Activity Date")
                {
                }
                field(Status;Status)
                {
                }
                field("Activity Message";"Activity Message")
                {
                }
                field("User ID";"User ID")
                {
                }
                field(Description;Description)
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }

    procedure SetData(NaviDocsEntry: Record "NaviDocs Entry";UseActivityLog: Boolean)
    var
        NaviDocsEntryComment: Record "NaviDocs Entry Comment";
        ActivityLog: Record "Activity Log";
    begin
        //-NPR5.30 [243998]
        if not IsTemporary then
          exit;
        DeleteAll;
        if UseActivityLog then begin
          ActivityLog.SetRange("Record ID",NaviDocsEntry.RecordId);
          if ActivityLog.FindSet then
            repeat
              Rec := ActivityLog;
              Insert;
            until ActivityLog.Next = 0;
        end else begin
          NaviDocsEntryComment.SetRange("Entry No.",NaviDocsEntry."Entry No.");
          if NaviDocsEntryComment.FindSet then
            repeat
              Init;
              ID := NaviDocsEntryComment."Line No.";
              "Record ID" := NaviDocsEntry.RecordId;
              "Activity Date" := CreateDateTime(NaviDocsEntryComment."Insert Date",NaviDocsEntryComment."Insert Time");
              "User ID" := NaviDocsEntryComment."User ID";
              if NaviDocsEntryComment.Warning then
                Status := Status::Failed
              else
                Status := Status::Success;
              "Activity Message" := NaviDocsEntryComment.Description;
              Insert(true);
            until NaviDocsEntryComment.Next = 0;
        end;
        CurrPage.Update(false);
        //+NPR5.30 [243998]
    end;
}

