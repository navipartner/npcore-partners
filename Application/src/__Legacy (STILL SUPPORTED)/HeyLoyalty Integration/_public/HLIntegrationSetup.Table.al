table 6059800 "NPR HL Integration Setup"
{
    ObsoleteState = Pending;
    ObsoleteTag = '2026-01-29';
    ObsoleteReason = 'This module is no longer being maintained';
    Access = Public;
    Caption = 'HeyLoyalty Integration Setup';
    DataClassification = CustomerContent;
    DrillDownPageID = "NPR HL Integration Setup";
    LookupPageID = "NPR HL Integration Setup";

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(10; "Enable Integration"; Boolean)
        {
            Caption = 'Enable Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Modify();
                HLIntegrationMgt.SetupTaskProcessingJobQueue();
            end;
        }
        field(15; "Instant Task Enqueue"; Boolean)
        {
            Caption = 'Instant Task Enqueue';
            DataClassification = SystemMetadata;
            ObsoleteState = Pending;
            ObsoleteTag = '2023-10-28';
            ObsoleteReason = 'Is not needed anymore with the new way of handling outstanding data log entries we have in BC Saas.';

            trigger OnValidate()
            var
                HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
            begin
                if "Instant Task Enqueue" then
                    if not HLIntegrationMgt.ConfirmInstantTaskEnqueue() then
                        Error('');
            end;
        }
        field(20; "HeyLoyalty Api Url"; Text[250])
        {
            Caption = 'HeyLoyalty Api Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            InitValue = 'https://api.heyloyalty.com/loyalty/v1';
        }
        field(21; "HeyLoyalty Api Key"; Text[100])
        {
            Caption = 'HeyLoyalty Api Key';
            DataClassification = CustomerContent;
        }
        field(22; "HeyLoyalty Api Secret"; Text[100])
        {
            Caption = 'HeyLoyalty Api Secret';
            DataClassification = CustomerContent;
        }
        field(30; "HeyLoyalty Member List Id"; Code[20])
        {
            Caption = 'HeyLoyalty Member List Id';
            DataClassification = CustomerContent;
        }
        field(40; "Member Integration"; Boolean)
        {
            Caption = 'Member Integration';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Modify();
                if "Member Integration" then begin
                    HLDataLogSubscrMgt.CreateDataLogSetup("NPR HL Integration Area"::Members);
                    HLIntegrationMgt.RegisterWebhookListeners();
                    HLIntegrationMgt.EnableWebhookRequestRetentionPolicy();
                end;
                HLIntegrationMgt.SetupTaskProcessingJobQueue();
            end;
        }
        field(50; "Membership HL Field ID"; Text[50])
        {
            Caption = 'Membership HL Field ID';
            DataClassification = CustomerContent;
        }
        field(51; "External Membership No. HLF ID"; Text[50])
        {
            Caption = 'External Membership No. HL Field ID';
            DataClassification = CustomerContent;
        }
        field(52; "Membership Issued On HLF ID"; Text[50])
        {
            Caption = 'Membership Issued On HL Field ID';
            DataClassification = CustomerContent;
        }
        field(53; "Membership Valid Until HLF ID"; Text[50])
        {
            Caption = 'Membership Valid Until HL Field ID';
            DataClassification = CustomerContent;
        }
        field(54; "Membership Item No. HLF ID"; Text[50])
        {
            Caption = 'Membership Item No. HL Field ID';
            DataClassification = CustomerContent;
        }
        field(60; "Read Member Data from Webhook"; Boolean)
        {
            Caption = 'Read Member Data from Webhook';
            DataClassification = CustomerContent;
        }
        field(70; "Unsubscribe if Blocked"; Boolean)
        {
            Caption = 'Unsubscribe if Blocked';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(75; "Require GDPR Approval"; Boolean)
        {
            Caption = 'Require GDPR Approval';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(80; "Require Newsletter Subscrip."; Boolean)
        {
            Caption = 'Require Newsletter Subscription';
            DataClassification = CustomerContent;
            InitValue = true;
        }
        field(85; "Required Contact Info"; Enum "NPR HL Required Contact Method")
        {
            Caption = 'Required Contact Info';
            DataClassification = CustomerContent;
        }
        field(100; "Heybooking Integration Enabled"; Boolean)
        {
            Caption = 'Heybooking Integration Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                Modify();
                if "Heybooking Integration Enabled" then
                    HLIntegrationMgt.SetupHeybookingTicketNotifProfile();
            end;
        }
        field(110; "Heycommerce/Booking DB Api Url"; Text[250])
        {
            Caption = 'Heycommerce/Booking DB Api Url';
            DataClassification = CustomerContent;
            ExtendedDatatype = URL;
            InitValue = 'https://tracking.heycommerce.dk/api';
        }
        field(120; "Heybooking Integration Id"; Code[20])
        {
            Caption = 'Heybooking Integration Id';
            DataClassification = CustomerContent;
        }
        field(130; "Send Heybooking Err. to E-Mail"; Text[80])
        {
            Caption = 'Send Heybooking Err. to E-Mail';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;

            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Send Heybooking Err. to E-Mail" <> '' then
                    MailManagement.CheckValidEmailAddresses("Send Heybooking Err. to E-Mail");
            end;
        }
        field(135; "Send Heybooking Fire Events"; Boolean)
        {
            Caption = 'Send Heybooking Fire Events';
            DataClassification = CustomerContent;
        }
        field(140; "Data Processing Handler ID"; Code[20])
        {
            Caption = 'Data Processing Handler ID';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                ConfirmDataProcessingHandlerChangeQst: Label 'You have changed %1. Note that the previous value may have already been used to set up associated task processor, ticket notification profile and data log subscriber records. These will not be updated automatically. You must update them manually or the functionality will not work properly.\\Are you sure you want to change the field value?', Comment = '%1 - field caption';
            begin
                if "Data Processing Handler ID" = '' then
                    SetDataProcessingHandlerIDToDefaultValue();
                if "Data Processing Handler ID" <> xRec."Data Processing Handler ID" then
                    if not Confirm(ConfirmDataProcessingHandlerChangeQst, false, FieldCaption("Data Processing Handler ID")) then
                        "Data Processing Handler ID" := xRec."Data Processing Handler ID";
            end;
        }
        field(200; "Enable MC Subscription"; Boolean)
        {
            Caption = 'Enable MultiChoice Subscription';
            DataClassification = CustomerContent;
        }
        field(201; "Member of MCF Code"; Code[20])
        {
            Caption = 'Member of MCF Code';
            DataClassification = CustomerContent;
        }
        field(202; "Notification List Opt. ID"; Integer)
        {
            Caption = 'Notification List Option ID';
            DataClassification = CustomerContent;
        }
        field(203; "Newsletter List Opt. ID"; Integer)
        {
            Caption = 'Newsletter List Option ID';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
    trigger OnInsert()
    begin
        SetDataProcessingHandlerIDToDefaultValue();
    end;

    procedure SetDataProcessingHandlerIDToDefaultValue()
    var
        HeyLoyaltyDataProcessingHandlerID: Label 'HEYLOY', Locked = true, MaxLength = 20;
    begin
        "Data Processing Handler ID" := HeyLoyaltyDataProcessingHandlerID;
    end;

    procedure GetRecordOnce(ReRead: Boolean)
    begin
        if RecordHasBeenRead and not ReRead then
            exit;
        if not Get() then begin
            Init();
            Insert(true);
        end;
        RecordHasBeenRead := true;
    end;

    var
        HLDataLogSubscrMgt: Codeunit "NPR HL DLog Subscr. Mgt. Impl.";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        RecordHasBeenRead: Boolean;
}