codeunit 6151224 "NPR Spfy Task Send Bnd Impl" implements "NPR Spfy Task Send Boundary"
{
    Access = Internal;

    procedure Dispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var ErrorText: Text): Boolean
    var
        Sentry: Codeunit "NPR Sentry";
        Handled: Boolean;
        SendCodeunitId: Integer;
        UnmappedTaskKindErr: Label 'Shopify task list has no send codeunit mapped for table %1. This is a programming bug, not a user error. Please contact system vendor.', Locked = true;
    begin
        Clear(ErrorText);
        ClearLastError();
        // Ahead of the mapping, so a subscriber can also serve task kinds the mapping does not know at all.
        if not RunPTEDispatch(SpfyTaskWork, ErrorText, Handled) then
            exit(false);
        if Handled then
            exit(true);
        SendCodeunitId := MappedSendCodeunitId(SpfyTaskWork."Table No.");
        if SendCodeunitId = 0 then begin
            ErrorText := StrSubstNo(UnmappedTaskKindErr, SpfyTaskWork."Table No.");
            Sentry.InitScopeAndTransaction('Shopify task list unmapped task kind', 'bc.spfy.task_list.unmapped_kind');
            Sentry.AddError(ErrorText);
            Sentry.FinalizeScope();
            exit(false);
        end;
        if Codeunit.Run(SendCodeunitId, SpfyTaskWork) then
            exit(true);
        ErrorText := GetLastErrorText();
        exit(false);
    end;

    // The engine asks this before offering a kind to the batch-kind subscriber, so the answer has to come from the very
    // list the dispatch uses: a second literal list would drift and start offering mapped kinds to the extension.
    internal procedure IsBoundaryMappedKind(TableNo: Integer): Boolean
    begin
        exit(MappedSendCodeunitId(TableNo) <> 0);
    end;

    local procedure MappedSendCodeunitId(TableNo: Integer): Integer
    begin
        case TableNo of
            Database::Item,
            Database::"Item Variant",
            Database::"Inventory Buffer",
            Database::"NPR Spfy Tag Update Request",
            Database::"NPR Spfy Inventory Level",
            Database::"NPR Spfy Item Price",
            Database::"NPR Spfy Inv Item Location":
                exit(Codeunit::"NPR Spfy Task Send Items&Inv");
            Database::Customer:
                exit(Codeunit::"NPR Spfy Task Send Customers");
            Database::"NPR Spfy Entity Metafield":
                exit(Codeunit::"NPR Spfy Task Send Metafields");
            Database::"NPR NpRv Voucher",
            Database::"NPR NpRv Voucher Entry",
            Database::"NPR NpRv Arch. Voucher":
                exit(Codeunit::"NPR Spfy Task Send Voucher");
            Database::"Sales Shipment Header",
            Database::"Return Receipt Header":
                exit(Codeunit::"NPR Spfy Task Send Fulfillment");
            Database::"NPR NpCs Document":
                exit(Codeunit::"NPR Spfy Task Ready For Pickup");
            Database::"Sales Header":
                exit(Codeunit::"NPR Spfy Task Close Order");
            Database::"Sales Invoice Header",
            Database::"NPR Magento Payment Line":
                exit(Codeunit::"NPR Spfy Task Capture Payment");
            Database::"NPR POS Entry":
                exit(Codeunit::"NPR Spfy Task Send POS Entry");
        end;
    end;

    // A subscriber error is returned as a plain failed dispatch and never falls through to the standard sibling:
    // the subscriber may already have sent, so falling through would send the same update twice.
    local procedure RunPTEDispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var ErrorText: Text; var Handled: Boolean): Boolean
    var
        TempDispatchTask: Record "NPR Spfy Task" temporary;
        SpfyTaskRunContext: Codeunit "NPR Spfy Task Run Context";
        DispatchOk: Boolean;
        EntryNo: BigInteger;
        WorkView: Text;
    begin
        Handled := false;
        SpfyTaskRunContext.ClearPTEHandled();
        // Codeunit.Run hands the record over by reference, so a subscriber's filter or position changes would
        // otherwise leak into the standard sibling and into the completion path.
        WorkView := SpfyTaskWork.GetView(false);
        EntryNo := SpfyTaskWork."Entry No.";
        if SpfyTaskWork.IsTemporary() then begin
            CopyWorkListForDispatch(SpfyTaskWork, TempDispatchTask);
            DispatchOk := Codeunit.Run(Codeunit::"NPR Spfy Task PTE Dispatch", TempDispatchTask);
        end else
            DispatchOk := Codeunit.Run(Codeunit::"NPR Spfy Task PTE Dispatch", SpfyTaskWork);
        SpfyTaskWork.SetView(WorkView);
        if not SpfyTaskWork.IsTemporary() and (EntryNo <> 0) then
            if SpfyTaskWork.Get(EntryNo) then;
        if not DispatchOk then begin
            ErrorText := GetLastErrorText();
            exit(false);
        end;
        Handled := SpfyTaskRunContext.GetPTEHandled();
        exit(true);
    end;

    // Row by row into a table of its own: an assignment or Copy(..., true) would share the engine's backing table and
    // hand the subscriber the very work list the engine iterates.
    local procedure CopyWorkListForDispatch(var SpfyTaskWork: Record "NPR Spfy Task"; var TempDispatchTask: Record "NPR Spfy Task" temporary)
    var
        TempSourceTask: Record "NPR Spfy Task" temporary;
    begin
        // Shares the source table on purpose: reading through a second cursor leaves the caller's position untouched.
        TempSourceTask.Copy(SpfyTaskWork, true);
        if not TempSourceTask.FindSet() then
            exit;
        repeat
            TempDispatchTask := TempSourceTask;
            TempDispatchTask.Insert(false);
        until TempSourceTask.Next() = 0;
    end;
}
