interface "NPR INPEmailDocType"
{
    Access = Internal;

    /// <summary>
    /// The dynamic-template data provider expected for templates of this document type.
    /// Used to filter template lookups and to validate the configured template.
    /// </summary>
    procedure GetDataProvider(): Enum "NPR DynTemplateDataProvider"

    /// <summary>
    /// The id of the table the document of this type is read from (e.g. Sales Invoice Header).
    /// </summary>
    procedure GetSourceTableId(): Integer

    /// <summary>
    /// Sends the NP Email notification for the single document the record reference is positioned on,
    /// using the given template. Returns true when an e-mail was sent (so the caller can suppress the
    /// standard e-mail step for that document); returns false when there is no recipient or the send
    /// failed (genuine send failures are logged to Sentry).
    /// </summary>
    /// <param name="RecRef">A record reference positioned on a single document of this type.</param>
    /// <param name="TemplateId">The NP Email template to use.</param>
    procedure TrySendNPEmail(RecRef: RecordRef; TemplateId: Code[20]): Boolean
}
