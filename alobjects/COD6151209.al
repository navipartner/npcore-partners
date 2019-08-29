codeunit 6151209 "NpCs Arch. Collect Mgt."
{
    // #344264/MHA /20190717  CASE 344264 Object created - Archive Collect in Store Documents
    // #362443/MHA /20190719  CASE 344264 Added "Opening Hour Set"
    // #364557/MHA /20190821  CASE 364557 Added "Post on", "Sell-to Customer Name", "Location Code"


    trigger OnRun()
    begin
    end;

    var
        Text001: Label 'Processing Status updated to %1';
        Text002: Label 'Delivery Status updated to %1';
        Text003: Label 'Document Archived';
        Text004: Label 'Sales %1 %2 posted';
        Text005: Label 'Delivery printed: %1';
        Text006: Label 'Sales %1 %2 must be posted when %3 = %4';

    local procedure "--- Archive"()
    begin
    end;

    procedure ArchiveCollectDocument(var NpCsDocument: Record "NpCs Document"): Boolean
    var
        SalesHeader: Record "Sales Header";
        NpCsArchDocument: Record "NpCs Arch. Document";
        NpCsArchDocumentLogEntry: Record "NpCs Arch. Document Log Entry";
        PrevNpCsDocument: Record "NpCs Document";
        NpCsDocumentLogEntry: Record "NpCs Document Log Entry";
        NpCsWorkflowModule: Record "NpCs Workflow Module";
        NpCsWorkflowMgt: Codeunit "NpCs Workflow Mgt.";
        ErrorText: Text;
    begin
        PrevNpCsDocument := NpCsDocument;

        asserterror begin
          if SalesHeader.Get(NpCsDocument."Document Type",NpCsDocument."Document No.") then begin
            case NpCsDocument."Bill via" of
              NpCsDocument."Bill via"::POS:
                begin
                  SalesHeader.Delete(true);
                end;
              NpCsDocument."Bill via"::"Sales Document":
                begin
                  if NpCsDocument."Delivery Status" = NpCsDocument."Delivery Status"::Delivered then
                    Error(Text006,NpCsDocument."Document Type",NpCsDocument."Document No.",NpCsDocument.FieldCaption("Bill via"),NpCsDocument."Bill via");

                  SalesHeader.Delete(true);
                end;
            end;
          end;

          Commit;
          Error('');
        end;
        ErrorText := GetLastErrorText;

        NpCsWorkflowModule.Type := NpCsWorkflowModule.Type::"Post Processing";
        NpCsWorkflowMgt.InsertLogEntry(NpCsDocument,NpCsWorkflowModule,Text003,ErrorText <> '',ErrorText);
        Commit;
        if ErrorText <> '' then
          exit(false);

        InsertArchCollectDocument(NpCsDocument,NpCsArchDocument);

        NpCsDocumentLogEntry.SetRange("Document Entry No.",NpCsDocument."Entry No.");
        if NpCsDocumentLogEntry.FindSet then
          repeat
            InsertArchCollectDocumentLogEntry(NpCsDocumentLogEntry,NpCsArchDocument,NpCsArchDocumentLogEntry);
            NpCsDocumentLogEntry.Delete;
          until NpCsDocumentLogEntry.Next = 0;

        NpCsDocument.Delete(true);
        NpCsDocument := PrevNpCsDocument;
        exit(true);
    end;

    local procedure InsertArchCollectDocument(NpCsDocument: Record "NpCs Document";var NpCsArchDocument: Record "NpCs Arch. Document")
    begin
        NpCsArchDocument.Init;
        NpCsArchDocument."Entry No." := 0;
        NpCsArchDocument.Type := NpCsDocument.Type;
        NpCsArchDocument."Document Type" := NpCsDocument."Document Type";
        NpCsArchDocument."Document No." := NpCsDocument."Document No.";
        NpCsArchDocument."Reference No." := NpCsDocument."Reference No.";
        //-#362443 [362443]
        NpCsArchDocument."Inserted at" := NpCsDocument."Inserted at";
        NpCsArchDocument."Archived at" := CurrentDateTime;
        //+#362443 [362443]
        NpCsArchDocument."Workflow Code" := NpCsDocument."Workflow Code";
        NpCsArchDocument."Next Workflow Step" := NpCsDocument."Next Workflow Step";
        NpCsArchDocument."From Document Type" := NpCsDocument."From Document Type";
        NpCsArchDocument."From Document No." := NpCsDocument."From Document No.";
        NpCsArchDocument."From Store Code" := NpCsDocument."From Store Code";
        if NpCsDocument."Callback Data".HasValue then
          NpCsDocument.CalcFields("Callback Data");
        NpCsArchDocument."Callback Data" := NpCsDocument."Callback Data";
        NpCsArchDocument."To Document Type" := NpCsDocument."To Document Type";
        NpCsArchDocument."To Document No." := NpCsDocument."To Document No.";
        NpCsArchDocument."To Store Code" := NpCsDocument."To Store Code";
        //-#362443 [362443]
        NpCsArchDocument."Opening Hour Set" := NpCsDocument."Opening Hour Set";
        //+#362443 [362443]
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
        NpCsArchDocument."Prepayment Account No." := NpCsDocument."Prepayment Account No.";
        NpCsArchDocument."Delivery Document Type" := NpCsDocument."Delivery Document Type";
        NpCsArchDocument."Delivery Document No." := NpCsDocument."Delivery Document No.";
        NpCsArchDocument."Archive on Delivery" := NpCsDocument."Archive on Delivery";
        NpCsArchDocument."Location Code" := NpCsDocument."Location Code";
        //-#364557 [364557]
        NpCsArchDocument."Sell-to Customer Name" := NpCsDocument."Sell-to Customer Name";
        NpCsArchDocument."Post on" := NpCsDocument."Post on";
        //+#364557 [364557]
        NpCsArchDocument."Bill via" := NpCsDocument."Bill via";
        //-#364557 [364557]
        NpCsArchDocument."Processing Print Template" := NpCsDocument."Processing Print Template";
        //+#364557 [364557]
        NpCsArchDocument."Delivery Print Template (POS)" := NpCsDocument."Delivery Print Template (POS)";
        NpCsArchDocument."Delivery Print Template (S.)" := NpCsDocument."Delivery Print Template (S.)";
        NpCsArchDocument."Salesperson Code" := NpCsDocument."Salesperson Code";
        NpCsArchDocument.Insert(true);
    end;

    local procedure InsertArchCollectDocumentLogEntry(NpCsDocumentLogEntry: Record "NpCs Document Log Entry";NpCsArchDocument: Record "NpCs Arch. Document";var NpCsArchDocumentLogEntry: Record "NpCs Arch. Document Log Entry")
    begin
        NpCsArchDocumentLogEntry.Init;
        NpCsArchDocumentLogEntry."Entry No." := 0;
        NpCsArchDocumentLogEntry."Log Date" := NpCsDocumentLogEntry."Log Date";
        NpCsArchDocumentLogEntry."Workflow Type" := NpCsDocumentLogEntry."Workflow Type";
        NpCsArchDocumentLogEntry."Workflow Module" := NpCsDocumentLogEntry."Workflow Module";
        NpCsArchDocumentLogEntry."Log Message" := NpCsDocumentLogEntry."Log Message";
        if NpCsDocumentLogEntry."Error Message".HasValue then
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
}

