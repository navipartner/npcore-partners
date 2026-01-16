codeunit 6184732 "NPR MM MembershipMgtInternal"
{
    Access = Internal;

    var
        MembershipEvents: Codeunit "NPR MM Membership Events";
        _MembershipWebhooks: Codeunit "NPR MM MembershipWebhooks";
        _FeatureFlag: Codeunit "NPR Feature Flags Management";
        PriceCalcInterfaceTok: Label 'alterationPriceCalcInterface', Locked = true;

        CASE_MISSING: Label '%1 value %2 is missing its implementation.';
        TO_MANY_MEMBERS: Label 'Max number of members exceeded. The membership %1 of type %2 allows a maximum of %3 members per membership.';
        LOGIN_ID_EXIST: Label 'The selected member logon id [%1] is already in use.\\Member %2.';
        LOGIN_ID_BLANK: Label 'The %1 can''t be blank when the setting for %2 is %3.';

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
        CONFIRM_REGRET: Label 'Do you want to regret subscription for membership %1 valid from %2 until %3.';
        CONFIRM_REGRET_AUTO_RENEW: Label 'Warning: this membership is setup for auto-renewal and changing the subscriptions might make the future auto-renewal fail. Do you want to regret subscription for membership %1 valid from %2 until %3.';
        CONFIRM_REGRET_UNDO: Label 'This action will reactivate the subscription from %2 until %3 for membership %1. Do you want to continue?';
        MISSING_TEMPLATE: Label 'The customer template %1 is not valid or not found.';
        RENEW_MEMBERSHIP: Label 'Do you want to renew the membership with %1 (%2 - %3).';
        CONFLICTING_ENTRY: Label 'There is already a membership period active in the time period %1 - %2.';
        EXTEND_MEMBERSHIP: Label 'Do you want to extend the membership with %1 (%2 - %3).';
        UPGRADE_MEMBERSHIP: Label 'Do you want to upgrade the membership with %1 (%2 - %3).';
        EXTEND_TO_SHORT: Label 'When extending a subscription, the new until date (%1) must exceed the current subscriptions until date (%2).';
        MULTIPLE_TIMEFRAMES: Label 'The operation %1 can not span multiple time frames for member entry no. %2. The new time frame %3 - %4, span current time frame entries %5 and %6.';
        NO_TIMEFRAME: Label 'Date of cancel (%1) must be within the active time frame (%2 - %3).';
        STACKING_NOT_ALLOWED: Label 'Setup does not allow stacking - having multiple open time frames.  Membership entry no %1, for date %2.';
        UPGRADE_TO_CODE_MISSING: Label 'When performing an upgrade, you must specify a target membership code.';
        MEMBERSHIP_BLOCKED: Label 'The membership %1 for card %2 is blocked. Block date is %3.';
        MEMBERCARD_NOT_FOUND: Label 'The member card %1 was not found.';
        MEMBERCARD_BLOCKED: Label 'The member card %1 is blocked.';
        NO_ADMIN_MEMBER: Label 'At least one member must have an administrative role in the membership. This members information will not be synchronized to customer. Membership could not be created.';
        MEMBERCARD_BLANK: Label 'Member card number can''t be empty or blank.';
        INVALID_CONTACT: Label 'The contact number %1 is not valid in context of customer number %2';
        TO_MANY_MEMBERS_NO: Label '-127001';
        MEMBER_CARD_EXIST_NO: Label '-127002';
        NO_ADMIN_MEMBER_NO: Label '-127003';
        MEMBERCARD_BLANK_NO: Label '-127004';
        INVALID_CONTACT_NO: Label '-127005';
        AGE_VERIFICATION_SETUP_NO: Label '-127006';
        AGE_VERIFICATION_NO: Label '-127007';
        ALLOW_MEMBER_MERGE_NOT_SET_NO: Label '-127008';
        MEMBER_WITH_UID_EXISTS_NO: Label '-127009';
        NO_LEDGER_ENTRY: Label 'The membership %1 is not valid.\\It must be activated, but there is no ledger entry associated with that membership that can be activated.';
        NOT_ACTIVATED: Label 'The membership is marked as activate on first use, but has not been activated yet. Retry the action after the membership has been activated.';
        NOT_FOUND: Label '%1 not found. %2';
        GRACE_PERIOD: Label 'The %1 is not allowed because of grace period constraint.';
        PREVENT_CARD_EXTEND: Label 'The validity for card %1 must first manually be extend until %2.';
        INVALID_ACTIVATION_DATE: Label 'The option %1 for %2 is not valid for alteration type %3.';
        AGE_VERIFICATION_SETUP: Label 'Add member failed on age verification because item number for sales was not provided.';
        AGE_VERIFICATION: Label 'Member %1 does not meet the age constraint of %2 years set on this product.';
        ALLOW_MEMBER_MERGE_NOT_SET: Label 'This request violates the community’s unique member identity rules. See the API documentation for merge options.';
        MEMBER_WITH_UID_EXISTS: Label 'Member with unique ID [%1] with name: %2 is already in use.';

    internal procedure CreateMembershipInteractive(var MemberInfoCapture: Record "NPR MM Member Info Capture") ExternalCardNumber: Text[100];
    var
        MemberInfoCapturePage: Page "NPR MM Member Info Capture";
        PageAction: Action;
        AttemptCreateMembership: Codeunit "NPR Membership Attempt Create";
        ResponseMessage: Text;
    begin

        MemberInfoCapture.SetFilter("Entry No.", '=%1', MemberInfoCapture."Entry No.");
        MemberInfoCapturePage.SetRecord(MemberInfoCapture);
        MemberInfoCapturePage.SetTableView(MemberInfoCapture);
        Commit();

        MemberInfoCapturePage.LookupMode(true);
        PageAction := MemberInfoCapturePage.RunModal();

        if (PageAction = Action::LookupOK) then begin
            MemberInfoCapturePage.GetRecord(MemberInfoCapture);
            MemberInfoCapture.SetRecFilter();

            Commit();
            AttemptCreateMembership.SetAttemptCreateMembership();
            if (not AttemptCreateMembership.Run(MemberInfoCapture)) then
                if (not AttemptCreateMembership.WasSuccessful(ResponseMessage)) then
                    Error(ResponseMessage);

            Commit();
            AttemptCreateMembership.SetCreateMembership();
            AttemptCreateMembership.Run(MemberInfoCapture);

            Commit();
            ExternalCardNumber := MemberInfoCapture."External Card No."

        end;
    end;

    internal procedure CreateMembershipAll(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
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

        if (MembershipSetup."Loyalty Card" = MembershipSetup."Loyalty Card"::YES) then
            if (not IssueMemberCardWorker(MembershipEntryNo, MemberEntryNo, MemberInfoCapture, false, CardEntryNo, MembershipSalesSetup."Membership Code", ResponseMessage, false)) then
                exit(0);

        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
        MemberInfoCapture."Member Entry No" := MemberEntryNo;
        MemberInfoCapture."Card Entry No." := CardEntryNo;

        exit(MembershipEntryNo);
    end;

    internal procedure CreateMembership(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
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

    internal procedure DeleteMembership(MembershipEntryNo: Integer; Force: Boolean)
    begin
        DeleteMembershipWorker(MembershipEntryNo, Force, true);
    end;

    internal procedure DeleteMembershipFromTableTrigger(MembershipEntryNo: Integer; Force: Boolean)
    begin
        DeleteMembershipWorker(MembershipEntryNo, Force, false);
    end;

    local procedure DeleteMembershipWorker(MembershipEntryNo: Integer; Force: Boolean; DeleteMembershipRecord: Boolean)
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
        RequestMemberFieldUpdate: Record "NPR MM Request Member Update";
        Subscription: Record "NPR MM Subscription";
        GdprManagement: Codeunit "NPR NP GDPR Management";
        GdprAnonymizeRequestWS: Codeunit "NPR GDPR Anon. Req. WS";
        OriginalCustomerNo: Code[20];
        MembershipTimeFrameEntries: Boolean;
        AnonymizeResponseCode: Integer;
        MembershipPmtMethodmap: Record "NPR MM MembershipPmtMethodMap";
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
                        if (GdprAnonymizeRequestWS.CanCustomerBeAnonymized(OriginalCustomerNo, '', AnonymizeResponseCode)) then
                            GdprManagement.AnonymizeCustomer(OriginalCustomerNo);

            if (MembershipTimeFrameEntries) then
                if (GdprAnonymizeRequestWS.CanCustomerBeAnonymized(OriginalCustomerNo, '', AnonymizeResponseCode)) then
                    GdprManagement.AnonymizeCustomer(OriginalCustomerNo);

            MembershipPmtMethodmap.SetRange(MembershipId, Membership.SystemId);
            if not MembershipPmtMethodMap.IsEmpty() then
                MembershipPmtMethodMap.DeleteAll(true);

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
                                begin
                                    Contact."NPR Magento Contact" := false;
                                    Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::BLOCKED;
                                end;
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

                if (RequestMemberFieldUpdate.SetCurrentKey("Member Entry No.")) then;
                RequestMemberFieldUpdate.SetFilter("Member Entry No.", '=%1', TempMembershipRole."Member Entry No.");
                RequestMemberFieldUpdate.DeleteAll();

            until (TempMembershipRole.Next() = 0);
        end;

        Subscription.SetRange("Membership Entry No.", Membership."Entry No.");
        if not Subscription.IsEmpty() then
            Subscription.DeleteAll(true);

        if (DeleteMembershipRecord) then
            Membership.Delete();

    end;

    internal procedure AddMemberAndCard(MembershipEntryNo: Integer; var MemberInfoCapture: Record "NPR MM Member Info Capture"; AllowBlankExternalCardNumber: Boolean; var MemberEntryNo: Integer; var ResponseMessage: Text): Boolean
    begin

        if (not AddNamedMember(MembershipEntryNo, MemberInfoCapture, MemberEntryNo, ResponseMessage)) then
            exit(false);

        if (not IssueMemberCardWorker(MembershipEntryNo, MemberEntryNo, MemberInfoCapture, AllowBlankExternalCardNumber, MemberInfoCapture."Card Entry No.", ResponseMessage, false)) then
            exit(false);

        exit(true);
    end;

    internal procedure AddAnonymousMember(MembershipInfoCapture: Record "NPR MM Member Info Capture"; NumberOfMembers: Integer)
    begin

        AddCommunityMember(MembershipInfoCapture."Membership Entry No.", NumberOfMembers);
    end;

    internal procedure AddNamedMember(MembershipEntryNo: Integer; var MembershipInfoCapture: Record "NPR MM Member Info Capture"; var MemberEntryNo: Integer; var ReasonText: Text): Boolean
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
        ReuseExistingMember: Boolean;
    begin
        Membership.Get(MembershipEntryNo);
        MembershipSetup.Get(Membership."Membership Code");
        Community.Get(Membership."Community Code");
        ReuseExistingMember := false;

        Member.Init();
        if (Member.Get(CheckMemberUniqueId(Community.Code, MembershipInfoCapture))) then begin
            SetMemberFields(Member, MembershipInfoCapture);
            ValidateMemberFields(Membership."Entry No.", Member, ErrorText);
            Member.Modify();
            MemberEntryNo := Member."Entry No.";

            ReuseExistingMember := (Community."Create Member UI Violation" = Community."Create Member UI Violation");
            if (not ReuseExistingMember) then
                exit(MemberEntryNo <> 0);
        end;

        if (not ReuseExistingMember) then begin
            Member."External Member No." := AssignExternalMemberNo(MembershipInfoCapture."External Member No", Membership."Community Code");
            SetMemberFields(Member, MembershipInfoCapture);
            Member.Insert(true);
        end;

        if (not CreateMemberRole(Member."Entry No.", MembershipEntryNo, MembershipInfoCapture, MemberCount, ReasonText)) then
            exit(false);

        if (not ReuseExistingMember) then
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

            UpdateCustomerFromMember(Membership, MembershipRole."Member Entry No.");

            if (MemberCount > 1) then
                AddCustomerContact(MembershipEntryNo, Member."Entry No."); // The member just being added.

        end;

        ValidateMemberFields(Membership."Entry No.", Member, ErrorText);

        DuplicateMcsPersonIdReference(MembershipInfoCapture, Member, true);

        TransferInfoCaptureAttributes(MembershipInfoCapture."Entry No.", Database::"NPR MM Member", Member."Entry No.");

        if (MembershipSetup."Enable Age Verification") then begin
            if (not MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MembershipInfoCapture."Item No.")) then
                exit(RaiseError(ReasonText, AGE_VERIFICATION_SETUP, AGE_VERIFICATION_SETUP_NO) = 0);

            if (not CheckAgeConstraint(GetMembershipAgeConstraintDate(MembershipSalesSetup, MembershipInfoCapture), Member.Birthday, MembershipSetup."Validate Age Against",
                MembershipSalesSetup."Age Constraint Type", MembershipSalesSetup."Age Constraint (Years)")) then
                exit(RaiseError(ReasonText, StrSubstNo(AGE_VERIFICATION, Member."Display Name", MembershipSalesSetup."Age Constraint (Years)"), AGE_VERIFICATION_NO) = 0);
        end;

        MembershipEvents.OnAfterMemberCreateEvent(Membership, Member, MembershipInfoCapture);
        AddMemberCreateNotification(MembershipEntryNo, MembershipSetup, Member, MembershipInfoCapture);

        MemberEntryNo := Member."Entry No.";
        exit(MemberEntryNo <> 0);
    end;

    internal procedure UpdateMemberUniqueId(OriginalMember: Record "NPR MM Member"; NewFirstName: Text[50]; NewEmail: Text[80]; NewPhoneNumber: Text[30]; NewExternalMemberNo: Code[20])
    var
        AllMembersUpdated: Boolean;
        Member: Record "NPR MM Member";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Community: Record "NPR MM Member Community";
        MultipleCommunities: Label 'The member exist in multiple communities that employ different unique ID rules for the members. Merging members based on unique ID is not possible.';
        MemberEntryNo: Integer;
    begin
        if (not (CheckGetCommunityUniqueIdRules(OriginalMember."Entry No.", Community))) then
            Error(MultipleCommunities);

        MemberInfoCapture."First Name" := NewFirstName;
        MemberInfoCapture."E-Mail Address" := NewEmail;
        MemberInfoCapture."Phone No." := NewPhoneNumber;
        MemberInfoCapture."Member Entry No" := OriginalMember."Entry No.";

        Member.Get(OriginalMember."Entry No.");
        repeat
            MemberEntryNo := Member."Entry No.";
            UpdateMemberUniqueIdWorker(OriginalMember, NewFirstName, NewEmail, NewPhoneNumber, NewExternalMemberNo);
            SetMemberUniqueIdFilter(Community, MemberInfoCapture, Member);
            AllMembersUpdated := not Member.FindFirst();
        until ((AllMembersUpdated) or (MemberEntryNo = Member."Entry No."));
    end;

    local procedure UpdateMemberUniqueIdWorker(OriginalMember: Record "NPR MM Member"; NewFirstName: Text[50]; NewEmail: Text[80]; NewPhoneNumber: Text[30]; NewExternalMemberNo: Code[20])
    var
        MemberToUpdate: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";

        MembershipLogEntry: Record "NPR MM Member Arr. Log Entry";
        Ticket: Record "NPR TM Ticket";
        ReservationReq: Record "NPR TM Ticket Reservation Req.";
        NotificationEntry: Record "NPR MM Member Notific. Entry";
        SponsorTicketEntry: Record "NPR MM Sponsors. Ticket Entry";

        ChangeExternalMemberNo: Boolean;
        ChangeFirstName: Boolean;
        ChangeEmail: Boolean;
        ChangePhoneNumber: Boolean;

    begin
        if (not MemberToUpdate.Get(OriginalMember."Entry No.")) then
            exit;

        MemberToUpdate."First Name" := NewFirstName;
        MemberToUpdate."E-Mail Address" := NewEmail;
        MemberToUpdate."Phone No." := NewPhoneNumber;
        MemberToUpdate."External Member No." := NewExternalMemberNo;
        MemberToUpdate."Display Name" := GetDisplayName(MemberToUpdate);
        MemberToUpdate.Modify();

        ChangeExternalMemberNo := (MemberToUpdate."External Member No." = OriginalMember."External Member No.");
        ChangeFirstName := (MemberToUpdate."First Name" = OriginalMember."First Name");
        ChangeEmail := (MemberToUpdate."E-Mail Address" = OriginalMember."E-Mail Address");
        ChangePhoneNumber := (MemberToUpdate."Phone No." = OriginalMember."Phone No.");

        MembershipRole.SetFilter("Member Entry No.", '=%1', OriginalMember."Entry No.");
        if (MembershipRole.FindSet()) then
            repeat
                Membership.Get(MembershipRole."Membership Entry No.");
                if (ChangeExternalMemberNo) then begin
                    MembershipLogEntry.SetCurrentKey("External Membership No.", "External Member No.", "Event Type", "Response Type", "Local Date");
                    MembershipLogEntry.SetFilter("External Membership No.", '=%1', Membership."External Membership No.");
                    MembershipLogEntry.SetFilter("External Member No.", '=%1', OriginalMember."External Member No.");
                    MembershipLogEntry.ModifyAll("External Member No.", NewExternalMemberNo);
                end;

                NotificationEntry.SetCurrentKey("Membership Entry No.");
                NotificationEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                NotificationEntry.SetFilter("External Member No.", '=%1', OriginalMember."External Member No.");
                if (ChangeFirstName) then
                    NotificationEntry.ModifyAll("First Name", NewFirstName);
                if (ChangeEmail) then
                    NotificationEntry.ModifyAll("E-Mail Address", NewEmail);
                if (ChangePhoneNumber) then
                    NotificationEntry.ModifyAll("Phone No.", NewPhoneNumber);
                if (ChangeExternalMemberNo) then
                    NotificationEntry.ModifyAll("External Member No.", NewExternalMemberNo);

                SponsorTicketEntry.SetCurrentKey("Membership Entry No.");
                SponsorTicketEntry.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                SponsorTicketEntry.SetFilter("External Member No.", '=%1', OriginalMember."External Member No.");
                if (ChangeFirstName) then
                    SponsorTicketEntry.ModifyAll("First Name", NewFirstName);
                if (ChangeEmail) then
                    SponsorTicketEntry.ModifyAll("E-Mail Address", NewEmail);
                if (ChangePhoneNumber) then
                    SponsorTicketEntry.ModifyAll("Phone No.", NewPhoneNumber);
                if (ChangeExternalMemberNo) then
                    SponsorTicketEntry.ModifyAll("External Member No.", NewExternalMemberNo);

                UpdateContactFromMember(MembershipRole."Membership Entry No.", MemberToUpdate);

            until (MembershipRole.Next() = 0);

        if (ChangeExternalMemberNo) then begin
            Ticket.SetFilter("External Member Card No.", '=%1', OriginalMember."External Member No.");
            Ticket.SetLoadFields("External Member Card No.");
            Ticket.ModifyAll("External Member Card No.", NewExternalMemberNo);
        end;

        if (ChangeExternalMemberNo) then begin
            ReservationReq.SetFilter("External Member No.", '=%1', OriginalMember."External Member No.");
            ReservationReq.SetLoadFields("External Member No.");
            ReservationReq.ModifyAll("External Member No.", NewExternalMemberNo);
        end;

    end;

    internal procedure MergeMemberUniqueId(MemberToKeep: Record "NPR MM Member"; NewFirstName: Text[50]; NewEmail: Text[80]; NewPhoneNumber: Text[30]; NewExternalMemberNo: Code[20])
    var
        AllMembersUpdated: Boolean;
        Member: Record "NPR MM Member";
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Community: Record "NPR MM Member Community";
        MultipleCommunities: Label 'The member exist in multiple communities that employ different unique ID rules for the members. Merging members based on unique ID is not possible.';
        MemberEntryNo: Integer;
    begin
        if (not (CheckGetCommunityUniqueIdRules(MemberToKeep."Entry No.", Community))) then
            Error(MultipleCommunities);

        MemberInfoCapture."First Name" := NewFirstName;
        MemberInfoCapture."E-Mail Address" := NewEmail;
        MemberInfoCapture."Phone No." := NewPhoneNumber;
        MemberInfoCapture."Member Entry No" := MemberToKeep."Entry No.";

        Member.Get(MemberToKeep."Entry No.");
        repeat
            MemberEntryNo := Member."Entry No.";
            MergeMemberUniqueIdWorker(Community, MemberToKeep, NewFirstName, NewEmail, NewPhoneNumber, NewExternalMemberNo);
            SetMemberUniqueIdFilter(Community, MemberInfoCapture, Member);
            AllMembersUpdated := not Member.FindFirst();
        until ((AllMembersUpdated) or (MemberEntryNo = Member."Entry No."));

    end;

    local procedure MergeMemberUniqueIdWorker(Community: Record "NPR MM Member Community"; MemberToKeep: Record "NPR MM Member"; NewFirstName: Text[50]; NewEmail: Text[80]; NewPhoneNumber: Text[30]; NewExternalMemberNo: Code[20])
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MemberToRemove: Record "NPR MM Member";

        AdmissionServiceEntry: Record "NPR MM Admis. Service Entry";
        MemberCommunicationProfiles: Record "NPR MM Member Communication";
        MemberCard: Record "NPR MM Member Card";
        MemberNotification: Record "NPR MM Membership Notific.";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        MemberInfoCapture."First Name" := NewFirstName;
        MemberInfoCapture."E-Mail Address" := NewEmail;
        MemberInfoCapture."Phone No." := NewPhoneNumber;
        MemberInfoCapture."Member Entry No" := MemberToKeep."Entry No.";

        SetMemberUniqueIdFilter(Community, MemberInfoCapture, MemberToRemove);
        if (not MemberToRemove.FindFirst()) then
            exit;

        UpdateMemberUniqueIdWorker(MemberToKeep, NewFirstName, NewEmail, NewPhoneNumber, NewExternalMemberNo);

        AdmissionServiceEntry.SetFilter("Member Entry No.", '=%1', MemberToRemove."Entry No.");
        AdmissionServiceEntry.SetLoadFields("Member Entry No.");
        AdmissionServiceEntry.ModifyAll("Member Entry No.", MemberToKeep."Entry No.");

        MemberCommunicationProfiles.SetFilter("Member Entry No.", '=%1', MemberToRemove."Entry No.");
        if (MemberCommunicationProfiles.FindSet()) then
            repeat
                MemberCommunicationProfiles.Delete();
                MemberCommunicationProfiles."Member Entry No." := MemberToKeep."Entry No.";
                if (not MemberCommunicationProfiles.Insert()) then;
            until (MemberCommunicationProfiles.Next() = 0);

        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberToRemove."Entry No.");
        MemberCard.ModifyAll("Member Entry No.", MemberToKeep."Entry No.");

        MemberNotification.SetFilter("Member Entry No.", '=%1', MemberToRemove."Entry No.");
        MemberNotification.ModifyAll("Member Entry No.", MemberToKeep."Entry No.");

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberToRemove."Entry No.");
        if (MembershipRole.FindSet()) then
            repeat
                MembershipRole.Delete();
                MembershipRole."Member Entry No." := MemberToKeep."Entry No.";
                if (not MembershipRole.Insert()) then;
            until (MembershipRole.Next() = 0);

        DeleteMember(MemberToRemove."Entry No.", true);

        MembershipEvents.OnAfterMemberIsMerged(MemberToKeep, MemberToRemove);
    end;


    internal procedure DeleteMember(MemberEntryNo: Integer; ForceMemberDelete: Boolean)
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
                            begin
                                Contact."NPR Magento Contact" := false;
                                Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::BLOCKED;
                            end;
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

    internal procedure AddGuardianMember(MembershipEntryNo: Integer; GuardianExternalMemberNo: Code[20]; GdprApproval: Option): Boolean
    var
        GuardianMemberEntryNo: Integer;
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
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
        Membership.Get(MembershipEntryNo);
        UpdateCustomerFromMember(Membership, MembershipRole."Member Entry No.");

        exit(true);

    end;

    internal procedure PrintOffline(PrintOption: Option; EntryNo: Integer)
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

    internal procedure GetMemberImage(MemberEntryNo: Integer; var Base64StringImage: Text) Success: Boolean
    var
        Member: Record "NPR MM Member";
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        if (MemberMedia.IsFeatureEnabled()) then begin
            MemberMedia.GetMemberImageB64(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::PREVIEW, Base64StringImage);

        end else begin
            if (not Member.Image.HasValue()) then
                exit(false);

            TempBlob.CreateOutStream(OutStr);
            Member.Image.ExportStream(OutStr);
            TempBlob.CreateInStream(InStr);
            Base64StringImage := Base64Convert.ToBase64(InStr);
        end;

        exit(true);
    end;

    internal procedure GetMemberImageThumbnail(MemberEntryNo: Integer; var Base64StringImage: Text) Success: Boolean
    var
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin
        if (MemberMedia.IsFeatureEnabled()) then
            exit(GetMemberImageThumbnailCloudflare(MemberEntryNo, Base64StringImage, 360));

        // Local images
        if (GetMemberImageThumbnailLocalMedia(MemberEntryNo, Base64StringImage, 360)) then
            exit(true);

        if (GetMemberImageThumbnailLocalMedia(MemberEntryNo, Base64StringImage, 240)) then
            exit(true);

        exit(GetMemberImage(MemberEntryNo, Base64StringImage));
    end;

    internal procedure GetMemberImageThumbnail(MemberEntryNo: Integer; var Base64StringImage: Text; Width: Integer) Success: Boolean
    var
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin
        if (MemberMedia.IsFeatureEnabled()) then
            exit(GetMemberImageThumbnailCloudflare(MemberEntryNo, Base64StringImage, Width));

        exit(GetMemberImageThumbnailLocalMedia(MemberEntryNo, Base64StringImage, Width));
    end;

    local procedure GetMemberImageThumbnailCloudflare(MemberEntryNo: Integer; var Base64StringImage: Text; Width: Integer) Success: Boolean
    var
        Member: Record "NPR MM Member";
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin

        Member.SetLoadFields(SystemId);
        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        case Width of
            70:
                Success := MemberMedia.GetMemberImageB64(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::SMALL, Base64StringImage);
            240:
                Success := MemberMedia.GetMemberImageB64(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::MEDIUM, Base64StringImage);
            360:
                Success := MemberMedia.GetMemberImageB64(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::LARGE, Base64StringImage);
            1024:
                Success := MemberMedia.GetMemberImageB64(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::PREVIEW, Base64StringImage);
            else
                Success := MemberMedia.GetMemberImageB64(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::THUMBNAIL, Base64StringImage);
        end;
        exit(Success);
    end;

    internal procedure GetMemberImageThumbnailUrl(MemberEntryNo: Integer; var ImageUrl: Text; Width: Integer) Success: Boolean
    var
        Member: Record "NPR MM Member";
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin

        Member.SetLoadFields(SystemId);
        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        case Width of
            70:
                Success := MemberMedia.GetMemberImageUrl(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::SMALL, 300, ImageUrl);
            240:
                Success := MemberMedia.GetMemberImageUrl(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::MEDIUM, 300, ImageUrl);
            360:
                Success := MemberMedia.GetMemberImageUrl(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::LARGE, 300, ImageUrl);
            1024:
                Success := MemberMedia.GetMemberImageUrl(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::PREVIEW, 300, ImageUrl);
            else
                Success := MemberMedia.GetMemberImageUrl(Member.SystemId, Enum::"NPR CloudflareMediaVariants"::THUMBNAIL, 300, ImageUrl);
        end;
        exit(Success);
    end;

    internal procedure GetMemberImageThumbnailLocalMedia(MemberEntryNo: Integer; var Base64StringImage: Text; Width: Integer): Boolean
    var
        Member: Record "NPR MM Member";
        MediaThumbnail: Record "Tenant Media Thumbnails";
        Base64Convert: Codeunit "Base64 Convert";
        InStr: InStream;
        Embedded: Boolean;
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        if (not Member.Image.HasValue()) then
            exit(false);

        if (not (Width in [70, 240, 360])) then
            Embedded := true;

        MediaThumbnail.SetFilter("Media ID", '=%1', Member.Image.MediaId());
        MediaThumbnail.SetFilter(Embedded, '=%1', Embedded);
        if (not Embedded) then
            MediaThumbnail.SetFilter(Width, '=%1', Width);

        if (not MediaThumbnail.FindFirst()) then
            exit(false);

        MediaThumbnail.CalcFields(Content);
        if (not MediaThumbnail.Content.HasValue()) then
            exit(false);

        MediaThumbnail.Content.CreateInStream(InStr);
        Base64StringImage := Base64Convert.ToBase64(InStr);
        exit(true);
    end;

    internal procedure UpdateMember(MembershipEntryNo: Integer; MemberEntryNo: Integer; MembershipInfoCapture: Record "NPR MM Member Info Capture") Success: Boolean
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        ErrorText: Text;
        CommunityCode: Code[20];
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        if (not Membership.Get(MembershipEntryNo)) then
            exit(false);

        if (CurrentClientType <> ClientType::SOAP) then // To not disturb the SOAP service that uses the same function 
            if (GetMemberCommunityCode(MemberEntryNo, CommunityCode)) then
                CheckMemberUniqueId(CommunityCode, MembershipInfoCapture);

        Member.Get(MemberEntryNo);
        SetMemberFields(Member, MembershipInfoCapture);
        ValidateMemberFields(Membership."Entry No.", Member, ErrorText);
        Member.Modify();

        if (MembershipInfoCapture."Guardian External Member No." <> '') then
            AddGuardianMember(MembershipEntryNo, MembershipInfoCapture."Guardian External Member No.", MembershipInfoCapture."GDPR Approval");

        TransferInfoCaptureAttributes(MembershipInfoCapture."Entry No.", Database::"NPR MM Member", Member."Entry No.");
        SynchronizeCustomerAndContact(Membership);
        exit(true);
    end;

    internal procedure UpdateMember(DataSubjectId: Text[64]; JsonMember: JsonObject; ImageB64: Text) Success: Boolean
    var
        MemberRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        MemberInfo: Record "NPR MM Member Info Capture";
        MembershipNotification: Record "NPR MM Membership Notific.";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        JToken: JsonToken;
        EntryNo: Integer;
    begin

        MemberRole.SetFilter("GDPR Data Subject Id", '=%1', CopyStr(DataSubjectId, 1, MaxStrLen(MemberRole."GDPR Data Subject Id")));
        if (not MemberRole.FindFirst()) then
            exit(false);

        if (not Member.Get(MemberRole."Member Entry No.")) then
            exit(false);

        if (JsonMember.Get('m', JToken)) then
            JsonMember := JToken.AsObject();

        // {"fn":"Tim","ln":"Sannes","ad":"Spaljevägen 9","pc":"197 36","ct":"Bro","cc":"SE","em":"tsa@navipartner.dk","pn":"0732542026"}
        MemberRetailIntegration.MemberJSonToMemberInfo(JsonMember, MemberInfo);

        MemberInfo."Notification Method" := Member."Notification Method";
        MemberInfo."Member Entry No" := MemberRole."Member Entry No.";
        if (not UpdateMember(MemberRole."Membership Entry No.", MemberRole."Member Entry No.", MemberInfo)) then
            exit(false);

        if (StrLen(ImageB64) > 100) then
            if (not UpdateMemberImage(MemberRole."Member Entry No.", ImageB64)) then
                exit(false);

        if (MemberRole."Wallet Pass Id" <> '') then
            EntryNo := MemberNotification.CreateUpdateWalletNotification(MemberRole."Membership Entry No.", MemberRole."Member Entry No.", 0, Today());

        if (MemberRole."Wallet Pass Id" = '') then
            EntryNo := MemberNotification.CreateWalletSendNotification(MemberRole."Membership Entry No.", MemberRole."Member Entry No.", 0, Today());

        if (MembershipNotification.Get(EntryNo)) then
            if (MembershipNotification."Processing Method" = MembershipNotification."Processing Method"::INLINE) then
                MemberNotification.HandleMembershipNotification(MembershipNotification);

        exit(true);
    end;

    internal procedure UpdateMemberImage(MemberEntryNo: Integer; Base64StringImage: Text) Success: Boolean
    var
        OutStr: OutStream;
        InStr: InStream;
        Member: Record "NPR MM Member";
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        Base64Start: Integer;
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin
        if (not Member.Get(MemberEntryNo)) then
            exit(false);

        if (MemberMedia.IsFeatureEnabled()) then
            exit(MemberMedia.PutMemberImageB64(Member.SystemId, '', Base64StringImage));

        Base64Start := 1;
        // Remove mime type prefix
        if (StrLen(Base64StringImage) > 10) then
            if (CopyStr(Base64StringImage, 1, 5) = 'data:') then
                Base64Start := StrPos(Base64StringImage, ',') + 1;

        TempBlob.CreateOutStream(OutStr);
        Base64Convert.FromBase64(CopyStr(Base64StringImage, Base64Start), OutStr);
        TempBlob.CreateInStream(InStr);
        Member.Image.ImportStream(InStr, Member.FieldName(Image));
        exit(Member.Modify());

    end;

    internal procedure UpdateMemberPassword(MemberEntryNo: Integer; UserLogonID: Code[50]; NewPassword: Text[50]) Success: Boolean
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

    internal procedure FindMembershipUsing(SearchMethod: Code[20]; Key1: Text[100]; Key2: Text[100]) MembershipEntryNo: Integer
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
                exit(GetMembershipFromExtCardNo(CopyStr(Key1, 1, MaxStrLen(MemberCard."External Card No.")), WorkDate(), NotFoundReasonText));
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

    internal procedure GetMembershipValidDate(MembershipEntryNo: Integer; ReferenceDate: Date; var ValidFromDate: Date; var ValidUntilDate: Date) IsValid: Boolean
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
            ReferenceDate := Today();

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

    internal procedure GetMembershipMaxValidUntilDate(MembershipEntryNo: Integer; var MaxValidUntilDate: Date): Boolean
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

    internal procedure GetConsecutiveTimeFrame(MembershipEntryNo: Integer; ReferenceDate: Date; var FromDate: Date; var UntilDate: Date): Boolean;
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
            ReferenceDate := Today();

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

    internal procedure IsMembershipActive(MemberShipEntryNo: Integer; ReferenceDate: Date; WithActivate: Boolean) IsActive: Boolean
    var
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        if (WithActivate) then begin
            ActivateMembershipLedgerEntry(MemberShipEntryNo, ReferenceDate);
        end;

        exit(GetMembershipValidDate(MemberShipEntryNo, ReferenceDate, ValidFromDate, ValidUntilDate));
    end;

    internal procedure IsMemberCardActive(ExternalCardNo: Text[100]; ReferenceDate: Date): Boolean
    var
        CardEntryNo: Integer;
        MemberCard: Record "NPR MM Member Card";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        MemberCard.Reset();
        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetFilter(Blocked, '=%1', false);
        MemberCard.SetFilter("External Card No.", '=%1 | =%2', ExternalCardNo, EncodeSHA1(ExternalCardNo));

        if (not MemberCard.FindFirst()) then begin
            GetMembershipFromForeignCardNo(ExternalCardNo, ReferenceDate, CardEntryNo);
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

    internal procedure IssueMemberCard(MemberInfoCapture: Record "NPR MM Member Info Capture"; var CardEntryNo: Integer; var ResponseMessage: Text): Boolean
    var
        Member: Record "NPR MM Member";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
    begin

        // from external
        if (not IssueMemberCardWorker(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture, true, CardEntryNo, ResponseMessage, false)) then
            exit(false);

        if (MemberInfoCapture.Image.HasValue()) then begin
            if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                TempBlob.CreateOutStream(OutStr);
                MemberInfoCapture.Image.ExportStream(OutStr);
                TempBlob.CreateInStream(InStr);
                Member.Image.ImportStream(InStr, Member.FieldName(Image));
                Member.Modify();
            end;
        end;

        exit(CardEntryNo <> 0);
    end;

    internal procedure ValidateMemberFirstName(Member: Record "NPR MM Member") ConflictsWithMemberEntryNo: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Community: Record "NPR MM Member Community";
        CommunityCode: Code[20];
    begin
        if (not GetMemberCommunityCode(Member."Entry No.", CommunityCode)) then
            exit;

        Community.Get(CommunityCode);
        if (not (Community."Member Unique Identity" in [Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME])) then
            exit;

        MemberInfoCapture.Init();
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        MemberInfoCapture."Member Entry No" := Member."Entry No.";
        MemberInfoCapture."First Name" := Member."First Name";
        MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";
        ConflictsWithMemberEntryNo := CheckMemberUniqueId(CommunityCode, MemberInfoCapture);
    end;

    internal procedure ValidateMemberPhoneNumber(Member: Record "NPR MM Member") ConflictsWithMemberEntryNo: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Community: Record "NPR MM Member Community";
        CommunityCode: Code[20];
    begin
        if (not GetMemberCommunityCode(Member."Entry No.", CommunityCode)) then
            exit;

        Community.Get(CommunityCode);
        if (not (Community."Member Unique Identity" in [Community."Member Unique Identity"::PHONENO,
                                                        Community."Member Unique Identity"::EMAIL_AND_PHONE,
                                                        Community."Member Unique Identity"::EMAIL_OR_PHONE])) then
            exit;

        MemberInfoCapture.Init();
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        MemberInfoCapture."Member Entry No" := Member."Entry No.";
        MemberInfoCapture."Phone No." := Member."Phone No.";
        MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";
        ConflictsWithMemberEntryNo := CheckMemberUniqueId(CommunityCode, MemberInfoCapture);
    end;

    internal procedure ValidateMemberEmail(Member: Record "NPR MM Member") ConflictsWithMemberEntryNo: Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Community: Record "NPR MM Member Community";
        CommunityCode: Code[20];
    begin
        if (not GetMemberCommunityCode(Member."Entry No.", CommunityCode)) then
            exit;

        Community.Get(CommunityCode);
        if (not (Community."Member Unique Identity" in [Community."Member Unique Identity"::EMAIL,
                                                        Community."Member Unique Identity"::EMAIL_AND_PHONE,
                                                        Community."Member Unique Identity"::EMAIL_OR_PHONE,
                                                        Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME])) then
            exit;

        MemberInfoCapture.Init();
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::NEW;
        MemberInfoCapture."Member Entry No" := Member."Entry No.";
        MemberInfoCapture."Phone No." := Member."Phone No.";
        MemberInfoCapture."First Name" := Member."First Name";
        MemberInfoCapture."E-Mail Address" := Member."E-Mail Address";
        ConflictsWithMemberEntryNo := CheckMemberUniqueId(CommunityCode, MemberInfoCapture);
    end;

    internal procedure CheckMemberUniqueId(CommunityCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture") MemberEntryNo: Integer
    var
        Community: Record "NPR MM Member Community";
        Member: Record "NPR MM Member";
        MEMBER_REUSE: Label 'Member with unique ID [%1] with name: %2 is already in use.\Do you want to create duplicate member?';
        ConflictingMemberExists: Boolean;
        ResponseMessage: Text;
    begin

        if (not Community.Get(CommunityCode)) then
            exit(-1);

        if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then begin
            Member.SetFilter("External Member No.", '=%1', MemberInfoCapture."External Member No");
            if (not Member.FindFirst()) then
                exit(0);
            exit(Member."Entry No.");
        end;

        SetMemberUniqueIdFilter(Community, MemberInfoCapture, Member);
        ConflictingMemberExists := Member.FindFirst();

        MembershipEvents.OnCheckMemberUniqueIdViolation(Community, MemberInfoCapture, Member, ConflictingMemberExists);

        if (ConflictingMemberExists) then begin
            if ((MemberInfoCapture."Guardian External Member No." <> '') and
                (MemberInfoCapture."Guardian External Member No." = Member."External Member No.")) then
                exit(0);

            case Community."Create Member UI Violation" of
                Community."Create Member UI Violation"::Error:
                    RaiseError(ResponseMessage, StrSubstNo(MEMBER_WITH_UID_EXISTS, Member.GetFilters(), Member."Display Name"), MEMBER_WITH_UID_EXISTS_NO);

                Community."Create Member UI Violation"::Confirm:
                    begin
                        if (MemberInfoCapture.AcceptDuplicate) then
                            exit(0);

                        if (GuiAllowed()) then
                            if (not Confirm(MEMBER_REUSE, false, Member.GetFilters(), Member."Display Name")) then
                                Error(ABORTED);

                        MemberInfoCapture.AcceptDuplicate := true;
                        exit(0);
                    end;

                Community."Create Member UI Violation"::REUSE:
                    MemberInfoCapture.AcceptDuplicate := true;

                Community."Create Member UI Violation"::MERGE_MEMBER:
                    // UI operations handle this differently by selecting data from the conflicting member
                    // Note that a user may change the unique id fields in the UI before confirming, so cannot merge here.
                    if (not GuiAllowed()) then begin
                        if (not MemberInfoCapture.AllowMergeOnConflict) then
                            RaiseError(ResponseMessage, ALLOW_MEMBER_MERGE_NOT_SET, ALLOW_MEMBER_MERGE_NOT_SET_NO);
                        if (Member.Get(MemberInfoCapture."Member Entry No")) then
                            MergeMemberUniqueId(Member, MemberInfoCapture."First Name", MemberInfoCapture."E-Mail Address", MemberInfoCapture."Phone No.", MemberInfoCapture."External Member No");
                    end;
                else
                    Error(CASE_MISSING, Community.FieldName("Create Member UI Violation"), Community."Create Member UI Violation");
            end;

            exit(Member."Entry No.");
        end;

        if (not ConflictingMemberExists) then
            if ((MemberInfoCapture."Member Entry No" <> 0)
                and (Community."Create Member UI Violation" in [Community."Create Member UI Violation"::REUSE, Community."Create Member UI Violation"::MERGE_MEMBER])) then
                exit(MemberInfoCapture."Member Entry No");

        exit(0);
    end;


    internal procedure SetMemberUniqueIdFilter(Community: Record "NPR MM Member Community"; MemberInfoCapture: Record "NPR MM Member Info Capture"; var Member: Record "NPR MM Member")
    var
        RequireField: Label '%1 is required.';
        RequireFieldOrField: Label 'Either %1 or %2 is required.';
        RequireFieldAndField: Label 'Both %1 and %2 are required.';
        FiltersAreSet: Boolean;
    begin
        Member.FilterGroup(240);
        Member.SetFilter(Blocked, '=%1', false);
        if (MemberInfoCapture."Member Entry No" <> 0) then
            Member.SetFilter("Entry No.", '<>%1', MemberInfoCapture."Member Entry No");
        Member.FilterGroup(0);

        FiltersAreSet := false;
        MembershipEvents.OnSetMemberUniqueIdFilter(Community, MemberInfoCapture, Member, FiltersAreSet);
        if (FiltersAreSet) then
            exit;

        case Community."Member Unique Identity" of
            Community."Member Unique Identity"::NONE:
                Member.SetFilter("Entry No.", '=%1', -1); // This should never match a current user
            Community."Member Unique Identity"::EMAIL:
                begin
                    if (MemberInfoCapture."E-Mail Address" = '') then
                        Error(RequireField, MemberInfoCapture.FieldCaption("E-Mail Address"));
                    Member.SetFilter("E-Mail Address", '=%1', LowerCase(MemberInfoCapture."E-Mail Address"));
                end;
            Community."Member Unique Identity"::PHONENO:
                begin
                    if (MemberInfoCapture."Phone No." = '') then
                        Error(RequireField, MemberInfoCapture.FieldCaption("Phone No."));
                    Member.SetFilter("Phone No.", '=%1', MemberInfoCapture."Phone No.");
                end;
            Community."Member Unique Identity"::SSN:
                begin
                    if (MemberInfoCapture."Social Security No." = '') then
                        Error(RequireField, MemberInfoCapture.FieldCaption("Social Security No."));
                    Member.SetFilter("Social Security No.", '=%1', MemberInfoCapture."Social Security No.");
                end;
            Community."Member Unique Identity"::EMAIL_AND_PHONE:
                begin
                    if ((MemberInfoCapture."E-Mail Address" = '') or (MemberInfoCapture."Phone No." = '')) then
                        Error(RequireFieldAndField, MemberInfoCapture.FieldCaption("E-Mail Address"), MemberInfoCapture.FieldCaption("Phone No."));
                    Member.SetCurrentKey("E-Mail Address");
                    Member.SetFilter("E-Mail Address", '=%1', LowerCase(MemberInfoCapture."E-Mail Address"));
                    Member.SetFilter("Phone No.", '=%1', MemberInfoCapture."Phone No.");
                end;
            Community."Member Unique Identity"::EMAIL_OR_PHONE:
                begin
                    if ((MemberInfoCapture."E-Mail Address" = '') and (MemberInfoCapture."Phone No." = '')) then
                        Error(RequireFieldOrField, MemberInfoCapture.FieldCaption("E-Mail Address"), MemberInfoCapture.FieldCaption("Phone No."));

                    if ((MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." = '')) then
                        Member.SetFilter("E-Mail Address", '=%1', LowerCase(MemberInfoCapture."E-Mail Address"));

                    if ((MemberInfoCapture."E-Mail Address" = '') and (MemberInfoCapture."Phone No." <> '')) then
                        Member.SetFilter("Phone No.", '=%1', MemberInfoCapture."Phone No.");

                    if ((MemberInfoCapture."E-Mail Address" <> '') and (MemberInfoCapture."Phone No." <> '')) then begin
                        Member.FilterGroup(-1);
                        Member.SetFilter("E-Mail Address", '=%1', LowerCase(MemberInfoCapture."E-Mail Address"));
                        Member.SetFilter("Phone No.", '=%1', MemberInfoCapture."Phone No.");
                    end;
                end;
            Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME:
                begin
                    if ((MemberInfoCapture."E-Mail Address" = '') or (MemberInfoCapture."First Name" = '')) then
                        Error(RequireFieldAndField, MemberInfoCapture.FieldCaption("E-Mail Address"), MemberInfoCapture.FieldCaption("First Name"));
                    Member.SetCurrentKey("E-Mail Address");
                    Member.SetFilter("E-Mail Address", '=%1', LowerCase(MemberInfoCapture."E-Mail Address"));
                    Member.SetFilter("First Name", '%1', '@' + MemberInfoCapture."First Name");
                end;
            else
                Error(CASE_MISSING, Community.FieldName("Member Unique Identity"), Community."Member Unique Identity");
        end;
    end;

    internal procedure BlockMembership(MembershipEntryNo: Integer; Block: Boolean)
    var
        Membership: Record "NPR MM Membership";
        MembershipRole, MembershipRole2 : Record "NPR MM Membership Role";
        MembersToHandle: List of [Integer];
        MembershipRolesToHandle: List of [Integer];
        MemberEntryNo: Integer;
    begin
        Membership.Get(MembershipEntryNo);

        // (Un)block anonymous cards in this membership
        BlockMemberCards(MembershipEntryNo, 0, Block);

        // All roles in this membership
        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if MembershipRole.FindSet() then begin
            MembershipRole2.SetCurrentKey("Member Entry No.");
            MembershipRole2.SetFilter("Membership Entry No.", '<>%1', MembershipEntryNo);

            repeat
                // Look for roles in other memberships with the opposite block state
                MembershipRole2.SetFilter("Member Entry No.", '=%1', MembershipRole."Member Entry No.");
                MembershipRole2.SetFilter(Blocked, '=%1', not Block);

                if MembershipRole2.IsEmpty() then
                    // No conflicting roles in other memberships → (un)block member
                    MembersToHandle.Add(MembershipRole."Member Entry No.")
                else
                    // Conflicting roles exist → only (un)block this membership role
                    MembershipRolesToHandle.Add(MembershipRole."Member Entry No.");
            until MembershipRole.Next() = 0;
        end;

        // (Un)block members that have no conflicting roles in other memberships
        foreach MemberEntryNo in MembersToHandle do
            BlockMember(MembershipEntryNo, MemberEntryNo, Block);

        // (Un)block roles + cards in this membership for members that stay mixed across memberships
        foreach MemberEntryNo in MembershipRolesToHandle do
            if MembershipRole.Get(MembershipEntryNo, MemberEntryNo) then begin
                BlockMemberCards(MembershipEntryNo, MemberEntryNo, Block);
                if MembershipRole.Blocked <> Block then begin
                    MembershipRole.Validate(Blocked, Block);
                    MembershipRole.Modify();
                end;
            end;

        // Finally (un)block the membership itself
        if Membership.Blocked <> Block then begin
            Membership.Validate(Blocked, Block);
            Membership.Modify();
        end;
    end;


    internal procedure ReflectMembershipRoles(MembershipEntryNo: Integer; MemberEntryNo: Integer; Blocked: Boolean)
    var
        MembershipRole: Record "NPR MM Membership Role";
        MembershipRole2: Record "NPR MM Membership Role";
        MembershipSetup: Record "NPR MM Membership Setup";
        GDPRManagement: Codeunit "NPR GDPR Management";
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

    internal procedure BlockMember(MembershipEntryNo: Integer; MemberEntryNo: Integer; Block: Boolean)
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

        MembershipEvents.OnAfterBlockMember(MemberEntryNo);
    end;

    internal procedure BlockMemberCards(MembershipEntryNo: Integer; MemberEntryNo: Integer; Block: Boolean)
    var
        MemberCard: Record "NPR MM Member Card";
    begin

        MemberCard.SetCurrentKey("Membership Entry No.", "Member Entry No.");
        MemberCard.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MemberCard.FindSet()) then begin
            repeat
                BlockMemberCard(MemberCard."Entry No.", Block);
            until (MemberCard.Next() = 0);
        end;
    end;

    internal procedure BlockMemberCard(CardEntryNo: Integer; Block: Boolean)
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

    internal procedure CreateRegretMemberInfoRequest(ExternalMemberCardNo: Text[100]; RegretWithItemNo: Code[20]) MemberInfoEntryNo: Integer
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

        MemberInfoCapture."Document Date" := Today();
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::REGRET;

        if (not RegretMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    internal procedure RegretMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal) Success: Boolean
    var
        ReasonText: Text;
    begin

        exit(RegretMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    internal procedure RegretMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text) Success: Boolean
    begin

        exit(RegretMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure RegretMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        PlaceHolderLbl: Label '%1: %2 {%3 .. %4}', Locked = true;
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today();

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
                ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption(), MembershipEntry.GetFilters());
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

        if ((WithConfirm) and (GuiAllowed()) and (MembershipEntry.Context <> MembershipEntry.Context::REGRET)) then begin
            if (Membership."Auto-Renew" = Membership."Auto-Renew"::NO) then
                if (not Confirm(CONFIRM_REGRET, false, Membership."External Membership No.", MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date")) then
                    exit(false);
            if (Membership."Auto-Renew" <> Membership."Auto-Renew"::NO) then
                if (not Confirm(CONFIRM_REGRET_AUTO_RENEW, false, Membership."External Membership No.", MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date")) then
                    exit(false);
        end;

        if ((WithConfirm) and (GuiAllowed()) and (MembershipEntry.Context = MembershipEntry.Context::REGRET)) then
            if (not Confirm(CONFIRM_REGRET_UNDO, false, Membership."External Membership No.", MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date")) then
                exit(false);


        ReasonText := StrSubstNo(PlaceHolderLbl, MemberInfoCapture."Information Context", MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");

        if (WithUpdate) then begin
            RegretSubscription(Membership);
            MembershipEntryLink.CreateMembershipEntryLink(MembershipEntry, MemberInfoCapture, 0D);
            CarryOutMembershipRegret(MembershipEntry);
        end;

        OutStartDate := MembershipEntry."Valid From Date";
        OutUntilDate := MembershipEntry."Valid Until Date";

        exit(true);
    end;

    internal procedure CarryOutMembershipRegret(var MembershipEntry: Record "NPR MM Membership Entry")
    begin
        if (MembershipEntry.Context = MembershipEntry.Context::REGRET) then begin
            DoReverseRegretTimeFrame(MembershipEntry);
        end else begin
            DoRegretTimeframe(MembershipEntry);
        end;
    end;

    local procedure DoReverseRegretTimeFrame(var MembershipEntry: Record "NPR MM Membership Entry")
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin

        if (not ((MembershipEntry.Context = MembershipEntry.Context::REGRET) and (MembershipEntry."Original Context" = MembershipEntry."Original Context"::NEW))) then
            Error('Only the initial new transaction may be reverse regretted.');

        MembershipEntry.Context := MembershipEntry."Original Context";
        MembershipEntry.Validate(Blocked, false);
        MembershipEntry.Modify();

        SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(MembershipEntry);

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipEntry);

        OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
    end;

    internal procedure DoRegretTimeframe(var MembershipEntry: Record "NPR MM Membership Entry")
    var
        Membership: Record "NPR MM Membership";
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin

        // Note - also invoked from MM Member WebService Mgr
        if (MembershipEntry.Context = MembershipEntry.Context::AUTORENEW) then
            MembershipAutoRenew.ReverseInvoice(MembershipEntry."Document No.");

        MembershipEntry."Original Context" := MembershipEntry.Context;
        MembershipEntry.Context := MembershipEntry.Context::REGRET;
        MembershipEntry.Validate(Blocked, true);
        MembershipEntry.Modify();

        if MembershipEntry."Original Context" in [MembershipEntry."Original Context"::NEW, MembershipEntry."Original Context"::RENEW, MembershipEntry."Original Context"::AUTORENEW, MembershipEntry."Original Context"::EXTEND] then begin
            Membership.Get(MembershipEntry."Membership Entry No.");
            if not Membership.Blocked then
                DisableMembershipAutoRenewal(Membership, true, false);
        end;

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
        SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(MembershipEntry);
        OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");

    end;

    internal procedure CreateCancelMemberInfoRequest(ExternalMemberCardNo: Text[100]; CancelWithItemNo: Code[20]): Integer
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
        MemberInfoCapture."Document Date" := Today(); // Active

        if (not CancelMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    internal procedure CancelMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(CancelMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    internal procedure CancelMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(CancelMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure CancelMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipEntryLink: Record "NPR MM Membership Entry Link";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Subscription: Record "NPR MM Subscription";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        IPriceHandler: Interface "NPR IMemberAlterationPriceHandler";
        Item: Record Item;
        EndDateNew: Date;
        CancelledFraction: Decimal;
        PlaceHolderLbl: Label '%1: %2 {%3 .. %4}', Locked = true;
    begin

        OutStartDate := 0D;
        OutUntilDate := 0D;
        SuggestedUnitPrice := 0;

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today();

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if (not MembershipEntry.FindLast()) then begin
            ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption(), MembershipEntry.GetFilters());
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

        if (SubscriptionMgtImpl.GetSubscriptionFromMembership(MemberInfoCapture."Membership Entry No.", Subscription)) then
            if (
                (Subscription."Auto-Renew" = Subscription."Auto-Renew"::YES_INTERNAL) and
                (Subscription."Committed Until" > EndDateNew)
            ) then
                EndDateNew := Subscription."Committed Until";

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

        if (_FeatureFlag.IsEnabled(PriceCalcInterfaceTok)) then begin
            IPriceHandler := MembershipAlterationSetup."Price Calculation";
            SuggestedUnitPrice := IPriceHandler.CalculateCancelAlterationPrice(MembershipAlterationSetup, MemberInfoCapture, MembershipEntry, EndDateNew);
        end else begin
            CancelledFraction := 1 - CalculatePeriodStartToDateFraction(MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date", EndDateNew);
            case MembershipAlterationSetup."Price Calculation" of
                MembershipAlterationSetup."Price Calculation"::UNIT_PRICE:
                    SuggestedUnitPrice := -1 * MembershipEntry."Unit Price";
                MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE:
                    SuggestedUnitPrice := Round(-CancelledFraction * MembershipEntry."Unit Price", 1);
                MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE:
                    SuggestedUnitPrice := 0;
            end;
        end;

        ReasonText := StrSubstNo(PlaceHolderLbl, MemberInfoCapture."Information Context", MembershipEntry.Context, MembershipEntry."Valid From Date", MembershipEntry."Valid Until Date");

        if (WithUpdate) then begin
            RegretSubscription(Membership);
            MembershipEntryLink.CreateMembershipEntryLink(MembershipEntry, MemberInfoCapture, EndDateNew);
            CarryOutMembershipCancel(Membership, MembershipEntry, EndDateNew);
        end;

        OutStartDate := MembershipEntry."Valid From Date";
        OutUntilDate := EndDateNew;

        exit(true);
    end;

    internal procedure CarryOutMembershipCancel(var Membership: Record "NPR MM Membership"; var MembershipEntry: Record "NPR MM Membership Entry"; EndDateNew: Date)
    var
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        MembershipEntry."Valid Until Date" := EndDateNew;
        MembershipEntry.Modify();

        DisableMembershipAutoRenewal(Membership, true, false);
        SubscriptionMgtImpl.UpdateSubscriptionValidUntilDateFromMembershipEntry(MembershipEntry);

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipEntry);

        OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
    end;

    internal procedure CreateRenewMemberInfoRequest(ExternalMemberCardNo: Text[100]; RenewWithItemNo: Code[20]): Integer
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

        if (MembershipEntry."Activate On First Use") then
            Error(NOT_ACTIVATED);

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        PrefillMemberInfoCapture(MemberInfoCapture, Member, Membership, ExternalMemberCardNo, RenewWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::RENEW;
        MemberInfoCapture."Document Date" := Today(); // Active

        if (not RenewMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    internal procedure RenewMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(RenewMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    internal procedure RenewMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(RenewMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure RenewMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        IPriceHandler: Interface "NPR IMemberAlterationPriceHandler";
        Item: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EntryNo: Integer;
        PlaceHolderLbl: Label '%1: %4 -> %5 {%2 .. %3}', Locked = true;
        MembershipScheduledForUpdate: Boolean;
        TargetMembershipCode: Code[20];
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today();

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);

        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption(), MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(NOT_FOUND, MembershipAlterationSetup.TableCaption(), '');
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
                StartDateNew := Today();

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

        if WithUpdate then
            RegretSubscription(Membership);

        if (MembershipAlterationSetup."To Membership Code" <> '') then
            if (not (ValidateChangeMembershipCode(WithConfirm, Membership."Entry No.", MembershipAlterationSetup."To Membership Code", ReasonText))) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (not CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, MemberInfoCapture."Document Date", StartDateNew, EndDateNew, ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (_FeatureFlag.IsEnabled(PriceCalcInterfaceTok)) then begin
            IPriceHandler := MembershipAlterationSetup."Price Calculation";
            SuggestedUnitPrice := IPriceHandler.CalculateRenewAlterationPrice(MembershipAlterationSetup, MemberInfoCapture, MembershipEntry);
        end else begin
            case MembershipAlterationSetup."Price Calculation" of
                MembershipAlterationSetup."Price Calculation"::UNIT_PRICE:
                    SuggestedUnitPrice := Item."Unit Price";
                MembershipAlterationSetup."Price Calculation"::PRICE_DIFFERENCE:
                    SuggestedUnitPrice := Item."Unit Price";
                MembershipAlterationSetup."Price Calculation"::TIME_DIFFERENCE:
                    SuggestedUnitPrice := Item."Unit Price";
            end;

            SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration(Membership."Entry No.", MembershipAlterationSetup);
        end;

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(PlaceHolderLbl, MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code");

        if (WithUpdate) then begin
            MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";

            TargetMembershipCode := Membership."Membership Code";
            if (MembershipAlterationSetup."To Membership Code" <> '') then
                TargetMembershipCode := MembershipAlterationSetup."To Membership Code";

            if MemberInfoCapture."Enable Auto-Renew" then
                EnableMembershipInternalAutoRenewal(Membership, TargetMembershipCode, true, false);

            if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", TargetMembershipCode, ReasonText)) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

            MemberInfoCapture."Membership Code" := TargetMembershipCode;
            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew, MembershipScheduledForUpdate);

            if (not MembershipScheduledForUpdate) then begin
                Membership.Get(MemberInfoCapture."Membership Entry No.");
                if (Membership."Membership Code" <> TargetMembershipCode) then begin
                    Membership."Membership Code" := TargetMembershipCode;
                    Membership.Modify();
                end;
            end;

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    internal procedure CreateExtendMemberInfoRequest(ExternalMemberCardNo: Text[100]; RenewWithItemNo: Code[20]): Integer
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
        MemberInfoCapture."Document Date" := Today(); // Active

        if (not ExtendMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    internal procedure ExtendMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(ExtendMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    internal procedure ExtendMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; ReasonText: Text): Boolean
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
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        IPriceHandler: Interface "NPR IMemberAlterationPriceHandler";
        StartDateNew: Date;
        EndDateNew: Date;
        EndDateCurrent: Date;
        EntryNo: Integer;
        CancelledFraction: Decimal;
        NewFraction: Decimal;
        StartDateLedgerEntryNo: Integer;
        EndDateLedgerEntryNo: Integer;
        PlaceHolderLbl: Label '%1: %4 -> %5 {%2 .. %3}', Locked = true;
        MembershipScheduledForUpdate: Boolean;
    begin

        OutStartDate := 0D;
        OutUntilDate := 0D;
        SuggestedUnitPrice := 0;

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today();

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption(), MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(NOT_FOUND, MembershipAlterationSetup.TableCaption(), '');
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

        if WithUpdate then
            RegretSubscription(Membership);

        if (MembershipAlterationSetup."To Membership Code" <> '') then
            if (not (ValidateChangeMembershipCode(WithConfirm, Membership."Entry No.", MembershipAlterationSetup."To Membership Code", ReasonText))) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (MembershipEntry."Unit Price (Base)" = 0) then begin
            OldItem.Get(MembershipEntry."Item No.");
            MembershipEntry."Unit Price (Base)" := OldItem."Unit Price";
        end;

        if (not CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, MemberInfoCapture."Document Date", StartDateNew, EndDateNew, ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (_FeatureFlag.IsEnabled(PriceCalcInterfaceTok)) then begin
            IPriceHandler := MembershipAlterationSetup."Price Calculation";
            SuggestedUnitPrice := IPriceHandler.CalculateExtendAlterationPrice(MembershipAlterationSetup, MemberInfoCapture, MembershipEntry, StartDateNew, EndDateNew);
        end else begin
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
        end;

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(PlaceHolderLbl, MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code");

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

            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew, MembershipScheduledForUpdate);

            if (EndDateCurrent <> 0D) then begin
                if (EndDateCurrent <= MembershipEntry."Valid From Date") then begin
                    MembershipEntry.Blocked := true;
                    MembershipEntry."Blocked At" := CurrentDateTime();
                    MembershipEntry."Blocked By" := CopyStr(UserId(), 1, MaxStrLen(MembershipEntry."Blocked By"));
                end else begin
                    MembershipEntry."Valid Until Date" := EndDateCurrent;
                end;
                MembershipEntry."Closed By Entry No." := EntryNo;
                MembershipEntry.Modify();
                SubscriptionMgtImpl.UpdateSubscriptionPeriodFromMembership(MembershipEntry."Entry No.");
            end;

            OnMembershipChangeEvent(MembershipEntry."Membership Entry No.");
        end;

        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    internal procedure CreateUpgradeMemberInfoRequest(ExternalMemberCardNo: Text[100]; UpgradeWithItemNo: Code[20]): Integer
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

        PrefillMemberInfoCapture(MemberInfoCapture, Member, Membership, ExternalMemberCardNo, UpgradeWithItemNo);
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::UPGRADE;
        MemberInfoCapture."Document Date" := Today(); // Active

        if (not UpgradeMembership(MemberInfoCapture, true, false, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price")) then
            Error('');

        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    internal procedure UpgradeMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin

        exit(UpgradeMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    internal procedure UpgradeMembershipVerbose(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin

        exit(UpgradeMembershipWorker(MemberInfoCapture, WithConfirm, WithUpdate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure UpgradeMembershipWorker(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        IPriceHandler: Interface "NPR IMemberAlterationPriceHandler";
        Item: Record Item;
        OldItem: Record Item;
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
        StartDateNew: Date;
        EndDateCurrent: Date;
        EndDateNew: Date;
        EntryNo: Integer;
        RemainingFraction: Decimal;
        ValidFromDate: Date;
        PlaceHolderLbl: Label '%1: %4 -> %5 {%2 .. %3} {%6 {%7,%8} -> %9}', Locked = true;
        MembershipScheduledForUpdate: Boolean;
        TargetMembershipCode: Code[20];
    begin

        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := Today();

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption(), MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(NOT_FOUND, MembershipAlterationSetup.TableCaption(), '');
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

        if WithUpdate then
            RegretSubscription(Membership);

        if (not (ValidateChangeMembershipCode(WithConfirm, Membership."Entry No.", MembershipAlterationSetup."To Membership Code", ReasonText))) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (MembershipEntry."Unit Price (Base)" = 0) then begin
            OldItem.Get(MembershipEntry."Item No.");
            MembershipEntry."Unit Price (Base)" := OldItem."Unit Price";
        end;
        ValidFromDate := GetUpgradeInitialValidFromDate(MembershipEntry."Entry No.");

        if (not CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, MemberInfoCapture."Document Date", StartDateNew, EndDateNew, ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        if (_FeatureFlag.IsEnabled(PriceCalcInterfaceTok)) then begin
            IPriceHandler := MembershipAlterationSetup."Price Calculation";
            SuggestedUnitPrice := IPriceHandler.CalculateUpgradeAlterationPrice(MembershipAlterationSetup, MemberInfoCapture, MembershipEntry, ValidFromDate, StartDateNew, EndDateNew);
        end else begin
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
        end;

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(ExitFalseOrWithError(WithConfirm, ReasonText));

        ReasonText := StrSubstNo(PlaceHolderLbl,
                                  MemberInfoCapture."Information Context", StartDateNew, EndDateNew, Membership."Membership Code", MembershipAlterationSetup."To Membership Code",
                                  Round(RemainingFraction, 0.01), Item."Unit Price", MembershipEntry."Unit Price (Base)", Round(SuggestedUnitPrice, 0.01));

        if (WithUpdate) then begin
            MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";

            TargetMembershipCode := Membership."Membership Code";
            if (MembershipAlterationSetup."To Membership Code" <> '') then
                TargetMembershipCode := MembershipAlterationSetup."To Membership Code";

            MemberInfoCapture."Membership Code" := TargetMembershipCode;

            if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", TargetMembershipCode, ReasonText)) then
                exit(ExitFalseOrWithError(WithConfirm, ReasonText));

            EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, StartDateNew, EndDateNew, MembershipScheduledForUpdate);

            MembershipEntry."Valid Until Date" := EndDateCurrent;
            MembershipEntry."Closed By Entry No." := EntryNo;
            MembershipEntry.Modify();

            if (not MembershipScheduledForUpdate) then begin
                Membership.Get(MemberInfoCapture."Membership Entry No.");
                if (Membership."Membership Code" <> TargetMembershipCode) then begin
                    Membership."Membership Code" := TargetMembershipCode;
                    Membership.Modify();
                end;
            end;

            SubscriptionMgtImpl.UpdateSubscriptionPeriodFromMembership(MembershipEntry."Membership Entry No.");

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

    internal procedure GetUpgradeInitialValidUntilDate(EntryNo: Integer) ValidUntil: Date
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

    internal procedure CalculateRemainingAmount(MembershipEntry: Record "NPR MM Membership Entry"; var OriginalAmountLCY: Decimal; var RemainingAmountLCY: Decimal; var DueDate: Date): Boolean
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

    internal procedure CreateAutoRenewMemberInfoRequest(MembershipEntryNo: Integer; RenewWithItemNo: Code[20]; var ReasonText: Text): Integer
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        AlterationRuleSystemId: Guid;
        PlaceHolder2Lbl: Label '%1 with %2', Locked = true;
    begin

        if (not Membership.Get(MembershipEntryNo)) then begin
            ReasonText := StrSubstNo(NOT_FOUND, Membership.TableCaption(), MembershipEntryNo);
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

        if (not SelectAutoRenewRule(MembershipEntry, RenewWithItemNo, AlterationRuleSystemId, ReasonText)) then
            exit(0);

        if (not MembershipAlterationSetup.GetBySystemId(AlterationRuleSystemId)) then begin
            ReasonText := StrSubstNo(NOT_FOUND, 'Auto-Renew item', StrSubstNo(PlaceHolder2Lbl, MembershipEntry.Context::AUTORENEW, RenewWithItemNo));
            exit(0);
        end;

        MemberInfoCapture.Init();
        MemberInfoCapture."Entry No." := 0;

        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."Membership Code" := MembershipAlterationSetup."From Membership Code";

        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Item No." := RenewWithItemNo;
        MemberInfoCapture."Information Context" := MemberInfoCapture."Information Context"::AUTORENEW;
        MemberInfoCapture."Document Date" := Today(); // Active
        MemberInfoCapture.Description := MembershipAlterationSetup.Description;

        if (not AutoRenewMembershipWorker(MemberInfoCapture, false, Today(), MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price", ReasonText)) then
            exit(0);

        MemberInfoCapture."Valid Until" := MembershipStartDate;
        MemberInfoCapture.Insert();
        exit(MemberInfoCapture."Entry No.");
    end;

    internal procedure SelectAutoRenewRule(MembershipEntry: Record "NPR MM Membership Entry"; var RenewWithItemNo: Code[20]; var AlterationRuleSystemId: Guid; var ReasonText: Text): Boolean
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipSetup: Record "NPR MM Membership Setup";
        Membership: Record "NPR MM Membership";
        HaveAutoRenewItem: Boolean;
        EstimatedStartDate, EstimatedUntilDate : Date;
        PlaceHolderLbl: Label '%1 for %2', Locked = true;
        KeepAutoRenewProduct: Boolean;
        TargetMembershipCode: Code[20];
        FromMembershipCode: Code[20];
    begin
        HaveAutoRenewItem := (RenewWithItemNo <> '');
        if (not HaveAutoRenewItem) then begin
            case MembershipEntry.Context of
                MembershipEntry.Context::NEW:
                    begin
                        if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MembershipEntry."Item No.")) then
                            HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, MembershipEntry."Membership Code", MembershipSalesSetup."Auto-Renew To");
                        RenewWithItemNo := MembershipSalesSetup."Auto-Renew To";
                    end;
                MembershipEntry.Context::RENEW:
                    begin
                        FromMembershipCode := GetFromMembershipCode(MembershipEntry);
                        // Check if membership code changed during renewal
                        if FromMembershipCode <> MembershipEntry."Membership Code" then
                            HaveAutoRenewItem := TryGetAutoRenewForMembershipChange(MembershipAlterationSetup."Alteration Type"::RENEW, FromMembershipCode, MembershipEntry, MembershipAlterationSetup, RenewWithItemNo)
                        else begin
                            HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::RENEW, MembershipEntry."Membership Code", MembershipEntry."Item No.");
                            RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                        end;
                    end;
                MembershipEntry.Context::EXTEND:
                    begin
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::EXTEND, MembershipEntry."Membership Code", MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                    end;
                MembershipEntry.Context::UPGRADE:
                    begin
                        FromMembershipCode := GetFromMembershipCode(MembershipEntry);
                        // Check if membership code changed during upgrade
                        if FromMembershipCode <> MembershipEntry."Membership Code" then
                            HaveAutoRenewItem := TryGetAutoRenewForMembershipChange(MembershipAlterationSetup."Alteration Type"::UPGRADE, FromMembershipCode, MembershipEntry, MembershipAlterationSetup, RenewWithItemNo)
                        else begin
                            HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::UPGRADE, MembershipEntry."Membership Code", MembershipEntry."Item No.");
                            RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                        end;
                    end;
                MembershipEntry.Context::AUTORENEW:
                    begin
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, MembershipEntry."Membership Code", MembershipEntry."Item No.");
                        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
                    end;
            end;
        end;

        if (not HaveAutoRenewItem) then begin
            HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, MembershipEntry."Membership Code", MembershipEntry."Item No.");
            RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
        end;

        // Check the age constraint - do we need to leave the current membership code?
        if (MembershipSetup.Get(MembershipEntry."Membership Code")) then
            if (MembershipSetup."Enable Age Verification") then begin
                Membership.Get(MembershipEntry."Membership Entry No.");
                EstimatedStartDate := CalcDate('<+1D>', MembershipEntry."Valid Until Date");
                EstimatedUntilDate := CalcDate(MembershipAlterationSetup."Membership Duration", EstimatedStartDate);

                if (MembershipAlterationSetup."Age Constraint Type" <> MembershipAlterationSetup."Age Constraint Type"::NA) then begin
                    TargetMembershipCode := MembershipAlterationSetup."To Membership Code";
                    MembershipAlterationSetup."To Membership Code" := ''; // Check the age constraint on the current membership code
                    KeepAutoRenewProduct := CheckAgeConstraintOnMembershipAlter(Membership, MembershipAlterationSetup, Today(), EstimatedStartDate, EstimatedUntilDate, ReasonText);
                    if (not KeepAutoRenewProduct) then begin
                        RenewWithItemNo := MembershipAlterationSetup.AutoRenewToOnAgeConstraint;
                        HaveAutoRenewItem := MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, TargetMembershipCode, RenewWithItemNo);
                    end;
                    if ((not HaveAutoRenewItem) and (not KeepAutoRenewProduct)) then begin
                        ReasonText := StrSubstNo('Age constraint applies and the members age invalidates the current Auto-Renew rule without providing an alternative. Verify field "%1" for rule: [%2] [%3] [%4]',
                            MembershipAlterationSetup.FieldCaption(AutoRenewToOnAgeConstraint), MembershipAlterationSetup."Alteration Type"::AUTORENEW, MembershipEntry."Membership Code", MembershipEntry."Item No.");
                        exit(false);
                    end;
                end;
            end;

        if (not HaveAutoRenewItem) then begin
            ReasonText := StrSubstNo(NOT_FOUND, 'Auto-Renew rule', StrSubstNo(PlaceHolderLbl, MembershipEntry.Context, MembershipEntry."Item No."));
            exit(false);
        end;

        if (RenewWithItemNo = '') then
            ReasonText := StrSubstNo(NOT_FOUND, 'Auto-Renew rule item', StrSubstNo(PlaceHolderLbl, MembershipEntry.Context, MembershipEntry."Item No."));

        AlterationRuleSystemId := MembershipAlterationSetup.SystemId;
        exit(RenewWithItemNo <> '');

    end;

    local procedure TryGetAutoRenewForMembershipChange(AlterationType: Option REGRET,RENEW,UPGRADE,EXTEND,CANCEL,AUTORENEW; FromMembershipCode: Code[20]; MembershipEntry: Record "NPR MM Membership Entry"; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; var RenewWithItemNo: Code[20]): Boolean
    var
        TempAutoRenewItemNo: Code[20];
    begin
        // Find alteration rule (RENEW/UPGRADE) from old membership code
        if not MembershipAlterationSetup.Get(AlterationType, FromMembershipCode, MembershipEntry."Item No.") then
            exit(false);

        // Get the Auto-Renew item from that rule
        TempAutoRenewItemNo := MembershipAlterationSetup."Auto-Renew To";

        // Find AUTORENEW rule for the new membership code with that item
        if not MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, MembershipEntry."Membership Code", TempAutoRenewItemNo) then
            exit(false);

        // Return the final Auto-Renew item
        RenewWithItemNo := MembershipAlterationSetup."Auto-Renew To";
        exit(true);
    end;

    local procedure GetFromMembershipCode(CurrMembershipEntry: Record "NPR MM Membership Entry") FromMembershipCode: Code[20];
    var
        FromMembershipEntry: Record "NPR MM Membership Entry";
    begin
        FromMembershipEntry.Reset();
        FromMembershipEntry.SetRange("Membership Entry No.", CurrMembershipEntry."Membership Entry No.");
        FromMembershipEntry.SetFilter("Entry No.", '<>%1', CurrMembershipEntry."Entry No.");
        FromMembershipEntry.SetLoadFields("Membership Code");
        if not FromMembershipEntry.FindLast() then
            exit;

        FromMembershipCode := FromMembershipEntry."Membership Code";
    end;

    internal procedure AutoRenewMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture"; WithUpdate: Boolean; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal): Boolean
    var
        ReasonText: Text;
    begin
        exit(AutoRenewMembership(MemberInfoCapture, WithUpdate, Today(), OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    internal procedure AutoRenewMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture"; WithUpdate: Boolean; RenewalDate: Date; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    begin
        exit(AutoRenewMembershipWorker(MemberInfoCapture, WithUpdate, RenewalDate, OutStartDate, OutUntilDate, SuggestedUnitPrice, ReasonText));
    end;

    local procedure AutoRenewMembershipWorker(var MemberInfoCapture: Record "NPR MM Member Info Capture"; WithUpdate: Boolean; RenewalDate: Date; var OutStartDate: Date; var OutUntilDate: Date; var SuggestedUnitPrice: Decimal; var ReasonText: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        Item: Record Item;
        StartDateNew: Date;
        EndDateNew: Date;
        EntryNo: Integer;
    begin
        if RenewalDate = 0D then
            RenewalDate := Today();
        if (MemberInfoCapture."Document Date" = 0D) then
            MemberInfoCapture."Document Date" := RenewalDate;

        Membership.Get(MemberInfoCapture."Membership Entry No.");

        if (MemberInfoCapture."Membership Code" = '') then
            MemberInfoCapture."Membership Code" := Membership."Membership Code";

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MemberInfoCapture."Membership Entry No.");
        MembershipEntry.SetFilter(Blocked, '=%1', false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        ReasonText := StrSubstNo(NOT_FOUND, MembershipEntry.TableCaption(), MembershipEntry.GetFilters());
        if (not MembershipEntry.FindLast()) then
            exit(false);

        ReasonText := NOT_ACTIVATED;
        if (MembershipEntry."Activate On First Use") then
            exit(false);

        MembershipAlterationSetup.Get(MembershipAlterationSetup."Alteration Type"::AUTORENEW, MemberInfoCapture."Membership Code", MemberInfoCapture."Item No.");
        ReasonText := StrSubstNo(GRACE_PERIOD, MembershipAlterationSetup."Alteration Type");
        if (not ValidAlterationGracePeriod(MembershipAlterationSetup, MembershipEntry, MemberInfoCapture."Document Date")) then
            exit(false);

        Item.Get(MemberInfoCapture."Item No.");

        if (MembershipEntry."Valid Until Date" < RenewalDate) then
            MembershipEntry."Valid Until Date" := CalcDate('<-1D>', RenewalDate);

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

        if (StartDateNew < RenewalDate) then
            StartDateNew := RenewalDate;

        EndDateNew := CalcDate(MembershipAlterationSetup."Membership Duration", StartDateNew);

        if (StartDateNew <= MembershipEntry."Valid Until Date") then
            exit(ExitFalseOrWithError(false, StrSubstNo(CONFLICTING_ENTRY, StartDateNew, EndDateNew)));

        if (not MembershipAlterationSetup."Stacking Allowed") then
            if (GetLedgerEntryForDate(Membership."Entry No.", RenewalDate, EntryNo)) then
                if (EntryNo <> MembershipEntry."Entry No.") then
                    exit(ExitFalseOrWithError(false, StrSubstNo(STACKING_NOT_ALLOWED, Membership."Entry No.", RenewalDate)));

        SuggestedUnitPrice := CalculateAutoRenewPrice(Membership."Entry No.", MembershipAlterationSetup, MemberInfoCapture, MembershipEntry);

        if (not CheckExtendMemberCards(false, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", EndDateNew, MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", ReasonText)) then
            exit(false);

        if (WithUpdate) then begin
            if not CarryOutMembershipRenewal(MemberInfoCapture, MembershipAlterationSetup, StartDateNew, EndDateNew, EntryNo, ReasonText) then
                exit(false);
        end;

        ReasonText := 'Ok';
        OutStartDate := StartDateNew;
        OutUntilDate := EndDateNew;
        exit(true);
    end;

    internal procedure CalculateAutoRenewPrice(MembershipEntryNo: Integer; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipEntry: Record "NPR MM Membership Entry") SuggestedUnitPrice: Decimal
    var
        Item: Record Item;
        IPriceHandler: Interface "NPR IMemberAlterationPriceHandler";
    begin
        if (_FeatureFlag.IsEnabled(PriceCalcInterfaceTok)) then begin
            IPriceHandler := MembershipAlterationSetup."Price Calculation";
            SuggestedUnitPrice := IPriceHandler.CalculateAutoRenewAlterationPrice(MembershipAlterationSetup, MemberInfoCapture, MembershipEntry);
        end else begin
            Item.SetLoadFields("Unit Price");
            Item.Get(MemberInfoCapture."Item No.");
            SuggestedUnitPrice := Item."Unit Price";
            SuggestedUnitPrice += MembershipAlterationSetup."Member Unit Price" * GetMembershipMemberCountForAlteration(MembershipEntryNo, MembershipAlterationSetup);
        end;
    end;

    internal procedure CarryOutMembershipRenewal(var MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; StartDateNew: Date; EndDateNew: Date; var EntryNo: Integer; var ReasonText: Text): Boolean
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
    begin
        SubscriptionRequest."New Valid From Date" := StartDateNew;
        SubscriptionRequest."New Valid Until Date" := EndDateNew;

        exit(CarryOutMembershipRenewal(SubscriptionRequest, MemberInfoCapture, MembershipAlterationSetup, EntryNo, ReasonText));
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure CarryOutMembershipRenewal(var SubscriptionRequest: Record "NPR MM Subscr. Request"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; var EntryNo: Integer; var ReasonText: Text): Boolean
    var
        MembershipAutoRenew: Codeunit "NPR MM Membership Auto Renew";
        MembershipScheduledForUpdate: Boolean;
        TargetMembershipCode: Code[20];
        Membership: Record "NPR MM Membership";
    begin
        MemberInfoCapture."Duration Formula" := MembershipAlterationSetup."Membership Duration";

        Membership.Get(MemberInfoCapture."Membership Entry No.");
        TargetMembershipCode := MembershipAlterationSetup."From Membership Code";
        if (MembershipAlterationSetup."To Membership Code" <> '') and (MembershipAlterationSetup."Age Constraint Type" = MembershipAlterationSetup."Age Constraint Type"::NA) then
            TargetMembershipCode := MembershipAlterationSetup."To Membership Code";

        MemberInfoCapture."Membership Code" := TargetMembershipCode;

        if (not MembershipAutoRenew.CreateInvoice(SubscriptionRequest, MemberInfoCapture)) then
            exit(false);

        if (not CheckExtendMemberCards(true, MemberInfoCapture."Membership Entry No.", MembershipAlterationSetup."Card Expired Action", SubscriptionRequest."New Valid Until Date", MemberInfoCapture."External Card No.", MemberInfoCapture."Card Entry No.", TargetMembershipCode, ReasonText)) then
            exit(false);

        EntryNo := AddMembershipLedgerEntry(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, SubscriptionRequest."New Valid From Date", SubscriptionRequest."New Valid Until Date", MembershipScheduledForUpdate);

        if (not MembershipScheduledForUpdate) then begin
            Membership.Get(MemberInfoCapture."Membership Entry No.");
            if (Membership."Membership Code" <> TargetMembershipCode) then begin
                Membership."Membership Code" := TargetMembershipCode;
                Membership.Modify();
            end;
        end;

        OnMembershipChangeEvent(MemberInfoCapture."Membership Entry No.");
        exit(true);
    end;

    local procedure ExtendMemberCard(MembershipEntryNo: Integer; CardEntryNo: Integer; ExpiredCardOption: Integer; NewTimeFrameEndDate: Date; var MemberCardEntryNoOut: Integer; TargetMembershipCode: Code[20]; var ResponseMessage: Text): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberCard: Record "NPR MM Member Card";
        MembershipSetup: Record "NPR MM Membership Setup";
        NewUntilDate: Date;
    begin

        MemberCard.Get(CardEntryNo);
        MembershipSetup.Get(TargetMembershipCode);

        case MembershipSetup."Card Expire Date Calculation" of
            MembershipSetup."Card Expire Date Calculation"::NA:
                NewUntilDate := 0D;
            MembershipSetup."Card Expire Date Calculation"::DateFormula:
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
                    exit(IssueMemberCardWorker(MembershipEntryNo, MemberCard."Member Entry No.", MemberInfoCapture, false, MemberCardEntryNoOut, TargetMembershipCode, ResponseMessage, true));

                end;

            AlterationSetup."Card Expired Action"::Update:
                begin

                    MemberCardEntryNoOut := CardEntryNo;

                    MemberCard."Valid Until" := NewUntilDate;
                    exit(MemberCard.Modify());
                end;
        end;
    end;

    local procedure CheckExtendMemberCards(WithUpdate: Boolean; MembershipEntryNo: Integer; ExpiredCardOption: Integer; NewTimeFrameEndDate: Date; ExternalCardNo: Text[100]; var MemberCardEntryNoOut: Integer; var ResponseMessage: Text): Boolean
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.Get(MembershipEntryNo);
        exit(CheckExtendMemberCards(WithUpdate, MembershipEntryNo, ExpiredCardOption, NewTimeFrameEndDate, ExternalCardNo, MemberCardEntryNoOut, Membership."Membership Code", ResponseMessage));
    end;

    local procedure CheckExtendMemberCards(WithUpdate: Boolean; MembershipEntryNo: Integer; ExpiredCardOption: Integer; NewTimeFrameEndDate: Date; ExternalCardNo: Text[100]; var MemberCardEntryNoOut: Integer; TargetMembershipCode: Code[20]; var ResponseMessage: Text): Boolean
    var
        AlterationSetup: Record "NPR MM Members. Alter. Setup";
        MemberCard: Record "NPR MM Member Card";
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
                AlterationSetup."Card Expired Action"::Update:
                    ;
                AlterationSetup."Card Expired Action"::NEW:
                    UpdateRequired := (PreviousMemberEntryNo <> MemberCard."Member Entry No.");
            end;

            if ((WithUpdate) and (UpdateRequired)) then begin
                if (not ExtendMemberCard(MembershipEntryNo, MemberCard."Entry No.", ExpiredCardOption, NewTimeFrameEndDate, NewCardEntryNo, TargetMembershipCode, ResponseMessage)) then
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
        MemberInfoCapture."Card Entry No." := GetCardEntryNoFromExtCardNo(ExternalMemberCardNo);
        MemberInfoCapture."Item No." := MembershipSalesItemNo;
    end;

    internal procedure AddMembershipLedgerEntry_NEW(MembershipEntryNo: Integer; DocumentDate: Date; MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture") LedgerEntryNo: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MemberCard: Record "NPR MM Member Card";
        ValidFromDate: Date;
        ValidUntilDate: Date;
        MembershipScheduledForUpdate: Boolean;
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");
        MemberInfoCapture."Item No." := MembershipSalesSetup."No.";

        if (DocumentDate = 0D) then
            DocumentDate := WorkDate();

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

        LedgerEntryNo := AddMembershipLedgerEntry(MembershipEntryNo, MemberInfoCapture, ValidFromDate, ValidUntilDate, MembershipScheduledForUpdate);
        OnMembershipChangeEvent(MembershipEntryNo);

        exit(LedgerEntryNo);

    end;

    local procedure CalculateLedgerEntryDates_NEW(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; Perpetual: Boolean; SalesDate: Date; PromptDate: Date; var ValidFromDate: Date; var ValidUntilDate: Date)
    begin

        if (Perpetual) then begin
            ValidFromDate := SalesDate;
            ValidUntilDate := DMY2Date(31, 12, 9999);
            exit;
        end;

        case MembershipSalesSetup."Valid From Base" of

            MembershipSalesSetup."Valid From Base"::PROMPT:
                ValidFromDate := PromptDate;

            MembershipSalesSetup."Valid From Base"::SALESDATE:
                ValidFromDate := SalesDate;

            MembershipSalesSetup."Valid From Base"::"DATEFORMULA":
                ValidFromDate := SalesDate;

            MembershipSalesSetup."Valid From Base"::FIRST_USE:
                begin
                    ValidFromDate := 0D;
                    ValidUntilDate := 0D;
                    exit;
                end;
        end;

        MembershipSalesSetup.TestField("Duration Formula");
        ValidUntilDate := CalcDate(MembershipSalesSetup."Duration Formula", ValidFromDate);

    end;

    internal procedure GetMembershipAgeConstraintDate(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; MemberInfoCapture: Record "NPR MM Member Info Capture") ConstraintDate: Date
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        DocumentDate: Date;
        ValidFromDate: Date;
        ValidUntilDate: Date;
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        DocumentDate := MemberInfoCapture."Document Date";
        if (DocumentDate = 0D) then
            DocumentDate := WorkDate();

        CalculateLedgerEntryDates_NEW(
          MembershipSalesSetup,
          ((MembershipSalesSetup."Valid Until Calculation" = MembershipSalesSetup."Valid Until Calculation"::END_OF_TIME) or MembershipSetup.Perpetual),
          DocumentDate,
          MemberInfoCapture."Document Date",
          ValidFromDate,
          ValidUntilDate);

        case MembershipSetup."Validate Age Against" of
            MembershipSetup."Validate Age Against"::SALESDATE_Y,
  MembershipSetup."Validate Age Against"::SALESDATE_YM,
  MembershipSetup."Validate Age Against"::SALESDATE_YMD:
                ConstraintDate := DocumentDate;
            MembershipSetup."Validate Age Against"::PERIODBEGIN_Y,
  MembershipSetup."Validate Age Against"::PERIODBEGIN_YM,
  MembershipSetup."Validate Age Against"::PERIODBEGIN_YMD:
                ConstraintDate := ValidFromDate;
            MembershipSetup."Validate Age Against"::PERIODEND_Y,
  MembershipSetup."Validate Age Against"::PERIODEND_YM,
  MembershipSetup."Validate Age Against"::PERIODEND_YMD:
                ConstraintDate := ValidUntilDate;
        end;

        exit(ConstraintDate);

    end;

    internal procedure SynchronizeCustomerAndContact(Membership: Record "NPR MM Membership")
    var
        Community: Record "NPR MM Member Community";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipRole: Record "NPR MM Membership Role";
        AdminMemberEntryNo: Integer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        Customer: Record Customer;
    begin
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

        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::GUARDIAN);
        MembershipRole.SetFilter(Blocked, '=%1', false);

        if (MembershipRole.FindFirst()) then begin
            AdminMemberEntryNo := MembershipRole."Member Entry No.";

        end else begin
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
            MembershipRole.SetFilter(Blocked, '=%1', Membership.Blocked);
            if (not MembershipRole.FindFirst()) then
                exit;
            AdminMemberEntryNo := MembershipRole."Member Entry No.";
        end;

        UpdateCustomerFromMember(Membership, AdminMemberEntryNo);

        MembershipRole.Reset();
        MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
        MembershipRole.SetFilter("Member Entry No.", '<>%1', AdminMemberEntryNo);
        MembershipRole.SetFilter("Member Role", '<>%1&<>%2', MembershipRole."Member Role"::ANONYMOUS, MembershipRole."Member Role"::GUARDIAN);

        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindSet()) then begin
            repeat
                AddCustomerContact(Membership."Entry No.", MembershipRole."Member Entry No.");
            until (MembershipRole.Next() = 0);
        end;
    end;

    internal procedure GetMembershipChangeOptions(MembershipEntryNo: Integer; AlterationGroup: Code[10]; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; var TmpMembershipEntry: Record "NPR MM Membership Entry" temporary): Boolean
    var
        TempMemberInfoCapture: Record "NPR MM Member Info Capture" temporary;
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
                TempMemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                TempMemberInfoCapture."Item No." := MembershipAlterationSetup."Sales Item No.";
                if (Item.Get(TempMemberInfoCapture."Item No.")) then;

                IsValidOption := false;
                if AlterationSetupInGroup(MembershipAlterationSetup, AlterationGroup) then
                    case MembershipAlterationSetup."Alteration Type" of
                        MembershipAlterationSetup."Alteration Type"::RENEW:
                            IsValidOption := RenewMembership(TempMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                        MembershipAlterationSetup."Alteration Type"::EXTEND:
                            IsValidOption := ExtendMembership(TempMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                        MembershipAlterationSetup."Alteration Type"::UPGRADE:
                            IsValidOption := UpgradeMembership(TempMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                        MembershipAlterationSetup."Alteration Type"::REGRET:
                            IsValidOption := RegretMembership(TempMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                        MembershipAlterationSetup."Alteration Type"::CANCEL:
                            IsValidOption := CancelMembership(TempMemberInfoCapture, false, false, StartDate, EndDate, UnitPrice);
                    end;
                if (IsValidOption) then begin
                    TmpMembershipEntry.Init();

                    TmpMembershipEntry.SystemId := MembershipAlterationSetup.SystemId;
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

    internal procedure GetMemberCommunityCode(MemberEntryNo: Integer; var CommunityCode: Code[20]): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        Community: Record "NPR MM Member Community";
    begin
        CommunityCode := '';

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (not MembershipRole.FindFirst()) then
            exit(false);

        if (not Membership.Get(MembershipRole."Membership Entry No.")) then
            exit(false);

        if (not Community.Get(Membership."Community Code")) then
            exit(false);

        CommunityCode := Community.Code;
        exit(true);
    end;

    internal procedure CheckGetCommunityUniqueIdRules(MemberEntryNo: Integer; var Community: Record "NPR MM Member Community"): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        CommunityCheck: Record "NPR MM Member Community";
    begin

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (MembershipRole.FindSet()) then begin
            repeat
                Membership.Get(MembershipRole."Membership Entry No.");
                CommunityCheck.Get(Membership."Community Code");

                if (Community.Code = '') then
                    Community.Get(Membership."Community Code");

                if (CommunityCheck.Code <> Community.Code) then
                    if (CommunityCheck."Member Unique Identity" <> Community."Member Unique Identity") then
                        exit(false);
                if (CommunityCheck."Create Member UI Violation" <> Community."Create Member UI Violation") then
                    exit(false);

            until MembershipRole.Next() = 0;
        end;
        exit(true);
    end;

    internal procedure GetFirstAdminMember(MembershipEntryNo: Integer; var Member: Record "NPR MM Member"): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        MembershipRole.SetRange("Membership Entry No.", MembershipEntryNo);
        MembershipRole.SetRange("Member Role", MembershipRole."Member Role"::ADMIN);
        if (not MembershipRole.FindFirst()) then
            exit(false);
        exit(Member.Get(MembershipRole."Member Entry No."));
    end;

    internal procedure GetUserAccountFromMember(Member: Record "NPR MM Member"; var UserAccount: Record "NPR UserAccount") AccountFound: Boolean
    var
        UserAccountMgtImpl: Codeunit "NPR UserAccountMgtImpl";
    begin
        AccountFound := UserAccountMgtImpl.FindAccountByEmail(Member."E-Mail Address".ToLower(), UserAccount);
    end;

    internal procedure CreateUserAccountFromMember(Member: Record "NPR MM Member"; var UserAccount: Record "NPR UserAccount")
    var
        UserAccountMgt: Codeunit "NPR UserAccountMgtImpl";
    begin
        UserAccount.Init();
        UserAccount.AccountNo := 0;
        UserAccount.Validate(FirstName, Member."First Name");
        if (Member."Middle Name" <> '') then
            UserAccount.Validate(FirstName, UserAccount.FirstName + ' ' + Member."Middle Name");
        UserAccount.Validate(LastName, Member."Last Name");
        UserAccount.EmailAddress := CopyStr(Member."E-Mail Address".ToLower().Trim(), 1, MaxStrLen(UserAccount.EmailAddress));
        UserAccount.PhoneNo := Member."Phone No.";

        UserAccountMgt.CreateAccount(UserAccount);
    end;

    internal procedure CreatePaymentUserAccountFromEmail(EmailAddress: Text[80]; var UserAccount: Record "NPR UserAccount")
    var
        UserAccountMgt: Codeunit "NPR UserAccountMgtImpl";
    begin
        UserAccount.Init();
        UserAccount.AccountNo := 0;
        UserAccount.EmailAddress := EmailAddress.ToLower();
        UserAccountMgt.CreateAccount(UserAccount);
    end;

    internal procedure GetMemberCount(MembershipEntryNo: Integer; var AdminMemberCount: Integer; var MemberMemberCount: Integer; var AnonymousMemberCount: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        AdminMemberCount := 0;
        MemberMemberCount := 0;
        AnonymousMemberCount := 0;

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        AdminMemberCount := MembershipRole.Count();

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::MEMBER);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MemberMemberCount := MembershipRole.Count();

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::DEPENDENT);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MemberMemberCount += MembershipRole.Count();

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ANONYMOUS);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindFirst()) then
            AnonymousMemberCount := MembershipRole."Member Count";
    end;

    internal procedure ApplyGracePeriodPreset(Preset: Option; var MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup")
    begin

        case Preset of
            MembershipAlterationSetup."Grace Period Presets"::NA:
                begin
                end;
            MembershipAlterationSetup."Grace Period Presets"::EXPIRED_MEMBERSHIP:
                begin
                    MembershipAlterationSetup."Grace Period Calculation" := MembershipAlterationSetup."Grace Period Calculation"::ADVANCED;
                    MembershipAlterationSetup."Grace Period Relates To" := MembershipAlterationSetup."Grace Period Relates To"::END_DATE;
                    Evaluate(MembershipAlterationSetup."Grace Period Before", '<+1D>');
                    Evaluate(MembershipAlterationSetup."Grace Period After", '<+100Y>');
                    MembershipAlterationSetup."Activate Grace Period" := true;
                end;

            MembershipAlterationSetup."Grace Period Presets"::ACTIVE_MEMBERSHIP:
                begin
                    MembershipAlterationSetup."Grace Period Calculation" := MembershipAlterationSetup."Grace Period Calculation"::ADVANCED;
                    MembershipAlterationSetup."Grace Period Relates To" := MembershipAlterationSetup."Grace Period Relates To"::END_DATE;
                    Evaluate(MembershipAlterationSetup."Grace Period Before", '<-100Y>');
                    Evaluate(MembershipAlterationSetup."Grace Period After", '<0D>');
                    MembershipAlterationSetup."Activate Grace Period" := true;
                end;
        end;
    end;

    internal procedure CreateMembershipCommunicationDefaultSetup(MembershipEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
    begin

        if (not (Membership.Get(MembershipEntryNo))) then
            exit;

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipRole.FindSet()) then
            exit;

        repeat
            CreateMembershipMemberDefaultCommunicationSetup(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.");
        until (MembershipRole.Next() = 0);
    end;

    internal procedure CreateMemberCommunicationDefaultSetup(MemberEntryNo: Integer)
    var
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
    begin

        if (not (Member.Get(MemberEntryNo))) then
            exit;

        MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        if (not MembershipRole.FindSet()) then
            exit;

        repeat
            CreateMembershipMemberDefaultCommunicationSetup(MembershipRole."Membership Entry No.", MembershipRole."Member Entry No.");
        until (MembershipRole.Next() = 0);
    end;

    internal procedure CreateMembershipMemberDefaultCommunicationSetup(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MemberCommunication: Record "NPR MM Member Communication";
        MemberCommunicationSetup: Record "NPR MM Member Comm. Setup";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
    begin

        Member.Get(MemberEntryNo);
        if (Member.Blocked) then
            exit;

        Membership.Get(MembershipEntryNo);
        if (Membership.Blocked) then
            exit;

        MemberCommunication.Init();
        MemberCommunication."Membership Entry No." := MembershipEntryNo;
        MemberCommunication."Member Entry No." := MemberEntryNo;

        MemberCommunicationSetup.SetFilter("Membership Code", '=%1', Membership."Membership Code");
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
    end;

    internal procedure GetCommunicationMethod_Welcome(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::WELCOME, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_Renew(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::RENEW, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_MemberCard(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::MEMBERCARD, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_Ticket(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::TICKETS, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_Coupon(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::COUPONS, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_RenewalSuccess(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::RENEWAL_SUCCESS, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_RenewalFailure(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::RENEWAL_FAILURE, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_AutoRenewalEnabled(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin

        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::AUTORENEWAL_ENABLED, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_PaymentMethodCollect(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::PAYMENT_METHOD_COLLECTION, Method, Address, Engine));
    end;

    internal procedure GetCommunicationMethod_AutoRenewalDisabled(MemberEntryNo: Integer; MembershipEntryNo: Integer; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
    var
        MemberCommunication: Record "NPR MM Member Communication";
    begin
        exit(GetCommunicationMethodWorker(MemberEntryNo, MembershipEntryNo, MemberCommunication."Message Type"::AUTORENEWAL_DISABLED, Method, Address, Engine));
    end;

    local procedure GetCommunicationMethodWorker(MemberEntryNo: Integer; MembershipEntryNo: Integer; MessageType: Option; var Method: Code[10]; var Address: Text[100]; var Engine: Option): Boolean
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
            'W-EMAIL':
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

        NPRAttributeManagement.GetEntryAttributeValue(TextArray40, Database::"NPR MM Member Info Capture", MemberInfoCaptureEntryNo);
        for N := 1 to (ArrayLen(TextArray40)) do
            if (TextArray40[N] <> '') then
                if (NPRAttributeManagement.GetAttributeShortcut(Database::"NPR MM Member Info Capture", N, NPRAttributeID)) then
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

    local procedure AddMembershipRenewalSuccessNotification(MembershipLedgerEntry: Record "NPR MM Membership Entry")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
    begin

        MemberNotification.AddMembershipRenewalSuccessNotification(MembershipLedgerEntry);
    end;

    local procedure AddMemberCreateNotification(MembershipEntryNo: Integer; MembershipSetup: Record "NPR MM Membership Setup"; Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        MembershipNotification: Record "NPR MM Membership Notific.";
        AzureRegistrationSetup: Record "NPR MM AzureMemberRegSetup";
        EntryNoList: List of [Integer];
        EntryNo: Integer;
        AllowWallet: Boolean;
    begin
        AllowWallet := true;

        if (MembershipSetup."Create Welcome Notification") then begin
            MemberNotification.AddMemberWelcomeNotification(MembershipEntryNo, Member."Entry No.", MemberInfoCapture."Item No.", EntryNoList);
            foreach EntryNo in EntryNoList do
                if (MembershipNotification.Get(EntryNo)) then
                    if (MembershipNotification.AzureRegistrationSetupCode <> '') then
                        if (AzureRegistrationSetup.Get(MembershipNotification.AzureRegistrationSetupCode)) then
                            AllowWallet := (AllowWallet and AzureRegistrationSetup.AllowAnonymousWallet);

        end;

        if (AllowWallet) then
            if (MemberInfoCapture."Member Card Type" in [MemberInfoCapture."Member Card Type"::CARD_PASSSERVER, MemberInfoCapture."Member Card Type"::PASSSERVER]) then
                EntryNo := MemberNotification.CreateWalletSendNotification(MembershipEntryNo, Member."Entry No.", 0, TODAY);

        _MembershipWebhooks.TriggerMemberAddedWebhookCall(MembershipEntryNo, Member."Entry No.", Member.SystemId);
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

        if (MembershipAlterationSetup.GracePeriodRelatesToFromDate <> 0D) then
            if (GracePeriodDate < MembershipAlterationSetup.GracePeriodRelatesToFromDate) then
                exit(false);

        if (MembershipAlterationSetup.GracePeriodRelatesToUntilDate <> 0D) then
            if (GracePeriodDate > MembershipAlterationSetup.GracePeriodRelatesToUntilDate) then
                exit(false);

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

    local procedure ValidateChangeMembershipCode(WithConfirm: Boolean; MembershipEntryNo: Integer; ToMembershipCode: Code[20]; var ReasonText: Text): Boolean
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

        case MembershipSetup."Validate Age Against" of
            MembershipSetup."Validate Age Against"::SALESDATE_Y,
            MembershipSetup."Validate Age Against"::SALESDATE_YM,
            MembershipSetup."Validate Age Against"::SALESDATE_YMD:
                ReferenceDate := SalesDate;

            MembershipSetup."Validate Age Against"::PERIODBEGIN_Y,
            MembershipSetup."Validate Age Against"::PERIODBEGIN_YM,
            MembershipSetup."Validate Age Against"::PERIODBEGIN_YMD:
                ReferenceDate := PeriodStartDate;

            MembershipSetup."Validate Age Against"::PERIODEND_Y,
            MembershipSetup."Validate Age Against"::PERIODEND_YM,
            MembershipSetup."Validate Age Against"::PERIODEND_YMD:
                ReferenceDate := PeriodEndDate;
        end;

        exit(CheckMemberAgeConstraint(Membership."Entry No.", ReferenceDate, MembershipSetup."Validate Age Against", MembershipAlterationSetup."Age Constraint Type", MembershipAlterationSetup."Age Constraint (Years)", MembershipAlterationSetup."Age Constraint Applies To", ReasonText));

    end;

    internal procedure IsBirthdayMandatory(Member: Record "NPR MM Member"): Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin
        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindSet()) then begin
            repeat
                if (Membership.Get(MembershipRole."Membership Entry No.")) then begin
                    MembershipSetup.Get(Membership."Membership Code");
                    if (MembershipSetup."Enable Age Verification") then
                        exit(true);
                end;
            until (MembershipRole.Next() = 0);
        end;

        exit(false);
    end;

    internal procedure IsAgeValidForMember(Member: Record "NPR MM Member"; ReferenceDate: Date; var ReasonText: Text) AgeConstraintOk: Boolean
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin
        ReasonText := '';

        MembershipRole.SetFilter("Member Entry No.", '=%1', Member."Entry No.");
        MembershipRole.SetFilter(Blocked, '=%1', false);
        if (MembershipRole.FindSet()) then begin
            repeat
                AgeConstraintOk := IsAgeValidForMembershipMembers(MembershipRole."Membership Entry No.", ReferenceDate, ReasonText);
                if (not AgeConstraintOk) then
                    exit(false);

            until (MembershipRole.Next() = 0);
        end;

        exit(true);
    end;

    local procedure IsAgeValidForMembershipMembers(MembershipEntryNo: Integer; ReferenceDate: Date; var ReasonText: Text) AgeConstraintOk: Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipLedgerEntry: Record "NPR MM Membership Entry";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        LedgerEntryNo: Integer;
        AlterationOptionType: Option;
    begin
        AgeConstraintOk := true;

        if (not Membership.Get(MembershipEntryNo)) then
            exit;

        MembershipSetup.Get(Membership."Membership Code");
        if (not MembershipSetup."Enable Age Verification") then
            exit;

        if (not GetLedgerEntryForDate(Membership."Entry No.", ReferenceDate, LedgerEntryNo)) then
            exit;

        if (not MembershipLedgerEntry.Get(LedgerEntryNo)) then
            exit;

        if (MembershipLedgerEntry.Blocked) then
            exit;

        if MembershipLedgerEntry.Context = MembershipLedgerEntry.Context::NEW then begin
            // Sales setup lookup: Get(type, ItemNo)
            if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MembershipLedgerEntry."Item No.")) then
                AgeConstraintOk := CheckMemberAgeConstraint(MembershipEntryNo, ReferenceDate,
                    MembershipSetup."Validate Age Against",
                    MembershipSalesSetup."Age Constraint Type",
                    MembershipSalesSetup."Age Constraint (Years)",
                    MembershipSalesSetup."Age Constraint Applies To", ReasonText);
        end;

        if MembershipLedgerEntry.Context in [MembershipLedgerEntry.Context::RENEW, MembershipLedgerEntry.Context::UPGRADE, MembershipLedgerEntry.Context::EXTEND] then begin
            // Find alteration rule that maps to this membership (reset filters first)
            case MembershipLedgerEntry.Context of
                MembershipLedgerEntry.Context::RENEW:
                    AlterationOptionType := MembershipAlterationSetup."Alteration Type"::RENEW;
                MembershipLedgerEntry.Context::UPGRADE:
                    AlterationOptionType := MembershipAlterationSetup."Alteration Type"::UPGRADE;
                MembershipLedgerEntry.Context::EXTEND:
                    AlterationOptionType := MembershipAlterationSetup."Alteration Type"::EXTEND;
                else
                    Error('Unhandled context in IsAgeValidForMembershipMembers');
            end;
            MembershipAlterationSetup.Reset();
            MembershipAlterationSetup.SetFilter("Alteration Type", '=%1', AlterationOptionType);
            MembershipAlterationSetup.SetFilter("To Membership Code", '=%1|=%2', '', Membership."Membership Code");
            MembershipAlterationSetup.SetFilter("From Membership Code", '=%1|=%2', '', Membership."Membership Code");
            MembershipAlterationSetup.SetFilter("Sales Item No.", '=%1', MembershipLedgerEntry."Item No.");
            if (MembershipAlterationSetup.FindFirst()) then
                AgeConstraintOk := CheckMemberAgeConstraint(MembershipEntryNo, ReferenceDate,
                    MembershipSetup."Validate Age Against",
                    MembershipAlterationSetup."Age Constraint Type",
                    MembershipAlterationSetup."Age Constraint (Years)",
                    MembershipAlterationSetup."Age Constraint Applies To", ReasonText);
        end;

    end;

    local procedure CheckMemberAgeConstraint(MembershipEntryNo: Integer; ReferenceDate: Date; ReferenceDateType: Option; ConstraintType: Option NA,"Less Than","Less Than or Equal To","Greater Then","Greater Than or Equal To","Equal To"; Constraint: Integer; AppliesTo: Option; var ReasonText: Text): Boolean
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipRole: Record "NPR MM Membership Role";
        Member: Record "NPR MM Member";
        AgeConstraintOk: Boolean;
        MemberEntryNo: Integer;
        MemberBirthDate: Date;
        PlaceHolderLbl: Label ' {%5 must be %4 %3 => (%1 + %2)}';
        PlaceHolder2Lbl: Label '<+%1Y>', Locked = true;
    begin

        MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        MembershipRole.SetFilter(Blocked, '=%1', false);
        MembershipRole.SetFilter("Member Role", '<>%1', MembershipRole."Member Role"::ANONYMOUS);

        if (AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::DEPENDANTS) then
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::DEPENDENT);

        if (AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::ADMINS) then
            MembershipRole.SetFilter("Member Role", '=%1', MembershipRole."Member Role"::ADMIN);

        if (MembershipRole.IsEmpty()) then
            exit(true); // this membership does not have members that are subject to age control. 

        if (AppliesTo in [MembershipSalesSetup."Age Constraint Applies To"::OLDEST, MembershipSalesSetup."Age Constraint Applies To"::YOUNGEST]) then begin
            MembershipRole.FindSet();
            MemberBirthDate := 0D;
            MemberEntryNo := -1;
            if (AppliesTo = MembershipSalesSetup."Age Constraint Applies To"::OLDEST) then
                MemberBirthDate := Today();
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
                              StrSubstNo(PlaceHolderLbl, Member.Birthday, Constraint, CalcDate(StrSubstNo(PlaceHolder2Lbl, Constraint), Member.Birthday), Format(ConstraintType), ReferenceDate);
        end;

        exit(AgeConstraintOk);

    end;

    internal procedure CheckAgeConstraint(ReferenceDate1: Date; ReferenceDate2: Date; ReferenceDateType: Option; ConstraintType: Option NA,LT,LTE,GT,GTE,E; Years: Integer) ConstraintOK: Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        LowDate: Date;
        HighDate: Date;
        DateToValidate: Date;
        PlaceHolderLbl: Label '<+%1Y>', Locked = true;
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

        DateToValidate := CalcDate(StrSubstNo(PlaceHolderLbl, Years), LowDate); // Birth date + constraint in years

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

        if (ReferenceDateType in [MembershipSetup."Validate Age Against"::SALESDATE_YM, MembershipSetup."Validate Age Against"::PERIODBEGIN_YM, MembershipSetup."Validate Age Against"::PERIODEND_YM]) then
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

        if (ReferenceDateType in [MembershipSetup."Validate Age Against"::SALESDATE_YMD, MembershipSetup."Validate Age Against"::PERIODBEGIN_YMD, MembershipSetup."Validate Age Against"::PERIODEND_YMD]) then
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

    local procedure GetMembershipMemberCount(MembershipEntryNo: Integer): Integer
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

    internal procedure GetMembershipMemberCountForAlteration(MembershipEntryNo: Integer; MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup") MemberCount: Integer
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

        case MembershipAlterationSetup."Member Count Calculation" of
            MembershipAlterationSetup."Member Count Calculation"::NA:
                MemberCount := 0;
            MembershipAlterationSetup."Member Count Calculation"::NAMED:
                MemberCount := AdminMemberCount + MemberMemberCount;
            MembershipAlterationSetup."Member Count Calculation"::ANONYMOUS:
                MemberCount := AnonymousMemberCount;
            MembershipAlterationSetup."Member Count Calculation"::ALL:
                MemberCount := AdminMemberCount + MemberMemberCount + AnonymousMemberCount;
            else
                Error('Undefined Member Count Calculation %1', MembershipAlterationSetup."Member Count Calculation");
        end;

        exit(MemberCount);
    end;

    local procedure ConflictingLedgerEntries(MembershipEntryNo: Integer; StartDate: Date; EndDate: Date; var StartEntryNo: Integer; var EndEntryNo: Integer): Boolean
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

    internal procedure CalculatePeriodStartToDateFraction(Period_Start: Date; Period_End: Date; Period_Date: Date): Decimal
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

    local procedure AddMembershipLedgerEntry(MembershipEntryNo: Integer; MemberInfoCapture: Record "NPR MM Member Info Capture"; ValidFromDate: Date; ValidUntilDate: Date; var MembershipScheduledForUpdate: Boolean): Integer
    var
        MembershipLedgerEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        MembershipRole: Record "NPR MM Membership Role";
        PendingCustomerUpdate: Record "NPR MM Pending Customer Update";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
        MemberNotification: Codeunit "NPR MM Member Notification";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
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

        Membership.Get(MembershipEntryNo);
        if (not MembershipSetup.Get(MembershipLedgerEntry."Membership Code")) then
            MembershipSetup.Init();

        MembershipScheduledForUpdate := false;
        if (MembershipLedgerEntry.Context in [MembershipLedgerEntry.Context::UPGRADE, MembershipLedgerEntry.Context::RENEW, MembershipLedgerEntry.Context::AUTORENEW]) then begin
            if (Membership."Customer No." <> '') then begin
                if (MembershipSetup."Customer Config. Template Code" <> '') then begin
                    ConfigTemplateHeader.Get(MembershipSetup."Customer Config. Template Code");
                    if (Customer.Get(Membership."Customer No.")) then
                        if (MembershipSetup."Defer Cust. Update Alterations" and (MembershipLedgerEntry."Valid From Date" > WorkDate())) then begin
                            PendingCustomerUpdate.Init();
                            PendingCustomerUpdate."Entry No." := 0;
                            PendingCustomerUpdate.MembershipEntryNo := MembershipLedgerEntry."Membership Entry No.";
                            PendingCustomerUpdate."Customer No." := Customer."No.";
                            PendingCustomerUpdate."Customer Config. Template Code" := MembershipSetup."Customer Config. Template Code";
                            PendingCustomerUpdate.MembershipCode := MembershipLedgerEntry."Membership Code";
                            PendingCustomerUpdate."Valid From Date" := MembershipLedgerEntry."Valid From Date";
                            PendingCustomerUpdate.Insert();
                            MembershipScheduledForUpdate := true;
                        end else begin
                            RecRef.GetTable(Customer);
                            ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                            RecRef.SetTable(Customer);
                            Customer.Modify(true);
                        end;
                end;
            end;
        end;

        MembershipEvents.OnAfterInsertMembershipEntry(MembershipLedgerEntry);
        _MembershipWebhooks.TriggerMembershipEntryWebhookCall(Membership.SystemId, MembershipLedgerEntry.SystemId);

        if (not MembershipLedgerEntry."Activate On First Use") then begin
            AddMembershipRenewalNotification(MembershipLedgerEntry);
            if MembershipLedgerEntry.Context <> MembershipLedgerEntry.Context::REGRET then
                SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(MembershipLedgerEntry);
        end;

        if ((MembershipSetup."Enable NP Pass Integration") and
            (MemberInfoCapture."Information Context" <> MemberInfoCapture."Information Context"::FOREIGN)) then begin

            if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::NEW) then begin
                ; // The create notification is created when first member is added.

            end else begin
                MembershipRole.SetFilter("Membership Entry No.", '=%1', Membership."Entry No.");
                MembershipRole.SetFilter(Blocked, '=%1', false);
                MembershipRole.SetFilter("Wallet Pass Id", '<>%1', '');
                if (not MembershipRole.IsEmpty()) then begin

                    if (MembershipLedgerEntry."Valid From Date" >= Today()) then
                        MemberNotification.CreateUpdateWalletNotification(Membership."Entry No.", 0, 0, MembershipLedgerEntry."Valid From Date");

                    if (MembershipLedgerEntry."Valid From Date" <> Today()) then
                        MemberNotification.CreateUpdateWalletNotification(Membership."Entry No.", 0, 0, Today());

                end;

                MembershipRole.SetFilter("Wallet Pass Id", '=%1', '');
                if (not MembershipRole.IsEmpty()) then begin

                    MemberNotification.CreateWalletSendNotification(Membership."Entry No.", 0, 0, Today());

                    if (MembershipLedgerEntry."Valid From Date" > Today()) then
                        MemberNotification.CreateUpdateWalletNotification(Membership."Entry No.", 0, 0, MembershipLedgerEntry."Valid From Date");

                end;

            end;
        end;

        if MemberInfoCapture."Information Context" in [MemberInfoCapture."Information Context"::AUTORENEW, MemberInfoCapture."Information Context"::RENEW] then
            AddMembershipRenewalSuccessNotification(MembershipLedgerEntry);

        if MemberInfoCapture."Enable Auto-Renew" then
            MemberNotification.AddMembershipAutoRenewalEnableNotification(MembershipLedgerEntry."Membership Entry No.", MembershipLedgerEntry."Membership Code");

        exit(MembershipLedgerEntry."Entry No.");
    end;

    internal procedure ActivateMembershipLedgerEntry(MembershipEntryNo: Integer; ActivationDate: Date)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MemberCard: Record "NPR MM Member Card";
        MembershipSetup: Record "NPR MM Membership Setup";
        SubscriptionMgtImpl: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin

        Membership.Get(MembershipEntryNo);

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipEntry.FindFirst()) then
            Error(NO_LEDGER_ENTRY, Membership."External Membership No.");

        if (not MembershipEntry."Activate On First Use") then
            exit; // Already activated

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
        _MembershipWebhooks.TriggerMembershipActivatedWebhookCall(Membership.SystemId, MembershipEntry.SystemId);

        AddMembershipRenewalNotification(MembershipEntry);
        SubscriptionMgtImpl.UpdateMembershipSubscriptionDetails(Membership, MembershipEntry);

    end;

    internal procedure MembershipNeedsActivation(MembershipEntryNo: Integer): Boolean
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
        if (not MembershipEntry.FindFirst()) then
            exit(true); // :)

        exit(MembershipEntry."Activate On First Use");
    end;

    local procedure GetCommunityMembership(MembershipCode: Code[20]; CreateWhenMissing: Boolean): Integer
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
            Membership."Issued Date" := Today();

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

    local procedure GetNewMembership(MembershipCode: Code[20]; MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateWhenMissing: Boolean): Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Community: Record "NPR MM Member Community";
        Membership: Record "NPR MM Membership";
        MMPaymentMethodMgt: Codeunit "NPR MM Payment Method Mgt.";
        MembershipCreated: Boolean;
        MissingCustomerNoErr: Label 'Each membership must have a link to a customer in order for the system to store the payment token.';
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
            Membership."Issued Date" := Today();
            Membership."Document ID" := MemberInfoCapture."Import Entry Document ID";
            Membership."Modified At" := CurrentDateTime();
            if (MemberInfoCapture."Information Context" = MemberInfoCapture."Information Context"::FOREIGN) then
                Membership."Replicated At" := CurrentDateTime();
            if (MemberInfoCapture."Enable Auto-Renew") then
                Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;

            Membership.Insert(true);
            MembershipCreated := true;
        end;

        Membership.FindFirst();
        if (Community."Membership to Cust. Rel.") then begin
            if (Membership."Customer No." = '') then begin

                MembershipEvents.OnBeforeAssignCustomerNo(MemberInfoCapture);
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
        if MemberInfoCapture."Member Payment Method" <> 0 then begin
            if Membership."Customer No." = '' then
                Error(MissingCustomerNoErr);
            MMPaymentMethodMgt.SetMemberPaymentMethodAsDefault(Membership, MemberInfoCapture."Member Payment Method");
        end;

        TransferInfoCaptureAttributes(MemberInfoCapture."Entry No.", Database::"NPR MM Membership", Membership."Entry No.");

        if (MembershipCreated) then
            MembershipEvents.OnAfterMembershipCreateEvent(Membership);

        exit(Membership."Entry No.");
    end;

    local procedure CreateCustomerFromTemplate(CustomerNoSeriesCode: Code[20]; CustTemplateCode: Code[10]; ContTemplateCode: Code[10]; ExternalCustomerNo: Code[20]): Code[20]
    var
        Contact: Record Contact;
        ContBusRelation: Record "Contact Business Relation";
        Customer: Record Customer;
        ConfigTemplateHeader: Record "Config. Template Header";
        ConfigTemplateMgt: Codeunit "Config. Template Management";
        RecRef: RecordRef;
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin

        if (CustTemplateCode = '') then
            Error(MISSING_TEMPLATE, CustTemplateCode);

        if (not ConfigTemplateHeader.Get(CustTemplateCode)) then
            Error(MISSING_TEMPLATE, CustTemplateCode);

        Customer.Init();
        Customer."No." := '';

        if (CustomerNoSeriesCode <> '') then
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            Customer."No." := NoSeriesManagement.GetNextNo(CustomerNoSeriesCode, 0D, false);
#ELSE
            Customer."No." := NoSeriesManagement.GetNextNo(CustomerNoSeriesCode, 0D, true);
#ENDIF

        Customer."NPR External Customer No." := ExternalCustomerNo;
        Customer.Insert(true);

        RecRef.GetTable(Customer);
        ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
        RecRef.SetTable(Customer);

        MembershipEvents.OnAfterCustomerCreate(Customer);
        Customer.Modify(true);

        if (ContTemplateCode <> '') and ConfigTemplateHeader.Get(ContTemplateCode) then begin
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
            ContBusRelation.ReadIsolation := IsolationLevel::ReadUncommitted;
#ENDIF 
            ContBusRelation.SetCurrentKey("Link to Table", "No.");
            ContBusRelation.SetFilter("Link to Table", '=%1', ContBusRelation."Link to Table"::Customer);
            ContBusRelation.SetFilter("No.", '=%1', Customer."No.");

            if (ContBusRelation.FindFirst() and Contact.Get(ContBusRelation."Contact No.")) then begin
                RecRef.GetTable(Contact);
                ConfigTemplateMgt.UpdateRecord(ConfigTemplateHeader, RecRef);
                RecRef.SetTable(Contact);

                MembershipEvents.OnAfterContactCreate(Customer, Contact);
                Contact.Modify(true);
            end;
        end;


        exit(Customer."No.");
    end;

    local procedure UpdateCustomerFromMember(Membership: Record "NPR MM Membership"; MemberEntryNo: Integer)
    var
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
        Community: Record "NPR MM Member Community";
#if not BC17
        SpfyCustomerMgt: Codeunit "NPR Spfy Customer Mgt.";
#endif
    begin
        Member.Get(MemberEntryNo);
        MembershipRole.Get(Membership."Entry No.", MemberEntryNo);

        if (not Community.Get(Membership."Community Code")) then
            Community.Init();
        if (Community.MemberDefaultCountryCode = '') then
            Community.MemberDefaultCountryCode := 'DK';

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
            if (Customer.Name = '') then
                Customer.Validate(Name, CopyStr(Member."Display Name", 1, MaxStrLen(Customer.Name)));
        end else begin
            if (Customer.Name = '') then
                Customer.Validate(Name, Membership."Company Name");
            Customer.Validate("Name 2", CopyStr(Member."Display Name", 1, MaxStrLen(Customer."Name 2")));
        end;

        Customer.Validate(Address, CopyStr(Member.Address, 1, MaxStrLen(Customer.Address)));

        //** shifted order since BC clears city and postcode when country code is validated
        // the magento integration requires a country code, until "mandatory fields" have been implemented for member creation
        // this should remain.
        Customer.Validate("Country/Region Code", CopyStr(Member."Country Code", 1, MaxStrLen(Customer."Country/Region Code")));
        if (Customer."Country/Region Code" = '') then
            Customer.Validate("Country/Region Code", Community.MemberDefaultCountryCode);

        Customer.Validate(City, CopyStr(Member.City, 1, MaxStrLen(Customer.City)));
        Customer.Validate("Post Code", CopyStr(Member."Post Code Code", 1, MaxStrLen(Customer."Post Code")));

        Customer.Validate("Phone No.", CopyStr(Member."Phone No.", 1, MaxStrLen(Customer."Phone No.")));
        Customer.Validate("E-Mail", CopyStr(Member."E-Mail Address", 1, MaxStrLen(Customer."E-Mail")));
        if (Membership.Blocked) then
            Customer.Validate(Blocked, Customer.Blocked::All)
        else
            Customer.Validate(Blocked, Customer.Blocked::" ");

        Customer.Modify();
#if not BC17
        SpfyCustomerMgt.UpdateMarketingConsentState(Member, Customer."No.");
        SpfyCustomerMgt.AutoEnableCustomerSync(Customer);
#endif

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

                UpdateContactFromMember(Membership."Entry No.", Member);
            end;
        end;
    end;

    [CommitBehavior(CommitBehavior::Error)]
    internal procedure UpdateContactFromMember(MembershipEntryNo: Integer; Member: Record "NPR MM Member")
    var
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
        Contact: Record Contact;
        ContactXRec: Record Contact;
        Community: Record "NPR MM Member Community";
        MagentoSetup: Record "NPR Magento Setup";
        HaveContact: Boolean;
    begin

        Membership.Get(MembershipEntryNo);
        MembershipRole.Get(MembershipEntryNo, Member."Entry No.");
        if (not Community.Get(Membership."Community Code")) then
            Community.Init();
        if (Community.MemberDefaultCountryCode = '') then
            Community.MemberDefaultCountryCode := 'DK';

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
            Contact.Validate("Country/Region Code", Community.MemberDefaultCountryCode);

        Contact.Validate(City, CopyStr(Member.City, 1, MaxStrLen(Contact.City)));
        Contact.Validate("Post Code", CopyStr(Member."Post Code Code", 1, MaxStrLen(Contact."Post Code")));

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
                    Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::ACTIVE;

                    if (Member."Block Reason" = Member."Block Reason"::ANONYMIZED) then
                        Contact."NPR Magento Contact" := false;

                    if ((Member.Blocked) or (Member."E-Mail Address" = '')) then
                        Contact."NPR Magento Account Status" := Contact."NPR Magento Account Status"::BLOCKED;
                end;
        end;

        Contact.Modify(true);

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

    local procedure AddCommunityMember(MembershipEntryNo: Integer; NumberOfMembers: Integer): Integer
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

    local procedure SetMemberFields(var Member: Record "NPR MM Member"; MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        CurrentMember: Record "NPR MM Member";
        CountryRegion: Record "Country/Region";
        PostCode: Record "Post Code";
        TempBlob: Codeunit "Temp Blob";
        InStr: InStream;
        OutStr: OutStream;
        CountryName: Text;
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin

        CurrentMember.Copy(Member);
        MembershipEvents.OnBeforeSetMemberFields(Member, MemberInfoCapture);

#pragma warning disable AA0139
        Member."First Name" := DeleteCtrlChars(MemberInfoCapture."First Name");
        Member."Middle Name" := DeleteCtrlChars(MemberInfoCapture."Middle Name");
        Member."Last Name" := DeleteCtrlChars(MemberInfoCapture."Last Name");
        Member.Address := DeleteCtrlChars(MemberInfoCapture.Address);
#pragma warning restore
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
            if (CountryRegion.Get(UpperCase(CopyStr(MemberInfoCapture.Country, 1, MaxStrLen(CountryRegion.Code))))) then begin
                Member."Country Code" := CountryRegion.Code;
                Member.Country := CountryRegion.Name;
            end else begin
                CountryName := MemberInfoCapture.Country;
                if (StrLen(MemberInfoCapture.Country) > 1) then
                    CountryName := StrSubstNo(PlaceHolderLbl, UpperCase(CopyStr(MemberInfoCapture.Country, 1, 1)), LowerCase(CopyStr(MemberInfoCapture.Country, 2)));

                CountryRegion.SetFilter(Name, '=%1|=%2|=%3', CountryName, UpperCase(CountryName), MemberInfoCapture.Country);
                if (CountryRegion.FindFirst()) then begin
                    Member."Country Code" := CountryRegion.Code;
                    Member.Country := CountryRegion.Name;
                end;
            end;
        end;

        Member."E-Mail Address" := LowerCase(MemberInfoCapture."E-Mail Address");
#pragma warning disable AA0139
        Member."E-Mail Address" := DeleteCtrlChars(Member."E-Mail Address");
#pragma warning restore
        Member."Phone No." := MemberInfoCapture."Phone No.";
        Member."Social Security No." := MemberInfoCapture."Social Security No.";
        Member.Gender := MemberInfoCapture.Gender;
        Member.Birthday := MemberInfoCapture.Birthday;
        Member."E-Mail News Letter" := MemberInfoCapture."News Letter";
        Member.PreferredLanguageCode := MemberInfoCapture.PreferredLanguageCode;

        Member."Notification Method" := MemberInfoCapture."Notification Method";

        if (MemberInfoCapture."Notification Method" = MemberInfoCapture."Notification Method"::DEFAULT) then begin
            Member."Notification Method" := MemberInfoCapture."Notification Method"::EMAIL;
            if ((Member."Phone No." <> '') and (Member."E-Mail Address" = '')) then
                Member."Notification Method" := MemberInfoCapture."Notification Method"::SMS;
        end;

        if (MemberInfoCapture.Image.HasValue()) then begin
            TempBlob.CreateOutStream(OutStr);
            MemberInfoCapture.Image.ExportStream(OutStr);
            TempBlob.CreateInStream(InStr);
            Member.Image.ImportStream(InStr, Member.FieldName(Image));
        end;

        Member."Display Name" := GetDisplayName(Member);
        Member."Store Code" := MemberInfoCapture."Store Code";

        MembershipEvents.OnAfterSetMemberFields(Member, MemberInfoCapture);
        MembershipEvents.OnAfterMemberFieldsAssignmentEvent(CurrentMember, Member);

        exit;
    end;


    internal procedure GetDisplayName(Member: Record "NPR MM Member") DisplayName: Text[100]
    begin

        DisplayName := Member."Last Name";

        if ((StrLen(Member."First Name") + StrLen(Member."Last Name")) < MaxStrLen(DisplayName)) then
            DisplayName := CopyStr(StrSubstNo('%1 %2', Member."First Name", Member."Last Name"), 1, MaxStrLen(DisplayName));

        if (StrLen(Member."Middle Name") > 0) then
            if (StrLen(Member."First Name") + StrLen(Member."Middle Name") + StrLen(Member."Last Name") + 2 <= MaxStrLen(Member."Display Name")) then
                DisplayName := CopyStr(StrSubstNo('%1 %2 %3', Member."First Name", Member."Middle Name", Member."Last Name"), 1, MaxStrLen(DisplayName));

        exit(DisplayName);
    end;

    internal procedure ValidateMemberFields(MembershipEntryNo: Integer; Member: Record "NPR MM Member"; ResponseMessage: Text): Boolean
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
            Community."Member Unique Identity"::EMAIL_AND_PHONE:
                UniqIdSet := (Member."E-Mail Address" <> '') AND (Member."Phone No." <> '');
            Community."Member Unique Identity"::EMAIL_OR_PHONE:
                UniqIdSet := (Member."E-Mail Address" <> '') OR (Member."Phone No." <> '');
            Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME:
                UniqIdSet := (Member."E-Mail Address" <> '') AND (Member."First Name" <> '');
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
    begin

        Member.Get(MemberEntryNo);
        Membership.Get(MembershipEntryNo);

        // When community is REUSE and a membership is created with multiple members and they share the same unique identity
        if (MembershipRole.Get(MembershipEntryNo, MemberEntryNo)) then begin
            MemberCount := GetMembershipMemberCount(MembershipEntryNo);
            exit(true);
        end;

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
        MembershipRole."GDPR Data Subject Id" := CreateDataSubjectId();

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
                                MembershipRole."GDPR Data Subject Id" := CreateDataSubjectId();
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
                MembershipRole."GDPR Data Subject Id" := CreateDataSubjectId();
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
        Membership: Record "NPR MM Membership";
    begin
        Membership.Get(MembershipEntryNo);
        exit(IssueMemberCardWorker(MembershipEntryNo, MemberEntryNo, MemberInfoCapture, AllowBlankNumber, CardEntryNo, Membership."Membership Code", ReasonMessage, ForceValidUntilDate));
    end;

    local procedure IssueMemberCardWorker(MembershipEntryNo: Integer; MemberEntryNo: Integer; var MemberInfoCapture: Record "NPR MM Member Info Capture"; AllowBlankNumber: Boolean; var CardEntryNo: Integer; TargetMembershipCode: Code[20]; var ReasonMessage: Text; ForceValidUntilDate: Boolean): Boolean
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        MembershipEntry: Record "NPR MM Membership Entry";
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
        MembershipSetup.Get(TargetMembershipCode);
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

        if (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::GENERATED) then
            if (MemberInfoCapture."External Card No." = '') then
                GenerateExtCardNoSimple(MembershipSetup.Code, MemberInfoCapture);

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

        // Override ValidUntil when f.ex. memberships is new and there is no membership entry to sync with
        CardValidUntil := MemberInfoCapture."Valid Until";
        if ((MemberInfoCapture."Valid Until" = 0D) or (MembershipSetup."Card Number Scheme" = MembershipSetup."Card Number Scheme"::GENERATED)) then begin
            if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::"DATEFORMULA") then
                MemberInfoCapture."Valid Until" := CalcDate(MembershipSetup."Card Number Valid Until", Today);

            if (MembershipSetup."Card Expire Date Calculation" = MembershipSetup."Card Expire Date Calculation"::SYNCHRONIZED) then begin
                MembershipEntry.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
                MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
                MembershipEntry.SetFilter(Blocked, '=%1', false);
                if (MembershipEntry.FindLast()) then
                    if (not MembershipEntry."Activate On First Use") then
                        MemberInfoCapture."Valid Until" := MembershipEntry."Valid Until Date";
            end;
        end;

        MemberCard."External Card No." := MemberInfoCapture."External Card No.";
#pragma warning disable AA0139
        if (StrLen(MemberCard."External Card No.") > 4) then
            MemberCard."External Card No. Last 4" := CopyStr(MemberCard."External Card No.", StrLen(MemberCard."External Card No.") - 4 + 1);
#pragma warning restore
        MemberCard."Pin Code" := MemberInfoCapture."Pin Code";
        MemberCard."Valid Until" := MemberInfoCapture."Valid Until";

        if (ForceValidUntilDate) then
            MemberCard."Valid Until" := CardValidUntil;

        MemberCard."Card Is Temporary" := MemberInfoCapture."Temporary Member Card";

        MemberCard.Modify();

        CardEntryNo := MemberCard."Entry No.";
        exit(CardEntryNo <> 0);

    end;

    local procedure EncodeSHA1(Plain: Text): Text[80]
    begin
        // Should be obsoleted
        exit(CopyStr(Plain, 1, 80));
    end;

    local procedure AssignExternalMembershipNo(CommunityCode: Code[20]) ExternalNo: Code[20]
    var
        Community: Record "NPR MM Member Community";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
    begin

        Community.Get(CommunityCode);
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ExternalNo := NoSeriesManagement.GetNextNo(Community."External Membership No. Series", Today, false);
#ELSE
        ExternalNo := NoSeriesManagement.GetNextNo(Community."External Membership No. Series", Today, true);
#ENDIF
    end;

    local procedure AssignExternalMemberNo(SuggestedExternalNo: Code[20]; CommunityCode: Code[20]) ExternalNo: Code[20]
    var
        Community: Record "NPR MM Member Community";
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        Member: Record "NPR MM Member";
        ConflictLbl: Label 'Multiple members share the same external member number (%1). Verify number series %2 for issues. This action can not be completed until this has been attended.';
    begin

        Community.Get(CommunityCode);
        if (SuggestedExternalNo <> '') then begin
            NoSeriesManagement.TestManual(Community."External Member No. Series");
            exit(SuggestedExternalNo);
        end;

#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        ExternalNo := NoSeriesManagement.GetNextNo(Community."External Member No. Series", Today, false);
#ELSE
        ExternalNo := NoSeriesManagement.GetNextNo(Community."External Member No. Series", Today, true);
#ENDIF

        Member.SetCurrentKey("External Member No.");
        Member.SetFilter("External Member No.", '=%1', ExternalNo);
        if (not Member.IsEmpty()) then
            Error(ConflictLbl, ExternalNo, Community."External Member No. Series");
    end;

    local procedure GenerateExtCardNoSimple(MembershipCode: Code[20]; var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        BaseNumberPadding: Code[100];
        PAN: Code[100];
        PanLength: Integer;
        PlaceHolderLbl: Label '%1%2', Locked = true;
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

        PAN := StrSubstNo(PlaceHolderLbl, MembershipSetup."Card Number Prefix", CopyStr(BaseNumberPadding, 1, PanLength));

        case MembershipSetup."Card Number Validation" of
            MembershipSetup."Card Number Validation"::NONE:
                ;
            MembershipSetup."Card Number Validation"::CHECKDIGIT:
                PAN := StrSubstNo(PlaceHolderLbl, PAN, GenerateRandom('N'));
        end;

        if (StrLen(PAN) > MaxStrLen(MemberInfoCapture."External Card No.")) then
            Error(PAN_TO_LONG, MaxStrLen(MemberInfoCapture."External Card No."), MembershipSetup."Card Number Pattern");

        MemberInfoCapture."External Card No." := PAN;
        MemberInfoCapture."Pin Code" := GenerateRandom('N') + GenerateRandom('N') + GenerateRandom('N') + GenerateRandom('N');

    end;

#pragma warning disable AA0139
    internal procedure GenerateExtCardNo(GeneratePattern: Text[30]; ExternalMemberNo: Code[20]; ExternalMembershipNo: Code[20]; NumberSeries: Code[20]) ExtCardNo: Code[50]
    var
        PosStartClause: Integer;
        PosEndClause: Integer;
        Pattern: Text[5];
        PatternLength: Integer;
        Itt: Integer;
        Left: Text[10];
        Right: Text[10];
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
        NoSeriesManagement: Codeunit "No. Series";
#ELSE
        NoSeriesManagement: Codeunit NoSeriesManagement;
#ENDIF
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin
        if (GeneratePattern = '') then
            exit;

        // Pattern example TEXT-[MA][N*5]-[N]
        // MA MemberAccount (external)
        // MS MemberShip (external)
        // S Number Series
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
                        ExtCardNo := StrSubstNo(PlaceHolderLbl, ExtCardNo, ExternalMemberNo);
                    'MS':
                        ExtCardNo := StrSubstNo(PlaceHolderLbl, ExtCardNo, ExternalMembershipNo);
                    'S':
#IF NOT (BC17 OR BC18 OR BC19 OR BC20 OR BC21 OR BC22 OR BC23)
                        ExtCardNo := StrSubstNo(PlaceHolderLbl, ExtCardNo, NoSeriesManagement.GetNextNo(NumberSeries, Today, false));
#ELSE
                        ExtCardNo := StrSubstNo(PlaceHolderLbl, ExtCardNo, NoSeriesManagement.GetNextNo(NumberSeries, Today, true));
#ENDIF
                    'N', 'A', 'X':
                        begin
                            Evaluate(PatternLength, Right);
                            for Itt := 1 to PatternLength do
                                ExtCardNo := StrSubstNo(PlaceHolderLbl, ExtCardNo, GenerateRandom(Left));
                        end;
                    else begin
                        ExtCardNo := StrSubstNo(PlaceHolderLbl, ExtCardNo, Pattern);
                    end;
                end;
            end;

            if (StrLen(GeneratePattern) > PosEndClause) then
                GeneratePattern := CopyStr(GeneratePattern, PosEndClause + 1)
            else
                GeneratePattern := '';

        end;
    end;
#pragma warning restore

    local procedure GenerateRandom(Pattern: Code[2]) Random: Code[1]
    var
        Number: Integer;
        RandomCharacter: Code[1];
    begin
        Number := GetRandom(2);
        case Pattern of
            'N':
                Random := Format(Number mod 10);
            'A':
                RandomCharacter[1] := (Number mod 25) + 65;
            'X':
                begin
                    if (GetRandom(2) mod 35) < 10 then
                        Random := Format(Number mod 10)
                    else
                        RandomCharacter[1] := (Number mod 25) + 65;
                end;
        end;

        if (Random = '') then
            exit(RandomCharacter);
    end;

    local procedure GetRandom(Bytes: Integer) RandomInt: Integer
    var
        i: Integer;
        RandomHexString: Code[50];
    begin
#pragma warning disable AA0139
        RandomHexString := UpperCase(DelChr(Format(CreateGuid()), '=', '{}-'));
#pragma warning restore
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
        MemberCommunity: Record "NPR MM Member Community";
    begin

        if (LogonId = '') then
            exit(false);

        MemberCommunity.Get(CommunityCode);
        if (MemberCommunity."Member Logon Credentials" = MemberCommunity."Member Logon Credentials"::NA) then
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

        if (ContactBusinessRelation.IsEmpty()) then
            if (Contact."Company No." <> '') then
                ContactBusinessRelation.SetFilter("Contact No.", '=%1', Contact."Company No.");

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
                    Community."Member Unique Identity"::EMAIL_AND_PHONE:
                        MemberLogonId := Member."E-Mail Address";
                    Community."Member Unique Identity"::EMAIL_OR_PHONE:
                        MemberLogonId := Member."E-Mail Address";
                    Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME:
                        MemberLogonId := Member."E-Mail Address";
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

    local procedure RaiseError(var ResponseMessage: Text; MessageText: Text; MessageId: Text): Integer
    var
        PlaceHolderLbl: Label '[%1] - %2', Locked = true;
    begin
        ResponseMessage := MessageText;

        if (MessageId <> '') then
            ResponseMessage := StrSubstNo(PlaceHolderLbl, MessageId, MessageText);

        Error(ResponseMessage);
    end;

    local procedure ExitFalseOrWithError(VerboseMessage: Boolean; ErrorMessage: Text): Boolean
    begin

        if (VerboseMessage) then
            Error(ErrorMessage);

        exit(false);
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

    internal procedure GetMembershipFromUserPassword(UserLogonId: Code[80]; Password: Text[80]) MembershipEntryNo: Integer
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

    internal procedure GetMembershipFromExtMemberNo(ExternalMemberNo: Code[20]) MembershipEntryNo: Integer
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

    internal procedure GetMembershipFromExtCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text) MembershipEntryNo: Integer
    var
        CardEntryNo: Integer;
    begin

        // local check to find cardnumber
        if (StrLen(ExternalCardNo) <= 50) then
            MembershipEntryNo := GetMembershipFromExtCardNoWorker(ExternalCardNo, ReferenceDate, ReasonNotFound, CardEntryNo);

        // Foreign cards might have more information then just a raw card number.
        if (MembershipEntryNo = 0) then
            MembershipEntryNo := GetMembershipFromForeignCardNo(ExternalCardNo, ReferenceDate, CardEntryNo);

    end;

    local procedure GetMembershipFromForeignCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var CardEntryNo: Integer) MembershipEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        RemoteReasonText: Text;
        ForeignMembershipMgr: Codeunit "NPR MM Foreign Members. Mgr.";
        FormatedCardNumber: Text[100];
        PlaceHolderLbl: Label '%1%2', Locked = true;
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
                        MembershipEntryNo := GetMembershipFromExtCardNoWorker(StrSubstNo(PlaceHolderLbl, ForeignMembershipSetup."Append Local Prefix", ExternalCardNo), ReferenceDate, RemoteReasonText, CardEntryNo);
                end;

                // try remote number with integration code to parse the scanned card data
                if (MembershipEntryNo = 0) then begin
                    ForeignMembershipMgr.FormatForeignCardNumberFromScan(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code", ExternalCardNo, FormatedCardNumber);
                    MembershipEntryNo := GetMembershipFromExtCardNoWorker(FormatedCardNumber, ReferenceDate, RemoteReasonText, CardEntryNo);
                end;

                if (MembershipEntryNo <> 0) then
                    if (Membership.Get(MembershipEntryNo)) then
                        ForeignMembershipMgr.SynchronizeLoyaltyPoints(ForeignMembershipSetup."Community Code", ForeignMembershipSetup."Manager Code", MembershipEntryNo, ExternalCardNo);

            until ((ForeignMembershipSetup.Next() = 0) or (MembershipEntryNo <> 0));
        end;

    end;

    local procedure GetMembershipFromExtCardNoWorker(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text; var CardEntryNo: Integer): Integer
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
            ReferenceDate := WorkDate();

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

    internal procedure GetMembershipFromExtMembershipNo(ExternalMembershipNo: Code[20]) MembershipEntryNo: Integer
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

    internal procedure GetMembershipFromCustomerNo(CustomerNo: Code[20]) MembershipEntryNo: Integer
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

    internal procedure GetMemberFromExtMemberNo(ExternalMemberNo: Code[20]) MemberEntryNo: Integer
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

    internal procedure GetMemberFromExtCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var NotFoundReasonText: Text) MemberEntryNo: Integer
    var
        Member: Record "NPR MM Member";
        MemberCard: Record "NPR MM Member Card";
        MembershipEntryNo: Integer;
        CardEntryNo: Integer;
    begin

        NotFoundReasonText := '';

        if (ReferenceDate = 0D) then
            ReferenceDate := Today();

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

        exit(ValidateGetMember(MemberCard."Member Entry No.", MemberCard."Membership Entry No.", NotFoundReasonText));

    end;

    internal procedure GetMemberFromUserPassword(UserLogonId: Code[50]; Password: Text[50]) MemberEntryNo: Integer
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

    internal procedure GetMemberCardEntryNo(MemberEntryNo: Integer; MembershipCode: Code[20]; ReferenceDate: Date) MemberCardEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        Member: Record "NPR MM Member";
        MembershipSetup: Record "NPR MM Membership Setup";
    begin

        if (not Member.Get(MemberEntryNo)) then
            exit(0);

        if (ReferenceDate < Today) then
            ReferenceDate := Today();

        MemberCard.SetCurrentKey("Member Entry No.");
        MemberCard.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
        MemberCard.SetFilter(Blocked, '=%1', false);

        MembershipSetup.Get(MembershipCode);
        if (MembershipSetup."Card Expire Date Calculation" <> MembershipSetup."Card Expire Date Calculation"::NA) then
            MemberCard.SetFilter("Valid Until", '>=%1', ReferenceDate);

        if (not MemberCard.FindLast()) then
            exit(0);

        exit(MemberCard."Entry No.");
    end;

    internal procedure GetCardEntryNoFromExtCardNo(ExternalCardNo: Text[100]) CardEntryNo: Integer
    var
        MemberCard: Record "NPR MM Member Card";
        FoundMemberCard: Boolean;
        PrefixedCardNo: Text;
        ForeignMembershipSetup: Record "NPR MM Foreign Members. Setup";
        PlaceHolderLbl: Label '%1%2', Locked = true;
    begin

        MemberCard.SetCurrentKey("External Card No.");
        MemberCard.SetLoadFields("Entry No.", "External Card No.");
        MemberCard.SetFilter("External Card No.", '=%1|=%2', ExternalCardNo, EncodeSHA1(ExternalCardNo));
        MemberCard.SetFilter(Blocked, '=%1', false);

        FoundMemberCard := MemberCard.FindFirst();

        if (not FoundMemberCard) then begin
            ForeignMembershipSetup.SetCurrentKey("Invokation Priority");
            ForeignMembershipSetup.SetFilter(Disabled, '=%1', false);
            ForeignMembershipSetup.SetFilter("Community Code", '<>%1', '');
            ForeignMembershipSetup.SetFilter("Manager Code", '<>%1', '');
            if (ForeignMembershipSetup.FindSet()) then begin
                repeat

                    // try remote number with local prefix
                    PrefixedCardNo := ExternalCardNo;
                    if (ForeignMembershipSetup."Append Local Prefix" <> '') then
                        PrefixedCardNo := StrSubstNo(PlaceHolderLbl, ForeignMembershipSetup."Append Local Prefix", ExternalCardNo);

                    MemberCard.SetFilter("External Card No.", '=%1|=%2', PrefixedCardNo, EncodeSHA1(PrefixedCardNo));
                    FoundMemberCard := MemberCard.FindFirst();

                until ((ForeignMembershipSetup.Next() = 0) or (FoundMemberCard));
            end;
        end;

        if (not FoundMemberCard) then
            exit(0);

        exit(MemberCard."Entry No.");
    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateFindRecords', '', true, true)]
    local procedure OnAfterNavigateFindRecordsSubscriber(var DocumentEntry: Record "Document Entry"; DocNoFilter: Text; PostingDateFilter: Text)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
    begin

        if (MembershipEntry.ReadPermission()) then begin
            if (not MembershipEntry.SetCurrentKey("Receipt No.")) then;
            MembershipEntry.SetFilter("Receipt No.", '%1', DocNoFilter);
            InsertIntoDocEntry(DocumentEntry, Database::"NPR MM Membership Entry", 0, CopyStr(DocNoFilter, 1, 20), MembershipEntry.TableCaption(), MembershipEntry.Count());
        end;

    end;

    [EventSubscriber(ObjectType::Page, Page::Navigate, 'OnAfterNavigateShowRecords', '', true, true)]
    local procedure OnAfterNavigateShowRecordsSubscriber(TableID: Integer; DocNoFilter: Text; PostingDateFilter: Text; ItemTrackingSearch: Boolean)
    var
        MembershipEntry: Record "NPR MM Membership Entry";
        Membership: Record "NPR MM Membership";
        MembershipFilter: Text;
        PlaceHolderLbl: Label '|%1', Locked = true;
    begin

        if (TableID = Database::"NPR MM Membership Entry") then begin
            if (not MembershipEntry.SetCurrentKey("Receipt No.")) then;
            MembershipEntry.SetFilter("Receipt No.", DocNoFilter);
            MembershipEntry.FindSet();
            repeat
                MembershipFilter += StrSubstNo(PlaceHolderLbl, MembershipEntry."Membership Entry No.");
            until (MembershipEntry.Next() = 0);

            Membership.SetFilter("Entry No.", CopyStr(MembershipFilter, 2));

            if (Membership.Count() = 1) then begin
                Page.Run(Page::"NPR MM Membership Card", Membership);
            end else begin
                Page.Run(Page::"NPR MM Memberships", Membership);
            end;
        end;

    end;

    local procedure InsertIntoDocEntry(var DocumentEntry: Record "Document Entry" temporary; DocTableID: Integer; DocType: Integer; DocNoFilter: Code[20]; DocTableName: Text; DocNoOfRecords: Integer): Integer
    begin

        if (DocNoOfRecords = 0) then
            exit(DocNoOfRecords);

        DocumentEntry.Init();
        DocumentEntry."Entry No." := DocumentEntry."Entry No." + 1;
        DocumentEntry."Table ID" := DocTableID;
#if BC17         
        DocumentEntry."Document Type" := DocType;
#else        
        DocumentEntry."Document Type" := "Document Entry Document Type".FromInteger(DocType);
#endif
        DocumentEntry."Document No." := DocNoFilter;
        DocumentEntry."Table Name" := CopyStr(DocTableName, 1, MaxStrLen(DocumentEntry."Table Name"));
        DocumentEntry."No. of Records" := DocNoOfRecords;
        DocumentEntry.Insert();

        exit(DocNoOfRecords);

    end;

    internal procedure DeleteCtrlChars(StringToClean: Text): Text
    var
        CtrlChrs: Text[32];
        i: Integer;
    begin

        for i := 1 to 31 do
            CtrlChrs[i] := i;

        StringToClean := DelChr(StringToClean, '<>', ' ');

        exit(DelChr(StringToClean, '=', CtrlChrs));

    end;

    internal procedure FindPersonByFacialRecognition(TableID: Integer) PersonId: Text[50]
    var
        MCSPersonGroupsSetup: Record "NPR MCS Person Groups Setup";
        PersonGroups: Record "NPR MCS Person Groups";
        Camera: Page "NPR NPCamera";
        MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
        PictureStream: InStream;
        JsonFacesArr, JsonIdArr : JsonArray;
        NoFaceErr: Label 'No face detected.';
        FaceNotIdentifiedErr: Label 'Face not identified.';
    begin
        if (Camera.TakePicture(PictureStream)) then begin
            MCSPersonGroupsSetup.Get(TableID);
            PersonGroups.Get(MCSPersonGroupsSetup."Person Groups Id");
            PersonGroups.TestField(PersonGroupId);
            MCSFaceServiceAPI.DetectFaces(PictureStream, JsonFacesArr);
            if (JsonFacesArr.Count() = 0) then
                Error(NoFaceErr);
            MCSFaceServiceAPI.IdentifyFace(PersonGroups.PersonGroupId, JsonFacesArr, JsonIdArr);
            if (JsonIdArr.Count() = 0) then
                Error(FaceNotIdentifiedErr);
            PersonId := MCSFaceServiceAPI.FindMember(PersonGroups, JsonFacesArr, JsonIdArr);
        end;
    end;

    internal procedure TakeMemberInfoPicture(MMMemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        Camera: Page "NPR NPCamera";
        PictureStream: InStream;
    begin
        if (Camera.TakePicture(PictureStream)) then begin
            MMMemberInfoCapture.Image.ImportStream(PictureStream, MMMemberInfoCapture.FieldName(Image));
            MMMemberInfoCapture.Modify();
        end
    end;

    internal procedure TakeMemberPicture(MMMember: Record "NPR MM Member")
    var
        Camera: Page "NPR NPCamera";
        PictureStream: InStream;
        MemberMedia: Codeunit "NPR MMMemberImageMediaHandler";
    begin
        if (Camera.TakePicture(PictureStream)) then begin

            if (MemberMedia.IsFeatureEnabled()) then begin
                MemberMedia.PutMemberImageFromStream(MMMember.SystemId, '', PictureStream);
            end else begin
                MMMember.Image.ImportStream(PictureStream, MMMember.FieldName(Image));
                MMMember.Modify();
            end;

            Commit();
            TrainFacialRecognitionService(MMMember, PictureStream);
        end
    end;

    local procedure TrainFacialRecognitionService(MMMember: Record "NPR MM Member"; PictureStream: InStream)
    var
        RecRef: RecordRef;
        MCSFaceServiceAPI: Codeunit "NPR MCS Face Service API";
        MemberName: Text;
    begin
        RecRef.Get(MMMember.RecordId);
        MemberName := MMMember."First Name";
        if (MMMember."Middle Name" <> '') then
            MemberName := MemberName + ' ' + MMMember."Middle Name";
        if (MMMember."Last Name" <> '') then
            MemberName := MemberName + ' ' + MMMember."Last Name";
        MCSFaceServiceAPI.DetectIdentifyPicture(RecRef, MemberName, PictureStream);
    end;

    local procedure CreateDataSubjectId(): Text[35]
    begin
#pragma warning disable AA0139
        exit(UpperCase(DelChr(Format(CreateGuid()), '=', '{}-')));
#pragma warning restore
    end;

    internal procedure ValidateGetMember(MemberEntryNo: Integer; MembershipEntryNo: Integer; var NotFoundReasonText: Text): Integer
    var
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
        MembershipRole: Record "NPR MM Membership Role";
    begin

        if (not Member.Get(MemberEntryNo)) then begin
            NotFoundReasonText := StrSubstNo(NOT_FOUND, Member.TableCaption, MemberEntryNo);
            exit(0);
        end;

        if (Member.Blocked) then begin
            NotFoundReasonText := StrSubstNo(MEMBER_BLOCKED, Member."External Member No.", Member."Blocked At");
            exit(0);
        end;

        if (Membership.Get(MembershipEntryNo)) then begin
            MembershipRole.SetFilter("Membership Entry No.", '=%1', MembershipEntryNo);
            MembershipRole.SetFilter("Member Entry No.", '=%1', MemberEntryNo);
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (MembershipRole.IsEmpty()) then begin
                NotFoundReasonText := StrSubstNo(MEMBER_ROLE_BLOCKED, Member."External Member No.", Membership."External Membership No.");
                exit(0);
            end;
        end;

        exit(Member."Entry No.");
    end;

    internal procedure ThrowException_AmbiguousItemUsage()
    var
        MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        UsageErr: Label 'You cannot use the same item for both %1 and %2', Comment = '%1 - MembershipAlterationSetup table caption, %2 - MembershipSalesSetup table caption';
    begin
        Error(UsageErr, MembershipAlterationSetup.TableCaption, MembershipSalesSetup.TableCaption);
    end;

    internal procedure AddToAlterationJournal(Membership: Record "NPR MM Membership")
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        MemberInfoCapture.Init();
        MemberInfoCapture."Source Type" := MemberInfoCapture."Source Type"::ALTERATION_JNL;
        MemberInfoCapture.Insert();
        MemberInfoCapture."Membership Entry No." := Membership."Entry No.";
        MemberInfoCapture."External Membership No." := Membership."External Membership No.";
        MemberInfoCapture."Membership Code" := Membership."Membership Code";
        MemberInfoCapture.Modify();
    end;

    internal procedure GetMembershipEntryNoFromCustomer(CustomerNo: Code[20]) MembershipEntryNo: Integer
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.Reset();
        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", CustomerNo);
        Membership.SetLoadFields("Entry No.");
        Membership.FindFirst();

        MembershipEntryNo := Membership."Entry No.";
    end;

    internal procedure GetMembershipFromCustomerNo(CustomerNo: Code[20]; var Membership: Record "NPR MM Membership") Found: Boolean;
    begin
        Membership.Reset();
        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", CustomerNo);
        Found := Membership.FindFirst();
    end;

    [TryFunction]
    internal procedure TryGetMembershipEntryNoFromCustomer(CustomerNo: Code[20]; var MembershipEntryNo: Integer)
    begin
        MembershipEntryNo := GetMembershipEntryNoFromCustomer(CustomerNo);
    end;

    internal procedure GetCustomerNoFromMembershipEntryNo(MembershipEntryNo: Integer) CustomerNo: Code[20]
    var
        Membership: Record "NPR MM Membership";
    begin
        Membership.SetLoadFields("Customer No.");
        Membership.Get(MembershipEntryNo);
        CustomerNo := Membership."Customer No.";
    end;

    internal procedure CancelAutoRenew(ExternalMemberCardNo: Text[100])
    var
        Membership: Record "NPR MM Membership";
        NotFoundReasonText: Text;
    begin
        if (not (Membership.Get(GetMembershipFromExtCardNo(ExternalMemberCardNo, Today, NotFoundReasonText)))) then
            Error(NotFoundReasonText);

        DisableMembershipAutoRenewal(Membership, true, false);
        RegretSubscription(Membership);
    end;

    internal procedure CheckMembershipAutoRenewStatusYesInternal(CustomerNo: Code[20]): Boolean
    var
        Membership: Record "NPR MM Membership";
    begin
        if (CustomerNo = '') then
            exit(false);
        Membership.Reset();
        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", CustomerNo);
        Membership.SetLoadFields("Auto-Renew");
        if not Membership.FindFirst() then
            exit(false);
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL then
            exit(false);
        exit(true);
    end;

    internal procedure EnableMembershipInternalAutoRenewal(var Membership: Record "NPR MM Membership"; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    begin
        EnableMembershipInternalAutoRenewal(Membership, Membership."Membership Code", CreateMemberNotification, ForceMemberNotification);
    end;

    local procedure EnableMembershipInternalAutoRenewal(var Membership: Record "NPR MM Membership"; TargetMembershipCode: Code[20]; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        EligibleForNotification: Boolean;
    begin
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_INTERNAL then begin
            Membership."Auto-Renew" := Membership."Auto-Renew"::YES_INTERNAL;
            Membership.Modify(true);

            EligibleForNotification := true;
        end;

        if not CreateMemberNotification then
            exit;

        EligibleForNotification := EligibleForNotification or ForceMemberNotification;
        if not EligibleForNotification then
            exit;

        MemberNotification.AddMembershipAutoRenewalEnableNotification(Membership."Entry No.", TargetMembershipCode);
    end;

    internal procedure CheckIfCanEnableAutoRenewal(Membership: Record "NPR MM Membership")
    var
        Subscription: Record "NPR MM Subscription";
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtIml: Codeunit "NPR MM Subscription Mgt. Impl.";
        TerminationRequestExistsErr: Label 'Cannot enable auto-renewal for membership %1 because there is a pending termination request for its subscription.', Comment = '%1 - External Membership No.';
    begin
        if not SubscriptionMgtIml.GetSubscriptionFromMembership(Membership."Entry No.", Subscription) then
            exit;

        SubscriptionRequest.SetRange("Subscription Entry No.", Subscription."Entry No.");
        SubscriptionRequest.SetRange("Processing Status", SubscriptionRequest."Processing Status"::Pending);
        SubscriptionRequest.SetRange(Type, SubscriptionRequest.Type::Terminate);
        if SubscriptionRequest.IsEmpty() then
            exit;

        Error(TerminationRequestExistsErr, Membership."External Membership No.");

    end;

    internal procedure EnableMembershipExternalAutoRenewal(var Membership: Record "NPR MM Membership"; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        EligibleForNotification: Boolean;
    begin
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::YES_EXTERNAL then begin
            Membership."Auto-Renew" := Membership."Auto-Renew"::YES_EXTERNAL;
            Membership.Modify(true);

            EligibleForNotification := true;
        end;

        if not CreateMemberNotification then
            exit;

        EligibleForNotification := EligibleForNotification or ForceMemberNotification;
        if not EligibleForNotification then
            exit;

        MemberNotification.AddMembershipAutoRenewalEnableNotification(Membership."Entry No.", Membership."Membership Code");
    end;

    internal procedure DisableMembershipAutoRenewal(var Membership: Record "NPR MM Membership"; CreateMemberNotification: Boolean; ForceMemberNotification: Boolean)
    var
        MemberNotification: Codeunit "NPR MM Member Notification";
        EligibleForNotification: Boolean;
    begin
        if Membership."Auto-Renew" <> Membership."Auto-Renew"::NO then begin
            Membership."Auto-Renew" := Membership."Auto-Renew"::NO;
            Membership.Modify(true);

            EligibleForNotification := true;
        end;

        if not CreateMemberNotification then
            exit;

        EligibleForNotification := EligibleForNotification or ForceMemberNotification;
        if not EligibleForNotification then
            exit;

        MemberNotification.AddMembershipAutoRenewalDisabledNotification(Membership."Entry No.", Membership."Membership Code");
    end;

    internal procedure SetAutoRenewStatusWithConfirmPage(var Membership: Record "NPR MM Membership")
    var
        SetAutoRenewStatus: Page "NPR MM Set Auto-Renew Status";
    begin
        Clear(SetAutoRenewStatus);
        SetAutoRenewStatus.SetMembership(Membership);
        SetAutoRenewStatus.RunModal();
    end;

    local procedure AlterationSetupInGroup(MembershipAlterationSetup: Record "NPR MM Members. Alter. Setup"; AlterationGroup: Code[10]): boolean
    var
        MMMembersAlterLine: Record "NPR MM Members. Alter. Line";
    begin
        if AlterationGroup = '' then
            exit(true);
        exit(MMMembersAlterLine.Get(AlterationGroup, MembershipAlterationSetup.SystemId));
    end;

    procedure RegretSubscription(var Membership: Record "NPR MM Membership")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        SubscriptionMgtIml: Codeunit "NPR MM Subscription Mgt. Impl.";
    begin
        if (not SubscriptionMgtIml.CheckIfPendingSubscriptionRequestExist(Membership."Entry No.", SubscriptionRequest)) then
            exit;

        CancelSubscription(SubscriptionRequest);

        // Refresh record as subscription module might have made changes to the membership
        Membership.Get(Membership.RecordId());
    end;

    local procedure CancelSubscription(var Rec: Record "NPR MM Subscr. Request")
    var
        SubscrPaymentRequest: Record "NPR MM Subscr. Payment Request";
        SubscrReversalMgt: Codeunit "NPR MM Subscr. Reversal Mgt.";
        SubscrPmtReversalRequest: Record "NPR MM Subscr. Payment Request";
        SubsPayRequestUtils: Codeunit "NPR MM Subs Pay Request Utils";
    begin
        SubscrPaymentRequest.SetRange("Subscr. Request Entry No.", Rec."Entry No.");
        if (not SubscrPaymentRequest.FindLast()) then
            exit;

        if SubscrPaymentRequest.Status in [SubscrPaymentRequest.Status::New, SubscrPaymentRequest.Status::Requested] then
            if SubscrPaymentRequest.Type = SubscrPaymentRequest.Type::PayByLink then
                SubscrReversalMgt.RequestRefund(Rec, SubscrPaymentRequest, true, SubscrPmtReversalRequest)
            else
                SubsPayRequestUtils.SetSubscrPaymentRequestStatus(SubscrPaymentRequest, Enum::"NPR MM Payment Request Status"::Cancelled, false)
        else
            SubscrReversalMgt.RequestRefund(Rec, SubscrPaymentRequest, true, SubscrPmtReversalRequest);
    end;

    internal procedure CreateEnableDisableSubsRequest(Subscription: Record "NPR MM Subscription"; RequestType: Enum "NPR MM Subscr. Request Type")
    var
        SubscriptionRequest: Record "NPR MM Subscr. Request";
        DisableRequestLbl: Label 'Disable request';
        EnableRequestLbl: Label 'Enable request';
        RequestLbl: Text;
    begin
        case RequestType of
            SubscriptionRequest.Type::Enable:
                RequestLbl := EnableRequestLbl;
            SubscriptionRequest.Type::Disable:
                RequestLbl := DisableRequestLbl;
            else
                exit;
        end;

        SubscriptionRequest.Init();
        SubscriptionRequest."Subscription Entry No." := Subscription."Entry No.";
        SubscriptionRequest.Type := RequestType;
        SubscriptionRequest.Status := SubscriptionRequest.Status::Confirmed;
        SubscriptionRequest."Processing Status" := SubscriptionRequest."Processing Status"::Success;
        SubscriptionRequest.Description := CopyStr(RequestLbl, 1, MaxStrLen(SubscriptionRequest.Description));
        SubscriptionRequest."Membership Code" := Subscription."Membership Code";
        SubscriptionRequest.Insert(true);
    end;

    internal procedure POSAssignMembershipPaymentUserAccount(Sale: Codeunit "NPR POS Sale"; PaymentUserAccount: Text)
    var
        POSSale: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(POSSale);
        POSSale."Membership Payer E-Mail" := CopyStr(PaymentUserAccount.ToLower().Trim(), 1, MaxStrLen(POSSale."Membership Payer E-Mail"));
        POSSale.Modify();
    end;

    internal procedure POSMembershipSelected(SalePOS: Record "NPR POS Sale"): Boolean
    var
        Membership: Record "NPR MM Membership";
        MembershipEntry: Record "NPR MM Membership Entry";
    begin
        Membership.SetCurrentKey("Customer No.");
        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        if not Membership.FindFirst() then
            exit(false);

        MembershipEntry.SetRange("Membership Entry No.", Membership."Entry No.");
        MembershipEntry.SetRange(Blocked, false);
        MembershipEntry.SetFilter(Context, '<>%1', MembershipEntry.Context::REGRET);
        if MembershipEntry.IsEmpty() then
            exit(false);

        exit(true);
    end;

    internal procedure GetMemberEmail(SalePOS: Record "NPR POS Sale"; var MembershipEmail: Text)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipMgt: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
        Membership: Record "NPR MM Membership";
    begin
        MemberInfoCapture.SetRange("Receipt No.", SalePOS."Sales Ticket No.");
        MemberInfoCapture.SetLoadFields("E-Mail Address");
        if MemberInfoCapture.FindFirst() then begin
            MembershipEmail := MemberInfoCapture."E-Mail Address";
            exit;
        end;

        Membership.SetRange("Customer No.", SalePOS."Customer No.");
        Membership.SetLoadFields("Entry No.");
        if Membership.FindFirst() then begin
            MembershipMgt.GetFirstAdminMember(Membership."Entry No.", Member);
            MembershipEmail := Member."E-Mail Address";
        end;
    end;

    internal procedure MemberInfoCaptureExist(SalePOS: Record "NPR POS Sale"): Boolean
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
    begin
        MemberInfoCapture.Reset();
        MemberInfoCapture.SetCurrentKey("Receipt No.", "Line No.");
        MemberInfoCapture.SetRange("Receipt No.", SalePOS."Sales Ticket No.");
        exit(not MemberInfoCapture.IsEmpty());
    end;

    internal procedure PayerAccountExists(SalePOS: Record "NPR POS Sale"; var UserAccount: Record "NPR UserAccount"; Member: Record "NPR MM Member"): Boolean
    var
        UserAccountMgtImpl: Codeunit "NPR UserAccountMgtImpl";
    begin
        if SalePOS."Membership Payer E-Mail" = Member."E-Mail Address" then
            exit(false);

        if not UserAccountMgtImpl.FindAccountByEmail(SalePOS."Membership Payer E-Mail", UserAccount) then
            exit(false);

        exit(true)
    end;

    internal procedure GetCustomerNoFromUserAccount(UserAccountNo: Code[20]): Code[20]
    var
        UserAccount: Record "NPR UserAccount";
        Member: Record "NPR MM Member";
        MembershipRole: Record "NPR MM Membership Role";
        Membership: Record "NPR MM Membership";
    begin
        UserAccount.SetLoadFields(EmailAddress);
        if not UserAccount.Get(UserAccountNo) then
            exit('');

        Member.SetCurrentKey("E-Mail Address");
        Member.SetRange("E-Mail Address", UserAccount.EmailAddress);
        Member.SetLoadFields("Entry No.");
        if not Member.FindFirst() then
            exit('');

        MembershipRole.SetCurrentKey("Member Entry No.");
        MembershipRole.SetLoadFields("Membership Entry No.");
        MembershipRole.SetRange("Member Entry No.", Member."Entry No.");
        if not MembershipRole.FindFirst() then
            exit('');

        Membership.SetLoadFields("Customer No.");
        if not Membership.Get(MembershipRole."Membership Entry No.") then
            exit('');

        exit(Membership."Customer No.");
    end;
}