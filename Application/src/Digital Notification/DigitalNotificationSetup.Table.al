#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6248183 "NPR Digital Notification Setup"
{
    Access = Internal;
    Caption = 'Digital Notification Setup';
    DataClassification = CustomerContent;
    Extensible = false;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = SystemMetadata;
        }
        field(10; "Email Template Id Order"; Code[20])
        {
            Caption = 'Email Template Id Order';
            DataClassification = CustomerContent;
            TableRelation = "NPR NPEmailTemplate";

            trigger OnValidate()
            var
                CannotClearTemplateErr: Label 'Cannot clear Email Template Id Order while Digital Notification is enabled. Disable the feature first.';
            begin
                if (Rec."Email Template Id Order" = '') and (xRec."Email Template Id Order" <> '') then
                    if Rec.Enabled then
                        Error(CannotClearTemplateErr);
            end;
        }
        field(15; "Exclude Vouchers From Manifest"; Boolean)
        {
            Caption = 'Exclude Vouchers From Manifest';
            DataClassification = CustomerContent;
        }
        field(20; Enabled; Boolean)
        {
            Caption = 'Enabled';
            DataClassification = CustomerContent;

            trigger OnValidate()
            var
                DigitalNotificationSend: Codeunit "NPR Digital Notification Send";
                MissingTemplateErr: Label 'Cannot enable Digital Notification without configuring Email Template Id Order first.';
            begin
                if Rec.Enabled and (Rec."Email Template Id Order" = '') then
                    Error(MissingTemplateErr);

                if Rec.Enabled then
                    DigitalNotificationSend.SetJobQueueEntry(true)
                else
                    DigitalNotificationSend.SetJobQueueEntry(false);
            end;
        }
        field(30; "Max Attempts"; Integer)
        {
            Caption = 'Max Attempts';
            DataClassification = CustomerContent;
            InitValue = 3;
            MinValue = 0;
            ToolTip = 'Specifies the maximum number of attempts to send a failed notification before giving up. Set to 0 for unlimited attempts.';
        }
    }

    keys
    {
        key(PK; "Primary Key")
        {
            Clustered = true;
        }
    }
}
#endif
