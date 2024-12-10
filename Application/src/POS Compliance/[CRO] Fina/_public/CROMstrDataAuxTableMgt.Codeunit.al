codeunit 6185089 "NPR CRO MstrData Aux Table Mgt"
{
    SingleInstance = true;

    var
        CROAuxSalesHeaderInitialized: Boolean;
        CROAuxSalesHeader: Record "NPR CRO Aux Sales Header";

    procedure GetCROAuxSalesHeaderPosUnit(SalesHeaderSystemID: Guid; var CROPOSUnitValue: Code[10]): Boolean
    var
        CROAuditMgt: Codeunit "NPR CRO Audit Mgt.";
    begin
        if not CROAuditMgt.IsCROFiscalActive() then
            exit(false);

        InitializeCROAuxSalesHeader(SalesHeaderSystemID);

        CROPOSUnitValue := CROAuxSalesHeader."NPR CRO POS Unit";
        exit(true);
    end;

    procedure SetCROAuxSalesHeaderPosUnit(SalesHeaderSystemID: Guid; NewCROPOSUnitValue: Code[10]; Validate: Boolean): Boolean
    begin
        InitializeCROAuxSalesHeader(SalesHeaderSystemID);

        if Validate then
            CROAuxSalesHeader.Validate("NPR CRO POS Unit", NewCROPOSUnitValue)
        else
            CROAuxSalesHeader."NPR CRO POS Unit" := NewCROPOSUnitValue;

        exit(CROAuxSalesHeader.Modify());
    end;

    local procedure InitializeCROAuxSalesHeader(SalesHeaderSystemID: Guid)
    begin
        if CROAuxSalesHeaderInitialized then
            exit;

        if CROAuxSalesHeader.Get(SalesHeaderSystemID) then begin
            CROAuxSalesHeaderInitialized := true;
            exit;
        end;

        CROAuxSalesHeader.Init();
        CROAuxSalesHeader."Sales Header SystemId" := SalesHeaderSystemID;
        CROAuxSalesHeader.Insert();
        CROAuxSalesHeaderInitialized := true;
    end;
}