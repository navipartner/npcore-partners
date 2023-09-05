table 6059800 "NPR HL Integration Setup"
{
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
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }

    procedure GetRecordOnce(ReRead: Boolean)
    begin
        if RecordHasBeenRead and not ReRead then
            exit;
        if not Get() then begin
            Init();
            exit;
        end;
        RecordHasBeenRead := true;
    end;

    var
        HLDataLogSubscrMgt: Codeunit "NPR HL DLog Subscr. Mgt. Impl.";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        RecordHasBeenRead: Boolean;
}