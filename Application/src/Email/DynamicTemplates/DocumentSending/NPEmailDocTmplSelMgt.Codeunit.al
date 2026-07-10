codeunit 6248733 "NPR NPEmailDocTmplSelMgt"
{
    Access = Internal;

    /// <summary>
    /// Returns the NP Email template configured for the given
    /// document type, if one exists and has a template assigned.    
    /// </summary>
    procedure TryGetTemplateId(DocumentType: Enum "NPR NPEmailDocType"; var TemplateId: Code[20]): Boolean
    var
        DocTmplSelection: Record "NPR NPEmailDocTmplSelection";
    begin
        Clear(TemplateId);
        DocTmplSelection.SetRange("Document Type", DocumentType);
        if not DocTmplSelection.FindFirst() then
            exit(false);
        if DocTmplSelection."Email Template Id" = '' then
            exit(false);
        TemplateId := DocTmplSelection."Email Template Id";
        exit(true);
    end;

    /// <summary>
    /// Maps a source table id to the document type whose implementation reads from that table.
    /// The Undefined (0) value is skipped.
    /// </summary>
    procedure TryResolveDocType(SourceTableId: Integer; var DocumentType: Enum "NPR NPEmailDocType"): Boolean
    var
        IDocType: Interface "NPR INPEmailDocType";
        Ordinal: Integer;
    begin
        if SourceTableId = 0 then
            exit(false);
        foreach Ordinal in Enum::"NPR NPEmailDocType".Ordinals() do begin
            if Ordinal <> 0 then begin
                DocumentType := Enum::"NPR NPEmailDocType".FromInteger(Ordinal);
                IDocType := DocumentType;
                if IDocType.GetSourceTableId() = SourceTableId then
                    exit(true);
            end;
        end;
        exit(false);
    end;

    /// <summary>
    /// Resolves the NP Email document type for the posted document this Sales Header produces when posted and sent
    /// (invoice for Order/Invoice, credit memo for Return Order/Credit Memo). Returns false when the header maps to
    /// no NP Email document type - e.g. a document type NP Email does not (yet) support.
    /// </summary>
    procedure TryResolveDocTypeFromSalesHeader(SalesHeader: Record "Sales Header"; var DocumentType: Enum "NPR NPEmailDocType"): Boolean
    var
        PostedTableId: Integer;
    begin
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order,
            SalesHeader."Document Type"::Invoice:
                PostedTableId := Database::"Sales Invoice Header";
            SalesHeader."Document Type"::"Return Order",
            SalesHeader."Document Type"::"Credit Memo":
                PostedTableId := Database::"Sales Cr.Memo Header";
            else
                exit(false);
        end;
        exit(TryResolveDocType(PostedTableId, DocumentType));
    end;

    /// <summary>
    /// Returns true when NP Email is the only delivery channel on the profile for the given document type: the
    /// e-mail step it replaces is active (E-Mail is not No), a template is configured for that document type, and
    /// Printer, Disk and Electronic Document are all No. When NP Email is the sole channel the standard "Post and
    /// Send Confirmation" dialog (page 365) adds nothing and can be skipped; if any other channel is active - or NP
    /// Email is not configured for this document type - the dialog is kept so the operator can review and confirm.
    /// </summary>
    procedure IsNPEmailSoleDeliveryChannel(DocumentSendingProfile: Record "Document Sending Profile"; DocumentType: Enum "NPR NPEmailDocType"): Boolean
    var
        TemplateId: Code[20];
    begin
        if DocumentSendingProfile."E-Mail" = DocumentSendingProfile."E-Mail"::No then
            exit(false);
        if DocumentSendingProfile.Printer <> DocumentSendingProfile.Printer::No then
            exit(false);
        if DocumentSendingProfile.Disk <> DocumentSendingProfile.Disk::No then
            exit(false);
        if DocumentSendingProfile."Electronic Document" <> DocumentSendingProfile."Electronic Document"::No then
            exit(false);
        exit(TryGetTemplateId(DocumentType, TemplateId));
    end;
}
