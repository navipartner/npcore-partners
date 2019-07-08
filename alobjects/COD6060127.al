codeunit 6060127 "MM Membership Management"
{
    // MM1.00/TSA/20151217  CASE 229684 NaviPartner Member Management Module
    // MM1.01/TSA/20151222  CASE 230149 Added function get member from external card no
    // MM1.02/TSA/20151228  CASE 229684 Added Image update function, member update function
    // MM1.03/TSA/20160104  CASE 230647 Added NewsLetter CRM option
    // MM1.04/TSA/20160115  CASE 231978 General Enhancements
    // MM1.05/TSA/20160121  CASE 232494 Adding support functions for getting the membership valid from / until dates based on a reference date
    // MM1.06/TSA/20160127  CASE 232910 Added function to block membersship
    // MM1.08/TSA/20160223  CASE 234913 Include company name field on membership
    // MM1.09/TSA/20160226  CASE 235634 Membership connection to Customer & Contacts
    // MM1.09/BHR/20160310  CASE 233047 Remove hidden char when importing members
    // MM1.10/TSA/20160321  CASE 237393 Cancel Membership.
    // MM1.10/TSA/20160325  CASE 236532 Added picture blob field addmember (from POS)
    // MM1.10/TSA/20160330  CASE 237849 Added call SetSkipNumberLookup on customer create
    // MM1.10/TSA/20160330  CASE 237848 Added more fields to contact synch.
    // MM1.10/TSA/20160331  CASE 234591 Added parameter to CreateMembership to include creation of ledger entry, made AddMembershipLedgerEntry() global
    // MM1.10/TSA/20160404  CASE 233948 Added SynchronizeCustomerAndContact function
    // MM1.11/TSA/20160420  CASE 233824 Added Membership change functions, RENEW, EXTEND, UPGRADE
    // MM1.11.01/TSA/20160503  CASE 233824 Swapped RENEW and EXTEND implementation
    // MM1.12/TSA/20160503  CASE 240661 Added DAN Captions
    // MM1.14/TSA/20160503  CASE 240697 Added Price fraction calculations.
    // MM1.14,TSA/20160518  CASE 240870 Added Membership Code to  Membership Entry to handle cancel of upgrade
    // MM1.14/TSA/20160523  CASE 240871 Reminder Service
    // MM1.15/TSA/20160615  CASE xxxxxx Bug fix Mising fields transferred to member, membership ledger entry description set
    // MM1.15/TSA/20160810  CASE 248625 Member info is updated when Uniqueness rule specifies reuse
    // MM1.16/TSA/20160829  CASE 239052 First contact must also update member rec with contact no.
    // MM1.16/TSA/20160831  CASE 239052 Setting up an event for np-xml to trigger on when membership is altered, and the web needs to be resynched
    // MM1.16/TSA/20160913  CASE 252216 Signature change on search function
    // MM1.17/TSA/20161121  CASE 258982 Changed how partially created business relations was corrected
    // MM1.17/TSA/20161208  CASE 259671 Extended functionality for handling the start date of membership
    // MM1.17/TSA/20161223  CASE 261887 Incorrect date check in GetLedgerEntryForDate
    // MM1.17/TSA/20161228  CASE 262040 Signature change on AddNamedMember, AddMemberAndCard, CreateMemberRole to handle a late fail
    // MM1.17/TSA/20161229  CASE 261216 Signature change IssueNewMemberCard and IssueMemberCardWorker
    // MM1.17/TSA/20161229  CASE 261216 Added BlockMemberCards, BlockMemberCard, GetCardEntryNoFromExtCardNo, refactored GenerateExtCardNoSimple
    // MM1.17/TSA/20170111  CASE 261432 Added integrationevent OnAfterMemberCreateEvent, OnAfterMemberFieldsAssignmentEvent
    // MM1.18/TSA/20170216  CASE 265729 Added membership code to the alter membership result set
    // MM1.18/TSA/20170302  CASE 265340 Membership Role entity should carry Contact No., changing so that both fields are populated
    // MM1.18/TSA/20170302  CASE 265340 UpdateMember() trigger SynchronizeCustomerAndContact(), refactored AddCustomerContact(),
    // MM1.18/TSA/20170302  CASE 265340 Implemented MAXSTRLEN when validating member to customer / contact fields
    // MM1.19/TSA/20170315  CASE 264882 Restructured to meet Config template rather than Customer Template
    // MM1.19/TSA/20170317  CASE 264050 Change rounding principle for upgrade, renew, extend price calculation
    // MM1.19/TSA/20170322  CASE 268166 Upgrade membership with a different date formula
    // MM1.19/TSA/20170324  CASE 270308 Added a link to a the created membercard generated in this transaction.
    // MM1.19/TSA/20170418  CASE 272422 New function - IsIdentifierMemberNumber - subscriber of Codeunit Identifier Dissociation
    // MM1.19/TSA/20170518  CASE 276779 GetMembershipValidDate() must return dates when a membership has been valid in the past
    // MM1.19/TSA/20170519  CASE 276779 added the GetMembershipMaxValidUntilDate() function
    // MM1.19/TSA/20170524  CASE 2665379 UpdateContactFromMember changed signature and made global
    // NPR5.33/MHA/20170608  CASE 279229 Added Contact Config. Template functionality
    // NPR5.33/TSA/20170609  CASE 279983 Bad filter after reset in GetMembershipValidDate()
    // NPR5.34/TSA /20170719 CASE 284560 Changed AddMemberAndCard to pass on param to allow blank external card no.
    // NPR5.34/TSA /20170724 CASE 284798 Corrected Spelling for subscriber function IdentifyThisCodePublisher
    // MM1.22/TSA /20170808 CASE 285403 Added publisher OnAfterInsertMembershipEntry()
    // MM1.22/TSA /20170811 CASE 282251 Stripping spaces from beginning of external member card number to prevent card no " " to find first entry
    // MM1.22/TSA /20170816 CASE 287080 Added the AddAnonymousMember() function
    // MM1.22/TSA /20170816 CASE 287080 Added price calculations for anonymous members in RENEW, EXTEND, UPGRADE
    // MM1.22/TSA /20170818 CASE 287080 New role Anonymous must be omitted when navigating Membership Role to Member
    // MM1.22/TSA /20170829 CASE 286922 Auto Renew functions, CreateAutoRenewMemberInfoRequest(), AutoRenewMembership()
    // MM1.22/TSA /20170901 CASE 288919 Removed the prefill of membership info capture to get one-step upgrade to work
    // MM1.22/TSA /20170905 CASE 276832 Added Guardian Role Creation
    // MM1.22/TSA /20170911 CASE 284560 Added Assign of Card is temporary
    // MM1.23/TSA /20171003 CASE 257011 Handling a blank card number on when creating a new member card,
    // MM1.23/TSA /20171004 CASE 257011 Membership Datetime for replication, synchronization, modification
    // MM1.23/TSA / Missing update of customer after upgrade and renew and sync
    // MM1.23/TSA /20171012 CASE 293364 Allow REVOKE and EXTEND to change membership type even though membership is active
    // MM1.24/TSA /20171129 CASE 298110 Moved delete membership from delete trigger to function
    // MM1.24/TSA /20171207 CASE 298387 Added TIME_DIFFERENCE calc for UpgradeMembership
    // MM1.25/TSA /20171213 CASE 299690 Added global function AddGuardianMember()
    // MM1.25/TSA /20171219 CASE 299783 Refactoring the membership alteration function to be able to be verbose
    // MM1.25/TSA /20171220 CASE 300685 Cancel and Regret does not undo loyalty points in auto-mode
    // MM1.25/TSA /20180103 CASE 299783 Adding support for reversing auto-renew invoice
    // MM1.25/TSA /20180115 CASE 299537 Created function PrintOffline
    // MM1.25/TSA /20180118 CASE 300256 IssueMemberCardWorker refactored for new setting for handling card expire option
    // MM1.26/TSA/20180120 CASE 299785 Improved error message when auto-renew rule selection fails, signature change
    // MM1.26/TSA /20180124 CASE 303154 UpdateMember did not add the Guardian Member if applicable
    // MM1.26/TSA /20180125 CASE 301146 Postcode and country code / name lookup on member details update
    // MM1.26/TSA /20180126 CASE 303696 Improved errors handling on auto-renew
    // MM1.26/TSA /20180207 CASE 294868 Changed SynchronizeCustomerAndContact to handle guardian
    // MM1.26/TSA /20180219 CASE 305631 Refactored Regret function to make the regret part available as public function (from WS);
    // MM1.27/TSA /20180301 CASE 306157 Handling blank external card number when extend card is required
    // MM1.27/TSA /20180315 CASE 308300 I18 of hardcoded date
    // MM1.27/TSA /20180323 CASE 307113 Community Membership External Membership No.
    // MM1.28/TSA /20180405 CASE 307113 Added filter to membership code for community memberships
    // MM1.28/TSA /20180417 CASE 303635 Added some more return data from CreateAutoRenewMemberInfoRequest to get a more comprehensive web service request for auto renew
    // MM1.32/TSA /20180503 CASE 313795 GDRP
    // MM1.29/TSA /20180504 CASE 314131 Pass activation on welcome notification
    // MM1.29/TSA /20180507 CASE 313741 Update Magento Contact false when membership delete
    // MM1.29/TSA /20180511 CASE 313795 Added GDPR support
    // MM1.29/TSA /20180522 CASE 316141 Price Calculuations base on current entry "Unit Price" changed to "Unit Price (Base)";
    // MM1.29.02/TSA /20180531 CASE 314131 Moved AddMemberCreateNotification(), AddMembershipRenewalNotification()  implementation to 6060136
    // MM1.30/TSA /20180605 CASE 317428 Advanced Graced Period Calculation
    // MM1.30/TSA /20180612 CASE 317508 Fallback rule for auto-renew
    // MM1.30/TSA /20180614 CASE 319296 Added Alternative number series for creating customer
    // MM1.30/TSA /20180615 CASE 319243 Housecleaning - removing unused variables
    // #319900/TSA /20180710 CASE 319900 BlockMember() refactored with protect on GET() functions.
    // MM1.32/TSA /20180511 CASE 313795 Fixed the CreateGuardianRoleWorker() when GDPR was not setup
    // MM1.33/TSA /20180731 CASE 323652 Added Document Number to the offline print journal
    // MM1.33/TSA /20180803 CASE 323651 Added support to undo the unintensional regret of the first transaction.
    // MM1.33/TSA /20180806 CASE 324065 Guardian
    // MM1.33/MHA /20180814  CASE 326754 Deleted function IsIdentifierMemberNumber()
    // MM1.34/TSA /20180907 CASE 327605 CalculateRemainingAmount()
    // MM1.35/TSA /20181015 CASE 332452 IssueMemberCard() checks for picture update.
    // MM1.35/TSA /20181019 CASE 333079 Incorrect filter for finding guardian when having more than one member
    // MM1.36/TSA /20181114 CASE 335667 Fixed synchronization of contact data to customer
    // MM1.36/TSA /20181114 CASE 335667 Added function ReflectMembershipRoles()
    // MM1.36/TSA /20181204 CASE 338771 Renew compares wrong date when having dateformula as start options
    // MM1.37/TSA /20181219 CASE 319900 ReasonMessage not declared as VAR in IssueMemberCardWorker()
    // MM1.39/TSA /20190527 CASE 350968 Change datatype on field Auto-Renew


    trigger OnRun()
    begin
    end;

    var
        CASE_MISSING: Label '%1 value %2 is missing its implementation.';
        TO_MANY_MEMBERS: Label 'Max number of members exceeded.\\The membership %1 of type %2 allows a maximum of %3 members per membership.';
        LOGIN_ID_EXIST: Label 'The selected member logon id [%1] is already in use.\\Member %2.';
        LOGIN_ID_BLANK: Label 'The %1 can''t be blank when the setting for %2 is %3.';
        MEMBER_EXIST: Label 'Member ID [%1] is already in use.';
        MEMBER_REUSE: Label 'Member ID [%1] is already in use.\Do you want reuse member %2.';
        MEMBER_BLOCKED: Label 'Member ID [%1] is blocked. Block date is %2.';
        MEMBER_ROLE_BLOCKED: Label 'Member ID [%1] has no active role in membership [%2].';
        MEMBER_CARD_EXIST: Label 'Member Card ID [%1] is already in use. To reuse this card number, block the current card first.';
        INVALID_NUMBER: Label 'The value %1 is not valid for %2.';
        ABORTED: Label 'Aborted.';
        PAN_TO_LONG: Label 'The generated PAN exceeds %1 characters when using pattern %2.';
        PATTERN_ERROR: Label 'Error in pattern %1.';
        MISSING_VALUE: Label '%1 must be specified for %2 %3.';
        MEMBERSHIP_ENTRY_NOT_FOUND: Label 'The membership card %1 has no membership entries to base that change on.';
        TIME_ENTRY_NOT_FOUND: Label 'The membership has no time entries to base that change on.';
        MEMBERSHIP_CARD_REF: Label 'The membership card %1 has an invalid reference to membership. Membership entry %2 was not found.';
        MEMBER_CARD_REF: Label 'The membership card %1 has an invalid reference to member. Member entry %2 was not found.';
        CONFIRM_CANCEL: Label 'Membership %1 valid from %2 until %3, will be canceled, effective from %4.';
        CONFIRM_REGRET: Label 'Do you want to regret creating membership %1 valid from %2 until %3.';
        MISSING_TEMPLATE: Label 'The customer template %1 is not valid or not found.';
        RENEW_MEMBERSHIP: Label 'Do you want to renew the membership with %1 (%2 - %3).';
        CONFLICTING_ENTRY: Label 'There is already a membership period active in the time period %1 - %2.';
        EXTEND_MEMBERSHIP: Label 'Do you want to extend the membership with %1 (%2 - %3).';
        UPGRADE_MEMBERSHIP: Label 'Do you want to upgrade the membership with %1 (%2 - %3).';
        CANCEL_MEMBERSHIP_NOT_ALLOWED: Label 'The membership can''t be refunded at this time. ';
        FUTUREDATE_NOT_SUPPORTED: Label 'When changing membeship type, a future date may not be used.';
        PRICEMODEL_NOT_SUPPORTED: Label 'The pricemodel %1 is not supported with operation %2.';
        EXTEND_TO_SHORT: Label 'When extending a subscription, the new until date (%1) must exceed the current subscriptons until date (%2).';
        OVERLAPPING_TIMEFRAME: Label 'There are overlapping time frames for membership entry no %1, for date %2.';
        MULTIPLE_TIMEFRAMES: Label 'The operation %1 can not span multiple time frames for member entry no. %2. The new time frame %3 - %4, span current time frame entries %5 and %6.';
        NO_TIMEFRAME: Label 'Date of cancel (%1) must be within the active time frame (%2 - %3).';
        STACKING_NOT_ALLOWED: Label 'Setup does not allow stacking - having multiple open time frames.  Membership entry no %1, for date %2.';
        UPGRADE_TO_CODE_MISSING: Label 'When performing an upgrade, you must specify a target membership code.';
        MEMBERSHIP_BLOCKED: Label 'The membership %1 for card %2 is blocked. Block date is %3.';
        MEMBERCARD_NOT_FOUND: Label 'The member card %1 was not found.';
        MEMBERCARD_BLOCKED: Label 'The member card %1 is blocked.';
        MEMBERCARD_EXPIRED: Label 'The member card %1 has expired.';
        NO_ADMIN_MEMBER: Label 'At least one member must have an administrative role in the membership. This members information will not be synchronized to customer. Membership could not be created.';
        MEMBERCARD_BLANK: Label 'Membercard number can''t be empty or blank.';
        TO_MANY_MEMBERS_NO: Label '-127001';
        MEMBER_CARD_EXIST_NO: Label '-127002';
        NO_ADMIN_MEMBER_NO: Label '-127003';
        MEMBERCARD_BLANK_NO: Label '-127004';
        NO_LEDGER_ENTRY: Label 'The membership %1 is NOT valid.\\It must be activated, but there is no ledger entry associated with that membership that can be actived.';
        NOT_ACTIVATED: Label 'The membership is marked as activate on first use, but has not been activated yet. Retry the action after the membership has been activated.';
        NOT_FOUND: Label '%1 not found. %2';
        GRACE_PERIOD: Label 'The %1 is not allowed because of grace period constraint.';
        PREVENT_CARD_EXTEND: Label 'The validity for card %1 must first manually be extend until %2.';

    procedure CreateMembershipAll(MembershipSalesSetup: Record "MM Membership Sales Setup";var MemberInfoCapture: Record "MM Member Info Capture";CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
    var
        Community: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
        MemberEntryNo: Integer;
        CardEntryNo: Integer;
        ResponseMessage: Text;
    begin

        MembershipSalesSetup.TestField (Blocked, false);

        MembershipSetup.Get (MembershipSalesSetup."Membership Code");
        MembershipSetup.TestField (Blocked, false);

        Community.Get (MembershipSetup."Community Code");
        Community.TestField ("External Membership No. Series");
        Community.TestField ("External Member No. Series");

        MembershipEntryNo := CreateMembership (MembershipSalesSetup, MemberInfoCapture, CreateMembershipLedgerEntry);

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::ANONYMOUS) then
          MemberEntryNo := AddCommunityMember (MembershipEntryNo, 1);

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
          if (not AddNamedMember (true, MembershipEntryNo, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
            exit (0);

        if (not IssueMemberCardWorker (true, MembershipEntryNo, MemberEntryNo, MemberInfoCapture, false, CardEntryNo, ResponseMessage, false)) then
          exit (0);

        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Member Entry No" := MemberEntryNo;
        MemberInfoCapture."Card Entry No." := CardEntryNo;

        exit (MembershipEntryNo);
    end;

    procedure CreateMembership(MembershipSalesSetup: Record "MM Membership Sales Setup";MemberInfoCapture: Record "MM Member Info Capture";CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
    var
        MembershipSetup: Record "MM Membership Setup";
    begin

        MembershipSetup.Get (MembershipSalesSetup."Membership Code");

        case MembershipSetup."Membership Type" of
          // Single Shared membership object, anonymous members
          MembershipSetup."Membership Type"::COMMUNITY :
            MembershipEntryNo := GetCommunityMembership (MembershipSetup.Code, true);

          // Shared membership object, named members
          MembershipSetup."Membership Type"::GROUP :
            MembershipEntryNo := GetNewMembership (MembershipSetup.Code, MemberInfoCapture, true);

          // One membership one member
          MembershipSetup."Membership Type"::INDIVIDUAL :
            MembershipEntryNo := GetNewMembership (MembershipSetup.Code, MemberInfoCapture, true);

          else
            Error (CASE_MISSING, MembershipSetup.FieldName ("Membership Type"), MembershipSetup."Membership Type");
        end;

        if (CreateMembershipLedgerEntry) then
          AddMembershipLedgerEntry_NEW (MembershipEntryNo, MemberInfoCapture."Document Date", MembershipSalesSetup, MemberInfoCapture);

        exit (MembershipEntryNo);
    end;

    procedure DeleteMembership(MembershipEntryNo: Integer;Force: Boolean)
    var
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        MembershipLedgerEntry: Record "MM Membership Entry";
        MemberCard: Record "MM Member Card";
        MembershipSetup: Record "MM Membership Setup";
        MembershipPointsEntry: Record "MM Membership Points Entry";
        Contact: Record Contact;
        MembershipNotification: Record "MM Membership Notification";
        MemberNotificationEntry: Record "MM Member Notification Entry";
    begin

        //-MM1.24 [298110]
        if (MembershipEntryNo = 0) then
          exit;

        Membership.Get (MembershipEntryNo);

        if (not Force) then begin
          MembershipSetup.Get (Membership."Membership Code");
          MembershipSetup.TestField ("Allow Membership Delete", true);
        end;

        MembershipLedgerEntry.SetCurrentKey ("Membership Entry No.");
        MembershipLedgerEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipLedgerEntry.FindSet ()) then
          MembershipLedgerEntry.DeleteAll (true);

        //-MM1.32 [318132]
        MembershipNotification.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipNotification.DeleteAll ();

        MemberNotificationEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MemberNotificationEntry.DeleteAll ();
        //+MM1.32 [318132]

        MemberCard.SetCurrentKey ("Membership Entry No.");
        MemberCard.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MemberCard.FindFirst ()) then
          MemberCard.DeleteAll ();

        MembershipRole.SetCurrentKey ("Membership Entry No.");
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipRole.FindFirst ()) then
          MembershipRole.DeleteAll ();

        MembershipPointsEntry.SetFilter ("Entry No.", '=%1', Membership."Entry No.");
        //-MM1.29 [313741]
        //IF (MembershipPointsEntry.FINDFIRST ()) THEN
        //  MembershipPointsEntry.DELETEALL ();
        if (MembershipRole.FindSet ()) then begin
          repeat
            if (Contact.Get (MembershipRole."Contact No.")) then begin
              Contact."Magento Contact" := false;
              Contact.Modify (true);
            end;
          until (MembershipRole.Next () = 0);
          MembershipPointsEntry.DeleteAll ();
        end;

        //+MM1.29 [313741]


        Membership.Delete();
    end;

    procedure AddMemberAndCard(FailWithError: Boolean;MembershipEntryNo: Integer;var MemberInfoCapture: Record "MM Member Info Capture";AllowBlankExternalCardNumber: Boolean;var MemberEntryNo: Integer;var ResponseMessage: Text): Boolean
    begin

        if (not AddNamedMember (FailWithError, MembershipEntryNo, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
          exit (false);

        if (not IssueMemberCardWorker (FailWithError, MembershipEntryNo, MemberEntryNo, MemberInfoCapture, AllowBlankExternalCardNumber, MemberInfoCapture."Card Entry No.", ResponseMessage, false)) then
          exit (false);

        exit (true);
    end;

    procedure AddAnonymousMember(MembershipInfoCapture: Record "MM Member Info Capture";NumberOfMembers: Integer)
    begin

        //-+MM1.22 [287080]
        AddCommunityMember (MembershipInfoCapture."Membership Entry No.", NumberOfMembers);
    end;

    procedure AddNamedMember(FailWithError: Boolean;MembershipEntryNo: Integer;var MembershipInfoCapture: Record "MM Member Info Capture";var MemberEntryNo: Integer;var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipSetup: Record "MM Membership Setup";
        Community: Record "MM Member Community";
        MembershipRole: Record "MM Membership Role";
        ErrorText: Text;
        MemberCount: Integer;
        GuardianMemberEntryNo: Integer;
    begin

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        Community.Get (Membership."Community Code");

        Member.Init ();
        if (Member.Get (CheckMemberUniqueId (Community.Code, MembershipInfoCapture))) then begin
          SetMemberFields (Member, MembershipInfoCapture);
          ValidateMemberFields (Membership."Entry No.", Member, true, ErrorText);
          Member.Modify ();
          MemberEntryNo := Member."Entry No.";
          exit (MemberEntryNo <> 0);
        end;

        Member."External Member No." := AssignExternalMemberNo (MembershipInfoCapture."External Member No", Membership."Community Code");
        SetMemberFields (Member, MembershipInfoCapture);

        Member.Insert (true);

        if (not CreateMemberRole (FailWithError, Member."Entry No.", MembershipEntryNo, MembershipInfoCapture, MemberCount, ReasonText)) then
          exit (false);

        //-MM1.33 [324065]
        if (MembershipInfoCapture."Guardian External Member No." <> '') then begin
          GuardianMemberEntryNo := GetMemberFromExtMemberNo (MembershipInfoCapture."Guardian External Member No.");
          CreateGuardianRoleWorker (MembershipEntryNo, GuardianMemberEntryNo, MembershipInfoCapture."GDPR Approval");
        end;
        //+MM1.33 [324065]

        if (Community."Membership to Cust. Rel.") then begin
          // First member updates customer address
          MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
          MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
          MembershipRole.SetFilter (Blocked, '=%1', false);

          if (MembershipRole.IsEmpty ()) then begin
            //-#276832 [276832]
            MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
            if (MembershipRole.IsEmpty ()) then
              exit (RaiseError (FailWithError, ReasonText, NO_ADMIN_MEMBER, NO_ADMIN_MEMBER_NO) = 0);
          end;

          //-MM1.33 [324065]
          // MembershipRole.FINDFIRST ();
          // UpdateCustomerFromMember (MembershipEntryNo, MembershipRole."Member Entry No.");
          MembershipRole.Reset;
          MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
          MembershipRole.SetFilter ("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::DEPENDENT);
          MembershipRole.SetFilter (Blocked, '=%1', false);
          MembershipRole.FindFirst ();
          UpdateCustomerFromMember (MembershipEntryNo, MembershipRole."Member Entry No.");
          //+MM1.33 [324065]

          if (MemberCount > 1) then
             AddCustomerContact (MembershipEntryNo, Member."Entry No."); // The member just being added.

        end;

        ValidateMemberFields (Membership."Entry No.", Member, true, ErrorText);

        DuplicateMcsPersonIdReference (MembershipInfoCapture, Member, true);
        OnAfterMemberCreateEvent (Membership, Member);

        if (MembershipSetup."Create Welcome Notification") then
          AddMemberCreateNotification (MembershipEntryNo, Member, MembershipInfoCapture);

        MemberEntryNo := Member."Entry No.";
        exit (MemberEntryNo <> 0);
    end;

    procedure AddGuardianMember(MembershipEntryNo: Integer;GuardianExternalMemberNo: Code[20];GdprApproval: Option): Boolean
    var
        GuardianMemberEntryNo: Integer;
        MembershipRole: Record "MM Membership Role";
    begin

        if (MembershipEntryNo = 0) then
          exit (false);


        // EXIT (CreateGuardianRoleWorker (MembershipEntryNo, GuardianExternalMemberNo, GdprApproval));

        if (GuardianExternalMemberNo = '') then
          exit (false);

        GuardianMemberEntryNo := GetMemberFromExtMemberNo (GuardianExternalMemberNo);
        if (not (CreateGuardianRoleWorker (MembershipEntryNo, GuardianMemberEntryNo, GdprApproval))) then
          exit (false);

        MembershipRole.Reset;
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter ("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::DEPENDENT);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        MembershipRole.FindFirst ();
        UpdateCustomerFromMember (MembershipEntryNo, MembershipRole."Member Entry No.");

        exit (true);
        //+MM1.33 [324065]
    end;

    procedure PrintOffline(PrintOption: Option;EntryNo: Integer)
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
        MembershipEntry: Record "MM Membership Entry";
    begin

        //-MM1.25 [299537]
        case PrintOption of
          MemberInfoCapture."Information Context"::PRINT_MEMBERSHIP : MemberInfoCapture."Membership Entry No." := EntryNo;
          MemberInfoCapture."Information Context"::PRINT_CARD : MemberInfoCapture."Card Entry No." := EntryNo;
          MemberInfoCapture."Information Context"::PRINT_ACCOUNT : MemberInfoCapture."Member Entry No" := EntryNo;
        end;

        MemberInfoCapture."Information Context" := PrintOption;
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::PRINT_JNL;

        if ((MemberInfoCapture."Card Entry No." <> 0) and (MemberCard.Get (MemberInfoCapture."Card Entry No."))) then begin

          //-MM1.33 [323652]
          MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
          MembershipEntry.SetFilter (Blocked, '=%1', false);

          if (MembershipEntry.FindLast ()) then  begin
            MemberInfoCapture."Document No." := MembershipEntry."Document No.";
            MemberInfoCapture."Receipt No." := MembershipEntry."Receipt No.";
          end;
          //+MM1.33 [323652]


          MemberInfoCapture."External Card No." := MemberCard."External Card No.";
          MemberInfoCapture."External Card No. Last 4" := MemberCard."External Card No. Last 4";
          MemberInfoCapture."Valid Until" := MemberCard."Valid Until";
          MemberInfoCapture."Membership Entry No." := MemberCard."Membership Entry No.";
          MemberInfoCapture."Member Entry No" := MemberCard."Member Entry No."
        end;

        if ((MemberInfoCapture."Membership Entry No." <> 0) and (Membership.Get (MemberInfoCapture."Membership Entry No."))) then begin
          MemberInfoCapture."Company Name" := Membership."Company Name";
          MemberInfoCapture."Membership Code" := Membership."Membership Code";
          MemberInfoCapture."External Membership No." := Membership."External Membership No.";
          MemberInfoCapture."Document Date" := Membership."Issued Date";
        end;

        if ((MemberInfoCapture."Member Entry No" <> 0) and (Member.Get (MemberInfoCapture."Member Entry No"))) then begin
          MemberInfoCapture."External Member No" := Member."External Member No.";
          MemberInfoCapture."First Name" := Member."First Name";
          MemberInfoCapture."Last Name" := Member."Last Name";
          MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";
          MemberInfoCapture."Phone No." := Member."Phone No.";
        end;

        MemberInfoCapture.Insert ();
        //+MM1.25 [299537]
    end;

    procedure GetMemberImage(MemberEntryNo: Integer;var Base64StringImage: Text) Success: Boolean
    var
        Member: Record "MM Member";
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
    begin

        if (not Member.Get (MemberEntryNo)) then
          exit (false);

        if (not Member.Picture.HasValue ()) then
          exit (false);

        Member.CalcFields (Picture);
        Member.Picture.CreateInStream (InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Base64StringImage := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);

        exit (true);
    end;

    procedure UpdateMember(MembershipEntryNo: Integer;MemberEntryNo: Integer;MembershipInfoCapture: Record "MM Member Info Capture") Success: Boolean
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        ErrorText: Text;
    begin

        if (not Member.Get (MemberEntryNo)) then
          exit (false);

        if (not Membership.Get (MembershipEntryNo)) then
          exit (false);

        SetMemberFields (Member, MembershipInfoCapture);
        ValidateMemberFields (Membership."Entry No.", Member, true, ErrorText);
        Member.Modify ();

        //-MM1.26 [303154]
        if (MembershipInfoCapture."Guardian External Member No." <> '') then
          AddGuardianMember (MembershipEntryNo, MembershipInfoCapture."Guardian External Member No.", MembershipInfoCapture."GDPR Approval");
        //+MM1.26 [303154]

        SynchronizeCustomerAndContact (MembershipEntryNo);
    end;

    procedure UpdateMemberImage(MemberEntryNo: Integer;Base64StringImage: Text) Success: Boolean
    var
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        OutStr: OutStream;
        Member: Record "MM Member";
    begin

        if (not Member.Get (MemberEntryNo)) then
          exit (false);

        Member.Picture.CreateOutStream (OutStr);
        MemoryStream := MemoryStream.MemoryStream (Convert.FromBase64String (Base64StringImage));

        MemoryStream.WriteTo (OutStr);
        MemoryStream.Close();
        MemoryStream.Dispose();

        exit (Member.Modify ());
    end;

    procedure UpdateMemberPassword(MemberEntryNo: Integer;UserLogonID: Code[50];NewPassword: Text[50]) Success: Boolean
    var
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
    begin

        if (not Member.Get (MemberEntryNo)) then
          exit (false);

        MembershipRole.SetFilter ("Member Entry No.", '=%1', MemberEntryNo);
        MembershipRole.SetFilter ("User Logon ID", '=%1', UserLogonID);
        if (not MembershipRole.FindFirst ()) then
          exit (false);

        MembershipRole."Password Hash" := EncodeSHA1 (NewPassword);
        exit (MembershipRole.Modify ());
    end;

    procedure FindMembershipUsing(SearchMethod: Code[20];Key1: Text[100];Key2: Text[100]) MembershipEntryNo: Integer
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        MemberCard: Record "MM Member Card";
        NotFoundReasonText: Text;
    begin

        if (Key1 = '') then
          exit (0);

        case SearchMethod of
          'EXT-CARD-NO' :       exit (GetMembershipFromExtCardNo       (CopyStr (Key1, 1, MaxStrLen (MemberCard."External Card No.")), WorkDate, NotFoundReasonText));
          'EXT-MEMBER-NO' :     exit (GetMembershipFromExtMemberNo     (CopyStr (Key1, 1, MaxStrLen (Member."External Member No."))));
          'EXT-MEMBERSHIP-NO' : exit (GetMembershipFromExtMembershipNo (CopyStr (Key1, 1, MaxStrLen (Membership."External Membership No."))));
          'USER-PW' :           exit (GetMembershipFromUserPassword    (CopyStr (Key1, 1, MaxStrLen (MembershipRole."User Logon ID")), CopyStr (Key2, 1, MaxStrLen (MembershipRole."Password Hash"))));
          else
            Error (CASE_MISSING, 'FindMembershipUsing', SearchMethod);
        end;
    end;

    procedure GetMembershipValidDate(MembershipEntryNo: Integer;ReferenceDate: Date;var ValidFromDate: Date;var ValidUntilDate: Date) IsValid: Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSetup: Record "MM Membership Setup";
    begin

        ValidFromDate := 0D;
        ValidUntilDate := 0D;

        if (MembershipEntryNo = 0) then
          exit (false);

        if (not Membership.Get (MembershipEntryNo)) then
          exit (false);

        if (not MembershipSetup.Get (Membership."Membership Code")) then
          exit (false);

        if (MembershipSetup.Perpetual) then begin
          ValidUntilDate := DMY2Date (31, 12, 9999); //31129999D;
          exit (true);
        end;

        if (ReferenceDate = 0D) then
          ReferenceDate := Today;

        MembershipEntry.SetCurrentKey ("Membership Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (MembershipEntry.IsEmpty ()) then
          exit (false);

        MembershipEntry.SetFilter ("Valid From Date", '<=%1', ReferenceDate);
        MembershipEntry.SetFilter ("Valid Until Date", '>=%1', ReferenceDate);

        if (not MembershipEntry.FindSet ()) then begin
          // not valid on reference date, maybe in the future
          MembershipEntry.Reset ();
          MembershipEntry.SetCurrentKey ("Membership Entry No.");
          MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
          MembershipEntry.SetFilter ("Valid From Date", '>=%1', ReferenceDate);
          if (MembershipEntry.FindFirst ()) then begin
            ValidFromDate := MembershipEntry."Valid From Date";
            ValidUntilDate := MembershipEntry."Valid Until Date";
          end else begin
            //-MM1.19 [276779]
            // or maybe in the past
            MembershipEntry.Reset ();
            MembershipEntry.SetCurrentKey ("Membership Entry No.");
            MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo); //-+ [279983]
            if (MembershipEntry.FindLast ()) then begin
              ValidFromDate := MembershipEntry."Valid From Date";
              ValidUntilDate := MembershipEntry."Valid Until Date";
            end;
            //+MM1.19 [276779]
          end;

          exit (false);
        end;

        ValidFromDate := MembershipEntry."Valid From Date";
        ValidUntilDate := MembershipEntry."Valid Until Date";

        exit (((ReferenceDate >= ValidFromDate) and (ReferenceDate <= ValidUntilDate)) and (not Membership.Blocked));
    end;

    procedure GetMembershipMaxValidUntilDate(MembershipEntryNo: Integer;var MaxValidUntilDate: Date): Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSetup: Record "MM Membership Setup";
    begin

        MaxValidUntilDate := 0D;

        if (MembershipEntryNo = 0) then
          exit (false);

        if (not Membership.Get (MembershipEntryNo)) then
          exit (false);

        if (not MembershipSetup.Get (Membership."Membership Code")) then
          exit (false);

        if (MembershipSetup.Perpetual) then begin
          MaxValidUntilDate := DMY2Date (31, 12, 9999); //31129999D;
          exit (true);
        end;

        MembershipEntry.SetCurrentKey ("Membership Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (MembershipEntry.IsEmpty ()) then
          exit (false);

        MembershipEntry.FindSet ();
        repeat
          if (MaxValidUntilDate < MembershipEntry."Valid Until Date") then
            MaxValidUntilDate := MembershipEntry."Valid Until Date";
        until (MembershipEntry.Next () = 0);

        exit (MaxValidUntilDate <> 0D);
    end;

    procedure IsMembershipActive(MemberShipEntryNo: Integer;ReferenceDate: Date;WithActivate: Boolean) IsActive: Boolean
    var
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        //-MM1.17 [259671]
        if (WithActivate) then begin
          ActivateMembershipLedgerEntry (MemberShipEntryNo, ReferenceDate);
        end;
        //+MM1.17 [259671]

        exit (GetMembershipValidDate (MemberShipEntryNo, ReferenceDate, ValidFromDate, ValidUntilDate));
    end;

    procedure IsMemberCardActive(ExternalCardNo: Text[50];ReferenceDate: Date): Boolean
    var
        CardEntryNo: Integer;
        MemberCard: Record "MM Member Card";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        ReasonNotFound: Text;
    begin

        MemberCard.Reset ();
        MemberCard.SetCurrentKey ("External Card No.");
        MemberCard.SetFilter (Blocked, '=%1', false);
        MemberCard.SetFilter ("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1 (ExternalCardNo));

        //-#300256 [300256]
        //MemberCard.SETFILTER ("Valid Until", '>=%1', ReferenceDate);

        //EXIT (MemberCard.FINDFIRST ());
        // Foreign cards might have more information then just a raw card number.
        if (not MemberCard.FindFirst ()) then begin
          GetMembershipFromForeignCardNo (ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);
          if ((CardEntryNo = 0) or (not MemberCard.Get (CardEntryNo))) then
            exit (false);
        end;

        if (not Membership.Get (MemberCard."Membership Entry No.")) then
          exit (false);

        MembershipSetup.Get (Membership."Membership Code");
        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA) then
          exit (true);

        exit (MemberCard."Valid Until" >= ReferenceDate);
        //+#300256 [300256]
    end;

    procedure IssueMemberCard(FailWithError: Boolean;MemberInfoCapture: Record "MM Member Info Capture";var CardEntryNo: Integer;var ResponseMessage: Text): Boolean
    var
        Member: Record "MM Member";
    begin

        // from external
        if (not IssueMemberCardWorker (FailWithError, MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture, true, CardEntryNo, ResponseMessage, false)) then
          exit (false);

        //-MM1.35 [332452]
        MemberInfoCapture.CalcFields (Picture);
        if (MemberInfoCapture.Picture.HasValue()) then begin
          if (Member.Get (MemberInfoCapture."Member Entry No")) then begin
            Member.Picture := MemberInfoCapture.Picture;
            Member.Modify ();
          end;
        end;
        //+MM1.35 [332452]

        exit (CardEntryNo <> 0);
    end;

    procedure CheckMemberUniqueId(CommunityCode: Code[20];MemberInfoCapture: Record "MM Member Info Capture") MemberEntryNo: Integer
    var
        Community: Record "MM Member Community";
        Member: Record "MM Member";
        MemberFound: Boolean;
    begin

        if (not Community.Get (CommunityCode)) then
          exit (-1);

        case Community."Member Unique Identity" of
          Community."Member Unique Identity"::NONE :
            Member.SetFilter ("Entry No.", '=%1', -1); // This should never match a current user
          Community."Member Unique Identity"::EMAIL :
            begin
              MemberInfoCapture.TestField ("E-Mail Address");
              Member.SetFilter ("E-Mail Address", '=%1', MemberInfoCapture."E-Mail Address");
            end;
          Community."Member Unique Identity"::PHONENO :
            begin
              MemberInfoCapture.TestField ("Phone No.");
              Member.SetFilter ("Phone No.", '=%1', MemberInfoCapture."Phone No.");
            end;
          Community."Member Unique Identity"::SSN :
            begin
              MemberInfoCapture.TestField ("Social Security No.");
              Member.SetFilter ("Social Security No.", '=%1', MemberInfoCapture."Social Security No.");
            end;
          else
            Error (CASE_MISSING, Community.FieldName ("Member Unique Identity"), Community."Member Unique Identity");
        end;

        Member.SetFilter (Blocked, '=%1', false);
        MemberFound := Member.FindFirst ();

        if (MemberFound) then begin
          //-#276832 [276832]
          if ((MemberInfoCapture."Guardian External Member No." <> '') and
              (MemberInfoCapture."Guardian External Member No." = Member."External Member No.")) then
            exit (0);
          //+#276832 [276832]

          case Community."Create Member UI Violation" of
            Community."Create Member UI Violation"::ERROR :
              Error (MEMBER_EXIST, Member.GetFilters());
            Community."Create Member UI Violation"::CONFIRM :
              if GuiAllowed then
                if not Confirm (MEMBER_REUSE, true, Member.GetFilters(), Member."First Name") then
                  Error (ABORTED);
            Community."Create Member UI Violation"::REUSE : ;
            else
              Error (CASE_MISSING, Community.FieldName ("Create Member UI Violation"), Community."Create Member UI Violation");
          end;
          exit (Member."Entry No.");
        end;

        exit (0);
    end;

    procedure BlockMembership(MembershipEntryNo: Integer;Block: Boolean)
    var
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
    begin

        Membership.Get (MembershipEntryNo);
        BlockMemberCards (MembershipEntryNo, 0, Block);

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipRole.FindSet ()) then begin
          repeat
            BlockMember (MembershipEntryNo, MembershipRole."Member Entry No.", Block);
          until (MembershipRole.Next () = 0);
        end;

        if (Membership.Blocked <> Block) then begin
          Membership.Validate (Blocked, Block);
          Membership.Modify ();
        end;
    end;

    procedure ReflectMembershipRoles(MembershipEntryNo: Integer;MemberEntryNo: Integer;Blocked: Boolean)
    var
        MembershipRole: Record "MM Membership Role";
        MembershipRole2: Record "MM Membership Role";
        MembershipSetup: Record "MM Membership Setup";
        MM_GDPRManagement: Codeunit "MM GDPR Management";
        GDPRManagement: Codeunit "GDPR Management";
        MemberInfoCapture: Record "MM Member Info Capture";
    begin

        if (not MembershipRole.Get (MembershipEntryNo, MemberEntryNo)) then
          exit;

        MembershipRole.CalcFields ("Membership Code");
        if (not MembershipSetup.Get (MembershipRole."Membership Code")) then
          exit;

        if (Blocked) then begin
          if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin
            // when all guardians are blocked, changes roles to admins and members
            MembershipRole2.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipRole2.SetFilter ("Member Role", '=%1', MembershipRole2."Member Role"::GUARDIAN);
            MembershipRole2.SetFilter ("Member Entry No.", '<>%1', MemberEntryNo);
            MembershipRole2.SetFilter (Blocked, '=%1', false);
            if (MembershipRole2.IsEmpty ()) then begin
              MembershipRole2.Reset();
              MembershipRole2.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
              MembershipRole2.SetFilter ("Member Entry No.", '<>%1', MemberEntryNo);
              if (MembershipRole2.FindSet ()) then begin
                repeat

                  if (MembershipRole2."GDPR Agreement No." <> '') then
                    GDPRManagement.CreateAgreementPendingEntry (MembershipRole2."GDPR Agreement No.", 0, MembershipRole2."GDPR Data Subject Id");

                  MembershipRole2."Member Role" := MembershipRole2."Member Role"::MEMBER;
                  if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::ALL_ADMINS) then
                    MembershipRole2."Member Role" := MembershipRole2."Member Role"::ADMIN;
                  MembershipRole2.Modify ();

                until (MembershipRole.Next () = 0);

                if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::FIRST_IS_ADMIN) then begin
                  MembershipRole2."Member Role" := MembershipRole2."Member Role"::ADMIN;
                  MembershipRole2.Modify ();
                end;
              end;
            end;
          end;

        end;

        if (not Blocked) then begin
          if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin
            // when a guardian is un-blocked, changes all non-guardians to dependents
            MembershipRole2.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipRole2.SetFilter ("Member Role", '<>%1', MembershipRole2."Member Role"::GUARDIAN);
            MembershipRole2.SetFilter (Blocked, '=%1', false);
            if (MembershipRole2.FindSet ()) then begin
              repeat
                MembershipRole2."Member Role" := MembershipRole2."Member Role"::DEPENDENT;
                MembershipRole2.Modify ();

                if (MembershipRole2."GDPR Agreement No." <> '') then
                  GDPRManagement.CreateAgreementDelegateToGuardianEntry (MembershipRole2."GDPR Agreement No.", 0, MembershipRole2."GDPR Data Subject Id");

              until (MembershipRole2.Next () = 0);
            end;

            MembershipRole.Get (MembershipEntryNo, MemberEntryNo);
            MembershipRole."Member Role" := MembershipRole."Member Role"::GUARDIAN;
            MembershipRole.Modify ();
          end;
        end;
    end;

    procedure BlockMember(MembershipEntryNo: Integer;MemberEntryNo: Integer;Block: Boolean)
    var
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
    begin

        //-+#319900 [319900] slightly refactored with protect on GET() functions.

        if (MembershipRole.Get (MembershipEntryNo, MemberEntryNo)) then begin
          if (MembershipRole.Blocked <> Block) then begin
            MembershipRole.Validate (Blocked, Block);
            MembershipRole.Modify ();
          end;

          //-MM1.22 [287080] Anonymous memberrole has no member
          if (MembershipRole."Member Role" <> MembershipRole."Member Role"::ANONYMOUS) then begin
            Member.Get (MemberEntryNo);
            if (Member.Blocked <> Block) then begin
              Member.Validate (Blocked, Block);
              Member.Modify ();
            end;
          end;
        end else begin

          if (Member.Get (MemberEntryNo)) then
            if (Member.Blocked <> Block) then begin
              Member.Validate (Blocked, Block);
              Member.Modify ();
            end;
        end;

        BlockMemberCards (MembershipEntryNo, MemberEntryNo, Block);
    end;

    procedure BlockMemberCards(MembershipEntryNo: Integer;MemberEntryNo: Integer;Block: Boolean)
    var
        MemberCard: Record "MM Member Card";
    begin

        MemberCard.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MemberCard.SetFilter ("Member Entry No.", '=%1', MemberEntryNo);
        if (MemberCard.FindSet ()) then begin
          repeat
            BlockMemberCard (MemberCard."Entry No.", Block);
          until (MemberCard.Next () = 0);
        end;
    end;

    procedure BlockMemberCard(CardEntryNo: Integer;Block: Boolean)
    var
        MemberCard: Record "MM Member Card";
    begin

        if (MemberCard.Get (CardEntryNo)) then begin
          if (MemberCard.Blocked <> Block) then begin
            MemberCard.Validate (Blocked, Block);
            MemberCard.Modify ();
          end;
        end;
    end;

    procedure CreateRegretMemberInfoRequest(ExternalMemberCardNo: Text[100];RegretWithItemNo: Code[20]) MemberInfoEntryNo: Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipEntry: Record "MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if not (Membership.Get (GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        if not (Member.Get (GetMemberFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then
          Error (MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;
        PrefillMemberInfoCapture (MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RegretWithItemNo);

        MemberInfoCapture."Document Date" := Today;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;

        if (not RegretMembership (MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
          Error ('');

        MemberInfoCapture.Insert ();
        exit (MemberInfoCapture."Entry No.");
    end;

    procedure RegretMembership(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal) Success: Boolean
    var
        ReasonText: Text;
    begin

        exit (RegretMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure RegretMembershipVerbose(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text) Success: Boolean
    begin

        exit (RegretMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure RegretMembershipWorker(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text) Success: Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
    begin

        //-MM1.25 [299783] Refactoring the membership alteration function to be able to be verbose
        if (MemberInfoCapture."Document Date" = 0D) then
          MemberInfoCapture."Document Date" := Today;

        Membership.Get (MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetCurrentKey ("Entry No."); //XXX
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then begin
          //-MM1.33 [323651]
          // ReasonText := STRSUBSTNO (NOT_FOUND, MembershipEntry.TABLECAPTION, MembershipEntry.GETFILTERS ());
          // EXIT (FALSE);
          MembershipEntry.Reset ();
          MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
          MembershipEntry.SetFilter ("Original Context", '=%1', MembershipEntry."Original Context"::NEW);
          MembershipEntry.SetFilter (Blocked, '=%1', true);
          if (not MembershipEntry.FindFirst ()) then begin
            ReasonText := StrSubstNo (NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters ());
            exit (false);
          end;
          //+MM1.33 [323651]
        end;

        SuggestedUnitPrice := MembershipEntry."Unit Price" * -1;

        //-MM1.33 [323651]
        if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then
          SuggestedUnitPrice := MembershipEntry."Unit Price";
        //+MM1.33 [323651]

        if (MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::REGRET, Membership."Membership Code", MemberInfoCapture."Item No.")) then
          if (not ValidAlterationGracePeriod (MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then begin
            ReasonText := StrSubstNo (GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
            exit (false);
          end;

        if ((WithConfirm) and (GuiAllowed)) then
          if (not Confirm (CONFIRM_REGRET, false, Membership."External Membership No.", MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date")) then
            exit (false);

        //-MM1.25 [299783]
        ReasonText := StrSubstNo ('%1: %2 {%3 .. %4}', MemberInfoCapture."Information Context", MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
        //+MM1.25 [299783]

        if (WithUpdate) then begin

          if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then begin
            DoReverseRegretTimeFrame (MembershipEntry);
          end else begin
            DoRegretTimeframe (MembershipEntry);
          end;

        end;

        OutStartDate := MembershipEntry."Valid From Date";
        OutUntilDate := MembershipEntry."Valid Until Date";

        exit (true);
    end;

    local procedure DoReverseRegretTimeFrame(var MembershipEntry: Record "MM Membership Entry")
    begin

        if not ((MembershipEntry.Context = MembershipEntry.Context::REGRET) and (MembershipEntry."Original Context" = MembershipEntry."Original Context"::NEW)) then
          Error ('Only the initial new transaction may be reverse regretted.');

        MembershipEntry.Context := MembershipEntry."Original Context";
        MembershipEntry.Validate (Blocked, false);
        MembershipEntry.Modify ();

        OnAfterInsertMembershipEntry  (MembershipEntry);

        OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
    end;

    procedure DoRegretTimeframe(var MembershipEntry: Record "MM Membership Entry")
    var
        Membership: Record "MM Membership";
        MembershipAutoRenew: Codeunit "MM Membership Auto Renew";
    begin

        //-MM1.26 [305631]
        // Note - also invoked from MM Member WebService Mgr

        if (MembershipEntry.Context = MembershipEntry.Context::AUTORENEW) then
          MembershipAutoRenew.ReverseInvoice (MembershipEntry."Document No.");

        MembershipEntry."Original Context" := MembershipEntry.Context;
        MembershipEntry.Context := MembershipEntry.Context::REGRET;
        MembershipEntry.Validate (Blocked, true);
        MembershipEntry.Modify ();

        OnAfterInsertMembershipEntry  (MembershipEntry);

        if (MembershipEntry.Next (-1) <> 0) then begin
          if (Format (MembershipEntry."Duration Dateformula") <> '') then begin
            MembershipEntry."Valid Until Date" := CalcDate (MembershipEntry."Duration Dateformula", MembershipEntry."Valid From Date");
            MembershipEntry.Modify ();
          end;

          //-MM1.29 [316141]
          if (MembershipEntry."Original Context" = MembershipEntry."Original Context"::UPGRADE) then begin
            MembershipEntry."Valid Until Date" := GetUpgradeInitialValidUntilDate (MembershipEntry."Entry No.");
            MembershipEntry.Modify ();
          end;
          //+MM1.29 [316141]

          Membership.Get (MembershipEntry."Membership Entry No.");
          if (Membership."Membership Code" <> MembershipEntry."Membership Code") then begin
            Membership."Membership Code" := MembershipEntry."Membership Code";
            Membership.Modify ();
          end;
        end;

        OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
        //+MM1.26 [305631]
    end;

    procedure CreateCancelMemberInfoRequest(ExternalMemberCardNo: Text[50];CancelWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipEntry: Record "MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if not (Membership.Get (GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        if not (Member.Get (GetMemberFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        MembershipEntry.SetCurrentKey ("Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then
          Error (MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture (MemberInfoCapture, Member, Membership, ExternalMemberCardNo, CancelWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not CancelMembership (MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
          Error ('');

        MemberInfoCapture.Insert ();
        exit (MemberInfoCapture."Entry No.");
    end;

    procedure CancelMembership(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit (CancelMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure CancelMembershipVerbose(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    begin

        exit (CancelMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure CancelMembershipWorker(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        Item: Record Item;
        EndDateNew: Date;
        CancelledFraction: Decimal;
        NewFraction: Decimal;
    begin

        //-MM1.25 [299783] Refactoring the membership alteration function to be able to be verbose
        OutStartDate := 0D;
        OutUntilDate := 0D;
        SuggestedUnitPrice := 0;

        if (MemberInfoCapture."Document Date" = 0D) then
          MemberInfoCapture."Document Date" := Today;

        Membership.Get (MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then begin
          ReasonText := StrSubstNo (NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters ());
          exit (false);
        end;

        MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::CANCEL, Membership."Membership Code", MemberInfoCapture."Item No.");
        if (not ValidAlterationGracePeriod (MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then begin
          ReasonText := StrSubstNo (GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
          exit (false);
        end;

        Item.Get (MemberInfoCapture."Item No.");

        case MembershipAlterationSetup."Alteration Activate From" of
          MembershipAlterationSetup."Alteration Activate From"::ASAP : EndDateNew := MemberInfoCapture."Document Date";
          MembershipAlterationSetup."Alteration Activate From"::DF   : EndDateNew := CalcDate (MembershipAlterationSetup."Alteration Date Formula", MemberInfoCapture."Document Date");
        end;

        if (MembershipEntry."Valid Until Date" <= EndDateNew) then begin
          ReasonText := StrSubstNo (NO_TIMEFRAME, EndDateNew, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));
        end;

        if (EndDateNew <= MembershipEntry."Valid From Date") then begin
          ReasonText := StrSubstNo (NO_TIMEFRAME, EndDateNew, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));
        end;

        if ((WithConfirm) and (GuiAllowed)) then
          if (not Confirm (CONFIRM_CANCEL, false, MembershipAlterationSetup.Description, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", EndDateNew)) then
            exit (false);

        CancelledFraction := 1 - CalculatePeriodStartToDateFraction (MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", EndDateNew);
        NewFraction :=  0;
        case MembershipAlterationSetup."Price Calculation" of
          MembershipAlterationSetup."Price Calculation"::UNIT_PRICE : SuggestedUnitPrice := -1 * MembershipEntry."Unit Price";
          MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE : SuggestedUnitPrice := Round (-CancelledFraction * MembershipEntry."Unit Price", 1);
          MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE : SuggestedUnitPrice := 0;
        end;

        //-MM1.25 [299783]
        ReasonText := StrSubstNo ('%1: %2 {%3 .. %4}', MemberInfoCapture."Information Context", MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
        //+MM1.25 [299783]

        if (WithUpdate) then begin
          MembershipEntry."Valid Until Date" := EndDateNew;
          MembershipEntry.Modify ();

          //-MM1.25 [300685]
          OnAfterInsertMembershipEntry  (MembershipEntry);
          //+MM1.25 [300685]

          OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := MembershipEntry."Valid From Date";
        OutUntilDate := EndDateNew;

        exit (true);
    end;

    procedure CreateRenewMemberInfoRequest(ExternalMemberCardNo: Text[50];RenewWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipEntry: Record "MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get (GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        if not (Member.Get (GetMemberFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        MembershipEntry.SetCurrentKey ("Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then
          Error (MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        //-#293269 [293269]
        if (MembershipEntry."Activate On First Use") then
          Error (NOT_ACTIVATED);
        //+#293269 [293269]

        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture (MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RenewWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not RenewMembership (MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
          Error ('');

        MemberInfoCapture.Insert ();
        exit (MemberInfoCapture."Entry No.");
    end;

    procedure RenewMembership(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit (RenewMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure RenewMembershipVerbose(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    begin

        exit (RenewMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure RenewMembershipWorker(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        Item: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EntryNo: Integer;
        NeedExtendMemberCard: Boolean;
        CardEntryNo: Integer;
    begin

        //-MM1.25 [299783] Refactoring the membership alteration function to be able to be verbose
        if (MemberInfoCapture."Document Date" = 0D) then
          MemberInfoCapture."Document Date" := Today;

        Membership.Get (MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);

        ReasonText := StrSubstNo (NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters ());
        if (not MembershipEntry.FindLast ()) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (NOT_FOUND, MembershipAlterationSetup.TableCaption, '');
        if (not MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::RENEW, Membership."Membership Code", MemberInfoCapture."Item No.")) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod (MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        Item.Get (MemberInfoCapture."Item No.");

        if (MembershipEntry."Valid Until Date" < Today) then
          MembershipEntry."Valid Until Date" := CalcDate ('<-1D>', Today);

        case MembershipAlterationSetup."Alteration Activate From" of
          MembershipAlterationSetup."Alteration Activate From"::ASAP : StartDateNew := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
          MembershipAlterationSetup."Alteration Activate From"::DF   : StartDateNew := CalcDate (MembershipAlterationSetup."Alteration Date Formula", MembershipEntry."Valid Until Date");
        end;

        if (StartDateNew < Today) then
          StartDateNew := Today;

        EndDateNew := CalcDate (MembershipAlterationSetup."Membership Duration", StartDateNew);

        ReasonText := StrSubstNo (CONFLICTING_ENTRY, StartDateNew, EndDateNew);

        //-MM1.36 [338771]
        //IF (StartDateNew <= MembershipEntry."Valid From Date") THEN
        if (StartDateNew <= MembershipEntry."Valid Until Date") then
        //+MM1.36 [338771]
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (STACKING_NOT_ALLOWED, Membership."Entry No.", Today);
        if (not MembershipAlterationSetup."Stacking Allowed") then
          if (GetLedgerEntryForDate (Membership."Entry No.", Today, EntryNo)) then
            if (EntryNo <> MembershipEntry."Entry No.") then
              exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        if (WithConfirm) and (GuiAllowed) then
          if (not Confirm (RENEW_MEMBERSHIP, false, MembershipAlterationSetup.Description, StartDateNew, EndDateNew)) then
            exit (false);

        if (MembershipAlterationSetup."To Membership Code" <> '') then
          if (not (ValidateChangeMembershipCode (WithConfirm, Membership."Entry No.", StartDateNew, MembershipAlterationSetup."To Membership Code", ReasonText))) then
            exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        case MembershipAlterationSetup."Price Calculation" of
          MembershipAlterationSetup."Price Calculation"::UNIT_PRICE : SuggestedUnitPrice := Item."Unit Price";
          MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE : SuggestedUnitPrice := Item."Unit Price";
          MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE : SuggestedUnitPrice := Item."Unit Price";
        end;

        //-MM1.22 [287080]
        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration (Membership."Entry No.", MembershipAlterationSetup);
        //+MM1.22 [287080]

        //-#300256 [300256]
        NeedExtendMemberCard := RequireExtendMemberCard (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Card No.", EndDateNew, MembershipAlterationSetup, CardEntryNo);
        if (NeedExtendMemberCard) then
          if (not AllowExtendMemberCard (CardEntryNo, MembershipAlterationSetup, EndDateNew, ReasonText)) then
            exit (ExitFalseOrWithError (WithConfirm, ReasonText));
        //-#300256 [300256]

        //-MM1.25 [299783]
        ReasonText := StrSubstNo ('%1: %4 -> %5 {%2 .. %3}', MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code");
        //+MM1.25 [299783]

        if (WithUpdate) then begin
          MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
          if (MembershipAlterationSetup."To Membership Code" <> '') then
            if (MembershipAlterationSetup."From Membership Code" <> MembershipAlterationSetup."To Membership Code") then begin
              Membership."Membership Code" := MembershipAlterationSetup."To Membership Code";
              Membership.Modify ();
            end;

          MemberInfoCapture."Membership Code" := Membership."Membership Code";
          //-MM1.19 [270308]
          if (NeedExtendMemberCard) then
            if (not ExtendMemberCard (false, MemberInfoCapture."Membership Entry No.", CardEntryNo, MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."Card Entry No.", ReasonText)) then
              exit (ExitFalseOrWithError (WithConfirm, ReasonText));
          //-MM1.19 [270308]
          EntryNo := AddMembershipLedgerEntry (MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

          OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit (true);
    end;

    procedure CreateExtendMemberInfoRequest(ExternalMemberCardNo: Text[50];RenewWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipEntry: Record "MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get (GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        if not (Member.Get (GetMemberFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        MembershipEntry.SetCurrentKey ("Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then
          Error (MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture (MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RenewWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not ExtendMembership (MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
          Error ('');

        MemberInfoCapture.Insert ();
        exit (MemberInfoCapture."Entry No.");
    end;

    procedure ExtendMembership(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit (ExtendMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure ExtendMembershipVerbose(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    begin

        exit (ExtendMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure ExtendMembershipWorker(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        Item: Record Item;
        OldItem: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EndDateCurrent: Date;
        EntryNo: Integer;
        CancelledFraction: Decimal;
        NewFraction: Decimal;
        StartDateLedgerEntryNo: Integer;
        EndDateLedgerEntryNo: Integer;
        NeedExtendMemberCard: Boolean;
        CardEntryNo: Integer;
    begin

        OutStartDate := 0D;
        OutUntilDate := 0D;
        SuggestedUnitPrice := 0;

        if (MemberInfoCapture."Document Date" = 0D) then
          MemberInfoCapture."Document Date" := Today;

        Membership.Get (MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo (NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters ());
        if (not MembershipEntry.FindLast ()) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (NOT_FOUND, MembershipAlterationSetup.TableCaption, '');
        if (not MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::EXTEND, Membership."Membership Code", MemberInfoCapture."Item No.")) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod (MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        Item.Get (MemberInfoCapture."Item No.");

        case MembershipAlterationSetup."Alteration Activate From" of
          MembershipAlterationSetup."Alteration Activate From"::ASAP : StartDateNew := MemberInfoCapture."Document Date";
          MembershipAlterationSetup."Alteration Activate From"::DF   : StartDateNew := CalcDate (MembershipAlterationSetup."Alteration Date Formula", MemberInfoCapture."Document Date");
        end;

        EndDateNew := CalcDate (MembershipAlterationSetup."Membership Duration", StartDateNew);
        EndDateCurrent := 0D;
        if (MembershipEntry."Valid Until Date" >= StartDateNew) then
          EndDateCurrent := CalcDate ('<-1D>', StartDateNew);

        ReasonText := StrSubstNo (CONFLICTING_ENTRY, StartDateNew, EndDateNew);
        if (StartDateNew <= MembershipEntry."Valid From Date") then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (EXTEND_TO_SHORT, EndDateNew, MembershipEntry."Valid Until Date");
        if (EndDateNew < MembershipEntry."Valid Until Date") then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (MULTIPLE_TIMEFRAMES, MembershipAlterationSetup."Alteration Type", Membership."Entry No.", StartDateNew, EndDateNew, StartDateLedgerEntryNo, EndDateLedgerEntryNo);
        if (ConflictingLedgerEntries (Membership."Entry No.", StartDateNew, EndDateNew, StartDateLedgerEntryNo, EndDateLedgerEntryNo)) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        if ((WithConfirm) and (GuiAllowed)) then
          if (not Confirm (EXTEND_MEMBERSHIP, false, MembershipAlterationSetup.Description, StartDateNew, EndDateNew)) then
            exit (false);

        if (MembershipAlterationSetup."To Membership Code" <> '') then
          if (not (ValidateChangeMembershipCode (WithConfirm, Membership."Entry No.", StartDateNew, MembershipAlterationSetup."To Membership Code", ReasonText))) then
            exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        //-MM1.29 [316141]
        if (MembershipEntry."Unit Price (Base)" = 0) then begin
          OldItem.Get (MembershipEntry."Item No.");
          MembershipEntry."Unit Price (Base)" := OldItem."Unit Price";
        end;
        //+MM1.29 [316141]

        CancelledFraction := 1 - CalculatePeriodStartToDateFraction (MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", StartDateNew);
        NewFraction :=  1 - CalculatePeriodStartToDateFraction (StartDateNew, EndDateNew, MembershipEntry."Valid Until Date");
        case MembershipAlterationSetup."Price Calculation" of
          MembershipAlterationSetup."Price Calculation"::UNIT_PRICE : SuggestedUnitPrice := Item."Unit Price";
          //-MM1.29 [316141]
          //MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE : SuggestedUnitPrice := ROUND (-CancelledFraction * MembershipEntry."Unit Price" + Item."Unit Price", 0.01);
          MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE : SuggestedUnitPrice := Round (-CancelledFraction * MembershipEntry."Unit Price (Base)" + Item."Unit Price", 0.01);
          //+MM1.29 [316141]
          MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE : SuggestedUnitPrice := Round (NewFraction * Item."Unit Price", 0.01);
        end;

        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration (Membership."Entry No.", MembershipAlterationSetup);

        NeedExtendMemberCard := RequireExtendMemberCard (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Card No.", EndDateNew, MembershipAlterationSetup, CardEntryNo);
        if (NeedExtendMemberCard) then
          if (not AllowExtendMemberCard (CardEntryNo, MembershipAlterationSetup, EndDateNew, ReasonText)) then
            exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo ('%1: %4 -> %5 {%2 .. %3}', MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code");

        if (WithUpdate) then begin
          MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
          if (MembershipAlterationSetup."To Membership Code" <> '') then
            if (MembershipAlterationSetup."From Membership Code" <> MembershipAlterationSetup."To Membership Code") then begin
              Membership."Membership Code" := MembershipAlterationSetup."To Membership Code";
              Membership.Modify ();
            end;

          MemberInfoCapture."Membership Code" := Membership."Membership Code";


          if (NeedExtendMemberCard) then
            if (not ExtendMemberCard (false, MemberInfoCapture."Membership Entry No.", CardEntryNo, MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."Card Entry No.", ReasonText)) then
              exit (ExitFalseOrWithError (WithConfirm, ReasonText));

          EntryNo := AddMembershipLedgerEntry (MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

          if (EndDateCurrent <> 0D) then begin
            if (EndDateCurrent <= MembershipEntry."Valid From Date") then begin
              MembershipEntry.Blocked := true;
              MembershipEntry."Blocked At" := CurrentDateTime ();
              MembershipEntry."Blocked By" := UserId;
            end else begin
              MembershipEntry."Valid Until Date" := EndDateCurrent;
            end;
            MembershipEntry."Closed By Entry No." := EntryNo;
            MembershipEntry.Modify ();
          end;

          OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit (true);
    end;

    procedure CreateUpgradeMemberInfoRequest(ExternalMemberCardNo: Text[50];UpgradeWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipEntry: Record "MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get (GetMembershipFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        if not (Member.Get (GetMemberFromExtCardNo (ExternalMemberCardNo, Today, NotFoundReasonText))) then
          Error (NotFoundReasonText);

        MembershipEntry.SetCurrentKey ("Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then
          Error (MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;

        //PrefillMemberInfoCapture (MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RenewWithItemNo);
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Item No." := UpgradeWithItemNo;

        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not UpgradeMembership (MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
          Error ('');

        MemberInfoCapture.Insert ();
        exit (MemberInfoCapture."Entry No.");
    end;

    procedure UpgradeMembership(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit (UpgradeMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure UpgradeMembershipVerbose(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    begin

        exit (UpgradeMembershipWorker (MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure UpgradeMembershipWorker(MemberInfoCapture: Record "MM Member Info Capture";WithConfirm: Boolean;WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        Item: Record Item;
        OldItem: Record Item;
        StartDateNew: Date;
        EndDateCurrent: Date;
        EndDateNew: Date;
        EntryNo: Integer;
        RemainingFraction: Decimal;
        NeedExtendMemberCard: Boolean;
        CardEntryNo: Integer;
        ValidFromDate: Date;
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
          MemberInfoCapture."Document Date" := Today;

        Membership.Get (MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo (NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters ());
        if (not MembershipEntry.FindLast ()) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (NOT_FOUND, MembershipAlterationSetup.TableCaption, '');
        if (not MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::UPGRADE, Membership."Membership Code", MemberInfoCapture."Item No.")) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod (MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        Item.Get (MemberInfoCapture."Item No.");

        case MembershipAlterationSetup."Alteration Activate From" of
          MembershipAlterationSetup."Alteration Activate From"::ASAP : StartDateNew := MemberInfoCapture."Document Date";
          MembershipAlterationSetup."Alteration Activate From"::DF   :
            begin
              ReasonText := FUTUREDATE_NOT_SUPPORTED;
              exit (ExitFalseOrWithError (WithConfirm, ReasonText));
            end;
        end;

        EndDateCurrent := CalcDate ('<-1D>', StartDateNew);
        EndDateNew := MembershipEntry."Valid Until Date";

        if (MembershipAlterationSetup."Upgrade With New Duration") then
          EndDateNew := CalcDate (MembershipAlterationSetup."Membership Duration", StartDateNew);

        ReasonText := StrSubstNo (MEMBERSHIP_ENTRY_NOT_FOUND, Membership."External Membership No.");
        if (MembershipEntry."Valid Until Date" < StartDateNew) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        ReasonText := StrSubstNo (CONFLICTING_ENTRY, StartDateNew, MembershipEntry."Valid Until Date");
        if (StartDateNew < MembershipEntry."Valid From Date") then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        if (WithConfirm) and (GuiAllowed) then
          if (not Confirm (UPGRADE_MEMBERSHIP, false, MembershipAlterationSetup.Description, StartDateNew, EndDateNew)) then
            exit (false);

        if (not (ValidateChangeMembershipCode (WithConfirm, Membership."Entry No.", StartDateNew, MembershipAlterationSetup."To Membership Code", ReasonText))) then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        //-MM1.29 [316141]
        if (MembershipEntry."Unit Price (Base)" = 0) then begin
          OldItem.Get (MembershipEntry."Item No.");
          MembershipEntry."Unit Price (Base)" := OldItem."Unit Price";
        end;
        ValidFromDate := GetUpgradeInitialValidFromDate (MembershipEntry."Entry No.");
        //+MM1.29 [316141]

        RemainingFraction := 1 - CalculatePeriodStartToDateFraction (ValidFromDate, EndDateNew, StartDateNew);
        case MembershipAlterationSetup."Price Calculation" of
          MembershipAlterationSetup."Price Calculation"::UNIT_PRICE : SuggestedUnitPrice := Item."Unit Price";
          //-MM1.29 [316141]
          //MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE : SuggestedUnitPrice := -CancelledFraction * MembershipEntry."Unit Price" + CancelledFraction * Item."Unit Price";
          MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE : SuggestedUnitPrice := -RemainingFraction * MembershipEntry."Unit Price (Base)" + RemainingFraction * Item."Unit Price";
          //+MM1.29 [316141]

          MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE : SuggestedUnitPrice := RemainingFraction * Item."Unit Price";
        end;

        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration (Membership."Entry No.", MembershipAlterationSetup);

        //-#300256 [300256]
        NeedExtendMemberCard := RequireExtendMemberCard (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Card No.", EndDateNew, MembershipAlterationSetup, CardEntryNo);
        if (NeedExtendMemberCard) then
          if (not AllowExtendMemberCard (CardEntryNo, MembershipAlterationSetup, EndDateNew, ReasonText)) then
            exit (ExitFalseOrWithError (WithConfirm, ReasonText));
        //-#300256 [300256]

        ReasonText := StrSubstNo ('%1: %4 -> %5 {%2 .. %3} {%6 {%7,%8} -> %9}',
                                  MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code",
                                  Round(RemainingFraction,0.01), Item."Unit Price", MembershipEntry."Unit Price (Base)", Round(SuggestedUnitPrice,0.01));

        if (WithUpdate) then begin
          MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
          if (MembershipAlterationSetup."From Membership Code" <> MembershipAlterationSetup."To Membership Code") then begin
            Membership."Membership Code" := MembershipAlterationSetup."To Membership Code";
            Membership.Modify ();
          end;

          MemberInfoCapture."Membership Code" := Membership."Membership Code";
          if (NeedExtendMemberCard) then
            if (not ExtendMemberCard (false, MemberInfoCapture."Membership Entry No.", CardEntryNo, MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."Card Entry No.", ReasonText)) then
              exit (ExitFalseOrWithError (WithConfirm, ReasonText));

          EntryNo := AddMembershipLedgerEntry (MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);
          if (StartDateNew = MembershipEntry."Valid From Date") then begin
            //MembershipEntry.Blocked := TRUE;
            //MembershipEntry."Blocked At" := CURRENTDATETIME;
            //XXMembershipEntry."Blocked By" := USERID;
          end;
          MembershipEntry."Valid Until Date" := EndDateCurrent;
          MembershipEntry."Closed By Entry No." := EntryNo;

          MembershipEntry.Modify ();

          OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit (true);
    end;

    local procedure GetUpgradeInitialValidFromDate(EntryNo: Integer) ValidFrom: Date
    var
        MembershipEntry: Record "MM Membership Entry";
    begin
        MembershipEntry.Get (EntryNo);
        if (MembershipEntry.Context <> MembershipEntry.Context::UPGRADE) then
          exit (MembershipEntry."Valid From Date");

        MembershipEntry.Reset ();
        MembershipEntry.SetFilter ("Closed By Entry No.", '=%1', EntryNo);
        if (MembershipEntry.FindFirst ()) then
          ValidFrom := GetUpgradeInitialValidFromDate (MembershipEntry."Entry No.");
    end;

    local procedure GetUpgradeInitialValidUntilDate(EntryNo: Integer) ValidUntil: Date
    var
        MembershipEntry: Record "MM Membership Entry";
    begin
        MembershipEntry.Get (EntryNo);
        if (MembershipEntry.Context <> MembershipEntry.Context::UPGRADE) then
          exit (CalcDate (MembershipEntry."Duration Dateformula", MembershipEntry."Valid From Date"));

        MembershipEntry.Reset ();
        MembershipEntry.SetFilter ("Closed By Entry No.", '=%1', EntryNo);
        if (MembershipEntry.FindFirst ()) then
          ValidUntil := GetUpgradeInitialValidUntilDate (MembershipEntry."Entry No.");
    end;

    procedure CalculateRemainingAmount(MembershipEntry: Record "MM Membership Entry";var OriginalAmountLCY: Decimal;var RemainingAmountLCY: Decimal;var DueDate: Date): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin

        OriginalAmountLCY := 0;
        RemainingAmountLCY := 0;
        DueDate := 0D;

        if (MembershipEntry."Document No." = '') then
          exit (false);

        if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then
          exit (true);

        if (not SalesInvoiceHeader.Get (MembershipEntry."Document No.")) then begin
          SalesInvoiceHeader.SetFilter ("Pre-Assigned No.", '=%1', MembershipEntry."Document No.");
          if (not SalesInvoiceHeader.FindFirst ()) then
            exit (false);
        end;

        CustLedgerEntry.SetFilter ("Document No.", '=%1', SalesInvoiceHeader."No.");
        if (not CustLedgerEntry.FindFirst ()) then
          exit (false);

        CustLedgerEntry.CalcFields ("Original Amt. (LCY)", "Remaining Amt. (LCY)");
        OriginalAmountLCY := CustLedgerEntry."Original Amt. (LCY)";
        RemainingAmountLCY := CustLedgerEntry."Remaining Amt. (LCY)";
        DueDate := CustLedgerEntry."Due Date";
        exit (true);
    end;

    procedure CreateAutoRenewMemberInfoRequest(MembershipEntryNo: Integer;RenewWithItemNo: Code[20];var ReasonText: Text): Integer
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipSalesSetup: Record "MM Membership Sales Setup";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        HaveAutoRenewItem: Boolean;
    begin

        if (not Membership.Get (MembershipEntryNo)) then begin
          ReasonText := StrSubstNo (NOT_FOUND, Membership.TableCaption, MembershipEntryNo);
          exit (0);
        end;

        MembershipEntry.SetCurrentKey ("Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast ()) then begin
          ReasonText := TIME_ENTRY_NOT_FOUND;
          exit (0);
        end;

        HaveAutoRenewItem := (RenewWithItemNo <> '');
        if (not HaveAutoRenewItem) then begin
          case MembershipEntry.Context of
            MembershipEntry.Context::NEW :
              begin
                HaveAutoRenewItem := MembershipSalesSetup.Get (MembershipSalesSetup.Type::ITEM, MembershipEntry."Item No.");
                RenewWithItemNo := MembershipSalesSetup."Auto-Renew To";
              end;
            MembershipEntry.Context::RENEW :
              begin
                HaveAutoRenewItem := MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::RENEW, Membership."Membership Code", MembershipEntry."Item No.");
                RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
              end;
            MembershipEntry.Context::EXTEND :
              begin
                HaveAutoRenewItem := MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::EXTEND, Membership."Membership Code", MembershipEntry."Item No.");
                RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
              end;
            MembershipEntry.Context::UPGRADE :
              begin
                HaveAutoRenewItem := MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::UPGRADE, Membership."Membership Code", MembershipEntry."Item No.");
                RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
              end;
            MembershipEntry.Context::AUTORENEW :
              begin
                HaveAutoRenewItem := MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", MembershipEntry."Item No.");
                RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
              end;
          end;
        end;

        //-MM1.30 [317508], fallback to a standard auto-renew rule that is not based on the previous alteration action
        if (not HaveAutoRenewItem) then begin
          HaveAutoRenewItem := MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", MembershipEntry."Item No.");
          RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
        end;
        //+MM1.30 [317508]

        if (not HaveAutoRenewItem) then begin
          ReasonText := StrSubstNo (NOT_FOUND, 'Auto-Renew rule', StrSubstNo ('%1 for %2', MembershipEntry.Context, MembershipEntry."Item No."));
          exit (0);
        end;

        if (RenewWithItemNo = '') then begin
          ReasonText := StrSubstNo (NOT_FOUND, 'Auto-Renew rule item', StrSubstNo ('%1 for %2', MembershipEntry.Context, MembershipEntry."Item No."));
          exit (0);
        end;

        //-#303635 [303635]
        if (not MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", RenewWithItemNo)) then begin
          ReasonText := StrSubstNo (NOT_FOUND, 'Auto-Renew item', StrSubstNo ('%1 with %2', MembershipEntry.Context::AUTORENEW, RenewWithItemNo));
          exit (0);
        end;
        //+#303635 [303635]


        MemberInfoCapture.Init ();
        MemberInfoCapture."Entry No." := 0;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Item No." := RenewWithItemNo;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not AutoRenewMembershipWorker (MemberInfoCapture, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price", ReasonText)) then
          exit (0);

        MemberInfoCapture."Valid Until" := MembershipStartDate;
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;

        MemberInfoCapture.Insert ();
        exit (MemberInfoCapture."Entry No.");
    end;

    procedure AutoRenewMembership(var MemberInfoCapture: Record "MM Member Info Capture";WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit (AutoRenewMembershipWorker (MemberInfoCapture, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure AutoRenewMembershipWorker(var MemberInfoCapture: Record "MM Member Info Capture";WithUpdate: Boolean;var OutStartDate: Date;var OutUntilDate: Date;var SuggestedUnitPrice: Decimal;var ReasonText: Text): Boolean
    var
        MembershipAutoRenew: Codeunit "MM Membership Auto Renew";
        Membership: Record "MM Membership";
        MembershipEntry: Record "MM Membership Entry";
        MembershipAlterationSetup: Record "MM Membership Alteration Setup";
        Item: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EntryNo: Integer;
        NeedExtendMemberCard: Boolean;
        CardEntryNo: Integer;
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
          MemberInfoCapture."Document Date" := Today;

        Membership.Get (MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        MembershipEntry.SetFilter (Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo (NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters ());
        if (not MembershipEntry.FindLast ()) then
          exit (false);

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
          exit (false);

        MembershipAlterationSetup.Get (MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", MemberInfoCapture."Item No.");
        ReasonText := StrSubstNo (GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod (MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
          exit (false);

        Item.Get (MemberInfoCapture."Item No.");

        if (MembershipEntry."Valid Until Date" < Today) then
          MembershipEntry."Valid Until Date" := CalcDate ('<-1D>', Today);

        case MembershipAlterationSetup."Alteration Activate From" of
          MembershipAlterationSetup."Alteration Activate From"::ASAP : StartDateNew := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
          MembershipAlterationSetup."Alteration Activate From"::DF   : StartDateNew := CalcDate (MembershipAlterationSetup."Alteration Date Formula", MembershipEntry."Valid Until Date");
        end;

        if (StartDateNew < Today) then
          StartDateNew := Today;

        EndDateNew := CalcDate (MembershipAlterationSetup."Membership Duration", StartDateNew);

        //-MM1.36 [338771]
        // IF (StartDateNew <= MembershipEntry."Valid From Date") THEN
        if (StartDateNew <= MembershipEntry."Valid Until Date") then
        //+MM1.36 [338771]
          exit (ExitFalseOrWithError (false, StrSubstNo (CONFLICTING_ENTRY, StartDateNew, EndDateNew)));

        if (not MembershipAlterationSetup."Stacking Allowed") then
          if (GetLedgerEntryForDate (Membership."Entry No.", Today, EntryNo)) then
            if (EntryNo <> MembershipEntry."Entry No.") then
              exit (ExitFalseOrWithError (false, StrSubstNo (STACKING_NOT_ALLOWED, Membership."Entry No.", Today)));

        SuggestedUnitPrice := Item."Unit Price";
        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration (Membership."Entry No.", MembershipAlterationSetup);

        NeedExtendMemberCard := RequireExtendMemberCard (MemberInfoCapture."Membership Entry No.", MemberInfoCapture."External Card No.", EndDateNew, MembershipAlterationSetup, CardEntryNo);
        if (NeedExtendMemberCard) then
          if (not AllowExtendMemberCard (CardEntryNo, MembershipAlterationSetup, EndDateNew, ReasonText)) then
            exit (ExitFalseOrWithError (false, ReasonText));

        if (WithUpdate) then begin
          MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
          MemberInfoCapture."Membership Code" := Membership."Membership Code";

          if (not MembershipAutoRenew.CreateInvoice (MemberInfoCapture, StartDateNew, EndDateNew)) then
            exit (false);

          if (NeedExtendMemberCard) then
            ExtendMemberCard (false, MemberInfoCapture."Membership Entry No.", CardEntryNo, MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."Card Entry No.", ReasonText);

          EntryNo := AddMembershipLedgerEntry (MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

          OnMembershipChangeEvent (MembershipEntry."Membership Entry No.");
        end;

        ReasonText := 'Ok';
        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit (true);
    end;

    local procedure RequireExtendMemberCard(MembershipEntryNo: Integer;ExternalMemberCardNo: Text[50];NewEndDate: Date;AlterationSetup: Record "MM Membership Alteration Setup";var CardEntryNo: Integer): Boolean
    var
        MemberCard: Record "MM Member Card";
    begin

        MemberCard.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (ExternalMemberCardNo = '') then begin
          MemberCard.SetFilter (Blocked, '=%1', false);
          if (MemberCard.IsEmpty ()) then
            exit (false);
          MemberCard.FindLast();
          ExternalMemberCardNo := MemberCard."External Card No.";
        end;

        MemberCard.SetFilter ("External Card No.", '=%1', ExternalMemberCardNo);
        MemberCard.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);

        if (not MemberCard.FindFirst ()) then
          exit (false);

        CardEntryNo := MemberCard."Entry No.";

        case AlterationSetup."Card Expired Action" of
          AlterationSetup."Card Expired Action"::IGNORE :  exit (false);
          AlterationSetup."Card Expired Action"::PREVENT : exit (true);
          AlterationSetup."Card Expired Action"::UPDATE : exit (NewEndDate > MemberCard."Valid Until");
          AlterationSetup."Card Expired Action"::NEW :    exit (NewEndDate > MemberCard."Valid Until");
        end;

        exit (false); // No need to extend card
    end;

    local procedure AllowExtendMemberCard(CardEntryNo: Integer;AlterationSetup: Record "MM Membership Alteration Setup";NewEndDate: Date;var ReasonText: Text): Boolean
    var
        MemberCard: Record "MM Member Card";
        TmpReasonText: Text;
    begin

        TmpReasonText := '';
        if (not MemberCard.Get (CardEntryNo)) then
          TmpReasonText := StrSubstNo (MEMBERCARD_NOT_FOUND, StrSubstNo ('%1 %2', MemberCard.FieldCaption("Entry No."), CardEntryNo));

        if (AlterationSetup."Card Expired Action" = AlterationSetup."Card Expired Action"::PREVENT) then
          if (NewEndDate > MemberCard."Valid Until") then
            TmpReasonText := StrSubstNo (PREVENT_CARD_EXTEND, MemberCard."External Card No.", NewEndDate);

        if (TmpReasonText <> '') then
          ReasonText := TmpReasonText;

        exit (TmpReasonText = '');
    end;

    local procedure ExtendMemberCard(FailWithError: Boolean;MembershipEntryNo: Integer;CardEntryNo: Integer;ExpiredCardOption: Integer;NewTimeFrameEndDate: Date;var MemberCardEntryNoOut: Integer;ResponseMessage: Text): Boolean
    var
        MemberInfoCapture: Record "MM Member Info Capture";
        AlterationSetup: Record "MM Membership Alteration Setup";
        MemberCard: Record "MM Member Card";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        NewUntilDate: Date;
    begin

        //-#300256 [300256]
        MemberCard.Get (CardEntryNo);
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        case MembershipSetup."Card Expire Date Calculation" of
          MembershipSetup."Card Expire Date Calculation"::NA : NewUntilDate := 0D;
          MembershipSetup."Card Expire Date Calculation"::DATEFORMULA :
            begin
              // xx
              //      IF (MemberCard."Valid Until" = 0D) THEN
              //        MemberCard."Valid Until" := TODAY;
              //      NewUntilDate := CALCDATE (MembershipSetup."Card Number Valid Until", MemberCard."Valid Until");

              if (MemberCard."Valid Until" <= Today) then
                MemberCard."Valid Until" := CalcDate ('<-1D>', Today); // An expired card appears to have been valid until yesterday

              NewUntilDate := CalcDate (MembershipSetup."Card Number Valid Until",
                CalcDate ('<+1D>', MemberCard."Valid Until")); // Card should be valid from day after current end date, or they will overlap
              // xx
            end;
          MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED : NewUntilDate := NewTimeFrameEndDate;
        end;

        case ExpiredCardOption of
          AlterationSetup."Card Expired Action"::IGNORE : exit (true);
          AlterationSetup."Card Expired Action"::PREVENT :
            begin
              ResponseMessage := StrSubstNo (PREVENT_CARD_EXTEND, MemberCard."External Card No.", NewUntilDate);
              exit (NewUntilDate <= MemberCard."Valid Until");
            end;
          AlterationSetup."Card Expired Action"::NEW :
            begin
              MemberInfoCapture."Valid Until" := NewUntilDate;
              exit (IssueMemberCardWorker (FailWithError, MembershipEntryNo, MemberCard."Member Entry No.", MemberInfoCapture, false, MemberCardEntryNoOut, ResponseMessage, true));
            end;

          AlterationSetup."Card Expired Action"::UPDATE :
            begin
              MemberCard."Valid Until" := NewUntilDate;
              exit (MemberCard.Modify ());
            end;
        end;

        // MemberInfoCapture."Valid Until" := NewEndDate;
        // MemberEntryNo := GetMemberFromExtCardNo (ExternalMemberCardNo, TODAY, ResponseMessage);

        //TODO
        // Setup to reuse current card, with new end date, IssueMemberCardWorker will create a new card if setup allows it.
        //EXIT (IssueMemberCardWorker (FailWithError, MembershipEntryNo, MemberEntryNo, MemberInfoCapture, FALSE, MemberCardEntryNoOut, ResponseMessage, TRUE));
        //+#300256 [300256]
    end;

    local procedure PrefillMemberInfoCapture(var MemberInfoCapture: Record "MM Member Info Capture";Member: Record "MM Member";Membership: Record "MM Membership";ExternalMemberCardNo: Text[50];MembershipSalesItemNo: Code[20])
    begin

        MemberInfoCapture."Member Entry No" := Member."Entry No.";
        MemberInfoCapture."External Member No" := Member."External Member No.";
        MemberInfoCapture."First Name" := Member."First Name";
        MemberInfoCapture."Middle Name" := Member."Middle Name";
        MemberInfoCapture."Last Name" := Member."Last Name";
        MemberInfoCapture."Social Security No." := Member."Social Security No.";
        MemberInfoCapture.Address := Member.Address;
        MemberInfoCapture."Post Code Code" := Member."Post Code Code";
        MemberInfoCapture.City := Member.City;
        MemberInfoCapture."Country Code" := Member."Country Code";
        MemberInfoCapture.Gender := Member.Gender;
        MemberInfoCapture.Birthday := Member.Birthday;
        MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";

        MemberInfoCapture."External Card No." := ExternalMemberCardNo;
        MemberInfoCapture."Item No." := MembershipSalesItemNo;
    end;

    procedure AddMembershipLedgerEntry_NEW(MembershipEntryNo: Integer;DocumentDate: Date;MembershipSalesSetup: Record "MM Membership Sales Setup";MemberInfoCapture: Record "MM Member Info Capture") LedgerEntryNo: Integer
    var
        MembershipSetup: Record "MM Membership Setup";
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        MembershipSetup.Get (MembershipSalesSetup."Membership Code");
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";

        if (DocumentDate = 0D) then
          DocumentDate :=  WorkDate;

        //-MM1.17 [259671]
        // IF (MembershipSalesSetup."Valid From Base" = MembershipSalesSetup."Valid From Base"::SALESDATE) THEN BEGIN
        //  ValidFromDate := DocumentDate;
        // END ELSE BEGIN
        //  MembershipSalesSetup.TESTFIELD ("Valid From Date Calculation");
        //  ValidFromDate := CALCDATE (MembershipSalesSetup."Valid From Date Calculation", DocumentDate);
        // END;
        case MembershipSalesSetup."Valid From Base" of
          MembershipSalesSetup."Valid From Base"::PROMPT :
            ValidFromDate := MemberInfoCapture."Document Date";

          MembershipSalesSetup."Valid From Base"::SALESDATE :
            ValidFromDate := DocumentDate;

          MembershipSalesSetup."Valid From Base"::DATEFORMULA :
            begin
              MembershipSalesSetup.TestField ("Valid From Date Calculation");
              ValidFromDate := CalcDate (MembershipSalesSetup."Valid From Date Calculation", DocumentDate);
            end;

          MembershipSalesSetup."Valid From Base"::FIRST_USE :
            ValidFromDate := 0D;
        end;
        //+MM1.17 [259671]

        if ((MembershipSetup.Perpetual) or (MembershipSalesSetup."Valid Until Calculation" = MembershipSalesSetup."Valid Until Calculation"::END_OF_TIME)) then begin
          if (ValidFromDate = 0D) then
            ValidFromDate := DocumentDate;
          ValidUntilDate := DMY2Date (31, 12, 9999); //31129999D;
        end else begin
          MembershipSalesSetup.TestField ("Duration Formula");
          if (MembershipSalesSetup."Valid From Base" <> MembershipSalesSetup."Valid From Base"::FIRST_USE) then
            ValidUntilDate := CalcDate (MembershipSalesSetup."Duration Formula", ValidFromDate);
          MemberInfoCapture."Duration Formula" := MembershipSalesSetup."Duration Formula";
        end;

        MemberInfoCapture."Membership Code" := MembershipSalesSetup."Membership Code";

        //-MM1.23 [257011]
        if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then begin
          if (IsMembershipActive (MembershipEntryNo, Today, false)) then
            exit (0); //Hmm
        end;
        //+MM1.23 [257011]

        exit (AddMembershipLedgerEntry (MembershipEntryNo, MemberInfoCapture, ValidFromDate, ValidUntilDate));
    end;

    procedure SynchronizeCustomerAndContact(MembershipEntryNo: Integer)
    var
        Community: Record "MM Member Community";
        MembershipSetup: Record "MM Membership Setup";
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        AdminMemberEntryNo: Integer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        Customer: Record Customer;
    begin

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        Community.Get (Membership."Community Code");

        if (not Community."Membership to Cust. Rel.") then
          exit;

        if (MembershipSetup."Customer Config. Template Code" = '') then
          exit;

        if (Membership."Customer No." = '') then begin
          //-NPR5.34 [279229]
          //Membership."Customer No." := CreateCustomerFromTemplate (MembershipSetup."Customer Config. Template Code", Membership."External Membership No.");
          Membership."Customer No." :=
            //-#319296 [319296]
            //CreateCustomerFromTemplate (MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
            CreateCustomerFromTemplate (Community."Customer No. Series", MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
            //+#319296 [319296]

          //+NPR5.34 [279229]
          Membership.Modify ();
        end;

        //xx
        ConfigTemplateHeader.Get (MembershipSetup."Customer Config. Template Code");
        if (Customer.Get (Membership."Customer No.")) then begin
          RecRef.GetTable(Customer);
          ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
          RecRef.SetTable(Customer);
          Customer.Modify (true);
        end;
        //Xx

        //-MM1.26 [294868]
        // MembershipRole.SETFILTER ("Membership Entry No.", '=%1', MembershipEntryNo);
        // MembershipRole.SETFILTER ("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        // MembershipRole.SETFILTER (Blocked, '=%1', FALSE);

        // IF (MembershipRole.ISEMPTY ()) THEN
        //   EXIT;
        //
        // MembershipRole.FINDFIRST ();
        // UpdateCustomerFromMember (MembershipEntryNo, MembershipRole."Member Entry No.");
        // AdminMemberEntryNo := MembershipRole."Member Entry No.";
        //
        // MembershipRole.RESET();
        // MembershipRole.SETFILTER ("Membership Entry No.", '=%1', MembershipEntryNo);
        // MembershipRole.SETFILTER ("Member Entry No.", '<>%1', AdminMemberEntryNo);
        // MembershipRole.SETFILTER ("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter (Blocked, '=%1', false);

        if (MembershipRole.FindFirst) then begin
          AdminMemberEntryNo := MembershipRole."Member Entry No.";

        end else begin
          MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
          if (not MembershipRole.FindFirst ()) then
            exit;
          AdminMemberEntryNo := MembershipRole."Member Entry No.";
        end;

        UpdateCustomerFromMember (MembershipEntryNo, AdminMemberEntryNo);

        MembershipRole.Reset();
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter ("Member Entry No.", '<>%1', AdminMemberEntryNo);
        MembershipRole.SetFilter ("Member Role", '<>%1&<>%2', MembershipRole."Member Role"::ANONYMOUS, MembershipRole."Member Role"::GUARDIAN);
        //+MM1.26 [294868]

        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.FindSet ()) then begin
          repeat
            AddCustomerContact (MembershipEntryNo, MembershipRole."Member Entry No.");
          until (MembershipRole.Next () = 0);
        end;
    end;

    procedure GetMembershipChangeOptions(var MembershipEntryNo: Integer;var MembershipAlterationSetup: Record "MM Membership Alteration Setup";var TmpMembershipEntry: Record "MM Membership Entry" temporary): Boolean
    var
        TmpMemberInfoCapture: Record "MM Member Info Capture" temporary;
        Item: Record Item;
        EntryNo: Integer;
        IsValidOption: Boolean;
        StartDate: Date;
        EndDate: Date;
        UnitPrice: Decimal;
    begin

        if (MembershipAlterationSetup.FindSet ()) then begin
          repeat
            EntryNo += 1;
            TmpMemberInfoCapture."Membership Entry No." := MembershipEntryNo;
            TmpMemberInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
            if (Item.Get (TmpMemberInfoCapture."Item No.")) then ;

            IsValidOption := false;
            case MembershipAlterationSetup."Alteration Type" of
              MembershipAlterationSetup."Alteration Type"::RENEW     : IsValidOption := RenewMembership (TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
              MembershipAlterationSetup."Alteration Type"::EXTEND    : IsValidOption := ExtendMembership (TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
              MembershipAlterationSetup."Alteration Type"::UPGRADE   : IsValidOption := UpgradeMembership (TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
              MembershipAlterationSetup."Alteration Type"::REGRET    : IsValidOption := RegretMembership (TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
              MembershipAlterationSetup."Alteration Type"::CANCEL    : IsValidOption := CancelMembership (TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
            end;

            if (IsValidOption) then begin
              TmpMembershipEntry.Init;

              TmpMembershipEntry."Entry No." := EntryNo;
              TmpMembershipEntry."Valid From Date" := StartDate;
              TmpMembershipEntry."Valid Until Date" := EndDate;
              TmpMembershipEntry."Item No." := MembershipAlterationSetup."Sales Item No.";
              TmpMembershipEntry.Description := MembershipAlterationSetup.Description;
              TmpMembershipEntry."Amount Incl VAT" := UnitPrice;
              TmpMembershipEntry."Unit Price" := Item."Unit Price";

              //-MM1.18 [265729]
              TmpMembershipEntry."Membership Code" := MembershipAlterationSetup."From Membership Code";
              if (MembershipAlterationSetup."To Membership Code" <> '') then
                TmpMembershipEntry."Membership Code" := MembershipAlterationSetup."To Membership Code";
              //+MM1.18 [265729]

              case MembershipAlterationSetup."Alteration Type" of
                MembershipAlterationSetup."Alteration Type"::RENEW      : TmpMembershipEntry.Context := TmpMembershipEntry.Context::RENEW;
                MembershipAlterationSetup."Alteration Type"::EXTEND     : TmpMembershipEntry.Context := TmpMembershipEntry.Context::EXTEND;
                MembershipAlterationSetup."Alteration Type"::UPGRADE    : TmpMembershipEntry.Context := TmpMembershipEntry.Context::UPGRADE;
                MembershipAlterationSetup."Alteration Type"::REGRET     : TmpMembershipEntry.Context := TmpMembershipEntry.Context::REGRET;
                MembershipAlterationSetup."Alteration Type"::CANCEL     : TmpMembershipEntry.Context := TmpMembershipEntry.Context::CANCEL;
              end;

              TmpMembershipEntry.Insert ();
            end;
          until (MembershipAlterationSetup.Next () = 0);
        end;

        exit (not TmpMembershipEntry.IsEmpty ());
    end;

    procedure GetMemberCount(MembershipEntryno: Integer;var AdminMemberCount: Integer;var MemberMemberCount: Integer;var AnonymousMemberCount: Integer)
    var
        MembershipRole: Record "MM Membership Role";
    begin

        AdminMemberCount := 0;
        MemberMemberCount := 0;
        AnonymousMemberCount := 0;

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        AdminMemberCount := MembershipRole.Count();

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::MEMBER);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        MemberMemberCount := MembershipRole.Count();

        //-MM1.32 [313795]
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::DEPENDENT);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        MemberMemberCount += MembershipRole.Count();
        //+MM1.32 [313795]

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ANONYMOUS);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.FindFirst ()) then
          AnonymousMemberCount := MembershipRole."Member Count";
    end;

    local procedure "--internal"()
    begin
    end;

    local procedure DuplicateMcsPersonIdReference(MemberInfoCapture: Record "MM Member Info Capture";Member: Record "MM Member";DeleteSourceRecord: Boolean): Boolean
    var
        RecRefCapture: RecordRef;
        RecRefMember: RecordRef;
        MCSPersonBusinessEntities: Record "MCS Person Business Entities";
        MCSPersonBusinessEntities2: Record "MCS Person Business Entities";
    begin

        RecRefCapture := MemberInfoCapture.RecordId.GetRecord();
        RecRefMember := Member.RecordId.GetRecord();

        MCSPersonBusinessEntities.SetFilter ("Table Id", '=%1', RecRefCapture.Number);
        MCSPersonBusinessEntities.SetFilter (Key, '=%1', RecRefCapture.RecordId);
        if (not MCSPersonBusinessEntities.FindFirst ()) then
          exit (false);

        MCSPersonBusinessEntities2.PersonId := MCSPersonBusinessEntities.PersonId;
        MCSPersonBusinessEntities2."Table Id"  := RecRefMember.Number;
        MCSPersonBusinessEntities2.Key := RecRefMember.RecordId;
        MCSPersonBusinessEntities2.Insert ();
        if (DeleteSourceRecord) then
          MCSPersonBusinessEntities.Delete ();

        exit (true);
    end;

    local procedure AddMembershipRenewalNotification(MembershipLedgerEntry: Record "MM Membership Entry")
    var
        MemberNotification: Codeunit "MM Member Notification";
    begin

        //-MM1.29.02 [314131] Function moved to notification codeunit
        MemberNotification.AddMembershipRenewalNotification (MembershipLedgerEntry);
    end;

    local procedure AddMemberCreateNotification(MembershipEntryNo: Integer;Member: Record "MM Member";MemberInfoCapture: Record "MM Member Info Capture")
    var
        MemberNotification: Codeunit "MM Member Notification";
    begin

        //-MM1.29.02 [314131] Function moved to notification codeunit
        MemberNotification.AddMemberWelcomeNotification (MembershipEntryNo, Member."Entry No.");

        //-MM1.32 [318132]
        if (MemberInfoCapture."Member Card Type" in [MemberInfoCapture."Member Card Type"::CARD_PASSSERVER, MemberInfoCapture."Member Card Type"::PASSSERVER]) then
          MemberNotification.CreateWalletSendNotification (MembershipEntryNo, Member."Entry No.", 0);
        //+MM1.32 [318132]
    end;

    local procedure ValidAlterationGracePeriod(MembershipAlterationSetup: Record "MM Membership Alteration Setup";MembershipEntry: Record "MM Membership Entry";ReferenceDate: Date): Boolean
    var
        GracePeriodDate: Date;
        GraceDayCount: Integer;
        InGracePeriod: Boolean;
        LowerBoundDate: Date;
        UpperBoundDate: Date;
    begin

        if (not MembershipAlterationSetup."Activate Grace Period") then
          exit (true);

        if (MembershipEntry."Activate On First Use") then
          exit (false);

        case MembershipAlterationSetup."Grace Period Relates To" of
          MembershipAlterationSetup."Grace Period Relates To"::START_DATE : GracePeriodDate := MembershipEntry."Valid From Date";
          MembershipAlterationSetup."Grace Period Relates To"::END_DATE : GracePeriodDate := MembershipEntry."Valid Until Date";
        end;

        LowerBoundDate := 0D;
        UpperBoundDate := DMY2Date (31, 12, 9999); //31129999D;


        //-MM1.30 [317428]
        // IF (FORMAT (MembershipAlterationSetup."Grace Period Before") <> '') THEN BEGIN
        //  GraceDayCount := ABS ((GracePeriodDate - CALCDATE (MembershipAlterationSetup."Grace Period Before", GracePeriodDate)));
        //  LowerBoundDate := GracePeriodDate - GraceDayCount;
        // END;
        //
        // IF (FORMAT (MembershipAlterationSetup."Grace Period After") <> '') THEN BEGIN
        //  GraceDayCount := ABS ((GracePeriodDate - CALCDATE (MembershipAlterationSetup."Grace Period After", GracePeriodDate)));
        //  UpperBoundDate := GracePeriodDate + GraceDayCount;
        // END;

        if (Format (MembershipAlterationSetup."Grace Period Before") <> '') then begin
          if (MembershipAlterationSetup."Grace Period Calculation" = MembershipAlterationSetup."Grace Period Calculation"::SIMPLE) then begin
            GraceDayCount := Abs ((GracePeriodDate - CalcDate (MembershipAlterationSetup."Grace Period Before", GracePeriodDate)));
            LowerBoundDate := GracePeriodDate - GraceDayCount;
          end;

          if (MembershipAlterationSetup."Grace Period Calculation" = MembershipAlterationSetup."Grace Period Calculation"::ADVANCED) then begin
            LowerBoundDate := CalcDate (MembershipAlterationSetup."Grace Period Before", GracePeriodDate);
          end;
        end;

        if (Format (MembershipAlterationSetup."Grace Period After") <> '') then begin
          GraceDayCount := Abs ((GracePeriodDate - CalcDate (MembershipAlterationSetup."Grace Period After", GracePeriodDate)));
          UpperBoundDate := GracePeriodDate + GraceDayCount;

          if (MembershipAlterationSetup."Grace Period Calculation" = MembershipAlterationSetup."Grace Period Calculation"::ADVANCED) then begin
            UpperBoundDate := CalcDate (MembershipAlterationSetup."Grace Period After", GracePeriodDate);
          end;
        end;
        //+MM1.30 [317428]

        InGracePeriod := ((LowerBoundDate <= ReferenceDate) and (ReferenceDate <= UpperBoundDate));
        exit (InGracePeriod);
    end;

    local procedure ValidateChangeMembershipCode(WithConfirm: Boolean;MembershipEntryNo: Integer;StartDate: Date;ToMembershipCode: Code[20];var ReasonText: Text): Boolean
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        MemberCount: Integer;
    begin

        //-#300395 [300395] refactored for ReasontText
        Membership.Get (MembershipEntryNo);

        ReasonText := UPGRADE_TO_CODE_MISSING;
        if (ToMembershipCode = '') then
          exit (ExitFalseOrWithError (WithConfirm, ReasonText));

        MembershipSetup.Get (ToMembershipCode);
        if (ToMembershipCode <> Membership."Membership Code") then begin

          //-MM1.23 [293364]
          //  IF (StartDate > TODAY) THEN
          //    EXIT (ExitFalseOrWithError (WithConfirm, FUTUREDATE_NOT_SUPPORTED));
          //+MM1.23 [293364]

          MemberCount := GetMembershipMemberCount (MembershipEntryNo);
          ReasonText := StrSubstNo (TO_MANY_MEMBERS, Membership."External Membership No.", MembershipSetup.Code, MembershipSetup."Membership Member Cardinality");
          if (MembershipSetup."Membership Member Cardinality" > 0) then
            if (MemberCount > MembershipSetup."Membership Member Cardinality") then
              exit (ExitFalseOrWithError (WithConfirm, ReasonText));
        end;

        ReasonText := '';
        exit (true);
    end;

    local procedure GetMembershipMemberCount(MembershipEntryNo: Integer) MemberCount: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
    begin

        //-MM1.22 [287080]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        GetMemberCount (MembershipEntryNo, AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        if (MembershipSetup."Anonymous Member Cardinality" = MembershipSetup."Anonymous Member Cardinality"::UNLIMITED) then
          exit (AdminMemberCount + MemberMemberCount);

        exit (AdminMemberCount + MemberMemberCount + AnonymousMemberCount);

        //+MM1.22 [287080]
    end;

    local procedure GetMembershipMemberCountForAlteration(MembershipEntryNo: Integer;MembershipAlterationSetup: Record "MM Membership Alteration Setup") MemberCount: Integer
    var
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
    begin

        //-MM1.22 [287080]
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        GetMemberCount (MembershipEntryNo, AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        with MembershipAlterationSetup do begin
          case "Member Count Calculation" of
            "Member Count Calculation"::NA :        MemberCount :=  0;
            "Member Count Calculation"::NAMED :     MemberCount := AdminMemberCount + MemberMemberCount;
            "Member Count Calculation"::ANONYMOUS : MemberCount := AnonymousMemberCount;
            "Member Count Calculation"::ALL :       MemberCount := AdminMemberCount + MemberMemberCount + AnonymousMemberCount;
             else
               Error ('Undefined Member Count Calculation %1', MembershipAlterationSetup."Member Count Calculation");
          end;
        end;

        exit (MemberCount);

        //+MM1.22 [287080]
    end;

    local procedure ConflictingLedgerEntries(MembershipEntryNo: Integer;StartDate: Date;EndDate: Date;var StartEntryNo: Integer;var EndEntryNo: Integer) HaveConflict: Boolean
    begin

        if (not GetLedgerEntryForDate (MembershipEntryNo, StartDate, StartEntryNo)) then
          exit (false);

        if (not GetLedgerEntryForDate (MembershipEntryNo, EndDate, EndEntryNo)) then
          exit (false);

        exit (StartEntryNo <> EndEntryNo);
    end;

    local procedure GetLedgerEntryForDate(MembershipEntryNo: Integer;DateToCheck: Date;var EntryNo: Integer): Boolean
    var
        MembershipEntry: Record "MM Membership Entry";
    begin

        EntryNo := 0;

        //-MM1.17 [261887]
        MembershipEntry.SetCurrentKey ("Membership Entry No.");
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter ("Valid From Date", '<=%1', DateToCheck);
        MembershipEntry.SetFilter ("Valid Until Date", '>=%1', DateToCheck);
        MembershipEntry.SetFilter (Blocked, '=%1', false);
        if (not MembershipEntry.FindLast ()) then
          exit (false);

        // MembershipEntry.SETCURRENTKEY ("Membership Entry No.");
        // MembershipEntry.SETFILTER ("Membership Entry No.", '=%1', MembershipEntryNo);
        // MembershipEntry.SETFILTER ("Valid From Date", '>=%1', DateToCheck);
        // MembershipEntry.SETFILTER (Blocked, '=%1', FALSE);
        // IF (NOT MembershipEntry.FINDFIRST ()) THEN
        //  EXIT (FALSE);
        //+MM1.17 [261887]

        EntryNo := MembershipEntry."Entry No.";
        exit (true);
    end;

    local procedure CalculatePeriodStartToDateFraction(Period_Start: Date;Period_End: Date;Period_Date: Date) Fraction: Decimal
    begin

        // Calculates the fraction from start to date in the timeframe start..end
        // Returs zero when date is not in start..end range
        // StartDate is considered a "from date"
        // Date and EndDate are considered "until dates" - when all dates are equal, return 1

        if ((Period_Date < Period_Start) or (Period_Date > Period_End)) then
          exit (0);

        if (Period_Start = Period_End) then
          exit (1);

        //EXIT ((calcdate ('<+1D>', Period_Date) - Period_Start) / (calcdate ('<+1D>', Period_End) - Period_Start));
        exit ((Period_Date - Period_Start) / (Period_End - Period_Start));
    end;

    local procedure AddMembershipLedgerEntry(MembershipEntryNo: Integer;MemberInfoCapture: Record "MM Member Info Capture";ValidFromDate: Date;ValidUntilDate: Date) MemberShipLedgerEntryNo: Integer
    var
        MembershipLedgerEntry: Record "MM Membership Entry";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        MembershipRole: Record "MM Membership Role";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        MemberNotification: Codeunit "MM Member Notification";
        Item: Record Item;
    begin

        MembershipLedgerEntry."Membership Entry No." := MembershipEntryNo;
        MembershipLedgerEntry."Created At" := CurrentDateTime ();

        //MembershipLedgerEntry.Context := NEW,REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW
        case MemberInfoCapture."Information Context" of
          MemberInfoCapture."Information Context"::NEW : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::NEW;
          MemberInfoCapture."Information Context"::REGRET : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::REGRET;
          MemberInfoCapture."Information Context"::RENEW : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::RENEW;
          MemberInfoCapture."Information Context"::UPGRADE : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::UPGRADE;
          MemberInfoCapture."Information Context"::EXTEND : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::EXTEND;
          MemberInfoCapture."Information Context"::CANCEL : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::CANCEL;
          MemberInfoCapture."Information Context"::AUTORENEW : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::AUTORENEW;
          MemberInfoCapture."Information Context"::FOREIGN : MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::FOREIGN;
          else
            exit (0);
        end;

        MembershipLedgerEntry."Duration Dateformula" := MemberInfoCapture."Duration Formula";
        MembershipLedgerEntry."Valid From Date" := ValidFromDate;
        MembershipLedgerEntry."Valid Until Date" := ValidUntilDate;
        MembershipLedgerEntry."Original Context" := MembershipLedgerEntry.Context;

        //-MM1.17 [259671]
        if (ValidFromDate = 0D) and (MembershipLedgerEntry.Context = MembershipLedgerEntry.Context::NEW) then begin
          MembershipLedgerEntry."Valid From Date" := 0D;
          MembershipLedgerEntry."Valid Until Date" := 0D;
          MembershipLedgerEntry."Activate On First Use" := true;
        end;
        //+MM1.17 [259671]

        MembershipLedgerEntry."Item No." := MemberInfoCapture."Item No.";
        MembershipLedgerEntry."Membership Code" := MemberInfoCapture."Membership Code";

        MembershipLedgerEntry."Unit Price" := MemberInfoCapture."Unit Price";
        MembershipLedgerEntry.Amount := MemberInfoCapture.Amount;
        MembershipLedgerEntry."Amount Incl VAT" := MemberInfoCapture."Amount Incl VAT";

        //-MM1.29 [316141]
        if (Item.Get (MembershipLedgerEntry."Item No.")) then
          MembershipLedgerEntry."Unit Price (Base)" := Item."Unit Price";
        //+MM1.29 [316141]

        MembershipLedgerEntry."Receipt No." := MemberInfoCapture."Receipt No.";
        MembershipLedgerEntry."Line No." := MemberInfoCapture."Line No.";
        MembershipLedgerEntry."Source Type" := MemberInfoCapture."Source Type";
        MembershipLedgerEntry."Document Type" := MemberInfoCapture."Document Type";
        MembershipLedgerEntry."Document No." := MemberInfoCapture."Document No.";
        MembershipLedgerEntry."Document Line No." := MemberInfoCapture."Document Line No.";
        MembershipLedgerEntry."Import Entry Document ID" := MemberInfoCapture."Import Entry Document ID";
        MembershipLedgerEntry.Description := MemberInfoCapture.Description;
        //-MM1.19 [270308]
        MembershipLedgerEntry."Member Card Entry No." := MemberInfoCapture."Card Entry No.";
        //-MM1.19 [270308]

        MembershipLedgerEntry."Auto-Renew Entry No." := MemberInfoCapture."Auto-Renew Entry No.";
        MembershipLedgerEntry.Insert ();

        //XX
        if (MembershipLedgerEntry.Context in [MembershipLedgerEntry.Context::UPGRADE, MembershipLedgerEntry.Context::RENEW]) then begin
          Membership.Get (MembershipEntryNo);
          if (Membership."Customer No." <> '') then begin
            MembershipSetup.Get (Membership."Membership Code");
            if (MembershipSetup."Customer Config. Template Code" <> '') then begin
              ConfigTemplateHeader.Get (MembershipSetup."Customer Config. Template Code");
              if (Customer.Get (Membership."Customer No.")) then begin
                RecRef.GetTable(Customer);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
                RecRef.SetTable(Customer);
                Customer.Modify (true);
              end;
            end;
          end;
        end;
        //xx

        //-MM1.22 [285403]
        OnAfterInsertMembershipEntry  (MembershipLedgerEntry);
        //+MM1.22 [285403]

        if (not MembershipLedgerEntry."Activate On First Use") then
          AddMembershipRenewalNotification (MembershipLedgerEntry);

        //-MM1.32 [318132]
        // //-MM1.29 [314131]
        // IF (MembershipSetup."Enable NP Pass Integration") THEN
        //  MemberNotification.CreateWalletUpdateNotification (Membership."Entry No.");
        // //+MM1.29 [314131]

        if ((MembershipSetup."Enable NP Pass Integration") and
            (MemberInfoCapture."Information Context" <>  MemberInfoCapture."Information Context"::FOREIGN)) then begin

          if (MemberInfoCapture."Information Context" =  MemberInfoCapture."Information Context"::NEW) then begin
            ; // The create notification is created when first member is added.

          end else begin
            MembershipRole.SetFilter ("Membership Entry No.", '=%1', Membership."Entry No.");
            MembershipRole.SetFilter (Blocked, '=%1', false);
            MembershipRole.SetFilter ("Wallet Pass Id", '<>%1', '');
            if (not MembershipRole.IsEmpty ()) then
              MemberNotification.CreateUpdateWalletNotification (Membership."Entry No.", 0, 0);
          end;
        end;
        //+MM1.32 [318132]

        exit (MembershipLedgerEntry."Entry No.");
    end;

    procedure ActivateMembershipLedgerEntry(MembershipEntryNo: Integer;ActivationDate: Date)
    var
        MembershipEntry: Record "MM Membership Entry";
        Membership: Record "MM Membership";
    begin

        Membership.Get (MembershipEntryNo);

        //-MM1.17 [259671]
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipEntry.FindFirst ()) then
          Error (NO_LEDGER_ENTRY, Membership."External Membership No.");
          //EXIT; // only first entry can be activated on first use

        if (not MembershipEntry."Activate On First Use") then
          exit; // Allready activated

        MembershipEntry."Valid From Date" := ActivationDate;
        MembershipEntry."Valid Until Date" := CalcDate (MembershipEntry."Duration Dateformula", ActivationDate);
        MembershipEntry."Activate On First Use" := false;
        MembershipEntry.Modify;

        //-MM1.22 [285403]
        OnAfterInsertMembershipEntry  (MembershipEntry);
        //+MM1.22 [285403]

        AddMembershipRenewalNotification (MembershipEntry);
        Commit;
        //+MM1.17 [259671]
    end;

    procedure MembershipNeedsActivation(MembershipEntryNo: Integer): Boolean
    var
        MembershipEntry: Record "MM Membership Entry";
    begin

        //-MM1.17 [259671]
        MembershipEntry.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipEntry.FindFirst ()) then
          exit (true); // :)

        exit (MembershipEntry."Activate On First Use");
        //+MM1.17 [259671]
    end;

    local procedure GetCommunityMembership(MembershipCode: Code[20];CreateWhenMissing: Boolean) MembershipEntryNo: Integer
    var
        MembershipSetup: Record "MM Membership Setup";
        Community: Record "MM Member Community";
        Membership: Record "MM Membership";
        MembershipCreated: Boolean;
    begin

        MembershipSetup.Get (MembershipCode);
        Community.Get (MembershipSetup."Community Code");

        Membership.SetFilter ("Community Code", '=%1', MembershipSetup."Community Code");

        //-#307113 [307113]
        Membership.SetFilter ("Membership Code", '=%1', MembershipCode);
        //+#307113 [307113]

        if (Membership.IsEmpty ()) then begin
          if (not CreateWhenMissing) then
            exit (0);

          Membership.Init ();
          Membership.Description := Community.Description;
          Membership."Community Code" := MembershipSetup."Community Code";
          Membership."Membership Code" := MembershipCode;
          Membership."Issued Date" := Today;

          //-#307113 [307113]
          Membership."External Membership No." := AssignExternalMembershipNo (MembershipSetup."Community Code");
          //+#307113 [307113]

          Membership.Insert (true);
          MembershipCreated := true;
        end;

        Membership.FindFirst ();

        if (Community."Membership to Cust. Rel.") then begin
          if (Membership."Customer No." = '') then begin
            MembershipSetup.TestField ("Customer Config. Template Code");

            //-NPR5.34 [279229]
            //Membership."Customer No." := CreateCustomerFromTemplate (MembershipSetup."Customer Config. Template Code", Membership."External Membership No.");
            Membership."Customer No." :=
              //-#319296 [319296]
              //CreateCustomerFromTemplate (MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
              CreateCustomerFromTemplate (Community."Customer No. Series", MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
              //+#319296 [319296]

            //+NPR5.34 [279229]
            Membership.Modify ();
          end;
        end;

        //-MM1.22 [286922]
        if (MembershipCreated) then
          OnAfterMembershipCreateEvent (Membership);
        //+MM1.22 [286922]

        exit (Membership."Entry No.");
    end;

    local procedure GetNewMembership(MembershipCode: Code[20];MemberInfoCapture: Record "MM Member Info Capture";CreateWhenMissing: Boolean) MembershipEntryNo: Integer
    var
        MembershipSetup: Record "MM Membership Setup";
        Community: Record "MM Member Community";
        Membership: Record "MM Membership";
        MembershipCreated: Boolean;
    begin

        MembershipSetup.Get (MembershipCode);
        Community.Get (MembershipSetup."Community Code");

        if (MemberInfoCapture."External Membership No." = '') then
          MemberInfoCapture."External Membership No." := AssignExternalMembershipNo (MembershipSetup."Community Code");

        Membership.SetFilter ("External Membership No.", '=%1', MemberInfoCapture."External Membership No.");
        Membership.SetFilter ("Membership Code", '=%1', MembershipCode);
        if (Membership.IsEmpty ()) then begin
          if (not CreateWhenMissing) then
            exit (0);

          Membership.Init ();
          Membership."External Membership No." := MemberInfoCapture."External Membership No.";
          Membership.Description := Community.Description;
          Membership."Community Code" := MembershipSetup."Community Code";
          Membership."Membership Code" := MembershipCode;
          Membership."Company Name" := MemberInfoCapture."Company Name";
          Membership."Issued Date" := Today;
          //-MM1.23 [257011]
          Membership."Document ID" := MemberInfoCapture."Import Entry Document ID";
          Membership."Modified At" := CurrentDateTime ();
          if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then
            Membership."Replicated At" := CurrentDateTime ();
          //+MM1.23 [257011]

          Membership.Insert (true);
          MembershipCreated := true;
        end;

        Membership.FindFirst ();
        if (Community."Membership to Cust. Rel.") then begin
          if (Membership."Customer No." = '') then begin
            Membership."Customer No." :=
              //-#319296 [319296]
              //CreateCustomerFromTemplate (MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
              CreateCustomerFromTemplate (Community."Customer No. Series", MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
              //+#319296 [319296]

            //-MM1.22 [286922]
            //-MM1.39 [350968]
            // Membership."Auto-Renew" := MemberInfoCapture."Enable Auto-Renew";
            if (MemberInfoCapture."Enable Auto-Renew") then
              Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
            //+MM1.39 [350968]

            Membership."Auto-Renew Payment Method Code" := MemberInfoCapture."Auto-Renew Payment Method Code";

            //-MM1.39 [350968]
            //IF (Membership."Auto-Renew") THEN
            // Membership.TESTFIELD ("Auto-Renew Payment Method Code");
            if (Membership."Auto-Renew" = Membership."Auto-Renew"::YES_INTERNAL) then
              Membership.TestField ("Auto-Renew Payment Method Code");
            //+MM1.39 [350968]
            //+MM1.22 [286922]

            //-MM1.23 [257011]
            Membership."Modified At" := CurrentDateTime ();
            //+MM1.23 [257011]

            Membership.Modify ();
          end;
        end;

        //-MM1.22 [286922]
        if (MembershipCreated) then
          OnAfterMembershipCreateEvent (Membership);
        //+MM1.22 [286922]

        exit (Membership."Entry No.");
    end;

    local procedure CreateCustomerFromTemplate(CustomerNoSeriesCode: Code[10];CustTemplateCode: Code[10];ContTemplateCode: Code[10];ExternalCustomerNo: Code[20]) CustomerNo: Code[20]
    var
        Contact: Record Contact;
        ContBusRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        if (CustTemplateCode = '') then
          Error (MISSING_TEMPLATE, CustTemplateCode);

        if (not ConfigTemplateHeader.Get (CustTemplateCode)) then
          Error (MISSING_TEMPLATE, CustTemplateCode);

        Customer.Init;
        Customer."No." := '';

        //-#319296 [319296]
        if (CustomerNoSeriesCode <> '') then
          Customer."No." := NoSeriesManagement.GetNextNo (CustomerNoSeriesCode, 0D, true);
        //+#319296 [319296]

        Customer."External Customer No." := ExternalCustomerNo;
        Customer.Insert(true);

        RecRef.GetTable(Customer);
        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
        RecRef.SetTable(Customer);

        Customer.Modify (true);

        if (ContTemplateCode <> '') and ConfigTemplateHeader.Get(ContTemplateCode) then begin
          ContBusRelation.SetRange("Link to Table",ContBusRelation."Link to Table"::Customer);
          ContBusRelation.SetRange("No.",Customer."No.");
          if ContBusRelation.FindFirst and Contact.Get(ContBusRelation."Contact No.") then begin
            RecRef.GetTable(Contact);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
            RecRef.SetTable(Contact);
            Contact.Modify(true);
          end;
        end;

        exit (Customer."No.");
    end;

    local procedure UpdateCustomerFromMember(MembershipEntryNo: Integer;MemberEntryNo: Integer)
    var
        Membership: Record "MM Membership";
        GuardianMembership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
        GuardianMembershipRole: Record "MM Membership Role";
        Customer: Record Customer;
        UpdateContFromCust: Codeunit "CustCont-Update";
        ContComp: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
    begin

        Membership.Get (MembershipEntryNo);
        Member.Get (MemberEntryNo);
        MembershipRole.Get (MembershipEntryNo, MemberEntryNo);

        if (not Customer.Get (Membership."Customer No.")) then
          exit;

        //-MM1.33 [324065]
        if (MembershipRole."Member Role" in [MembershipRole."Member Role"::ANONYMOUS,
                                             MembershipRole."Member Role"::MEMBER]) then
          exit;

        if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin

          GuardianMembershipRole.SetFilter ("Member Entry No.", '=%1', MemberEntryNo);
          GuardianMembershipRole.SetFilter ("Member Role", '=%1', GuardianMembershipRole."Member Role"::ADMIN);
          GuardianMembershipRole.SetFilter (Blocked, '=%1', false);
          if (GuardianMembershipRole.FindFirst ()) then begin
            GuardianMembership.Get (GuardianMembershipRole."Membership Entry No.");
            if (GuardianMembership."Customer No." <> '') then begin
              Customer.Validate ("Bill-to Customer No.", GuardianMembership."Customer No.");
              Customer.Modify ();
            end;
          end;
          exit;
        end;
        //+MM1.33 [324065]

        if (Membership."Company Name" = '') then begin
          Customer.Validate (Name, CopyStr (Member."Display Name", 1, MaxStrLen (Customer.Name)));
        end else begin
          Customer.Validate (Name, Membership."Company Name");
          Customer.Validate ("Name 2", CopyStr (Member."Display Name", 1, MaxStrLen (Customer."Name 2")));
        end;

        Customer.Validate (Address, CopyStr (Member.Address, 1, MaxStrLen (Customer.Address)));
        Customer.Validate (City, CopyStr (Member.City, 1, MaxStrLen (Customer.City)));
        Customer.Validate ("Post Code", CopyStr (Member."Post Code Code", 1, MaxStrLen (Customer."Post Code")));
        Customer.Validate ("Country/Region Code", CopyStr (Member."Country Code", 1, MaxStrLen (Customer."Country/Region Code")));

        // the magento integration requires a country code, until "mandatory fields" have been implemented for member creation
        // this should remain.
        if (Customer."Country/Region Code" = '') then
          Customer.Validate ("Country/Region Code", 'DK');

        Customer.Validate ("Phone No.", CopyStr (Member."Phone No.", 1, MaxStrLen (Customer."Phone No.")));
        Customer.Validate ("E-Mail", CopyStr (Member."E-Mail Address", 1, MaxStrLen (Customer."E-Mail")));
        if (Membership.Blocked) then
          Customer.Validate (Blocked, Customer.Blocked::All);

        Customer.Modify ();

        MarketingSetup.Get;
        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
          exit;

        UpdateContFromCust.OnModify (Customer);

        ContactBusinessRelation.SetCurrentKey ("Link to Table", "No.");
        ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetFilter ("No.", '=%1', Membership."Customer No.");

        if (ContactBusinessRelation.IsEmpty ()) then
          UpdateContFromCust.InsertNewContact (Customer, false);

        if (ContactBusinessRelation.FindFirst ()) then begin
          if (ContComp.Get (ContactBusinessRelation."Contact No.")) then begin
            ContComp."Magento Contact" := (not Member.Blocked) and (Member."E-Mail Address" <> '');
            ContComp.Modify (true);

            // TODO - remove this field
            //-MM1.33 [324065]
            // Member."Contact No." := ContComp."No.";
            // Member.MODIFY ();
            // MembershipRole."Contact No." := ContComp."No.";
            // MembershipRole.MODIFY ();

            if (Member."Contact No." = '') then begin
              Member."Contact No." := ContComp."No.";
              Member.Modify ();
            end;

            if (MembershipRole."Contact No." = '') then begin
              MembershipRole."Contact No." := ContComp."No.";
              MembershipRole.Modify ();
            end;
            //+MM1.33 [324065]


            UpdateContactFromMember (MembershipEntryNo, Member);
          end;
        end;
    end;

    procedure UpdateContactFromMember(MembershipEntryNo: Integer;Member: Record "MM Member")
    var
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        Contact: Record Contact;
        ContactXRec: Record Contact;
        HaveContact: Boolean;
    begin

        Membership.Get (MembershipEntryNo);
        MembershipRole.Get (MembershipEntryNo, Member."Entry No.");

        HaveContact := false;
        if (MembershipRole."Contact No." <> '') then
          HaveContact := Contact.Get (MembershipRole."Contact No.");

        if (not HaveContact) then
          if (Member."Contact No." <> '') then
            HaveContact := Contact.Get (Member."Contact No.");

        if (not HaveContact) then
          exit;

        //-MM1.36 [335667]
        ContactXRec.Get (Contact."No.");
        //+MM1.36 [335667]

        Contact.Validate (Name, CopyStr (Member."Display Name", 1, MaxStrLen (Contact.Name)));
        Contact.Validate ("First Name", CopyStr (Member."First Name", 1, MaxStrLen (Contact."First Name")));
        Contact.Validate ("Middle Name", CopyStr (Member."Middle Name", 1, MaxStrLen (Contact."Middle Name")));
        Contact.Validate (Surname, CopyStr (Member."Last Name", 1, MaxStrLen (Contact.Surname)));

        Contact.Validate (Address, CopyStr (Member.Address, 1, MaxStrLen (Contact.Address)));
        Contact.Validate ("Post Code", CopyStr (Member."Post Code Code", 1, MaxStrLen (Contact."Post Code")));
        Contact.Validate (City, CopyStr (Member.City, 1, MaxStrLen (Contact.City)));

        if (Member."Country Code" <> '') then
          Contact.Validate ("Country/Region Code", CopyStr (Member."Country Code", 1, MaxStrLen (Contact."Country/Region Code")));

        Contact.Validate ("Phone No.", CopyStr (Member."Phone No.", 1, MaxStrLen (Contact."Phone No.")));
        Contact.Validate ("E-Mail", CopyStr (Member."E-Mail Address", 1, MaxStrLen (Contact."E-Mail")));

        // the magento integration requires a country code, until "mandatory fields" have been implemented for member creation
        // this should remain.
        if (Contact."Country/Region Code" = '') then
          Contact.Validate ("Country/Region Code", 'DK');

        Contact."Magento Contact" := (not Member.Blocked) and (Member."E-Mail Address" <> '');

        Contact.Modify (true);

        //-MM1.36 [335667]
        // Code on Modify trigger requires XREC (modification from a page) to properly handle customer synchronization
        Contact.OnModify (ContactXRec);
        //+MM1.36 [335667]
    end;

    local procedure AddCustomerContact(MembershipEntryNo: Integer;MemberEntryNo: Integer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        MembershipSetup: Record "MM Membership Setup";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
        Contact: Record Contact;
        ContComp: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
        HaveContact: Boolean;
        Customer: Record Customer;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin

        Membership.Get (MembershipEntryNo);
        Member.Get (MemberEntryNo);
        MembershipRole.Get (MembershipEntryNo, MemberEntryNo);

        if (not Customer.Get (Membership."Customer No.")) then
          exit;

        MarketingSetup.Get;
        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
          exit;

        MembershipSetup.Get(Membership."Membership Code");

        ContactBusinessRelation.SetCurrentKey ("Link to Table", "No.");
        ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetFilter ("No.", '=%1', Membership."Customer No.");
        if (ContactBusinessRelation.FindFirst ()) then begin
          if (ContComp.Get (ContactBusinessRelation."Contact No.")) then begin

            //-MM1.33 [324065]
            // HaveContact := (Member."Contact No." <> '');
            HaveContact := (MembershipRole."Contact No." <> '');
            //+MM1.33 [324065]

            if (HaveContact) then
              HaveContact := Contact.Get (Member."Contact No.");

            if (not HaveContact) then begin
              Contact.Init;
              Contact."No." := '';
              Contact.Validate (Type, Contact.Type::Person);
              Contact.Insert(true);

              if (MembershipSetup."Contact Config. Template Code" <> '') and ConfigTemplateHeader.Get(MembershipSetup."Contact Config. Template Code") then begin
                RecRef.GetTable(Contact);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader,RecRef);
                RecRef.SetTable(Contact);
              end;

              Contact."Company No." := ContComp."No.";
              Contact.InheritCompanyToPersonData (ContComp); //NAV 2017
              Contact.Modify (true);

              Member."Contact No." := Contact."No.";
              Member.Modify ();

              MembershipRole."Contact No." := Contact."No.";
              MembershipRole.Modify ();
            end;

            UpdateContactFromMember (MembershipEntryNo, Member);

          end;
        end;
    end;

    local procedure AddCommunityMember(MembershipEntryNo: Integer;NumberOfMembers: Integer) MemberEntryNo: Integer
    var
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        MembershipSetup: Record "MM Membership Setup";
        MemberCount: Integer;
    begin

        // Community Member setup has unnamed members or

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::ANONYMOUS);
        if (MembershipRole.FindFirst ()) then begin
          MembershipRole."Member Count" += NumberOfMembers;
          if (MembershipRole."Member Count" < 0) then
            MembershipRole."Member Count" := 0;
          MembershipRole.Modify ();
        end else begin
          MembershipRole."Membership Entry No." := MembershipEntryNo;
          MembershipRole."Member Role" := MembershipRole."Member Role"::ANONYMOUS;
          MembershipRole."Community Code" := Membership."Community Code";
          MembershipRole."Created At" := CurrentDateTime;

          MembershipRole."Member Count" := NumberOfMembers;
          if (MembershipRole."Member Count" < 0) then
            MembershipRole."Member Count" := 0;

          MembershipRole.Insert ();
        end;

        if (MembershipSetup."Anonymous Member Cardinality" = MembershipSetup."Anonymous Member Cardinality"::LIMITED) then begin
          MemberCount := GetMembershipMemberCount (MembershipEntryNo);
          if (MemberCount > MembershipSetup."Membership Member Cardinality") then
            Error (TO_MANY_MEMBERS, Membership."External Membership No.", Membership."Membership Code", MembershipSetup."Membership Member Cardinality");
        end;

        exit (0);
    end;

    local procedure ActivateCustomerForWeb(MembershipEntryNo: Integer)
    begin

        // TODO: Defer customer / contact sync until activated.
    end;

    local procedure SetMemberFields(var Member: Record "MM Member";MemberInfoCapture: Record "MM Member Info Capture")
    var
        CurrentMember: Record "MM Member";
        CountryRegion: Record "Country/Region";
        CountryName: Text;
        PostCode: Record "Post Code";
    begin

        CurrentMember.Copy (Member);

        Member."First Name" := DeleteCtrlChars (MemberInfoCapture."First Name");
        Member."Middle Name" := DeleteCtrlChars (MemberInfoCapture."Middle Name");
        Member."Last Name" := DeleteCtrlChars (MemberInfoCapture."Last Name");
        Member.Address := DeleteCtrlChars (MemberInfoCapture.Address);

        Member."Post Code Code" := MemberInfoCapture."Post Code Code";
        Member.City := MemberInfoCapture.City;
        Member."Country Code" := MemberInfoCapture."Country Code";
        Member.Country := MemberInfoCapture.Country;

        //-MM1.26 [301146]
        if (Member."Post Code Code" <> '') then begin
          PostCode.SetFilter (Code, '=%1', UpperCase (Member."Post Code Code"));
          if (PostCode.FindFirst ()) then begin
            Member.City := PostCode.City;
            Member."Country Code" := PostCode."Country/Region Code";
          end;
        end;

        if (Member."Country Code" <> '') then
          if (CountryRegion.Get (Member."Country Code")) then
            Member.Country := CountryRegion.Name;

        if (MemberInfoCapture.Country <> '') and (MemberInfoCapture."Country Code" = '') then begin
          CountryName := MemberInfoCapture.Country;
          if (StrLen  (MemberInfoCapture.Country) > 1) then
            CountryName := StrSubstNo ('%1%2', UpperCase (CopyStr (MemberInfoCapture.Country, 1, 1)), LowerCase (CopyStr (MemberInfoCapture.Country,2)));

          CountryRegion.SetFilter (Name, '=%1|=%2|=%3', CountryName, UpperCase(CountryName), MemberInfoCapture.Country);
          if (CountryRegion.FindFirst ()) then begin
            Member."Country Code" := CountryRegion.Code;
            Member.Country := CountryRegion.Name;
          end;
        end;
        //+MM1.26 [301146]

        Member."E-Mail Address" := LowerCase (MemberInfoCapture."E-Mail Address");
        Member."E-Mail Address" := DeleteCtrlChars (Member."E-Mail Address");

        Member."Phone No." := MemberInfoCapture."Phone No.";
        Member."Social Security No." := MemberInfoCapture."Social Security No.";
        Member.Gender := MemberInfoCapture.Gender;
        Member.Birthday := MemberInfoCapture.Birthday;
        Member."E-Mail News Letter" := MemberInfoCapture."News Letter";
        Member."Notification Method" := MemberInfoCapture."Notification Method";

        MemberInfoCapture.CalcFields (Picture);
        if (MemberInfoCapture.Picture.HasValue()) then begin
          Member.Picture := MemberInfoCapture.Picture;
        end;
        Member."Display Name" := StrSubstNo ('%1 %2', Member."First Name", Member."Last Name");

        OnAfterMemberFieldsAssignmentEvent (CurrentMember, Member);

        exit;
    end;

    local procedure ValidateMemberFields(MembershipEntryNo: Integer;Member: Record "MM Member";FailWithError: Boolean;ResponseMessage: Text) IsValid: Boolean
    var
        Membership: Record "MM Membership";
        Community: Record "MM Member Community";
        UniqIdSet: Boolean;
        MembershipSetup: Record "MM Membership Setup";
    begin

        ResponseMessage := '';

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        Community.Get (Membership."Community Code");
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::ANONYMOUS) then
          exit (true);

        UniqIdSet := false;
        case Community."Member Unique Identity" of
          Community."Member Unique Identity"::NONE : UniqIdSet := true;
          Community."Member Unique Identity"::EMAIL : UniqIdSet := (Member."E-Mail Address" <> '');
          Community."Member Unique Identity"::PHONENO : UniqIdSet := (Member."Phone No." <> '');
          Community."Member Unique Identity"::SSN : UniqIdSet := (Member."Social Security No." <> '');
          else
            Error (CASE_MISSING, Community.FieldName ("Member Unique Identity"), Community."Member Unique Identity");
        end;

        if (not UniqIdSet) then
          exit (RaiseError (FailWithError, ResponseMessage, StrSubstNo (MISSING_VALUE, Community."Member Unique Identity", Member.TableCaption(), Member."External Member No."), '') = 0);

        exit (true);
    end;

    local procedure CreateMemberRole(FailWithError: Boolean;MemberEntryNo: Integer;MembershipEntryNo: Integer;MemberInfoCapture: Record "MM Member Info Capture";var MemberCount: Integer;var ResponseMessage: Text): Boolean
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        MembershipRoleGuardian: Record "MM Membership Role";
        MembershipSetup: Record "MM Membership Setup";
        GDPRManagement: Codeunit "GDPR Management";
        MemberGDPRManagement: Codeunit "MM GDPR Management";
        GuardianMemberEntryNo: Integer;
    begin

        Member.Get (MemberEntryNo);
        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");

        //-MM1.33 [324065]
        MembershipRoleGuardian.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        //-MM1.35 [333079]
        //MembershipRoleGuardian.SETFILTER ("Member Role", '<>%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRoleGuardian.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        //+MM1.35 [333079]

        MembershipRoleGuardian.SetFilter (Blocked, '=%1', false);
        //+MM1.33 [324065]

        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter ("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
        MembershipRole.SetFilter (Blocked, '=%1', false);

        if (MembershipRole.IsEmpty ()) then begin
          // First member
          MembershipRole.Init ();
          MembershipRole."Member Role" := MembershipRole."Member Role"::ADMIN;
          if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::MEMBERS_ONLY) then
            MembershipRole."Member Role" := MembershipRole."Member Role"::MEMBER;

        end else begin
          // member 2..n
          MembershipRole.Init ();
          if (MembershipSetup."Membership Type" = MembershipSetup."Membership Type"::INDIVIDUAL) then begin
            RaiseError (FailWithError, ResponseMessage, StrSubstNo (TO_MANY_MEMBERS, Membership."External Membership No.", MembershipSetup.Code, 1), TO_MANY_MEMBERS_NO);
            exit (false);
          end;

          MemberCount := GetMembershipMemberCount (MembershipEntryNo);

          if (MembershipSetup."Membership Member Cardinality" > 0) then begin
            if (MemberCount >= MembershipSetup."Membership Member Cardinality") then begin
              RaiseError (FailWithError, ResponseMessage, StrSubstNo (TO_MANY_MEMBERS, Membership."External Membership No.", MembershipSetup.Code, MembershipSetup."Membership Member Cardinality"), TO_MANY_MEMBERS_NO);
              exit (false);
            end;
          end;

          MembershipRole."Member Role" := MembershipRole."Member Role"::MEMBER;
          if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::ALL_ADMINS) then
            MembershipRole."Member Role" := MembershipRole."Member Role"::ADMIN;

        end;

        //-MM1.32 [313795]
        //-MM1.33 [324065]
        // IF (MemberInfoCapture."Guardian External Member No." <> '') THEN
        if (MemberInfoCapture."Guardian External Member No." <> '') or (MembershipRoleGuardian.FindFirst ()) then
        //+MM1.33 [324065]
          MembershipRole."Member Role" := MembershipRole."Member Role"::DEPENDENT;
        //+MM1.32 [313795]

        MembershipRole."Community Code" := Membership."Community Code";
        MembershipRole."Membership Entry No." := MembershipEntryNo;
        MembershipRole."Member Entry No." := MemberEntryNo;

        MembershipRole."User Logon ID" := SelectMemberLogonCredentials (Membership."Community Code", Member, MemberInfoCapture."User Logon ID");
        if (LogonIdExists (MembershipRole."Community Code", MembershipRole."User Logon ID")) then
          Error (LOGIN_ID_EXIST, MembershipRole."User Logon ID", Member."External Member No.");

        //-MM1.32 [313795]
        MembershipRole."GDPR Agreement No." := MembershipSetup."GDPR Agreement No.";
        MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
        //+MM1.32 [313795]

        MembershipRole."Password Hash" := EncodeSHA1 (MemberInfoCapture."Password SHA1");
        MembershipRole."Created At" := CurrentDateTime;
        MembershipRole.Insert (true);

        //-MM1.32 [313795]
        // To get the requests in the correct order.
        if (MembershipRole."Member Role" <> MembershipRole."Member Role"::DEPENDENT) then begin
          if (MembershipSetup."GDPR Mode" = MembershipSetup."GDPR Mode"::CONSENT) then
              GDPRManagement.CreateAgreementPendingEntry (MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

          if (MemberInfoCapture."Guardian External Member No." = '') then
            MemberGDPRManagement.SetApprovalState (MembershipRole."GDPR Agreement No.", MembershipRole."GDPR Data Subject Id", MemberInfoCapture."GDPR Approval");
        end;
        //+MM1.32 [313795]

        MemberCount := GetMembershipMemberCount (MembershipEntryNo);

        //-MM1.33 [324065]
        // Moved to calling function for clarity
        // GuardianMemberEntryNo := GetMemberFromExtMemberNo (MemberInfoCapture."Guardian External Member No.");
        // CreateGuardianRoleWorker (MembershipEntryNo, GuardianMemberEntryNo, MemberInfoCapture."GDPR Approval");
        //

        exit (true);
    end;

    local procedure CreateGuardianRoleWorker(MembershipEntryNo: Integer;GuardianMemberEntryNo: Integer;GuardianGdprApproval: Option): Boolean
    var
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        MembershipSetup: Record "MM Membership Setup";
        GDPRManagement: Codeunit "GDPR Management";
        MemberGDPRManagement: Codeunit "MM GDPR Management";
    begin

        if (GuardianMemberEntryNo = 0) then
          exit (false);

        Member.Get (GuardianMemberEntryNo);
        Membership.Get (MembershipEntryNo);

        //-MM1.32 [313795]
        MembershipSetup.Get (Membership."Membership Code");

        // All non-guardians will have their GDPR approval set to "Delegated to Guardian"
        MembershipRole.Reset ();
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.FindSet ()) then begin
          Membership.Get (MembershipEntryNo);
          MembershipSetup.Get (Membership."Membership Code");
          repeat

            if (MembershipRole."Member Role" <> MembershipRole."Member Role"::GUARDIAN) then begin
              if (MembershipRole."Member Role" <> MembershipRole."Member Role"::DEPENDENT) then begin
                MembershipRole."Member Role" := MembershipRole."Member Role"::DEPENDENT;
                MembershipRole.Modify ();
              end;

              if (MembershipSetup."GDPR Agreement No." <> '') then begin
                MembershipRole.CalcFields ("GDPR Approval");

                if ((MembershipRole."GDPR Agreement No." <> MembershipSetup."GDPR Agreement No.") or (MembershipRole."GDPR Data Subject Id" = '')) then begin
                  MembershipRole."GDPR Agreement No." := MembershipSetup."GDPR Agreement No.";
                  if (MembershipRole."GDPR Data Subject Id" = '') then
                    MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
                  MembershipRole.Modify ();
                end;

                if (MembershipRole."GDPR Approval" <> MembershipRole."GDPR Approval"::DELEGATED) then
                  GDPRManagement.CreateAgreementDelegateToGuardianEntry (MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

              end;
            end;

          until (MembershipRole.Next () = 0);

        end;
        //+MM1.32 [313795]

        // Create the GUARDIAN
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter ("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter ("Member Entry No.", '=%1', GuardianMemberEntryNo);
        MembershipRole.SetFilter (Blocked, '=%1', false);

        if (MembershipRole.IsEmpty ()) then begin
          MembershipRole.Init ();
          MembershipRole."Member Role" := MembershipRole."Member Role"::GUARDIAN;

          MembershipRole."Community Code" := Membership."Community Code";
          MembershipRole."Membership Entry No." := MembershipEntryNo;
          MembershipRole."Member Entry No." := GuardianMemberEntryNo;

          //-MM1.32 [313795]
          if (MembershipSetup."GDPR Agreement No." <> '') then begin
            MembershipRole."GDPR Agreement No." := MembershipSetup."GDPR Agreement No.";
            MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
          end;
          //+MM1.32 [313795]

          MembershipRole."Created At" := CurrentDateTime;
          MembershipRole.Insert (true);

          //+MM1.32 [313795]
          if (MembershipRole."GDPR Agreement No." <> '') then begin
            // To get the requests in the correct order.
            if (MembershipSetup."GDPR Mode" = MembershipSetup."GDPR Mode"::CONSENT) then
              GDPRManagement.CreateAgreementPendingEntry (MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

            MemberGDPRManagement.SetApprovalState (MembershipRole."GDPR Agreement No.", MembershipRole."GDPR Data Subject Id", GuardianGdprApproval);
          end;
          //+MM1.32 [313795]
        end;


        exit (true);
    end;

    local procedure IssueMemberCardWorker(FailWithError: Boolean;MembershipEntryNo: Integer;MemberEntryNo: Integer;var MemberInfoCapture: Record "MM Member Info Capture";AllowBlankNumber: Boolean;var CardEntryNo: Integer;var ReasonMessage: Text;ForceValidUntilDate: Boolean): Boolean
    var
        MembershipSetup: Record "MM Membership Setup";
        Membership: Record "MM Membership";
        Member: Record "MM Member";
        MemberCard: Record "MM Member Card";
        MemberCard2: Record "MM Member Card";
        CardValidUntil: Date;
        CardFound: Boolean;
    begin

        CardEntryNo := 0;
        MemberInfoCapture."External Card No." := UpperCase (MemberInfoCapture."External Card No.");

        Membership.Get (MembershipEntryNo);
        MembershipSetup.Get (Membership."Membership Code");
        if (MembershipSetup."Loyalty Card" = MembershipSetup."Loyalty Card"::NO) then
          exit (false);

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
          Member.Get (MemberEntryNo);

        //-MM1.23 [257011]
        CardFound := false;
        if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then begin
          MemberCard2.Reset ();
          MemberCard2.SetCurrentKey ("External Card No.");
          MemberCard2.SetFilter ("External Card No.", '=%1', MemberInfoCapture."External Card No.");
          MemberCard2.SetFilter (Blocked, '=%1', false);
          CardFound := MemberCard2.FindFirst ();
        end;

        if (CardFound) then begin
          MemberCard.Get (MemberCard2."Entry No.");
          CardFound := (MembershipEntryNo = MemberCard2."Membership Entry No.");
        end;
        //+MM1.23 [257011]

        if (not CardFound) then begin
          MemberCard."Entry No." := 0;
          MemberCard.Init ();
          MemberCard."Membership Entry No." := MembershipEntryNo;
          MemberCard."Member Entry No." := MemberEntryNo;

          //-#307113 [307113]
          if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then
            MemberCard."Card Type" := MemberCard."Card Type"::EXTERNAL;
          //+#307113 [307113]

          MemberCard.Insert ();
        end;

        MemberInfoCapture."External Member No" := Member."External Member No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";

        // Override ValidUntil specified on MembershipSetup for card scheme GENERATED
        CardValidUntil := MemberInfoCapture."Valid Until";

        if (MemberInfoCapture."External Card No." = '') then
          if (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::GENERATED) then
            GenerateExtCardNoSimple (MembershipSetup.Code, MemberInfoCapture);

        if (not AllowBlankNumber) and (MemberInfoCapture."External Card No." = '') then begin
          RaiseError (FailWithError, ReasonMessage, MEMBERCARD_BLANK, MEMBERCARD_BLANK_NO);
          exit (false);
        end;

        //IF (MemberInfoCapture."External Card No." <> '') THEN BEGIN
        if (MemberInfoCapture."External Card No." <> '') and (not CardFound) then begin
          MemberCard2.Reset ();
          MemberCard2.SetCurrentKey ("External Card No.");
          MemberCard2.SetFilter ("External Card No.", '=%1', MemberInfoCapture."External Card No.");
          MemberCard2.SetFilter (Blocked, '=%1', false);
          if (MemberCard2.FindFirst ()) then begin
            RaiseError (FailWithError, ReasonMessage, StrSubstNo (MEMBER_CARD_EXIST, MemberCard2."External Card No."), MEMBER_CARD_EXIST_NO);
            exit (false);
          end;
        end;
        //+MM1.23 [257011]

        MemberCard."External Card No." := MemberInfoCapture."External Card No.";
        MemberCard."External Card No. Last 4" := MemberInfoCapture."External Card No. Last 4";
        MemberCard."Pin Code" := MemberInfoCapture."Pin Code";
        MemberCard."Valid Until" := MemberInfoCapture."Valid Until";

        if (ForceValidUntilDate) then
          MemberCard."Valid Until" := CardValidUntil;

        //-MM1.22 [284560]
        MemberCard."Card Is Temporary" := MemberInfoCapture."Temporary Member Card";
        //+MM1.22 [284560]

        MemberCard.Modify ();

        //-NPR5.34 [261216]
        //EXIT (MemberCard."Entry No.");
        CardEntryNo := MemberCard."Entry No.";
        exit (CardEntryNo <> 0);
        //+NPR5.34 [261216]
    end;

    local procedure PrintCard()
    begin
    end;

    local procedure EncodeSHA1(Plain: Text) Encoded: Text
    begin

        exit (Plain);
    end;

    local procedure AssignExternalMembershipNo(CommunityCode: Code[20]) ExternalNo: Code[20]
    var
        Community: Record "MM Member Community";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        Community.Get (CommunityCode);
        ExternalNo := NoSeriesManagement.GetNextNo (Community."External Membership No. Series", Today, true);
    end;

    local procedure AssignExternalMemberNo(SuggestedExternalNo: Code[20];CommunityCode: Code[20]) ExternalNo: Code[20]
    var
        Community: Record "MM Member Community";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        Community.Get (CommunityCode);
        if (SuggestedExternalNo <> '') then begin
          NoSeriesManagement.TestManual (Community."External Member No. Series");
          exit (SuggestedExternalNo);
        end;

        ExternalNo := NoSeriesManagement.GetNextNo (Community."External Member No. Series", Today, true);
    end;

    local procedure GenerateExtCardNoSimple(MembershipCode: Code[20];var MemberInfoCapture: Record "MM Member Info Capture")
    var
        MembershipSetup: Record "MM Membership Setup";
        BaseNumberPadding: Code[100];
        PAN: Code[100];
        PanLength: Integer;
    begin

        MembershipSetup.Get (MembershipCode);

        if (MembershipSetup."Card Number Pattern" = '') then begin
          MembershipSetup."Card Number Pattern" := '[X*4][MA][X*4][MS][S]';
          MembershipSetup."Card Number Length" := 0;
        end;

        BaseNumberPadding := GenerateExtCardNo (MembershipSetup."Card Number Pattern", MemberInfoCapture."External Member No", MemberInfoCapture."External Membership No.", MembershipSetup."Card Number No. Series");

        PanLength := 0;
        case MembershipSetup."Card Number Validation" of
          MembershipSetup."Card Number Validation"::NONE : ;
          MembershipSetup."Card Number Validation"::CHECKDIGIT : PanLength -= 1;
        end;

        if (MembershipSetup."Card Number Length" <> 0) then
          PanLength += MembershipSetup."Card Number Length" - StrLen (MembershipSetup."Card Number Prefix")
        else
          PanLength += StrLen (BaseNumberPadding);

        PAN := StrSubstNo ('%1%2', MembershipSetup."Card Number Prefix", CopyStr (BaseNumberPadding, 1, PanLength));

        case MembershipSetup."Card Number Validation" of
          MembershipSetup."Card Number Validation"::NONE : ;
          MembershipSetup."Card Number Validation"::CHECKDIGIT :
            PAN := StrSubstNo ('%1%2', PAN, GenerateRandom ('N'));
        end;

        if (StrLen (PAN) > MaxStrLen (MemberInfoCapture."External Card No.")) then
          Error (PAN_TO_LONG, MaxStrLen (MemberInfoCapture."External Card No."), MembershipSetup."Card Number Pattern");

        MemberInfoCapture."External Card No." := PAN;
        MemberInfoCapture."External Card No. Last 4" := CopyStr (PAN, StrLen (PAN) -4 +1);
        MemberInfoCapture."Pin Code" := '1234';

        //-#300256 [300256]
        // MemberInfoCapture."Valid Until" := CALCDATE (MembershipSetup."Card Number Valid Until", TODAY);
        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::DATEFORMULA) then
          MemberInfoCapture."Valid Until" := CalcDate (MembershipSetup."Card Number Valid Until", Today);
        //+#300256 [300256]
    end;

    procedure GenerateExtCardNo(GeneratePattern: Text[30];ExternalMemberNo: Code[20];ExternalMembershipNo: Code[20];NumberSeries: Code[10]) ExtCardNo: Code[50]
    var
        PosStartClause: Integer;
        PosEndClause: Integer;
        Pattern: Text[5];
        PatternLength: Integer;
        Itt: Integer;
        Left: Text[10];
        Right: Text[10];
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        if GeneratePattern = '' then
          exit;

        // Pattern example TEXT-[MA][N*5]-[N]
        // MA MemberAccount (external)
        // MS MemberShip (external)
        // S Numberseries
        // N random number (repeats * time)
        // A random char (repeats * time)
        // X random alpha numeric (repeats * time)

        GeneratePattern := UpperCase (GeneratePattern);

        ExtCardNo := '';
        if ( StrLen (DelChr (GeneratePattern, '=', '[')) <> StrLen (DelChr (GeneratePattern, '=', ']'))) then
          Error (PATTERN_ERROR, GeneratePattern);

        while (StrLen (GeneratePattern) > 0) do begin
          PosStartClause := StrPos (GeneratePattern,'[');
          PosEndClause  := StrPos (GeneratePattern,']');
          PatternLength := PosEndClause - PosStartClause - 1;

          Pattern := '';
          if (PatternLength > 0) then
            Pattern := CopyStr(GeneratePattern, PosStartClause + 1, PatternLength);

          if (PatternLength < 1) then begin
            ExtCardNo := ExtCardNo + GeneratePattern;
            exit;
          end;

          if (PosStartClause > 1) then begin
            ExtCardNo := ExtCardNo + CopyStr (GeneratePattern, 1, PosStartClause-1);
          end;

          if (PatternLength > 0) then begin
            Left := Pattern;
            Right := '1';
            if (StrPos (Pattern, '*') > 1) then begin
              Left := CopyStr (Pattern, 1, StrPos (Pattern, '*') -1);
              Right := CopyStr (Pattern, StrPos (Pattern, '*') +1);
            end;

            case Left of
              'MA' : ExtCardNo := StrSubstNo ('%1%2', ExtCardNo, ExternalMemberNo);
              'MS' : ExtCardNo := StrSubstNo ('%1%2', ExtCardNo, ExternalMembershipNo);
              'S' : ExtCardNo := StrSubstNo ('%1%2', ExtCardNo, NoSeriesManagement.GetNextNo (NumberSeries, Today, true));
              'N','A','X' :
                begin
                  Evaluate (PatternLength, Right);
                  for Itt := 1 to PatternLength do
                    ExtCardNo := StrSubstNo ('%1%2', ExtCardNo, GenerateRandom (Left));
                end;
              else begin
                ExtCardNo := StrSubstNo ('%1%2', ExtCardNo, Pattern);
              end;
            end;
          end;

          if (StrLen (GeneratePattern) > PosEndClause) then
            GeneratePattern := CopyStr (GeneratePattern, PosEndClause + 1)
          else
            GeneratePattern := '';

        end;
    end;

    local procedure GenerateRandom(Pattern: Code[2]) Random: Code[1]
    var
        Number: Integer;
        Char: Char;
    begin
        Number := GetRandom(2);
        case Pattern of
          'N'  : Random := Format(Number mod 10);
          'A'  : Char   := (Number mod 25) + 65;
          'X' :
            begin
              if (GetRandom(2) mod 35) < 10 then
                Random := Format(Number mod 10)
              else
                Char:= (Number mod 25) + 65;
            end;
        end;

        if Random = '' then
          exit(UpperCase(Format(Char)));
    end;

    local procedure GetRandom(Bytes: Integer) RandomInt: Integer
    var
        i: Integer;
        RandomHexString: Code[50];
    begin
        RandomHexString := UpperCase(DelChr(Format(CreateGuid),'=','{}-'));
        Bytes := Bytes mod StrLen (RandomHexString);

        RandomInt := 0;
        for i := 1 to Bytes do
          case CopyStr(RandomHexString,i,1) of
            '1': RandomInt += Power(16,Bytes - i);
            '2': RandomInt += 2 * Power(16,Bytes - i);
            '3': RandomInt += 3 * Power(16,Bytes - i);
            '4': RandomInt += 4 * Power(16,Bytes - i);
            '5': RandomInt += 5 * Power(16,Bytes - i);
            '6': RandomInt += 6 * Power(16,Bytes - i);
            '7': RandomInt += 7 * Power(16,Bytes - i);
            '8': RandomInt += 8 * Power(16,Bytes - i);
            '9': RandomInt += 9 * Power(16,Bytes - i);
            'A': RandomInt += 10 * Power(16,Bytes - i);
            'B': RandomInt += 11 * Power(16,Bytes - i);
            'C': RandomInt += 12 * Power(16,Bytes - i);
            'D': RandomInt += 13 * Power(16,Bytes - i);
            'E': RandomInt += 14 * Power(16,Bytes - i);
            'F': RandomInt += 15 * Power(16,Bytes - i);
          end;
    end;

    local procedure LogonIdExists(CommunityCode: Code[20];LogonId: Code[80]): Boolean
    var
        MembershipRole: Record "MM Membership Role";
    begin

        if (LogonId = '') then
          exit (false);

        MembershipRole.SetCurrentKey ("Community Code", "User Logon ID");

        MembershipRole.SetFilter ("Community Code", '=%1', CommunityCode);
        MembershipRole.SetFilter ("User Logon ID", '=%1', LogonId);
        MembershipRole.SetFilter (Blocked, '=%1', false);

        exit (MembershipRole.FindFirst ());
    end;

    local procedure SelectMemberLogonCredentials(CommunityCode: Code[20];Member: Record "MM Member";CustomLogonID: Code[80]) MemberLogonId: Code[80]
    var
        Community: Record "MM Member Community";
        MembershipRole: Record "MM Membership Role";
    begin

        Community.Get (CommunityCode);

        case Community."Member Logon Credentials" of
          Community."Member Logon Credentials"::NA : exit ('');
          Community."Member Logon Credentials"::MEMBER_UNIQUE_ID :
            case Community."Member Unique Identity" of
              Community."Member Unique Identity"::NONE : MemberLogonId := '';
              Community."Member Unique Identity"::EMAIL : MemberLogonId := Member."E-Mail Address";
              Community."Member Unique Identity"::PHONENO : MemberLogonId := Member."Phone No.";
              Community."Member Unique Identity"::SSN : MemberLogonId := Member."Social Security No.";
              else
                Error (CASE_MISSING, Community.FieldName ("Member Unique Identity"), Community."Member Unique Identity");
            end;
          Community."Member Logon Credentials"::MEMBER_NUMBER : MemberLogonId := Member."External Member No.";
          Community."Member Logon Credentials"::CUSTOM : MemberLogonId := CustomLogonID;
          else
            Error (CASE_MISSING, Community.FieldName ("Member Logon Credentials"), Community."Member Logon Credentials");
        end;

        if (MemberLogonId = '') then
          Error (LOGIN_ID_BLANK,
            MembershipRole.FieldName ("User Logon ID"),
            Community.FieldName ("Member Logon Credentials"),
            Community."Member Logon Credentials");

        exit (MemberLogonId);
    end;

    local procedure GetBase64StringFromBinaryFile(Filename: Text) Value: Text
    var
        BinaryReader: DotNet npNetBinaryReader;
        MemoryStream: DotNet npNetMemoryStream;
        Convert: DotNet npNetConvert;
        InStr: InStream;
        f: File;
    begin

        Value := '';

        f.Open(Filename);
        f.CreateInStream(InStr);
        MemoryStream := InStr;
        BinaryReader := BinaryReader.BinaryReader(InStr);

        Value := Convert.ToBase64String(BinaryReader.ReadBytes(MemoryStream.Length));

        MemoryStream.Dispose;
        Clear(MemoryStream);
        f.Close;
        exit(Value);
    end;

    local procedure RaiseError(FailWithError: Boolean;var ResponseMessage: Text;MessageText: Text;MessageId: Text) MessageNumber: Integer
    begin
        ResponseMessage := MessageText;

        if (MessageId <> '') then
          ResponseMessage := StrSubstNo ('[%1] - %2', MessageId, MessageText);

        if (FailWithError) then
          Error (ResponseMessage);

        if not Evaluate (MessageNumber, MessageId) then
          MessageNumber := -1;

        asserterror Error (''); // quiet rollback!
        exit (MessageNumber);
    end;

    local procedure ExitFalseOrWithError(VerboseMessage: Boolean;ErrorMessage: Text): Boolean
    begin

        if (VerboseMessage) then
          Error (ErrorMessage);

        exit (false);
    end;

    local procedure "--Events"()
    begin
    end;

    local procedure OnMembershipChangeEvent(MembershipEntryNo: Integer)
    var
        Membership: Record "MM Membership";
    begin

        //-+MM1.16 [239052]
        if (Membership.Get (MembershipEntryNo)) then begin
          Membership.Modify (true);
        end;
    end;

    local procedure "--ExternalSearchFunctions"()
    begin
    end;

    procedure GetMembershipFromUserPassword(UserLogonId: Code[50];Password: Text[50]) MembershipEntryNo: Integer
    var
        MembershipRole: Record "MM Membership Role";
        Membership: Record "MM Membership";
    begin

        MembershipRole.SetCurrentKey ("User Logon ID");
        MembershipRole.SetFilter ("User Logon ID", '=%1', UserLogonId);
        MembershipRole.SetFilter ("Password Hash", '=%1 | =%2', Password, EncodeSHA1 (Password));

        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (not MembershipRole.FindFirst ()) then
          exit (0);

        Membership.Get (MembershipRole."Membership Entry No.");
        if (Membership.Blocked) then
          exit (0);

        exit (Membership."Entry No.");
    end;

    procedure GetMembershipFromExtMemberNo(ExternalMemberNo: Code[20]) MembershipEntryNo: Integer
    var
        Member: Record "MM Member";
        MembershipRole: Record "MM Membership Role";
        Membership: Record "MM Membership";
    begin

        Member.SetCurrentKey ("External Member No.");
        Member.SetFilter ("External Member No.", '=%1', ExternalMemberNo);
        Member.SetFilter (Blocked, '=%1', false);
        if (not Member.FindFirst ()) then
          exit (0);

        MembershipRole.SetCurrentKey ("Member Entry No.");
        MembershipRole.SetFilter ("Member Entry No.", '=%1', Member."Entry No.");
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (not MembershipRole.FindFirst ()) then
          exit (0);

        if not (Membership.Get (MembershipRole."Membership Entry No.")) then
          exit (0);

        if (Membership.Blocked) then
          exit (0);

        exit (Membership."Entry No.");
    end;

    procedure GetMembershipFromExtCardNo(ExternalCardNo: Text[100];ReferenceDate: Date;var ReasonNotFound: Text) MembershipEntryNo: Integer
    var
        CardEntryNo: Integer;
    begin

        // local check to find cardnumber
        //-#324413 [324413]
        // MembershipEntryNo := GetMembershipFromExtCardNoWorker (ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);
        if (StrLen (ExternalCardNo) <= 50) then
          MembershipEntryNo := GetMembershipFromExtCardNoWorker (ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);
        //+#324413 [324413]

        //-MM1.23 [257011]
        // Foreign cards might have more information then just a raw card number.
        if (MembershipEntryNo = 0) then
          MembershipEntryNo := GetMembershipFromForeignCardNo (ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);

        //+MM1.23 [257011]
    end;

    local procedure GetMembershipFromForeignCardNo(ExternalCardNo: Text[100];ReferenceDate: Date;var ReasonNotFound: Text;var CardEntryNo: Integer) MembershipEntryNo: Integer
    var
        Membership: Record "MM Membership";
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
        RemoteReasonText: Text;
        ForeignMembershipMgr: Codeunit "MM Foreign Membership Mgr.";
        FormatedCardNumber: Text[50];
    begin

        //-MM1.23 [257011]
        ForeignMembershipSetup.SetCurrentKey ("Invokation Priority");
        ForeignMembershipSetup.SetFilter (Disabled, '=%1', false);
        ForeignMembershipSetup.SetFilter ("Community Code", '<>%1', '');
        ForeignMembershipSetup.SetFilter ("Manager Code", '<>%1', '');
        if (ForeignMembershipSetup.FindSet ()) then begin
          repeat

            // try remote number with local prefix
            if (ForeignMembershipSetup."Append Local Prefix" <> '') then begin
              if (StrLen (ForeignMembershipSetup."Append Local Prefix") + StrLen (ExternalCardNo) <= 50) then
                MembershipEntryNo := GetMembershipFromExtCardNoWorker (StrSubstNo ('%1%2', ForeignMembershipSetup."Append Local Prefix", ExternalCardNo), ReferenceDate, RemoteReasonText, CardEntryNo);
            end;

            // try remote number with integration code to parse the scanned card data
            if (MembershipEntryNo = 0) then begin
              ForeignMembershipMgr.FormatForeignCardnumberFromScan (ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code", ExternalCardNo, FormatedCardNumber);
              MembershipEntryNo := GetMembershipFromExtCardNoWorker (FormatedCardNumber, ReferenceDate, RemoteReasonText, CardEntryNo);
            end;

            if (MembershipEntryNo <> 0) then
              if (Membership.Get (MembershipEntryNo)) then
                ForeignMembershipMgr.SynchronizeLoyaltyPoints (ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code", MembershipEntryNo, ExternalCardNo);

          until ((ForeignMembershipSetup.Next() = 0) or (MembershipEntryNo <> 0));
        end;
        //+MM1.23 [257011]
    end;

    local procedure GetMembershipFromExtCardNoWorker(ExternalCardNo: Text[50];ReferenceDate: Date;var ReasonNotFound: Text;var CardEntryNo: Integer) MembershipEntryNo: Integer
    var
        MemberCard: Record "MM Member Card";
        Membership: Record "MM Membership";
        MembershipSetup: Record "MM Membership Setup";
    begin

        ReasonNotFound := '';

        //-#282251 [282251]
        ExternalCardNo := DelChr (ExternalCardNo, '<', ' ');
        if (ExternalCardNo = '') then begin
          ReasonNotFound := StrSubstNo (INVALID_NUMBER, ExternalCardNo, MemberCard.FieldCaption ("External Card No."));
          exit (0);
        end;
        //+#282251 [282251]

        MemberCard.SetCurrentKey ("External Card No.");
        MemberCard.SetFilter ("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1 (ExternalCardNo));

        if (not MemberCard.FindFirst) then begin
          ReasonNotFound := StrSubstNo (MEMBERCARD_NOT_FOUND, ExternalCardNo);
          exit (0);
        end;

        MemberCard.SetFilter (Blocked, '=%1', false);
        if (not MemberCard.FindFirst) then begin
          ReasonNotFound := StrSubstNo (MEMBERCARD_BLOCKED, ExternalCardNo);
          exit (0);
        end;

        if (ReferenceDate = 0D) then
          ReferenceDate := WorkDate;

        //-#300256 [300256]
        if (not Membership.Get (MemberCard."Membership Entry No.")) then begin
          ReasonNotFound := StrSubstNo (MEMBERSHIP_CARD_REF, ExternalCardNo, MemberCard."Membership Entry No.");
          exit (0);
        end;

        MembershipSetup.Get (Membership."Membership Code");
        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then begin
        //+#300256 [300256]

          MemberCard.SetFilter ("Valid Until", '>=%1', ReferenceDate);
          if (not MemberCard.FindFirst ()) then begin

            MemberCard.Reset ();
            MemberCard.SetCurrentKey ("External Card No.");
            MemberCard.SetFilter (Blocked, '=%1', false);
            MemberCard.SetFilter ("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1 (ExternalCardNo));
            if (MemberCard.FindLast ()) then begin
              if (Membership.Get (MemberCard."Membership Entry No.")) then begin
                if (not Membership.Blocked) then begin
                  // external member card number exist, but it has expired, membership is not blocked.
                  //-#300256 [300256]
                  CardEntryNo := MemberCard."Entry No.";
                  exit (Membership."Entry No.");
                  // ReasonNotFound := STRSUBSTNO (MEMBERCARD_EXPIRED, ExternalCardNo);
                  // EXIT (0);
                  //+#300256 [300256]

                end else begin
                  // external member card number exist, it has expired, membership is blocked.
                  ReasonNotFound := StrSubstNo (MEMBERSHIP_BLOCKED, Membership."External Membership No.", ExternalCardNo, Membership."Blocked At");
                  exit (0);
                end;
              end;
            end else begin
              // just in case..
              ReasonNotFound := StrSubstNo (MEMBERCARD_BLOCKED, ExternalCardNo);
              exit (0);
            end;
          end;

        //-#300256 [300256]
        end;

        // IF (NOT Membership.GET (MemberCard."Membership Entry No.")) THEN BEGIN
        //  ReasonNotFound := STRSUBSTNO (MEMBERSHIP_CARD_REF, ExternalCardNo, MemberCard."Membership Entry No.");
        //  EXIT (0);
        // END;
        //+#300256 [300256]

        if (Membership.Blocked) then begin
          ReasonNotFound := StrSubstNo (MEMBERSHIP_BLOCKED, Membership."External Membership No.", ExternalCardNo, Membership."Blocked At");
          exit (0);
        end;

        //-#300256 [300256]
        CardEntryNo := MemberCard."Entry No.";
        //+#300256 [300256]

        exit (Membership."Entry No.");
    end;

    procedure GetMembershipFromExtMembershipNo(ExternalMembershipNo: Code[20]) MembershipEntryNo: Integer
    var
        Membership: Record "MM Membership";
    begin

        Membership.SetCurrentKey ("External Membership No.");
        Membership.SetFilter ("External Membership No.", '=%1', ExternalMembershipNo);
        Membership.SetFilter (Blocked, '=%1', false);
        if (not Membership.FindFirst ()) then
          exit (0);

        exit (Membership."Entry No.");
    end;

    procedure GetMemberFromExtMemberNo(ExternalMemberNo: Code[20]) MemberEntryNo: Integer
    var
        Member: Record "MM Member";
    begin

        Member.SetCurrentKey ("External Member No.");
        Member.SetFilter ("External Member No.", '=%1', ExternalMemberNo);
        Member.SetFilter (Blocked, '=%1', false);
        if (not Member.FindFirst ()) then
          exit (0);

        exit (Member."Entry No.");
    end;

    procedure GetMemberFromExtCardNo(ExternalCardNo: Text[50];ReferenceDate: Date;var NotFoundReasonText: Text) MemberEntryNo: Integer
    var
        MemberCard: Record "MM Member Card";
        Member: Record "MM Member";
        Membership: Record "MM Membership";
        MembershipRole: Record "MM Membership Role";
        MembershipEntryNo: Integer;
        CardEntryNo: Integer;
    begin

        NotFoundReasonText := '';

        //-MM80.1.01
        if (ReferenceDate = 0D) then
          ReferenceDate := Today;

        //-#300256 [300256]
        MembershipEntryNo := GetMembershipFromExtCardNoWorker (ExternalCardNo, ReferenceDate, NotFoundReasonText, CardEntryNo);
        if (MembershipEntryNo = 0) then
          exit (0);

        if (not MemberCard.Get (CardEntryNo)) then begin
          NotFoundReasonText := StrSubstNo (MEMBERCARD_NOT_FOUND, '{'+ExternalCardNo+'}');
          exit (0);
        end;

        if (MemberCard."Member Entry No." = 0) then begin
          NotFoundReasonText := StrSubstNo (MEMBER_CARD_REF, ExternalCardNo, MemberCard."Member Entry No.");
          exit (0);
        end;

        if not Member.Get (MemberCard."Member Entry No.") then begin
          NotFoundReasonText := StrSubstNo (MEMBER_CARD_REF, ExternalCardNo, MemberCard."Member Entry No.");
          exit (0);
        end;

        if (Member.Blocked) then begin
          NotFoundReasonText := StrSubstNo (MEMBER_BLOCKED, Member."External Member No.", Member."Blocked At");
          exit (0);
        end;

        //-#297221 [297221]
        MembershipRole.SetFilter ("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
        MembershipRole.SetFilter ("Member Entry No.", '=%1', MemberCard."Member Entry No.");
        MembershipRole.SetFilter (Blocked, '=%1', false);
        if (MembershipRole.IsEmpty()) then begin
          NotFoundReasonText := StrSubstNo (MEMBER_ROLE_BLOCKED, Member."External Member No.", Membership."External Membership No.");
          exit (0);
        end;
        //+#297221 [297221]

        exit (Member."Entry No.");
        //+MM80.1.01
    end;

    procedure GetMemberFromUserPassword(UserLogonId: Code[50];Password: Text[50]) MemberEntryNo: Integer
    var
        MembershipRole: Record "MM Membership Role";
        Member: Record "MM Member";
    begin

        MembershipRole.SetCurrentKey ("User Logon ID");
        MembershipRole.SetFilter ("User Logon ID", '=%1', UpperCase (UserLogonId));
        MembershipRole.SetFilter ("Password Hash", '=%1|=%2', Password, EncodeSHA1 (Password));
        MembershipRole.SetFilter (Blocked, '=%1', false);
        //-MM1.22 [287080]
        MembershipRole.SetFilter ("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
        //+MM1.22 [287080]

        if (not MembershipRole.FindFirst ()) then
          exit (0);

        Member.Get (MembershipRole."Member Entry No.");
        if (Member.Blocked) then
          exit (0);

        exit (Member."Entry No.");
    end;

    procedure GetMemberCardEntryNo(MemberEntryNo: Integer;MembershipCode: Code[20];ReferenceDate: Date) MemberCardEntryNo: Integer
    var
        MemberCard: Record "MM Member Card";
        Member: Record "MM Member";
        MembershipSetup: Record "MM Membership Setup";
    begin

        if (not Member.Get (MemberEntryNo)) then
          exit (0);

        if (ReferenceDate < Today) then
          ReferenceDate := Today;

        MemberCard.SetFilter ("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter (Blocked, '=%1', false);

        //-#300256 [300256]
        // MemberCard.SETFILTER ("Valid Until", '>=%1', ReferenceDate);
        MembershipSetup.Get (MembershipCode);
        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
          MemberCard.SetFilter ("Valid Until", '>=%1', ReferenceDate);
        //+#300256 [300256]

        if (not MemberCard.FindLast ()) then
          exit (0);

        exit (MemberCard."Entry No.");
    end;

    procedure GetCardEntryNoFromExtCardNo(ExternalCardNo: Text[50]) CardEntryNo: Integer
    var
        MemberCard: Record "MM Member Card";
        PrefixedCardNo: Text;
        ForeignMembershipSetup: Record "MM Foreign Membership Setup";
    begin

        MemberCard.SetCurrentKey ("External Card No.");
        MemberCard.SetFilter ("External Card No.", '=%1|=%2', ExternalCardNo, EncodeSHA1 (ExternalCardNo));
        MemberCard.SetFilter (Blocked, '=%1', false);

        //-#307113 [307113]
        if (MemberCard.IsEmpty ()) then begin
          ForeignMembershipSetup.SetCurrentKey ("Invokation Priority");
          ForeignMembershipSetup.SetFilter (Disabled, '=%1', false);
          ForeignMembershipSetup.SetFilter ("Community Code", '<>%1', '');
          ForeignMembershipSetup.SetFilter ("Manager Code", '<>%1', '');
          if (ForeignMembershipSetup.FindSet ()) then begin
            repeat

              // try remote number with local prefix
              PrefixedCardNo := ExternalCardNo;
              if (ForeignMembershipSetup."Append Local Prefix" <> '') then
                PrefixedCardNo := StrSubstNo ('%1%2', ForeignMembershipSetup."Append Local Prefix", ExternalCardNo);

              MemberCard.SetFilter ("External Card No.", '=%1|=%2', PrefixedCardNo, EncodeSHA1 (PrefixedCardNo));

            until ((ForeignMembershipSetup.Next () = 0) or (not MemberCard.IsEmpty ()));
          end;
        end;
        //+#307113 [307113]

        if (not MemberCard.FindFirst ()) then
          exit (0);

        exit (MemberCard."Entry No.");
    end;

    local procedure "--"()
    begin
    end;

    procedure DeleteCtrlChars(StringToClean: Text): Text
    var
        CtrlChrs: Text[32];
        i: Integer;
    begin
        //-MM1.09
        for i := 1 to 31 do
          CtrlChrs[i] := i;

        exit (DelChr (StringToClean,'=', CtrlChrs));
        //+MM1.09
    end;

    local procedure "--Publishers"()
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMembershipCreateEvent(Membership: Record "MM Membership")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMemberCreateEvent(var Membership: Record "MM Membership";var Member: Record "MM Member")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterMemberFieldsAssignmentEvent(CurrentMember: Record "MM Member";var NewMember: Record "MM Member")
    begin
    end;

    [IntegrationEvent(FALSE, FALSE)]
    local procedure OnAfterInsertMembershipEntry(MembershipEntry: Record "MM Membership Entry")
    begin
    end;
}

