table 6014465 "NPR SMS Setup"
{
    Caption = 'SMS Setup';
    DataClassification = CustomerContent;
    LookupPageId = "NPR SMS Setup";
    DrillDownPageId = "NPR SMS Setup";
    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
            DataClassification = CustomerContent;
        }
        field(2; "SMS Provider"; enum "NPR SMS Setup Provider")
        {
            Caption = 'SMS Provider';
            DataClassification = CustomerContent;
        }
        field(3; "Discard Msg. Older Than [Hrs]"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Discard Msg. Older Than [Hrs]';
            MinValue = 0;
            InitValue = 24;
        }
        field(4; "Default Sender No."; Text[20])
        {
            Caption = 'Default Sender No.';
            DataClassification = CustomerContent;
        }
        field(5; "Domestic Phone Prefix"; Text[20])
        {
            Caption = 'Domestic Phone Prefix';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if (DelChr("Domestic Phone Prefix", '<=>', '+1234567890 ') <> '') then
                    FieldError("Domestic Phone Prefix", PhoneNoCannotContainLettersErr);
            end;
        }
        field(6; "SMS Endpoint"; Code[20])
        {
            Caption = 'SMS Endpoint';
            TableRelation = "NPR Nc Endpoint";
            DataClassification = CustomerContent;
        }
        field(7; "SMS-Address Postfix"; Text[30])
        {
            Caption = 'SMS-Address Postfix';
            DataClassification = CustomerContent;
        }
        field(8; "Local E-Mail Address"; Text[40])
        {
            Caption = 'Local E-Mail Address';
            DataClassification = CustomerContent;
            ExtendedDatatype = EMail;
            trigger OnValidate()
            var
                MailManagement: Codeunit "Mail Management";
            begin
                if "Local E-Mail Address" = '' then
                    exit;
                MailManagement.CheckValidEmailAddresses("Local E-Mail Address");
            end;
        }
        field(9; "Local SMTP Pickup Library"; Text[100])
        {
            Caption = 'Local SMTP ''Pickup'' Library';
            DataClassification = CustomerContent;
        }
        field(10; "Customer No."; Code[20])
        {
            Caption = 'Customer No.';
            DataClassification = CustomerContent;
        }
        field(11; "Auto Send Attempts"; Integer)
        {
            DataClassification = CustomerContent;
            Caption = 'Auto Send Attempts';
            MinValue = 0;
            InitValue = 3;
        }
        field(12; "Job Queue Category Code"; Code[10])
        {
            DataClassification = CustomerContent;
            Caption = 'Job Queue Category Code';
            TableRelation = "Job Queue Category";
            NotBlank = true;
            trigger OnValidate()
            var
                SMSMgt: Codeunit "NPR SMS Management";
            begin
                if Rec."Job Queue Category Code" <> xRec."Job Queue Category Code" then begin
                    SMSMgt.DeleteMessageJob(xRec."Job Queue Category Code");
                    if Rec."Job Queue Category Code" <> '' then
                        SMSMgt.CreateMessageJob(Rec."Job Queue Category Code");
                end;
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
    var
        PhoneNoCannotContainLettersErr: Label 'must not contain letters';
}
