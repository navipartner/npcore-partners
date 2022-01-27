page 6059834 "NPR Event Comment Sheet"
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Comment Sheet';
    DataCaptionFields = "No.";
    DelayedInsert = true;
    LinksAllowed = false;
    MultipleNewLines = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "Comment Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Date"; Rec.Date)
                {
                    ToolTip = 'Specifies the date the comment was created.';
                    ApplicationArea = NPRRetail;
                }
                field(Comment; Rec.Comment)
                {
                    ToolTip = 'Specifies the comment itself.';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies a code for the comment.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine();
    end;
}
