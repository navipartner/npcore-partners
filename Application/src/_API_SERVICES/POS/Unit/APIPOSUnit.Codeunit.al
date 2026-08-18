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

    [CommitBehavior(CommitBehavior::Ignore)] // commit when API ends; keep open + period repair in one transaction
    internal procedure OpenPOSUnit(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        POSUnit: Record "NPR POS Unit";
        POSPeriodRegister: Record "NPR POS Period Register";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        UnitId: Guid;
        UnitIdText: Text;
        InactiveErr: Label 'POS Unit ''%1'' is inactive and cannot be opened.';
        EODErr: Label 'POS Unit ''%1'' is in End-of-Day and cannot be opened via API. Finish the attended End-of-Day procedure first.';
        NotUnattendedErr: Label 'POS Unit ''%1'' is not an UNATTENDED unit; only UNATTENDED units can be opened via API.';
    begin
        UnitIdText := Request.Paths().Get(3);
        if UnitIdText = '' then
            exit(Response.RespondBadRequest('Missing required path parameter: unitId'));
        if not Evaluate(UnitId, UnitIdText) then
            exit(Response.RespondBadRequest('Invalid unitId format'));

        POSUnit.ReadIsolation := IsolationLevel::UpdLock; // serialize concurrent opens of the same unit
        if not POSUnit.GetBySystemId(UnitId) then
            exit(Response.RespondResourceNotFound());

        if POSUnit."POS Type" <> POSUnit."POS Type"::UNATTENDED then
            exit(Response.RespondBadRequest(StrSubstNo(NotUnattendedErr, POSUnit."No.")));

        case POSUnit.Status of
            POSUnit.Status::INACTIVE:
                exit(Response.RespondBadRequest(StrSubstNo(InactiveErr, POSUnit."No.")));
            POSUnit.Status::EOD:
                exit(Response.RespondBadRequest(StrSubstNo(EODErr, POSUnit."No.")));
            POSUnit.Status::OPEN:
                begin
                    POSPeriodRegister.ReadIsolation := IsolationLevel::ReadCommitted;
                    if POSCreateEntry.GetPOSPeriodRegisterForPOSUnit(POSUnit."No.", POSPeriodRegister, true) then
                        exit(Response.RespondOK(POSUnitToJson(POSUnit))); // already open with an open period — idempotent no-op
                end;
        end;

        // Reached by CLOSED, or OPEN-without-open-period: open the unit and guarantee a fresh OPEN period register.
        OpenUnitAndEnsurePeriod(POSUnit);
        exit(Response.RespondOK(POSUnitToJson(POSUnit)));
    end;

    local procedure OpenUnitAndEnsurePeriod(var POSUnit: Record "NPR POS Unit")
    var
        ManagePOSUnit: Codeunit "NPR POS Manage POS Unit";
        POSCreateEntry: Codeunit "NPR POS Create Entry";
        OpeningEntryNo: Integer;
    begin
        ManagePOSUnit.CreateFirstTimeCheckpoint(POSUnit."No.");
        ManagePOSUnit.ClosePOSUnitOpenPeriods(POSUnit."POS Store Code", POSUnit."No.");
        ManagePOSUnit.OpenPOSUnit(POSUnit);
        // Blank salesperson: a headless open has no operator. On any POS Audit Profile with Audit Log Enabled this
        // fails hard in the FR audit subscriber, which is ungated by audit handler and requires a non-blank
        // salesperson. Deliberate until NF525's position on QR/self-service POS is established.
        OpeningEntryNo := POSCreateEntry.InsertUnitOpenEntry(POSUnit."No.", '');
        ManagePOSUnit.SetOpeningEntryNo(POSUnit."No.", OpeningEntryNo);
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
