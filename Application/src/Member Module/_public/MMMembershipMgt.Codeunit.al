codeunit 6060127 "NPR MM Membership Mgt."
{
    procedure CreateMembershipAll(MembershipSalesSetup: Record "NPR MM Members. Sales Setup"; var MemberInfoCapture: Record "NPR MM Member Info Capture"; CreateMembershipLedgerEntry: Boolean) MembershipEntryNo: Integer
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipEntryNo := MembershipManagement.CreateMembershipAll(MembershipSalesSetup, MemberInfoCapture, CreateMembershipLedgerEntry);
    end;

    procedure GetMembershipFromExtCardNo(ExternalCardNo: Text[100]; ReferenceDate: Date; var ReasonNotFound: Text) MembershipEntryNo: Integer
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipEntryNo := MembershipManagement.GetMembershipFromExtCardNo(ExternalCardNo, ReferenceDate, ReasonNotFound);
    end;

    procedure DeleteMembership(MembershipEntryNo: Integer; WithGDPRCheck: Boolean; Force: Boolean)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
        GDPR: Codeunit "NPR MM GDPR Management";
    begin
        if (WithGDPRCheck) then begin
            GDPR.DeleteMembership(MembershipEntryNo);
        end else begin
            MembershipManagement.DeleteMembership(MembershipEntryNo, Force);
        end;
    end;

    procedure GetMembershipMaxValidUntilDate(MembershipEntryNo: Integer; var MaxValidUntilDate: Date)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.GetMembershipMaxValidUntilDate(MembershipEntryNo, MaxValidUntilDate);
    end;

    procedure RegretMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.RegretMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure RenewMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.RenewMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure UpgradeMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.UpgradeMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure ExtendMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.ExtendMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure CancelMembership(MemberInfoCapture: Record "NPR MM Member Info Capture"; WithConfirm: Boolean; WithUpdate: Boolean; var MembershipStartDate: Date; var MembershipUntilDate: Date; var UnitPrice: Decimal)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.CancelMembership(MemberInfoCapture, WithConfirm, WithUpdate, MembershipStartDate, MembershipUntilDate, UnitPrice);
    end;

    procedure BlockMembership(MembershipEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMembership(MembershipEntryNo, true);
    end;

    procedure UnblockMembership(MembershipEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMembership(MembershipEntryNo, false);
    end;

    procedure BlockMember(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMember(MembershipEntryNo, MemberEntryNo, true);
    end;

    procedure UnblockMember(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMember(MembershipEntryNo, MemberEntryNo, false);
    end;

    procedure BlockMemberCard(CardEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCard(CardEntryNo, true);
    end;

    procedure UnblockMemberCard(CardEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCard(CardEntryNo, false);
    end;

    procedure BlockMemberCards(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCards(MembershipEntryNo, MemberEntryNo, true);
    end;

    procedure UnblockMemberCards(MembershipEntryNo: Integer; MemberEntryNo: Integer)
    var
        MembershipManagement: Codeunit "NPR MM MembershipMgtInternal";
    begin
        MembershipManagement.BlockMemberCards(MembershipEntryNo, MemberEntryNo, false);
    end;

}