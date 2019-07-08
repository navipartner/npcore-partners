codeunit 6150696 "Managed Dependency Upgrade"
{
    // NPR5.47/MMV /20181012 CASE 311268 Created object
    // 
    // Persistent upgrade codeunit so NPDeploy is invoked when a released is deploy.
    // Purpose is to provide a failsafe deployment of add-ins for databases where this does not happen more frequently.

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    [UpgradePerDatabase]
    procedure Deploy()
    var
        ManagedDependencyMgt: Codeunit "Managed Dependency Mgt.";
        DependencyManagementSetup: Record "Dependency Management Setup";
    begin
        if not DependencyManagementSetup.Get then
          exit;
        if not DependencyManagementSetup.Configured then
          exit;

        if ManagedDependencyMgt.Run() then;
    end;
}

