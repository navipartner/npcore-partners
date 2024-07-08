page 6151109 "NPR MM AzureMemberRegSetup"
{
    PageType = Card;
    UsageCategory = None;
    SourceTable = "NPR MM AzureMemberRegSetup";
    Caption = 'Azure Member Registration Setup';
    Extensible = false;

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(MemberRegistrationSetupCode; Rec.AzureRegistrationSetupCode)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Code field.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Enabled; Rec.Enabled)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enabled field.';
                }
            }

            group(AzureSetup)
            {
                Caption = 'Azure';

                field(AzureStorageAccountName; Rec.AzureStorageAccountName)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Azure Storage Account Name field.';
                    Editable = not Rec.Enabled;
                }
                field(QueueName; Rec.QueueName)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Partition Key field that identifies this instance. Should be formatted as {GUID}-{Company Alias} or similar.';
                    Editable = not Rec.Enabled;
                }
            }
            group(Outbound)
            {
                Caption = 'Outbound';

                field(MemberRegistrationUrl; Rec.MemberRegistrationUrl)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the URL user device will be directed to.';
                }
                field(TermsOfServiceUrl; Rec.TermsOfServiceUrl)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Terms of Service URL.';
                }
                field(EmailTemplate; Rec.EmailTemplate)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the E-Mail Template Code to be used with Azure member registration.';
                }
                field(SMSTemplate; Rec.SMSTemplate)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the SMS Template Code to be used with Azure member registration.';
                }
                field(AllowAnonymousWallet; Rec.AllowAnonymousWallet)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies if Wallet should be included in initial Welcome notification.';
                }
            }

            group(Processing)
            {
                Caption = 'Queue Processing';

                field(EnableDequeuing; Rec.EnableDequeuing)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Enable Dequeuing field.';
                }
                field(DequeueBatchSize; Rec.DequeueBatchSize)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Dequeue Batch Size field.';
                }
                field(DequeueUntilEmpty; Rec.DequeueUntilEmpty)
                {
                    ApplicationArea = NPRMembershipAdvanced;
                    ToolTip = 'Specifies the value of the Dequeue Until Empty field.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(setup)
            {
                Caption = 'Setup';
                action(CreateAzureQueue)
                {
                    Caption = 'Create Azure Queue';
                    ToolTip = 'Creates a queue with name as Queue Name in the specified Storage Account';
                    ApplicationArea = NPRMembershipAdvanced;
                    Image = AddAction;

                    trigger OnAction();
                    var
                        MemberAzureFunctions: Codeunit "NPR MM AzureMemberRegistration";
                        QueueCreated: Label 'Ok, queue %1 created in storage account %2.';
                    begin
                        Rec.TestField(AzureStorageAccountName);
                        Rec.TestField(QueueName);
                        if (not MemberAzureFunctions.CreateStorageAccountQueue(Rec.AzureStorageAccountName, Rec.QueueName)) then
                            Error(GetLastErrorText());

                        Message(QueueCreated, Rec.QueueName, Rec.AzureStorageAccountName);
                    end;
                }
                action(CreateJobQueue)
                {
                    Caption = 'Schedule Processing of Azure Queue';
                    ToolTip = 'Adds a new periodic job, responsible for fetching member updates from the Azure queue.';
                    Image = AddAction;
                    ApplicationArea = NPRMembershipAdvanced;
                    Ellipsis = true;

                    trigger OnAction()
                    var
                        JobQueueEntry: Record "Job Queue Entry";
                        MemberAzureFunctions: Codeunit "NPR MM AzureMemberRegistration";
                    begin
                        if MemberAzureFunctions.CreateAzureMemberUpdateJob(JobQueueEntry, false) then
                            Page.Run(Page::"Job Queue Entry Card", JobQueueEntry);
                    end;
                }
            }
            action(CheckAzureQueue)
            {
                Caption = 'Validate Azure Queue';
                ToolTip = 'Checks if a queue with same name as Queue Name exists in the specified Storage Account';
                ApplicationArea = NPRMembershipAdvanced;
                Image = TaskQualityMeasure;

                trigger OnAction();
                var
                    MemberAzureFunctions: Codeunit "NPR MM AzureMemberRegistration";
                    QueueFound: Label 'Ok, queue %1 found in storage account %2.';
                begin
                    Rec.TestField(AzureStorageAccountName);
                    Rec.TestField(QueueName);
                    if (not MemberAzureFunctions.CheckIfStorageAccountQueueExist(Rec.AzureStorageAccountName, Rec.QueueName)) then
                        Error(GetLastErrorText());

                    Message(QueueFound, Rec.QueueName, Rec.AzureStorageAccountName);
                end;
            }
            action(CheckAzureBlob)
            {
                Caption = 'Validate Azure Blob';
                ToolTip = 'Checks if image operations for this this Storage Account works.';
                ApplicationArea = NPRMembershipAdvanced;
                Image = TaskQualityMeasure;

                trigger OnAction();
                var
                    MemberAzureFunctions: Codeunit "NPR MM AzureMemberRegistration";
                    BlobOperations: Label 'Ok, tested put, get and delete operations for storage account %1.';
                begin
                    Rec.TestField(AzureStorageAccountName);
                    MemberAzureFunctions.TestBlobFunctions(Rec.AzureStorageAccountName);
                    Message(BlobOperations, Rec.AzureStorageAccountName);
                end;
            }
            action(ProcessAzureQueue)
            {
                Caption = 'Process Azure Queue';
                ToolTip = 'Process queue manually and import member updates';
                ApplicationArea = NPRMembershipAdvanced;

                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                Image = CreatePutAway;

                trigger OnAction();
                var
                    MemberAzureFunctions: Codeunit "NPR MM AzureMemberRegistration";
                    MembersUpdated: Label '%1 members updated, %2 invalid messages.';
                    ProcessCount, FailedCount : Integer;
                    TotalCount: Integer;
                begin
                    repeat
                        MemberAzureFunctions.ProcessMemberUpdateQueue(Rec.AzureRegistrationSetupCode, ProcessCount, FailedCount);
                        TotalCount += ProcessCount;
                    until ((ProcessCount = 0) or (not Rec.DequeueUntilEmpty));

                    Message(MembersUpdated, TotalCount, FailedCount);
                end;
            }
        }
        area(Navigation)
        {
            action(AzureLog)
            {
                Caption = 'View Import Log';
                ToolTip = 'View the Azure interaction log.';
                ApplicationArea = NPRMembershipAdvanced;
                Image = ImportLog;

                RunObject = page "NPR MM AzureRegistrationLog";
            }
        }

    }
}