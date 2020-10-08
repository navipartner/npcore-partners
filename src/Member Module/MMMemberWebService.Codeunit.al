codeunit 6060128 "NPR MM Member WebService"
{

    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1.';
        NEW_MEMBER_TICKET: Label 'Ticket %1 for admission %2 was created for member %3.';
        MEMBER_TICKET: Label 'Ticket %1 for admission %2 was reused for member %3.';

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

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtCardNo(ExternalMemberCardNo, WorkDate, NotFoundReasonText);
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

    procedure MemberCardRegisterArrival(ExternalMemberCardNo: Code[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var MessageText: Text) IsRegistered: Boolean
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
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        Membership.Import();

        InsertImportEntry('GetMembershipTicketList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetMembershipTicketList-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
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
        Membership.Export;

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
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        Membership.Import();

        InsertImportEntry('GetMembershipChangeItemsList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetMembershipChangeItemsList-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
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

            MemberInfoCapture.DeleteAll();
        end else begin
            Membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure ActivateMembership(ExternalMembershipNo: Code[20]; ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMembershipNo(ExternalMembershipNo);
        exit(MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate, true));
    end;

    local procedure "--"()
    begin
    end;

    procedure CreateMembership(var membership: XMLport "NPR MM Create Membership"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        membership.Import();

        InsertImportEntry('CreateMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('CreateMembership-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
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

    procedure AddMembershipMember(var member: XMLport "NPR MM Add Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        member.Import();

        InsertImportEntry('AddMembershipMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('AddMembershipMember-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
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

            MemberInfoCapture.DeleteAll();
        end else begin
            member.AddErrorResponse(ImportEntry."Error Message");
        end;

        Commit();
    end;

    procedure AddAnonymousMember(var AnonymousMember: XMLport "NPR MM Anonymous Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        AnonymousMember.Import();

        InsertImportEntry('AddAnonymousMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('AddAnonymousMember-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        AnonymousMember.SetDestination(OutStr);
        AnonymousMember.Export;
        Commit();

        ImportEntry.Modify(true);
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
    begin

        membership.Import();

        InsertImportEntry('ChangeMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('ChangeMembership-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
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
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        membership.Import();

        InsertImportEntry('GetMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetMembership-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
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

            MemberInfoCapture.DeleteAll();
        end else begin
            membership.AddErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure GetMembershipMembers(var member: XMLport "NPR MM Get Members. Members"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        member.Import();

        InsertImportEntry('GetMembershipMembers', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetMembershipMembers-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
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
        member.Export;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure UpdateMember(var member: XMLport "NPR MM Update Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        member.Import();

        InsertImportEntry('UpdateMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('UpdateMember-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
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
    begin

        member.Import();

        InsertImportEntry('BlockMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('BlockMembership-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
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
        member.Export;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure BlockMember(var member: XMLport "NPR MM Block Membership Member"; ScannerStationId: Code[10])
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        member.Import();

        InsertImportEntry('BlockMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('BlockMember-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
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
        member.Export;
        ImportEntry.Modify(true);

        Commit();

    end;

    procedure GetMembershipRoles(var roles: XMLport "NPR MM Get Member GDPR Roles")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        roles.Import();

        InsertImportEntry('GetMembershipRoles', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetMembershipRoles-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        roles.SetDestination(OutStr);
        roles.Export;
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
    begin

        gdpr.Import();

        InsertImportEntry('SetGDPRApproval', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('SetGDPRApproval-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        gdpr.SetDestination(OutStr);
        gdpr.Export;
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
    begin

        ConfirmMembershipPayment.Import();

        InsertImportEntry('ConfirmMembershipPayment', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('ConfirmMembershipPayment-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ConfirmMembershipPayment.SetDestination(OutStr);
        ConfirmMembershipPayment.Export;
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
        ConfirmMembershipPayment.Export;
        ImportEntry.Modify(true);

        Commit();

    end;

    procedure RegretMembershipTimeframe(var Membership: XMLport "NPR MM Regret Member Timeframe")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        Membership.Import();

        InsertImportEntry('RegretMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('RegretMembership-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
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
                    EntryNo := MemberNotification.CreateWalletSendNotification(MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.");
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
    begin

        CreateMemberPass.Import();

        InsertImportEntry('CreateWalletMemberPass', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('CreateWalletMemberPass-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        CreateMemberPass.SetDestination(OutStr);
        CreateMemberPass.Export;
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
    begin

        if (StrLen(Token) <> MaxStrLen(MembershipRole."Notification Token")) then
            exit;

        MembershipRole.SetFilter("Notification Token", '=%1', Token);
        if (not MembershipRole.FindFirst()) then
            exit;

        MembershipRole."Notification Token" := StrSubstNo('Token Expired at %1 %2', Today, Time);
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
        TmpMemberCommunication: Record "NPR MM Member Communication" temporary;
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        ExternalMemberNo: Code[20];
        ExternalMembershipNo: Code[20];
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin

        GetSetMemberComOptions.Import();

        InsertImportEntry('GetSetMemberComOption', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetSetMemberComOption-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetMemberComOptions.SetDestination(OutStr);
        GetSetMemberComOptions.Export;
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            GetSetMemberComOptions.GetRequest(ExternalMemberNo, ExternalMembershipNo, TmpMemberCommunication);

            MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo(ExternalMemberNo);
            MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo(ExternalMembershipNo);

            if (MemberEntryNo = 0) or (MembershipEntryNo = 0) then begin
                ResponseMessage := StrSubstNo('Member number "%1" or Membership number "%2" is invalid.', ExternalMemberNo, ExternalMembershipNo);
                GetSetMemberComOptions.SetErrorResponse(ResponseMessage);

            end else begin
                TmpMemberCommunication.Reset();

                MembershipManagement.CreateMemberCommunicationDefaultSetup(MemberEntryNo);

                if (TmpMemberCommunication.FindSet()) then begin
                    repeat
                        if (MemberCommunication.Get(MemberEntryNo, MembershipEntryNo, TmpMemberCommunication."Message Type")) then begin
                            MemberCommunication.TransferFields(TmpMemberCommunication, false);
                            MemberCommunication."Changed At" := CurrentDateTime();
                            MemberCommunication.Modify();
                        end;
                    until (TmpMemberCommunication.Next() = 0);

                    if (TmpMemberCommunication.IsTemporary()) then
                        TmpMemberCommunication.DeleteAll();
                end;

                MemberCommunication.Reset();
                MemberCommunication.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
                MemberCommunication.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                if (MemberCommunication.FindSet()) then begin
                    repeat
                        TmpMemberCommunication.TransferFields(MemberCommunication, true);
                        TmpMemberCommunication.Insert();
                    until (MemberCommunication.Next() = 0);
                end;

                GetSetMemberComOptions.SetResponse(ExternalMemberNo, ExternalMembershipNo, TmpMemberCommunication);

            end;
        end else begin
            GetSetMemberComOptions.SetErrorResponse(ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetMemberComOptions.SetDestination(OutStr);
        GetSetMemberComOptions.Export;
        ImportEntry.Modify(true);

        Commit();

    end;

    local procedure "--RecuringPayment"()
    begin
    end;

    procedure GetAutoRenewProduct(var Membership: XMLport "NPR MM Get AutoRenew Product")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        Membership.Import();

        InsertImportEntry('GetMembershipAutoRenewProduct', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetMembershipAutoRenewProduct-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
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
        Membership.Export;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure ConfirmAutoRenewPayment(var Membership: XMLport "NPR MM Confirm AutoRenew Pay.")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        Membership.Import();

        InsertImportEntry('ConfirmAutoRenewPayment', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('ConfirmAutoRenewPayment-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
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
        Membership.Export;
        ImportEntry.Modify(true);

        Commit();
    end;

    procedure GetSetAutoRenew(var GetSetAutoRenew: XMLport "NPR MM GetSet AutoRenew Option")
    var
        ImportEntry: Record "NPR Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "NPR Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipEntryNo: Integer;
    begin

        GetSetAutoRenew.Import();

        InsertImportEntry('GetSetAutoRenewOption', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo('GetSetAutoRenewOption-%1.xml', Format(CurrentDateTime(), 0, 9));
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid), '=', '{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetAutoRenew.SetDestination(OutStr);
        GetSetAutoRenew.Export;
        ImportEntry.Modify(true);
        Commit();

        if (NaviConnectSyncMgt.ProcessImportEntry(ImportEntry)) then begin

            GetSetAutoRenew.createResponse();

        end else begin
            GetSetAutoRenew.setError('Not processed.');

        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetAutoRenew.SetDestination(OutStr);
        GetSetAutoRenew.Export;
        ImportEntry.Modify(true);

        Commit();

    end;

    local procedure "--Helper WS"()
    begin
    end;

    procedure ResolveMemberIdentifier(var MemberIdentifier: XMLport "NPR MM Member Identifier")
    begin

        MemberIdentifier.Import();
        MemberIdentifier.CreateResult();

    end;

    local procedure "--Locals"()
    begin
    end;

    local procedure IsMembershipValid(MembershipEntryNo: Integer) IsValid: Boolean
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
    begin

        if (MembershipEntryNo = 0) then
            exit(false);

        IsValid := MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate, false);
        if (not IsValid) then
            IsValid := MembershipMgr.MembershipNeedsActivation(MembershipEntryNo);

        exit(IsValid);
    end;

    local procedure ValidateMemberAndRegisterArrival(ExternalMemberNo: Code[20]; ExternalMemberCardNo: Text[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; var ResponseMessage: Text) Success: Integer
    var
        MembershipMgr: Codeunit "NPR MM Membership Mgt.";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        MemberLimitationMgr: Codeunit "NPR MM Member Lim. Mgr.";
        MembershipEntryNo: Integer;
        MemberCardEntryNo: Integer;
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        LimitLogEntry: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMemberNo(ExternalMemberNo);

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
            ResponseMessage := StrSubstNo('External Member Number %1, not found.', ExternalMemberNo);
            MemberLimitationMgr.LogMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1); //MM1.21 [284653]
            exit(-1);
        end;
        if (not MembershipMgr.IsMembershipActive(MembershipEntryNo, WorkDate, true)) then begin
            ResponseMessage := StrSubstNo('Membership is not active for today (%1).', Format(WorkDate, 0, 9));
            MemberLimitationMgr.LogMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1); //MM1.21 [284653]
            exit(-1);
        end;

        Success := 0;
        ResponseMessage := '';

        LimitLogEntry := 0;
        MemberLimitationMgr.WS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, LimitLogEntry, ResponseMessage, Success); //MM1.21 [284653]
        if (Success <> 0) then
            exit(Success);

        if (MembershipSetup."Ticket Item Barcode" <> '') then begin

            // TicketRequestManager.LockResources ();
            Success := IssueMemberTicketAndRegisterArrival(MembershipSetup."Ticket Item Barcode", AdmissionCode, ScannerStationId, Member, ResponseMessage);

            // MemberLimitationMgr.WS_CheckLimitMemberCardArrival (ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, Success); //MM1.21 [284653]
            // EXIT (Success);

        end;

        MemberLimitationMgr.WS_CheckLimitMemberCardArrival(ExternalMemberCardNo, AdmissionCode, ScannerStationId, LimitLogEntry, ResponseMessage, Success); //MM1.21 [284653]
        exit(Success);
    end;

    local procedure IssueMemberTicketAndRegisterArrival(TicketItemNo: Code[50]; AdmissionCode: Code[20]; ScannerStationId: Code[10]; Member: Record "NPR MM Member"; var ResponseMessage: Text) Success: Integer
    var
        TicketMgr: Codeunit "NPR TM Ticket Management";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TicketNo: Code[20];
        Ticket: Record "NPR TM Ticket";
        ResponseCode: Integer;
        Token: Text[100];
    begin

        if not (MemberRetailIntegration.TranslateBarcodeToItemVariant(TicketItemNo, ItemNo, VariantCode, ResolvingTable)) then begin
            ResponseMessage := StrSubstNo('%1 does not translate to an item. Check Item Cross-Reference or Item table.', TicketItemNo);
            exit(-1);
        end;

        Ticket.SetCurrentKey("External Member Card No.");
        Ticket.SetFilter("Item No.", '=%1', ItemNo);
        Ticket.SetFilter("Variant Code", '=%1', VariantCode);
        Ticket.SetFilter("Document Date", '=%', Today);

        Ticket.SetFilter("External Member Card No.", '=%1', Member."External Member No.");
        if (Ticket.FindLast()) then begin
            // IF (Ticket."Document Date" = TODAY) THEN BEGIN
            ResponseCode := TicketMgr.ValidateTicketForArrival(0, Ticket."No.", AdmissionCode, -1, false, ResponseMessage);
            if (ResponseCode = 0) then begin

                if (AdmissionCode = '') then
                    AdmissionCode := '-default-';

                ResponseMessage := StrSubstNo(MEMBER_TICKET, Ticket."No.", AdmissionCode, Member."External Member No.");

                exit(ResponseCode);
            end;
            // END;
        end;

        //ResponseCode := MemberRetailIntegration.IssueTicketFromMemberScan (FALSE, ItemNo, VariantCode, Member, TicketNo, ResponseMessage);
        //IF (ResponseCode <> 0) THEN
        //  EXIT (ResponseCode);
        Commit();
        if (not TicketMakeReservation(TicketItemNo, AdmissionCode, Member."External Member No.", ScannerStationId, Token, ResponseMessage)) then
            exit(-1);

        Commit();

        if not (TicketConfirmReservation(Token, ScannerStationId, TicketNo, ResponseMessage)) then
            exit(-1);

        Commit();

        Ticket.Get(TicketNo);
        Success := TicketMgr.ValidateTicketForArrival(0, TicketNo, AdmissionCode, -1, false, ResponseMessage);

        if (Success = 0) then begin
            if (AdmissionCode = '') then
                AdmissionCode := '-default-';
            ResponseMessage := StrSubstNo(NEW_MEMBER_TICKET, TicketNo, AdmissionCode, Member."External Member No.");
        end;

        exit(Success);
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text; var ImportEntry: Record "NPR Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "NPR Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Member WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
            MemberIntegrationSetup();
            ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"NPR MM Member WebService", WebserviceFunction);
            if (ImportEntry."Import Type" = '') then
                Error(SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date, 0, 9));
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

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer; WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "NPR Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID", WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function", '%1', CopyStr(WebserviceFunction, 1, MaxStrLen(ImportType."Webservice Function")));

        if ImportType.FindFirst then
            exit(ImportType.Code);

        exit('');
    end;

    local procedure "--Utils"()
    begin
    end;

    local procedure "--TicketAPI"()
    begin
    end;

    local procedure TicketMakeReservation(ExternalItemNumber: Code[20]; AdmissionCode: Code[20]; MemberReference: Code[20]; ScannerStation: Code[20]; var Token: Text[100]; var ResponseMessage: Text) ReservationStatus: Boolean
    var
        xmltext: Text;
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TicketReservation: XMLport "NPR TM Ticket Reservation";
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        txtRead: Text;
    begin

        xmltext :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<tickets xmlns="urn:microsoft-dynamics-nav/xmlports/x6060114">' +
        '   <reserve_tickets token="">' +
        StrSubstNo('       <ticket external_id="%1" line_no="1" qty="1" admission_schedule_entry="0" member_number="%2" admission_code="%3"/>', ExternalItemNumber, MemberReference, AdmissionCode) +
        '   </reserve_tickets>' +
        '</tickets>';

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(xmltext);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(iStream);
        TicketReservation.SetSource(iStream);
        TicketReservation.Import();

        TicketWebService.MakeTicketReservation(TicketReservation, ScannerStation);

        ReservationStatus := TicketReservation.GetResult(Token, ResponseMessage);

        exit(ReservationStatus);

    end;

    local procedure TicketConfirmReservation(Token: Text[100]; ScannerStation: Code[20]; var TicketNumber: Code[20]; var ResponseMessage: Text) ConfirmationStatus: Boolean
    var
        xmltext: Text;
        TmpBLOBbuffer: Record "NPR BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TicketWebService: Codeunit "NPR TM Ticket WebService";
        TicketConfirmation: XMLport "NPR TM Ticket Confirmation";
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        Ticket: Record "NPR TM Ticket";
    begin

        xmltext :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>' +
        '<tickets xmlns="urn:microsoft-dynamics-nav/xmlports/x6060117">' +
        '  <ticket_tokens>' +
        StrSubstNo('      <ticket_token>%1</ticket_token>', Token) +
        '      <send_notification_to></send_notification_to>' +
        '      <external_order_no>prepaid</external_order_no>' +
        '  </ticket_tokens>' +
        '</tickets>';

        TmpBLOBbuffer.Insert();
        TmpBLOBbuffer."Buffer 1".CreateOutStream(oStream);
        oStream.WriteText(xmltext);
        TmpBLOBbuffer.Modify();

        TmpBLOBbuffer."Buffer 1".CreateInStream(iStream);
        TicketConfirmation.SetSource(iStream);
        TicketConfirmation.Import();

        ConfirmationStatus := TicketWebService.ConfirmTicketReservation(TicketConfirmation, ScannerStation);

        ResponseMessage := 'There was a problem with Confirm Ticket Reservation.';
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationResponse.FindFirst()) then begin

            if (TicketReservationResponse.Confirmed) then begin
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationResponse."Request Entry No.");
                if (Ticket.FindFirst()) then
                    TicketNumber := Ticket."No.";
                ResponseMessage := '';
                ConfirmationStatus := true;
            end else begin
                ResponseMessage := TicketReservationResponse."Response Message";
                ConfirmationStatus := false;
            end;
        end;

        exit(ConfirmationStatus);

    end;
}

