codeunit 6150729 "NPR POS Sales Print Mgt."
{
    Access = Internal;

    var
        PRINT_RECEIPT: Label 'Print Sales Receipt';

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
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

    [Obsolete('Remove after POS Scenario is removed', 'NPR32.0')]
    local procedure CurrCodeunitId(): Integer
    begin
        exit(CODEUNIT::"NPR POS Sales Print Mgt.");
    end;

    procedure PrintPOSEntrySalesReceipt(SalePOS: Record "NPR POS Sale")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSEntry: Record "NPR POS Entry";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
        RetailReportSelectionMgt: Codeunit "NPR Retail Report Select. Mgt.";
        RecRef: RecordRef;
    begin
        if FeatureFlagsManagement.IsEnabled('endSalePerformanceImprovements') then begin
            if not POSUnit.Get(SalePOS."Register No.") then
                exit;

            if (POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED) then
                exit;

            POSEntry.SetCurrentKey("Document No.");
            POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
            if not POSEntry.FindFirst() then
                exit;

            if POSAuditProfile.Get(POSUnit."POS Audit Profile") then
                if ((POSEntry."Entry Type" <> POSEntry."Entry Type"::"Cancelled Sale") and POSAuditProfile."Do Not Print Receipt on Sale") or
                   ((POSEntry."Entry Type" = POSEntry."Entry Type"::"Cancelled Sale") and not POSAuditProfile."Print Receipt On Sale Cancel")
                then
                    exit;
        end else begin
            POSEntry.SetRange("Document No.", SalePOS."Sales Ticket No.");
            if not POSEntry.FindFirst() then
                exit;

            if SkipReceiptPrint(POSEntry) then
                exit;
        end;

        RecRef.GetTable(POSEntry);
        RetailReportSelectionMgt.SetRegisterNo(POSEntry."POS Unit No.");
        RetailReportSelectionMgt.RunObjects(RecRef, "NPR Report Selection Type"::"Sales Receipt (POS Entry)".AsInteger());
    end;

    local procedure SkipReceiptPrint(POSEntry: Record "NPR POS Entry"): Boolean
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
    begin
        POSUnit.Get(POSEntry."POS Unit No.");

        if (POSUnit."POS Type" = POSUnit."POS Type"::UNATTENDED) then
            exit(true);

        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            exit(false);

        exit(
            ((POSEntry."Entry Type" <> POSEntry."Entry Type"::"Cancelled Sale") and POSAuditProfile."Do Not Print Receipt on Sale") or
            ((POSEntry."Entry Type" = POSEntry."Entry Type"::"Cancelled Sale") and not POSAuditProfile."Print Receipt On Sale Cancel"));
    end;
}

