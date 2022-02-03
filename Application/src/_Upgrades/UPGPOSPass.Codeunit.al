codeunit 6014591 "NPR UPG POS Pass"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Pass', 'OnCheckPreconditionsPerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pass", 'UpgradePOSUnitPasswords')) then begin
            UpgradePOSUnitPasswords();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pass", 'UpgradePOSUnitPasswords'));
        end;

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pass", 'MoveLockPassToPOSSecurityProfile')) then begin
            MoveLockPassToPOSSecurityProfile();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pass", 'MoveLockPassToPOSSecurityProfile'));
        end;

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSUnitPasswords()
    var
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
        POSSecurityProfile: Record "NPR POS Security Profile";
    begin
        if not POSUnit.FindSet() then
            exit;
        repeat
            if POSUnit.GetProfile(POSViewProfile) and (POSViewProfile."Open Register Password" = '') then begin
                POSViewProfile."Open Register Password" := POSUnit."Open Register Password";
                POSViewProfile.Modify();
            end;
            if POSUnit.GetProfile(POSSecurityProfile) and (POSSecurityProfile."Password on Unblock Discount" = '') then begin
                POSSecurityProfile."Password on Unblock Discount" := POSUnit."Password on Unblock Discount";
                POSSecurityProfile.Modify();
            end;
        until POSUnit.next() = 0;
    end;

    local procedure MoveLockPassToPOSSecurityProfile()
    var
        BasePosSecurityProfile: Record "NPR POS Security Profile";
        NewPosSecurityProfile: Record "NPR POS Security Profile";
        PosViewProfile: Record "NPR POS View Profile";
        PosUnit: Record "NPR POS Unit";
    begin
        if PosViewProfile.FindSet() then
            repeat
                if (PosViewProfile."Lock Timeout" <> PosViewProfile."Lock Timeout"::NEVER) or (PosViewProfile."Open Register Password" <> '') then begin
                    PosUnit.SetRange("POS View Profile", PosViewProfile.Code);
                    if PosUnit.FindSet() then
                        repeat
                            case true of
                                (PosUnit."POS Security Profile" = '') or not BasePosSecurityProfile.Get(PosUnit."POS Security Profile"):
                                    begin
                                        NewPosSecurityProfile.SetRange("Lock Timeout", PosViewProfile."Lock Timeout");
                                        NewPosSecurityProfile.SetRange("Unlock Password", PosViewProfile."Open Register Password");
                                        NewPosSecurityProfile.SetRange("Password on Unblock Discount", '');
                                        if not NewPosSecurityProfile.FindFirst() then begin
                                            Clear(BasePosSecurityProfile);
                                            BasePosSecurityProfile.Code := PosUnit."POS Security Profile";
                                            InsertPosSecurityProfile(BasePosSecurityProfile, PosViewProfile, NewPosSecurityProfile);
                                        end;
                                        PosUnit."POS Security Profile" := NewPosSecurityProfile.Code;
                                        PosUnit.Modify();
                                    end;

                                (BasePosSecurityProfile."Lock Timeout" = BasePosSecurityProfile."Lock Timeout"::NEVER) and (BasePosSecurityProfile."Unlock Password" = ''):
                                    begin
                                        BasePosSecurityProfile."Lock Timeout" := PosViewProfile."Lock Timeout";
                                        BasePosSecurityProfile."Unlock Password" := PosViewProfile."Open Register Password";
                                        BasePosSecurityProfile.Modify();
                                    end;

                                (BasePosSecurityProfile."Lock Timeout" <> PosViewProfile."Lock Timeout") or (BasePosSecurityProfile."Unlock Password" <> PosViewProfile."Open Register Password"):
                                    begin
                                        NewPosSecurityProfile.SetRange("Lock Timeout", PosViewProfile."Lock Timeout");
                                        NewPosSecurityProfile.SetRange("Unlock Password", PosViewProfile."Open Register Password");
                                        NewPosSecurityProfile.SetRange("Password on Unblock Discount", BasePosSecurityProfile."Password on Unblock Discount");
                                        if not NewPosSecurityProfile.FindFirst() then
                                            InsertPosSecurityProfile(BasePosSecurityProfile, PosViewProfile, NewPosSecurityProfile);
                                        PosUnit."POS Security Profile" := NewPosSecurityProfile.Code;
                                        PosUnit.Modify();
                                    end;
                            end;
                        until PosUnit.Next() = 0;
                end;
            until PosViewProfile.Next() = 0;
    end;

    local procedure InsertPosSecurityProfile(FromPosSecurityProfile: Record "NPR POS Security Profile"; PosViewProfile: Record "NPR POS View Profile"; var PosSecurityProfile: Record "NPR POS Security Profile")
    var
        AutoGeneratedLbl: Label 'Created from POS v.profile %1', MaxLength = 32;
    begin
        if FromPosSecurityProfile.Code <> '' then
            PosSecurityProfile.Code := FromPosSecurityProfile.Code
        else
            PosSecurityProfile.Code := PosViewProfile.Code;
        if PosSecurityProfile.Find() then begin
            PosSecurityProfile.Code := 'UPGRADE_001';
            while PosSecurityProfile.Find() do
                PosSecurityProfile.Code := IncStr(PosSecurityProfile.Code);
        end;
        PosSecurityProfile.Init();
        PosSecurityProfile."Lock Timeout" := PosViewProfile."Lock Timeout";
        PosSecurityProfile."Unlock Password" := PosViewProfile."Open Register Password";
        PosSecurityProfile."Password on Unblock Discount" := FromPosSecurityProfile."Password on Unblock Discount";
        PosSecurityProfile.Description := CopyStr(StrSubstNo(AutoGeneratedLbl, PosSecurityProfile.Code), 1, MaxStrLen(PosSecurityProfile.Description));
        PosSecurityProfile.Insert();
    end;
}
