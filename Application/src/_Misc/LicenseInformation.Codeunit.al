codeunit 6014402 "NPR License Information"
{

    TableNo = Object;

    trigger OnRun()
    begin
        if not InLicenseFile(Rec.Type, Rec.ID) then
            Error('');
    end;

    var
        "Object": Record "Object";

    procedure InLicenseFile("Object Type": Integer; "Object No": Integer): Boolean
    var
        PermissionRange: Record "Permission Range";
    begin
        PermissionRange.SetRange("Object Type", "Object Type");
        PermissionRange.SetFilter(From, '<=%1', "Object No");
        PermissionRange.SetFilter("To", '>=%1', "Object No");
        PermissionRange.SetRange("Execute Permission", PermissionRange."Execute Permission"::Yes);
        exit(not PermissionRange.IsEmpty());
    end;

    procedure HasPermission("Object Type": Integer; "Object No": Integer): Boolean
    var
        AccessControl: Record "Access Control";
        Permission: Record Permission;
        User: Record User;
    begin
        User.SetRange("User Name", UserId);
        User.FindFirst();

        AccessControl.SetRange("User Security ID", User."User Security ID");
        AccessControl.FindSet();

        Permission.SetRange("Role ID", AccessControl."Role ID");
        Permission.SetRange("Object Type", "Object Type");
        Permission.SetFilter("Object ID", '%1|%2', "Object No", 0);
        exit(not Permission.IsEmpty());
    end;

    procedure PaymentManagementLicensed(): Boolean
    begin
        exit(InLicenseFile(Object.Type::Table, GranulePaymentManagement()))
    end;

    procedure DocumentCaptureLicensed(): Boolean
    begin
        exit(InLicenseFile(Object.Type::Table, GranuleDocumentCapture()))
    end;

    procedure GranulePaymentManagement(): Integer
    begin
        exit(6016800);
    end;

    procedure GranuleDocumentCapture(): Integer
    begin
        exit(6085573);
    end;

    procedure GetRetailVersion(): Text
    var
        NPRApp: ModuleInfo;
    begin
        NavApp.GetCurrentModuleInfo(NPRApp);
        exit(StrSubstNo('NPR%1', NPRApp.AppVersion()));
    end;
}

