codeunit 6014488 "NPR Membership Attempt Create"
{
    TableNo = "NPR MM Member Info Capture";

    var
        FORCED_ROLLBACK: Label 'Successfully created. Force rollback with error.', Locked = true, Comment = 'The function is attempted and always rolled back';

        FUNCTION_NOT_SET: label 'Programming error. Function not set in "NPR Membership Attempt Create"';
        TransactionControl: Option NotSet,ForcedRollBack,DoRollbackOnError;

    trigger OnRun()
    begin
        if (TransactionControl = TransactionControl::DoRollbackOnError) then
            CreateMembership(Rec);

        if (TransactionControl = TransactionControl::ForcedRollBack) then
            AttemptCreateMemberships(Rec);

        if (TransactionControl = TransactionControl::NotSet) then
            Error(FUNCTION_NOT_SET);
    end;


    procedure SetCreateMembership()
    begin
        TransactionControl := TransactionControl::DoRollbackOnError;
    end;

    procedure SetAttemptCreateMembershipForcedRollback()
    begin
        TransactionControl := TransactionControl::ForcedRollBack;
    end;

    procedure SetAttemptCreateMembership()
    begin
        TransactionControl := TransactionControl::ForcedRollBack;
    end;

    local procedure AttemptCreateMemberships(var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MembershipEntryNo: Integer;
        ResponseMessage: Text;
        NOT_SUPPORTED_FOR_REMOTE: Label 'This membership action is not supported for a remote membership';
    begin

        MemberInfoCapture.LockTable(true);

        MemberInfoCapture.FindSet();
        repeat

            MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");

            case MembershipSalesSetup."Business Flow Type" of
                MembershipSalesSetup."Business Flow Type"::MEMBERSHIP:
                    begin
                        if (IsForeignMembership(MembershipSalesSetup."Membership Code")) then
                            Error(FORCED_ROLLBACK);

                        MembershipEntryNo := MemberManagement.CreateMembership(MembershipSalesSetup, MemberInfoCapture, false);
                        MemberManagement.AddMemberAndCard(MembershipEntryNo, MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);

                        MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                        MemberInfoCapture.Modify();

                        while (MemberInfoCapture.Next() <> 0) do begin
                            MemberManagement.AddMemberAndCard(MembershipEntryNo, MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);
                            MemberInfoCapture."Membership Entry No." := MembershipEntryNo;
                            MemberInfoCapture.Modify();
                        end;
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER:
                    begin
                        repeat
                            if (not IsForeignMembership(MembershipSalesSetup."Membership Code")) then
                                MemberManagement.AddMemberAndCard(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);
                            MemberInfoCapture.Modify();

                        until (MemberInfoCapture.Next() = 0);
                        Error(FORCED_ROLLBACK);
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER:
                    begin

                        if (IsForeignMembership(MembershipSalesSetup."Membership Code")) then
                            Error(NOT_SUPPORTED_FOR_REMOTE);

                        MemberManagement.AddAnonymousMember(MemberInfoCapture, MemberInfoCapture.Quantity);
                        Error(FORCED_ROLLBACK);
                    end;

                MembershipSalesSetup."Business Flow Type"::ADD_CARD:
                    begin

                        if (IsForeignMembership(MembershipSalesSetup."Membership Code")) then
                            Error(NOT_SUPPORTED_FOR_REMOTE);

                        MemberManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                        Error(FORCED_ROLLBACK);
                    end;

                MembershipSalesSetup."Business Flow Type"::REPLACE_CARD:
                    begin

                        if (IsForeignMembership(MembershipSalesSetup."Membership Code")) then
                            Error(NOT_SUPPORTED_FOR_REMOTE);

                        if (MemberInfoCapture."Replace External Card No." <> '') then
                            MemberManagement.BlockMemberCard(MemberManagement.GetCardEntryNoFromExtCardNo(MemberInfoCapture."Replace External Card No."), true);
                        MemberManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                        Error(FORCED_ROLLBACK);
                    end;
            end;

        until (MemberInfoCapture.Next() = 0);

    end;



    local procedure CreateMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture")
    var
        MembershipSalesSetup: Record "NPR MM Members. Sales Setup";
        MemberNotification: Codeunit "NPR MM Member Notification";
        MemberManagement: Codeunit "NPR MM Membership Mgt.";
        MembershipStartDate: Date;
        MembershipUntilDate: Date;
        ResponseMessage: Text;
        MSG_1101: Label 'Quantity must be 1, when selling memberships.';
    begin

        MemberInfoCapture.FindSet();
        repeat

            case MemberInfoCapture."Information Context" of

                MemberInfoCapture."Information Context"::NEW:
                    begin

                        MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.");

                        if (MembershipSalesSetup."Business Flow Type" <> MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER) then
                            if (MemberInfoCapture.Quantity <> 1) then
                                Error(MSG_1101);

                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::MEMBERSHIP) then begin

                            if (IsForeignMembership(MembershipSalesSetup."Membership Code")) then begin
                                RemoteCreateMembership(MemberInfoCapture, MembershipSalesSetup);
                                repeat
                                    RemoteAddMember(MemberInfoCapture, MembershipSalesSetup);
                                until (MemberInfoCapture.Next() = 0);
                                //TODO: Consider - RemoteActivateMembership (MemberInfoCapture, MembershipSalesSetup);

                            end else begin
                                MemberManagement.AddMembershipLedgerEntry_NEW(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Document Date", MembershipSalesSetup, MemberInfoCapture);
                            end;

                        end;

                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER) then begin
                            repeat

                                if (IsForeignMembership(MembershipSalesSetup."Membership Code")) then begin
                                    RemoteAddMember(MemberInfoCapture, MembershipSalesSetup);
                                end else begin
                                    MemberManagement.AddMemberAndCard(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);
                                end;

                            until (MemberInfoCapture.Next() = 0);

                        end;

                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER) then begin
                            MemberManagement.AddAnonymousMember(MemberInfoCapture, MemberInfoCapture.Quantity);
                        end;

                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::REPLACE_CARD) then begin
                            MemberManagement.BlockMemberCard(MemberManagement.GetCardEntryNoFromExtCardNo(MemberInfoCapture."Replace External Card No."), true);
                            MemberManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                            if (MembershipSalesSetup."Member Card Type" in [MembershipSalesSetup."Member Card Type"::CARD_PASSSERVER, MembershipSalesSetup."Member Card Type"::PASSSERVER]) then
                                MemberNotification.CreateWalletSendNotification(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.", TODAY);
                        end;

                        if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_CARD) then begin
                            MemberManagement.IssueMemberCard(MemberInfoCapture, MemberInfoCapture."Card Entry No.", ResponseMessage);
                            if (MembershipSalesSetup."Member Card Type" in [MembershipSalesSetup."Member Card Type"::CARD_PASSSERVER, MembershipSalesSetup."Member Card Type"::PASSSERVER]) then
                                MemberNotification.CreateWalletSendNotification(MemberInfoCapture."Membership Entry No.", MemberInfoCapture."Member Entry No", MemberInfoCapture."Card Entry No.", TODAY);
                        end;

                    end;

                MemberInfoCapture."Information Context"::REGRET:
                    begin
                        MemberManagement.RegretMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");
                    end;

                MemberInfoCapture."Information Context"::RENEW:
                    begin
                        MemberManagement.RenewMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");
                    end;

                MemberInfoCapture."Information Context"::UPGRADE:
                    begin
                        MemberManagement.UpgradeMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");

                        if (MembershipSalesSetup.Get(MembershipSalesSetup.Type::ITEM, MemberInfoCapture."Item No.")) then begin
                            if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_NAMED_MEMBER) then begin
                                repeat
                                    MemberManagement.AddMemberAndCard(MemberInfoCapture."Membership Entry No.", MemberInfoCapture, true, MemberInfoCapture."Member Entry No", ResponseMessage);
                                until (MemberInfoCapture.Next() = 0);
                            end;

                            if (MembershipSalesSetup."Business Flow Type" = MembershipSalesSetup."Business Flow Type"::ADD_ANONYMOUS_MEMBER) then begin
                                MemberManagement.AddAnonymousMember(MemberInfoCapture, MemberInfoCapture.Quantity);
                            end;
                        end;

                    end;

                MemberInfoCapture."Information Context"::EXTEND:
                    begin
                        MemberManagement.ExtendMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");
                    end;

                MemberInfoCapture."Information Context"::CANCEL:
                    begin
                        MemberManagement.CancelMembership(MemberInfoCapture, false, true, MembershipStartDate, MembershipUntilDate, MemberInfoCapture."Unit Price");
                    end;

            end;
        until (MemberInfoCapture.Next() = 0);

    end;

    local procedure IsForeignMembership(MembershipCode: Code[20]): Boolean
    var
        NPRMembership: Codeunit "NPR MM NPR Membership";
    begin

        exit(NPRMembership.IsForeignMembershipCommunity(MembershipCode));

    end;

    local procedure RemoteCreateMembership(var MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipSalesSetup: Record "NPR MM Members. Sales Setup")
    var
        NPRMembership: Codeunit "NPR MM NPR Membership";
        MembershipSetup: Record "NPR MM Membership Setup";
        NotValidReason: Text;
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        if (not NPRMembership.CreateRemoteMembership(MembershipSetup."Community Code", MemberInfoCapture, NotValidReason)) then
            Error(NotValidReason);

    end;

    local procedure RemoteAddMember(var MemberInfoCapture: Record "NPR MM Member Info Capture"; MembershipSalesSetup: Record "NPR MM Members. Sales Setup")
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        NPRMembership: Codeunit "NPR MM NPR Membership";
        NotValidReason: Text;
    begin

        MembershipSetup.Get(MembershipSalesSetup."Membership Code");

        if (not NPRMembership.CreateRemoteMember(MembershipSetup."Community Code", MemberInfoCapture, NotValidReason)) then
            Error(NotValidReason);

    end;

    internal procedure WasSuccessful(var ResponseMessage: Text): Boolean
    begin
        ResponseMessage := GetLastErrorText();
        exit(ResponseMessage = FORCED_ROLLBACK);
    end;

}