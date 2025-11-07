#if not (BC17 or BC18 or BC19 or BC20 or BC21)
codeunit 6248373 "NPR NP Email"
{
    var
        NPEmailImpl: Codeunit "NPR NPEmailDynTemplateImpl";

    /// <summary>
    /// Try to send an email using the specified template. This procedure will incur a commit.
    /// </summary>
    /// <param name="TemplateId">Id of the template to be used</param>
    /// <param name="RecordVariant">Record to be used for the dynamic content</param>
    /// <param name="RecipientAddress">E-mail Address of the recipient</param>
    /// <returns>Boolean, whether or not the sending was successful</returns>
    procedure TrySendEmail(TemplateId: Code[20]; RecordVariant: Variant; RecipientAddress: Text[250]): Boolean
    begin
        exit(TrySendEmail(TemplateId, RecordVariant, RecipientAddress, ''));
    end;

    /// <summary>
    /// Send an email using the specified template
    /// </summary>
    /// <param name="TemplateId">Id of the template to be used</param>
    /// <param name="RecordVariant">Record to be used for the dynamic content</param>
    /// <param name="RecipientAddress">E-mail Address of the recipient</param>
    procedure SendEmail(TemplateId: Code[20]; RecordVariant: Variant; RecipientAddress: Text[250])
    begin
        SendEmail(TemplateId, RecordVariant, RecipientAddress, '');
    end;

    /// <summary>
    /// Try to send an email using the specified template. This procedure will incur a commit.
    /// </summary>
    /// <param name="TemplateId">Id of the template to be used</param>
    /// <param name="RecordVariant">Record to be used for the dynamic content</param>
    /// <param name="RecipientAddress">E-mail Address of the recipient</param>
    /// <param name="PreferredLanguage">Language code of the recipients preferred language</param>
    /// <returns>Boolean, whether or not the sending was successful</returns>
    procedure TrySendEmail(TemplateId: Code[20]; RecordVariant: Variant; RecipientAddress: Text[250]; PreferredLanguage: Code[10]): Boolean
    var
        NPEmailTrySend: Codeunit "NPR NP Email Try Send";
    begin
        ClearLastError();
        Commit();
        NPEmailTrySend.SetParameters(TemplateId, RecordVariant, RecipientAddress, PreferredLanguage);
        exit(NPEmailTrySend.Run());
    end;

    /// <summary>
    /// Send an email using the specified template
    /// </summary>
    /// <param name="TemplateId">Id of the template to be used</param>
    /// <param name="RecordVariant">Record to be used for the dynamic content</param>
    /// <param name="RecipientAddress">E-mail Address of the recipient</param>
    /// <param name="PreferredLanguage">Language code of the recipients preferred language</param>
    procedure SendEmail(TemplateId: Code[20]; RecordVariant: Variant; RecipientAddress: Text[250]; PreferredLanguage: Code[10])
    var
        RecRef: RecordRef;
    begin
        if (not RecordVariant.IsRecord()) then
            Error('The provided "RecordVariant" must be of type Record. This is a programming bug. Contact system vendor!');

        RecRef.GetTable(RecordVariant);
        NPEmailImpl.SendEmail(TemplateId, RecipientAddress, PreferredLanguage, RecRef);
    end;

    /// <summary>
    /// Get the list of template Ids for a given data provider
    /// </summary>
    /// <param name="DataProvider">Data provider enum value</param>
    /// <returns>Temporary record of type "NPR NPEmailTemplateBuffer" containing the template Ids and descriptions</returns>
    procedure GetTemplates(DataProvider: Enum "NPR DynTemplateDataProvider") TempEmailTemplateBuffer: Record "NPR NPEmailTemplateBuffer" temporary
    var
        EmailTemplate: Record "NPR NPEmailTemplate";
    begin
        EmailTemplate.SetFilter(DataProvider, '=%1', DataProvider);
        if (EmailTemplate.FindSet()) then
            repeat
                TempEmailTemplateBuffer.TransferFields(EmailTemplate, true);
                TempEmailTemplateBuffer.Insert();
            until EmailTemplate.Next() = 0;
    end;
}
#endif