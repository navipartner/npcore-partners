#if not (BC17 or BC18 or BC19 or BC20 or BC21)
page 6185027 "NPR NPEmailTemplateCard"
{
    Extensible = false;
    Caption = 'NP Email Template Card';
    PageType = Card;
    ApplicationArea = NPRNPEmailTempl;
    UsageCategory = None;
    SourceTable = "NPR NPEmailTemplate";

    layout
    {
        area(Content)
        {
            group(General)
            {
                Caption = 'General';

                field(TemplateId; Rec.TemplateId)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Template Id field.';
                    ShowMandatory = true;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(EmailScenario; Rec.EmailScenario)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the E-mail Scenario field.';
                }
            }
            group(DefaultRecipients)
            {
                Caption = 'Default Recipients';

                field(DefaultRecipientCcAddress; Rec.DefaultRecipientCcAddress)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Default Recipient CC Address field.';
                }
                field(DefaultRecipientBccAddress; Rec.DefaultRecipientBccAddress)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Default Recipient BCC Address field.';
                }
            }
            group(Layout)
            {
                Caption = 'Layout';

                field(LayoutId; Rec.LayoutId)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Layout Id field.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        DynamicTemplates: Page "NPR SendGridDynamicTemplates";
                        TempDynamicTemplates2: Record "NPR SendGridDynamicTemplate" temporary;
                    begin
                        DynamicTemplates.LookupMode := true;
                        if (TempDynamicTemplates.Get(Rec.LayoutId)) then;
                        DynamicTemplates.SetSourceTable(TempDynamicTemplates);
                        if (DynamicTemplates.RunModal() <> Action::LookupOK) then
                            exit;

                        DynamicTemplates.GetRecord(TempDynamicTemplates2);
                        Rec.LayoutId := TempDynamicTemplates2.Id;
                        _LayoutName := TempDynamicTemplates2.Name;
                    end;

                    trigger OnValidate()
                    begin
                        TempDynamicTemplates.Get(Rec.LayoutId);
                    end;
                }
                field(LayoutName; _LayoutName)
                {
                    Caption = 'Layout Name';
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Layout Name field.';
                    Editable = false;
                }
                field(DataProvider; Rec.DataProvider)
                {
                    ApplicationArea = NPRNPEmailTempl;
                    ToolTip = 'Specifies the value of the Data Provider field.';
                }
            }
            part(LanguageMap; "NPR NPEmailTemplateLangSubform")
            {
                Caption = 'Languages';
                ApplicationArea = NPRNPEmailTempl;
                SubPageLink = TemplateId = field(TemplateId);
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(GenerateExample)
            {
                ApplicationArea = NPRNPEmailTempl;
                Caption = 'Generate Data Example';
                ToolTip = 'Running this action will generate a data example that can be used when designing the template';
                Image = CalculatePlan;

                trigger OnAction()
                var
                    JObject: JsonObject;
                    ExampleText: Text;
                    DataProvider: Interface "NPR IDynamicTemplateDataProvider";
                begin
                    DataProvider := Rec.DataProvider;
                    JObject := DataProvider.GenerateContentExample();
                    JObject.WriteTo(ExampleText);
                    Message(ExampleText);
                end;
            }
        }
        area(Promoted)
        {
            actionref(Promoted_GenerateExample; GenerateExample) { }
        }
    }

    var
        TempDynamicTemplates: Record "NPR SendGridDynamicTemplate" temporary;
        _LayoutName: Text;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        if Rec.GetFilter(DataProvider) <> '' then
            if Evaluate(Rec.DataProvider, Rec.GetFilter(DataProvider)) then;
    end;

    trigger OnAfterGetCurrRecord()
    var
        APIClient: Codeunit "NPR SendGrid API Client";
        EmailAccount: Record "Email Account";
        EmailScenarioHndlr: Codeunit "Email Scenario";
        NPEmailAccount: Record "NPR NP Email Account";
        NPEmailWebSMTPAccount: Record "NPR NPEmailWebSMTPEmailAccount";
        AccountId: Integer;
        FailedToFetchNPEmailAccountIdErr: Label 'Failed to get NP Email Account ID. Was the setup completed?';
    begin
        Clear(_LayoutName);

        TempDynamicTemplates.Reset();
        TempDynamicTemplates.DeleteAll();

        if (EmailScenarioHndlr.GetEmailAccount(Rec.EmailScenario, EmailAccount) and (EmailAccount.Connector = "Email Connector"::"NPR NP Email Web SMTP")) then begin
            NPEmailWebSMTPAccount.Get(EmailAccount."Account Id");
            AccountId := NPEmailWebSMTPAccount.NPEmailAccountId;
        end;

        if (AccountId <= 0) then
            if (NPEmailAccount.FindFirst()) then
                AccountId := NPEmailAccount.AccountId;

        if (AccountId <= 0) then
            Error(FailedToFetchNPEmailAccountIdErr);

        if (not APIClient.TryGetDynamicTemplates(AccountId, TempDynamicTemplates)) then
            exit;

        CurrPage.LanguageMap.Page.SetDynamicTemplates(TempDynamicTemplates);

        if (TempDynamicTemplates.Get(Rec.LayoutId)) then
            _LayoutName := TempDynamicTemplates.Name;
    end;
}
#endif