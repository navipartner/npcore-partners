codeunit 6184621 "NPR POS Fiscal Perm. Check"
{
    Access = Internal;

    var
        _Requirements: Dictionary of [Integer, Boolean];

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR POS Sale", 'OnBeforeInitSale', '', false, false)]
    local procedure OnBeforeInitSale(SaleHeader: Record "NPR POS Sale"; FrontEnd: Codeunit "NPR POS Front End Management")
    var
        POSAuditProfile: Record "NPR POS Audit Profile";
        POSUnit: Record "NPR POS Unit";
        POSSession: Codeunit "NPR POS Session";
        POSSetup: Codeunit "NPR POS Setup";
    begin
        FrontEnd.GetSession(POSSession);
        POSSession.GetSetup(POSSetup);
        POSSetup.GetPOSUnit(POSUnit);
        if not POSAuditProfile.Get(POSUnit."POS Audit Profile") then
            exit;
        if POSAuditProfile."Audit Handler" = '' then
            exit;

        CheckSalePermissions(POSUnit."No.", POSAuditProfile."Audit Handler");
    end;

    local procedure CheckSalePermissions(POSUnitNo: Code[10]; AuditHandler: Code[20])
    var
        POSFiscalPermCheck: Codeunit "NPR POS Fiscal Perm. Check";
    begin
        // The fiscal steps run after the customer has paid, so stop the sale before it starts if any of them would fail on permissions
        OnAddSaleRequiredPermissions(AuditHandler, POSFiscalPermCheck);
        POSFiscalPermCheck.CheckRequirements(POSUnitNo);
    end;

    internal procedure AddRead(TableNo: Integer)
    begin
        if not _Requirements.ContainsKey(TableNo) then
            _Requirements.Add(TableNo, false);
    end;

    internal procedure AddWrite(TableNo: Integer)
    begin
        if _Requirements.ContainsKey(TableNo) then
            _Requirements.Set(TableNo, true)
        else
            _Requirements.Add(TableNo, true);
    end;

    internal procedure CheckRequirements(POSUnitNo: Code[10])
    var
        TypeHelper: Codeunit "Type Helper";
        RecRef: RecordRef;
        MissingPermissions: TextBuilder;
        TableNo: Integer;
        MissingPermissionsErr: Label 'You cannot start a sale on POS unit %1 because your user is missing permissions that the fiscalization needs to complete the sale. Ask your administrator to grant:%2', Comment = '%1 = POS Unit No., %2 = List of missing permissions, one per line';
        MissingReadLbl: Label 'Read permission on %1', Comment = '%1 = Table caption';
        MissingWriteLbl: Label 'Read, Insert, Modify and Delete permissions on %1', Comment = '%1 = Table caption';
    begin
        foreach TableNo in _Requirements.Keys() do begin
            RecRef.Open(TableNo);
            if _Requirements.Get(TableNo) then begin
                if not (RecRef.ReadPermission() and RecRef.WritePermission()) then
                    MissingPermissions.Append(TypeHelper.LFSeparator() + StrSubstNo(MissingWriteLbl, RecRef.Caption()));
            end else
                if not RecRef.ReadPermission() then
                    MissingPermissions.Append(TypeHelper.LFSeparator() + StrSubstNo(MissingReadLbl, RecRef.Caption()));
            RecRef.Close();
        end;

        if MissingPermissions.Length() > 0 then
            Error(MissingPermissionsErr, POSUnitNo, MissingPermissions.ToText());
    end;

    [InternalEvent(false)]
    local procedure OnAddSaleRequiredPermissions(AuditHandler: Code[20]; var POSFiscalPermCheck: Codeunit "NPR POS Fiscal Perm. Check")
    begin
    end;
}
