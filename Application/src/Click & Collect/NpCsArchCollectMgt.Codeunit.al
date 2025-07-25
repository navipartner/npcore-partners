﻿codeunit 6151209 "NPR NpCs Arch. Collect Mgt."
{
    Access = Internal;

    var
        Text003: Label 'Document Archived';

    //--- Archive ---
    internal procedure ArchiveCollectDocument(var NpCsDocument: Record "NPR NpCs Document"; DeleteSalesDocument: Boolean): Boolean
    var
        NpCsArchDocument: Record "NPR NpCs Arch. Document";
        NpCsArchDocumentLogEntry: Record "NPR NpCs Arch. Doc. Log Entry";
        PrevNpCsDocument: Record "NPR NpCs Document";
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        NpCsWorkflowModule: Record "NPR NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NPR NpCs Workflow Mgt.";
        Success: Boolean;
        Amount: Decimal;
        AmountInclVAT: Decimal;
    begin
        PrevNpCsDocument := NpCsDocument;
        GetOrderAmounts(NpCsDocument, Amount, AmountInclVAT);

        if DeleteSalesDocument then begin
            ClearLastError();
            Success := Codeunit.Run(Codeunit::"NPR NpCs Delete Related S.Doc.", NpCsDocument);

            NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Post Processing";
            NpCsWorkflowMgt.InsertLogEntry(NpCsDocument, NpCsWorkflowModule, Text003, not Success, GetLastErrorText);
            Commit();
            if not Success then
                exit(false);
        end;

        InsertArchCollectDocument(NpCsDocument, NpCsArchDocument, Amount, AmountInclVAT);

        NpCsDocumentLogEntry.SetRange("Document Entry No.", NpCsDocument."Entry No.");
        if NpCsDocumentLogEntry.FindSet() then
            repeat
                InsertArchCollectDocumentLogEntry(NpCsDocumentLogEntry, NpCsArchDocument, NpCsArchDocumentLogEntry);
                NpCsDocumentLogEntry.Delete();
            until NpCsDocumentLogEntry.Next() = 0;

        NpCsDocument.SuspendDeliveryStatusCheck(true);
        NpCsDocument.Delete(true);
        NpCsDocument := PrevNpCsDocument;
        exit(true);
    end;

    local procedure InsertArchCollectDocument(NpCsDocument: Record "NPR NpCs Document"; var NpCsArchDocument: Record "NPR NpCs Arch. Document"; Amount: Decimal; AmountInclVAT: Decimal)
    var
        ClickCollect: Codeunit "NPR Click & Collect";
    begin
        NpCsArchDocument.Init();
        NpCsArchDocument."Entry No." := 0;
        NpCsArchDocument.Type := NpCsDocument.Type;
        NpCsArchDocument."Document Type" := NpCsDocument."Document Type";
        NpCsArchDocument."Document No." := NpCsDocument."Document No.";
        NpCsArchDocument."Reference No." := NpCsDocument."Reference No.";
        NpCsArchDocument."Inserted at" := NpCsDocument."Inserted at";
        NpCsArchDocument."Archived at" := CurrentDateTime;
        NpCsArchDocument."Workflow Code" := NpCsDocument."Workflow Code";
        NpCsArchDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step";
        NpCsArchDocument."From Document Type" := NpCsDocument."From Document Type";
        NpCsArchDocument."From Document No." := NpCsDocument."From Document No.";
        NpCsArchDocument."From Store Code" := NpCsDocument."From Store Code";
        if NpCsDocument."Callback Data".HasValue() then
            NpCsDocument.CalcFields("Callback Data");
        NpCsArchDocument."Callback Data" := NpCsDocument."Callback Data";
        NpCsArchDocument."To Document Type" := NpCsDocument."To Document Type";
        NpCsArchDocument."To Document No." := NpCsDocument."To Document No.";
        NpCsArchDocument."To Store Code" := NpCsDocument."To Store Code";
        NpCsArchDocument."Opening Hour Set" := NpCsDocument."Opening Hour Set";
        NpCsArchDocument."Processing Expiry Duration" := NpCsDocument."Processing Expiry Duration";
        NpCsArchDocument."Processing Status" := NpCsDocument."Processing Status";
        NpCsArchDocument."Processing updated at" := NpCsDocument."Processing updated at";
        NpCsArchDocument."Processing updated by" := NpCsDocument."Processing updated by";
        NpCsArchDocument."Processing expires at" := NpCsDocument."Processing expires at";
        NpCsArchDocument."Customer No." := NpCsDocument."Customer No.";
        NpCsArchDocument."Customer E-mail" := NpCsDocument."Customer E-mail";
        NpCsArchDocument."Customer Phone No." := NpCsDocument."Customer Phone No.";
        NpCsArchDocument."Send Notification from Store" := NpCsDocument."Send Notification from Store";
        NpCsArchDocument."Notify Customer via E-mail" := NpCsDocument."Notify Customer via E-mail";
        NpCsArchDocument."E-mail Template (Pending)" := NpCsDocument."E-mail Template (Pending)";
        NpCsArchDocument."E-mail Template (Confirmed)" := NpCsDocument."E-mail Template (Confirmed)";
        NpCsArchDocument."E-mail Template (Rejected)" := NpCsDocument."E-mail Template (Rejected)";
        NpCsArchDocument."E-mail Template (Expired)" := NpCsDocument."E-mail Template (Expired)";
        NpCsArchDocument."Notify Customer via Sms" := NpCsDocument."Notify Customer via Sms";
        NpCsArchDocument."Sms Template (Pending)" := NpCsDocument."Sms Template (Pending)";
        NpCsArchDocument."Sms Template (Confirmed)" := NpCsDocument."Sms Template (Confirmed)";
        NpCsArchDocument."Sms Template (Rejected)" := NpCsDocument."Sms Template (Rejected)";
        NpCsArchDocument."Sms Template (Expired)" := NpCsDocument."Sms Template (Expired)";
        NpCsArchDocument."Delivery Expiry Duration" := NpCsDocument."Delivery Expiry Days (Qty.)";
        NpCsArchDocument."Delivery Status" := NpCsDocument."Delivery Status";
        NpCsArchDocument."Delivery updated at" := NpCsDocument."Delivery updated at";
        NpCsArchDocument."Delivery updated by" := NpCsDocument."Delivery updated by";
        NpCsArchDocument."Delivery expires at" := NpCsDocument."Delivery expires at";
        NpCsArchDocument."Store Stock" := NpCsDocument."Store Stock";
        NpCsArchDocument."Prepaid Amount" := NpCsDocument."Prepaid Amount";
        NpCsArchDocument.Amount := Amount;
        NpCsArchDocument."Amount Including VAT" := AmountInclVAT;
        NpCsArchDocument."Prepayment Account No." := NpCsDocument."Prepayment Account No.";
        NpCsArchDocument."Delivery Document Type" := NpCsDocument."Delivery Document Type";
        NpCsArchDocument."Delivery Document No." := NpCsDocument."Delivery Document No.";
        NpCsArchDocument."Archive on Delivery" := NpCsDocument."Archive on Delivery";
        NpCsArchDocument."Location Code" := NpCsDocument."Location Code";
        NpCsArchDocument."Sell-to Customer Name" := NpCsDocument."Sell-to Customer Name";
        NpCsArchDocument."Post on" := NpCsDocument."Post on";
        NpCsArchDocument."Bill via" := NpCsDocument."Bill via";
        NpCsArchDocument."Processing Print Template" := NpCsDocument."Processing Print Template";
        NpCsArchDocument."Delivery Print Template (POS)" := NpCsDocument."Delivery Print Template (POS)";
        NpCsArchDocument."Delivery Print Template (S.)" := NpCsDocument."Delivery Print Template (S.)";
        NpCsArchDocument."Salesperson Code" := NpCsDocument."Salesperson Code";
        ClickCollect.InsertArchCollectDocumentOnBeforeInsert(NpCsDocument, NpCsArchDocument);
        NpCsArchDocument.Insert(true);
    end;

    local procedure InsertArchCollectDocumentLogEntry(NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry"; NpCsArchDocument: Record "NPR NpCs Arch. Document"; var NpCsArchDocumentLogEntry: Record "NPR NpCs Arch. Doc. Log Entry")
    begin
        NpCsArchDocumentLogEntry.Init();
        NpCsArchDocumentLogEntry."Entry No." := 0;
        NpCsArchDocumentLogEntry."Log Date" := NpCsDocumentLogEntry."Log Date";
        NpCsArchDocumentLogEntry."Workflow Type" := NpCsDocumentLogEntry."Workflow Type";
        NpCsArchDocumentLogEntry."Workflow Module" := NpCsDocumentLogEntry."Workflow Module";
        NpCsArchDocumentLogEntry."Log Message" := NpCsDocumentLogEntry."Log Message";
        if NpCsDocumentLogEntry."Error Message".HasValue() then
            NpCsDocumentLogEntry.CalcFields("Error Message");
        NpCsArchDocumentLogEntry."Error Message" := NpCsDocumentLogEntry."Error Message";
        NpCsArchDocumentLogEntry."Error Entry" := NpCsDocumentLogEntry."Error Entry";
        NpCsArchDocumentLogEntry."User ID" := NpCsDocumentLogEntry."User ID";
        NpCsArchDocumentLogEntry."Store Code" := NpCsDocumentLogEntry."Store Code";
        NpCsArchDocumentLogEntry."Store Log Entry No." := NpCsDocumentLogEntry."Store Log Entry No.";
        NpCsArchDocumentLogEntry."Document Entry No." := NpCsArchDocument."Entry No.";
        NpCsArchDocumentLogEntry."Original Entry No." := NpCsDocumentLogEntry."Entry No.";
        NpCsArchDocumentLogEntry.Insert(true);
    end;

    local procedure GetOrderAmounts(NpCsDocument: Record "NPR NpCs Document"; var Amount: Decimal; var AmountInclVAT: Decimal)
    var
        SalesHeader: Record "Sales Header";
    begin
        if not SalesHeader.Get(NpCsDocument."Document Type", NpCsDocument."Document No.") then
            exit;

        SalesHeader.CalcFields(Amount, "Amount Including VAT");
        Amount := SalesHeader.Amount;
        AmountInclVAT := SalesHeader."Amount Including VAT";
    end;
}
