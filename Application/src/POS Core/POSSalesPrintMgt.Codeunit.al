codeunit 6150729 "NPR POS Sales Print Mgt."
{
    Access = Internal;

    var
        PRINT_RECEIPT: Label 'Print Sales Receipt';

    [EventSubscriber(ObjectType::Table, Database::"NPR POS Sales Workflow Step", 'OnBeforeInsertEvent', '', true, true)]
    local procedure OnBeforeInsertWorkflowStep(var Rec: Record "NPR POS Sales Workflow Step"; RunTrigger: Boolean)
    begin
        if Rec."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        case Rec."Subscriber Function" of
            'PrintReceiptOnSale':
                begin
                    Rec.Description := PRINT_RECEIPT;
                    Rec."Sequence No." := 20;
                end;
        end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sales Print Mgt.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnFinishSale', '', true, true)]
    local procedure PrintReceiptOnSale(POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step"; SalePOS: Record "NPR POS Sale")
    begin
        if POSSalesWorkflowStep."Subscriber Codeunit ID" <> CurrCodeunitId() then
            exit;

        if POSSalesWorkflowStep."Subscriber Function" <> 'PrintReceiptOnSale' then
            exit;

        PrintPOSEntrySalesReceipt(SalePOS);
    end;

    procedure PrintPOSEntrySalesReceipt(SalePOS: Record "NPR POS Sale")
    var
        POSEntry: Record "NPR POS Entry";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
        ReportSelectionRetail: Record "NPR Report Selection Retail";
    begin
        POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
        if not POSEntry.FindFirst() then
            exit;

        if SkipReceiptPrint(POSEntry) then
            exit;

        RecRef.GetTable(POSEntry);
        RetailReportSelectionMgt.SetRegisterNo(POSEntry."POS Unit No.");
        RetailReportSelectionMgt.RunObjects(RecRef, ReportSelectionRetail."Report Type"::"Sales Receipt (POS Entry)");
    end;

    local procedure SkipReceiptPrint(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(POSEntry."POS Unit No.");
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            exit(false);

        exit((POSEntry."Entry Type" = POSEntry."Entry Type"::"Cancelled Sale") and not POSAuditProfile."Print Receipt On Sale Cancel");
    end;
}

