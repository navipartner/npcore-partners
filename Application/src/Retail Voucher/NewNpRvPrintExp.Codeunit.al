codeunit 6151138 "NPR New NpRv Print Exp." implements "NPR Feature Management"
{
    Access = Internal;

    internal procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"New NpRv Print Experience");
        Feature.Insert();
    end;

    internal procedure IsFeatureEnabled(): Boolean
    var
        Feature: Record "NPR Feature";
    begin
        if not Feature.Get(GetFeatureId()) then
            exit(false);
        exit(Feature.Enabled);
    end;

    procedure SetFeatureEnabled(NewEnabled: Boolean)
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
        FeatureIdTok: Label 'NewNpRvPrintExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New NpRv Print Experience', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. All Gift and Credit Voucher Types will be permanently migrated from template printing to the static codeunit. Are you sure you want to continue?';
        CannotRevertErr: Label 'This feature cannot be disabled once it is enabled.';
        FeatureIdTok: Label 'NewNpRvPrintExperience', Locked = true;
    begin
        if not (Rec.Id = FeatureIdTok) then
            exit;
        if xRec.Enabled then
            Error(CannotRevertErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;
        MigrateVoucherPrintSettings();
    end;

    local procedure MigrateVoucherPrintSettings()
    var
        VoucherType: Record "NPR NpRv Voucher Type";
        Voucher: Record "NPR NpRv Voucher";
        ModulePayDefault: Codeunit "NPR NpRv Module Pay.: Default";
        ModulePayPartial: Codeunit "NPR NpRv Module Pay. - Partial";
    begin
        VoucherType.SetFilter("Apply Payment Module", '%1|%2', ModulePayDefault.ModuleCode(), ModulePayPartial.ModuleCode());
        if VoucherType.FindSet() then
            repeat
                Voucher.Reset();
                Voucher.SetRange("Voucher Type", VoucherType.Code);
                Voucher.ModifyAll("Print Template Code", '');
                Voucher.SetRange("Print Object Type", Voucher."Print Object Type"::Template);
                if not Voucher.IsEmpty() then begin
                    Voucher.ModifyAll("Print Object ID", Codeunit::"NPR Static Retail Voucher");
                    Voucher.ModifyAll("Print Object Type", Voucher."Print Object Type"::Codeunit);
                end;
            until VoucherType.Next() = 0;

        VoucherType.SetRange("Print Object Type", VoucherType."Print Object Type"::Template);
        VoucherType.ModifyAll("Print Template Code", '');
        VoucherType.ModifyAll("Print Object ID", Codeunit::"NPR Static Retail Voucher");
        VoucherType.ModifyAll("Print Object Type", VoucherType."Print Object Type"::Codeunit);
    end;
}
