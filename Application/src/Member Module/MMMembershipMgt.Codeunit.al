codeunit 6060127 "NPR MM Membership Mgt."
{

    trigger OnRun()
    begin
    end;

    var
        MembershipEvents: Codeunit "NPR MM Membership Events";

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
        INVALID_CONTACT: Label 'The contact number %1 is not valid in context of customer number %2';
        TO_MANY_MEMBERS_NO: Label '-127001';
        MEMBER_CARD_EXIST_NO: Label '-127002';
        NO_ADMIN_MEMBER_NO: Label '-127003';
        MEMBERCARD_BLANK_NO: Label '-127004';
        INVALID_CONTACT_NO: Label '-127005';
        AGE_VERIFICATION_SETUP_NO: Label '-127006';
        AGE_VERIFICATION_NO: Label '-127007';
        NO_LEDGER_ENTRY: Label 'The membership %1 is not valid.\\It must be activated, but there is no ledger entry associated with that membership that can be actived.';
        NOT_ACTIVATED: Label 'The membership is marked as activate on first use, but has not been activated yet. Retry the action after the membership has been activated.';
        NOT_FOUND: Label '%1 not found. %2';
        GRACE_PERIOD: Label 'The %1 is not allowed because of grace period constraint.';
        PREVENT_CARD_EXTEND: Label 'The validity for card %1 must first manually be extend until %2.';
        INVALID_ACTIVATION_DATE: Label 'The option %1 for %2 is not valid for alteration type %3.';
        AGE_VERIFICATION_SETUP: Label 'Add member failed on age verification because item number for sales was not provided.';
        AGE_VERIFICATION: Label 'Member %1 does not meet the age constraint of %2 years set on this product.';

    procedure CreateMembershipAll(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
    var
        Community: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberEntryNo: Integer;
        CardEntryNo: Integer;
        ResponseMessage: Text;
    begin

        MembershipSalesSetup.TestField(Blocked, false);

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");
        MembershipSetup.TestField(Blocked, false);

        Community.Get(MembershipSetup."Community Code");
        Community.TestField("External Membership No. Series");
        Community.TestField("External Member No. Series");

        MembershipEntryNo := CreateMembership(MembershipSalesSetup, MemberInfoCapture, CreateMembershipLedgerEntry);

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::ANONYMOUS) then
            MemberEntryNo := AddCommunityMember(MembershipEntryNo, 1);

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
            if (not AddNamedMember(MembershipEntryNo, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
                exit(0);

        if (not IssueMemberCardWorker(MembershipEntryNo, MemberEntryNo, MemberInfoCapture, false, CardEntryNo, ResponseMessage, false)) then
            exit(0);

        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Member Entry No" := MemberEntryNo;
        MemberInfoCapture."Card Entry No." := CardEntryNo;

        exit(MembershipEntryNo);
    end;

    procedure CreateMembership(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");
        MembershipSetup.TestField(Blocked, false);

        case MembershipSetup."Membership Type" of
            // Single Shared membership object, anonymous members
            MembershipSetup."Membership Type"::COMMUNITY:
                MembershipEntryNo := GetCommunityMembership(MembershipSetup.Code, true);

            // Shared membership object, named members
            MembershipSetup."Membership Type"::GROUP:
                MembershipEntryNo := GetNewMembership(MembershipSetup.Code, MemberInfoCapture, true);

            // One membership one member
            MembershipSetup."Membership Type"::INDIVIDUAL:
                MembershipEntryNo := GetNewMembership(MembershipSetup.Code, MemberInfoCapture, true);

            else
                Error(CASE_MISSING, MembershipSetup.FieldName("Membership Type"), MembershipSetup."Membership Type");
        end;

        if (CreateMembershipLedgerEntry) then
            AddMembershipLedgerEntry_NEW(MembershipEntryNo, MemberInfoCapture."Document Date", MembershipSalesSetup, MemberInfoCapture);

        exit(MembershipEntryNo);
    end;

    procedure DeleteMembership(MembershipEntryNo: Integer; Force: Boolean)
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        TempMembershipRole: Record "NPR MM Membership Role" temporary;
        MembershipLedgerEntry: Record "NPR MM Membership Entry";
        MemberCard: Record "NPR MM Member Card";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipPointsEntry: Record "NPR MM Members. Points Entry";
        Contact: Record Contact;
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        MagentoSetup: Record "NPR Magento Setup";
        Customer: Record Customer;
        MemberArrivalLogEntry: Record "NPR MM Member Arr. Log Entry";
        MemberCommunication: Record "NPR MM Member Communication";
        NPGDPRManagement: Codeunit "NPR NP GDPR Management";
        GDPRAnonymizationRequestWS: Codeunit "NPR GDPR Anon. Req. WS";
        OriginalCustomerNo: Code[20];
        MembershipTimeFrameEntries: Boolean;
        ReasonCode: Text;
        AnonymizationResponseCode: Integer;
    begin

        if (MembershipEntryNo = 0) then
            exit;

        Membership.Get(MembershipEntryNo);

        if (not Force) then begin
            MembershipSetup.Get(Membership."Membership Code");
            MembershipSetup.TestField("Allow Membership Delete", true);
        end;

        MembershipRole.SetCurrentKey("Membership Entry No.");
        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        if (MembershipRole.FindSet()) then begin
            repeat
                TempMembershipRole.TransferFields(MembershipRole, true);
                TempMembershipRole.Insert();
            until (MembershipRole.Next() = 0);
        end;

        MembershipLedgerEntry.SetCurrentKey("Membership Entry No.");
        MembershipLedgerEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipTimeFrameEntries := MembershipLedgerEntry.FindSet();
        if (MembershipTimeFrameEntries) then
            MembershipLedgerEntry.DeleteAll(true);

        MembershipNotification.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipNotification.DeleteAll();

        MemberNotificationEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MemberNotificationEntry.DeleteAll();

        MemberArrivalLogEntry.SetFilter("External Membership No.", '=%1', Membership."External Membership No.");
        MemberArrivalLogEntry.DeleteAll();

        MemberCard.SetCurrentKey("Membership Entry No.");
        MemberCard.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MemberCard.DeleteAll(true);

        MembershipPointsEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipPointsEntry.DeleteAll();

        MemberCommunication.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MemberCommunication.DeleteAll();

        if (Membership."Customer No." <> '') then begin
            OriginalCustomerNo := Membership."Customer No.";
            Membership."Customer No." := '';
            Membership.Modify();

            if (not MembershipTimeFrameEntries) then
                if (Customer.Get(OriginalCustomerNo)) then
                    if (not Customer.Delete(true)) then
                        if (GDPRAnonymizationRequestWS.CanCustomerBeAnonymized(OriginalCustomerNo, '', AnonymizationResponseCode)) then
                            NPGDPRManagement.AnonymizeCustomer(OriginalCustomerNo);

            if (MembershipTimeFrameEntries) then
                if (GDPRAnonymizationRequestWS.CanCustomerBeAnonymized(OriginalCustomerNo, '', AnonymizationResponseCode)) then
                    NPGDPRManagement.AnonymizeCustomer(OriginalCustomerNo);

        end;

        TempMembershipRole.Reset();
        if (TempMembershipRole.FindSet()) then begin

            if (not MagentoSetup.Get()) then
                MagentoSetup.Init();

            repeat
                if (Contact.Get(TempMembershipRole."Contact No.")) then begin
                    if (not Contact.Delete(true)) then begin
                        case MagentoSetup."Magento Version" of
                            MagentoSetup."Magento Version"::"1":
                                Contact."NPR Magento Contact" := false;
                            MagentoSetup."Magento Version"::"2":
                                Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::BLOCKED;
                        end;
                        Contact.Modify(true);
                    end;
                end;

                MembershipRole.Get(TempMembershipRole."Membership Entry No.", TempMembershipRole."Member Entry No.");
                MembershipRole.Delete();

                // Delete member only when orphaned
                MembershipRole.Reset();
                MembershipRole.SetFilter("Member Entry No.", '=%1', TempMembershipRole."Member Entry No.");
                if (MembershipRole.IsEmpty()) then
                    if (Member.Get(TempMembershipRole."Member Entry No.")) then
                        Member.Delete();

            until (TempMembershipRole.Next() = 0);
        end;

        Membership.Delete();

    end;

    procedure AddMemberAndCard(MembershipEntryNo: Integer; var MemberInfoCapture: Record "NPR MM Member Info Capture"; AllowBlankExternalCardNumber: Boolean; var MemberEntryNo: Integer; var ResponseMessage: Text): Boolean
    begin

        if (not AddNamedMember(MembershipEntryNo, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
            exit(false);

        if (not IssueMemberCardWorker(MembershipEntryNo, MemberEntryNo, MemberInfoCapture, AllowBlankExternalCardNumber, MemberInfoCapture."Card Entry No.", ResponseMessage, false)) then
            exit(false);

        exit(true);
    end;

    procedure AddAnonymousMember(MembershipInfoCapture: Record "NPR MM Member Info Capture"; NumberOfMembers: Integer)
    begin

        AddCommunityMember(MembershipInfoCapture."Membership Entry No.", NumberOfMembers);
    end;

    procedure AddNamedMember(MembershipEntryNo: Integer; var MembershipInfoCapture: Record "NPR MM Member Info Capture"; var MemberEntryNo: Integer; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        ErrorText: Text;
        MemberCount: Integer;
        GuardianMemberEntryNo: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        Community.Get(Membership."Community Code");

        Member.Init();
        if (Member.Get(CheckMemberUniqueId(Community.Code, MembershipInfoCapture))) then begin
            SetMemberFields(Member, MembershipInfoCapture);
            ValidateMemberFields(Membership."Entry No.", Member, ErrorText);
            Member.Modify();
            MemberEntryNo := Member."Entry No.";
            exit(MemberEntryNo <> 0);
        end;

        Member."External Member No." := AssignExternalMemberNo(MembershipInfoCapture."External Member No", Membership."Community Code");
        SetMemberFields(Member, MembershipInfoCapture);

        Member.Insert(true);

        if (not CreateMemberRole(Member."Entry No.", MembershipEntryNo, MembershipInfoCapture, MemberCount, ReasonText)) then
            exit(false);

        CreateMemberCommunicationDefaultSetup(Member."Entry No.");

        if (MembershipInfoCapture."Guardian External Member No." <> '') then begin
            GuardianMemberEntryNo := GetMemberFromExtMemberNo(MembershipInfoCapture."Guardian External Member No.");
            CreateGuardianRoleWorker(MembershipEntryNo, GuardianMemberEntryNo, MembershipInfoCapture."GDPR Approval");
        end;

        if (Community."Membership to Cust. Rel.") then begin
            // First member updates customer address
            MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
            MembershipRole.SetFilter(Blocked, '=%1', false);

            if (MembershipRole.IsEmpty()) then begin

                MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
                if (MembershipRole.IsEmpty()) then
                    exit(RaiseError(ReasonText, NO_ADMIN_MEMBER, NO_ADMIN_MEMBER_NO) = 0);
            end;

            MembershipRole.Reset();
            MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipRole.SetFilter("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::DEPENDENT);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            MembershipRole.FindFirst();

            UpdateCustomerFromMember(MembershipEntryNo, MembershipRole."Member Entry No.");

            if (MemberCount > 1) then
                AddCustomerContact(MembershipEntryNo, Member."Entry No."); // The member just being added.

        end;

        ValidateMemberFields(Membership."Entry No.", Member, ErrorText);

        DuplicateMcsPersonIdReference(MembershipInfoCapture, Member, true);

        TransferInfoCaptureAttributes(MembershipInfoCapture."Entry No.", DATABASE::"NPR MM Member", Member."Entry No.");

        if (MembershipSetup."Enable Age Verification") then begin
            if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MembershipInfoCapture."Item No.")) then
                exit(RaiseError(ReasonText, AGE_VERIFICATION_SETUP, AGE_VERIFICATION_SETUP_NO) = 0);

            if (not CheckAgeConstraint(GetMembershipAgeConstraintDate(MembershipSalesSetup, MembershipInfoCapture), Member.Birthday, MembershipSetup."Validate Age Against",
                MembershipSalesSetup."Age Constraint Type", MembershipSalesSetup."Age Constraint (Years)")) then
                exit(RaiseError(ReasonText, StrSubstNo(AGE_VERIFICATION, Member."Display Name", MembershipSalesSetup."Age Constraint (Years)"), AGE_VERIFICATION_NO) = 0);
        end;

        MembershipEvents.OnAfterMemberCreateEvent(Membership, Member);
        AddMemberCreateNotification(MembershipEntryNo, MembershipSetup, Member, MembershipInfoCapture);

        MemberEntryNo := Member."Entry No.";
        exit(MemberEntryNo <> 0);
    end;

    procedure DeleteMember(MemberEntryNo: Integer; ForceMemberDelete: Boolean)
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        MemberCard: Record "NPR MM Member Card";
        MemberNotificationEntry: Record "NPR MM Member Notific. Entry";
        Contact: Record Contact;
        MagentoSetup: Record "NPR Magento Setup";
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit;

        MembershipRole.SetCurrentKey("Member Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MembershipRole.FindSet()) then begin

            if (not MagentoSetup.Get()) then
                MagentoSetup.Init();

            repeat
                if (Contact.Get(MembershipRole."Contact No.")) then begin

                    case MagentoSetup."Magento Version" of
                        MagentoSetup."Magento Version"::"1":
                            Contact."NPR Magento Contact" := false;
                        MagentoSetup."Magento Version"::"2":
                            Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::BLOCKED;
                    end;

                    Contact.Modify(true);
                end;
            until (MembershipRole.Next() = 0);
        end;

        MembershipRole.DeleteAll();

        if (MemberCard.SetCurrentKey("Member Entry No.")) then;
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.DeleteAll();

        if (MemberNotificationEntry.SetCurrentKey("Member Entry No.")) then;
        MemberNotificationEntry.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberNotificationEntry.DeleteAll();

        if (ForceMemberDelete) then
            Member.Delete();

    end;

    procedure AddGuardianMember(MembershipEntryNo: Integer; GuardianExternalMemberNo: Code[20]; GdprApproval: Option): Boolean
    var
        GuardianMemberEntryNo: Integer;
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (MembershipEntryNo = 0) then
            exit(false);

        if (GuardianExternalMemberNo = '') then
            exit(false);

        GuardianMemberEntryNo := GetMemberFromExtMemberNo(GuardianExternalMemberNo);
        if (not (CreateGuardianRoleWorker(MembershipEntryNo, GuardianMemberEntryNo, GdprApproval))) then
            exit(false);

        MembershipRole.Reset();
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1|=%2', MembershipRole."Member Role"::ADMIN, MembershipRole."Member Role"::DEPENDENT);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.FindFirst();
        UpdateCustomerFromMember(MembershipEntryNo, MembershipRole."Member Entry No.");

        exit(true);

    end;

    procedure PrintOffline(PrintOption: Option; EntryNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        case PrintOption of
            MemberInfoCapture."Information Context"::PRINT_MEMBERSHIP:
                MemberInfoCapture."Membership Entry No." := EntryNo;
            MemberInfoCapture."Information Context"::PRINT_CARD:
                MemberInfoCapture."Card Entry No." := EntryNo;
            MemberInfoCapture."Information Context"::PRINT_ACCOUNT:
                MemberInfoCapture."Member Entry No" := EntryNo;
        end;

        MemberInfoCapture."Information Context" := PrintOption;
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::PRINT_JNL;

        if ((MemberInfoCapture."Card Entry No." <> 0) and (MemberCard.Get(MemberInfoCapture."Card Entry No."))) then begin

            MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
            MembershipEntry.SetFilter(Blocked, '=%1', false);

            if (MembershipEntry.FindLast()) then begin
                MemberInfoCapture."Document No." := MembershipEntry."Document No.";
                MemberInfoCapture."Receipt No." := MembershipEntry."Receipt No.";
            end;

            MemberInfoCapture."External Card No." := MemberCard."External Card No.";
            MemberInfoCapture."External Card No. Last 4" := MemberCard."External Card No. Last 4";
            MemberInfoCapture."Valid Until" := MemberCard."Valid Until";
            MemberInfoCapture."Membership Entry No." := MemberCard."Membership Entry No.";
            MemberInfoCapture."Member Entry No" := MemberCard."Member Entry No."
        end;

        if ((MemberInfoCapture."Membership Entry No." <> 0) and (Membership.Get(MemberInfoCapture."Membership Entry No."))) then begin
            MemberInfoCapture."Company Name" := Membership."Company Name";
            MemberInfoCapture."Membership Code" := Membership."Membership Code";
            MemberInfoCapture."External Membership No." := Membership."External Membership No.";
            MemberInfoCapture."Document Date" := Membership."Issued Date";
        end;

        if ((MemberInfoCapture."Member Entry No" <> 0) and (Member.Get(MemberInfoCapture."Member Entry No"))) then begin
            MemberInfoCapture."External Member No" := Member."External Member No.";
            MemberInfoCapture."First Name" := Member."First Name";
            MemberInfoCapture."Last Name" := Member."Last Name";
            MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";
            MemberInfoCapture."Phone No." := Member."Phone No.";
        end;

        MemberInfoCapture.Insert();

    end;

    procedure GetMemberImage(MemberEntryNo: Integer; var Base64StringImage: Text) Success: Boolean
    var
        Member: Record "NPR MM Member";
        InStr: InStream;
        Base64Convert: Codeunit "Base64 Convert";
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        if (not Member.Picture.HasValue()) then
            exit(false);

        Member.CalcFields(Picture);
        Member.Picture.CreateInStream(InStr);
        Base64StringImage := Base64Convert.ToBase64(InStr);
        exit(true);
    end;

    procedure UpdateMember(MembershipEntryNo: Integer; MemberEntryNo: Integer; MembershipInfoCapture: Record "NPR MM Member Info Capture") Success: Boolean
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        ErrorText: Text;
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        SetMemberFields(Member, MembershipInfoCapture);
        ValidateMemberFields(Membership."Entry No.", Member, ErrorText);
        Member.Modify();

        if (MembershipInfoCapture."Guardian External Member No." <> '') then
            AddGuardianMember(MembershipEntryNo, MembershipInfoCapture."Guardian External Member No.", MembershipInfoCapture."GDPR Approval");

        TransferInfoCaptureAttributes(MembershipInfoCapture."Entry No.", DATABASE::"NPR MM Member", Member."Entry No.");

        SynchronizeCustomerAndContact(MembershipEntryNo);

        exit(true);

    end;

    procedure UpdateMemberImage(MemberEntryNo: Integer; Base64StringImage: Text) Success: Boolean
    var
        OutStr: OutStream;
        Member: Record "NPR MM Member";
        Base64Convert: Codeunit "Base64 Convert";
    begin
        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        Member.Picture.CreateOutStream(OutStr);
        Base64Convert.FromBase64(Base64StringImage, OutStr);
        exit(Member.Modify());
    end;

    procedure UpdateMemberPassword(MemberEntryNo: Integer; UserLogonID: Code[50]; NewPassword: Text[50]) Success: Boolean
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipRole.SetFilter("User Logon ID", '=%1', UserLogonID);
        if (not MembershipRole.FindFirst()) then
            exit(false);

        MembershipRole."Password Hash" := EncodeSHA1(NewPassword);
        exit(MembershipRole.Modify());
    end;

    procedure FindMembershipUsing(SearchMethod: Code[20]; Key1: Text[100]; Key2: Text[100]) MembershipEntryNo: Integer
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MemberCard: Record "NPR MM Member Card";
        NotFoundReasonText: Text;
    begin

        if (Key1 = '') then
            exit(0);

        case SearchMethod of
            'EXT-CARD-NO':
                exit(GetMembershipFromExtCardNo(CopyStr(Key1, 1, MaxStrLen(MemberCard."External Card No.")), WorkDate, NotFoundReasonText));
            'EXT-MEMBER-NO':
                exit(GetMembershipFromExtMemberNo(CopyStr(Key1, 1, MaxStrLen(Member."External Member No."))));
            'EXT-MEMBERSHIP-NO':
                exit(GetMembershipFromExtMembershipNo(CopyStr(Key1, 1, MaxStrLen(Membership."External Membership No."))));
            'USER-PW':
                exit(GetMembershipFromUserPassword(CopyStr(Key1, 1, MaxStrLen(MembershipRole."User Logon ID")), CopyStr(Key2, 1, MaxStrLen(MembershipRole."Password Hash"))));
            else
                Error(CASE_MISSING, 'FindMembershipUsing', SearchMethod);
        end;
    end;

    procedure GetMembershipValidDate(MembershipEntryNo: Integer; ReferenceDate: Date; var ValidFromDate: Date; var ValidUntilDate: Date) IsValid: Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        ValidFromDate := 0D;
        ValidUntilDate := 0D;

        if (MembershipEntryNo = 0) then
            exit(false);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (MembershipSetup.Perpetual) then begin
            ValidUntilDate := DMY2Date(31, 12, 9999);
            exit(true);
        end;

        if (ReferenceDate = 0D) then
            ReferenceDate := Today;

        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (MembershipEntry.IsEmpty()) then
            exit(false);

        MembershipEntry.SetFilter("Valid From Date", '<=%1', ReferenceDate);
        MembershipEntry.SetFilter("Valid Until Date", '>=%1', ReferenceDate);

        if (not MembershipEntry.FindSet()) then begin
            // not valid on reference date, maybe in the future
            MembershipEntry.Reset();
            MembershipEntry.SetCurrentKey("Membership Entry No.");
            MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipEntry.SetFilter("Valid From Date", '>=%1', ReferenceDate);
            MembershipEntry.SetFilter(Blocked, '=%1', false);
            MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
            if (MembershipEntry.FindFirst()) then begin
                ValidFromDate := MembershipEntry."Valid From Date";
                ValidUntilDate := MembershipEntry."Valid Until Date";
            end else begin

                // or maybe in the past
                MembershipEntry.Reset();
                MembershipEntry.SetCurrentKey("Membership Entry No.");
                MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                MembershipEntry.SetFilter(Blocked, '=%1', false);
                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                if (MembershipEntry.FindLast()) then begin
                    ValidFromDate := MembershipEntry."Valid From Date";
                    ValidUntilDate := MembershipEntry."Valid Until Date";
                end;

            end;

            exit(false);
        end;

        ValidFromDate := MembershipEntry."Valid From Date";
        ValidUntilDate := MembershipEntry."Valid Until Date";

        exit(((ReferenceDate >= ValidFromDate) and (ReferenceDate <= ValidUntilDate)) and (not Membership.Blocked));
    end;

    procedure GetMembershipMaxValidUntilDate(MembershipEntryNo: Integer; var MaxValidUntilDate: Date): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        MaxValidUntilDate := 0D;

        if (MembershipEntryNo = 0) then
            exit(false);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (MembershipSetup.Perpetual) then begin
            MaxValidUntilDate := DMY2Date(31, 12, 9999);
            exit(true);
        end;

        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (MembershipEntry.IsEmpty()) then
            exit(false);

        MembershipEntry.FindSet();
        repeat
            if (MaxValidUntilDate < MembershipEntry."Valid Until Date") then
                MaxValidUntilDate := MembershipEntry."Valid Until Date";
        until (MembershipEntry.Next() = 0);

        exit(MaxValidUntilDate <> 0D);
    end;

    procedure GetConsecutiveTimeFrame(MembershipEntryNo: Integer; ReferenceDate: Date; var FromDate: Date; var UntilDate: Date): Boolean;
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        FromDate := 0D;
        UntilDate := 0D;

        if (MembershipEntryNo = 0) then
            exit(false);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (not MembershipSetup.Get(Membership."Membership Code")) then
            exit(false);

        if (MembershipSetup.Perpetual) then begin
            UntilDate := DMY2Date(31, 12, 9999);
            exit(true);
        end;

        if (ReferenceDate = 0D) then
            ReferenceDate := TODAY;

        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        MembershipEntry.SetFilter("Valid From Date", '<=%1', ReferenceDate);
        MembershipEntry.SetFilter("Valid Until Date", '>=%1', ReferenceDate);
        if (not MembershipEntry.FindFirst()) then
            exit(false);

        // Searching lowest date
        repeat
            FromDate := MembershipEntry."Valid From Date";
            if (FromDate <> 0D) then
                FromDate := CalcDate('<-1D>', FromDate);
            MembershipEntry.SetFilter("Valid From Date", '<=%1', FromDate);
            MembershipEntry.SetFilter("Valid Until Date", '>=%1', FromDate);
        until (not MembershipEntry.FindLast() or (FromDate = 0D));

        // reset to reference date
        MembershipEntry.SetFilter("Valid From Date", '<=%1', ReferenceDate);
        MembershipEntry.SetFilter("Valid Until Date", '>=%1', ReferenceDate);
        if (not MembershipEntry.FindFirst()) then
            exit(false);

        // Search highest date
        repeat
            UntilDate := MembershipEntry."Valid Until Date";
            if (UntilDate < DMY2Date(31, 12, 9999)) then
                UntilDate := CalcDate('<+1D>', UntilDate);
            MembershipEntry.SetFilter("Valid From Date", '<=%1', UntilDate);
            MembershipEntry.SetFilter("Valid Until Date", '>=%1', UntilDate);
        until (not MembershipEntry.FindLast() or (UntilDate = DMY2Date(31, 12, 9999)));

        FromDate := CalcDate('<+1D>', FromDate);
        UntilDate := CalcDate('<-1D>', UntilDate);

        exit(true);

    end;

    procedure IsMembershipActive(MemberShipEntryNo: Integer; ReferenceDate: Date; WithActivate: Boolean) IsActive: Boolean
    var
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        if (WithActivate) then begin
            ActivateMembershipLedgerEntry(MemberShipEntryNo, ReferenceDate);
        end;

        exit(GetMembershipValidDate(MemberShipEntryNo, ReferenceDate, ValidFromDate, ValidUntilDate));
    end;

    procedure IsMemberCardActive(ExternalCardNo: Text[100]; ReferenceDate: Date): Boolean
    var
        CardEntryNo: Integer;
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        ReasonNotFound: Text;
    begin

        MemberCard.Reset();
        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter(Blocked, '=%1', false);
        MemberCard.SetFilter("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1(ExternalCardNo));

        if (not MemberCard.FindFirst()) then begin
            GetMembershipFromForeignCardNo(ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);
            if ((CardEntryNo = 0) or (not MemberCard.Get(CardEntryNo))) then
                exit(false);
        end;

        if (not Membership.Get(MemberCard."Membership Entry No.")) then
            exit(false);

        MembershipSetup.Get(Membership."Membership Code");
        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::NA) then
            exit(true);

        exit(MemberCard."Valid Until" >= ReferenceDate);

    end;

    procedure IssueMemberCard(MemberInfoCapture: Record "NPR MM Member Info Capture"; var CardEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        Member: Record "NPR MM Member";
    begin

        // from external
        if (not IssueMemberCardWorker(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture, true, CardEntryNo, ResponseMessage, false)) then
            exit(false);

        MemberInfoCapture.CalcFields(Picture);
        if (MemberInfoCapture.Picture.HasValue()) then begin
            if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                Member.Picture := MemberInfoCapture.Picture;
                Member.Modify();
            end;
        end;

        exit(CardEntryNo <> 0);
    end;

    procedure CheckMemberUniqueId(CommunityCode: Code[20]; MemberInfoCapture: Record "NPR MM Member Info Capture") MemberEntryNo: Integer
    var
        Community: Record "NPR MM Member Community";
        Member: Record "NPR MM Member";
        MemberFound: Boolean;
    begin

        if (not Community.Get(CommunityCode)) then
            exit(-1);

        case Community."Member Unique Identity" of
            Community."Member Unique Identity"::NONE:
                Member.SetFilter("Entry No.", '=%1', -1); // This should never match a current user
            Community."Member Unique Identity"::EMAIL:
                begin
                    MemberInfoCapture.TestField("E-Mail Address");
                    Member.SetFilter("E-Mail Address", '=%1', MemberInfoCapture."E-Mail Address");
                end;
            Community."Member Unique Identity"::PHONENO:
                begin
                    MemberInfoCapture.TestField("Phone No.");
                    Member.SetFilter("Phone No.", '=%1', MemberInfoCapture."Phone No.");
                end;
            Community."Member Unique Identity"::SSN:
                begin
                    MemberInfoCapture.TestField("Social Security No.");
                    Member.SetFilter("Social Security No.", '=%1', MemberInfoCapture."Social Security No.");
                end;
            else
                Error(CASE_MISSING, Community.FieldName("Member Unique Identity"), Community."Member Unique Identity");
        end;

        Member.SetFilter(Blocked, '=%1', false);
        MemberFound := Member.FindFirst();

        if (MemberFound) then begin

            if ((MemberInfoCapture."Guardian External Member No." <> '') and
                (MemberInfoCapture."Guardian External Member No." = Member."External Member No.")) then
                exit(0);

            case Community."Create Member UI Violation" of
                Community."Create Member UI Violation"::ERROR:
                    Error(MEMBER_EXIST, Member.GetFilters());
                Community."Create Member UI Violation"::CONFIRM:
                    if (GuiAllowed()) then
                        if (not Confirm(MEMBER_REUSE, true, Member.GetFilters(), Member."First Name")) then
                            Error(ABORTED);
                Community."Create Member UI Violation"::REUSE:
                    ;
                else
                    Error(CASE_MISSING, Community.FieldName("Create Member UI Violation"), Community."Create Member UI Violation");
            end;
            exit(Member."Entry No.");
        end;

        exit(0);
    end;

    procedure BlockMembership(MembershipEntryNo: Integer; Block: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        Membership.Get(MembershipEntryNo);
        BlockMemberCards(MembershipEntryNo, 0, Block);

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (MembershipRole.FindSet()) then begin
            repeat
                BlockMember(MembershipEntryNo, MembershipRole."Member Entry No.", Block);
            until (MembershipRole.Next() = 0);
        end;

        if (Membership.Blocked <> Block) then begin
            Membership.Validate(Blocked, Block);
            Membership.Modify();
        end;
    end;

    procedure ReflectMembershipRoles(MembershipEntryNo: Integer; MemberEntryNo: Integer; Blocked: Boolean)
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipRole2: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        MM_GDPRManagement: Codeunit "NPR MM GDPR Management";
        GDPRManagement: Codeunit "NPR GDPR Management";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin

        if (not MembershipRole.Get(MembershipEntryNo, MemberEntryNo)) then
            exit;

        MembershipRole.CalcFields("Membership Code");
        if (not MembershipSetup.Get(MembershipRole."Membership Code")) then
            exit;

        if (Blocked) then begin
            if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin
                // when all guardians are blocked, changes roles to admins and members
                MembershipRole2.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                MembershipRole2.SetFilter("Member Role", '=%1', MembershipRole2."Member Role"::GUARDIAN);
                MembershipRole2.SetFilter("Member Entry No.", '<>%1', MemberEntryNo);
                MembershipRole2.SetFilter(Blocked, '=%1', false);
                if (MembershipRole2.IsEmpty()) then begin
                    MembershipRole2.Reset();
                    MembershipRole2.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                    MembershipRole2.SetFilter("Member Entry No.", '<>%1', MemberEntryNo);
                    if (MembershipRole2.FindSet()) then begin
                        repeat

                            if (MembershipRole2."GDPR Agreement No." <> '') then
                                GDPRManagement.CreateAgreementPendingEntry(MembershipRole2."GDPR Agreement No.", 0, MembershipRole2."GDPR Data Subject Id");

                            MembershipRole2."Member Role" := MembershipRole2."Member Role"::MEMBER;
                            if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::ALL_ADMINS) then
                                MembershipRole2."Member Role" := MembershipRole2."Member Role"::ADMIN;
                            MembershipRole2.Modify();

                        until (MembershipRole.Next() = 0);

                        if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::FIRST_IS_ADMIN) then begin
                            MembershipRole2."Member Role" := MembershipRole2."Member Role"::ADMIN;
                            MembershipRole2.Modify();
                        end;
                    end;
                end;
            end;

        end;

        if (not Blocked) then begin
            if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin
                // when a guardian is un-blocked, changes all non-guardians to dependents
                MembershipRole2.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                MembershipRole2.SetFilter("Member Role", '<>%1', MembershipRole2."Member Role"::GUARDIAN);
                MembershipRole2.SetFilter(Blocked, '=%1', false);
                if (MembershipRole2.FindSet()) then begin
                    repeat
                        MembershipRole2."Member Role" := MembershipRole2."Member Role"::DEPENDENT;
                        MembershipRole2.Modify();

                        if (MembershipRole2."GDPR Agreement No." <> '') then
                            GDPRManagement.CreateAgreementDelegateToGuardianEntry(MembershipRole2."GDPR Agreement No.", 0, MembershipRole2."GDPR Data Subject Id");

                    until (MembershipRole2.Next() = 0);
                end;

                MembershipRole.Get(MembershipEntryNo, MemberEntryNo);
                MembershipRole."Member Role" := MembershipRole."Member Role"::GUARDIAN;
                MembershipRole.Modify();
            end;
        end;
    end;

    procedure BlockMember(MembershipEntryNo: Integer; MemberEntryNo: Integer; Block: Boolean)
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (MembershipRole.Get(MembershipEntryNo, MemberEntryNo)) then begin
            if (MembershipRole.Blocked <> Block) then begin
                MembershipRole.Validate(Blocked, Block);
                MembershipRole.Modify();
            end;

            if (MembershipRole."Member Role" <> MembershipRole."Member Role"::ANONYMOUS) then begin
                Member.Get(MemberEntryNo);
                if (Member.Blocked <> Block) then begin
                    Member.Validate(Blocked, Block);
                    Member.Modify();
                end;
            end;
        end else begin

            if (Member.Get(MemberEntryNo)) then
                if (Member.Blocked <> Block) then begin
                    Member.Validate(Blocked, Block);
                    Member.Modify();
                end;
        end;

        BlockMemberCards(MembershipEntryNo, MemberEntryNo, Block);
    end;

    procedure BlockMemberCards(MembershipEntryNo: Integer; MemberEntryNo: Integer; Block: Boolean)
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MemberCard.FindSet()) then begin
            repeat
                BlockMemberCard(MemberCard."Entry No.", Block);
            until (MemberCard.Next() = 0);
        end;
    end;

    procedure BlockMemberCard(CardEntryNo: Integer; Block: Boolean)
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        if (MemberCard.Get(CardEntryNo)) then begin
            if (MemberCard.Blocked <> Block) then begin
                MemberCard.Validate(Blocked, Block);
                MemberCard.Modify();
            end;
        end;
    end;

    procedure CreateRegretMemberInfoRequest(ExternalMemberCardNo: Text[100]; RegretWithItemNo: Code[20]) MemberInfoEntryNo: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not (Membership.Get(GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        if (not (Member.Get(GetMemberFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            Error(MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;
        PrefillMemberInfoCapture(MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RegretWithItemNo);

        MemberInfoCapture."Document Date" := Today;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;

        if (not RegretMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    procedure RegretMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal) Success: Boolean
    var
        ReasonText: Text;
    begin

        exit(RegretMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure RegretMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text) Success: Boolean
    begin

        exit(RegretMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure RegretMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text) Success: Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetCurrentKey("Entry No."); //XXX
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then begin

            MembershipEntry.Reset();
            MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
            MembershipEntry.SetFilter("Original Context", '=%1', MembershipEntry."Original Context"::NEW);
            MembershipEntry.SetFilter(Blocked, '=%1', true);
            if (not MembershipEntry.FindFirst()) then begin
                ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters());
                exit(false);
            end;

        end;

        SuggestedUnitPrice := MembershipEntry."Unit Price" * -1;

        if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then
            SuggestedUnitPrice := MembershipEntry."Unit Price";

        if (MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::REGRET, Membership."Membership Code", MemberInfoCapture."Item No.")) then
            if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then begin
                ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
                exit(false);
            end;

        if ((WithConfirm) and (GuiAllowed())) then
            if (not Confirm(CONFIRM_REGRET, false, Membership."External Membership No.", MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date")) then
                exit(false);

        ReasonText := StrSubstNo('%1: %2 {%3 .. %4}', MemberInfoCapture."Information Context", MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");

        if (WithUpdate) then begin

            if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then begin
                DoReverseRegretTimeFrame(MembershipEntry);
            end else begin
                DoRegretTimeframe(MembershipEntry);
            end;

        end;

        OutStartDate := MembershipEntry."Valid From Date";
        OutUntilDate := MembershipEntry."Valid Until Date";

        exit(true);
    end;

    local procedure DoReverseRegretTimeFrame(var MembershipEntry: Record "NPR MM Membership Entry")
    begin

        if (not ((MembershipEntry.Context = MembershipEntry.Context::REGRET) and (MembershipEntry."Original Context" = MembershipEntry."Original Context"::NEW))) then
            Error('Only the initial new transaction may be reverse regretted.');

        MembershipEntry.Context := MembershipEntry."Original Context";
        MembershipEntry.Validate(Blocked, false);
        MembershipEntry.Modify();

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipEntry);

        OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
    end;

    procedure DoRegretTimeframe(var MembershipEntry: Record "NPR MM Membership Entry")
    var
        Membership: Record "NPR MM Membership";
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
    begin

        // Note - also invoked from MM Member WebService Mgr
        if (MembershipEntry.Context = MembershipEntry.Context::AUTORENEW) then
            MembershipAutoRenew.ReverseInvoice(MembershipEntry."Document No.");

        MembershipEntry."Original Context" := MembershipEntry.Context;
        MembershipEntry.Context := MembershipEntry.Context::REGRET;
        MembershipEntry.Validate(Blocked, true);
        MembershipEntry.Modify();

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipEntry);

        if (MembershipEntry.Next(-1) <> 0) then begin
            if (Format(MembershipEntry."Duration Dateformula") <> '') then begin
                MembershipEntry."Valid Until Date" := CalcDate(MembershipEntry."Duration Dateformula", MembershipEntry."Valid From Date");
                MembershipEntry.Modify();
            end;

            if (MembershipEntry."Original Context" = MembershipEntry."Original Context"::UPGRADE) then begin
                MembershipEntry."Valid Until Date" := GetUpgradeInitialValidUntilDate(MembershipEntry."Entry No.");
                MembershipEntry.Modify();
            end;

            Membership.Get(MembershipEntry."Membership Entry No.");
            if (Membership."Membership Code" <> MembershipEntry."Membership Code") then begin
                Membership."Membership Code" := MembershipEntry."Membership Code";
                Membership.Modify();
            end;
        end;

        OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");

    end;

    procedure CreateCancelMemberInfoRequest(ExternalMemberCardNo: Text[100]; CancelWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not (Membership.Get(GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        if (not (Member.Get(GetMemberFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            Error(MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture(MemberInfoCapture, Member, Membership, ExternalMemberCardNo, CancelWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::CANCEL;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not CancelMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    procedure CancelMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(CancelMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure CancelMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(CancelMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure CancelMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        EndDateNew: Date;
        CancelledFraction: Decimal;
        NewFraction: Decimal;
        HaveAlterationRule: Boolean;
    begin

        OutStartDate := 0D;
        OutUntilDate := 0D;
        SuggestedUnitPrice := 0;

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then begin
            ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters());
            exit(false);
        end;

        if (WithUpdate) and (MemberInfoCapture."Item No." = '') then begin
            MembershipAlterationSetup."Alteration Activate From" := MembershipAlterationSetup."Alteration Activate From"::ASAP;
            MembershipAlterationSetup."Price Calculation" := MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE;
        end else begin
            if (not MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::CANCEL, Membership."Membership Code", MemberInfoCapture."Item No.")) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));
        end;

        if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then begin
            ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
            exit(false);
        end;

        Item.Get(MemberInfoCapture."Item No.");

        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                EndDateNew := MemberInfoCapture."Document Date";
            MembershipAlterationSetup."Alteration Activate From"::DF:
                EndDateNew := CalcDate(MembershipAlterationSetup."Alteration Date Formula", MemberInfoCapture."Document Date");

            else begin
                    ReasonText := StrSubstNo(INVALID_ACTIVATION_DATE, Format(MembershipAlterationSetup."Alteration Activate From"),
                      MembershipAlterationSetup.FieldCaption("Alteration Activate From"), Format(MembershipAlterationSetup."Alteration Type"));
                    exit(ExitFalseOrWithError(WithConfirm, ReasonText));
                end;

        end;

        if (MembershipEntry."Valid Until Date" <= EndDateNew) then begin
            ReasonText := StrSubstNo(NO_TIMEFRAME, EndDateNew, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));
        end;

        if (EndDateNew <= MembershipEntry."Valid From Date") then begin
            ReasonText := StrSubstNo(NO_TIMEFRAME, EndDateNew, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));
        end;

        if ((WithConfirm) and (GuiAllowed())) then
            if (not Confirm(CONFIRM_CANCEL, false, MembershipAlterationSetup.Description, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", EndDateNew)) then
                exit(false);

        CancelledFraction := 1 - CalculatePeriodStartToDateFraction(MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", EndDateNew);
        NewFraction := 0;
        case MembershipAlterationSetup."Price Calculation" of
            MembershipAlterationSetup."Price Calculation"::UNIT_PRICE:
                SuggestedUnitPrice := -1 * MembershipEntry."Unit Price";
            MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE:
                SuggestedUnitPrice := Round(-CancelledFraction * MembershipEntry."Unit Price", 1);
            MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE:
                SuggestedUnitPrice := 0;
        end;

        ReasonText := StrSubstNo('%1: %2 {%3 .. %4}', MemberInfoCapture."Information Context", MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");

        if (WithUpdate) then begin
            MembershipEntry."Valid Until Date" := EndDateNew;
            MembershipEntry.Modify();

            MembershipEvents.OnAfterInsertMembershipEntry(MembershipEntry);

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := MembershipEntry."Valid From Date";
        OutUntilDate := EndDateNew;

        exit(true);
    end;

    procedure CreateRenewMemberInfoRequest(ExternalMemberCardNo: Text[100]; RenewWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MemberCard: Record "NPR MM Member Card";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText))) then
            Error(NotFoundReasonText);

        if (not (Member.Get(GetMemberFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            Error(MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        if (MembershipEntry."Activate On First Use") then
            Error(NOT_ACTIVATED);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture(MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RenewWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not RenewMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    procedure RenewMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(RenewMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure RenewMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(RenewMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure RenewMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EntryNo: Integer;
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);

        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(NOT_FOUND, MembershipAlterationSetup.TableCaption, '');
        if (not MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::RENEW, Membership."Membership Code", MemberInfoCapture."Item No.")) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        Item.Get(MemberInfoCapture."Item No.");

        if (MembershipAlterationSetup."Alteration Activate From" <> MembershipAlterationSetup."Alteration Activate From"::B2B) then
            if (MembershipEntry."Valid Until Date" < Today) then
                MembershipEntry."Valid Until Date" := CalcDate('<-1D>', Today);

        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                StartDateNew := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
            MembershipAlterationSetup."Alteration Activate From"::DF:
                StartDateNew := CalcDate(MembershipAlterationSetup."Alteration Date Formula", MembershipEntry."Valid Until Date");
            MembershipAlterationSetup."Alteration Activate From"::B2B:
                StartDateNew := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
        end;

        if (MembershipAlterationSetup."Alteration Activate From" <> MembershipAlterationSetup."Alteration Activate From"::B2B) then
            if (StartDateNew < Today) then
                StartDateNew := Today;

        EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        ReasonText := StrSubstNo(CONFLICTING_ENTRY, StartDateNew, EndDateNew);

        if (StartDateNew <= MembershipEntry."Valid Until Date") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(STACKING_NOT_ALLOWED, Membership."Entry No.", Today);
        if (not MembershipAlterationSetup."Stacking Allowed") then
            if (GetLedgerEntryForDate(Membership."Entry No.", Today, EntryNo)) then
                if (EntryNo <> MembershipEntry."Entry No.") then
                    exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (WithConfirm) and (GuiAllowed()) then
            if (not Confirm(RENEW_MEMBERSHIP, false, MembershipAlterationSetup.Description, StartDateNew, EndDateNew)) then
                exit(false);

        if (MembershipAlterationSetup."To Membership Code" <> '') then
            if (not (ValidateChangeMembershipCode(WithConfirm, Membership."Entry No.", StartDateNew, MembershipAlterationSetup."To Membership Code", ReasonText))) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (not CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, MemberInfoCapture."Document Date", StartDateNew, EndDateNew, ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        case MembershipAlterationSetup."Price Calculation" of
            MembershipAlterationSetup."Price Calculation"::UNIT_PRICE:
                SuggestedUnitPrice := Item."Unit Price";
            MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE:
                SuggestedUnitPrice := Item."Unit Price";
            MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE:
                SuggestedUnitPrice := Item."Unit Price";
        end;

        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration(Membership."Entry No.", MembershipAlterationSetup);

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo('%1: %4 -> %5 {%2 .. %3}', MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code");

        if (WithUpdate) then begin
            MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
            if (MembershipAlterationSetup."To Membership Code" <> '') then
                if (MembershipAlterationSetup."From Membership Code" <> MembershipAlterationSetup."To Membership Code") then begin
                    Membership."Membership Code" := MembershipAlterationSetup."To Membership Code";
                    Membership.Modify();
                end;

            MemberInfoCapture."Membership Code" := Membership."Membership Code";

            if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    procedure CreateExtendMemberInfoRequest(ExternalMemberCardNo: Text[100]; RenewWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText))) then
            Error(NotFoundReasonText);

        if (not (Member.Get(GetMemberFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            Error(MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture(MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RenewWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::EXTEND;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not ExtendMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    procedure ExtendMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(ExtendMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure ExtendMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(ExtendMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure ExtendMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
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
    begin

        OutStartDate := 0D;
        OutUntilDate := 0D;
        SuggestedUnitPrice := 0;

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(NOT_FOUND, MembershipAlterationSetup.TableCaption, '');
        if (not MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::EXTEND, Membership."Membership Code", MemberInfoCapture."Item No.")) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        Item.Get(MemberInfoCapture."Item No.");

        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                StartDateNew := MemberInfoCapture."Document Date";
            MembershipAlterationSetup."Alteration Activate From"::DF:
                StartDateNew := CalcDate(MembershipAlterationSetup."Alteration Date Formula", MemberInfoCapture."Document Date");

            else begin
                    ReasonText := StrSubstNo(INVALID_ACTIVATION_DATE, Format(MembershipAlterationSetup."Alteration Activate From"),
                      MembershipAlterationSetup.FieldCaption("Alteration Activate From"), Format(MembershipAlterationSetup."Alteration Type"));
                    exit(ExitFalseOrWithError(WithConfirm, ReasonText));
                end;

        end;

        EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);
        EndDateCurrent := 0D;
        if (MembershipEntry."Valid Until Date" >= StartDateNew) then
            EndDateCurrent := CalcDate('<-1D>', StartDateNew);

        ReasonText := StrSubstNo(CONFLICTING_ENTRY, StartDateNew, EndDateNew);
        if (StartDateNew <= MembershipEntry."Valid From Date") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(EXTEND_TO_SHORT, EndDateNew, MembershipEntry."Valid Until Date");
        if (EndDateNew < MembershipEntry."Valid Until Date") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(MULTIPLE_TIMEFRAMES, MembershipAlterationSetup."Alteration Type", Membership."Entry No.", StartDateNew, EndDateNew, StartDateLedgerEntryNo, EndDateLedgerEntryNo);
        if (ConflictingLedgerEntries(Membership."Entry No.", StartDateNew, EndDateNew, StartDateLedgerEntryNo, EndDateLedgerEntryNo)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if ((WithConfirm) and (GuiAllowed())) then
            if (not Confirm(EXTEND_MEMBERSHIP, false, MembershipAlterationSetup.Description, StartDateNew, EndDateNew)) then
                exit(false);

        if (MembershipAlterationSetup."To Membership Code" <> '') then
            if (not (ValidateChangeMembershipCode(WithConfirm, Membership."Entry No.", StartDateNew, MembershipAlterationSetup."To Membership Code", ReasonText))) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (MembershipEntry."Unit Price (Base)" = 0) then begin
            OldItem.Get(MembershipEntry."Item No.");
            MembershipEntry."Unit Price (Base)" := OldItem."Unit Price";
        end;

        if (not CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, MemberInfoCapture."Document Date", StartDateNew, EndDateNew, ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        CancelledFraction := 1 - CalculatePeriodStartToDateFraction(MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", StartDateNew);
        NewFraction := 1 - CalculatePeriodStartToDateFraction(StartDateNew, EndDateNew, MembershipEntry."Valid Until Date");
        case MembershipAlterationSetup."Price Calculation" of
            MembershipAlterationSetup."Price Calculation"::UNIT_PRICE:
                SuggestedUnitPrice := Item."Unit Price";

            MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE:
                SuggestedUnitPrice := Round(-CancelledFraction * MembershipEntry."Unit Price (Base)" + Item."Unit Price", 0.01);

            MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE:
                SuggestedUnitPrice := Round(NewFraction * Item."Unit Price", 0.01);
        end;

        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration(Membership."Entry No.", MembershipAlterationSetup);

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo('%1: %4 -> %5 {%2 .. %3}', MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code");

        if (WithUpdate) then begin
            MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
            if (MembershipAlterationSetup."To Membership Code" <> '') then
                if (MembershipAlterationSetup."From Membership Code" <> MembershipAlterationSetup."To Membership Code") then begin
                    Membership."Membership Code" := MembershipAlterationSetup."To Membership Code";
                    Membership.Modify();
                end;

            MemberInfoCapture."Membership Code" := Membership."Membership Code";

            if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

            if (EndDateCurrent <> 0D) then begin
                if (EndDateCurrent <= MembershipEntry."Valid From Date") then begin
                    MembershipEntry.Blocked := true;
                    MembershipEntry."Blocked At" := CurrentDateTime();
                    MembershipEntry."Blocked By" := UserId;
                end else begin
                    MembershipEntry."Valid Until Date" := EndDateCurrent;
                end;
                MembershipEntry."Closed By Entry No." := EntryNo;
                MembershipEntry.Modify();
            end;

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    procedure CreateUpgradeMemberInfoRequest(ExternalMemberCardNo: Text[100]; UpgradeWithItemNo: Code[20]): Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        NotFoundReasonText: Text;
    begin

        if (not Membership.Get(GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText))) then
            Error(NotFoundReasonText);

        if (not (Member.Get(GetMemberFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then
            Error(MEMBERSHIP_ENTRY_NOT_FOUND, ExternalMemberCardNo);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Item No." := UpgradeWithItemNo;

        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not UpgradeMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    procedure UpgradeMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(UpgradeMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    procedure UpgradeMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(UpgradeMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure UpgradeMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        OldItem: Record Item;
        StartDateNew: Date;
        EndDateCurrent: Date;
        EndDateNew: Date;
        EntryNo: Integer;
        RemainingFraction: Decimal;
        ValidFromDate: Date;
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(NOT_FOUND, MembershipAlterationSetup.TableCaption, '');
        if (not MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::UPGRADE, Membership."Membership Code", MemberInfoCapture."Item No.")) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        Item.Get(MemberInfoCapture."Item No.");

        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                StartDateNew := MemberInfoCapture."Document Date";

            else begin
                    ReasonText := StrSubstNo(INVALID_ACTIVATION_DATE, Format(MembershipAlterationSetup."Alteration Activate From"),
                      MembershipAlterationSetup.FieldCaption("Alteration Activate From"), Format(MembershipAlterationSetup."Alteration Type"));
                    exit(ExitFalseOrWithError(WithConfirm, ReasonText));
                end;

        end;

        EndDateCurrent := CalcDate('<-1D>', StartDateNew);
        EndDateNew := MembershipEntry."Valid Until Date";

        if (MembershipAlterationSetup."Upgrade With New Duration") then
            EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        ReasonText := StrSubstNo(MEMBERSHIP_ENTRY_NOT_FOUND, Membership."External Membership No.");
        if (MembershipEntry."Valid Until Date" < StartDateNew) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(CONFLICTING_ENTRY, StartDateNew, MembershipEntry."Valid Until Date");
        if (StartDateNew < MembershipEntry."Valid From Date") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (WithConfirm) and (GuiAllowed()) then
            if (not Confirm(UPGRADE_MEMBERSHIP, false, MembershipAlterationSetup.Description, StartDateNew, EndDateNew)) then
                exit(false);

        if (not (ValidateChangeMembershipCode(WithConfirm, Membership."Entry No.", StartDateNew, MembershipAlterationSetup."To Membership Code", ReasonText))) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (MembershipEntry."Unit Price (Base)" = 0) then begin
            OldItem.Get(MembershipEntry."Item No.");
            MembershipEntry."Unit Price (Base)" := OldItem."Unit Price";
        end;
        ValidFromDate := GetUpgradeInitialValidFromDate(MembershipEntry."Entry No.");

        if (not CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, MemberInfoCapture."Document Date", StartDateNew, EndDateNew, ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        RemainingFraction := 1 - CalculatePeriodStartToDateFraction(ValidFromDate, EndDateNew, StartDateNew);
        case MembershipAlterationSetup."Price Calculation" of
            MembershipAlterationSetup."Price Calculation"::UNIT_PRICE:
                SuggestedUnitPrice := Item."Unit Price";

            MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE:
                SuggestedUnitPrice := -RemainingFraction * MembershipEntry."Unit Price (Base)" + RemainingFraction * Item."Unit Price";

            MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE:
                SuggestedUnitPrice := RemainingFraction * Item."Unit Price";
        end;

        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration(Membership."Entry No.", MembershipAlterationSetup);

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo('%1: %4 -> %5 {%2 .. %3} {%6 {%7,%8} -> %9}',
                                  MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code",
                                  Round(RemainingFraction, 0.01), Item."Unit Price", MembershipEntry."Unit Price (Base)", Round(SuggestedUnitPrice, 0.01));

        if (WithUpdate) then begin
            MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
            if (MembershipAlterationSetup."From Membership Code" <> MembershipAlterationSetup."To Membership Code") then begin
                Membership."Membership Code" := MembershipAlterationSetup."To Membership Code";
                Membership.Modify();
            end;

            MemberInfoCapture."Membership Code" := Membership."Membership Code";

            if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

            // TODO - consider same date!
            if (StartDateNew = MembershipEntry."Valid From Date") then begin
                //MembershipEntry.Blocked := true;
                //MembershipEntry."Blocked At" := CurrentDateTime;
                //XXMembershipEntry."Blocked By" := USERID;
            end;

            MembershipEntry."Valid Until Date" := EndDateCurrent;
            MembershipEntry."Closed By Entry No." := EntryNo;

            MembershipEntry.Modify();

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    local procedure GetUpgradeInitialValidFromDate(EntryNo: Integer) ValidFrom: Date
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        MembershipEntry.Get(EntryNo);
        if (MembershipEntry.Context <> MembershipEntry.Context::UPGRADE) then
            exit(MembershipEntry."Valid From Date");

        MembershipEntry.Reset();
        MembershipEntry.SetFilter("Closed By Entry No.", '=%1', EntryNo);
        if (MembershipEntry.FindFirst()) then
            ValidFrom := GetUpgradeInitialValidFromDate(MembershipEntry."Entry No.");
    end;

    local procedure GetUpgradeInitialValidUntilDate(EntryNo: Integer) ValidUntil: Date
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        MembershipEntry.Get(EntryNo);
        if (MembershipEntry.Context <> MembershipEntry.Context::UPGRADE) then
            exit(CalcDate(MembershipEntry."Duration Dateformula", MembershipEntry."Valid From Date"));

        MembershipEntry.Reset();
        MembershipEntry.SetFilter("Closed By Entry No.", '=%1', EntryNo);
        if (MembershipEntry.FindFirst()) then
            ValidUntil := GetUpgradeInitialValidUntilDate(MembershipEntry."Entry No.");
    end;

    procedure CalculateRemainingAmount(MembershipEntry: Record "NPR MM Membership Entry"; var OriginalAmountLCY: Decimal; var RemainingAmountLCY: Decimal; var DueDate: Date): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin

        OriginalAmountLCY := 0;
        RemainingAmountLCY := 0;
        DueDate := 0D;

        if (MembershipEntry."Document No." = '') then
            exit(false);

        if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then
            exit(true);

        if (not SalesInvoiceHeader.Get(MembershipEntry."Document No.")) then begin
            SalesInvoiceHeader.SetFilter("Pre-Assigned No.", '=%1', MembershipEntry."Document No.");
            if (not SalesInvoiceHeader.FindFirst()) then
                exit(false);
        end;

        CustLedgerEntry.SetFilter("Document No.", '=%1', SalesInvoiceHeader."No.");
        if (not CustLedgerEntry.FindFirst()) then
            exit(false);

        CustLedgerEntry.CalcFields("Original Amt. (LCY)", "Remaining Amt. (LCY)");
        OriginalAmountLCY := CustLedgerEntry."Original Amt. (LCY)";
        RemainingAmountLCY := CustLedgerEntry."Remaining Amt. (LCY)";
        DueDate := CustLedgerEntry."Due Date";
        exit(true);
    end;

    procedure CreateAutoRenewMemberInfoRequest(MembershipEntryNo: Integer; RenewWithItemNo: Code[20]; var ReasonText: Text): Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        HaveAutoRenewItem: Boolean;
    begin

        if (not Membership.Get(MembershipEntryNo)) then begin
            ReasonText := StrSubstNo(NOT_FOUND, Membership.TableCaption, MembershipEntryNo);
            exit(0);
        end;

        MembershipEntry.SetCurrentKey("Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then begin
            ReasonText := TIME_ENTRY_NOT_FOUND;
            exit(0);
        end;

        HaveAutoRenewItem := (RenewWithItemNo <> '');
        if (not HaveAutoRenewItem) then begin
            case MembershipEntry.Context of
                MembershipEntry.Context::NEW:
                    begin
                        HaveAutoRenewItem := MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipSalesSetup."Auto-Renew To";
                    end;
                MembershipEntry.Context::RENEW:
                    begin
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::RENEW, Membership."Membership Code", MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                    end;
                MembershipEntry.Context::EXTEND:
                    begin
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::EXTEND, Membership."Membership Code", MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                    end;
                MembershipEntry.Context::UPGRADE:
                    begin
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::UPGRADE, Membership."Membership Code", MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                    end;
                MembershipEntry.Context::AUTORENEW:
                    begin
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                    end;
            end;
        end;

        if (not HaveAutoRenewItem) then begin
            HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", MembershipEntry."Item No.");
            RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
        end;

        if (not HaveAutoRenewItem) then begin
            ReasonText := StrSubstNo(NOT_FOUND, 'Auto-Renew rule', StrSubstNo('%1 for %2', MembershipEntry.Context, MembershipEntry."Item No."));
            exit(0);
        end;

        if (RenewWithItemNo = '') then begin
            ReasonText := StrSubstNo(NOT_FOUND, 'Auto-Renew rule item', StrSubstNo('%1 for %2', MembershipEntry.Context, MembershipEntry."Item No."));
            exit(0);
        end;

        if (not MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", RenewWithItemNo)) then begin
            ReasonText := StrSubstNo(NOT_FOUND, 'Auto-Renew item', StrSubstNo('%1 with %2', MembershipEntry.Context::AUTORENEW, RenewWithItemNo));
            exit(0);
        end;

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Item No." := RenewWithItemNo;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;
        MemberInfoCapture."Document Date" := Today; // Active

        if (not AutoRenewMembershipWorker(MemberInfoCapture, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price", ReasonText)) then
            exit(0);

        MemberInfoCapture."Valid Until" := MembershipStartDate;
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    procedure AutoRenewMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture"; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(AutoRenewMembershipWorker(MemberInfoCapture, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure AutoRenewMembershipWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EntryNo: Integer;
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption, MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(false);

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(false);

        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, Membership."Membership Code", MemberInfoCapture."Item No.");
        ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
            exit(false);

        Item.Get(MemberInfoCapture."Item No.");

        if (MembershipEntry."Valid Until Date" < Today) then
            MembershipEntry."Valid Until Date" := CalcDate('<-1D>', Today);

        case MembershipAlterationSetup."Alteration Activate From" of
            MembershipAlterationSetup."Alteration Activate From"::ASAP:
                StartDateNew := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
            MembershipAlterationSetup."Alteration Activate From"::DF:
                StartDateNew := CalcDate(MembershipAlterationSetup."Alteration Date Formula", MembershipEntry."Valid Until Date");

            else begin
                    ReasonText := StrSubstNo(INVALID_ACTIVATION_DATE, Format(MembershipAlterationSetup."Alteration Activate From"),
                      MembershipAlterationSetup.FieldCaption("Alteration Activate From"), Format(MembershipAlterationSetup."Alteration Type"));
                    exit(ExitFalseOrWithError(false, ReasonText));
                end;

        end;

        if (StartDateNew < Today) then
            StartDateNew := Today;

        EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        if (StartDateNew <= MembershipEntry."Valid Until Date") then
            exit(ExitFalseOrWithError(false, StrSubstNo(CONFLICTING_ENTRY, StartDateNew, EndDateNew)));

        if (not MembershipAlterationSetup."Stacking Allowed") then
            if (GetLedgerEntryForDate(Membership."Entry No.", Today, EntryNo)) then
                if (EntryNo <> MembershipEntry."Entry No.") then
                    exit(ExitFalseOrWithError(false, StrSubstNo(STACKING_NOT_ALLOWED, Membership."Entry No.", Today)));

        SuggestedUnitPrice := Item."Unit Price";
        SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration(Membership."Entry No.", MembershipAlterationSetup);

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(false);

        if (WithUpdate) then begin
            MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";
            MemberInfoCapture."Membership Code" := Membership."Membership Code";

            if (not MembershipAutoRenew.CreateInvoice(MemberInfoCapture, StartDateNew, EndDateNew)) then
                exit(false);

            if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
                exit(false);

            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew);

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        ReasonText := 'Ok';
        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    local procedure ExtendMemberCard(MembershipEntryNo: Integer; CardEntryNo: Integer; ExpiredCardOption: Integer; NewTimeFrameEndDate: Date; var MemberCardEntryNoOut: Integer; ResponseMessage: Text): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        NewUntilDate: Date;
    begin

        MemberCard.Get(CardEntryNo);
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        case MembershipSetup."Card Expire Date Calculation" of
            MembershipSetup."Card Expire Date Calculation"::NA:
                NewUntilDate := 0D;
            MembershipSetup."Card Expire Date Calculation"::DATEFORMULA:
                begin
                    if (MemberCard."Valid Until" <= Today) then
                        MemberCard."Valid Until" := CalcDate('<-1D>', Today); // An expired card appears to have been valid until yesterday

                    NewUntilDate := CalcDate(MembershipSetup."Card Number Valid Until",
                      CalcDate('<+1D>', MemberCard."Valid Until")); // Card should be valid from day after current end date, or they will overlap
                end;
            MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED:
                NewUntilDate := NewTimeFrameEndDate;
        end;

        case ExpiredCardOption of
            AlterationSetup."Card Expired Action"::IGNORE:
                exit(true);
            AlterationSetup."Card Expired Action"::PREVENT:
                begin
                    ResponseMessage := StrSubstNo(PREVENT_CARD_EXTEND, MemberCard."External Card No.", NewUntilDate);
                    exit(NewUntilDate <= MemberCard."Valid Until");
                end;
            AlterationSetup."Card Expired Action"::NEW:
                begin
                    MemberInfoCapture."Valid Until" := NewUntilDate;
                    exit(IssueMemberCardWorker(MembershipEntryNo, MemberCard."Member Entry No.", MemberInfoCapture, false, MemberCardEntryNoOut, ResponseMessage, true));

                end;

            AlterationSetup."Card Expired Action"::UPDATE:
                begin

                    MemberCardEntryNoOut := CardEntryNo;

                    MemberCard."Valid Until" := NewUntilDate;
                    exit(MemberCard.Modify());
                end;
        end;
    end;

    local procedure CheckExtendMemberCards(WithUpdate: Boolean; MembershipEntryNo: Integer; ExpiredCardOption: Integer; NewTimeFrameEndDate: Date; ExternalCardNo: Text[100]; var MemberCardEntryNoOut: Integer; var ResponseMessage: Text): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        NewUntilDate: Date;
        UpdateRequired: Boolean;
        NewCardEntryNo: Integer;
        LastEntryNo: Integer;
        PreviousMemberEntryNo: Integer;
    begin

        ResponseMessage := '';

        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);

        if (not MemberCard.FindLast()) then
            exit(true);

        LastEntryNo := MemberCard."Entry No.";
        MemberCard.SetFilter("Entry No.", '..%1', LastEntryNo);

        MemberCard.SetCurrentKey("Membership Entry No.", "Member Entry No.");

        if (not MemberCard.FindSet()) then
            exit(true);

        repeat

            if (ExternalCardNo = '') then
                ExternalCardNo := MemberCard."External Card No.";

            UpdateRequired := (NewTimeFrameEndDate > MemberCard."Valid Until");
            case ExpiredCardOption of
                AlterationSetup."Card Expired Action"::IGNORE:
                    UpdateRequired := false;
                AlterationSetup."Card Expired Action"::PREVENT:
                    if (UpdateRequired) then
                        ResponseMessage := StrSubstNo(PREVENT_CARD_EXTEND, MemberCard."External Card No.", NewTimeFrameEndDate);
                AlterationSetup."Card Expired Action"::UPDATE:
                    ;
                AlterationSetup."Card Expired Action"::NEW:
                    UpdateRequired := (PreviousMemberEntryNo <> MemberCard."Member Entry No.");
            end;

            if ((WithUpdate) and (UpdateRequired)) then begin
                if (not ExtendMemberCard(MembershipEntryNo, MemberCard."Entry No.", ExpiredCardOption, NewTimeFrameEndDate, NewCardEntryNo, ResponseMessage)) then
                    exit(false);

                if (ExpiredCardOption = AlterationSetup."Card Expired Action"::NEW) then
                    if (MemberCardEntryNoOut = 0) then
                        MemberCardEntryNoOut := NewCardEntryNo;

            end;

            PreviousMemberEntryNo := MemberCard."Member Entry No.";

        until (MemberCard.Next() = 0);

        exit(true);

    end;

    local procedure PrefillMemberInfoCapture(var MemberInfoCapture: Record "NPR MM Member Info Capture"; Member: Record "NPR MM Member"; Membership: Record "NPR MM Membership"; ExternalMemberCardNo: Text[100]; MembershipSalesItemNo: Code[20])
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

    procedure AddMembershipLedgerEntry_NEW(MembershipEntryNo: Integer; DocumentDate: Date; MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture") LedgerEntryNo: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCard: Record "NPR MM Member Card";
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";

        if (DocumentDate = 0D) then
            DocumentDate := WorkDate;

        CalculateLedgerEntryDates_NEW(
          MembershipSalesSetup,
          ((MembershipSetup.Perpetual) or (MembershipSalesSetup."Valid Until Calculation" = MembershipSalesSetup."Valid Until Calculation"::END_OF_TIME)),
          DocumentDate,
          MemberInfoCapture."Document Date",
          ValidFromDate,
          ValidUntilDate);

        MemberInfoCapture."Duration Formula" := MembershipSalesSetup."Duration Formula";

        MemberInfoCapture."Membership Code" := MembershipSalesSetup."Membership Code";

        if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then begin
            if (IsMembershipActive(MembershipEntryNo, Today, false)) then
                exit(0); //Hmm
        end;

        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED) then begin
            MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            if (ValidUntilDate <> 0D) then
                MemberCard.ModifyAll("Valid Until", ValidUntilDate);
        end;

        LedgerEntryNo := AddMembershipLedgerEntry(MembershipEntryNo, MemberInfoCapture, ValidFromDate, ValidUntilDate);
        OnMembershipChangeEvent(MembershipEntryNo);

        exit(LedgerEntryNo);

    end;

    local procedure CalculateLedgerEntryDates_NEW(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; Perpetual: Boolean; SalesDate: Date; PromptDate: Date; var ValidFromDate: Date; var ValiduntilDate: Date)
    begin

        if (Perpetual) then begin
            ValidFromDate := SalesDate;
            ValiduntilDate := DMY2Date(31, 12, 9999);
            exit;
        end;

        case MembershipSalesSetup."Valid From Base" of

            MembershipSalesSetup."Valid From Base"::PROMPT:
                ValidFromDate := PromptDate;

            MembershipSalesSetup."Valid From Base"::SALESDATE:
                ValidFromDate := SalesDate;

            MembershipSalesSetup."Valid From Base"::DATEFORMULA:
                begin
                    ValidFromDate := SalesDate;
                    if (SalesDate = WorkDate) then begin
                        MembershipSalesSetup.TestField("Valid From Date Calculation");
                        ValidFromDate := CalcDate(MembershipSalesSetup."Valid From Date Calculation", SalesDate);
                    end;
                end;

            MembershipSalesSetup."Valid From Base"::FIRST_USE:
                begin
                    ValidFromDate := 0D;
                    ValiduntilDate := 0D;
                    exit;
                end;
        end;

        MembershipSalesSetup.TestField("Duration Formula");
        ValiduntilDate := CalcDate(MembershipSalesSetup."Duration Formula", ValidFromDate);

    end;

    procedure GetMembershipAgeConstraintDate(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture") ConstraintDate: Date
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        DocumentDate: Date;
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        DocumentDate := MemberInfoCapture."Document Date";
        if (DocumentDate = 0D) then
            DocumentDate := WorkDate;

        CalculateLedgerEntryDates_NEW(
          MembershipSalesSetup,
          ((MembershipSalesSetup."Valid Until Calculation" = MembershipSalesSetup."Valid Until Calculation"::END_OF_TIME) or MembershipSetup.Perpetual),
          DocumentDate,
          MemberInfoCapture."Document Date",
          ValidFromDate,
          ValidUntilDate);

        with MembershipSetup do
            case "Validate Age Against" of
                "Validate Age Against"::SALESDATE_Y,
              "Validate Age Against"::SALESDATE_YM,
              "Validate Age Against"::SALESDATE_YMD:
                    ConstraintDate := DocumentDate;
                "Validate Age Against"::PERIODBEGIN_Y,
              "Validate Age Against"::PERIODBEGIN_YM,
              "Validate Age Against"::PERIODBEGIN_YMD:
                    ConstraintDate := ValidFromDate;
                "Validate Age Against"::PERIODEND_Y,
              "Validate Age Against"::PERIODEND_YM,
              "Validate Age Against"::PERIODEND_YMD:
                    ConstraintDate := ValidUntilDate;
            end;

        exit(ConstraintDate);

    end;

    procedure SynchronizeCustomerAndContact(MembershipEntryNo: Integer)
    var
        Community: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        AdminMemberEntryNo: Integer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        Customer: Record Customer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        Community.Get(Membership."Community Code");

        if (not Community."Membership to Cust. Rel.") then
            exit;

        if (MembershipSetup."Customer Config. Template Code" = '') then
            exit;

        if (Membership."Customer No." = '') then begin
            Membership."Customer No." :=
              CreateCustomerFromTemplate(Community."Customer No. Series", MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");

            Membership.Modify();
        end;

        ConfigTemplateHeader.Get(MembershipSetup."Customer Config. Template Code");
        if (Customer.Get(Membership."Customer No.")) then begin
            RecRef.GetTable(Customer);
            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
            RecRef.SetTable(Customer);
            Customer.Modify(true);
        end;

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        if (MembershipRole.FindFirst()) then begin
            AdminMemberEntryNo := MembershipRole."Member Entry No.";

        end else begin
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
            if (not MembershipRole.FindFirst()) then
                exit;
            AdminMemberEntryNo := MembershipRole."Member Entry No.";
        end;

        UpdateCustomerFromMember(MembershipEntryNo, AdminMemberEntryNo);

        MembershipRole.Reset();
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Entry No.", '<>%1', AdminMemberEntryNo);
        MembershipRole.SetFilter("Member Role", '<>%1&<>%2', MembershipRole."Member Role"::ANONYMOUS, MembershipRole."Member Role"::GUARDIAN);

        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindSet()) then begin
            repeat
                AddCustomerContact(MembershipEntryNo, MembershipRole."Member Entry No.");
            until (MembershipRole.Next() = 0);
        end;
    end;

    procedure GetMembershipChangeOptions(var MembershipEntryNo: Integer; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary): Boolean
    var
        TmpMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
        Item: Record Item;
        EntryNo: Integer;
        IsValidOption: Boolean;
        StartDate: Date;
        EndDate: Date;
        UnitPrice: Decimal;
    begin

        MembershipAlterationSetup.SetCurrentKey("Presentation Order");

        if (MembershipAlterationSetup.FindSet()) then begin
            repeat
                EntryNo += 1;
                TmpMemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                TmpMemberInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
                if (Item.Get(TmpMemberInfoCapture."Item No.")) then;

                IsValidOption := false;
                case MembershipAlterationSetup."Alteration Type" of
                    MembershipAlterationSetup."Alteration Type"::RENEW:
                        IsValidOption := RenewMembership(TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                    MembershipAlterationSetup."Alteration Type"::EXTEND:
                        IsValidOption := ExtendMembership(TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                    MembershipAlterationSetup."Alteration Type"::UPGRADE:
                        IsValidOption := UpgradeMembership(TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                    MembershipAlterationSetup."Alteration Type"::REGRET:
                        IsValidOption := RegretMembership(TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                    MembershipAlterationSetup."Alteration Type"::CANCEL:
                        IsValidOption := CancelMembership(TmpMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                end;

                if (IsValidOption) then begin
                    TmpMembershipEntry.Init();

                    TmpMembershipEntry."Entry No." := EntryNo;
                    TmpMembershipEntry."Valid From Date" := StartDate;
                    TmpMembershipEntry."Valid Until Date" := EndDate;
                    TmpMembershipEntry."Item No." := MembershipAlterationSetup."Sales Item No.";
                    TmpMembershipEntry.Description := MembershipAlterationSetup.Description;
                    TmpMembershipEntry."Amount Incl VAT" := UnitPrice;
                    TmpMembershipEntry."Unit Price" := Item."Unit Price";

                    TmpMembershipEntry."Line No." := MembershipAlterationSetup."Presentation Order";

                    TmpMembershipEntry."Membership Code" := MembershipAlterationSetup."From Membership Code";
                    if (MembershipAlterationSetup."To Membership Code" <> '') then
                        TmpMembershipEntry."Membership Code" := MembershipAlterationSetup."To Membership Code";

                    case MembershipAlterationSetup."Alteration Type" of
                        MembershipAlterationSetup."Alteration Type"::RENEW:
                            TmpMembershipEntry.Context := TmpMembershipEntry.Context::RENEW;
                        MembershipAlterationSetup."Alteration Type"::EXTEND:
                            TmpMembershipEntry.Context := TmpMembershipEntry.Context::EXTEND;
                        MembershipAlterationSetup."Alteration Type"::UPGRADE:
                            TmpMembershipEntry.Context := TmpMembershipEntry.Context::UPGRADE;
                        MembershipAlterationSetup."Alteration Type"::REGRET:
                            TmpMembershipEntry.Context := TmpMembershipEntry.Context::REGRET;
                        MembershipAlterationSetup."Alteration Type"::CANCEL:
                            TmpMembershipEntry.Context := TmpMembershipEntry.Context::CANCEL;
                    end;

                    TmpMembershipEntry.Insert();
                end;
            until (MembershipAlterationSetup.Next() = 0);
        end;

        exit(not TmpMembershipEntry.IsEmpty());
    end;

    procedure GetMemberCount(MembershipEntryno: Integer; var AdminMemberCount: Integer; var MemberMemberCount: Integer; var AnonymousMemberCount: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        AdminMemberCount := 0;
        MemberMemberCount := 0;
        AnonymousMemberCount := 0;

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        AdminMemberCount := MembershipRole.Count();

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::MEMBER);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MemberMemberCount := MembershipRole.Count();

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::DEPENDENT);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MemberMemberCount += MembershipRole.Count();

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryno);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ANONYMOUS);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then
            AnonymousMemberCount := MembershipRole."Member Count";
    end;

    procedure ApplyGracePeriodPreset(Preset: Option; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup")
    begin

        with MembershipAlterationSetup do begin
            case Preset of
                "Grace Period Presets"::NA:
                    begin
                    end;
                "Grace Period Presets"::EXPIRED_MEMBERSHIP:
                    begin
                        "Grace Period Calculation" := "Grace Period Calculation"::ADVANCED;
                        "Grace Period Relates To" := "Grace Period Relates To"::END_DATE;
                        Evaluate("Grace Period Before", '<+1D>');
                        Evaluate("Grace Period After", '<+100Y>');
                        "Activate Grace Period" := true;
                    end;

                "Grace Period Presets"::ACTIVE_MEMBERSHIP:
                    begin
                        "Grace Period Calculation" := "Grace Period Calculation"::ADVANCED;
                        "Grace Period Relates To" := "Grace Period Relates To"::END_DATE;
                        Evaluate("Grace Period Before", '<-100Y>');
                        Evaluate("Grace Period After", '<0D>');
                        "Activate Grace Period" := true;
                    end;
            end;
        end;
    end;

    procedure CreateMemberCommunicationDefaultSetup(MemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
        MemberCommunication: Record "NPR MM Member Communication";
        MemberCommunicationSetup: Record "NPR MM Member Comm. Setup";
        Member: Record "NPR MM Member";
    begin

        if (not (Member.Get(MemberEntryNo))) then
            exit;

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (not MembershipRole.FindSet()) then
            exit;

        repeat

            MemberCommunication.Init();
            MemberCommunication."Member Entry No." := MembershipRole."Member Entry No.";
            MemberCommunication."Membership Entry No." := MembershipRole."Membership Entry No.";

            MembershipRole.CalcFields("Membership Code");
            MemberCommunicationSetup.SetFilter("Membership Code", '=%1', MembershipRole."Membership Code");
            if (MemberCommunicationSetup.FindSet()) then begin
                repeat
                    MemberCommunication."Message Type" := MemberCommunicationSetup."Message Type";
                    MemberCommunication."Preferred Method" := MemberCommunicationSetup."Preferred Method";

                    if (MemberCommunicationSetup."Preferred Method" = MemberCommunicationSetup."Preferred Method"::MEMBER) then begin
                        case Member."Notification Method" of
                            Member."Notification Method"::EMAIL:
                                MemberCommunication."Preferred Method" := MemberCommunicationSetup."Preferred Method"::EMAIL;
                            Member."Notification Method"::SMS:
                                MemberCommunication."Preferred Method" := MemberCommunicationSetup."Preferred Method"::SMS;
                            else begin
                                    MemberCommunication."Preferred Method" := MemberCommunication."Preferred Method"::MANUAL;
                                    MemberCommunication."Accepted Communication" := MemberCommunication."Accepted Communication"::"OPT-OUT";
                                end;
                        end;
                    end;
                    MemberCommunication."Changed At" := CurrentDateTime();

                    if (not MemberCommunication.Insert()) then;

                until (MemberCommunicationSetup.Next() = 0);
            end;

        until (MembershipRole.Next() = 0);

    end;

    procedure GetCommunicationMethod_Welcome(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[200]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::WELCOME, Method, Address, Engine));

    end;

    procedure GetCommunicationMethod_Renew(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[200]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::RENEW, Method, Address, Engine));

    end;

    procedure GetCommunicationMethod_MemberCard(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[200]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::MEMBERCARD, Method, Address, Engine));

    end;

    procedure GetCommunicationMethod_Ticket(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[200]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::TICKETS, Method, Address, Engine));

    end;

    local procedure GetCommunicationMethodWorker(MemberEntryNo: Integer; MembershipEntryNo: Integer; MessageType: Option; var Method: Code[10]; var Address: Text[200]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        MemberCommunicationSetup: Record "NPR MM Member Comm. Setup";
    begin

        Method := 'NA';
        Address := '';

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        case Member."Notification Method" of
            Member."Notification Method"::EMAIL:
                Method := 'EMAIL';
            Member."Notification Method"::SMS:
                Method := 'SMS';
            Member."Notification Method"::MANUAL:
                Method := 'MANUAL';
            Member."Notification Method"::NONE:
                exit(false); // Master kill switch
        end;

        if (MembershipEntryNo = 0) then begin
            MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (MembershipRole.FindFirst()) then
                MembershipEntryNo := MembershipRole."Membership Entry No.";
        end;

        if (MemberCommunication.Get(MemberEntryNo, MembershipEntryNo, MessageType)) then begin
            case MemberCommunication."Preferred Method" of
                MemberCommunication."Preferred Method"::EMAIL:
                    Method := 'EMAIL';
                MemberCommunication."Preferred Method"::WALLET_EMAIL:
                    Method := 'W-EMAIL';  // code 10
                MemberCommunication."Preferred Method"::SMS:
                    Method := 'SMS';
                MemberCommunication."Preferred Method"::WALLET_SMS:
                    Method := 'W-SMS';
                MemberCommunication."Preferred Method"::MANUAL:
                    Method := 'MANUAL';
            end;

            if (MemberCommunication."Accepted Communication" = MemberCommunication."Accepted Communication"::"OPT-OUT") then
                Method := 'NA';
        end;

        case Method of
            'EMAIL':
                Address := Member."E-Mail Address";
            'W_EMAIL':
                Address := Member."E-Mail Address";
            'SMS':
                Address := Member."Phone No.";
            'W-SMS':
                Address := Member."Phone No.";
            'MANUAL':
                Address := '';
            'NA':
                Address := '';
        end;

        MemberCommunicationSetup.Init();
        if (Membership.Get(MembershipEntryNo)) then
            if (not MemberCommunicationSetup.Get(Membership."Membership Code", MessageType)) then
                MemberCommunicationSetup.Init();
        Engine := MemberCommunicationSetup."Notification Engine";

        exit(Address <> '');

    end;

    local procedure TransferInfoCaptureAttributes(MemberInfoCaptureEntryNo: Integer; DestinationTableID: Integer; DestinationEntryNo: Integer)
    var
        NPRAttributeID: Record "NPR Attribute ID";
        NPRAttributeManagement: Codeunit "NPR Attribute Management";
        TextArray40: array[40] of Text[250];
        N: Integer;
    begin

        if (DestinationEntryNo = 0) then
            exit;

        NPRAttributeManagement.GetEntryAttributeValue(TextArray40, DATABASE::"NPR MM Member Info Capture", MemberInfoCaptureEntryNo);
        for N := 1 to (ArrayLen(TextArray40)) do
            if (TextArray40[N] <> '') then
                if (NPRAttributeManagement.GetAttributeShortcut(DATABASE::"NPR MM Member Info Capture", N, NPRAttributeID)) then
                    if (NPRAttributeID.Get(DestinationTableID, NPRAttributeID."Attribute Code")) then
                        NPRAttributeManagement.SetEntryAttributeValue(DestinationTableID, NPRAttributeID."Shortcut Attribute ID", DestinationEntryNo, TextArray40[N])

    end;

    local procedure DuplicateMcsPersonIdReference(MemberInfoCapture: Record "NPR MM Member Info Capture"; Member: Record "NPR MM Member"; DeleteSourceRecord: Boolean): Boolean
    var
        RecRefCapture: RecordRef;
        RecRefMember: RecordRef;
        MCSPersonBusinessEntities: Record "NPR MCS Person Bus. Entit.";
        MCSPersonBusinessEntities2: Record "NPR MCS Person Bus. Entit.";
    begin

        RecRefCapture := MemberInfoCapture.RecordId.GetRecord();
        RecRefMember := Member.RecordId.GetRecord();

        MCSPersonBusinessEntities.SetFilter("Table Id", '=%1', RecRefCapture.Number);
        MCSPersonBusinessEntities.SetFilter(Key, '=%1', RecRefCapture.RecordId);
        if (not MCSPersonBusinessEntities.FindFirst()) then
            exit(false);

        MCSPersonBusinessEntities2.PersonId := MCSPersonBusinessEntities.PersonId;
        MCSPersonBusinessEntities2."Table Id" := RecRefMember.Number;
        MCSPersonBusinessEntities2.Key := RecRefMember.RecordId;
        MCSPersonBusinessEntities2.Insert();
        if (DeleteSourceRecord) then
            MCSPersonBusinessEntities.Delete();

        exit(true);
    end;

    local procedure AddMembershipRenewalNotification(MembershipLedgerEntry: Record "NPR MM Membership Entry")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        MemberNotification.AddMembershipRenewalNotification(MembershipLedgerEntry);
    end;

    local procedure AddMemberCreateNotification(MembershipEntryNo: Integer; MembershipSetup: Record "NPR MM Membership Setup"; Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        if (MembershipSetup."Create Welcome Notification") then
            MemberNotification.AddMemberWelcomeNotification(MembershipEntryNo, Member."Entry No.");

        if (MemberInfoCapture."Member Card Type" in [MemberInfoCapture."Member Card Type"::CARD_PASSSERVER, MemberInfoCapture."Member Card Type"::PASSSERVER]) then
            MemberNotification.CreateWalletSendNotification(MembershipEntryNo, Member."Entry No.", 0, TODAY);
    end;

    local procedure ValidAlterationGracePeriod(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MembershipEntry: Record "NPR MM Membership Entry"; ReferenceDate: Date): Boolean
    var
        GracePeriodDate: Date;
        GraceDayCount: Integer;
        InGracePeriod: Boolean;
        LowerBoundDate: Date;
        UpperBoundDate: Date;
    begin

        if (not MembershipAlterationSetup."Activate Grace Period") then
            exit(true);

        if (MembershipEntry."Activate On First Use") then
            exit(false);

        case MembershipAlterationSetup."Grace Period Relates To" of
            MembershipAlterationSetup."Grace Period Relates To"::START_DATE:
                GracePeriodDate := MembershipEntry."Valid From Date";
            MembershipAlterationSetup."Grace Period Relates To"::END_DATE:
                GracePeriodDate := MembershipEntry."Valid Until Date";
        end;

        LowerBoundDate := 0D;
        UpperBoundDate := DMY2Date(31, 12, 9999);

        if (Format(MembershipAlterationSetup."Grace Period Before") <> '') then begin
            if (MembershipAlterationSetup."Grace Period Calculation" = MembershipAlterationSetup."Grace Period Calculation"::SIMPLE) then begin
                GraceDayCount := Abs((GracePeriodDate - CalcDate(MembershipAlterationSetup."Grace Period Before", GracePeriodDate)));
                LowerBoundDate := GracePeriodDate - GraceDayCount;
            end;

            if (MembershipAlterationSetup."Grace Period Calculation" = MembershipAlterationSetup."Grace Period Calculation"::ADVANCED) then begin
                LowerBoundDate := CalcDate(MembershipAlterationSetup."Grace Period Before", GracePeriodDate);
            end;
        end;

        if (Format(MembershipAlterationSetup."Grace Period After") <> '') then begin
            GraceDayCount := Abs((GracePeriodDate - CalcDate(MembershipAlterationSetup."Grace Period After", GracePeriodDate)));
            UpperBoundDate := GracePeriodDate + GraceDayCount;

            if (MembershipAlterationSetup."Grace Period Calculation" = MembershipAlterationSetup."Grace Period Calculation"::ADVANCED) then begin
                UpperBoundDate := CalcDate(MembershipAlterationSetup."Grace Period After", GracePeriodDate);
            end;
        end;

        InGracePeriod := ((LowerBoundDate <= ReferenceDate) and (ReferenceDate <= UpperBoundDate));
        exit(InGracePeriod);
    end;

    local procedure ValidateChangeMembershipCode(WithConfirm: Boolean; MembershipEntryNo: Integer; StartDate: Date; ToMembershipCode: Code[20]; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCount: Integer;
    begin

        Membership.Get(MembershipEntryNo);

        ReasonText := UPGRADE_TO_CODE_MISSING;
        if (ToMembershipCode = '') then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        MembershipSetup.Get(ToMembershipCode);
        if (ToMembershipCode <> Membership."Membership Code") then begin

            MemberCount := GetMembershipMemberCount(MembershipEntryNo);
            ReasonText := StrSubstNo(TO_MANY_MEMBERS, Membership."External Membership No.", MembershipSetup.Code, MembershipSetup."Membership Member Cardinality");
            if (MembershipSetup."Membership Member Cardinality" > 0) then
                if (MemberCount > MembershipSetup."Membership Member Cardinality") then
                    exit(ExitFalseOrWithError(WithConfirm, ReasonText));
        end;

        ReasonText := '';
        exit(true);
    end;

    local procedure CheckAgeConstraintOnMembershipAlter(Membership: Record "NPR MM Membership"; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; SalesDate: Date; PeriodStartDate: Date; PeriodEndDate: Date; var ReasonText: Text): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        ReferenceDate: Date;
    begin

        ReasonText := '';

        MembershipSetup.Get(Membership."Membership Code");
        if (MembershipAlterationSetup."To Membership Code" <> '') then
            MembershipSetup.Get(MembershipAlterationSetup."To Membership Code");

        if (not MembershipSetup."Enable Age Verification") then
            exit(true);

        with MembershipSetup do
            case "Validate Age Against" of
                "Validate Age Against"::SALESDATE_Y,
              "Validate Age Against"::SALESDATE_YM,
              "Validate Age Against"::SALESDATE_YMD:
                    ReferenceDate := SalesDate;

                "Validate Age Against"::PERIODBEGIN_Y,
              "Validate Age Against"::PERIODBEGIN_YM,
              "Validate Age Against"::PERIODBEGIN_YMD:
                    ReferenceDate := PeriodStartDate;

                "Validate Age Against"::PERIODEND_Y,
              "Validate Age Against"::PERIODEND_YM,
              "Validate Age Against"::PERIODEND_YMD:
                    ReferenceDate := PeriodEndDate;
            end;

        with MembershipAlterationSetup do
            exit(CheckMemberAgeConstraint(Membership."Entry No.", ReferenceDate, MembershipSetup."Validate Age Against", "Age Constraint Type", "Age Constraint (Years)", "Age Constraint Applies To", ReasonText));

    end;

    local procedure CheckMemberAgeConstraint(MembershipEntryNo: Integer; ReferenceDate: Date; ReferenceDateType: Option; ConstraintType: Option NA,"Less Than","Less Than or Equal To","Greater Then","Greater Than or Equal To","Equal To"; Constraint: Integer; AppliesTo: Option; var ReasonText: Text): Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        Member: Record "NPR MM Member";
        AgeConstraintOk: Boolean;
        MemberEntryNo: Integer;
        MemberBirthDate: Date;
        AgeDuration: Duration;
    begin

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);

        if (AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::DEPENDANTS) then
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::DEPENDENT);

        if (AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::ADMINS) then
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);

        if (MembershipRole.IsEmpty()) then
            exit(false);

        if (AppliesTo in [MembershipSalesSetup."Age Constraint Applies To"::OLDEST, MembershipSalesSetup."Age Constraint Applies To"::YOUNGEST]) then begin
            MembershipRole.FindSet();
            MemberBirthDate := 0D;
            MemberEntryNo := -1;
            if (AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::OLDEST) then
                MemberBirthDate := Today;
            repeat
                if (Member.Get(MembershipRole."Member Entry No.")) then begin
                    if (not Member.Blocked) then begin
                        if ((AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::OLDEST) and (Member.Birthday < MemberBirthDate)) then begin
                            MemberBirthDate := Member.Birthday;
                            MemberEntryNo := Member."Entry No.";
                        end;
                        if ((AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::YOUNGEST) and (Member.Birthday > MemberBirthDate)) then begin
                            MemberBirthDate := Member.Birthday;
                            MemberEntryNo := Member."Entry No.";
                        end;

                    end;
                end;
            until (MembershipRole.Next() = 0);

            MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        end;

        MembershipRole.FindSet();
        repeat
            Member.Get(MembershipRole."Member Entry No.");
            if (not Member.Blocked) then
                AgeConstraintOk := CheckAgeConstraint(ReferenceDate, Member.Birthday, ReferenceDateType, ConstraintType, Constraint);

        until ((MembershipRole.Next() = 0) or (not AgeConstraintOk));

        if (not AgeConstraintOk) then begin

            if (Member.Birthday = 0D) then
                ReasonText := StrSubstNo(AGE_VERIFICATION, Member."Display Name", Constraint);

            if (Member.Birthday <> 0D) then
                ReasonText := StrSubstNo(AGE_VERIFICATION, Member."Display Name", Constraint) +
                              StrSubstNo(' {%5 must be %4 %3 => (%1 + %2)}', Member.Birthday, Constraint, CalcDate(StrSubstNo('<+%1Y>', Constraint), Member.Birthday), Format(ConstraintType), ReferenceDate);
        end;

        exit(AgeConstraintOk);

    end;

    procedure CheckAgeConstraint(ReferenceDate1: Date; ReferenceDate2: Date; ReferenceDateType: Option; ConstraintType: Option NA,LT,LTE,GT,GTE,E; Years: Integer) ConstraintOK: Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipSetup: Record "NPR MM Membership Setup";
        LowRange: Date;
        HighRange: Date;
        LowDate: Date;
        HighDate: Date;
        DateToValidate: Date;
    begin

        if (ConstraintType = ConstraintType::NA) then
            exit(true);

        if (ReferenceDate1 = 0D) then
            exit(false);

        if (ReferenceDate2 = 0D) then
            exit(false);

        LowDate := ReferenceDate1;
        HighDate := ReferenceDate2;
        if (ReferenceDate2 < ReferenceDate1) then begin
            LowDate := ReferenceDate2;
            HighDate := ReferenceDate1;
        end;

        LowRange := CalcDate('<CY-1Y+1D>', HighDate);
        HighRange := CalcDate('<CY>', HighDate);
        DateToValidate := CalcDate(StrSubstNo('<+%1Y>', Years), LowDate); // Birth date + constraint in years

        // Always check year
        case ConstraintType of
            ConstraintType::E:
                ConstraintOK := (Date2DMY(DateToValidate, 3) = Date2DMY(HighDate, 3));
            ConstraintType::LT:
                ConstraintOK := (Date2DMY(DateToValidate, 3) > Date2DMY(HighDate, 3));
            ConstraintType::LTE:
                ConstraintOK := (Date2DMY(DateToValidate, 3) >= Date2DMY(HighDate, 3));
            ConstraintType::GT:
                ConstraintOK := (Date2DMY(DateToValidate, 3) < Date2DMY(HighDate, 3));
            ConstraintType::GTE:
                ConstraintOK := (Date2DMY(DateToValidate, 3) <= Date2DMY(HighDate, 3));
        end;

        with MembershipSetup do
            if (ReferenceDateType in ["Validate Age Against"::SALESDATE_YM, "Validate Age Against"::PERIODBEGIN_YM, "Validate Age Against"::PERIODEND_YM]) then
                case ConstraintType of
                    ConstraintType::E:
                        ConstraintOK := ConstraintOK and (Date2DMY(DateToValidate, 2) = Date2DMY(HighDate, 2));
                    ConstraintType::LT:
                        ConstraintOK := (DateToValidate > CalcDate('<CM>', HighDate));
                    ConstraintType::LTE:
                        ConstraintOK := (DateToValidate >= CalcDate('<CM-1M>', HighDate));
                    ConstraintType::GT:
                        ConstraintOK := (DateToValidate < CalcDate('<CM-1M>', HighDate));
                    ConstraintType::GTE:
                        ConstraintOK := (DateToValidate <= CalcDate('<CM>', HighDate));
                end;

        with MembershipSetup do
            if (ReferenceDateType in ["Validate Age Against"::SALESDATE_YMD, "Validate Age Against"::PERIODBEGIN_YMD, "Validate Age Against"::PERIODEND_YMD]) then
                case ConstraintType of
                    ConstraintType::E:
                        ConstraintOK := (DateToValidate = HighDate);
                    ConstraintType::LT:
                        ConstraintOK := (DateToValidate > HighDate);
                    ConstraintType::LTE:
                        ConstraintOK := (DateToValidate >= HighDate);
                    ConstraintType::GT:
                        ConstraintOK := (DateToValidate < HighDate);
                    ConstraintType::GTE:
                        ConstraintOK := (DateToValidate <= HighDate);
                end;

        exit(ConstraintOK);

    end;

    local procedure GetMembershipMemberCount(MembershipEntryNo: Integer) MemberCount: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        GetMemberCount(MembershipEntryNo, AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        if (MembershipSetup."Anonymous Member Cardinality" = MembershipSetup."Anonymous Member Cardinality"::UNLIMITED) then
            exit(AdminMemberCount + MemberMemberCount);

        exit(AdminMemberCount + MemberMemberCount + AnonymousMemberCount);
    end;

    local procedure GetMembershipMemberCountForAlteration(MembershipEntryNo: Integer; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup") MemberCount: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        AdminMemberCount: Integer;
        MemberMemberCount: Integer;
        AnonymousMemberCount: Integer;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        GetMemberCount(MembershipEntryNo, AdminMemberCount, MemberMemberCount, AnonymousMemberCount);

        with MembershipAlterationSetup do begin
            case "Member Count Calculation" of
                "Member Count Calculation"::NA:
                    MemberCount := 0;
                "Member Count Calculation"::NAMED:
                    MemberCount := AdminMemberCount + MemberMemberCount;
                "Member Count Calculation"::ANONYMOUS:
                    MemberCount := AnonymousMemberCount;
                "Member Count Calculation"::ALL:
                    MemberCount := AdminMemberCount + MemberMemberCount + AnonymousMemberCount;
                else
                    Error('Undefined Member Count Calculation %1', MembershipAlterationSetup."Member Count Calculation");
            end;
        end;

        exit(MemberCount);
    end;

    local procedure ConflictingLedgerEntries(MembershipEntryNo: Integer; StartDate: Date; EndDate: Date; var StartEntryNo: Integer; var EndEntryNo: Integer) HaveConflict: Boolean
    begin

        if (not GetLedgerEntryForDate(MembershipEntryNo, StartDate, StartEntryNo)) then
            exit(false);

        if (not GetLedgerEntryForDate(MembershipEntryNo, EndDate, EndEntryNo)) then
            exit(false);

        exit(StartEntryNo <> EndEntryNo);
    end;

    local procedure GetLedgerEntryForDate(MembershipEntryNo: Integer; DateToCheck: Date; var EntryNo: Integer): Boolean
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        EntryNo := 0;

        MembershipEntry.SetCurrentKey("Membership Entry No.");
        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipEntry.SetFilter("Valid From Date", '<=%1', DateToCheck);
        MembershipEntry.SetFilter("Valid Until Date", '>=%1', DateToCheck);
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        if (not MembershipEntry.FindLast()) then
            exit(false);

        EntryNo := MembershipEntry."Entry No.";
        exit(true);
    end;

    local procedure CalculatePeriodStartToDateFraction(Period_Start: Date; Period_End: Date; Period_Date: Date) Fraction: Decimal
    begin

        // Calculates the fraction from start to date in the timeframe start..end
        // Returs zero when date is not in start..end range
        // StartDate is considered a "from date"
        // Date and EndDate are considered "until dates" - when all dates are equal, return 1

        if ((Period_Date < Period_Start) or (Period_Date > Period_End)) then
            exit(0);

        if (Period_Start = Period_End) then
            exit(1);

        exit((Period_Date - Period_Start) / (Period_End - Period_Start));
    end;

    local procedure AddMembershipLedgerEntry(MembershipEntryNo: Integer; MemberInfoCapture: Record "NPR MM Member Info Capture"; ValidFromDate: Date; ValidUntilDate: Date) MemberShipLedgerEntryNo: Integer
    var
        MembershipLedgerEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        MembershipRole: Record "NPR MM Membership Role";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        MemberNotification: Codeunit "NPR MM Member Notification";
        Item: Record Item;
    begin

        MembershipLedgerEntry."Membership Entry No." := MembershipEntryNo;
        MembershipLedgerEntry."Created At" := CurrentDateTime();

        case MemberInfoCapture."Information Context" of
            MemberInfoCapture."Information Context"::NEW:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::NEW;
            MemberInfoCapture."Information Context"::REGRET:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::REGRET;
            MemberInfoCapture."Information Context"::RENEW:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::RENEW;
            MemberInfoCapture."Information Context"::UPGRADE:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::UPGRADE;
            MemberInfoCapture."Information Context"::EXTEND:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::EXTEND;
            MemberInfoCapture."Information Context"::CANCEL:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::CANCEL;
            MemberInfoCapture."Information Context"::AUTORENEW:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::AUTORENEW;
            MemberInfoCapture."Information Context"::FOREIGN:
                MembershipLedgerEntry.Context := MembershipLedgerEntry.Context::FOREIGN;
            else
                exit(0);
        end;

        MembershipLedgerEntry."Duration Dateformula" := MemberInfoCapture."Duration Formula";
        MembershipLedgerEntry."Valid From Date" := ValidFromDate;
        MembershipLedgerEntry."Valid Until Date" := ValidUntilDate;
        MembershipLedgerEntry."Original Context" := MembershipLedgerEntry.Context;

        if (ValidFromDate = 0D) and (MembershipLedgerEntry.Context = MembershipLedgerEntry.Context::NEW) then begin
            MembershipLedgerEntry."Valid From Date" := 0D;
            MembershipLedgerEntry."Valid Until Date" := 0D;
            MembershipLedgerEntry."Activate On First Use" := true;
        end;

        MembershipLedgerEntry."Item No." := MemberInfoCapture."Item No.";
        MembershipLedgerEntry."Membership Code" := MemberInfoCapture."Membership Code";

        MembershipLedgerEntry."Unit Price" := MemberInfoCapture."Unit Price";
        MembershipLedgerEntry.Amount := MemberInfoCapture.Amount;
        MembershipLedgerEntry."Amount Incl VAT" := MemberInfoCapture."Amount Incl VAT";

        if (Item.Get(MembershipLedgerEntry."Item No.")) then
            MembershipLedgerEntry."Unit Price (Base)" := Item."Unit Price";

        MembershipLedgerEntry."Receipt No." := MemberInfoCapture."Receipt No.";
        MembershipLedgerEntry."Line No." := MemberInfoCapture."Line No.";
        MembershipLedgerEntry."Source Type" := MemberInfoCapture."Source Type";
        MembershipLedgerEntry."Document Type" := MemberInfoCapture."Document Type";
        MembershipLedgerEntry."Document No." := MemberInfoCapture."Document No.";
        MembershipLedgerEntry."Document Line No." := MemberInfoCapture."Document Line No.";
        MembershipLedgerEntry."Import Entry Document ID" := MemberInfoCapture."Import Entry Document ID";
        MembershipLedgerEntry.Description := MemberInfoCapture.Description;
        MembershipLedgerEntry."Member Card Entry No." := MemberInfoCapture."Card Entry No.";

        MembershipLedgerEntry."Auto-Renew Entry No." := MemberInfoCapture."Auto-Renew Entry No.";
        MembershipLedgerEntry.Insert();

        if (MembershipLedgerEntry.Context in [MembershipLedgerEntry.Context::UPGRADE, MembershipLedgerEntry.Context::RENEW]) then begin
            Membership.Get(MembershipEntryNo);
            if (Membership."Customer No." <> '') then begin
                MembershipSetup.Get(Membership."Membership Code");
                if (MembershipSetup."Customer Config. Template Code" <> '') then begin
                    ConfigTemplateHeader.Get(MembershipSetup."Customer Config. Template Code");
                    if (Customer.Get(Membership."Customer No.")) then begin
                        RecRef.GetTable(Customer);
                        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                        RecRef.SetTable(Customer);
                        Customer.Modify(true);
                    end;
                end;
            end;
        end;

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipLedgerEntry);

        if (not MembershipLedgerEntry."Activate On First Use") then
            AddMembershipRenewalNotification(MembershipLedgerEntry);

        if ((MembershipSetup."Enable NP Pass Integration") and
            (MemberInfoCapture."Information Context" <> MemberInfoCapture."Information Context"::FOREIGN)) then begin

            if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::NEW) then begin
                ; // The create notification is created when first member is added.

            end else begin
                MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                MembershipRole.SetFilter(Blocked, '=%1', false);
                MembershipRole.SetFilter("Wallet Pass Id", '<>%1', '');
                if (not MembershipRole.IsEmpty()) then begin

                    //MemberNotification.CreateUpdateWalletNotification (Membership."Entry No.", 0, 0);
                    if (MembershipLedgerEntry."Valid From Date" > TODAY) then
                        MemberNotification.CreateUpdateWalletNotification(Membership."Entry No.", 0, 0, MembershipLedgerEntry."Valid From Date");

                    if (MembershipLedgerEntry."Valid From Date" <> TODAY) then
                        MemberNotification.CreateUpdateWalletNotification(Membership."Entry No.", 0, 0, TODAY);

                end;

                MembershipRole.SetFilter("Wallet Pass Id", '=%1', '');
                if (not MembershipRole.IsEmpty()) then begin

                    //MemberNotification.CreateWalletSendNotification (Membership."Entry No.", 0, 0);
                    MemberNotification.CreateWalletSendNotification(Membership."Entry No.", 0, 0, TODAY);

                    if (MembershipLedgerEntry."Valid From Date" > TODAY) then
                        MemberNotification.CreateUpdateWalletNotification(Membership."Entry No.", 0, 0, MembershipLedgerEntry."Valid From Date");

                end;

            end;
        end;

        exit(MembershipLedgerEntry."Entry No.");
    end;

    procedure ActivateMembershipLedgerEntry(MembershipEntryNo: Integer; ActivationDate: Date)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        Membership.Get(MembershipEntryNo);

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipEntry.FindFirst()) then
            Error(NO_LEDGER_ENTRY, Membership."External Membership No.");

        if (not MembershipEntry."Activate On First Use") then
            exit; // Allready activated

        MembershipEntry."Valid From Date" := ActivationDate;
        MembershipEntry."Valid Until Date" := CalcDate(MembershipEntry."Duration Dateformula", ActivationDate);
        MembershipEntry."Activate On First Use" := false;
        MembershipEntry.Modify();

        MembershipSetup.Get(Membership."Membership Code");
        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED) then begin
            MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            MemberCard.ModifyAll("Valid Until", MembershipEntry."Valid Until Date");
        end;

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipEntry);

        AddMembershipRenewalNotification(MembershipEntry);
        Commit();
    end;

    procedure MembershipNeedsActivation(MembershipEntryNo: Integer): Boolean
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipEntry.FindFirst()) then
            exit(true); // :)

        exit(MembershipEntry."Activate On First Use");
    end;

    local procedure GetCommunityMembership(MembershipCode: Code[20]; CreateWhenMissing: Boolean) MembershipEntryNo: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
        Membership: Record "NPR MM Membership";
        MembershipCreated: Boolean;
    begin

        MembershipSetup.Get(MembershipCode);
        Community.Get(MembershipSetup."Community Code");

        Membership.SetFilter("Community Code", '=%1', MembershipSetup."Community Code");

        Membership.SetFilter("Membership Code", '=%1', MembershipCode);

        if (Membership.IsEmpty()) then begin
            if (not CreateWhenMissing) then
                exit(0);

            Membership.Init();
            Membership.Description := Community.Description;
            Membership."Community Code" := MembershipSetup."Community Code";
            Membership."Membership Code" := MembershipCode;
            Membership."Issued Date" := Today;

            Membership."External Membership No." := AssignExternalMembershipNo(MembershipSetup."Community Code");

            Membership.Insert(true);
            MembershipCreated := true;
        end;

        Membership.FindFirst();

        if (Community."Membership to Cust. Rel.") then begin
            if (Membership."Customer No." = '') then begin
                MembershipSetup.TestField("Customer Config. Template Code");
                Membership."Customer No." := CreateCustomerFromTemplate(Community."Customer No. Series", MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");
                Membership.Modify();
            end;
        end;

        if (MembershipCreated) then
            MembershipEvents.OnAfterMembershipCreateEvent(Membership);

        exit(Membership."Entry No.");
    end;

    local procedure GetNewMembership(MembershipCode: Code[20]; MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateWhenMissing: Boolean) MembershipEntryNo: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
        Membership: Record "NPR MM Membership";
        MembershipCreated: Boolean;
    begin

        MembershipSetup.Get(MembershipCode);
        Community.Get(MembershipSetup."Community Code");

        if (MemberInfoCapture."External Membership No." = '') then
            MemberInfoCapture."External Membership No." := AssignExternalMembershipNo(MembershipSetup."Community Code");

        Membership.SetFilter("External Membership No.", '=%1', MemberInfoCapture."External Membership No.");
        Membership.SetFilter("Membership Code", '=%1', MembershipCode);
        if (Membership.IsEmpty()) then begin
            if (not CreateWhenMissing) then
                exit(0);

            Membership.Init();
            Membership."External Membership No." := MemberInfoCapture."External Membership No.";
            Membership.Description := Community.Description;
            Membership."Community Code" := MembershipSetup."Community Code";
            Membership."Membership Code" := MembershipCode;
            Membership."Company Name" := MemberInfoCapture."Company Name";
            Membership."Issued Date" := Today;
            Membership."Document ID" := MemberInfoCapture."Import Entry Document ID";
            Membership."Modified At" := CurrentDateTime();
            if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then
                Membership."Replicated At" := CurrentDateTime();

            Membership.Insert(true);
            MembershipCreated := true;
        end;

        Membership.FindFirst();
        if (Community."Membership to Cust. Rel.") then begin
            if (Membership."Customer No." = '') then begin

                if (MemberInfoCapture."Customer No." <> '') then begin
                    if (not ValidateUseCustomerNo(MemberInfoCapture."Customer No.")) then
                        Error('The Customer Number %1 can not be assigned to membership.', MemberInfoCapture."Customer No.");
                    Membership."Customer No." := MemberInfoCapture."Customer No.";
                end;

                if (Membership."Customer No." = '') then
                    Membership."Customer No." :=
                      CreateCustomerFromTemplate(Community."Customer No. Series", MembershipSetup."Customer Config. Template Code", MembershipSetup."Contact Config. Template Code", Membership."External Membership No.");

                if (MemberInfoCapture."Enable Auto-Renew") then
                    Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;

                Membership."Auto-Renew Payment Method Code" := MemberInfoCapture."Auto-Renew Payment Method Code";

                if (Membership."Auto-Renew" = Membership."Auto-Renew"::YES_INTERNAL) then
                    Membership.TestField("Auto-Renew Payment Method Code");

                Membership."Modified At" := CurrentDateTime();
                Membership.Modify();
            end;
        end;

        TransferInfoCaptureAttributes(MemberInfoCapture."Entry No.", DATABASE::"NPR MM Membership", Membership."Entry No.");

        if (MembershipCreated) then
            MembershipEvents.OnAfterMembershipCreateEvent(Membership);

        exit(Membership."Entry No.");
    end;

    local procedure CreateCustomerFromTemplate(CustomerNoSeriesCode: Code[20]; CustTemplateCode: Code[10]; ContTemplateCode: Code[10]; ExternalCustomerNo: Code[20]) CustomerNo: Code[20]
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
            Error(MISSING_TEMPLATE, CustTemplateCode);

        if (not ConfigTemplateHeader.Get(CustTemplateCode)) then
            Error(MISSING_TEMPLATE, CustTemplateCode);

        Customer.Init();
        Customer."No." := '';

        if (CustomerNoSeriesCode <> '') then
            Customer."No." := NoSeriesManagement.GetNextNo(CustomerNoSeriesCode, 0D, true);

        Customer."NPR External Customer No." := ExternalCustomerNo;
        Customer.Insert(true);

        RecRef.GetTable(Customer);
        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(Customer);

        Customer.Modify(true);

        if (ContTemplateCode <> '') and ConfigTemplateHeader.Get(ContTemplateCode) then begin
            ContBusRelation.SetRange("Link to Table", ContBusRelation."Link to Table"::Customer);
            ContBusRelation.SetRange("No.", Customer."No.");
            if (ContBusRelation.FindFirst() and Contact.Get(ContBusRelation."Contact No.")) then begin
                RecRef.GetTable(Contact);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Contact);
                Contact.Modify(true);
            end;
        end;

        exit(Customer."No.");
    end;

    local procedure UpdateCustomerFromMember(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
        GuardianMembership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        GuardianMembershipRole: Record "NPR MM Membership Role";
        Customer: Record Customer;
        UpdateContFromCust: Codeunit "CustCont-Update";
        ContComp: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
        MagentoSetup: Record "NPR Magento Setup";
    begin

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);
        MembershipRole.Get(MembershipEntryNo, MemberEntryNo);

        if (not Customer.Get(Membership."Customer No.")) then
            exit;

        if (MembershipRole."Member Role" in [MembershipRole."Member Role"::ANONYMOUS,
                                             MembershipRole."Member Role"::MEMBER]) then
            exit;

        if (MembershipRole."Member Role" = MembershipRole."Member Role"::GUARDIAN) then begin

            GuardianMembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
            GuardianMembershipRole.SetFilter("Member Role", '=%1', GuardianMembershipRole."Member Role"::ADMIN);
            GuardianMembershipRole.SetFilter(Blocked, '=%1', false);
            if (GuardianMembershipRole.FindFirst()) then begin
                GuardianMembership.Get(GuardianMembershipRole."Membership Entry No.");
                if (GuardianMembership."Customer No." <> '') then begin
                    Customer.Validate("Bill-to Customer No.", GuardianMembership."Customer No.");
                    Customer.Modify();
                end;
            end;
            exit;
        end;

        if (Membership."Company Name" = '') then begin
            Customer.Validate(Name, CopyStr(Member."Display Name", 1, MaxStrLen(Customer.Name)));
        end else begin
            Customer.Validate(Name, Membership."Company Name");
            Customer.Validate("Name 2", CopyStr(Member."Display Name", 1, MaxStrLen(Customer."Name 2")));
        end;

        Customer.Validate(Address, CopyStr(Member.Address, 1, MaxStrLen(Customer.Address)));

        //** shifted order since BC clears city and postcode when country code is validated
        // the magento integration requires a country code, until "mandatory fields" have been implemented for member creation
        // this should remain.
        Customer.Validate("Country/Region Code", CopyStr(Member."Country Code", 1, MaxStrLen(Customer."Country/Region Code")));
        if (Customer."Country/Region Code" = '') then
            Customer.Validate("Country/Region Code", 'DK');

        Customer.Validate(City, CopyStr(Member.City, 1, MaxStrLen(Customer.City)));
        Customer.Validate("Post Code", CopyStr(Member."Post Code Code", 1, MaxStrLen(Customer."Post Code")));

        Customer.Validate("Phone No.", CopyStr(Member."Phone No.", 1, MaxStrLen(Customer."Phone No.")));
        Customer.Validate("E-Mail", CopyStr(Member."E-Mail Address", 1, MaxStrLen(Customer."E-Mail")));
        if (Membership.Blocked) then
            Customer.Validate(Blocked, Customer.Blocked::All);

        Customer.Modify();

        MarketingSetup.Get();
        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
            exit;

        UpdateContFromCust.OnModify(Customer);

        ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
        ContactBusinessRelation.SetFilter("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetFilter("No.", '=%1', Membership."Customer No.");

        if (ContactBusinessRelation.IsEmpty()) then
            UpdateContFromCust.InsertNewContact(Customer, false);

        if (ContactBusinessRelation.FindFirst()) then begin
            if (ContComp.Get(ContactBusinessRelation."Contact No.")) then begin

                if (not MagentoSetup.Get()) then
                    MagentoSetup.Init();

                case MagentoSetup."Magento Version" of
                    MagentoSetup."Magento Version"::"1":
                        ContComp."NPR Magento Contact" := (not Member.Blocked) and (Member."E-Mail Address" <> '');
                    MagentoSetup."Magento Version"::"2":
                        begin
                            ContComp."NPR Magento Contact" := true;
                            if ((not Member.Blocked) and (Member."E-Mail Address" <> '')) then begin
                                ContComp."NPR Magento Account Status" := ContComp."NPR Magento Account Status"::ACTIVE;
                            end else begin
                                ContComp."NPR Magento Account Status" := ContComp."NPR Magento Account Status"::BLOCKED;
                            end;
                        end;
                end;

                ContComp.Modify(true);

                if (Member."Contact No." = '') then begin
                    Member."Contact No." := ContComp."No.";
                    Member.Modify();
                end;

                if (MembershipRole."Contact No." = '') then begin
                    MembershipRole."Contact No." := ContComp."No.";
                    MembershipRole.Modify();
                end;

                UpdateContactFromMember(MembershipEntryNo, Member);
            end;
        end;
    end;

    procedure UpdateContactFromMember(MembershipEntryNo: Integer; Member: Record "NPR MM Member")
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Contact: Record Contact;
        ContactXRec: Record Contact;
        MagentoSetup: Record "NPR Magento Setup";
        HaveContact: Boolean;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipRole.Get(MembershipEntryNo, Member."Entry No.");

        HaveContact := false;
        if (MembershipRole."Contact No." <> '') then
            HaveContact := Contact.Get(MembershipRole."Contact No.");

        if (not HaveContact) then
            if (Member."Contact No." <> '') then
                HaveContact := Contact.Get(Member."Contact No.");

        if (not HaveContact) then
            exit;

        ContactXRec.Get(Contact."No.");

        Contact.Validate(Name, CopyStr(Member."Display Name", 1, MaxStrLen(Contact.Name)));
        Contact.Validate("First Name", CopyStr(Member."First Name", 1, MaxStrLen(Contact."First Name")));
        Contact.Validate("Middle Name", CopyStr(Member."Middle Name", 1, MaxStrLen(Contact."Middle Name")));
        Contact.Validate(Surname, CopyStr(Member."Last Name", 1, MaxStrLen(Contact.Surname)));

        Contact.Validate(Address, CopyStr(Member.Address, 1, MaxStrLen(Contact.Address)));

        if (Member."Country Code" <> '') then
            Contact.Validate("Country/Region Code", CopyStr(Member."Country Code", 1, MaxStrLen(Contact."Country/Region Code")));

        // the magento integration requires a country code, until "mandatory fields" have been implemented for member creation
        // this should remain.
        if (Contact."Country/Region Code" = '') then
            Contact.Validate("Country/Region Code", 'DK');

        Contact.Validate("Post Code", CopyStr(Member."Post Code Code", 1, MaxStrLen(Contact."Post Code")));
        Contact.Validate(City, CopyStr(Member.City, 1, MaxStrLen(Contact.City)));

        Contact.Validate("Phone No.", CopyStr(Member."Phone No.", 1, MaxStrLen(Contact."Phone No.")));
        Contact.Validate("E-Mail", CopyStr(Member."E-Mail Address", 1, MaxStrLen(Contact."E-Mail")));

        if (not MagentoSetup.Get()) then
            MagentoSetup.Init();

        case MagentoSetup."Magento Version" of
            MagentoSetup."Magento Version"::"1":
                Contact."NPR Magento Contact" := (not Member.Blocked) and (Member."E-Mail Address" <> '');
            MagentoSetup."Magento Version"::"2":
                begin
                    Contact."NPR Magento Contact" := true;
                    if ((not Member.Blocked) and (Member."E-Mail Address" <> '')) then begin
                        Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::ACTIVE;
                    end else begin
                        Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::BLOCKED;
                    end;
                end;
        end;

        Contact.Modify(True);

        // Code on Modify trigger requires XREC (modification from a page) to properly handle customer synchronization
        Contact.DoModify(ContactXRec);

    end;

    local procedure AddCustomerContact(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        ConfigTemplateHeader: Record "Config. Template Header";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        Contact: Record Contact;
        ContComp: Record Contact;
        ContactBusinessRelation: Record "Contact Business Relation";
        MarketingSetup: Record "Marketing Setup";
        HaveContact: Boolean;
        Customer: Record Customer;
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
    begin

        Membership.Get(MembershipEntryNo);
        Member.Get(MemberEntryNo);
        MembershipRole.Get(MembershipEntryNo, MemberEntryNo);

        if (not Customer.Get(Membership."Customer No.")) then
            exit;

        MarketingSetup.Get();
        if (MarketingSetup."Bus. Rel. Code for Customers" = '') then
            exit;

        MembershipSetup.Get(Membership."Membership Code");

        ContactBusinessRelation.SetCurrentKey("Link to Table", "No.");
        ContactBusinessRelation.SetFilter("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetFilter("No.", '=%1', Membership."Customer No.");
        if (ContactBusinessRelation.FindFirst()) then begin
            if (ContComp.Get(ContactBusinessRelation."Contact No.")) then begin

                HaveContact := (MembershipRole."Contact No." <> '');

                if (HaveContact) then
                    HaveContact := Contact.Get(Member."Contact No.");

                if (not HaveContact) then begin
                    Contact.Init();
                    Contact."No." := '';
                    Contact.Validate(Type, Contact.Type::Person);
                    Contact.Insert(true);

                    if (MembershipSetup."Contact Config. Template Code" <> '') and ConfigTemplateHeader.Get(MembershipSetup."Contact Config. Template Code") then begin
                        RecRef.GetTable(Contact);
                        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                        RecRef.SetTable(Contact);
                    end;

                    Contact."Company No." := ContComp."No.";
                    Contact.InheritCompanyToPersonData(ContComp);
                    Contact.Modify(true);

                    Member."Contact No." := Contact."No.";
                    Member.Modify();

                    MembershipRole."Contact No." := Contact."No.";
                    MembershipRole.Modify();
                end;

                UpdateContactFromMember(MembershipEntryNo, Member);

            end;
        end;
    end;

    local procedure AddCommunityMember(MembershipEntryNo: Integer; NumberOfMembers: Integer) MemberEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCount: Integer;
    begin

        // Community Member setup has unnamed members or
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ANONYMOUS);
        if (MembershipRole.FindFirst()) then begin
            MembershipRole."Member Count" += NumberOfMembers;
            if (MembershipRole."Member Count" < 0) then
                MembershipRole."Member Count" := 0;
            MembershipRole.Modify();
        end else begin
            MembershipRole."Membership Entry No." := MembershipEntryNo;
            MembershipRole."Member Role" := MembershipRole."Member Role"::ANONYMOUS;
            MembershipRole."Community Code" := Membership."Community Code";
            MembershipRole."Created At" := CurrentDateTime;

            MembershipRole."Member Count" := NumberOfMembers;
            if (MembershipRole."Member Count" < 0) then
                MembershipRole."Member Count" := 0;

            MembershipRole.Insert();
        end;

        if (MembershipSetup."Anonymous Member Cardinality" = MembershipSetup."Anonymous Member Cardinality"::LIMITED) then begin
            MemberCount := GetMembershipMemberCount(MembershipEntryNo);
            if (MemberCount > MembershipSetup."Membership Member Cardinality") then
                Error(TO_MANY_MEMBERS, Membership."External Membership No.", Membership."Membership Code", MembershipSetup."Membership Member Cardinality");
        end;

        exit(0);
    end;

    local procedure ActivateCustomerForWeb(MembershipEntryNo: Integer)
    begin

        // TODO: Defer customer / contact sync until activated.
    end;

    local procedure SetMemberFields(var Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CurrentMember: Record "NPR MM Member";
        CountryRegion: Record "Country/Region";
        CountryName: Text;
        PostCode: Record "Post Code";
    begin

        CurrentMember.Copy(Member);

        Member."First Name" := DeleteCtrlChars(MemberInfoCapture."First Name");
        Member."Middle Name" := DeleteCtrlChars(MemberInfoCapture."Middle Name");
        Member."Last Name" := DeleteCtrlChars(MemberInfoCapture."Last Name");
        Member.Address := DeleteCtrlChars(MemberInfoCapture.Address);

        Member."Post Code Code" := MemberInfoCapture."Post Code Code";
        Member.City := MemberInfoCapture.City;
        Member."Country Code" := MemberInfoCapture."Country Code";
        Member.Country := MemberInfoCapture.Country;

        if (Member."Post Code Code" <> '') then begin
            PostCode.SetFilter(Code, '=%1', UpperCase(Member."Post Code Code"));
            if (PostCode.FindFirst()) then begin
                Member.City := PostCode.City;
                Member."Country Code" := PostCode."Country/Region Code";
            end;
        end;

        if (Member."Country Code" <> '') then
            if (CountryRegion.Get(Member."Country Code")) then
                Member.Country := CountryRegion.Name;

        if (MemberInfoCapture.Country <> '') and (MemberInfoCapture."Country Code" = '') then begin
            CountryName := MemberInfoCapture.Country;
            if (StrLen(MemberInfoCapture.Country) > 1) then
                CountryName := StrSubstNo('%1%2', UpperCase(CopyStr(MemberInfoCapture.Country, 1, 1)), LowerCase(CopyStr(MemberInfoCapture.Country, 2)));

            CountryRegion.SetFilter(Name, '=%1|=%2|=%3', CountryName, UpperCase(CountryName), MemberInfoCapture.Country);
            if (CountryRegion.FindFirst()) then begin
                Member."Country Code" := CountryRegion.Code;
                Member.Country := CountryRegion.Name;
            end;
        end;

        Member."E-Mail Address" := LowerCase(MemberInfoCapture."E-Mail Address");
        Member."E-Mail Address" := DeleteCtrlChars(Member."E-Mail Address");

        Member."Phone No." := MemberInfoCapture."Phone No.";
        Member."Social Security No." := MemberInfoCapture."Social Security No.";
        Member.Gender := MemberInfoCapture.Gender;
        Member.Birthday := MemberInfoCapture.Birthday;
        Member."E-Mail News Letter" := MemberInfoCapture."News Letter";

        Member."Notification Method" := MemberInfoCapture."Notification Method";

        if (MemberInfoCapture."Notification Method" = MemberInfoCapture."Notification Method"::DEFAULT) then begin
            Member."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;
            if ((Member."Phone No." <> '') and (Member."E-Mail Address" = '')) then
                Member."Notification Method" := MemberInfoCapture."Notification Method"::SMS;
        end;

        MemberInfoCapture.CalcFields(Picture);
        if (MemberInfoCapture.Picture.HasValue()) then begin
            Member.Picture := MemberInfoCapture.Picture;
        end;

        Member."Display Name" := StrSubstNo('%1 %2', Member."First Name", Member."Last Name");

        if (StrLen(Member."Middle Name") > 0) then
            if (StrLen(Member."First Name") + StrLen(Member."Middle Name") + StrLen(Member."Last Name") + 2 <= MaxStrLen(Member."Display Name")) then
                Member."Display Name" := StrSubstNo('%1 %2 %3', Member."First Name", Member."Middle Name", Member."Last Name");

        MembershipEvents.OnAfterMemberFieldsAssignmentEvent(CurrentMember, Member);

        exit;
    end;

    local procedure ValidateMemberFields(MembershipEntryNo: Integer; Member: Record "NPR MM Member"; ResponseMessage: Text) IsValid: Boolean
    var
        Membership: Record "NPR MM Membership";
        Community: Record "NPR MM Member Community";
        UniqIdSet: Boolean;
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        ResponseMessage := '';

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        Community.Get(Membership."Community Code");
        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::ANONYMOUS) then
            exit(true);

        UniqIdSet := false;
        case Community."Member Unique Identity" of
            Community."Member Unique Identity"::NONE:
                UniqIdSet := true;
            Community."Member Unique Identity"::EMAIL:
                UniqIdSet := (Member."E-Mail Address" <> '');
            Community."Member Unique Identity"::PHONENO:
                UniqIdSet := (Member."Phone No." <> '');
            Community."Member Unique Identity"::SSN:
                UniqIdSet := (Member."Social Security No." <> '');
            else
                Error(CASE_MISSING, Community.FieldName("Member Unique Identity"), Community."Member Unique Identity");
        end;

        if (not UniqIdSet) then
            exit(RaiseError(ResponseMessage, StrSubstNo(MISSING_VALUE, Community."Member Unique Identity", Member.TableCaption(), Member."External Member No."), '') = 0);

        exit(true);
    end;

    local procedure CreateMemberRole(MemberEntryNo: Integer; MembershipEntryNo: Integer; MemberInfoCapture: Record "NPR MM Member Info Capture"; var MemberCount: Integer; var ResponseMessage: Text): Boolean
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipRoleGuardian: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        GDPRManagement: Codeunit "NPR GDPR Management";
        MemberGDPRManagement: Codeunit "NPR MM GDPR Management";
        GuardianMemberEntryNo: Integer;
    begin

        Member.Get(MemberEntryNo);
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");

        MembershipRoleGuardian.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRoleGuardian.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRoleGuardian.SetFilter(Blocked, '=%1', false);

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        if (MembershipRole.IsEmpty()) then begin
            // First member
            MembershipRole.Init();
            MembershipRole."Member Role" := MembershipRole."Member Role"::ADMIN;
            if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::MEMBERS_ONLY) then
                MembershipRole."Member Role" := MembershipRole."Member Role"::MEMBER;

        end else begin
            // member 2..n
            MembershipRole.Init();
            if (MembershipSetup."Membership Type" = MembershipSetup."Membership Type"::INDIVIDUAL) then begin
                RaiseError(ResponseMessage, StrSubstNo(TO_MANY_MEMBERS, Membership."External Membership No.", MembershipSetup.Code, 1), TO_MANY_MEMBERS_NO);
                exit(false);
            end;

            MemberCount := GetMembershipMemberCount(MembershipEntryNo);

            if (MembershipSetup."Membership Member Cardinality" > 0) then begin
                if (MemberCount >= MembershipSetup."Membership Member Cardinality") then begin
                    RaiseError(ResponseMessage, StrSubstNo(TO_MANY_MEMBERS, Membership."External Membership No.", MembershipSetup.Code, MembershipSetup."Membership Member Cardinality"), TO_MANY_MEMBERS_NO);
                    exit(false);
                end;
            end;

            MembershipRole."Member Role" := MembershipRole."Member Role"::MEMBER;
            if (MembershipSetup."Member Role Assignment" = MembershipSetup."Member Role Assignment"::ALL_ADMINS) then
                MembershipRole."Member Role" := MembershipRole."Member Role"::ADMIN;

        end;

        if (MemberInfoCapture."Guardian External Member No." <> '') or (MembershipRoleGuardian.FindFirst()) then
            MembershipRole."Member Role" := MembershipRole."Member Role"::DEPENDENT;

        MembershipRole."Community Code" := Membership."Community Code";
        MembershipRole."Membership Entry No." := MembershipEntryNo;
        MembershipRole."Member Entry No." := MemberEntryNo;

        MembershipRole."User Logon ID" := SelectMemberLogonCredentials(Membership."Community Code", Member, MemberInfoCapture."User Logon ID");
        if (LogonIdExists(MembershipRole."Community Code", MembershipRole."User Logon ID")) then
            Error(LOGIN_ID_EXIST, MembershipRole."User Logon ID", Member."External Member No.");

        MembershipRole."GDPR Agreement No." := MembershipSetup."GDPR Agreement No.";
        MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));

        if (MemberInfoCapture."Contact No." <> '') then begin
            if (not ValidateUseContactNo(Membership."Customer No.", MemberInfoCapture."Contact No.")) then begin
                RaiseError(ResponseMessage, StrSubstNo(INVALID_CONTACT, MemberInfoCapture."Contact No.", Membership."Customer No."), INVALID_CONTACT_NO);
                exit(false);
            end;
            MembershipRole."Contact No." := MemberInfoCapture."Contact No.";
        end;

        MembershipRole."Password Hash" := EncodeSHA1(MemberInfoCapture."Password SHA1");
        MembershipRole."Created At" := CurrentDateTime;
        MembershipRole.Insert(true);

        // To get the requests in the correct order.
        if (MembershipRole."Member Role" <> MembershipRole."Member Role"::DEPENDENT) then begin
            if (MembershipSetup."GDPR Mode" = MembershipSetup."GDPR Mode"::CONSENT) then
                GDPRManagement.CreateAgreementPendingEntry(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

            if (MemberInfoCapture."Guardian External Member No." = '') then
                MemberGDPRManagement.SetApprovalState(MembershipRole."GDPR Agreement No.", MembershipRole."GDPR Data Subject Id", MemberInfoCapture."GDPR Approval");
        end;

        MemberCount := GetMembershipMemberCount(MembershipEntryNo);

        exit(true);
    end;

    local procedure CreateGuardianRoleWorker(MembershipEntryNo: Integer; GuardianMemberEntryNo: Integer; GuardianGdprApproval: Option): Boolean
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        GDPRManagement: Codeunit "NPR GDPR Management";
        MemberGDPRManagement: Codeunit "NPR MM GDPR Management";
    begin

        if (GuardianMemberEntryNo = 0) then
            exit(false);

        Member.Get(GuardianMemberEntryNo);
        Membership.Get(MembershipEntryNo);

        MembershipSetup.Get(Membership."Membership Code");

        // All non-guardians will have their GDPR approval set to "Delegated to Guardian"
        MembershipRole.Reset();
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindSet()) then begin
            Membership.Get(MembershipEntryNo);
            MembershipSetup.Get(Membership."Membership Code");
            repeat

                if (MembershipRole."Member Role" <> MembershipRole."Member Role"::GUARDIAN) then begin
                    if (MembershipRole."Member Role" <> MembershipRole."Member Role"::DEPENDENT) then begin
                        MembershipRole."Member Role" := MembershipRole."Member Role"::DEPENDENT;
                        MembershipRole.Modify();
                    end;

                    if (MembershipSetup."GDPR Agreement No." <> '') then begin
                        MembershipRole.CalcFields("GDPR Approval");

                        if ((MembershipRole."GDPR Agreement No." <> MembershipSetup."GDPR Agreement No.") or (MembershipRole."GDPR Data Subject Id" = '')) then begin
                            MembershipRole."GDPR Agreement No." := MembershipSetup."GDPR Agreement No.";
                            if (MembershipRole."GDPR Data Subject Id" = '') then
                                MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
                            MembershipRole.Modify();
                        end;

                        if (MembershipRole."GDPR Approval" <> MembershipRole."GDPR Approval"::DELEGATED) then
                            GDPRManagement.CreateAgreementDelegateToGuardianEntry(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

                    end;
                end;

            until (MembershipRole.Next() = 0);

        end;

        // Create the GUARDIAN
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter("Member Entry No.", '=%1', GuardianMemberEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        if (MembershipRole.IsEmpty()) then begin
            MembershipRole.Init();
            MembershipRole."Member Role" := MembershipRole."Member Role"::GUARDIAN;

            MembershipRole."Community Code" := Membership."Community Code";
            MembershipRole."Membership Entry No." := MembershipEntryNo;
            MembershipRole."Member Entry No." := GuardianMemberEntryNo;

            if (MembershipSetup."GDPR Agreement No." <> '') then begin
                MembershipRole."GDPR Agreement No." := MembershipSetup."GDPR Agreement No.";
                MembershipRole."GDPR Data Subject Id" := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
            end;

            MembershipRole."Created At" := CurrentDateTime;
            MembershipRole.Insert(true);

            if (MembershipRole."GDPR Agreement No." <> '') then begin
                // To get the requests in the correct order.
                if (MembershipSetup."GDPR Mode" = MembershipSetup."GDPR Mode"::CONSENT) then
                    GDPRManagement.CreateAgreementPendingEntry(MembershipRole."GDPR Agreement No.", 0, MembershipRole."GDPR Data Subject Id");

                MemberGDPRManagement.SetApprovalState(MembershipRole."GDPR Agreement No.", MembershipRole."GDPR Data Subject Id", GuardianGdprApproval);
            end;

        end;

        exit(true);
    end;

    local procedure IssueMemberCardWorker(MembershipEntryNo: Integer; MemberEntryNo: Integer; var MemberInfoCapture: Record "NPR MM Member Info Capture"; AllowBlankNumber: Boolean; var CardEntryNo: Integer; var ReasonMessage: Text; ForceValidUntilDate: Boolean): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MemberCard2: Record "NPR MM Member Card";
        CardValidUntil: Date;
        CardFound: Boolean;
    begin

        CardEntryNo := 0;
        MemberInfoCapture."External Card No." := UpperCase(MemberInfoCapture."External Card No.");

        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        if (MembershipSetup."Loyalty Card" = MembershipSetup."Loyalty Card"::NO) then
            exit(false);

        if (MembershipSetup."Member Information" = MembershipSetup."Member Information"::NAMED) then
            Member.Get(MemberEntryNo);

        CardFound := false;
        if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then begin
            MemberCard2.Reset();
            MemberCard2.SetCurrentKey("External Card No.");
            MemberCard2.SetFilter("External Card No.", '=%1', MemberInfoCapture."External Card No.");
            MemberCard2.SetFilter(Blocked, '=%1', false);
            CardFound := MemberCard2.FindFirst();
        end;

        if (CardFound) then begin
            MemberCard.Get(MemberCard2."Entry No.");
            CardFound := (MembershipEntryNo = MemberCard2."Membership Entry No.");
        end;

        if (not CardFound) then begin
            MemberCard."Entry No." := 0;
            MemberCard.Init();
            MemberCard."Membership Entry No." := MembershipEntryNo;
            MemberCard."Member Entry No." := MemberEntryNo;

            if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then
                MemberCard."Card Type" := MemberCard."Card Type"::EXTERNAL;

            MemberCard.Insert();
        end;

        MemberInfoCapture."External Member No" := Member."External Member No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";

        // Override ValidUntil specified on MembershipSetup for card scheme GENERATED
        CardValidUntil := MemberInfoCapture."Valid Until";

        if (MemberInfoCapture."External Card No." = '') then
            if (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::GENERATED) then
                GenerateExtCardNoSimple(MembershipEntryNo, MembershipSetup.Code, MemberInfoCapture);

        if (not AllowBlankNumber) and (MemberInfoCapture."External Card No." = '') then begin
            RaiseError(ReasonMessage, MEMBERCARD_BLANK, MEMBERCARD_BLANK_NO);
            exit(false);
        end;

        if (MemberInfoCapture."External Card No." <> '') and (not CardFound) then begin
            MemberCard2.Reset();
            MemberCard2.SetCurrentKey("External Card No.");
            MemberCard2.SetFilter("External Card No.", '=%1', MemberInfoCapture."External Card No.");
            MemberCard2.SetFilter(Blocked, '=%1', false);
            if (MemberCard2.FindFirst()) then begin
                RaiseError(ReasonMessage, StrSubstNo(MEMBER_CARD_EXIST, MemberCard2."External Card No."), MEMBER_CARD_EXIST_NO);
                exit(false);
            end;
        end;

        MemberCard."External Card No." := MemberInfoCapture."External Card No.";
        MemberCard."External Card No. Last 4" := MemberInfoCapture."External Card No. Last 4";
        MemberCard."Pin Code" := MemberInfoCapture."Pin Code";
        MemberCard."Valid Until" := MemberInfoCapture."Valid Until";

        if (ForceValidUntilDate) then
            MemberCard."Valid Until" := CardValidUntil;

        MemberCard."Card Is Temporary" := MemberInfoCapture."Temporary Member Card";

        MemberCard.Modify();

        CardEntryNo := MemberCard."Entry No.";
        exit(CardEntryNo <> 0);

    end;

    local procedure PrintCard()
    begin
    end;

    local procedure EncodeSHA1(Plain: Text) Encoded: Text
    begin

        exit(Plain);
    end;

    local procedure AssignExternalMembershipNo(CommunityCode: Code[20]) ExternalNo: Code[20]
    var
        Community: Record "NPR MM Member Community";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        Community.Get(CommunityCode);
        ExternalNo := NoSeriesManagement.GetNextNo(Community."External Membership No. Series", Today, true);
    end;

    local procedure AssignExternalMemberNo(SuggestedExternalNo: Code[20]; CommunityCode: Code[20]) ExternalNo: Code[20]
    var
        Community: Record "NPR MM Member Community";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin

        Community.Get(CommunityCode);
        if (SuggestedExternalNo <> '') then begin
            NoSeriesManagement.TestManual(Community."External Member No. Series");
            exit(SuggestedExternalNo);
        end;

        ExternalNo := NoSeriesManagement.GetNextNo(Community."External Member No. Series", Today, true);
    end;

    local procedure GenerateExtCardNoSimple(MembershipEntryNo: Integer; MembershipCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
        BaseNumberPadding: Code[100];
        PAN: Code[100];
        PanLength: Integer;
    begin

        MembershipSetup.Get(MembershipCode);

        if (MembershipSetup."Card Number Pattern" = '') then begin
            MembershipSetup."Card Number Pattern" := '[X*4][MA][X*4][MS][S]';
            MembershipSetup."Card Number Length" := 0;
        end;

        BaseNumberPadding := GenerateExtCardNo(MembershipSetup."Card Number Pattern", MemberInfoCapture."External Member No", MemberInfoCapture."External Membership No.", MembershipSetup."Card Number No. Series");

        PanLength := 0;
        case MembershipSetup."Card Number Validation" of
            MembershipSetup."Card Number Validation"::NONE:
                ;
            MembershipSetup."Card Number Validation"::CHECKDIGIT:
                PanLength -= 1;
        end;

        if (MembershipSetup."Card Number Length" <> 0) then
            PanLength += MembershipSetup."Card Number Length" - StrLen(MembershipSetup."Card Number Prefix")
        else
            PanLength += StrLen(BaseNumberPadding);

        PAN := StrSubstNo('%1%2', MembershipSetup."Card Number Prefix", CopyStr(BaseNumberPadding, 1, PanLength));

        case MembershipSetup."Card Number Validation" of
            MembershipSetup."Card Number Validation"::NONE:
                ;
            MembershipSetup."Card Number Validation"::CHECKDIGIT:
                PAN := StrSubstNo('%1%2', PAN, GenerateRandom('N'));
        end;

        if (StrLen(PAN) > MaxStrLen(MemberInfoCapture."External Card No.")) then
            Error(PAN_TO_LONG, MaxStrLen(MemberInfoCapture."External Card No."), MembershipSetup."Card Number Pattern");

        MemberInfoCapture."External Card No." := PAN;
        MemberInfoCapture."External Card No. Last 4" := CopyStr(PAN, StrLen(PAN) - 4 + 1);
        MemberInfoCapture."Pin Code" := '1234';

        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::DATEFORMULA) then
            MemberInfoCapture."Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", Today);

        if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED) then begin
            MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipEntry.SetFilter(Blocked, '=%1', false);
            if (MembershipEntry.FindLast()) then begin
                if (not MembershipEntry."Activate On First Use") then
                    MemberInfoCapture."Valid Until" := MembershipEntry."Valid Until Date";
            end;
        end;

    end;

    procedure GenerateExtCardNo(GeneratePattern: Text[30]; ExternalMemberNo: Code[20]; ExternalMembershipNo: Code[20]; NumberSeries: Code[20]) ExtCardNo: Code[50]
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
        if (GeneratePattern = '') then
            exit;

        // Pattern example TEXT-[MA][N*5]-[N]
        // MA MemberAccount (external)
        // MS MemberShip (external)
        // S Numberseries
        // N random number (repeats * time)
        // A random char (repeats * time)
        // X random alpha numeric (repeats * time)

        GeneratePattern := UpperCase(GeneratePattern);

        ExtCardNo := '';
        if (StrLen(DelChr(GeneratePattern, '=', '[')) <> StrLen(DelChr(GeneratePattern, '=', ']'))) then
            Error(PATTERN_ERROR, GeneratePattern);

        while (StrLen(GeneratePattern) > 0) do begin
            PosStartClause := StrPos(GeneratePattern, '[');
            PosEndClause := StrPos(GeneratePattern, ']');
            PatternLength := PosEndClause - PosStartClause - 1;

            Pattern := '';
            if (PatternLength > 0) then
                Pattern := CopyStr(GeneratePattern, PosStartClause + 1, PatternLength);

            if (PatternLength < 1) then begin
                ExtCardNo := ExtCardNo + GeneratePattern;
                exit;
            end;

            if (PosStartClause > 1) then begin
                ExtCardNo := ExtCardNo + CopyStr(GeneratePattern, 1, PosStartClause - 1);
            end;

            if (PatternLength > 0) then begin
                Left := Pattern;
                Right := '1';
                if (StrPos(Pattern, '*') > 1) then begin
                    Left := CopyStr(Pattern, 1, StrPos(Pattern, '*') - 1);
                    Right := CopyStr(Pattern, StrPos(Pattern, '*') + 1);
                end;

                case Left of
                    'MA':
                        ExtCardNo := StrSubstNo('%1%2', ExtCardNo, ExternalMemberNo);
                    'MS':
                        ExtCardNo := StrSubstNo('%1%2', ExtCardNo, ExternalMembershipNo);
                    'S':
                        ExtCardNo := StrSubstNo('%1%2', ExtCardNo, NoSeriesManagement.GetNextNo(NumberSeries, Today, true));
                    'N', 'A', 'X':
                        begin
                            Evaluate(PatternLength, Right);
                            for Itt := 1 to PatternLength do
                                ExtCardNo := StrSubstNo('%1%2', ExtCardNo, GenerateRandom(Left));
                        end;
                    else begin
                            ExtCardNo := StrSubstNo('%1%2', ExtCardNo, Pattern);
                        end;
                end;
            end;

            if (StrLen(GeneratePattern) > PosEndClause) then
                GeneratePattern := CopyStr(GeneratePattern, PosEndClause + 1)
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
            'N':
                Random := Format(Number mod 10);
            'A':
                Char := (Number mod 25) + 65;
            'X':
                begin
                    if (GetRandom(2) mod 35) < 10 then
                        Random := Format(Number mod 10)
                    else
                        Char := (Number mod 25) + 65;
                end;
        end;

        if (Random = '') then
            exit(UpperCase(Format(Char)));
    end;

    local procedure GetRandom(Bytes: Integer) RandomInt: Integer
    var
        i: Integer;
        RandomHexString: Code[50];
    begin
        RandomHexString := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
        Bytes := Bytes mod StrLen(RandomHexString);

        RandomInt := 0;
        for i := 1 to Bytes do
            case CopyStr(RandomHexString, i, 1) of
                '1':
                    RandomInt += Power(16, Bytes - i);
                '2':
                    RandomInt += 2 * Power(16, Bytes - i);
                '3':
                    RandomInt += 3 * Power(16, Bytes - i);
                '4':
                    RandomInt += 4 * Power(16, Bytes - i);
                '5':
                    RandomInt += 5 * Power(16, Bytes - i);
                '6':
                    RandomInt += 6 * Power(16, Bytes - i);
                '7':
                    RandomInt += 7 * Power(16, Bytes - i);
                '8':
                    RandomInt += 8 * Power(16, Bytes - i);
                '9':
                    RandomInt += 9 * Power(16, Bytes - i);
                'A':
                    RandomInt += 10 * Power(16, Bytes - i);
                'B':
                    RandomInt += 11 * Power(16, Bytes - i);
                'C':
                    RandomInt += 12 * Power(16, Bytes - i);
                'D':
                    RandomInt += 13 * Power(16, Bytes - i);
                'E':
                    RandomInt += 14 * Power(16, Bytes - i);
                'F':
                    RandomInt += 15 * Power(16, Bytes - i);
            end;
    end;

    local procedure LogonIdExists(CommunityCode: Code[20]; LogonId: Code[80]): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (LogonId = '') then
            exit(false);

        MembershipRole.SetCurrentKey("Community Code", "User Logon ID");

        MembershipRole.SetFilter("Community Code", '=%1', CommunityCode);
        MembershipRole.SetFilter("User Logon ID", '=%1', LogonId);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        exit(MembershipRole.FindFirst());
    end;

    local procedure ValidateUseCustomerNo(CustomerNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        Membership: Record "NPR MM Membership";
    begin

        if (not Customer.Get(CustomerNo)) then
            exit(false);

        Membership.SetFilter("Customer No.", '=%1', CustomerNo);
        Membership.SetFilter(Blocked, '=%1', false);

        if (not Membership.FindFirst()) then
            exit(true);

        if (IsMembershipActive(Membership."Entry No.", Today, false)) then
            exit(false);

        Membership."Customer No." := '';
        Membership.Modify();
        exit(true);

    end;

    local procedure ValidateUseContactNo(CustomerNo: Code[20]; ContactNo: Code[20]): Boolean
    var
        Customer: Record Customer;
        Contact: Record Contact;
        MembershipRole: Record "NPR MM Membership Role";
        ContactBusinessRelation: Record "Contact Business Relation";
    begin

        if (not Customer.Get(CustomerNo)) then
            exit(false);

        if (not Contact.Get(ContactNo)) then
            exit(false);

        MembershipRole.SetFilter("Contact No.", '=%1', ContactNo);
        if (not MembershipRole.IsEmpty()) then
            exit(false);

        ContactBusinessRelation.SetFilter("Contact No.", '=%1', ContactNo);
        ContactBusinessRelation.SetFilter("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
        ContactBusinessRelation.SetFilter("No.", '=%1', CustomerNo);
        exit(not ContactBusinessRelation.IsEmpty());

    end;

    local procedure SelectMemberLogonCredentials(CommunityCode: Code[20]; Member: Record "NPR MM Member"; CustomLogonID: Code[80]) MemberLogonId: Code[80]
    var
        Community: Record "NPR MM Member Community";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        Community.Get(CommunityCode);

        case Community."Member Logon Credentials" of
            Community."Member Logon Credentials"::NA:
                exit('');
            Community."Member Logon Credentials"::MEMBER_UNIQUE_ID:
                case Community."Member Unique Identity" of
                    Community."Member Unique Identity"::NONE:
                        MemberLogonId := '';
                    Community."Member Unique Identity"::EMAIL:
                        MemberLogonId := Member."E-Mail Address";
                    Community."Member Unique Identity"::PHONENO:
                        MemberLogonId := Member."Phone No.";
                    Community."Member Unique Identity"::SSN:
                        MemberLogonId := Member."Social Security No.";
                    else
                        Error(CASE_MISSING, Community.FieldName("Member Unique Identity"), Community."Member Unique Identity");
                end;
            Community."Member Logon Credentials"::MEMBER_NUMBER:
                MemberLogonId := Member."External Member No.";
            Community."Member Logon Credentials"::CUSTOM:
                MemberLogonId := CustomLogonID;
            else
                Error(CASE_MISSING, Community.FieldName("Member Logon Credentials"), Community."Member Logon Credentials");
        end;

        if (MemberLogonId = '') then
            Error(LOGIN_ID_BLANK,
              MembershipRole.FieldName("User Logon ID"),
              Community.FieldName("Member Logon Credentials"),
              Community."Member Logon Credentials");

        exit(MemberLogonId);
    end;

    local procedure RaiseError(var ResponseMessage: Text; MessageText: Text; MessageId: Text) MessageNumber: Integer
    begin
        ResponseMessage := MessageText;

        if (MessageId <> '') then
            ResponseMessage := StrSubstNo('[%1] - %2', MessageId, MessageText);

        Error(ResponseMessage);
    end;

    local procedure ExitFalseOrWithError(VerboseMessage: Boolean; ErrorMessage: Text): Boolean
    begin

        if (VerboseMessage) then
            Error(ErrorMessage);

        exit(false);
    end;

    local procedure "--Events"()
    begin
    end;

    local procedure OnMembershipChangeEvent(MembershipEntryNo: Integer)
    var
        Membership: Record "NPR MM Membership";
    begin

        if (Membership.Get(MembershipEntryNo)) then begin
            Membership."Modified At" := CurrentDateTime();
            Membership.Modify(true);
        end;
    end;

    local procedure "--ExternalSearchFunctions"()
    begin
    end;

    procedure GetMembershipFromUserPassword(UserLogonId: Code[50]; Password: Text[50]) MembershipEntryNo: Integer
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
    begin

        MembershipRole.SetCurrentKey("User Logon ID");
        MembershipRole.SetFilter("User Logon ID", '=%1', UserLogonId);
        MembershipRole.SetFilter("Password Hash", '=%1 | =%2', Password, EncodeSHA1(Password));

        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (not MembershipRole.FindFirst()) then
            exit(0);

        Membership.Get(MembershipRole."Membership Entry No.");
        if (Membership.Blocked) then
            exit(0);

        exit(Membership."Entry No.");
    end;

    procedure GetMembershipFromExtMemberNo(ExternalMemberNo: Code[20]) MembershipEntryNo: Integer
    var
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
    begin

        Member.SetCurrentKey("External Member No.");
        Member.SetFilter("External Member No.", '=%1', ExternalMemberNo);
        Member.SetFilter(Blocked, '=%1', false);
        if (not Member.FindFirst()) then
            exit(0);

        MembershipRole.SetCurrentKey("Member Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (not MembershipRole.FindFirst()) then
            exit(0);

        if (not (Membership.Get(MembershipRole."Membership Entry No."))) then
            exit(0);

        if (Membership.Blocked) then
            exit(0);

        exit(Membership."Entry No.");
    end;

    procedure GetMembershipFromExtCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text) MembershipEntryNo: Integer
    var
        CardEntryNo: Integer;
    begin

        // local check to find cardnumber
        if (StrLen(ExternalCardNo) <= 50) then
            MembershipEntryNo := GetMembershipFromExtCardNoWorker(ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);

        // Foreign cards might have more information then just a raw card number.
        if (MembershipEntryNo = 0) then
            MembershipEntryNo := GetMembershipFromForeignCardNo(ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);

    end;

    local procedure GetMembershipFromForeignCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text; var CardEntryNo: Integer) MembershipEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        RemoteReasonText: Text;
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
        FormatedCardNumber: Text[100];
    begin

        ForeignMembershipSetup.SetCurrentKey("Invokation Priority");
        ForeignMembershipSetup.SetFilter(Disabled, '=%1', false);
        ForeignMembershipSetup.SetFilter("Community Code", '<>%1', '');
        ForeignMembershipSetup.SetFilter("Manager Code", '<>%1', '');
        if (ForeignMembershipSetup.FindSet()) then begin
            repeat

                // try remote number with local prefix
                if (ForeignMembershipSetup."Append Local Prefix" <> '') then begin
                    if (StrLen(ForeignMembershipSetup."Append Local Prefix") + StrLen(ExternalCardNo) <= 50) then
                        MembershipEntryNo := GetMembershipFromExtCardNoWorker(StrSubstNo('%1%2', ForeignMembershipSetup."Append Local Prefix", ExternalCardNo), ReferenceDate, RemoteReasonText, CardEntryNo);
                end;

                // try remote number with integration code to parse the scanned card data
                if (MembershipEntryNo = 0) then begin
                    ForeignMembershipMgr.FormatForeignCardnumberFromScan(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code", ExternalCardNo, FormatedCardNumber);
                    MembershipEntryNo := GetMembershipFromExtCardNoWorker(FormatedCardNumber, ReferenceDate, RemoteReasonText, CardEntryNo);
                end;

                if (MembershipEntryNo <> 0) then
                    if (Membership.Get(MembershipEntryNo)) then
                        ForeignMembershipMgr.SynchronizeLoyaltyPoints(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code", MembershipEntryNo, ExternalCardNo);

            until ((ForeignMembershipSetup.Next() = 0) or (MembershipEntryNo <> 0));
        end;

    end;

    local procedure GetMembershipFromExtCardNoWorker(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text; var CardEntryNo: Integer) MembershipEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        ReasonNotFound := '';

        ExternalCardNo := DelChr(ExternalCardNo, '<', ' ');
        if (ExternalCardNo = '') then begin
            ReasonNotFound := StrSubstNo(INVALID_NUMBER, ExternalCardNo, MemberCard.FieldCaption("External Card No."));
            exit(0);
        end;

        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1(ExternalCardNo));

        if (not MemberCard.FindFirst()) then begin
            ReasonNotFound := StrSubstNo(MEMBERCARD_NOT_FOUND, ExternalCardNo);
            exit(0);
        end;

        MemberCard.SetFilter(Blocked, '=%1', false);
        if (not MemberCard.FindFirst()) then begin
            ReasonNotFound := StrSubstNo(MEMBERCARD_BLOCKED, ExternalCardNo);
            exit(0);
        end;

        if (ReferenceDate = 0D) then
            ReferenceDate := WorkDate;

        if (not Membership.Get(MemberCard."Membership Entry No.")) then begin
            ReasonNotFound := StrSubstNo(MEMBERSHIP_CARD_REF, ExternalCardNo, MemberCard."Membership Entry No.");
            exit(0);
        end;

        MembershipSetup.Get(Membership."Membership Code");
        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then begin

            MemberCard.SetFilter("Valid Until", '>=%1', ReferenceDate);
            if (not MemberCard.FindFirst()) then begin

                MemberCard.Reset();
                MemberCard.SetCurrentKey("External Card No.");
                MemberCard.SetFilter(Blocked, '=%1', false);
                MemberCard.SetFilter("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1(ExternalCardNo));
                if (MemberCard.FindLast()) then begin
                    if (Membership.Get(MemberCard."Membership Entry No.")) then begin
                        if (not Membership.Blocked) then begin
                            // external member card number exist, but it has expired, membership is not blocked.
                            CardEntryNo := MemberCard."Entry No.";
                            exit(Membership."Entry No.");

                        end else begin
                            // external member card number exist, it has expired, membership is blocked.
                            ReasonNotFound := StrSubstNo(MEMBERSHIP_BLOCKED, Membership."External Membership No.", ExternalCardNo, Membership."Blocked At");
                            exit(0);
                        end;
                    end;
                end else begin
                    // just in case..
                    ReasonNotFound := StrSubstNo(MEMBERCARD_BLOCKED, ExternalCardNo);
                    exit(0);
                end;
            end;

        end;

        if (Membership.Blocked) then begin
            ReasonNotFound := StrSubstNo(MEMBERSHIP_BLOCKED, Membership."External Membership No.", ExternalCardNo, Membership."Blocked At");
            exit(0);
        end;

        CardEntryNo := MemberCard."Entry No.";

        exit(Membership."Entry No.");
    end;

    procedure GetMembershipFromExtMembershipNo(ExternalMembershipNo: Code[20]) MembershipEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
    begin

        Membership.SetCurrentKey("External Membership No.");
        Membership.SetFilter("External Membership No.", '=%1', ExternalMembershipNo);
        Membership.SetFilter(Blocked, '=%1', false);
        if (not Membership.FindFirst()) then
            exit(0);

        exit(Membership."Entry No.");
    end;

    procedure GetMembershipFromCustomerNo(CustomerNo: Code[20]) MembershipEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
    begin

        Membership.SetCurrentKey("Customer No.");
        Membership.SetFilter("Customer No.", '=%1', CustomerNo);
        Membership.SetFilter(Blocked, '=%1', false);
        if (not Membership.FindFirst()) then
            exit(0);

        exit(Membership."Entry No.");

    end;

    procedure GetMemberFromExtMemberNo(ExternalMemberNo: Code[50]) MemberEntryNo: Integer
    var
        Member: Record "NPR MM Member";
    begin

        Member.SetCurrentKey("External Member No.");
        Member.SetFilter("External Member No.", '=%1', ExternalMemberNo);
        Member.SetFilter(Blocked, '=%1', false);
        if (not Member.FindFirst()) then
            exit(0);

        exit(Member."Entry No.");
    end;

    procedure GetMemberFromExtCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var NotFoundReasonText: Text) MemberEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        MembershipEntryNo: Integer;
        CardEntryNo: Integer;
    begin

        NotFoundReasonText := '';

        if (ReferenceDate = 0D) then
            ReferenceDate := Today;

        MembershipEntryNo := GetMembershipFromExtCardNoWorker(ExternalCardNo, ReferenceDate, NotFoundReasonText, CardEntryNo);
        if (MembershipEntryNo = 0) then
            exit(0);

        if (not MemberCard.Get(CardEntryNo)) then begin
            NotFoundReasonText := StrSubstNo(MEMBERCARD_NOT_FOUND, '{' + ExternalCardNo + '}');
            exit(0);
        end;

        if (MemberCard."Member Entry No." = 0) then begin
            NotFoundReasonText := StrSubstNo(MEMBER_CARD_REF, ExternalCardNo, MemberCard."Member Entry No.");
            exit(0);
        end;

        if (not Member.Get(MemberCard."Member Entry No.")) then begin
            NotFoundReasonText := StrSubstNo(MEMBER_CARD_REF, ExternalCardNo, MemberCard."Member Entry No.");
            exit(0);
        end;

        if (Member.Blocked) then begin
            NotFoundReasonText := StrSubstNo(MEMBER_BLOCKED, Member."External Member No.", Member."Blocked At");
            exit(0);
        end;

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MemberCard."Membership Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberCard."Member Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.IsEmpty()) then begin
            NotFoundReasonText := StrSubstNo(MEMBER_ROLE_BLOCKED, Member."External Member No.", Membership."External Membership No.");
            exit(0);
        end;

        exit(Member."Entry No.");

    end;

    procedure GetMemberFromUserPassword(UserLogonId: Code[50]; Password: Text[50]) MemberEntryNo: Integer
    var
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
    begin

        MembershipRole.SetCurrentKey("User Logon ID");
        MembershipRole.SetFilter("User Logon ID", '=%1', UpperCase(UserLogonId));
        MembershipRole.SetFilter("Password Hash", '=%1|=%2', Password, EncodeSHA1(Password));
        MembershipRole.SetFilter(Blocked, '=%1', false);

        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);

        if (not MembershipRole.FindFirst()) then
            exit(0);

        Member.Get(MembershipRole."Member Entry No.");
        if (Member.Blocked) then
            exit(0);

        exit(Member."Entry No.");
    end;

    procedure GetMemberCardEntryNo(MemberEntryNo: Integer; MembershipCode: Code[20]; ReferenceDate: Date) MemberCardEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(0);

        if (ReferenceDate < Today) then
            ReferenceDate := Today;

        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);

        MembershipSetup.Get(MembershipCode);
        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
            MemberCard.SetFilter("Valid Until", '>=%1', ReferenceDate);

        if (not MemberCard.FindLast()) then
            exit(0);

        exit(MemberCard."Entry No.");
    end;

    procedure GetCardEntryNoFromExtCardNo(ExternalCardNo: Text[100]) CardEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        PrefixedCardNo: Text;
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
    begin

        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter("External Card No.", '=%1|=%2', ExternalCardNo, EncodeSHA1(ExternalCardNo));
        MemberCard.SetFilter(Blocked, '=%1', false);

        if (MemberCard.IsEmpty()) then begin
            ForeignMembershipSetup.SetCurrentKey("Invokation Priority");
            ForeignMembershipSetup.SetFilter(Disabled, '=%1', false);
            ForeignMembershipSetup.SetFilter("Community Code", '<>%1', '');
            ForeignMembershipSetup.SetFilter("Manager Code", '<>%1', '');
            if (ForeignMembershipSetup.FindSet()) then begin
                repeat

                    // try remote number with local prefix
                    PrefixedCardNo := ExternalCardNo;
                    if (ForeignMembershipSetup."Append Local Prefix" <> '') then
                        PrefixedCardNo := StrSubstNo('%1%2', ForeignMembershipSetup."Append Local Prefix", ExternalCardNo);

                    MemberCard.SetFilter("External Card No.", '=%1|=%2', PrefixedCardNo, EncodeSHA1(PrefixedCardNo));

                until ((ForeignMembershipSetup.Next() = 0) or (not MemberCard.IsEmpty()));
            end;
        end;

        if (not MemberCard.FindFirst()) then
            exit(0);

        exit(MemberCard."Entry No.");
    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure OnAfterNavigateFindRecordsSubscriber(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        POSPeriodRegister: Record "NPR POS Period Register";
        POSEntry: Record "NPR POS Entry";
        Entries: Integer;
    begin

        if (MembershipEntry.ReadPermission()) then begin
            if (not MembershipEntry.SetCurrentKey("Receipt No.")) then;
            MembershipEntry.SetFilter("Receipt No.", '%1', DocNoFilter);
            Entries := InsertIntoDocEntry(DocumentEntry, DATABASE::"NPR MM Membership Entry", 0, CopyStr(DocNoFilter, 1, 20), MembershipEntry.TableCaption, MembershipEntry.Count());
        end;

    end;

    [EventSubscriber(ObjectType::Page, 344, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnAfterNavigateShowRecordsSubscriber(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MembershipFilter: Text;
    begin

        if (TableID = DATABASE::"NPR MM Membership Entry") then begin
            if (not MembershipEntry.SetCurrentKey("Receipt No.")) then;
            MembershipEntry.SetFilter("Receipt No.", DocNoFilter);
            MembershipEntry.FindSet();
            repeat
                MembershipFilter += StrSubstNo('|%1', MembershipEntry."Membership Entry No.");
            until (MembershipEntry.Next() = 0);

            Membership.SetFilter("Entry No.", CopyStr(MembershipFilter, 2));

            if (Membership.Count() = 1) then begin
                PAGE.Run(PAGE::"NPR MM Membership Card", Membership);
            end else begin
                PAGE.Run(PAGE::"NPR MM Memberships", Membership);
            end;
        end;

    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary; DocTableID: Integer; DocType: Integer; DocNoFilter: Code[20]; DocTableName: Text[1024]; DocNoOfRecords: Integer): Integer
    begin

        if (DocNoOfRecords = 0) then
            exit(DocNoOfRecords);

        with DocumentEntry do begin
            Init();
            "Entry No." := "Entry No." + 1;
            "Table ID" := DocTableID;
            "Document Type" := DocType;
            "Document No." := DocNoFilter;
            "Table Name" := CopyStr(DocTableName, 1, MaxStrLen("Table Name"));
            "No. of Records" := DocNoOfRecords;
            Insert();
        end;

        exit(DocNoOfRecords);

    end;

    procedure DeleteCtrlChars(StringToClean: Text): Text
    var
        CtrlChrs: Text[32];
        i: Integer;
    begin

        for i := 1 to 31 do
            CtrlChrs[i] := i;

        StringToClean := DelChr(StringToClean, '<>', ' ');

        exit(DelChr(StringToClean, '=', CtrlChrs));

    end;

    internal procedure TakeMemberInfoPicture(MMMemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Camera: Codeunit Camera;
        PictureStream: InStream;
        OStream: OutStream;
        PictureName: Text;
    begin
        if Camera.GetPicture(PictureStream, PictureName) then begin
            MMMemberInfoCapture.Picture.CreateOutStream(OStream);
            CopyStream(OStream, PictureStream);
            MMMemberInfoCapture.Modify();
        end;
    end;

    internal procedure TakeMemberPicture(MMMember: Record "NPR MM Member")
    var
        Camera: Codeunit Camera;
        PictureStream: InStream;
        OStream: OutStream;
        PictureName: Text;
    begin
        if Camera.GetPicture(PictureStream, PictureName) then begin
            MMMember.Picture.CreateOutStream(OStream);
            CopyStream(OStream, PictureStream);
            MMMember.Modify();
        end;
    end;
}

