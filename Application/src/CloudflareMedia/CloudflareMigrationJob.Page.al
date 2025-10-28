page 6185124 "NPR CloudflareMigrationJob"
{
    Extensible = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR CloudflareMigrationJob";
    CardPageId = "NPR CloudflareMigrationJobCard";

    Editable = false;
    Caption = 'Cloudflare Media Migration Jobs';

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
                }
                field(SystemCreatedAt; Rec.SystemCreatedAt)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the SystemCreatedAt field.';
                }
                field(EnqueuedCount; Rec.EnqueuedCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Enqueued Count field.';
                }

                field(TotalCount; Rec.TotalCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Total Count field.';
                }
                field(SuccessCount; Rec.SuccessCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Success Count field.';
                }
                field(FailedCount; Rec.FailedCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Failed Count field.';
                }
                field(JobCancelled; Rec.JobCancelled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Cancelled field.';
                }
                field(RateLimitPerSecond; Rec.RateLimitPerSecond)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rate Limit Per Second field.';
                }
            }
        }
    }

}