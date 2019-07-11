codeunit 6150698 "Retail Data Model Upgrade"
{
    // NPR5.30/AP/20170222  CASE 261728  Created object.
    //                                   To be used as "Data Upgrade" entry point for Retail Data Model Upgrade Mgt.
    // NPR5.38/JDH /20171214 CASE 299296 Permission set management codeunit is triggered when running Data Upgrade
    // NPR5.40/JDH /20180326 CASE 309189 moved permission handling to permission CU
    // NPR5.41/THRO/20180425 CASE 311567 added function to update NPR Upgrade History
    // NPR5.41/JDH /20180426 CASE 312644 And moved the permisssion set management trigger back again to this Codeunit
    // NPR5.42/JDH /20180522 CASE 313269 STARTSESSION Fails on 2018 multitenant databases running CU4 - if so, run it normally

    Subtype = Upgrade;

    trigger OnRun()
    begin
    end;

    trigger OnUpgradePerDatabase()
    begin
      UpdateUpgradeHistory();
      UpgradePermissions();
    end;

    trigger OnUpgradePerCompany()
    begin
        UpgradeDateModelPerCompany();
    end;

    procedure UpgradeDateModelPerCompany()
    var
        RetailDataModelUpgradeMgt: Codeunit "Retail Data Model Upgrade Mgt.";
    begin
        RetailDataModelUpgradeMgt.TestUpgradeFromDataUpgradePerCompany;
    end;

    procedure UpdateUpgradeHistory()
    var
        NPRUpgradeHistory: Record "NPR Upgrade History";
        Licenceinformation: Codeunit "Licence information";
    begin
        //-NPR5.41 [311567]
        NPRUpgradeHistory.Init;
        NPRUpgradeHistory."Entry No." := 0;
        NPRUpgradeHistory."Upgrade Time" := CurrentDateTime;
        NPRUpgradeHistory.Version := 'NPR ' + Licenceinformation.GetRetailVersion;
        NPRUpgradeHistory.Insert(true);
        //+NPR5.41 [311567]
    end;

    procedure UpgradePermissions()
    var
        SessionID: Integer;
    begin
        //-NPR5.41 [312644]
        //This codeunit will update permissions in its own thread. This is done due to locking issues in Multitenant environments.
        //When the thread is finished, NAV will automatically terminate the thread, and an implicit Commit will be executed, thereby releasing the lock of the table
        //-NPR5.42 [313269]
        //STARTSESSION(SessionID, CODEUNIT::"Permission Set Mgt.");
        if not StartSession(SessionID, CODEUNIT::"Permission Set Mgt.") then
          CODEUNIT.Run(CODEUNIT::"Permission Set Mgt.");
        //+NPR5.42 [313269]
        //+NPR5.41 [312644]
    end;
}

