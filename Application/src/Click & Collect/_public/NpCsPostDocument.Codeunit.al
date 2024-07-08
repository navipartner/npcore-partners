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
        SalesHeader: Record "Sales Header";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        if SkipPosting(NpCsDocument) then
            exit;

        SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.");

        SalesHeader.Ship := true;
        SalesHeader.Invoice := true;

        if not Codeunit.Run(Codeunit::"Sales-Post", SalesHeader) then
            LogPosting(NpCsDocument, SalesHeader, GetLastErrorText);

        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);
    end;

    local procedure LogPosting(NpCsDocument: Record "NPR NpCs Document"; SalesHeader: Record "Sales Header"; ErrorText: Text)
    var
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        LogMessage: Text;
        SalesDocPostedAsLbl: Label 'Sales %1 %2 posted to %3 %4';
        SalesDocPostFailedLbl: Label 'Sales %1 %2 posting error';
    begin
        if ErrorText = '' then
            LogMessage := StrSubstNo(SalesDocPostedAsLbl, SalesHeader."Document Type", SalesHeader."No.", NpCsDocument."Document Type", NpCsDocument."Document No.")
        else
            LogMessage := StrSubstNo(SalesDocPostFailedLbl, SalesHeader."Document Type", SalesHeader."No.");
        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Order Status";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, LogMessage, ErrorText <> '', ErrorText);
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

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterPostSalesDoc', '', false, true)]
    local procedure OnAfterPostSalesDoc(var SalesHeader: Record "Sales Header"; SalesInvHdrNo: Code[20]; SalesCrMemoHdrNo: Code[20])
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
    begin
        if (SalesInvHdrNo = '') and (SalesCrMemoHdrNo = '') then
            exit;
        NpCsDocument.SetRange(Type, NpCsDocument.Type::"Collect in Store");
        NpCsDocument.SetRange("Document Type", SalesHeader."Document Type");
        NpCsDocument.SetRange("Document No.", SalesHeader."No.");
        if not NpCsDocument.FindFirst() then
            exit;
        if NpCsDocument."Bill via" = NpCsDocument."Bill via"::POS then
            exit;
        case SalesHeader."Document Type" of
            SalesHeader."Document Type"::Order, SalesHeader."Document Type"::Invoice:
                begin
                    NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Invoice";
                    NpCsDocument."Document No." := SalesInvHdrNo;
                end;
            SalesHeader."Document Type"::"Return Order", SalesHeader."Document Type"::"Credit Memo":
                begin
                    NpCsDocument."Document Type" := NpCsDocument."Document Type"::"Posted Credit Memo";
                    NpCsDocument."Document No." := SalesCrMemoHdrNo;
                end;
        end;
        NpCsDocument.Modify(true);
        LogPosting(NpCsDocument, SalesHeader, '');
        NpCsWorkflowMgt.ScheduleRunWorkflowDelay(NpCsDocument, 10000);

    end;
}
