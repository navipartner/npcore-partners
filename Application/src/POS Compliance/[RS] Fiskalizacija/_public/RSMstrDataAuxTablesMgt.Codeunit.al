codeunit 6185003 "NPR RS MstrData Aux Tables Mgt"
{
    SingleInstance = true;

    var
        RSAuxSalesHeader: Record "NPR RS Aux Sales Header";

    procedure GetRSAuxSalesHeaderPosUnit(SalesHeaderSystemID: Guid; var RSPOSUnitValue: Code[10]): Boolean
    var
        RSAuditMgt: Codeunit "NPR RS Audit Mgt.";
    begin
        if not RSAuditMgt.IsRSFiscalActive() then
            exit(false);

        InitializeRSAuxSalesHeader(SalesHeaderSystemID);

        RSPOSUnitValue := RSAuxSalesHeader."NPR RS POS Unit";
        exit(true);
    end;

    procedure SetRSAuxSalesHeaderPosUnit(SalesHeaderSystemID: Guid; NewRSPOSUnitValue: Code[10]; Validate: Boolean): Boolean
    begin
        InitializeRSAuxSalesHeader(SalesHeaderSystemID);

        if Validate then
            RSAuxSalesHeader.Validate("NPR RS POS Unit", NewRSPOSUnitValue)
        else
            RSAuxSalesHeader."NPR RS POS Unit" := NewRSPOSUnitValue;

        exit(RSAuxSalesHeader.Modify());
    end;

    local procedure InitializeRSAuxSalesHeader(SalesHeaderSystemID: Guid)
    begin
        if RSAuxSalesHeader.Get(SalesHeaderSystemID) then
            exit;

        RSAuxSalesHeader.Init();
        RSAuxSalesHeader."Sales Header SystemId" := SalesHeaderSystemID;
        RSAuxSalesHeader.Insert();
    end;
}
