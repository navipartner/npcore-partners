#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151034 "NPR NPEmailWebSMTPEmailAccount"
{
    Access = Internal;
    Caption = 'NP Email Email Account';
    DataClassification = CustomerContent;

    fields
    {
        field(1; AccountId; Guid)
        {
            Caption = 'Account Id';
            DataClassification = SystemMetadata;
        }
        field(3; FromName; Text[250])
        {
            Caption = 'From Name';
        }
        field(4; FromEmailAddress; Text[250])
        {
            Caption = 'From E-mail Address';
            ExtendedDatatype = EMail;
        }
        field(5; ReplyToName; Text[250])
        {
            Caption = 'Reply-to Name';
        }
        field(6; ReplyToEmailAddress; Text[250])
        {
            Caption = 'Reply-to E-mail Address';
            ExtendedDatatype = EMail;
        }
        field(2; NPEmailAccountId; Integer)
        {
            Caption = 'NP Email Account Id';
            TableRelation = "NPR NP Email Account".AccountId;
        }
        field(13; SenderIdentityVerified; Boolean)
        {
            Caption = 'Sender Identity Verified';
            FieldClass = FlowField;
            CalcFormula = exist("NPR SendGrid Sender Identity" where(FromEmailAddress = field(FromEmailAddress), Verified = const(true)));
        }
    }

    keys
    {
        key(PK; AccountId)
        {
            Clustered = true;
        }
    }

    internal procedure ToEmailAccount(var EmailAccount: Record "Email Account")
    begin
        EmailAccount."Account Id" := Rec.AccountId;
        EmailAccount.Connector := "Email Connector"::"NPR NP Email Web SMTP";
        EmailAccount."Email Address" := Rec.FromEmailAddress;
        EmailAccount.Name := Rec.FromName;
    end;

}
#endif