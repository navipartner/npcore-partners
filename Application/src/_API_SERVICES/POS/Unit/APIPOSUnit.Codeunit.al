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

    internal procedure GetPOSUnit(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSUnit: Record "NPR POS Unit";
        UnitId: Guid;
    begin
        if not Evaluate(UnitId, Request.Paths().Get(3)) then
            exit(Response.RespondBadRequest('Invalid unitId format'));

        POSUnit.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSUnit.GetBySystemId(UnitId) then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(POSUnitToJson(POSUnit)));
    end;

    internal procedure GetCurrentPOSUnit(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSUnit: Record "NPR POS Unit";
        UserSetup: Record "User Setup";
    begin
        if not UserSetup.Get(UserId) then
            exit(Response.RespondBadRequest('No User Setup found for current user'));
        if UserSetup."NPR POS Unit No." = '' then
            exit(Response.RespondBadRequest('No POS Unit assigned to current user'));

        POSUnit.ReadIsolation := IsolationLevel::ReadCommitted;
        if not POSUnit.Get(UserSetup."NPR POS Unit No.") then
            exit(Response.RespondResourceNotFound());

        exit(Response.RespondOK(POSUnitToJson(POSUnit)));
    end;

    local procedure POSUnitToJson(POSUnit: Record "NPR POS Unit") Json: JsonObject
    var
        SSProfile: Record "NPR SS Profile";
        SelfserviceProfileJson: JsonObject;
    begin
        Json.Add('id', Format(POSUnit.SystemId, 0, 4).ToLower());
        Json.Add('code', POSUnit."No.");
        Json.Add('name', POSUnit.Name);
        Json.Add('posStoreCode', POSUnit."POS Store Code");

        if (POSUnit."POS Self Service Profile" <> '') and SSProfile.Get(POSUnit."POS Self Service Profile") then begin
            SelfserviceProfileJson.Add('qrCardPaymentMethod', SSProfile."QR Card Payment Method");
            SelfserviceProfileJson.Add('selfserviceCardPaymentMethod', SSProfile."Selfservice Card Payment Meth.");
            SelfserviceProfileJson.Add('kioskModeUnlockPin', SSProfile."Kiosk Mode Unlock PIN");
            Json.Add('selfserviceProfile', SelfserviceProfileJson);
        end;
    end;
}
#endif
