codeunit 6060128 "MM Member WebService"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.02/TSA/20151228  CASE 229684 Touch-up and enchancements
    // MM1.03/TSA/20160107  CASE 231199 Filter by member only of member is used in search
    // MM1.06/TSA/20160122  CASE 232674 Added webservice
    // MM1.06/TSA/20160125  CASE 232910 Blocking memberships (and member account, card)
    // MM1.08/TSA/20160219  CASE 232494 Slight refactor of the single member ticket create function to 2 separate functions
    // MM1.08/TSA/20160219  CASE 232494 Added function for GetMembershipTicketList, IssueAndValidateMemberTicketBatch
    // MM1.09/TSA/20160229  CASE 235805 Changed to Ticket Reservation handling in IssueTicket function
    // MM1.11/TSA/20160427  CASE 239052 added ChangeMembership service
    // MM1.14.01/MHA/20160726  CASE 242557 Magento reference updated according to NC2.00
    // MM1.16/TSA/20160913  CASE 252216 Signature change on search function
    // MM1.17/TSA/20161208  CASE 259671 Extended functionality for handling the start date of membership, signature change on IsMembershipActive
    // MM1.17/TSA/20161208  CASE 259671 Changed member validation to accept unactivated memberships to be valid (but not activated)
    // MM1.17/TSA/20161208  CASE 259671 Added Service ActivateMembership to explicitly activate a membership. Activation also occur on first use.
    // MM1.17/TSA/20161208  CASE 259671 Relocated function TranslateBarcodeToItemVariant to codeunit MM Member Retail Integration
    // MM1.19/TSA/20170328  CASE 270627 Changed response message to contain ticket information on success
    // MM1.19/MMV /20170407 CASE 271789 Only delete filtered member capture records.
    // MM1.19/TSA/20170419  CASE 272422 ResolveIdentifiers SOAP Action
    // MM1.19/TSA/20170524  CASE GetMembershipTicketList message is always marked as success.
    // MM1.21/TSA /20170720 CASE 284653 Implementing Member Card scan Limits
    // MM1.22/TSA /20170823 CASE 287080 Added SOAP Action AddAnonymousMember()
    // MM1.23/TSA /20171002 CASE 257011 Made a hard check on membershipentry being 0
    // MM1.24/TSA /20171120 CASE 296437 Refactoring to get the first membercard number when only member is provided
    // MM1.24/TSA /20171206 CASE 290599 Added ConfirmMembershipPayment service
    // MM1.24/TSA /20171206 CASE 290599 Cleaned out old comments
    // MM1.25/TSA /20180118 CASE 300256 Signature change
    // MM1.26/TSA /20180209 CASE 304982 Missing filter
    // MM1.26/TSA /20180219 CASE 305631 Added RegretMembershipTimeframe service
    // MM1.26/TSA /20180219 CASE 305685 Added PrintMemberCard() service
    // MM1.28/TSA /20180417 CASE 303635 (Adyen) Autorenew services
    // MM1.29/TSA /20180517 CASE 313795 Set GDPR Approval service
    // MM1.32/TSA /20180711 CASE 318132 Added PrintMemberCard option 3 - Wallet / NP Pass
    // MM1.32/TSA /20180723 CASE 316468 Fixed a filtering issue for reusing tickets on member scan
    // MM1.33/TSA /20180801 CASE 326756 Refactored IssueMemberTicketAndRegisterArrival() to use ticket API instead
    // MM1.34/TSA /20180827 CASE 325803 Removed ResolveIdentifiers(), added ResolveMemberIdentifier()
    // MM1.34/TSA /20180913 CASE 328141 Adding SOAP Action to sent the membercard as wallet pass
    // MM1.35/TSA /20181023 CASE 333592 Added GetMembershipRoles()
    // MM1.35/TSA /20181024 CASE 328141 Removed the dedicated SOAP Action, since it is same as option 3 in PrintMemberCard()
    // MM1.36/TSA /20190110 CASE 328141 Added CreateWalletMemberPass()
    // MM1.38/TSA /20190517 CASE 355234 Added ValidateNotificationToken(), ExpireNotificationToken(), GenerateNotificationToken()
    // MM1.39/TSA /20190529 CASE 350968 Added GetSetAutoRenew
    // MM1.42/TSA /20191231 CASE 382728 Added GetSetMemberCommunication service


    trigger OnRun()
    begin
    end;

    var
        SETUP_MISSING: Label 'Setup is missing for %1.';
        NEW_MEMBER_TICKET: Label 'Ticket %1 for admission %2 was created for member %3.';
        MEMBER_TICKET: Label 'Ticket %1 for admission %2 was reused for member %3.';

    [Scope('Personalization')]
    procedure MemberValidation(ExternalMemberNo: Code[20];ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMemberNo (ExternalMemberNo);
        exit (IsMembershipValid (MembershipEntryNo));
    end;

    [Scope('Personalization')]
    procedure MembershipValidation(ExternalMembershipNo: Code[20];ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMembershipNo (ExternalMembershipNo);
        exit (IsMembershipValid (MembershipEntryNo));
    end;

    [Scope('Personalization')]
    procedure MemberEmailExists(EmailToCheck: Text[100]) EmailExists: Boolean
    var
        Member: Record "MM Member";
    begin

        Member.SetFilter ("E-Mail Address", '=%1', LowerCase (EmailToCheck));
        Member.SetFilter (Blocked, '=%1', false);
        exit (Member.FindFirst ());
    end;

    [Scope('Personalization')]
    procedure MemberCardNumberValidation(ExternalMemberCardNo: Text[50];ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
        NotFoundReasonText: Text;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtCardNo (ExternalMemberCardNo, WorkDate, NotFoundReasonText);
        exit (IsMembershipValid (MembershipEntryNo));
    end;

    [Scope('Personalization')]
    procedure MemberRegisterArrival(ExternalMemberNo: Code[20];AdmissionCode: Code[20];ScannerStationId: Code[10];var MessageText: Text) IsRegistered: Boolean
    var
        Success: Integer;
    begin

        MessageText := '';
        Success := ValidateMemberAndRegisterArrival (ExternalMemberNo, '', AdmissionCode, ScannerStationId, MessageText);
        exit (Success = 0);
    end;

    [Scope('Personalization')]
    procedure MemberCardRegisterArrival(ExternalMemberCardNo: Code[50];AdmissionCode: Code[20];ScannerStationId: Code[10];var MessageText: Text) IsRegistered: Boolean
    var
        Member: Record "MM Member";
        MembershipMgr: Codeunit "MM Membership Management";
        MemberEntryNo: Integer;
        Success: Integer;
    begin

        MessageText := '';
        MemberEntryNo := MembershipMgr.GetMemberFromExtCardNo (ExternalMemberCardNo, Today, MessageText);
        if (MemberEntryNo = 0) then begin
          exit (false);
        end;

        Member.Get (MemberEntryNo);

        Success := ValidateMemberAndRegisterArrival (Member."External Member No.", ExternalMemberCardNo, AdmissionCode, ScannerStationId, MessageText);
        exit (Success = 0);
    end;

    [Scope('Personalization')]
    procedure GetMembershipTicketList(var Membership: XMLport "MM Get Membership Ticket List";AdmissionCode: Code[20];ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        Membership.Import ();

        InsertImportEntry ('GetMembershipTicketList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetMembershipTicketList-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          Membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            Membership.AddResponse (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", AdmissionCode);
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          Membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;

        ImportEntry.Imported := true;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Modify(true);

        Commit ();
    end;

    [Scope('Personalization')]
    procedure GetMembershipChangeItemsList(var Membership: XMLport "MM Get Membership Change Items")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        Membership.Import ();

        InsertImportEntry ('GetMembershipChangeItemsList', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetMembershipChangeItemsList-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          Membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            Membership.AddResponse (MemberInfoCapture."Membership Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();
        end else begin
          Membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);

        Commit ();
    end;

    [Scope('Personalization')]
    procedure ActivateMembership(ExternalMembershipNo: Code[20];ScannerStationId: Code[10]) IsValid: Boolean
    var
        MembershipMgr: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMembershipNo (ExternalMembershipNo);
        exit (MembershipMgr.IsMembershipActive (MembershipEntryNo, WorkDate, true));
    end;

    local procedure "--"()
    begin
    end;

    [Scope('Personalization')]
    procedure CreateMembership(var membership: XMLport "MM Create Membership";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        membership.Import ();

        InsertImportEntry ('CreateMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('CreateMembership-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            membership.AddResponse (MemberInfoCapture."Membership Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure AddMembershipMember(var member: XMLport "MM Add Member";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        member.Import ();

        InsertImportEntry ('AddMembershipMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('AddMembershipMember-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          member.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            member.AddResponse (MemberInfoCapture."Member Entry No");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();
        end else begin
          member.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure AddAnonymousMember(var AnonymousMember: XMLport "MM Anonymous Member";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        AnonymousMember.Import ();

        InsertImportEntry ('AddAnonymousMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('AddAnonymousMember-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        AnonymousMember.SetDestination(OutStr);
        AnonymousMember.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          AnonymousMember.ClearResponse ();
          AnonymousMember.AddResponse ();

          //-MM1.26 [304982]
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          //+MM1.26 [304982]

          MemberInfoCapture.DeleteAll ();

        end else begin
          AnonymousMember.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure ChangeMembership(var membership: XMLport "MM Change Membership")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        membership.Import ();

        InsertImportEntry ('ChangeMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('ChangeMembership-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            membership.AddResponse (MemberInfoCapture."Membership Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure GetMembership(var membership: XMLport "MM Get Membership";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        membership.Import ();

        InsertImportEntry ('GetMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetMembership-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            membership.AddResponse (MemberInfoCapture."Membership Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();
        end else begin
          membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        membership.SetDestination(OutStr);
        membership.Export;
        ImportEntry.Modify(true);

        Commit ();
    end;

    [Scope('Personalization')]
    procedure GetMembershipMembers(var member: XMLport "MM Get Membership Members";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        member.Import ();

        InsertImportEntry ('GetMembershipMembers', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetMembershipMembers-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
        ImportEntry.Modify(true);

        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          member.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindFirst ();

          member.AddResponse (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Member No", MemberInfoCapture."External Card No.");

          MemberInfoCapture.DeleteAll ();
        end else begin
          member.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
        ImportEntry.Modify(true);

        Commit;
    end;

    [Scope('Personalization')]
    procedure UpdateMember(var member: XMLport "MM Update Member";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        member.Import ();

        InsertImportEntry ('UpdateMember', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('UpdateMember-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          member.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            member.AddResponse (MemberInfoCapture."Member Entry No");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();
        end else begin
          member.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure UpdateMemberImage(MemberExternalNo: Code[20];Base64StringImage: Text;ScannerStationId: Code[10]) Success: Boolean
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MemberEntryNo: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo (MemberExternalNo);
        Success := MembershipManagement.UpdateMemberImage (MemberEntryNo, Base64StringImage);

        exit (Success);
    end;

    [Scope('Personalization')]
    procedure GetMemberImage(MemberExternalNo: Code[20];var Base64StringImage: Text;ScannerStationId: Code[10]) Success: Boolean
    var
        MembershipManagement: Codeunit "MM Membership Management";
        MemberEntryNo: Integer;
    begin

        MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo (MemberExternalNo);
        Success := MembershipManagement.GetMemberImage (MemberEntryNo, Base64StringImage);

        exit (Success);
    end;

    [Scope('Personalization')]
    procedure BlockMembership(var member: XMLport "MM Block Membership";ScannerStationId: Code[10])
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        member.Import ();

        InsertImportEntry ('BlockMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('BlockMembershipMembers-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
        ImportEntry.Modify(true);

        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          member.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindFirst ();

          member.AddResponse (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Member No", MemberInfoCapture."External Card No.");

          MemberInfoCapture.DeleteAll ();
        end else begin
          member.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        member.SetDestination(OutStr);
        member.Export;
        ImportEntry.Modify(true);

        Commit;
    end;

    [Scope('Personalization')]
    procedure GetMembershipRoles(var roles: XMLport "MM Get Member GDPR Roles")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        //-MM1.35 [333592]�
        roles.Import ();

        InsertImportEntry ('GetMembershipRoles', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetMembershipRoles-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        roles.SetDestination(OutStr);
        roles.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          roles.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            roles.AddResponse (MemberInfoCapture."Member Entry No");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          roles.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
        //+MM1.35 [333592]
    end;

    [Scope('Personalization')]
    procedure GetSetGDPRApprovalState(var gdpr: XMLport "MM GDPR Get Set Approval State")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        gdpr.Import ();

        InsertImportEntry ('SetGDPRApproval', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('SetGDPRApproval-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        gdpr.SetDestination(OutStr);
        gdpr.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          gdpr.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            gdpr.AddResponse (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          gdpr.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure ConfirmMembershipPayment(var ConfirmMembershipPayment: XMLport "MM Confirm Membership Payment")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        //-MM1.24 [290599]
        ConfirmMembershipPayment.Import ();

        InsertImportEntry ('ConfirmMembershipPayment', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('ConfirmMembershipPayment-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ConfirmMembershipPayment.SetDestination(OutStr);
        ConfirmMembershipPayment.Export;
        ImportEntry.Modify(true);

        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          ConfirmMembershipPayment.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindFirst ();

          ConfirmMembershipPayment.AddResponse (MemberInfoCapture."Membership Entry No.");

          MemberInfoCapture.DeleteAll ();
        end else begin
          ConfirmMembershipPayment.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        ConfirmMembershipPayment.SetDestination(OutStr);
        ConfirmMembershipPayment.Export;
        ImportEntry.Modify(true);

        Commit;



        //+MM1.24 [290599]
    end;

    [Scope('Personalization')]
    procedure RegretMembershipTimeframe(var Membership: XMLport "MM Regret Membership Timeframe")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        Membership.Import ();

        InsertImportEntry ('RegretMembership', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('RegretMembership-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          Membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            Membership.AddResponse (MemberInfoCapture."Membership Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          Membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    [Scope('Personalization')]
    procedure PrintMemberCard(ExternalMemberCardNo: Code[50];PrintDirective: Integer): Boolean
    var
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MembershipManagement: Codeunit "MM Membership Management";
        MemberNotification: Codeunit "MM Member Notification";
        MemberCard: Record "MM Member Card";
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipNotification: Record "MM Membership Notification";
        EntryNo: Integer;
    begin

        //-MM1.26 [305685]
        MemberCard.SetFilter ("External Card No.", '=%1', ExternalMemberCardNo);
        if (not MemberCard.FindFirst ()) then
          exit (false);

        case PrintDirective of
          1 : MemberRetailIntegration.PrintMemberCard (MemberCard."Member Entry No.", MemberCard."Entry No.");
          2 : MembershipManagement.PrintOffline (MemberInfoCapture."Information Context"::PRINT_CARD, MemberCard."Entry No.");

          //-MM1.32 [318132]
          3 : begin
                EntryNo := MemberNotification.CreateWalletSendNotification (MemberCard."Membership Entry No.", MemberCard."Member Entry No.", MemberCard."Entry No.");
                if (MembershipNotification.Get (EntryNo)) then
                  if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                    MemberNotification.HandleMembershipNotification (MembershipNotification);
              end;
          //+MM1.32 [318132]

          else
            Error ('Print Directive 1: Print to Google printer, 2: Print to Offline Journal, 3: Wallet, print to NP Pass Server');
        end;

        exit (true);
        //+MM1.26 [305685]
    end;

    [Scope('Personalization')]
    procedure CreateWalletMemberPass(var CreateMemberPass: XMLport "MM Create Wallet Member Pass")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        CreateMemberPass.Import ();

        InsertImportEntry ('CreateWalletMemberPass', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('CreateWalletMemberPass-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        CreateMemberPass.SetDestination(OutStr);
        CreateMemberPass.Export;
        Commit ();

        ImportEntry.Modify(true);
        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          CreateMemberPass.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet ();
          repeat
            CreateMemberPass.AddResponse (MemberInfoCapture."Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.DeleteAll ();

        end else begin
          CreateMemberPass.AddErrorResponse (ImportEntry."Error Message");
        end;

        Commit ();
    end;

    procedure ValidateNotificationToken(Token: Text[64];var ExternalMembershipNumber: Code[20];var ExternalMemberNumber: Code[20]): Boolean
    var
        MembershipRole: Record "MM Membership Role";
    begin

        //-MM1.38 [355234]
        if (StrLen (Token) <> MaxStrLen (MembershipRole."Notification Token")) then
          exit (false);

        MembershipRole.SetFilter ("Notification Token", '=%1', Token);
        if (not MembershipRole.FindFirst ()) then
          exit (false);

        MembershipRole.CalcFields ("External Membership No.", "External Member No.");
        ExternalMembershipNumber := MembershipRole."External Membership No.";
        ExternalMemberNumber := MembershipRole."External Member No.";

        exit (true);
        //+MM1.38 [355234]
    end;

    procedure ExpireNotificationToken(Token: Text[64])
    var
        MembershipRole: Record "MM Membership Role";
    begin

        //-MM1.38 [355234]
        if (StrLen (Token) <> MaxStrLen (MembershipRole."Notification Token")) then
          exit;

        MembershipRole.SetFilter ("Notification Token", '=%1', Token);
        if (not MembershipRole.FindFirst ()) then
          exit;

        MembershipRole."Notification Token" := StrSubstNo ('Token Expired at %1 %2', Today, Time);
        MembershipRole.Modify ();
        //+MM1.38 [355234]
    end;

    procedure GenerateNotificationToken(ExternalMembershipNumber: Code[20];ExternalMemberNumber: Code[20];var Token: Text[64]): Boolean
    var
        MembershipRole: Record "MM Membership Role";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MemberNotification: Codeunit "MM Member Notification";
    begin

        //-MM1.38 [355234]
        Membership.SetFilter ("External Membership No.", '=%1', ExternalMembershipNumber);
        if (not Membership.FindFirst ()) then
          exit (false);

        Member.SetFilter ("External Member No.", '=%1', ExternalMemberNumber);
        if (not Member.FindFirst ()) then
          exit (false);

        if (not MembershipRole.Get (Membership."Entry No.", Member."Entry No.")) then
          exit (false);

        Token := MemberNotification.GenerateNotificationToken ();
        MembershipRole."Notification Token" := Token;

        exit (MembershipRole.Modify ());
        //+MM1.38 [355234]
    end;

    procedure GetSetComOptions(var GetSetMemberComOptions: XMLport "MM Member Communication")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberCommunication: Record "MM Member Communication";
        TmpMemberCommunication: Record "MM Member Communication" temporary;
        MembershipManagement: Codeunit "MM Membership Management";
        ExternalMemberNo: Code[20];
        ExternalMembershipNo: Code[20];
        MemberEntryNo: Integer;
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
    begin

        //-MM1.42 [382728]

        GetSetMemberComOptions.Import ();

        InsertImportEntry ('GetSetMemberComOption', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetSetMemberComOption-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetMemberComOptions.SetDestination(OutStr);
        GetSetMemberComOptions.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          GetSetMemberComOptions.GetRequest (ExternalMemberNo, ExternalMembershipNo, TmpMemberCommunication);

          MemberEntryNo := MembershipManagement.GetMemberFromExtMemberNo (ExternalMemberNo);
          MembershipEntryNo := MembershipManagement.GetMembershipFromExtMembershipNo (ExternalMembershipNo);

          if (MemberEntryNo = 0) or (MembershipEntryNo = 0) then begin
            ResponseMessage := StrSubstNo ('Member number "%1" or Membership number "%2" is invalid.', ExternalMemberNo, ExternalMembershipNo);
            GetSetMemberComOptions.SetErrorResponse (ResponseMessage);

          end else begin
            TmpMemberCommunication.Reset ();

            MembershipManagement.CreateMemberCommunicationDefaultSetup (MemberEntryNo);

            if (TmpMemberCommunication.FindSet ()) then begin
              repeat
                if (MemberCommunication.Get (MemberEntryNo, MembershipEntryNo, TmpMemberCommunication."Message Type")) then begin
                  MemberCommunication.TransferFields (TmpMemberCommunication, false);
                  MemberCommunication."Changed At" := CurrentDateTime ();
                  MemberCommunication.Modify ();
                end;
              until (TmpMemberCommunication.Next () = 0);

              if (TmpMemberCommunication.IsTemporary ()) then
                TmpMemberCommunication.DeleteAll ();
            end;

            MemberCommunication.Reset ();
            MemberCommunication.SetFilter ("Member Entry No.", '=%1', MemberEntryNo);
            MemberCommunication.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
            if (MemberCommunication.FindSet ()) then begin
              repeat
                TmpMemberCommunication.TransferFields (MemberCommunication, true);
                TmpMemberCommunication.Insert ();
              until (MemberCommunication.Next () = 0);
            end;

            GetSetMemberComOptions.SetResponse (ExternalMemberNo, ExternalMembershipNo, TmpMemberCommunication);

          end;
        end else begin
          GetSetMemberComOptions.SetErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetMemberComOptions.SetDestination(OutStr);
        GetSetMemberComOptions.Export;
        ImportEntry.Modify(true);

        Commit ();
        //+MM1.42 [382728]
    end;

    local procedure "--RecuringPayment"()
    begin
    end;

    [Scope('Personalization')]
    procedure GetAutoRenewProduct(var Membership: XMLport "MM Get AutoRenew Product")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        Membership.Import ();

        InsertImportEntry ('GetMembershipAutoRenewProduct', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetMembershipAutoRenewProduct-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          Membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            Membership.AddResponse (MemberInfoCapture."Membership Entry No.");
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.Delete ();
        end else begin
          Membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);

        Commit ();
    end;

    [Scope('Personalization')]
    procedure ConfirmAutoRenewPayment(var Membership: XMLport "MM Confirm AutoRenew Payment")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        Membership.Import ();

        InsertImportEntry ('ConfirmAutoRenewPayment', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('ConfirmAutoRenewPayment-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin
          Membership.ClearResponse ();
          MemberInfoCapture.SetCurrentKey ("Import Entry Document ID");
          MemberInfoCapture.SetFilter ("Import Entry Document ID", '=%1', ImportEntry."Document ID");
          MemberInfoCapture.FindSet (true);
          repeat
            Membership.AddResponse (MemberInfoCapture);
          until (MemberInfoCapture.Next () = 0);

          MemberInfoCapture.Delete ();
        end else begin
          Membership.AddErrorResponse (ImportEntry."Error Message");
        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        Membership.SetDestination(OutStr);
        Membership.Export;
        ImportEntry.Modify(true);

        Commit ();
    end;

    procedure GetSetAutoRenew(var GetSetAutoRenew: XMLport "MM GetSet AutoRenew Option")
    var
        ImportEntry: Record "Nc Import Entry";
        NaviConnectSyncMgt: Codeunit "Nc Sync. Mgt.";
        OutStr: OutStream;
        MemberInfoCapture: Record "MM Member Info Capture";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipManagement: Codeunit "MM Membership Management";
        MembershipEntryNo: Integer;
    begin

        //-MM1.39 [350968]
        GetSetAutoRenew.Import ();

        InsertImportEntry ('GetSetAutoRenewOption', ImportEntry);
        ImportEntry."Document Name" := StrSubstNo ('GetSetAutoRenewOption-%1.xml', Format (CurrentDateTime(), 0, 9) );
        ImportEntry."Document ID" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetAutoRenew.SetDestination(OutStr);
        GetSetAutoRenew.Export;
        ImportEntry.Modify(true);
        Commit ();

        if (NaviConnectSyncMgt.ProcessImportEntry (ImportEntry)) then begin

          GetSetAutoRenew.createResponse ();

        end else begin
          GetSetAutoRenew.setError ('Not processed.');

        end;

        ImportEntry."Document Source".CreateOutStream(OutStr);
        GetSetAutoRenew.SetDestination(OutStr);
        GetSetAutoRenew.Export;
        ImportEntry.Modify(true);

        Commit ();
        //+MM1.39 [350968]
    end;

    local procedure "--Helper WS"()
    begin
    end;

    [Scope('Personalization')]
    procedure ResolveMemberIdentifier(var MemberIdentifier: XMLport "MM Member Identifier")
    begin

        //-MM1.34 [325803]
        MemberIdentifier.Import ();
        MemberIdentifier.CreateResult ();
        //+MM1.34 [325803]
    end;

    local procedure "--Locals"()
    begin
    end;

    local procedure IsMembershipValid(MembershipEntryNo: Integer) IsValid: Boolean
    var
        MembershipMgr: Codeunit "MM Membership Management";
    begin

        //-#292221 [292221]
        if (MembershipEntryNo = 0) then
          exit (false);
        //+#292221 [292221]

        IsValid := MembershipMgr.IsMembershipActive (MembershipEntryNo, WorkDate, false);
        if (not IsValid) then
          IsValid := MembershipMgr.MembershipNeedsActivation (MembershipEntryNo);

        exit (IsValid);
    end;

    local procedure ValidateMemberAndRegisterArrival(ExternalMemberNo: Code[20];ExternalMemberCardNo: Text[50];AdmissionCode: Code[20];ScannerStationId: Code[10];var ResponseMessage: Text) Success: Integer
    var
        MembershipMgr: Codeunit "MM Membership Management";
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        MemberLimitationMgr: Codeunit "MM Member Limitation Mgr.";
        MembershipEntryNo: Integer;
        MemberCardEntryNo: Integer;
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
    begin

        MembershipEntryNo := MembershipMgr.GetMembershipFromExtMemberNo (ExternalMemberNo);

        //-MM1.24 [296437]
        if (not Membership.Get (MembershipEntryNo)) then ;
        if (not MembershipSetup.Get (Membership."Membership Code")) then ;
        if (not Member.Get (MembershipMgr.GetMemberFromExtMemberNo (ExternalMemberNo))) then
          Member."External Member No." := ExternalMemberNo;

        if ((ExternalMemberCardNo = '') and (Member."Entry No." <> 0)) then begin
          MemberCardEntryNo := MembershipMgr.GetMemberCardEntryNo (Member."Entry No.", Membership."Membership Code", Today);

          if ((MemberCardEntryNo <> 0) and MemberCard.Get (MemberCardEntryNo)) then
            ExternalMemberCardNo := MemberCard."External Card No.";
        end;

        if (MembershipEntryNo = 0) then begin
          ResponseMessage := StrSubstNo ('External Member Number %1, not found.', ExternalMemberNo);
          MemberLimitationMgr.LogMemberCardArrival (ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1); //MM1.21 [284653]
          exit (-1);
        end;
        if (not MembershipMgr.IsMembershipActive (MembershipEntryNo, WorkDate, true)) then begin
          ResponseMessage := StrSubstNo ('Membership is not active for today (%1).', Format (WorkDate,0,9));
          MemberLimitationMgr.LogMemberCardArrival (ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, -1); //MM1.21 [284653]
          exit (-1);
        end;

        Success := 0;
        ResponseMessage := '';

        if (MembershipSetup."Ticket Item Barcode" <> '') then begin

          //-MM1.33 [326756]
          // TicketRequestManager.LockResources ();
          Success := IssueMemberTicketAndRegisterArrival (MembershipSetup."Ticket Item Barcode", AdmissionCode, ScannerStationId, Member, ResponseMessage);

          // MemberLimitationMgr.WS_CheckLimitMemberCardArrival (ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, Success); //MM1.21 [284653]
          // EXIT (Success);
          //+MM1.33 [326756]

        end;

        MemberLimitationMgr.WS_CheckLimitMemberCardArrival (ExternalMemberCardNo, AdmissionCode, ScannerStationId, ResponseMessage, Success); //MM1.21 [284653]
        exit (Success);
    end;

    local procedure IssueMemberTicketAndRegisterArrival(TicketItemNo: Code[50];AdmissionCode: Code[20];ScannerStationId: Code[10];Member: Record "MM Member";var ResponseMessage: Text) Success: Integer
    var
        TicketMgr: Codeunit "TM Ticket Management";
        MemberRetailIntegration: Codeunit "MM Member Retail Integration";
        ItemNo: Code[20];
        VariantCode: Code[10];
        ResolvingTable: Integer;
        TicketNo: Code[20];
        Ticket: Record "TM Ticket";
        ResponseCode: Integer;
        Token: Text[100];
    begin

        if not (MemberRetailIntegration.TranslateBarcodeToItemVariant (TicketItemNo, ItemNo, VariantCode, ResolvingTable)) then begin
          ResponseMessage := StrSubstNo ('%1 does not translate to an item. Check Item Cross-Reference or Item table.', TicketItemNo);
          exit (-1);
        end;

        //-MM1.32 [316468]
        Ticket.SetCurrentKey ("External Member Card No.");
        Ticket.SetFilter ("Item No.", '=%1', ItemNo);
        Ticket.SetFilter ("Variant Code", '=%1', VariantCode);
        Ticket.SetFilter ("Document Date", '=%', Today);
        //+MM1.32 [316468]
        Ticket.SetFilter ("External Member Card No.", '=%1', Member."External Member No.");
        if (Ticket.FindLast ()) then begin
          // IF (Ticket."Document Date" = TODAY) THEN BEGIN
            ResponseCode := TicketMgr.ValidateTicketForArrival (0, Ticket."No.", AdmissionCode, -1, false, ResponseMessage);
            if (ResponseCode = 0) then begin

              if (AdmissionCode = '') then
                AdmissionCode := '-default-';

              ResponseMessage := StrSubstNo (MEMBER_TICKET, Ticket."No.", AdmissionCode, Member."External Member No.");

              exit (ResponseCode);
            end;
          // END;
        end;

        //-MM1.33 [326756]
        //ResponseCode := MemberRetailIntegration.IssueTicketFromMemberScan (FALSE, ItemNo, VariantCode, Member, TicketNo, ResponseMessage);
        //IF (ResponseCode <> 0) THEN
        //  EXIT (ResponseCode);
        Commit;
        if (not TicketMakeReservation (TicketItemNo, AdmissionCode, Member."External Member No.", ScannerStationId, Token, ResponseMessage)) then
          exit (-1);

        Commit;

        if not (TicketConfirmReservation (Token, ScannerStationId, TicketNo, ResponseMessage)) then
          exit (-1);

        Commit;
        //+MM1.33 [326756]


        Ticket.Get (TicketNo);
        Success := TicketMgr.ValidateTicketForArrival (0, TicketNo, AdmissionCode, -1, false, ResponseMessage);

        if (Success = 0) then begin
          if (AdmissionCode = '') then
            AdmissionCode := '-default-';
          ResponseMessage := StrSubstNo (NEW_MEMBER_TICKET, TicketNo, AdmissionCode, Member."External Member No.");
        end;

        exit (Success);
    end;

    local procedure InsertImportEntry(WebserviceFunction: Text;var ImportEntry: Record "Nc Import Entry")
    var
        NaviConnectSetupMgt: Codeunit "Nc Setup Mgt.";
    begin
        ImportEntry.Init;
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"MM Member WebService", WebserviceFunction);
        if (ImportEntry."Import Type" = '') then begin
          MemberIntegrationSetup ();
          ImportEntry."Import Type" := GetImportTypeCode(CODEUNIT::"MM Member WebService", WebserviceFunction);
          if (ImportEntry."Import Type" = '') then
            Error (SETUP_MISSING, WebserviceFunction);
        end;

        ImportEntry.Date := CurrentDateTime;
        ImportEntry."Document Name" := StrSubstNo('%1-%2.xml', ImportEntry."Import Type", Format(ImportEntry.Date,0,9));
        ImportEntry.Imported := false;
        ImportEntry."Runtime Error" := false;
        ImportEntry.Insert(true);
    end;

    local procedure MemberIntegrationSetup()
    var
        ImportType: Record "Nc Import Type";
    begin
        ImportType.SetFilter ("Webservice Codeunit ID", '=%1', CODEUNIT::"MM Member WebService");
        if (not ImportType.IsEmpty ()) then
          ImportType.DeleteAll ();

        CreateImportType ('MEMBER-01', 'MemberManagement', 'CreateMembership');
        CreateImportType ('MEMBER-02', 'MemberManagement', 'AddMembershipMember');
        CreateImportType ('MEMBER-03', 'MemberManagement', 'GetMembership');
        CreateImportType ('MEMBER-04', 'MemberManagement', 'GetMembershipMembers');
        CreateImportType ('MEMBER-05', 'MemberManagement', 'UpdateMember');
        CreateImportType ('MEMBER-06', 'MemberManagement', 'BlockMembership');
        CreateImportType ('MEMBER-07', 'MemberManagement', 'GetMembershipTicketList');
        CreateImportType ('MEMBER-08', 'MemberManagement', 'ChangeMembership');
        CreateImportType ('MEMBER-09', 'MemberManagement', 'GetMembershipChangeItemsList');
        CreateImportType ('MEMBER-10', 'MemberManagement', 'AddAnonymousMember');
        CreateImportType ('MEMBER-11', 'MemberManagement', 'ConfirmMembershipPayment');
        CreateImportType ('MEMBER-12', 'MemberManagement', 'RegretMembership');
        CreateImportType ('MEMBER-13', 'MemberManagement', 'GetMembershipAutoRenewProduct');
        CreateImportType ('MEMBER-14', 'MemberManagement', 'ConfirmAutoRenewPayment');
        CreateImportType ('MEMBER-15', 'MemberManagement', 'SetGDPRApproval');
        CreateImportType ('MEMBER-16', 'MemberManagement', 'CreateWalletMemberPass');
        CreateImportType ('MEMBER-17', 'MemberManagement', 'GetMembershipRoles');
        CreateImportType ('MEMBER-18', 'MemberManagement', 'GetSetAutoRenewOption');
        CreateImportType ('MEMBER-19', 'MemberManagement', 'GetSetMemberComOption');

        Commit;
    end;

    local procedure CreateImportType("Code": Code[20];Description: Text[30];FunctionName: Text[30])
    var
        ImportType: Record "Nc Import Type";
    begin

        ImportType.Code := Code;
        ImportType.Description := Description;
        ImportType."Webservice Function" := FunctionName;

        ImportType."Webservice Enabled" := true;
        ImportType."Import Codeunit ID" := CODEUNIT::"MM Member WebService Mgr";
        ImportType."Webservice Codeunit ID" := CODEUNIT::"MM Member WebService";

        ImportType.Insert ();
    end;

    local procedure GetImportTypeCode(WebServiceCodeunitID: Integer;WebserviceFunction: Text): Code[10]
    var
        ImportType: Record "Nc Import Type";
    begin

        Clear(ImportType);
        ImportType.SetRange("Webservice Codeunit ID",WebServiceCodeunitID);
        ImportType.SetFilter("Webservice Function",'%1',CopyStr(WebserviceFunction,1,MaxStrLen(ImportType."Webservice Function")));

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

    local procedure TicketMakeReservation(ExternalItemNumber: Code[20];AdmissionCode: Code[20];MemberReference: Code[20];ScannerStation: Code[20];var Token: Text[100];var ResponseMessage: Text) ReservationStatus: Boolean
    var
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TicketReservation: XMLport "TM Ticket Reservation";
        TicketWebService: Codeunit "TM Ticket WebService";
        txtRead: Text;
    begin

        //-MM1.33 [326756]

        xmltext :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
        '<tickets xmlns="urn:microsoft-dynamics-nav/xmlports/x6060114">'+
        '   <reserve_tickets token="">'+
        StrSubstNo ('       <ticket external_id="%1" line_no="1" qty="1" admission_schedule_entry="0" member_number="%2" admission_code="%3"/>', ExternalItemNumber, MemberReference, AdmissionCode)+
        '   </reserve_tickets>'+
        '</tickets>';

        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        TicketReservation.SetSource (iStream);
        TicketReservation.Import ();

        TicketWebService.MakeTicketReservation (TicketReservation, ScannerStation);

        ReservationStatus := TicketReservation.GetResult (Token, ResponseMessage);

        exit (ReservationStatus);

        //+MM1.33 [326756]
    end;

    local procedure TicketConfirmReservation(Token: Text[100];ScannerStation: Code[20];var TicketNumber: Code[20];var ResponseMessage: Text) ConfirmationStatus: Boolean
    var
        xmltext: Text;
        TmpBLOBbuffer: Record "BLOB buffer" temporary;
        iStream: InStream;
        oStream: OutStream;
        TicketWebService: Codeunit "TM Ticket WebService";
        TicketConfirmation: XMLport "TM Ticket Confirmation";
        TicketReservationResponse: Record "TM Ticket Reservation Response";
        Ticket: Record "TM Ticket";
    begin

        //-MM1.33 [326756]

        xmltext :=
        '<?xml version="1.0" encoding="UTF-8" standalone="no"?>'+
        '<tickets xmlns="urn:microsoft-dynamics-nav/xmlports/x6060117">'+
        '  <ticket_tokens>'+
        StrSubstNo ('      <ticket_token>%1</ticket_token>', Token) +
        '      <send_notification_to></send_notification_to>'+
        '      <external_order_no>prepaid</external_order_no>'+
        '  </ticket_tokens>'+
        '</tickets>';

        TmpBLOBbuffer.Insert ();
        TmpBLOBbuffer."Buffer 1".CreateOutStream (oStream);
        oStream.WriteText (xmltext);
        TmpBLOBbuffer.Modify ();

        TmpBLOBbuffer."Buffer 1".CreateInStream (iStream);
        TicketConfirmation.SetSource (iStream);
        TicketConfirmation.Import ();

        ConfirmationStatus := TicketWebService.ConfirmTicketReservation (TicketConfirmation, ScannerStation);

        ResponseMessage := 'There was a problem with Confirm Ticket Reservation.';
        TicketReservationResponse.SetFilter ("Session Token ID", '=%1', Token);
        if (TicketReservationResponse.FindFirst ()) then begin

          if (TicketReservationResponse.Confirmed) then begin
            Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationResponse."Request Entry No.");
            if (Ticket.FindFirst ()) then
              TicketNumber := Ticket."No.";
            ResponseMessage := '';
            ConfirmationStatus  := true;
          end else begin
            ResponseMessage := TicketReservationResponse."Response Message";
            ConfirmationStatus := false;
          end;
        end;


        exit (ConfirmationStatus);
        //+MM1.33 [326756]
    end;
}

