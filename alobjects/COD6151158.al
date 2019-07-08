codeunit 6151158 "MM Membership (Upgrade)"
{
    // MM1.39/TSA /20190527 CASE 350968 Upgrade codeunit MM Membership change bool to option on auto-renew

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [TableSyncSetup]
    procedure TableSync(var TableSynchSetup: Record "Table Synch. Setup")
    var
        DataUpgradeMgt: Codeunit "Data Upgrade Mgt.";
    begin
        DataUpgradeMgt.SetTableSyncSetup (DATABASE::"MM Membership", DATABASE::"MM Membership (UPG)", TableSynchSetup.Mode::Copy);
    end;

    [UpgradePerCompany]
    procedure UpgradeMembershipAutoRenew()
    var
        Membership: Record "MM Membership";
        MembershipUPG: Record "MM Membership (UPG)";
    begin

        if (MembershipUPG.FindSet ()) then begin
          repeat
            if (Membership.Get (MembershipUPG."Entry No.")) then begin
              if (MembershipUPG."Auto-Renew") then begin
                Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
                Membership.Modify ();
              end;

            end;
          until (MembershipUPG.Next () = 0);
        end;
    end;
}

