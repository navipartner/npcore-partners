#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248372 "NPR NPEmailDynTemplateImpl"
{
    Access = Internal;

    internal procedure SendEmail(TemplateId: Code[20]; RecipientAddress: Text[250]; PreferredLanguage: Code[10]; RecRef: RecordRef)
    var
        NPEmailTemplate: Record "NPR NPEmailTemplate";
        NPEmailTemplateLangMap: Record "NPR NPEmailTemplateLangMap";
        EmailData: JsonObject;
        EmailJson: JsonObject;
        EmailText: Text;
        DataProvider: Interface "NPR IDynamicTemplateDataProvider";
        LayoutId: Text[50];
        EmailItem: Record "Email Item";
        MailManagement: Codeunit "Mail Management";
    begin
        NPEmailTemplate.Get(TemplateId);
        LayoutId := NPEmailTemplate.LayoutId;

        DataProvider := NPEmailTemplate.DataProvider;
        EmailData := DataProvider.GetContent(RecRef);

        if (PreferredLanguage <> '') then
            if (NPEmailTemplateLangMap.Get(TemplateId, PreferredLanguage)) and (NPEmailTemplateLangMap.LayoutId <> '') then
                LayoutId := NPEmailTemplateLangMap.LayoutId;

        EmailJson.Add('npemail_dynamic_template_data', EmailData);
        EmailJson.Add('npemail_dynamic_template_id', LayoutId);
        EmailJson.WriteTo(EmailText);

        EmailItem.Initialize();
        EmailItem.Validate("Plaintext Formatted", true);
        EmailItem.Validate("Message Type", EmailItem."Message Type"::"Custom Message");
        EmailItem.Validate("Send to", RecipientAddress);
        EmailItem.Validate("Send CC", NPEmailTemplate.DefaultRecipientCcAddress);
        EmailItem.Validate("Send BCC", NPEmailTemplate.DefaultRecipientBccAddress);
        EmailItem.SetBodyText(EmailText);
        EmailItem.Insert();

        DataProvider.AddAttachments(EmailItem, RecRef);

        MailManagement.SetHideMailDialog(true);
        MailManagement.Send(EmailItem, NPEmailTemplate.EmailScenario);
    end;
}
#endif