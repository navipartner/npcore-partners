#if not (BC17 or BC18 or BC19 or BC20 or BC21)
table 6151118 "NPR NPEmailTemplate"
{
    Access = Internal;
    Caption = 'NP Email Template';

    fields
    {
        field(1; TemplateId; Code[20])
        {
            Caption = 'Template Id';
            DataClassification = CustomerContent;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(4; EmailScenario; Enum "Email Scenario")
        {
            Caption = 'Email Scenario';
            DataClassification = SystemMetadata;

            trigger OnValidate()
            var
                EmailScenarioHndlr: Codeunit "Email Scenario";
                EmailAccount: Record "Email Account";
                EmailAccountNotSupportedErr: Label 'The e-mail account assigned to the selected scenario, or the default e-mail account if scenario is not mapped to an account, must of type "%1". The current type is "%2"', Comment = '%1, %2 = email connector type';
            begin
                if (not EmailScenarioHndlr.GetEmailAccount(Rec.EmailScenario, EmailAccount)) then
                    if (not EmailScenarioHndlr.GetDefaultEmailAccount(EmailAccount)) then
                        exit;

                if (EmailAccount.Connector <> "Email Connector"::"NPR NP Email Web SMTP") then
                    Error(EmailAccountNotSupportedErr, "Email Connector"::"NPR NP Email Web SMTP", EmailACcount.Connector);
            end;
        }
        field(3; LayoutId; Text[50])
        {
            Caption = 'Layout Code';
            DataClassification = CustomerContent;
            TableRelation = "NPR SendGridDynamicTemplate".Id;
        }
        field(5; DataProvider; Enum "NPR DynTemplateDataProvider")
        {
            Caption = 'Data Provider';
            DataClassification = SystemMetadata;
        }
        field(7; DefaultRecipientCcAddress; Text[250])
        {
            Caption = 'Default Recipient CC Address';
            DataClassification = CustomerContent;
        }
        field(6; DefaultRecipientBccAddress; Text[250])
        {
            Caption = 'Default Recipient BCC Address';
            DataClassification = CustomerContent;
        }
    }
}
#endif