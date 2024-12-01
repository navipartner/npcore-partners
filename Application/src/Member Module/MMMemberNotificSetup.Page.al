page 6060142 "NPR MM Member Notific. Setup"
{
    Extensible = False;

    Caption = 'Member Notification Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Member Notific. Setup";
    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Days Before"; Rec."Days Before")
                {

                    ToolTip = 'Specifies the value of the Days Before field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Days Past"; Rec."Days Past")
                {

                    ToolTip = 'Specifies the value of the Days Past field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Cancel Overdue Notif. (Days)"; Rec."Cancel Overdue Notif. (Days)")
                {

                    ToolTip = 'Specifies the value of the Cancel Overdue Notif. (Days) field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Processing Method"; Rec."Processing Method")
                {

                    ToolTip = 'Specifies the value of the Processing Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Template Filter Value"; Rec."Template Filter Value")
                {

                    ToolTip = 'Specifies the value of the Template Filter Value field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Community Code"; Rec."Community Code")
                {

                    ToolTip = 'Specifies the value of the Community Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Membership Code"; Rec."Membership Code")
                {

                    ToolTip = 'Specifies the value of the Membership Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Next Notification Code"; Rec."Next Notification Code")
                {

                    ToolTip = 'Specifies the value of the Next Notification Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Target Member Role"; Rec."Target Member Role")
                {

                    ToolTip = 'Specifies the value of the Target Member Role field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Include NP Pass"; Rec."Include NP Pass")
                {

                    ToolTip = 'Specifies the value of the Include NP Pass field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("NP Pass Server Base URL"; Rec."NP Pass Server Base URL")
                {

                    ToolTip = 'Specifies the value of the NP Pass Server Base URL field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pass Notification Method"; Rec."Pass Notification Method")
                {

                    ToolTip = 'Specifies the value of the Pass Notification Method field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Passes API"; Rec."Passes API")
                {

                    ToolTip = 'Specifies the value of the Passes API field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("PUT Passes Template"; Rec."PUT Passes Template".HasValue())
                {

                    Caption = 'Have Template';
                    Editable = false;
                    ToolTip = 'Specifies the value of the Have Template field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pass Token"; Rec."Pass Token")
                {

                    ToolTip = 'Specifies the value of the Pass Token field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Pass Type Code"; Rec."Pass Type Code")
                {

                    ToolTip = 'Specifies the value of the Pass Type Code field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Generate Magento PW URL"; Rec."Generate Magento PW URL")
                {

                    ToolTip = 'Specifies the value of the Generate Magento PW URL field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                field("Fallback Magento PW URL"; Rec."Fallback Magento PW URL")
                {

                    ToolTip = 'Specifies the value of the Fallback Magento PW URL field';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }
        }
    }

    actions
    {

        area(navigation)
        {
            group(Setup)
            {
                Caption = 'Setup';

                action(EMailTemplates)
                {
                    Caption = 'E-Mail Templates';
                    ToolTip = 'Executes the E-Mail Templates action';
                    Image = InteractionTemplate;
                    Ellipsis = true;
                    RunObject = Page "NPR E-mail Templates";
                    RunPageView = WHERE("Table No." = CONST(6060139));
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action(SMSTemplate)
                {
                    Caption = 'SMS Template';
                    ToolTip = 'Executes the SMS Template action';
                    Image = InteractionTemplate;
                    Ellipsis = true;
                    RunObject = Page "NPR SMS Template List";
                    RunPageView = WHERE("Table No." = CONST(6060139));
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
                action(MemberComSetup)
                {
                    Caption = 'Member Communication Setup';
                    ToolTip = 'Navigate to Member Communication Setup Page';
                    Ellipsis = true;
                    Image = Interaction;
                    RunObject = Page "NPR MM Member Comm. Setup";
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                }
            }

            action(RenewNotificationsList)
            {
                Caption = 'View For Renewal Notifications';
                ToolTip = 'Navigate to the Notification List Page';
                Ellipsis = true;
                Image = Interaction;
                RunObject = Page "NPR MM Membership Notific.";
                RunPageLink = "Notification Trigger" = CONST(RENEWAL);
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }
            action(ViewNotifications)
            {
                Caption = 'View Notifications';
                ToolTip = 'Navigate to the Notification List Page';
                Ellipsis = true;
                Image = Interaction;
                RunObject = Page "NPR MM Membership Notific.";
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

        }
        area(processing)
        {

            action(ExportWalletTemplateFile)
            {
                Caption = 'Export Wallet Template File';
                ToolTip = 'Exports the default or current template used to send information to wallet.';
                Image = ExportAttachment;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    MemberNotification: Codeunit "NPR MM Member Notification";
                    PassData: Text;
                    FileName: Text;
                    TemplateOutStream: outstream;
                    TemplateInStream: InStream;
                    FileNameLbl: Label '%1 - %2.json', Locked = true;
                    DownloadLbl: Label 'Downloading template';
                begin
                    Rec.CalcFields("PUT Passes Template");
                    if (not Rec."PUT Passes Template".HasValue()) then begin
                        PassData := MemberNotification.GetDefaultWalletTemplate();
                        Rec."PUT Passes Template".CreateOutStream(TemplateOutStream);
                        TemplateOutStream.Write(PassData);
                        Rec.Modify();
                        Rec.CalcFields("PUT Passes Template");
                    end;

                    TempBlob.FromRecord(Rec, Rec.FieldNo("PUT Passes Template"));
                    if (not TempBlob.HasValue()) then
                        exit;

                    TempBlob.CreateInStream(TemplateInStream);
                    FileName := StrSubstNo(FileNameLbl, Rec.Code, Rec.Description);
                    DownloadFromStream(TemplateInStream, DownloadLbl, '', 'Template Files (*.json)|*.json', FileName)
                end;
            }

            action(ImportWalletTemplateFile)
            {
                Caption = 'Import Wallet Template File';
                ToolTip = 'Define information sent to wallet.';
                Image = ImportCodes;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;


                trigger OnAction()
                var
                    TempBlob: Codeunit "Temp Blob";
                    FileMgt: Codeunit "File Management";
                    FileName: Text;
                    RecRef: RecordRef;
                begin
                    FileName := FileMgt.BLOBImportWithFilter(TempBlob, IMPORT_FILE, '', 'Template Files (*.json)|*.json', 'json');

                    if (FileName = '') then
                        exit;

                    RecRef.GetTable(Rec);
                    TempBlob.ToRecordRef(RecRef, Rec.FieldNo("PUT Passes Template"));
                    RecRef.SetTable(Rec);

                    Rec.Modify(true);
                    Clear(TempBlob);

                end;
            }

            group(Notifications)
            {
                Caption = 'Notifications';
                action(SendNotifications)
                {
                    Caption = 'Send Pending Notification (Batch)';
                    ToolTip = 'This action sends all pending notification scheduled to be sent today and handled by "batch" method.';
                    Image = SendToMultiple;
                    ApplicationArea = NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        NotificationHandler: Codeunit "NPR MM Member Notification";
                    begin
                        if (Confirm('This action will send emails and text messages based on pending notification entries. Do you want to continue', false)) then
                            NotificationHandler.HandleBatchNotifications(Today);
                    end;
                }

                action(RefreshRenewNotification)
                {
                    Caption = 'Recreate All For Renewal Notifications';
                    Image = Recalculate;
                    ToolTip = 'Executes the Refresh Renew Notification action';
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        MemberNotification: Codeunit "NPR MM Member Notification";
                        MembershipSetup: Record "NPR MM Membership Setup";
                    begin

                        Rec.TestField(Type, Rec.Type::RENEWAL);
                        if (Rec."Membership Code" <> '') then begin
                            if (not Confirm(REFRESH_ALL_RENEW, true, Rec.FieldCaption("Membership Code"), Rec."Membership Code")) then
                                Error('');

                            MemberNotification.RefreshAllMembershipRenewalNotifications(Rec."Membership Code");

                        end else
                            if (Rec."Community Code" <> '') then begin
                                if (not Confirm(REFRESH_ALL_RENEW, true, Rec.FieldCaption("Community Code"), Rec."Community Code")) then
                                    Error('');

                                MembershipSetup.SetFilter("Community Code", '=%1', Rec."Community Code");
                                MembershipSetup.FindSet();
                                repeat
                                    MemberNotification.RefreshAllMembershipRenewalNotifications(MembershipSetup.Code);
                                until (MembershipSetup.Next() = 0);
                            end;

                    end;
                }
            }
            group(JobQueue)
            {
                Caption = 'Job Queue Management';
                action(SetJobQueueEntry)
                {
                    Caption = 'Create Job Queue Entry for Member Notification';
                    ToolTip = 'Create Job Queue Entry for processing notifications with processing method - batch';
                    Image = ResetStatus;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        MemberNotification: Codeunit "NPR MM Member Notification";
                        JobQueueCreatedMsg: Label 'Member Notifications job successfully created';
                    begin
                        MemberNotification.SetJobQueueEntry(true);
                        Message(JobQueueCreatedMsg);
                    end;
                }
                action(RemoveJobQueueEntry)
                {
                    Caption = 'Remove Job Queue Entry for Member Notification';
                    ToolTip = 'Remove all Job Queue Entries for processing notifications with processing method - batch from the list of jobs';
                    Image = ReopenCancelled;
                    ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;

                    trigger OnAction()
                    var
                        MemberNotification: Codeunit "NPR MM Member Notification";
                        JobQueueRemovedMsg: Label 'Member Notifications job successfully removed';
                    begin
                        MemberNotification.SetJobQueueEntry(false);
                        Message(JobQueueRemovedMsg);
                    end;
                }
            }
        }
    }

    var
        REFRESH_ALL_RENEW: Label 'Refresh all renew notifications for %1 %2.';
        IMPORT_FILE: Label 'Import File';

}

