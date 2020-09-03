codeunit 6150618 "NPR POS Entry Output Log Mgt."
{
    // NPR5.39/BR  /20180208  CASE 304165 Object Created
    // NPR5.40/MMV /20180319  CASE 304639 Changed subscriber and renamed object.
    // NPR5.41/MMV /20180425  CASE 312782 Fill method code
    // NPR5.48/MMV /20180607  CASE 318028 French certification


    trigger OnRun()
    begin
    end;

    var
        CAPTION_CODEUNIT: Label 'Codeunit';
        CAPTION_REPORT: Label 'Report';
        CAPTION_TEMPLATE: Label 'Print Template';

    local procedure CreatePOSEntryOutputLog(RecRef: RecordRef; ReportSelectionRetail: Record "NPR Report Selection Retail")
    var
        POSEntry: Record "NPR POS Entry";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        FldRef: FieldRef;
        POSAuditLogMgt: Codeunit "NPR POS Audit Log Mgt.";
        POSEntryOutputLog2: Record "NPR POS Entry Output Log";
        IsReprint: Boolean;
        POSAuditLog: Record "NPR POS Audit Log";
        POSSession: Codeunit "NPR POS Session";
        POSFrontEnd: Codeunit "NPR POS Front End Management";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        if RecRef.Number <> DATABASE::"NPR POS Entry" then
            exit;

        //-NPR5.48 [318028]
        // FldRef := RecRef.FIELD(1);
        // POSEntryOutputLog."Entry No." := 0;
        // POSEntryOutputLog."POS Entry No." := FldRef.VALUE;
        RecRef.SetTable(POSEntry);
        POSEntryOutputLog."Entry No." := 0;
        POSEntryOutputLog."POS Entry No." := POSEntry."Entry No.";
        //+NPR5.48 [318028]
        POSEntryOutputLog."Output Timestamp" := CurrentDateTime;
        case ReportSelectionRetail."Report Type" of
            ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)":
                POSEntryOutputLog."Output Type" := POSEntryOutputLog."Output Type"::SalesReceipt;
            ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)":
                POSEntryOutputLog."Output Type" := POSEntryOutputLog."Output Type"::LargeSalesReceipt;
            ReportSelectionRetail."Report Type"::"Balancing (POS Entry)":
                POSEntryOutputLog."Output Type" := POSEntryOutputLog."Output Type"::Balancing;
            ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)":
                POSEntryOutputLog."Output Type" := POSEntryOutputLog."Output Type"::SalesDocReceipt;
        end;

        //-NPR5.48 [318028]
        // CASE TRUE OF
        //  ReportSelectionRetail."Print Template"  <> '' :
        //    POSEntryOutputLog."Output Method Code" := STRSUBSTNO('%1: %2', CAPTION_TEMPLATE, ReportSelectionRetail."Print Template");
        //  ReportSelectionRetail."Report ID"  <> 0 :
        //    POSEntryOutputLog."Output Method Code" := STRSUBSTNO('%1: %2', CAPTION_REPORT, ReportSelectionRetail."Report ID");
        //  ReportSelectionRetail."Codeunit ID" <> 0 :
        //  POSEntryOutputLog."Output Method Code" := STRSUBSTNO('%1: %2', CAPTION_CODEUNIT, ReportSelectionRetail."Codeunit ID");
        // END;

        if POSSession.IsActiveSession(POSFrontEnd) then begin
            POSFrontEnd.GetSession(POSSession);
            POSSession.GetSetup(POSSetup);
            POSEntryOutputLog."Salesperson Code" := POSSetup.Salesperson;
        end;
        //+NPR5.48 [318028]
        POSEntryOutputLog."User ID" := UserId;
        POSEntryOutputLog."Output Method" := POSEntryOutputLog."Output Method"::Print;
        POSEntryOutputLog.Insert;

        //-NPR5.48 [318028]
        if POSEntryOutputLog."Output Type" in [POSEntryOutputLog."Output Type"::SalesReceipt, POSEntryOutputLog."Output Type"::LargeSalesReceipt] then begin
            POSEntryOutputLog2.SetRange("POS Entry No.", POSEntry."Entry No.");
            POSEntryOutputLog2.SetRange("Output Method", POSEntryOutputLog2."Output Method"::Print);
            POSEntryOutputLog2.SetFilter("Output Type", '=%1|=%2', POSEntryOutputLog2."Output Type"::SalesReceipt, POSEntryOutputLog2."Output Type"::LargeSalesReceipt);
            POSEntryOutputLog2.SetFilter("Entry No.", '<>%1', POSEntryOutputLog."Entry No.");
            IsReprint := not POSEntryOutputLog2.IsEmpty;
            if IsReprint then
                POSAuditLogMgt.CreateEntry(POSEntryOutputLog.RecordId, POSAuditLog."Action Type"::RECEIPT_COPY, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.")
            else
                POSAuditLogMgt.CreateEntry(POSEntryOutputLog.RecordId, POSAuditLog."Action Type"::RECEIPT_PRINT, POSEntry."Entry No.", POSEntry."Fiscal No.", POSEntry."POS Unit No.");
        end;
        //+NPR5.48 [318028]
    end;

    local procedure "---Subscribers"()
    begin
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014581, 'OnAfterRunReportSelectionType', '', false, false)]
    local procedure OnAfterRunReportSelectionTypeCreatePOSEntryOutputLog(ReportSelectionRetail: Record "NPR Report Selection Retail"; RecRef: RecordRef)
    begin
        if ReportSelectionRetail."Report Type" in [ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)",
                                                   ReportSelectionRetail."Report Type"::"Large Sales Receipt (POS Entry)",
                                                   ReportSelectionRetail."Report Type"::"Balancing (POS Entry)",
                                                   ReportSelectionRetail."Report Type"::"Sales Doc. Confirmation (POS Entry)"] then
            CreatePOSEntryOutputLog(RecRef, ReportSelectionRetail);
    end;
}

