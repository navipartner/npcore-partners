codeunit 6014454 "Permission Set Mgt."
{
    // NPR5.37/BR  /20171023  CASE 293886 Remove Certain Pages From BUTIK
    // NPR5.38/JDH /20171214 CASE 299296 Changed lazy insert to correct "if not get then inserts" - Changed Hardcoded values to codefield.
    // NPR5.40/JDH /20180326 CASE 309189 Only if there is proper permission to write, it runs the permission set upgrade
    // NPR5.41/JDH /20180426 CASE 312644 Added code to support that this CU is executed as part of the database upgrade procedure (in a new seperate thread)


    trigger OnRun()
    var
        Permission: Record Permission;
    begin
        //-NPR5.41 [312644]
        if not Permission.WritePermission then begin
            if GuiAllowed then
                Message('You dont have permission to update the permissions in this database');
            exit;
        end;

        Permission.LockTable;
        //+NPR5.41 [312644]

        SetupStorePageRights();

        //-NPR5.41 [312644]
        SetupRetailRights();
        OnAfterSetupRetailRights();

        if GuiAllowed then
            Message('Permissions given!')
        //+NPR5.41 [312644]
    end;

    procedure SetupStorePageRights()
    var
        AllObj: Record AllObj;
        RoleID: Code[20];
    begin
        //-NPR5.38 [299296]
        RoleID := 'BUTIK';
        //+NPR5.38 [299296]
        //Changed Hardcoded Value to Variable RoleID (Undocumented
        CreatePermissionSet(RoleID);
        GivePermission(RoleID, AllObj."Object Type"::TableData, 0, 1, 1, 1, 1, 1);
        GiveExecutePermission(RoleID, AllObj."Object Type"::Table, 0);
        GiveExecutePermission(RoleID, AllObj."Object Type"::Codeunit, 0);
        GiveExecutePermission(RoleID, AllObj."Object Type"::Report, 0);
        GiveExecutePermission(RoleID, AllObj."Object Type"::XMLport, 0);
        GiveExecutePermission(RoleID, AllObj."Object Type"::MenuSuite, 0);
        GiveExecutePermission(RoleID, AllObj."Object Type"::System, 0);
        GiveExecutePermission(RoleID, AllObj."Object Type"::Query, 0);

        AllObj.SetRange("Object Type", AllObj."Object Type"::Page);
        AllObj.SetRange("Object ID", 1, 9799);
        if AllObj.FindSet then
            repeat
                GiveExecutePermission(RoleID, AllObj."Object Type", AllObj."Object ID")
until AllObj.Next = 0;

        AllObj.SetRange("Object ID", 9805, 9807);
        if AllObj.FindSet then
            repeat
                GiveExecutePermission(RoleID, AllObj."Object Type", AllObj."Object ID")
until AllObj.Next = 0;

        AllObj.SetRange("Object ID", 9809, 9814);
        if AllObj.FindSet then
            repeat
                GiveExecutePermission(RoleID, AllObj."Object Type", AllObj."Object ID")
until AllObj.Next = 0;

        AllObj.SetFilter("Object ID", '%1..', 50000);
        if AllObj.FindSet then
            repeat
                GiveExecutePermission(RoleID, AllObj."Object Type", AllObj."Object ID")
until AllObj.Next = 0;

        //-NPR5.41 [312644]
        //MESSAGE('Persmissions given!')
        //+NPR5.41 [312644]
    end;

    procedure CreatePermissionSet(Name: Text)
    var
        PermissionSet: Record "Permission Set";
    begin
        //-NPR5.38 [299296]
        if PermissionSet.Get(Name) then
            exit;
        //+NPR5.38 [299296]

        PermissionSet."Role ID" := Name;
        PermissionSet.Name := Name;
        //-NPR5.38 [299296]
        //IF PermissionSet.INSERT THEN;
        PermissionSet.Insert;
        //+NPR5.38 [299296]
    end;

    procedure GiveExecutePermission(RoleID: Code[20]; ObjectType: Integer; ObjectID: Integer)
    var
        AllObj: Record AllObj;
    begin
        //-NPR5.37 [293886]
        if (ObjectType <> AllObj."Object Type"::Page) or (not SkipPage(ObjectID)) then
            //+NPR5.37 [293886]
            GivePermission(RoleID, ObjectType, ObjectID, 0, 0, 0, 0, 1);
    end;

    procedure GivePermission(RoleID: Code[20]; ObjectType: Integer; ObjectID: Integer; ReadPermission: Integer; InsertPermission: Integer; ModifyPermission: Integer; DeletePermission: Integer; ExecutePermision: Integer)
    var
        Permission: Record Permission;
    begin
        //-NPR5.38 [299296]
        // Permission."Role ID"            := RoleID;
        // Permission."Object Type"        := ObjectType;
        // Permission."Object ID"          := ObjectID;
        // Permission."Read Permission"    := ReadPermission;
        // Permission."Insert Permission"  := InsertPermission;
        // Permission."Modify Permission"  := ModifyPermission;
        // Permission."Delete Permission"  := DeletePermission;
        // Permission."Execute Permission" := ExecutePermision;
        // IF Permission.INSERT THEN;

        if not Permission.Get(RoleID, ObjectType, ObjectID) then begin
            Permission."Role ID" := RoleID;
            Permission."Object Type" := ObjectType;
            Permission."Object ID" := ObjectID;
            Permission.Insert;
        end;
        Permission."Read Permission" := ReadPermission;
        Permission."Insert Permission" := InsertPermission;
        Permission."Modify Permission" := ModifyPermission;
        Permission."Delete Permission" := DeletePermission;
        Permission."Execute Permission" := ExecutePermision;
        Permission.Modify;
        //+NPR5.38 [299296]
    end;

    local procedure SkipPage(PageNumber: Integer): Boolean
    begin
        //-NPR5.37 [293886]
        if PageNumber in [
          PAGE::"Incoming Document Approvers",
          PAGE::"Profile Card",
          PAGE::"Profile List",
          PAGE::"User Personalization List",
          PAGE::"Delete Profile Configuration",
          PAGE::"Delete User Personalization",
          PAGE::"Session List",
          PAGE::"Custom Report Layouts",
          PAGE::"Report Layout Selection",
          PAGE::Users,
          PAGE::Devices,
          PAGE::"POS Web Fonts",
          PAGE::".NET Assemblies",
          PAGE::"Dependency Management Setup",
          PAGE::"POS Stargate Packages"
          ] then
            exit(true)
        else
            exit(false);
        //+NPR5.37 [293886]
    end;

    local procedure GivePermissionWithCheck(RoleID: Code[20]; ObjectType: Integer; ObjectID: Integer)
    var
        AllObj: Record AllObj;
    begin
        //-NPR5.41 [312644]
        case ObjectType of
            AllObj."Object Type"::Page:
                if SkipPage(ObjectID) then
                    exit;
            AllObj."Object Type"::TableData:
                if SkipTableData(ObjectID) then
                    exit;
        end;

        GivePermission(RoleID, ObjectType, ObjectID, 1, 1, 1, 1, 1);
        //+NPR5.41 [312644]
    end;

    local procedure SkipTableData(TableNumber: Integer): Boolean
    begin
        //-NPR5.41 [312644]
        if TableNumber in [
          DATABASE::"Audit Roll"
          ] then
            exit(true)
        else
            exit(false);
        //+NPR5.41 [312644]
    end;

    local procedure SetupRetailRights()
    var
        AllObj: Record AllObj;
        RoleID: Text;
    begin
        //-NPR5.41 [312644]
        RetailSuper;
        RetailAll;
        //+NPR5.41 [312644]
    end;

    local procedure RetailSuper()
    var
        AllObj: Record AllObj;
        RoleID: Code[20];
    begin
        //-NPR5.41 [312644]
        RoleID := 'RETAIL-SUPER';
        CreatePermissionSet(RoleID);

        AllObj.SetRange("Object Type", AllObj."Object Type"::TableData);
        AllObj.SetFilter("Object ID", '%1..%2|%3..%4|%5..%6|%7..%8', 6014400, 6014699, 6059767, 6060166, 6150613, 6151612, 6184471, 6185470);
        if AllObj.FindSet then
            repeat
                GivePermission(RoleID, AllObj."Object Type", AllObj."Object ID", 1, 1, 1, 1, 1);
            until AllObj.Next = 0;
        //+NPR5.41 [312644]
    end;

    local procedure RetailAll()
    var
        AllObj: Record AllObj;
        RoleID: Code[20];
    begin
        //-NPR5.41 [312644]
        RoleID := 'RETAIL-ALL';
        CreatePermissionSet(RoleID);

        AllObj.SetRange("Object Type", AllObj."Object Type"::TableData);
        AllObj.SetFilter("Object ID", '%1..%2|%3..%4|%5..%6|%7..%8', 6014400, 6014699, 6059767, 6060166, 6150613, 6151612, 6184471, 6185470);
        if AllObj.FindSet then
            repeat
                GivePermissionWithCheck(RoleID, AllObj."Object Type", AllObj."Object ID");
            until AllObj.Next = 0;
        GivePermission(RoleID, AllObj."Object Type"::TableData, DATABASE::"Audit Roll", 1, 2, 2, 2, 1);
        //+NPR5.41 [312644]
    end;

    [BusinessEvent(false)]
    local procedure OnAfterSetupRetailRights()
    begin
        //-NPR5.41 [312644]
    end;
}

