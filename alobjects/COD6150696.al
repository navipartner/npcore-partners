codeunit 6150696 "Managed Dependency Upgrade"
{
    // NPR5.47/MMV /20181012 CASE 311268 Created object
    // 
    // Persistent upgrade codeunit so NPDeploy is invoked when a released is deploy.
    // Purpose is to provide a failsafe deployment of add-ins for databases where this does not happen more frequently.
    // 
    // NPR5.51/MMV /20190731 CASE 363439 Added explicit commit for AL upgrade

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    trigger OnUpgradePerDatabase()
    begin
      Deploy();
    end;

    procedure Deploy()
    var
        ManagedDependencyMgt: Codeunit "Managed Dependency Mgt.";
        DependencyManagementSetup: Record "Dependency Management Setup";
    begin
        //-NPR5.51 [363439]
        Commit;
        //+NPR5.51 [363439]
        if not DependencyManagementSetup.Get then
          exit;
        if not DependencyManagementSetup.Configured then
          exit;

        if ManagedDependencyMgt.Run() then;
    end;
}

