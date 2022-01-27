codeunit 6151210 "NPR NpCs Post Document"
{
    TableNo = "NPR NpCs Document";

    trigger OnRun()
    var
        NpCsDocument: Record "NPR NpCs Document";
    begin
        NpCsDocument := Rec;
        PostDocument(NpCsDocument);
        Rec := NpCsDocument;
    end;

    local procedure PostDocument(var NpCsDocument: Record "NPR NpCs Document")
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        ErrorText: Text;
        LogMessage: Text;
        Success: Boolean;
        SalesDocPostedAsLbl: Label 'Sales %1 %2 posted to %3 %4';
    begin
        if SkipPosting(NpCsDocument) then
            exit;

        SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.");

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;

        Success := Codeunit.Run(Codeunit::"Sales-Post", SalesHeader);
        if Success then begin
            case SalesHeader."Document Type" of
                SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                    NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Invoice";
                SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo":
                    NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Credit Memo";
            end;
            NpCsDocument."Document No." := SalesHeader."Last Posting No.";
            NpCsDocument.Modify(true);
        end else
            ErrorText := GetLastErrorText;

        LogMessage := StrSubstNo(SalesDocPostedAsLbl, SalesHeader."Document Type", SalesHeader."No.", NpCsDocument."Document Type", NpCsDocument."Document No.");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, not Success, ErrorText);
    end;

    local procedure SkipPosting(NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        if NpCsDocument."Bill via" <> NpCsDocument."Bill via"::"Sales Document" then
            exit(true);

        if not NpCsDocument."Store Stock" then
            exit(true);

        exit(
            NpCsDocument."Document Type" in
                [NpCsDocument."Document Type"::Quote,
                 NpCsDocument."Document Type"::"Blanket Order",
                 NpCsDocument."Document Type"::"Posted Invoice",
                 NpCsDocument."Document Type"::"Posted Credit Memo"]);
    end;
}
