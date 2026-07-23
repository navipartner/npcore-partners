codeunit 6151270 "NPR New Cash Drawer Open Exp" implements "NPR Feature Management"
{
    Access = Internal;

    procedure AddFeature()
    var
        Feature: Record "NPR Feature";
    begin
        Feature.Init();
        Feature.Id := GetFeatureId();
        Feature.Enabled := false;
        Feature.Description := GetFeatureDescription();
        Feature.Validate(Feature, Enum::"NPR Feature"::"New Cash Drawer Open Experience");
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
        FeatureIdTok: Label 'NewCashDrawerOpenExperience', Locked = true, MaxLength = 50;
    begin
        exit(FeatureIdTok);
    end;

    local procedure GetFeatureDescription(): Text[2048]
    var
        FeatureDescriptionLbl: Label 'New Cash Drawer Open Experience', MaxLength = 2048;
    begin
        exit(FeatureDescriptionLbl);
    end;

    [EventSubscriber(ObjectType::Table, Database::"NPR Feature", 'OnBeforeValidateEvent', 'Enabled', false, false)]
    local procedure NPRFeatureOnBeforeValidateEnabled(var Rec: Record "NPR Feature"; var xRec: Record "NPR Feature")
    var
        ConfirmManagement: Codeunit "Confirm Management";
        WarningLbl: Label 'WARNING: Enabling this feature is an irreversible action. Payment bins configured with the default EPSON_CASH_DRAWER print template will be migrated to the new static cash drawer open method. Are you sure you want to continue?';
        CannotRevertErr: Label 'This feature cannot be disabled once it is enabled.';
    begin
        if Rec.Id <> GetFeatureId() then
            exit;
        if xRec.Enabled then
            Error(CannotRevertErr);
        if not ConfirmManagement.GetResponseOrDefault(WarningLbl, false) then begin
            Rec.Enabled := false;
            Rec.Modify();
            exit;
        end;
        MigrateBins();
    end;

    internal procedure MigrateBins()
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        TempPOSPaymentBin: Record "NPR POS Payment Bin" temporary;
        POSPaymBinEjectTempl: Codeunit "NPR POS Paym.Bin Eject: Templ.";
        POSPaymBinEjectStatic: Codeunit "NPR POS Paym.Bin Eject: Static";
    begin
        POSPaymentBin.SetRange("Bin Type", POSPaymentBin."Bin Type"::CASH_DRAWER);
        POSPaymentBin.SetRange("Eject Method", CopyStr(POSPaymBinEjectTempl.InvokeMethodCode(), 1, MaxStrLen(POSPaymentBin."Eject Method")));
        if POSPaymentBin.FindSet() then
            repeat
                TempPOSPaymentBin := POSPaymentBin;
                TempPOSPaymentBin.Insert();
            until POSPaymentBin.Next() = 0;

        if TempPOSPaymentBin.FindSet() then
            repeat
                if POSPaymentBin.Get(TempPOSPaymentBin."No.") then
                    if POSPaymBinEjectTempl.ResolveEffectiveTemplate(POSPaymentBin) = POSPaymBinEjectTempl.DefaultCashDrawerTemplate() then begin
                        POSPaymentBin.Validate("Eject Method", CopyStr(POSPaymBinEjectStatic.InvokeMethodCode(), 1, MaxStrLen(POSPaymentBin."Eject Method")));
                        POSPaymentBin.Modify(true);
                    end;
            until TempPOSPaymentBin.Next() = 0;
    end;
}
