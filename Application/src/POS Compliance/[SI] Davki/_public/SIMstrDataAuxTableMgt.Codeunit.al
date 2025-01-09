codeunit 6248181 "NPR SI MstrData Aux Table Mgt"
{
    SingleInstance = true;

    var
        SIAuxSalesHeader: Record "NPR SI Aux Sales Header";

    procedure GetSIAuxSalesHeaderPosUnit(SalesHeaderSystemID: Guid; var SIPOSUnitValue: Code[10]): Boolean
    var
        SIAuditMgt: Codeunit "NPR SI Audit Mgt.";
    begin
        if not SIAuditMgt.IsSIFiscalActive() then
            exit(false);

        InitializeSIAuxSalesHeader(SalesHeaderSystemID);

        SIPOSUnitValue := SIAuxSalesHeader."NPR SI POS Unit";
        exit(true);
    end;

    procedure SetSIAuxSalesHeaderPosUnit(SalesHeaderSystemID: Guid; NewSIPOSUnitValue: Code[10]; Validate: Boolean): Boolean
    begin
        InitializeSIAuxSalesHeader(SalesHeaderSystemID);

        if Validate then
            SIAuxSalesHeader.Validate("NPR SI POS Unit", NewSIPOSUnitValue)
        else
            SIAuxSalesHeader."NPR SI POS Unit" := NewSIPOSUnitValue;

        exit(SIAuxSalesHeader.Modify());
    end;

    local procedure InitializeSIAuxSalesHeader(SalesHeaderSystemID: Guid)
    begin
        if SIAuxSalesHeader.Get(SalesHeaderSystemID) then
            exit;

        SIAuxSalesHeader.Init();
        SIAuxSalesHeader."Sales Header SystemId" := SalesHeaderSystemID;
        SIAuxSalesHeader.Insert();
    end;
}