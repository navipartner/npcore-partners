codeunit 6151084 "NPR MM Retail Integration"
{
    var
        MMRetailIntegr: Codeunit "NPR MM Member Retail Integr.";

    procedure POS_ValidateMemberCardNo(FailWithError: Boolean; AllowVerboseMode: Boolean; InputMode: Option CARD_SCAN,FACIAL_RECOGNITION,NO_PROMPT; ActivateMembership: Boolean; var ExternalMemberCardNo: Text[100]): Boolean
    begin
        MMRetailIntegr.POS_ValidateMemberCardNo(FailWithError, AllowVerboseMode, InputMode, ActivateMembership, ExternalMemberCardNo);
    end;

    procedure GetMembershipEntryNoPOSSalesInfo(AssociationType: Option; SalesTicketNo: Code[20]; LineNo: Integer): Integer
    var
        MMPOSSalesInfo: Record "NPR MM POS Sales Info";
    begin
        if MMPOSSalesInfo.Get(AssociationType, SalesTicketNo, LineNo) then
            exit(MMPOSSalesInfo."Membership Entry No.");
    end;

    procedure InsertMembershipPOSSalesInfo(AssociationType: Option; SalesTicketNo: Code[20]; LineNo: Integer; MembershipEntryNo: Integer; ExternalMemberCardNo: Text[200])
    var
        POSSalesInfo: Record "NPR MM POS Sales Info";
    begin
        if (not POSSalesInfo.GET(AssociationType, SalesTicketNo, LineNo)) then begin
            POSSalesInfo."Association Type" := AssociationType;
            POSSalesInfo."Receipt No." := SalesTicketNo;
            POSSalesInfo."Line No." := LineNo;
            POSSalesInfo.Insert();
        end;

        POSSalesInfo."Membership Entry No." := MembershipEntryNo;
        POSSalesInfo."Scanned Card Data" := ExternalMemberCardNo;
        POSSalesInfo.Modify();
    end;
}