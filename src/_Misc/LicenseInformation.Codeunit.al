codeunit 6014402 "NPR License Information"
{
    // NPR5.41/THRO/20180425 CASE 311567 Changed temptable in GetRetailVersion to table with DataPerCompany=No (Printer Selection)
    // TM1.39/THRO/20181126  CASE 334644 Replaced Coudeunit 1 by Wrapper Codeunit

    TableNo = Object;

    trigger OnRun()
    begin
        if not InLicenseFile(Type, ID) then Error('');
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
        exit(not PermissionRange.IsEmpty);
    end;

    procedure HasPermission("Object Type": Integer; "Object No": Integer): Boolean
    var
        AccessControl: Record "Access Control";
        Permission: Record Permission;
        User: Record User;
    begin
        User.SetRange("User Name", UserId);
        User.FindFirst;

        AccessControl.SetRange("User Security ID", User."User Security ID");
        AccessControl.FindSet;

        Permission.SetRange("Role ID", AccessControl."Role ID");
        Permission.SetRange("Object Type", "Object Type");
        Permission.SetFilter("Object ID", '%1|%2', "Object No", 0);
        exit(not Permission.IsEmpty);
    end;

    procedure PaymentManagementLicensed(): Boolean
    begin
        exit(InLicenseFile(Object.Type::Table, GranulePaymentManagement))
    end;

    procedure DocumentCaptureLicensed(): Boolean
    begin
        exit(InLicenseFile(Object.Type::Table, GranuleDocumentCapture))
    end;

    procedure "-- Module Enums --"()
    begin
    end;

    procedure GranulePaymentManagement(): Integer
    begin
        exit(6016800);
    end;

    procedure GranuleDocumentCapture(): Integer
    begin
        exit(6085573);
    end;

    procedure GetRetailVersion(): Text[30]
    var
        Obj: Record "Object";
        StartPos: Integer;
        VersionlistRem: Text[1024];
        EndPos: Integer;
        TMPTable: Record "Printer Selection" temporary;
        VersionTag: Text[1024];
    begin
        Obj.SetFilter("Version List", '@*NPR*');
        if Obj.FindFirst then
            repeat
                //get strpos of NPR
                StartPos := StrPos(Obj."Version List", 'NPR');
                VersionlistRem := CopyStr(Obj."Version List", StartPos);
                EndPos := StrPos(VersionlistRem, ',');
                if EndPos = 0 then
                    EndPos := StrLen(VersionlistRem) - 11
                else
                    EndPos -= 12;
                if EndPos > 0 then
                    VersionTag := CopyStr(VersionlistRem, 12, EndPos);
                //-NPR5.41 [311567]
                if not TMPTable.Get(VersionTag, 0) then begin
                    TMPTable."Report ID" := 0;
                    TMPTable."User ID" := VersionTag;
                    TMPTable.Insert;
                end;
            until Obj.Next = 0;
        if TMPTable.FindLast then;
        exit(TMPTable."User ID");
        //+NPR5.41 [311567]
    end;

    [EventSubscriber(ObjectType::Codeunit, 6014427, 'OnAfterGetApplicationVersion', '', false, false)]
    local procedure AddRetailVersionSubscriber(var AppVersion: Text[80])
    begin
        AppVersion += ',NPR ' + GetRetailVersion;
    end;
}

