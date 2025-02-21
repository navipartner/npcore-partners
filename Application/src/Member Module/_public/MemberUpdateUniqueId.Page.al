page 6184962 "NPR MemberUpdateUniqueId"
{
    PageType = ConfirmationDialog;
    UsageCategory = None;
    Caption = 'Update Member Unique ID';
    InstructionalText = 'Please enter the new unique ID for the member.';

    layout
    {
        area(Content)
        {

            field(ExternalMemberNo; _NewExternalMemberNo)
            {
                Caption = 'External Member No.';
                ToolTip = 'The external member number of the member';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                ShowMandatory = true;

                trigger OnValidate()
                var
                    EXT_NO_CHANGE: Label 'Please note that changing the external number requires re-printing of documents where this number is used. Do you want to continue?';
                    Member: Record "NPR MM Member";
                begin
                    _ExternalMemberNumberChanged := (_NewExternalMemberNo <> _SourceMember."External Member No.") and (_SourceMember."External Member No." <> '');
                    if (_ExternalMemberNumberChanged) then begin

                        Member.SetFilter("External Member No.", '=%1', _NewExternalMemberNo);
                        if (not Member.IsEmpty()) then
                            Error('External Member No. already exists. Please enter a different number.');

                        if (not Confirm(EXT_NO_CHANGE, false)) then
                            Error('');
                    end;
                end;
            }

            field(FirstName; _NewFirstName)
            {
                Caption = 'First Name';
                ToolTip = 'The new first name of the member';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = _FirstNameVisible;
                ShowMandatory = true;

                Trigger OnValidate()
                var
                    FirstNameRequired: Label 'First Name is required';
                begin
                    if (_NewFirstName = '') then
                        Error(FirstNameRequired);

                    UpdateExplanation(_SourceMember."Entry No.");
                    _UniqueIdentityChanged := true;
                end;
            }

            field(Email; _NewEmail)
            {
                Caption = 'Email';
                ToolTip = 'The new email of the member';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = _EmailVisible;
                ShowMandatory = true;

                Trigger OnValidate()
                var
                    EmailRequired: Label 'Email is required';
                begin
                    if (_NewEmail = '') then
                        Error(EmailRequired);

                    UpdateExplanation(_SourceMember."Entry No.");
                    _UniqueIdentityChanged := true;
                end;

            }

            field(PhoneNumber; _NewPhoneNumber)
            {
                Caption = 'Phone Number';
                ToolTip = 'The new phone number of the member';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Visible = _PhoneNumberVisible;
                ShowMandatory = true;
                Trigger OnValidate()
                var
                    PhoneNoRequired: Label 'Phone Number is required';
                begin
                    if (_NewPhoneNumber = '') then
                        Error(PhoneNoRequired);

                    UpdateExplanation(_SourceMember."Entry No.");
                    _UniqueIdentityChanged := true;
                end;

            }

            field(Merge; _Merge)
            {
                Caption = 'Merge Members';
                ToolTip = 'Specifies if this member will remain and the existing member with same unique ID will be deleted.';
                Visible = _MergeVisible;
                Editable = false;
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
            }

            field(ExternalIdToDelete; _ExternalMemberNoToDelete)
            {
                Caption = 'Conflicting Member No';
                ToolTip = 'The external member number of the member thats is conflicting with the current member before update.';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
            }

            field(Explanation; _Explanation)
            {
                Caption = 'Explanation';
                ToolTip = 'The explanation of the member';
                ApplicationArea = NPRMembershipEssential, NPRMembershipAdvanced;
                Editable = false;
                MultiLine = true;
                StyleExpr = _ExplanationStyle;
                Style = Attention;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        MembershipMgmt: Codeunit "NPR MM MembershipMgtInternal";
        ErrorMsg: Label 'A member with the same unique ID exists and causes a conflict. Please resolve the conflict before closing the page or click No abort.';
    begin
        if CloseAction = Action::Yes then begin

            if (not Confirm('This is action is not reversible. It may take some time to complete. Are you sure you want to continue?', false)) then
                exit(true);

            if (_ExternalMemberNumberChanged) then begin
                _SourceMember."External Member No." := _NewExternalMemberNo;
                _SourceMember.Modify(true);
            end;

            if (_UniqueIdentityChanged) then begin
                if (not _ConflictExists) then
                    MembershipMgmt.UpdateMemberUniqueId(_SourceMember, _NewFirstName, _NewEmail, _NewPhoneNumber, _NewExternalMemberNo);

                if (_ConflictExists and _Merge) then
                    MembershipMgmt.MergeMemberUniqueId(_SourceMember, _NewFirstName, _NewEmail, _NewPhoneNumber, _NewExternalMemberNo);

                if (_ConflictExists and not _Merge) then
                    Error(ErrorMsg);
            end;
        end;

        exit(true);
    end;

    internal procedure SetMember(var Member: Record "NPR MM Member")
    var
        MultipleCommunities: Label 'The member exist in multiple communities that employ different unique ID rules for the members. Merging members based on unique ID is not possible.';
        MembershipMgmt: Codeunit "NPR MM MembershipMgtInternal";
    begin
        _SourceMember := Member;
        _NewFirstName := Member."First Name";
        _NewEmail := Member."E-Mail Address";
        _NewPhoneNumber := Member."Phone No.";
        _NewExternalMemberNo := Member."External Member No.";

        _MergePossible := true;
        if (not (MembershipMgmt.CheckGetCommunityUniqueIdRules(Member."Entry No.", _Community))) then begin
            _MergePossible := false;
            _Explanation := MultipleCommunities;
            _ExplanationStyle := true;
        end;

        _FirstNameVisible := (_Community."Member Unique Identity" in [_Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME]);
        _EmailVisible := (_Community."Member Unique Identity" in [_Community."Member Unique Identity"::EMAIL_AND_FIRST_NAME, _Community."Member Unique Identity"::EMAIL]);
        _PhoneNumberVisible := (_Community."Member Unique Identity" in [_Community."Member Unique Identity"::EMAIL_AND_PHONE, _Community."Member Unique Identity"::EMAIL_OR_PHONE, _Community."Member Unique Identity"::PHONENO]);

        _MergeVisible := (_Community."Create Member UI Violation" = _Community."Create Member UI Violation"::MERGE_MEMBER);
    end;

    local procedure UpdateExplanation(MemberEntryNo: Integer)
    var
        MemberInfoCapture: Record "NPR MM Member Info Capture";
        MembershipMgmt: Codeunit "NPR MM MembershipMgtInternal";
        Member: Record "NPR MM Member";
        MembershipEvents: Codeunit "NPR MM Membership Events";
        ErrorMsg: Label 'A member with the same unique ID already exists. Rules do not allow duplicate unique IDs.';
        ConfirmDuplicateMsg: Label 'A member with the same unique ID already exists. Will you allow the duplicate?';
        AcceptDuplicateMsg: Label 'A member with the same unique ID already exists. The unique ID will be accepted on both members..';
        MergeMsg: Label 'Current member %1 will be updated with new unique id and replace the other member with the same unique id in all membership relationships.';
    begin
        _Merge := false;
        _ExplanationStyle := false;
        _Explanation := 'No conflict found.';

        MemberInfoCapture."First Name" := _NewFirstName;
        MemberInfoCapture."E-Mail Address" := _NewEmail;
        MemberInfoCapture."Phone No." := _NewPhoneNumber;
        MemberInfoCapture."Member Entry No" := MemberEntryNo;

        MembershipMgmt.SetMemberUniqueIdFilter(_Community, MemberInfoCapture, Member);
        _ConflictExists := Member.FindFirst();
        MembershipEvents.OnCheckMemberUniqueIdViolation(_Community, MemberInfoCapture, Member, _ConflictExists);

        if (_ConflictExists) then begin
            _ExplanationStyle := true;
            _ExternalMemberNoToDelete := Member."External Member No.";
            if (_Community."Create Member UI Violation" = _Community."Create Member UI Violation"::ERROR) then
                _Explanation := ErrorMsg;

            if (_Community."Create Member UI Violation" = _Community."Create Member UI Violation"::CONFIRM) then begin
                _Explanation := ErrorMsg;
                if (Confirm(ConfirmDuplicateMsg)) then begin
                    _Explanation := AcceptDuplicateMsg;
                    _ConflictExists := false;
                end;
            end;

            if (_Community."Create Member UI Violation" = _Community."Create Member UI Violation"::REUSE) then begin
                _Explanation := AcceptDuplicateMsg;
                _ConflictExists := false;
            end;

            if (_Community."Create Member UI Violation" = _Community."Create Member UI Violation"::MERGE_MEMBER) then begin
                _Merge := _MergePossible;
                _Explanation := StrSubstNo(MergeMsg, _SourceMember."External Member No.");
                _ExplanationStyle := true;
            end;
        end;
    end;



    var
        _SourceMember: Record "NPR MM Member";
        _NewExternalMemberNo: Code[20];
        _ExternalMemberNoToDelete: Code[20];
        _NewFirstName: Text[50];
        _NewEmail: Text[80];
        _NewPhoneNumber: Text[30];
        _FirstNameVisible: Boolean;
        _EmailVisible: Boolean;
        _PhoneNumberVisible: Boolean;
        _Merge: Boolean;
        _MergeVisible: Boolean;
        _Explanation: Text;
        _ExplanationStyle: Boolean;
        _ConflictExists: Boolean;
        _MergePossible: Boolean;
        _ExternalMemberNumberChanged: Boolean;
        _UniqueIdentityChanged: Boolean;
        _Community: Record "NPR MM Member Community";
}