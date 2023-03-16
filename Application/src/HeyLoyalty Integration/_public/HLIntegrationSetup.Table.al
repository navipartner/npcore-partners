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
                if not "Member Integration" then
                    exit;
                HLDataLogSubscrMgt.CreateDataLogSetup("NPR HL Integration Area"::Members);
                HLIntegrationMgt.RegisterWebhookListeners();
            end;
        }
        field(50; "Membership HL Field ID"; Text[50])
        {
            Caption = 'Membership HL Field ID';
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

    trigger OnModify()
    var
        ReloginRequiredMsg: Label 'You have changed %1. You will have to relogin to the system for the changes to take effect.', Comment = '%1 - tablecaption';
    begin
        if Format(Rec) <> Format(xRec) then
            Message(ReloginRequiredMsg, Rec.TableCaption);
    end;

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
        HLDataLogSubscrMgt: Codeunit "NPR HL Data Log Subscr. Mgt.";
        HLIntegrationMgt: Codeunit "NPR HL Integration Mgt.";
        RecordHasBeenRead: Boolean;
}