codeunit 6248726 "NPR New Voucher Reservation" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature();
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Voucher Reservation");
        Feature.Insert();
    end;

    procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);

        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean);
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;

        Feature.Enabled := NewEnabled;
        Feature.Modify();
    end;

    internal procedure GetFeatureId(): Text[50]
    var
        FeatureIdTok: Label 'NewVoucherReservation', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Voucher Reservation', MaxLength = 2024;
    begin
        exit(FeatureDescriptionLbl);
    end;

    internal procedure HandleOnUpgrade()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR New Voucher Reservation', 'MigrateFeatureFlag');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Voucher Reservation", 'MigrateFeatureFlag')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        MigrateFeatureFlag();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR New Voucher Reservation", 'MigrateFeatureFlag'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure MigrateFeatureFlag()
    var
        Feature: Record "NPR Feature";
        FeatureFlagsManagement: Codeunit "NPR Feature Flags Management";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit;
        if Feature.Enabled then
            exit;
        if not FeatureFlagsManagement.IsEnabled('newVoucherReservation') then
            exit;

        Feature.Enabled := true;
        Feature.Modify();
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        VoucherAmtReserveUpgrade: Codeunit "NPR VoucherAmtReserve Upgrade";
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Enabling this feature will change how voucher amounts are reserved and validated. A data migration will run to update existing voucher reservation entries. Are you sure you want to continue?';
        CannotRevertNewVoucherReservationFeatureErr: Label 'This feature cannot be disabled once it is enabled.';
        NewVoucherReservationLabel: Label 'NewVoucherReservation', Locked = true;
    begin
        if not (Rec.Id = NewVoucherReservationLabel) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertNewVoucherReservationFeatureErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;

        VoucherAmtReserveUpgrade.UpgradeReservationAmount();
    end;
}
