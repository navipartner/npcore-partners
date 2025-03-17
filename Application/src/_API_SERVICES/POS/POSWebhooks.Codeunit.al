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
#endif
}