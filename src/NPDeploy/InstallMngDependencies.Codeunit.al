codeunit 6014423 "NPR Install Mng. Dependencies"
{
    // NPR5.00/JDH/20160706 CASE 243906 Managed Dependency download
    // NPR5.26/MMV /20160907 CASE 242977 Removed reference to field "Use Ground Control Deployment"
    // NPR5.29/JDH /20170116 CASE 263589 Possible to run it without user confirmation (test framework cant run it otherwise)


    trigger OnRun()
    begin
        InsertBaseData;
        Commit;
        DownloadManagedDependecies;
    end;

    var
        Text001: Label 'This will Setup %1 to download automatically';
        Text002: Label 'Do you wish to Continue?';
        Text003: Label 'Downloading Managed Dependencies';
        Dia: Dialog;
        Text004: Label 'This can take 1-2 minutes';

    procedure InsertBaseData()
    var
        DependencyMgtSetup: Record "NPR Dependency Mgt. Setup";
    begin
        if GuiAllowed then
            //-NPR5.26 [242977]
            //IF NOT CONFIRM(STRSUBSTNO(Text001, DependencyMgtSetup.TABLECAPTION, USERID) + '\' + Text002) THEN
            if not Confirm(StrSubstNo(Text001, DependencyMgtSetup.TableCaption) + '\' + Text002) then
                //-NPR5.26 [242977]
                exit;
        //-NPR5.29 [263589]
        // IF NOT DependencyMgtSetup.GET THEN BEGIN
        //  DependencyMgtSetup.INIT;
        //  DependencyMgtSetup.INSERT;
        // END;
        //
        // DependencyMgtSetup."OData URL" := 'https://npdeploy.dynamics-retail.com:7088/NPDeploy/OData/Company('+'''RetailDemo'''+')/';
        // DependencyMgtSetup.Username := 'npkcenter\npdeploywsuser';
        // DependencyMgtSetup.StoreManagedDependencyPassword('+11DsZ31+1');
        // DependencyMgtSetup."Accept Statuses" := DependencyMgtSetup."Accept Statuses"::Released;
        // DependencyMgtSetup.Configured := TRUE;
        // DependencyMgtSetup.MODIFY;
        InsertSetup;
        //+NPR5.29 [263589]

        //-NPR5.26 [242977]
        // IF NOT UserSetup.GET(USERID) THEN BEGIN
        //  UserSetup.INIT;
        //  UserSetup."User ID" := USERID;
        //  UserSetup."Use Ground Control Deployment" := TRUE;
        //  UserSetup.INSERT(TRUE);
        // END
        // ELSE BEGIN
        //  UserSetup."Use Ground Control Deployment" := TRUE;
        //  UserSetup.MODIFY(TRUE);
        // END;
        //+NPR5.26 [242977]
    end;

    procedure DownloadManagedDependecies()
    var
        ManagedDependencyMgt: Codeunit "NPR Managed Dependency Mgt.";
    begin
        if GuiAllowed then
            Dia.Open(Text003 + '\' + Text004);

        ManagedDependencyMgt.Run();

        if GuiAllowed then
            Dia.Close;
    end;

    procedure InsertSetup()
    var
        DependencyMgtSetup: Record "NPR Dependency Mgt. Setup";
    begin
        //-NPR5.29 [263589]
        if not DependencyMgtSetup.Get then begin
            DependencyMgtSetup.Init;
            DependencyMgtSetup.Insert;
        end;

        DependencyMgtSetup."OData URL" := 'https://npdeploy.dynamics-retail.com:7088/NPDeploy/OData/Company(' + '''RetailDemo''' + ')/';
        DependencyMgtSetup.Username := 'npkcenter\npdeploywsuser';
        DependencyMgtSetup.StoreManagedDependencyPassword('+11DsZ31+1');
        DependencyMgtSetup."Accept Statuses" := DependencyMgtSetup."Accept Statuses"::Released;
        DependencyMgtSetup.Configured := true;
        DependencyMgtSetup.Modify;
        //+NPR5.29 [263589]
    end;
}

