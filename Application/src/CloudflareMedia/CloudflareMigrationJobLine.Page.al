page 6185126 "NPR CloudflareMigrationJobLine"
{
    Extensible = false;
    Caption = 'NPR Cloudflare Migration Job Line';
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR CloudflareMigrationJobLine";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Id field.';
                    Visible = false;
                }
                field(PublicId; Rec.PublicId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Public Id field.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Status field.';
                }
                field(ContentType; Rec.ContentType)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Content Type field.';
                }
                field(FileSize; Rec.FileSize)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the File Size field.';
                }
                field(ImageUrl; Rec.ImageUrl)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Image Url field.';
                }
                field(MediaKey; Rec.MediaKey)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Media Key field.';
                }
                field(Reason; Rec.Reason)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Reason field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(SetStatusPending)
            {
                Caption = 'Set Status to Pending';
                ToolTip = 'Sets the status of selected job lines to Pending.';
                Image = Status;
                ApplicationArea = NPRRetail;
                Scope = Repeater;
                trigger OnAction()
                var
                    JobLine: Record "NPR CloudflareMigrationJobLine";
                begin
                    CurrPage.SetSelectionFilter(JobLine);
                    JobLine.ModifyAll(Status, JobLine.Status::Pending);
                end;
            }
        }
    }
}