codeunit 6248414 "NPR UPGUserAccounts"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        _UpgradeTag: Codeunit "Upgrade Tag";
        _UpgradeTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        UpgradeSubscriptionsToAccounts();
    end;

    local procedure UpgradeSubscriptionsToAccounts()
    var
        MemberPaymentMethod: Record "NPR MM Member Payment Method";
        MembershipPmtMethodMap: Record "NPR MM MembershipPmtMethodMap";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipMgtInternal: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
        UserAccount: Record "NPR UserAccount";
        UserAccountMgt: Codeunit "NPR UserAccountMgtImpl";
        ShouldCreateAccount: Boolean;
    begin
        if (_UpgradeTag.HasUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPGUserAccounts", 'UpgradeSubscriptionsToAccounts'))) then
            exit;

        MemberPaymentMethod.SetRange("Table No.", Database::"NPR MM Membership");
        if MemberPaymentMethod.FindSet(true) then
            repeat
                if (Membership.Get(MemberPaymentMethod."BC Record ID")) then begin
                    MembershipRole.SetRange("Member Entry No.", Membership."Entry No.");
                    MembershipRole.SetRange("Member Role", MembershipRole."Member Role"::ADMIN);
#if (BC17 or BC18 or BC19 or BC20 or BC21)
                    Member.LockTable();
#else
                    Member.ReadIsolation := IsolationLevel::UpdLock;
#endif

                    if (MembershipRole.FindFirst()) and (Member.Get(MembershipRole."Member Entry No.")) then begin
                        ShouldCreateAccount := (not UserAccountMgt.FindAccountByEmail(Member."E-Mail Address".ToLower(), UserAccount));

                        if (ShouldCreateAccount) then
                            MembershipMgtInternal.CreateUserAccountFromMember(Member, UserAccount);

                        MemberPaymentMethod."Table No." := Database::"NPR UserAccount";
                        MemberPaymentMethod."BC Record ID" := UserAccount.RecordId();
                        MemberPaymentMethod.Modify();

                        MembershipPmtMethodMap.Init();
                        MembershipPmtMethodMap.MembershipId := Membership.SystemId;
                        MembershipPmtMethodMap.PaymentMethodId := MemberPaymentMethod.SystemId;
                        MembershipPmtMethodMap.Validate(Default, MemberPaymentMethod.Default);
                        MembershipPmtMethodMap.Insert();
                    end;
                end;
            until (MemberPaymentMethod.Next() = 0);

        _UpgradeTag.SetUpgradeTag(_UpgradeTagDef.GetUpgradeTag(Codeunit::"NPR UPGUserAccounts", 'UpgradeSubscriptionsToAccounts'));
    end;
}