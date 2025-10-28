page 6185125 "NPR CloudflareMigrationJobCard"
{
    Extensible = false;
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR CloudflareMigrationJob";
    InsertAllowed = false;
    Caption = 'Cloudflare Media Migration Job Card';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                Caption = 'General';
                field(JobId; Rec.JobId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Id field.';
                    Editable = false;
                    Visible = false;
                }

                field(MediaSelector; Rec.MediaSelector)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Media Selector field.', Comment = '%';
                    ShowMandatory = true;
                    Editable = false;
                }
                field(JobCancelled; Rec.JobCancelled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Job Cancelled field.';
                    Editable = false;
                }
                field(RateLimitPerSecond; Rec.RateLimitPerSecond)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Rate Limit Per Second field.';
                }
                field(LimitFetchCount; Rec.LimitFetchCount)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Limit Fetch Count field.';
                }
                field(NextCursorAfterRowId; Rec.NextCursorAfterRowId)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Next Cursor After Row Id field.';
                    Visible = false;
                }
                field(NextCursorAfterTs; Rec.NextCursorAfterTs)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Next Cursor After Ts field.';
                    Visible = false;
                }

                group(Metrics)
                {
                    Caption = 'Metrics';

                    field(EnqueuedCount; Rec.EnqueuedCount)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Enqueued Count field.';
                        Editable = false;
                    }
                    field(FailedCount; Rec.FailedCount)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Failed Count field.';
                        Editable = false;
                    }

                    field(SuccessCount; Rec.SuccessCount)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Success Count field.';
                        Editable = false;
                    }
                    field(TotalCount; Rec.TotalCount)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies the value of the Total Processed Count field.';
                        Editable = false;
                    }
                }
            }
            part(JobLines; "NPR CloudflareMigrationJobLine")
            {
                Caption = 'Job Lines';
                ApplicationArea = NPRRetail;
                SubPageLink = JobId = field(JobId);
                SubPageView = sorting(JobId, PublicId);
                Visible = true;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(ActionName)
            {
                Caption = 'Start Migration';
                Image = ImportDatabase;
                ToolTip = 'Start Migration will upload job lines to Cloudflare and migration will begin.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                    JobResponse: JsonObject;
                begin
                    if (not CloudflareMedia.StartMigrationJob(Rec.JobId, JobResponse)) then
                        Error(GetLastErrorText());
                    CurrPage.Update(false);
                end;
            }
            action(CancelMigration)
            {
                Caption = 'Cancel Migration';
                Image = Cancel;
                ToolTip = 'Cancels the ongoing migration process.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                    JobResponse: JsonObject;
                begin
                    if (not CloudflareMedia.CancelMigrationJob(Rec.JobId, JobResponse)) then
                        Error(GetLastErrorText());
                    CurrPage.Update(false);
                end;
            }
            action(CheckMigrationStatus)
            {
                Caption = 'Check Migration Status';
                Image = View;
                ToolTip = 'Checks the status of the ongoing migration.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                    JobResponse: JsonObject;
                begin
                    if (not CloudflareMedia.GetMigrationJobStatus(Rec.JobId, JobResponse)) then
                        Error(GetLastErrorText());
                    CurrPage.Update(false);
                end;
            }

            action(FetchMigrationResults)
            {
                Caption = 'Fetch Migration Results';
                Image = Download;
                ToolTip = 'Fetches the results of the completed migration.';
                ApplicationArea = NPRRetail;
                trigger OnAction()
                var
                    CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                    JobResponse: JsonObject;
                    JToken: JsonToken;
                    ItemsArray: JsonArray;
                    DownloadedItemsCount: Integer;
                    Done: Boolean;
                    Dialog: Dialog;
                    Label: Label 'Fetching results:\\Success Count: #1#######\\Failed Count: #2#######\\Migrated Count: #3#######\\Downloaded Count: #4######\\ \\Please wait...';
                begin

                    Dialog.Open(Label);
                    Dialog.Update(1, Rec.SuccessCount);
                    Dialog.Update(2, Rec.FailedCount);
                    Dialog.Update(3, Rec.TotalCount);
                    Dialog.Update(4, DownloadedItemsCount);
                    Sleep((2000)); // Give user a chance to see the dialog before we start updating it (and job will have time to start).

                    repeat
                        if (not CloudflareMedia.GetMigrationJobResults(Rec.JobId, JobResponse)) then
                            Error(GetLastErrorText());
                        Commit();

                        Rec.Get(Rec.JobId);

                        Dialog.Update(1, Rec.SuccessCount);
                        Dialog.Update(2, Rec.FailedCount);
                        Dialog.Update(3, Rec.TotalCount);

                        Done := true;
                        if (JobResponse.Get('items', JToken)) and (JToken.IsArray()) then begin
                            ItemsArray := JToken.AsArray();
                            Done := (ItemsArray.Count() = 0);
                            DownloadedItemsCount += ItemsArray.Count();
                        end;
                        Dialog.Update(4, DownloadedItemsCount);

                        if (not Done) then
                            Sleep(2000);

                    until (Rec.JobCancelled) or (Done);

                    Dialog.Close();
                end;
            }

            action(FinalizeMigration)
            {
                Caption = 'Finalize Migration';
                Image = Approve;
                ToolTip = 'Finalizes the migration process.';
                ApplicationArea = NPRRetail;

                trigger onAction()
                var
                    CloudflareMedia: Codeunit "NPR CloudflareMediaFacade";
                begin
                    if (not CloudflareMedia.FinalizeMigrationJob(Rec.JobId)) then
                        Error(GetLastErrorText());
                    CurrPage.Update(false);
                end;
            }
        }
    }
}