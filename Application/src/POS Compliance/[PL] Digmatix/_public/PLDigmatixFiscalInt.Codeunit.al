codeunit 6150901 "NPR PL Digmatix Fiscal Int."
{
    procedure IsPLFiscalActive(): Boolean
    var
        PLFiscalizationSetup: Record "NPR PL Digmatix Fisc. Setup";
    begin
        if not PLFiscalizationSetup.Get() then
            exit(false);

        exit(PLFiscalizationSetup."Enable PL Fiscal");
    end;

    procedure IsPLAuditEnabled(POSAuditProfileCode: Code[20]): Boolean
    var
        PLAuditMgt: Codeunit "NPR PL Digmatix Audit Mgt.";
    begin
        exit(PLAuditMgt.IsPLAuditEnabled(POSAuditProfileCode));
    end;

    procedure IsPLFiscalEnabledForPOSUnit(POSUnitNo: Code[10]): Boolean
    var
        POSUnit: Record "NPR POS Unit";
    begin
        if not IsPLFiscalActive() then
            exit(false);

        if not POSUnit.Get(POSUnitNo) then
            exit(false);

        exit(IsPLAuditEnabled(POSUnit."POS Audit Profile"));
    end;

    [IntegrationEvent(false, false)]
    internal procedure OnTestIsProfileSetAccordingToComplianceOnBeforeInitSale(POSUnit: Record "NPR POS Unit")
    begin
    end;
}
