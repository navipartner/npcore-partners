#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6150919 "NPR Digital Notification Setup"
{
    Caption = 'Digital Notification Setup';
    PageType = Card;
    SourceTable = "NPR Digital Notification Setup";
    InsertAllowed = false;
    DeleteAllowed = false;
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;
    Extensible = false;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';

                field("Email Template Id Order"; Rec."Email Template Id Order")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the email template used for sending order confirmation notifications with manifest URL.';
                }
                field("Max Attempts"; Rec."Max Attempts")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the maximum number of attempts to send a failed notification before giving up. Set to 0 for unlimited attempts.';
                }
                field("Exclude Vouchers From Manifest"; Rec."Exclude Vouchers From Manifest")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether voucher assets should be excluded from the digital notification manifest.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies whether digital notification sending is enabled.';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action(DigitalNotificationEntries)
            {
                ApplicationArea = NPRRetail;
                Caption = 'Digital Notification Entries';
                ToolTip = 'View all digital notification entries and their processing status.';
                Image = EntriesList;
                RunObject = page "NPR Digital Notif. Entries";
            }
        }
        area(processing)
        {
            group(JobQueue)
            {
                Caption = 'Job Queue Management';

                action(SetJobQueueEntry)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Create Job Queue Entry for Digital Notification';
                    ToolTip = 'Manually create and start the recurring job queue entry for processing digital notifications. Normally this is managed automatically when enabling the feature.';
                    Image = ResetStatus;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
                        JobQueueCreatedMsg: Label 'Digital Notification job queue entry has been created and started successfully.';
                    begin
                        DigitalNotificationSend.SetJobQueueEntry(true);
                        Message(JobQueueCreatedMsg);
                    end;
                }

                action(RemoveJobQueueEntry)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Remove Job Queue Entry for Digital Notification';
                    ToolTip = 'Manually remove all job queue entries for digital notification processing. Normally this is managed automatically when disabling the feature.';
                    Image = ReopenCancelled;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedOnly = true;

                    trigger OnAction()
                    var
                        DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
                        JobQueueRemovedMsg: Label 'Digital Notification job queue entry has been removed successfully.';
                    begin
                        DigitalNotificationSend.SetJobQueueEntry(false);
                        Message(JobQueueRemovedMsg);
                    end;
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
    end;
}
#endif
