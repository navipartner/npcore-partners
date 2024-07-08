xmlport 6151196 "NPR NpCs Collect Documents"
{
    Caption = 'Collect Documents';
    DefaultNamespace = 'urn:microsoft-dynamics-nav/xmlports/collect_document';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    PreserveWhiteSpace = true;
    UseDefaultNamespace = true;

    schema
    {
        textelement(collect_documents)
        {
            tableelement(tempnpcsdocument; "NPR NpCs Document")
            {
                XmlName = 'collect_document';
                UseTemporary = true;
                fieldattribute(type; TempNpCsDocument.Type)
                {
                }
                fieldattribute(from_document_type; TempNpCsDocument."From Document Type")
                {
                }
                fieldattribute(from_document_no; TempNpCsDocument."From Document No.")
                {
                }
                fieldattribute(from_store_code; TempNpCsDocument."From Store Code")
                {
                }
                fieldelement(reference_no; TempNpCsDocument."Reference No.")
                {
                    MaxOccurs = Once;
                }
                fieldelement(document_type; TempNpCsDocument."Document Type")
                {
                    MinOccurs = Zero;
                }
                fieldelement(document_no; TempNpCsDocument."Document No.")
                {
                    MinOccurs = Zero;
                }
                fieldelement(processing_status; TempNpCsDocument."Processing Status")
                {
                    MinOccurs = Zero;
                }
                fieldelement(processing_updated_at; TempNpCsDocument."Processing updated at")
                {
                    MinOccurs = Zero;
                }
                fieldelement(processing_updated_by; TempNpCsDocument."Processing updated by")
                {
                    MinOccurs = Zero;
                }
                fieldelement(delivery_status; TempNpCsDocument."Delivery Status")
                {
                    MinOccurs = Zero;
                }
                fieldelement(delivery_updated_at; TempNpCsDocument."Delivery updated at")
                {
                    MinOccurs = Zero;
                }
                fieldelement(delivery_updated_by; TempNpCsDocument."Delivery updated by")
                {
                    MinOccurs = Zero;
                }
                textelement(log_entries)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tempnpcsdocumentlogentry; "NPR NpCs Document Log Entry")
                    {
                        LinkFields = "Document Entry No." = FIELD("Entry No.");
                        LinkTable = TempNpCsDocument;
                        MinOccurs = Zero;
                        XmlName = 'log_entry';
                        UseTemporary = true;
                        fieldattribute(entry_no; TempNpCsDocumentLogEntry."Store Log Entry No.")
                        {
                        }
                        fieldelement(log_date; TempNpCsDocumentLogEntry."Log Date")
                        {
                        }
                        fieldelement(workflow_type; TempNpCsDocumentLogEntry."Workflow Type")
                        {
                        }
                        fieldelement(workflow_module; TempNpCsDocumentLogEntry."Workflow Module")
                        {
                        }
                        fieldelement(log_message; TempNpCsDocumentLogEntry."Log Message")
                        {
                        }
                        textelement(error_message)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                error_message := TempNpCsDocumentLogEntry.GetErrorMessage();
                            end;
                        }
                        fieldelement(error_entry; TempNpCsDocumentLogEntry."Error Entry")
                        {
                        }
                        fieldelement(user_id; TempNpCsDocumentLogEntry."User ID")
                        {
                        }
                    }

                    trigger OnAfterAssignVariable()
                    begin
                        currXMLport.Break();
                    end;
                }

                trigger OnBeforeInsertRecord()
                var
                    NpCsDocument: Record "NPR NpCs Document";
                    NpCsArchDocument: Record "NPR NpCs Arch. Document";
                begin
                    if FindNpCsDocument(NpCsDocument) then begin
                        EntryNo += 1;
                        TempNpCsDocument."Entry No." := EntryNo;

                        exit;
                    end;

                    if FindNpCsArchDocument(NpCsArchDocument) then begin
                        EntryNo += 1;
                        TempNpCsDocument."Entry No." := EntryNo;

                        exit;
                    end;

                    currXMLport.Skip();
                end;
            }
        }
    }

    var
        EntryNo: Integer;
        LogEntryNo: Integer;

    local procedure FindNpCsDocument(var NpCsDocument: Record "NPR NpCs Document"): Boolean
    begin
        NpCsDocument.SetRange(Type, TempNpCsDocument.Type);
        case TempNpCsDocument.Type of
            TempNpCsDocument.Type::"Send to Store":
                begin
                    NpCsDocument.SetRange("Document Type", TempNpCsDocument."From Document Type");
                    NpCsDocument.SetRange("Document No.", TempNpCsDocument."From Document No.");
                end;
            TempNpCsDocument.Type::"Collect in Store":
                begin
                    NpCsDocument.SetRange("From Document Type", TempNpCsDocument."From Document Type");
                    NpCsDocument.SetRange("From Document No.", TempNpCsDocument."From Document No.");
                end;
        end;
        NpCsDocument.SetRange("From Store Code", TempNpCsDocument."From Store Code");
        exit(NpCsDocument.FindFirst());
    end;

    local procedure FindNpCsArchDocument(var NpCsArchDocument: Record "NPR NpCs Arch. Document"): Boolean
    begin
        NpCsArchDocument.SetRange(Type, TempNpCsDocument.Type);
        case TempNpCsDocument.Type of
            TempNpCsDocument.Type::"Send to Store":
                begin
                    NpCsArchDocument.SetRange("Document Type", TempNpCsDocument."From Document Type");
                    NpCsArchDocument.SetRange("Document No.", TempNpCsDocument."From Document No.");
                end;
            TempNpCsDocument.Type::"Collect in Store":
                begin
                    NpCsArchDocument.SetRange("From Document Type", TempNpCsDocument."From Document Type");
                    NpCsArchDocument.SetRange("From Document No.", TempNpCsDocument."From Document No.");
                end;
        end;
        NpCsArchDocument.SetRange("From Store Code", TempNpCsDocument."From Store Code");
        exit(NpCsArchDocument.FindLast());
    end;

    procedure GetSourceTable(var TempNpCsDocumentTo: Record "NPR NpCs Document" temporary)
    begin
        TempNpCsDocumentTo.Copy(TempNpCsDocument, true);
    end;

    local procedure ArchDoc2Doc(NpCsArchDocument: Record "NPR NpCs Arch. Document"; var NpCsDocument: Record "NPR NpCs Document")
    begin
        NpCsDocument.Type := NpCsArchDocument.Type;
        NpCsDocument."Document Type" := NpCsArchDocument."Document Type";
        NpCsDocument."Document No." := NpCsArchDocument."Document No.";
        NpCsDocument."Reference No." := NpCsArchDocument."Reference No.";
        NpCsDocument."Workflow Code" := NpCsArchDocument."Workflow Code";
        NpCsDocument."Next Workflow Step" := NpCsArchDocument."Next Workflow Step";
        NpCsDocument."From Document Type" := NpCsArchDocument."From Document Type";
        NpCsDocument."From Document No." := NpCsArchDocument."From Document No.";
        NpCsDocument."From Store Code" := NpCsArchDocument."From Store Code";
        NpCsDocument."Callback Data" := NpCsArchDocument."Callback Data";
        NpCsDocument."To Document Type" := NpCsArchDocument."To Document Type";
        NpCsDocument."To Document No." := NpCsArchDocument."To Document No.";
        NpCsDocument."To Store Code" := NpCsArchDocument."To Store Code";
        NpCsDocument."Processing Status" := NpCsArchDocument."Processing Status";
        NpCsDocument."Processing updated at" := NpCsArchDocument."Processing updated at";
        NpCsDocument."Processing updated by" := NpCsArchDocument."Processing updated by";
        NpCsDocument."Customer E-mail" := NpCsArchDocument."Customer E-mail";
        NpCsDocument."Customer Phone No." := NpCsArchDocument."Customer Phone No.";
        NpCsDocument."Send Notification from Store" := NpCsArchDocument."Send Notification from Store";
        NpCsDocument."Notify Customer via E-mail" := NpCsArchDocument."Notify Customer via E-mail";
        NpCsDocument."E-mail Template (Pending)" := NpCsArchDocument."E-mail Template (Pending)";
        NpCsDocument."E-mail Template (Confirmed)" := NpCsArchDocument."E-mail Template (Confirmed)";
        NpCsDocument."E-mail Template (Rejected)" := NpCsArchDocument."E-mail Template (Rejected)";
        NpCsDocument."E-mail Template (Expired)" := NpCsArchDocument."E-mail Template (Expired)";
        NpCsDocument."Notify Customer via Sms" := NpCsArchDocument."Notify Customer via Sms";
        NpCsDocument."Sms Template (Pending)" := NpCsArchDocument."Sms Template (Pending)";
        NpCsDocument."Sms Template (Confirmed)" := NpCsArchDocument."Sms Template (Confirmed)";
        NpCsDocument."Sms Template (Rejected)" := NpCsArchDocument."Sms Template (Rejected)";
        NpCsDocument."Sms Template (Expired)" := NpCsArchDocument."Sms Template (Expired)";
        NpCsDocument."Delivery Status" := NpCsArchDocument."Delivery Status";
        NpCsDocument."Delivery updated at" := NpCsArchDocument."Delivery updated at";
        NpCsDocument."Delivery updated by" := NpCsArchDocument."Delivery updated by";
        NpCsDocument."Prepaid Amount" := NpCsArchDocument."Prepaid Amount";
        NpCsDocument."Prepayment Account No." := NpCsArchDocument."Prepayment Account No.";
        NpCsDocument."Delivery Document Type" := NpCsArchDocument."Delivery Document Type";
        NpCsDocument."Delivery Document No." := NpCsArchDocument."Delivery Document No.";
        NpCsDocument."Archive on Delivery" := NpCsArchDocument."Archive on Delivery";
        NpCsDocument."Store Stock" := NpCsArchDocument."Store Stock";
        NpCsDocument."Location Code" := NpCsArchDocument."Location Code";
    end;

    local procedure ArchDocLog2DocLog(NpCsArchDocumentLogEntry: Record "NPR NpCs Arch. Doc. Log Entry"; var NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry")
    begin
        NpCsDocumentLogEntry."Entry No." := NpCsArchDocumentLogEntry."Entry No.";
        NpCsDocumentLogEntry."Log Date" := NpCsArchDocumentLogEntry."Log Date";
        NpCsDocumentLogEntry."Workflow Type" := NpCsArchDocumentLogEntry."Workflow Type";
        NpCsDocumentLogEntry."Workflow Module" := NpCsArchDocumentLogEntry."Workflow Module";
        NpCsDocumentLogEntry."Log Message" := NpCsArchDocumentLogEntry."Log Message";
        NpCsDocumentLogEntry."Error Message" := NpCsArchDocumentLogEntry."Error Message";
        NpCsDocumentLogEntry."Error Entry" := NpCsArchDocumentLogEntry."Error Entry";
        NpCsDocumentLogEntry."User ID" := NpCsArchDocumentLogEntry."User ID";
        NpCsDocumentLogEntry."Store Code" := NpCsArchDocumentLogEntry."Store Code";
        NpCsDocumentLogEntry."Store Log Entry No." := NpCsArchDocumentLogEntry."Store Log Entry No.";
        NpCsDocumentLogEntry."Document Entry No." := NpCsArchDocumentLogEntry."Document Entry No.";
    end;

    procedure RefreshSourceTable()
    begin
        Clear(TempNpCsDocumentLogEntry);
        TempNpCsDocumentLogEntry.DeleteAll();
        LogEntryNo := 0;

        Clear(TempNpCsDocument);
        if not TempNpCsDocument.FindSet() then
            exit;

        repeat
            RefreshDocument();
        until TempNpCsDocument.Next() = 0;
    end;

    local procedure RefreshDocument()
    var
        NpCsDocument: Record "NPR NpCs Document";
        NpCsDocumentLogEntry: Record "NPR NpCs Document Log Entry";
        NpCsArchDocument: Record "NPR NpCs Arch. Document";
        NpCsArchDocumentLogEntry: Record "NPR NpCs Arch. Doc. Log Entry";
        NpCsExpirationMgt: Codeunit "NPR NpCs Expiration Mgt.";
    begin
        if FindNpCsDocument(NpCsDocument) then begin
            NpCsExpirationMgt.UpdateExpirationStatus(NpCsDocument, true);

            TempNpCsDocument.TransferFields(NpCsDocument, false);
            TempNpCsDocument.Modify();

            NpCsDocumentLogEntry.SetRange("Document Entry No.", NpCsDocument."Entry No.");
            if NpCsDocumentLogEntry.FindSet() then
                repeat
                    if NpCsDocumentLogEntry."Error Message".HasValue() then
                        NpCsDocumentLogEntry.CalcFields("Error Message");

                    LogEntryNo += 1;
                    TempNpCsDocumentLogEntry.Init();
                    TempNpCsDocumentLogEntry := NpCsDocumentLogEntry;
                    TempNpCsDocumentLogEntry."Store Log Entry No." := NpCsDocumentLogEntry."Entry No.";
                    TempNpCsDocumentLogEntry."Entry No." := LogEntryNo;
                    TempNpCsDocumentLogEntry."Document Entry No." := TempNpCsDocument."Entry No.";
                    TempNpCsDocumentLogEntry.Insert();
                until NpCsDocumentLogEntry.Next() = 0;

            exit;
        end;

        if FindNpCsArchDocument(NpCsArchDocument) then begin
            EntryNo += 1;
            ArchDoc2Doc(NpCsArchDocument, TempNpCsDocument);
            TempNpCsDocument.Modify();

            NpCsArchDocumentLogEntry.SetRange("Document Entry No.", NpCsArchDocument."Entry No.");
            if NpCsArchDocumentLogEntry.FindSet() then
                repeat
                    if NpCsArchDocumentLogEntry."Error Message".HasValue() then
                        NpCsArchDocumentLogEntry.CalcFields("Error Message");

                    LogEntryNo += 1;
                    TempNpCsDocumentLogEntry.Init();
                    ArchDocLog2DocLog(NpCsArchDocumentLogEntry, TempNpCsDocumentLogEntry);
                    TempNpCsDocumentLogEntry."Store Log Entry No." := NpCsArchDocumentLogEntry."Original Entry No.";
                    TempNpCsDocumentLogEntry."Entry No." := LogEntryNo;
                    TempNpCsDocumentLogEntry."Document Entry No." := TempNpCsDocument."Entry No.";
                    TempNpCsDocumentLogEntry.Insert();
                until NpCsArchDocumentLogEntry.Next() = 0;

            exit;
        end;
    end;
}

