codeunit 6060128 "NPR MM Member WebService"
{

    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1.';

    procedure MemberValidation(ExternalMemberNo: Code[20]; ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMemberNo(ExternalMemberNo);
        exit(IsMembershipValid(MembershipEntryNo));
    end;

    procedure MembershipValidation(ExternalMembershipNo: Code[20]; ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMembershipNo(ExternalMembershipNo);
        exit(IsMembershipValid(MembershipEntryNo));
    end;

    procedure MemberEmailExists(EmailToCheck: Text[100]) EmailExists: Boolean
    var
        Member: Record "NPR MM Member";
    begin

        Member.SetFilter("E-Mail Address", '=%1', LowerCase(EmailToCheck));
        Member.SetFilter(Blocked, '=%1', false);
        exit(Member.FindFirst());
    end;

    procedure MemberCardNumberValidation(ExternalMemberCardNo: Text[50]; ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
        NotFoundReasonText: Text;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtCardNo(ExternalMemberCardNo, WorkDate(), NotFoundReasonText);
        exit(IsMembershipValid(MembershipEntryNo));
    end;

    procedure MemberRegisterArrival(ExternalMemberNo: Code[20]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var MessageText: Text) IsRegistered: Boolean
    var
        Success: Integer;
    begin

        MessageText := '';
        Success := ValidateMemberAndRegisterArrival(ExternalMemberNo, '', AdmissionCode, ScannerStationId, MessageText);
        exit(Success = 0);
    end;

    procedure MemberCardRegisterArrival(ExternalMemberCardNo: Code[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var MessageText: Text) IsRegistered: Boolean
    var
        Member: Record "NPR MM Member";
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MemberEntryNo: Integer;
        Success: Integer;
    begin

        MessageText := '';
        MemberEntryNo := MembershipMgr.GetMemberFromExtCardNo(ExternalMemberCardNo, Today, MessageText);
        if (MemberEntryNo = 0) then begin
            exit(false);
        end;

        Member.Get(MemberEntryNo);

        Success := ValidateMemberAndRegisterArrival(Member."External Member No.", ExternalMemberCardNo, AdmissionCode, ScannerStationId, MessageText);
        exit(Success = 0);
    end;

    procedure GetMembershipTicketList(var Membership: XMLport "NPR MM Get Members. TicketList"; AdmissionCode: Code[20]; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetMembershipTicketList-%1.xml', Locked = true;
    begin

        Membership.Import();

        InsertImportEntry('GetMembershipTicketList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            Membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                Membership.AddResponse(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", AdmissionCode);
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.DeleteAll();

        end else begin
            Membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure GetMembershipChangeItemsList(var Membership: XMLport "NPR MM Get Members. Chg. Items")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetMembershipChangeItemsList-%1.xml', Locked = true;
    begin

        Membership.Import();

        InsertImportEntry('GetMembershipChangeItemsList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            Membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                Membership.AddResponse(MemberInfoCapture."Membership Entry No.");
            until (MemberInfoCapture.Next() = 0);

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            Membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure ActivateMembership(ExternalMembershipNo: Code[20]; ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMembershipNo(ExternalMembershipNo);
        exit(MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate(), true));
    end;

    procedure CreateMembership(var membership: XMLport "NPR MM Create Membership"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'CreateMembership-%1.xml', Locked = true;
    begin

        membership.Import();

        InsertImportEntry('CreateMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                membership.AddResponse(MemberInfoCapture."Membership Entry No.");
            until (MemberInfoCapture.Next() = 0);

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();

        end else begin
            membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export();
        ImportEntry.Modify(true);
        Commit();
    end;

    procedure AddMembershipMember(var member: XMLport "NPR MM Add Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'AddMembershipMember-%1.xml', Locked = true;
    begin

        member.Import();

        InsertImportEntry('AddMembershipMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            member.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                member.AddResponse(MemberInfoCapture."Member Entry No");
            until (MemberInfoCapture.Next() = 0);

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            member.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);
        Commit();
    end;

    procedure AddAnonymousMember(var AnonymousMember: XMLport "NPR MM Anonymous Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'AddAnonymousMember-%1.xml', Locked = true;
    begin

        AnonymousMember.Import();

        InsertImportEntry('AddAnonymousMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        AnonymousMember.SetDestination(OutStr);
        AnonymousMember.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            AnonymousMember.ClearResponse();
            AnonymousMember.AddResponse();

            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");

            MemberInfoCapture.DeleteAll();

        end else begin
            AnonymousMember.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure ChangeMembership(var membership: XMLport "NPR MM Change Membership")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'ChangeMembership-%1.xml', Locked = true;
    begin

        membership.Import();

        InsertImportEntry('ChangeMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export();
        Commit();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                membership.AddResponse(MemberInfoCapture."Membership Entry No.");
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.DeleteAll();

        end else begin
            membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure GetMembership(var membership: XMLport "NPR MM Get Membership"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetMembership-%1.xml', Locked = true;
    begin

        membership.Import();

        InsertImportEntry('GetMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                membership.AddResponse(MemberInfoCapture."Membership Entry No.");
            until (MemberInfoCapture.Next() = 0);

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export();
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure GetMembershipMembers(var member: XMLport "NPR MM Get Members. Members"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetMembershipMembers-%1.xml', Locked = true;
    begin

        member.Import();

        InsertImportEntry('GetMembershipMembers', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);

        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            member.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindFirst();

            member.AddResponse(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Member No", MemberInfoCapture."External Card No.");

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            member.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure UpdateMember(var member: XMLport "NPR MM Update Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'UpdateMember-%1.xml', Locked = true;
    begin

        member.Import();

        InsertImportEntry('UpdateMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        Commit();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            member.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                member.AddResponse(MemberInfoCapture."Member Entry No");
            until (MemberInfoCapture.Next() = 0);

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            member.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure UpdateMemberImage(MemberExternalNo: Code[20]; Base64StringImage: Text; ScannerStationId: Code[10]) Success: Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberEntryNo: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(MemberExternalNo);
        Success := MembershipManagement.UpdateMemberImage(MemberEntryNo, Base64StringImage);

        exit(Success);
    end;

    procedure GetMemberImage(MemberExternalNo: Code[20]; var Base64StringImage: Text; ScannerStationId: Code[10]) Success: Boolean
    var
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberEntryNo: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(MemberExternalNo);
        Success := MembershipManagement.GetMemberImage(MemberEntryNo, Base64StringImage);

        exit(Success);
    end;

    procedure BlockMembership(var member: XMLport "NPR MM Block Membership"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'BlockMembership-%1.xml', Locked = true;
    begin

        member.Import();

        InsertImportEntry('BlockMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);

        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            member.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindFirst();

            member.AddResponse(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Member No", MemberInfoCapture."External Card No.");

            if (MemberInfoCapture."External Membership No." <> '') then
                ImportEntry."Document Name" := StrSubstNo(FileNameLbl, MemberInfoCapture."External Membership No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            member.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure BlockMember(var member: XMLport "NPR MM Block Membership Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'BlockMember-%1.xml', Locked = true;
    begin

        member.Import();

        InsertImportEntry('BlockMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);

        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            member.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindFirst();

            member.AddResponse(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Member No", MemberInfoCapture."External Card No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            member.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export();
        ImportEntry.Modify(true);

        Commit();

    end;

    procedure GetMembershipRoles(var roles: XMLport "NPR MM Get Member GDPR Roles")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetMembershipRoles-%1.xml', Locked = true;
    begin

        roles.Import();

        InsertImportEntry('GetMembershipRoles', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        roles.SetDestination(OutStr);
        roles.Export();
        Commit();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            roles.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                roles.AddResponse(MemberInfoCapture."Member Entry No");
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.DeleteAll();

        end else begin
            roles.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();

    end;

    procedure GetSetGDPRApprovalState(var gdpr: XMLport "NPR MM GDPR GetSet Appr. State")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'SetGDPRApproval-%1.xml', Locked = true;
    begin

        gdpr.Import();

        InsertImportEntry('SetGDPRApproval', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        gdpr.SetDestination(OutStr);
        gdpr.Export();
        Commit();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            gdpr.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                gdpr.AddResponse(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No");
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.DeleteAll();

        end else begin
            gdpr.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure ConfirmMembershipPayment(var ConfirmMembershipPayment: XMLport "NPR MM Confirm Members. Pay.")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'ConfirmMembershipPayment-%1.xml', Locked = true;
    begin

        ConfirmMembershipPayment.Import();

        InsertImportEntry('ConfirmMembershipPayment', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ConfirmMembershipPayment.SetDestination(OutStr);
        ConfirmMembershipPayment.Export();
        ImportEntry.Modify(true);

        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            ConfirmMembershipPayment.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindFirst();

            ConfirmMembershipPayment.AddResponse(MemberInfoCapture."Membership Entry No.");

            MemberInfoCapture.DeleteAll();
        end else begin
            ConfirmMembershipPayment.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ConfirmMembershipPayment.SetDestination(OutStr);
        ConfirmMembershipPayment.Export();
        ImportEntry.Modify(true);

        Commit();

    end;

    procedure RegretMembershipTimeframe(var Membership: XMLport "NPR MM Regret Member Timeframe")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'RegretMembership-%1.xml', Locked = true;
    begin

        Membership.Import();

        InsertImportEntry('RegretMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        Commit();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            Membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                Membership.AddResponse(MemberInfoCapture."Membership Entry No.");
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.DeleteAll();

        end else begin
            Membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure PrintMemberCard(ExternalMemberCardNo: Code[50]; PrintDirective: Integer): Boolean
    var
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MemberCard: Record "NPR MM Member Card";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipNotification: Record "NPR MM Membership Notific.";
        EntryNo: Integer;
    begin

        MemberCard.SetFilter("External Card No.", '=%1', ExternalMemberCardNo);
        if (not MemberCard.FindFirst()) then
            exit(false);

        case PrintDirective of
            1:
                MemberRetailIntegration.PrintMemberCard(MemberCard."Member Entry No.", MemberCard."Entry No.");
            2:
                MembershipManagement.PrintOffline(MemberInfoCapture."Information Context"::PRINT_CARD, MemberCard."Entry No.");

            3:
                begin
                    EntryNo := MemberNotification.CreateWalletSendNotification(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.", TODAY);
                    if (MembershipNotification.Get(EntryNo)) then
                        if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                            MemberNotification.HandleMembershipNotification(MembershipNotification);
                end;

            else
                Error('Print Directive 1: Print to Google printer, 2: Print to Offline Journal, 3: Wallet, print to NP Pass Server');
        end;

        exit(true);

    end;

    procedure CreateWalletMemberPass(var CreateMemberPass: XMLport "NPR MM Create Wallet Mem. Pass")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'CreateWalletMemberPass-%1.xml', Locked = true;
    begin

        CreateMemberPass.Import();

        InsertImportEntry('CreateWalletMemberPass', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        CreateMemberPass.SetDestination(OutStr);
        CreateMemberPass.Export();
        Commit();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            CreateMemberPass.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet();
            repeat
                CreateMemberPass.AddResponse(MemberInfoCapture."Entry No.");
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.DeleteAll();

        end else begin
            CreateMemberPass.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure ValidateNotificationToken(Token: Text[64]; var ExternalMembershipNumber: Code[20]; var ExternalMemberNumber: Code[20]): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (StrLen(Token) <> MaxStrLen(MembershipRole."Notification Token")) then
            exit(false);

        MembershipRole.SetFilter("Notification Token", '=%1', Token);
        if (not MembershipRole.FindFirst()) then
            exit(false);

        MembershipRole.CalcFields("External Membership No.", "External Member No.");
        ExternalMembershipNumber := MembershipRole."External Membership No.";
        ExternalMemberNumber := MembershipRole."External Member No.";

        exit(true);

    end;

    procedure ExpireNotificationToken(Token: Text[64])
    var
        MembershipRole: Record "NPR MM Membership Role";
        TokenExpiredLbl: Label 'Token Expired at %1 %2';
    begin

        if (StrLen(Token) <> MaxStrLen(MembershipRole."Notification Token")) then
            exit;

        MembershipRole.SetFilter("Notification Token", '=%1', Token);
        if (not MembershipRole.FindFirst()) then
            exit;

        MembershipRole."Notification Token" := StrSubstNo(TokenExpiredLbl, Today(), Time());
        MembershipRole.Modify();

    end;

    procedure GenerateNotificationToken(ExternalMembershipNumber: Code[20]; ExternalMemberNumber: Code[20]; var Token: Text[64]): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        Membership.SetFilter("External Membership No.", '=%1', ExternalMembershipNumber);
        if (not Membership.FindFirst()) then
            exit(false);

        Member.SetFilter("External Member No.", '=%1', ExternalMemberNumber);
        if (not Member.FindFirst()) then
            exit(false);

        if (not MembershipRole.Get(Membership."Entry No.", Member."Entry No.")) then
            exit(false);

        Token := MemberNotification.GenerateNotificationToken();
        MembershipRole."Notification Token" := Token;

        exit(MembershipRole.Modify());

    end;

    procedure GetSetComOptions(var GetSetMemberComOptions: XMLport "NPR MM Member Comm.")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberCommunication: Record "NPR MM Member Communication";
        TempMemberCommunication: Record "NPR MM Member Communication" temporary;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ExternalMemberNo: Code[20];
        ExternalMembershipNo: Code[20];
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
        FileNameLbl: Label 'GetSetMemberComOption-%1.xml', Locked = true;
        MemberNumberInvalidLbl: Label 'Member number "%1" or Membership number "%2" is invalid.';
    begin

        GetSetMemberComOptions.Import();

        InsertImportEntry('GetSetMemberComOption', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetMemberComOptions.SetDestination(OutStr);
        GetSetMemberComOptions.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            GetSetMemberComOptions.GetRequest(ExternalMemberNo, ExternalMembershipNo, TempMemberCommunication);

            MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo);
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(ExternalMembershipNo);

            if (MemberEntryNo = 0) or (MembershipEntryNo = 0) then begin
                ResponseMessage := StrSubstNo(MemberNumberInvalidLbl, ExternalMemberNo, ExternalMembershipNo);
                GetSetMemberComOptions.SetErrorResponse(ResponseMessage);

            end else begin
                TempMemberCommunication.Reset();

                MembershipManagement.CreateMemberCommunicationDefaultSetup(MemberEntryNo);

                if (TempMemberCommunication.FindSet()) then begin
                    repeat
                        if (MemberCommunication.Get(MemberEntryNo, MembershipEntryNo, TempMemberCommunication."Message Type")) then begin
                            MemberCommunication.TransferFields(TempMemberCommunication, false);
                            MemberCommunication."Changed At" := CurrentDateTime();
                            MemberCommunication.Modify();
                        end;
                    until (TempMemberCommunication.Next() = 0);

                    if (TempMemberCommunication.IsTemporary()) then
                        TempMemberCommunication.DeleteAll();
                end;

                MemberCommunication.Reset();
                MemberCommunication.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
                MemberCommunication.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                if (MemberCommunication.FindSet()) then begin
                    repeat
                        TempMemberCommunication.TransferFields(MemberCommunication, true);
                        TempMemberCommunication.Insert();
                    until (MemberCommunication.Next() = 0);
                end;

                GetSetMemberComOptions.SetResponse(ExternalMemberNo, ExternalMembershipNo, TempMemberCommunication);

            end;
        end else begin
            GetSetMemberComOptions.SetErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetMemberComOptions.SetDestination(OutStr);
        GetSetMemberComOptions.Export();
        ImportEntry.Modify(true);

        Commit();

    end;

    procedure GetAutoRenewProduct(var Membership: XMLport "NPR MM Get AutoRenew Product")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'GetMembershipAutoRenewProduct-%1.xml', Locked = true;
    begin

        Membership.Import();

        InsertImportEntry('GetMembershipAutoRenewProduct', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            Membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                Membership.AddResponse(MemberInfoCapture."Membership Entry No.");
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.Delete();
        end else begin
            Membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure ConfirmAutoRenewPayment(var Membership: XMLport "NPR MM Confirm AutoRenew Pay.")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        FileNameLbl: Label 'ConfirmAutoRenewPayment-%1.xml', Locked = true;
    begin

        Membership.Import();

        InsertImportEntry('ConfirmAutoRenewPayment', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin
            Membership.ClearResponse();
            MemberInfoCapture.SetCurrentKey("Import Entry Document ID");
            MemberInfoCapture.SetFilter("Import Entry Document ID", '=%1', ImportEntry."Document ID");
            MemberInfoCapture.FindSet(true);
            repeat
                Membership.AddResponse(MemberInfoCapture);
            until (MemberInfoCapture.Next() = 0);

            MemberInfoCapture.Delete();
        end else begin
            Membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export();
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure GetSetAutoRenew(var GetSetAutoRenew: XMLport "NPR MM GetSet AutoRenew Option")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        FileNameLbl: Label 'GetSetAutoRenewOption-%1.xml', Locked = true;
    begin

        GetSetAutoRenew.Import();

        InsertImportEntry('GetSetAutoRenewOption', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := CreateDocumentId();

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetAutoRenew.SetDestination(OutStr);
        GetSetAutoRenew.Export();
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            GetSetAutoRenew.createResponse();

        end else begin
            GetSetAutoRenew.setError('Not processed.');

        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetAutoRenew.SetDestination(OutStr);
        GetSetAutoRenew.Export();
        ImportEntry.Modify(true);

        Commit();

    end;

    procedure MemberFieldUpdate(EntryNo: Integer; CurrentValue: Text[200]; NewValue: Text[200])
    var
        MemberFieldUpdateMgr: Codeunit "NPR MM Request Member Upd Mgr";
    begin
        MemberFieldUpdateMgr.UpdateMemberField(EntryNo, CurrentValue, NewValue, 0);
        COMMIT();
    end;

    procedure ReqeustMemberFieldUpdate(MemberCardNumber: Text[50]; FieldId: Code[10]; ScannerStationId: Code[10]): Boolean
    var
        MemberFieldUpdateMgr: Codeunit "NPR MM Request Member Upd Mgr";
    begin

        MemberFieldUpdateMgr.RequestFieldUpdate(MemberCardNumber, FieldId, ScannerStationId);
        EXIT(TRUE);
    end;

    procedure ResolveMemberIdentifier(var MemberIdentifier: XMLport "NPR MM Member Identifier")
    begin

        MemberIdentifier.Import();
        MemberIdentifier.CreateResult();

    end;

    local procedure IsMembershipValid(MembershipEntryNo: Integer) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
    begin

        if (MembershipEntryNo = 0) then
            exit(false);

        IsValid := MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate(), false);
        if (not IsValid) then
            IsValid := MembershipMgr.MembershipNeedsActivation(MembershipEntryNo);

        exit(IsValid);
    end;

    local procedure ValidateMemberAndRegisterArrival(ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[100]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text) ResponseCode: Integer
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        AttemptArrival: Codeunit "NPR MM Attempt Member Arrival";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        LimitLogEntry: Integer;
        MemberCardEntryNo: Integer;
        MembershipEntryNo: Integer;
        ExternalMemberNotFoundLbl: Label 'External Member Number %1, not found.';
        MembershipNotActiveLbl: Label 'Membership is not active for today (%1).';
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMemberNo(ExternalMemberNo);
        if (ExternalMemberCardNo <> '') then
            MembershipEntryNo := MembershipMgr.GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, ResponseMessage);

        if (not Membership.Get(MembershipEntryNo)) then;
        if (not MembershipSetup.Get(Membership."Membership Code")) then;
        if (not Member.Get(MembershipMgr.GetMemberFromExtMemberNo(ExternalMemberNo))) then
            Member."External Member No." := ExternalMemberNo;

        if ((ExternalMemberCardNo = '') and (Member."Entry No." <> 0)) then begin
            MemberCardEntryNo := MembershipMgr.GetMemberCardEntryNo(Member."Entry No.", Membership."Membership Code", Today);

            if ((MemberCardEntryNo <> 0) and MemberCard.Get(MemberCardEntryNo)) then
                ExternalMemberCardNo := MemberCard."External Card No.";
        end;

        if (MembershipEntryNo = 0) then begin
            ResponseMessage := StrSubstNo(ExternalMemberNotFoundLbl, ExternalMemberNo);
            MemberLimitationMgr.LogMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1);
            exit(-1);
        end;
        if (not MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate(), true)) then begin
            ResponseMessage := StrSubstNo(MembershipNotActiveLbl, Format(WorkDate(), 0, 9));
            MemberLimitationMgr.LogMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1);
            exit(-1);
        end;

        ResponseCode := 0;
        ResponseMessage := '';

        LimitLogEntry := 0;
        MemberLimitationMgr.WS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, LimitLogEntry, ResponseMessage, ResponseCode);
        if (ResponseCode <> 0) then
            exit(ResponseCode);

        commit();

        if (MembershipSetup."Ticket Item Barcode" = '') then
            exit(0);

        AttemptArrival.AttemptMemberArrival(MembershipSetup."Ticket Item Barcode", AdmissionCode, ScannerStationId, Member, MembershipEntryNo);
        if (AttemptArrival.Run()) then;
        ResponseCode := AttemptArrival.GetAttemptMemberArrivalResponse(ResponseMessage);

        MemberLimitationMgr.UpdateLogEntry(LimitLogEntry, ResponseCode, ResponseMessage);

        Commit();
        exit(ResponseCode);

    end;


    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        FileNameLbl: Label '%1-%2.xml', Locked = true;
    begin
        ImportEntry.Init();
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Member WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            MemberIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Member WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo(FileNameLbl, ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure MemberIntegrationSetup()
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetFilter("Webservice Codeunit ID", '=%1', CODEUNIT::"NPR MM Member WebService");
        if (not ImportType.IsEmpty()) then
            ImportType.DeleteAll();

        CreateImportType('MEMBER-01', 'MemberManagement', 'CreateMembership');
        CreateImportType('MEMBER-02', 'MemberManagement', 'AddMembershipMember');
        CreateImportType('MEMBER-03', 'MemberManagement', 'GetMembership');
        CreateImportType('MEMBER-04', 'MemberManagement', 'GetMembershipMembers');
        CreateImportType('MEMBER-05', 'MemberManagement', 'UpdateMember');
        CreateImportType('MEMBER-06', 'MemberManagement', 'BlockMembership');
        CreateImportType('MEMBER-07', 'MemberManagement', 'GetMembershipTicketList');
        CreateImportType('MEMBER-08', 'MemberManagement', 'ChangeMembership');
        CreateImportType('MEMBER-09', 'MemberManagement', 'GetMembershipChangeItemsList');
        CreateImportType('MEMBER-10', 'MemberManagement', 'AddAnonymousMember');
        CreateImportType('MEMBER-11', 'MemberManagement', 'ConfirmMembershipPayment');
        CreateImportType('MEMBER-12', 'MemberManagement', 'RegretMembership');
        CreateImportType('MEMBER-13', 'MemberManagement', 'GetMembershipAutoRenewProduct');
        CreateImportType('MEMBER-14', 'MemberManagement', 'ConfirmAutoRenewPayment');
        CreateImportType('MEMBER-15', 'MemberManagement', 'SetGDPRApproval');
        CreateImportType('MEMBER-16', 'MemberManagement', 'CreateWalletMemberPass');
        CreateImportType('MEMBER-17', 'MemberManagement', 'GetMembershipRoles');
        CreateImportType('MEMBER-18', 'MemberManagement', 'GetSetAutoRenewOption');
        CreateImportType('MEMBER-19', 'MemberManagement', 'GetSetMemberComOption');
        CreateImportType('MEMBER-20', 'MemberManagement', 'BlockMember');

        Commit();
    end;

    local procedure CreateImportType("Code": Code[20]; Description: Text[30]; FunctionName: Text[30])
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"NPR MM Member WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"NPR MM Member WebService";

        ImportType.Insert();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[20]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if (ImportType.FindFirst()) then
            exit(ImportType.Code);

        exit('');
    end;
#pragma warning disable AA0139
    local procedure CreateDocumentId(): Text[50]
    begin
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
    end;
#pragma warning restore
}

