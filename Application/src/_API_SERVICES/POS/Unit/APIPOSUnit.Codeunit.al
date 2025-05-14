#if not (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
codeunit 6248434 "NPR APIPOSUnit"
{
    Access = Internal;

    internal procedure GetPOSUnits(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSUnit: Record "NPR POS Unit";
        POSUnitFields: Dictionary of [Integer, Text];
    begin
        POSUnitFields.Add(POSUnit.FieldNo(SystemId), 'id');
        POSUnitFields.Add(POSUnit.FieldNo("No."), 'code');
        POSUnitFields.Add(POSUnit.FieldNo(Name), 'name');
        POSUnitFields.Add(POSUnit.FieldNo("POS Store Code"), 'posStoreCode');
        exit(Response.RespondOK(Request.GetData(Database::"NPR POS Unit", POSUnitFields)));
    end;
}
#endif