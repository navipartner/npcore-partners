codeunit 6150717 "NPR POS Webhooks"
{
    Access = Internal;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    var
        _Webhook: Enum "NPR POS Webhook";
        _Id: Guid;

    trigger OnRun()
    var
        POSEntry: Record "NPR POS Entry";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
    begin
        case _Webhook of
            Enum::"NPR POS Webhook"::POSSaleCompleted:
                begin
                    POSEntry.GetBySystemId(_Id);
                    OnPOSSaleCompleted(POSEntry.SystemId, POSEntry."POS Unit No.", POSEntry."Fiscal No.", POSEntry."Document No.", POSEntry."Customer No.");
                end;
            Enum::"NPR POS Webhook"::POSUnitBalanced:
                begin
                    POSWorkshiftCheckpoint.GetBySystemId(_Id);
                    OnPOSUnitBalanced(POSWorkshiftCheckpoint.SystemId, POSWorkshiftCheckpoint."POS Unit No.");
                end;
            Enum::"NPR POS Webhook"::POSBinTransferred:
                begin
                    // The unit comes from the checkpoint, not the POS entry: the entry's "POS Unit No." is the
                    // operating unit (from the operator's sale), which differs from the unit owning the
                    // transferred bin when the action runs with SourceBinSelection::FixedParameter.
                    POSWorkshiftCheckpoint.GetBySystemId(_Id);
                    POSEntry.Get(POSWorkshiftCheckpoint."POS Entry No.");
                    if TransferredIn(POSWorkshiftCheckpoint."Entry No.") then begin
                        OnPOSBinTransferredIn(POSEntry.SystemId, POSWorkshiftCheckpoint.SystemId, POSWorkshiftCheckpoint."POS Unit No.", POSEntry."Document No.");
                        OnAfterPOSBinTransferredInWebhook(POSWorkshiftCheckpoint.SystemId, POSWorkshiftCheckpoint."POS Unit No.");
                    end else begin
                        OnPOSBinTransferredOut(POSEntry.SystemId, POSWorkshiftCheckpoint.SystemId, POSWorkshiftCheckpoint."POS Unit No.", POSEntry."Document No.");
                        OnAfterPOSBinTransferredOutWebhook(POSWorkshiftCheckpoint.SystemId, POSWorkshiftCheckpoint."POS Unit No.");
                    end;
                end;
        end;
    end;
#endif
    procedure InvokeEndOfSaleWebhook(SystemId: Guid)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
        _Id := SystemId;
        _Webhook := Enum::"NPR POS Webhook"::POSSaleCompleted;
        if not this.Run() then
            Message('Error invoking POS end of sale webhook: %1', GetLastErrorText());
#endif
    end;

    procedure InvokeUnitBalancedWebhook(SystemId: Guid)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
        _Id := SystemId;
        _Webhook := Enum::"NPR POS Webhook"::POSUnitBalanced;
        if not this.Run() then
            Message('Error invoking POS unit balanced webhook: %1', GetLastErrorText());
#endif
    end;

    procedure InvokeBinTransferWebhook(WorkshiftCheckpointSystemId: Guid)
    begin
#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
        _Id := WorkshiftCheckpointSystemId;
        _Webhook := Enum::"NPR POS Webhook"::POSBinTransferred;
        if not this.Run() then
            Message('Error invoking POS bin transfer webhook: %1', GetLastErrorText());
#endif
    end;

#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22 or BC23 or BC24)
    [ExternalBusinessEvent('pos_sale_completed', 'POS Sale Completed', 'Triggered when a POS sale ends and a POS entry is created', EventCategory::"NPR POS", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR POS Webhooks", 'X')]
    local procedure OnPOSSaleCompleted(saleId: Guid; posUnit: Code[10]; receiptNo: Code[20]; fiscalDocumentNo: Code[20]; customerNo: Code[20])
    begin
    end;

    [ExternalBusinessEvent('pos_unit_balanced', 'POS Unit Balanced', 'Triggered when a POS unit is balanced', EventCategory::"NPR POS", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR POS Webhooks", 'X')]
    local procedure OnPOSUnitBalanced(workshiftCheckpointId: Guid; posUnit: Code[10])
    begin
    end;

    [ExternalBusinessEvent('pos_bin_transferred_out', 'POS Bin Transferred Out', 'Triggered when cash is moved out of a POS unit bin: unit-to-unit transfer, bank deposit, or safe drop', EventCategory::"NPR POS", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR POS Webhooks", 'X')]
    local procedure OnPOSBinTransferredOut(posEntryId: Guid; workshiftCheckpointId: Guid; posUnit: Code[10]; documentNo: Code[20])
    begin
    end;

    [ExternalBusinessEvent('pos_bin_transferred_in', 'POS Bin Transferred In', 'Triggered when cash enters a POS unit bin from outside BC, i.e. cash received from the bank. The receiving leg of a unit-to-unit transfer does not raise this event, as the sending unit already reported that cash through POS Bin Transferred Out', EventCategory::"NPR POS", '1.0')]
    [RequiredPermissions(PermissionObjectType::Codeunit, Codeunit::"NPR POS Webhooks", 'X')]
    local procedure OnPOSBinTransferredIn(posEntryId: Guid; workshiftCheckpointId: Guid; posUnit: Code[10]; documentNo: Code[20])
    begin
    end;

    /// <summary>
    /// Raised alongside the external business events above, which AL cannot subscribe to, so that tests can
    /// observe how many times a transfer actually reported itself, and in which direction.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterPOSBinTransferredOutWebhook(workshiftCheckpointId: Guid; posUnit: Code[10])
    begin
    end;

    /// <summary>
    /// Test-observable counterpart of the inbound external business event. See
    /// <see cref="OnAfterPOSBinTransferredOutWebhook"/>.
    /// </summary>
    [IntegrationEvent(false, false)]
    internal procedure OnAfterPOSBinTransferredInWebhook(workshiftCheckpointId: Guid; posUnit: Code[10])
    begin
    end;

    /// <summary>
    /// The direction belongs to the transfer that was posted, so it is read back from the bin checkpoints
    /// the posting wrote rather than carried here in codeunit state. "Transfer In" is written for inbound
    /// legs only, and lines the payload never touched keep the field's default, so one line marked inbound
    /// is decisive for the whole transfer.
    /// </summary>
    local procedure TransferredIn(WorkshiftCheckpointEntryNo: Integer): Boolean
    var
        PmtBinCheckpoint: Record "NPR POS Payment Bin Checkp.";
    begin
        PmtBinCheckpoint.SetCurrentKey("Workshift Checkpoint Entry No.");
        PmtBinCheckpoint.SetRange("Workshift Checkpoint Entry No.", WorkshiftCheckpointEntryNo);
        // A posted transfer always has bin checkpoints - neither caller posts without them. Fail here if
        // that ever stops holding, instead of reporting the transfer as outbound because none were found.
        PmtBinCheckpoint.FindFirst();

        PmtBinCheckpoint.SetRange("Transfer In", true);
        exit(not PmtBinCheckpoint.IsEmpty());
    end;
#endif
}