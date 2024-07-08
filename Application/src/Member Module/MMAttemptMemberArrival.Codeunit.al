codeunit 6014492 "NPR MM Attempt Member Arrival"
{
    Access = Internal;
    trigger OnRun()
    begin

        if (_FunctionOption = _FunctionOption::AttemptArrival) then begin
            _ResponseCode := DoAttemptMemberArrivalSingle(_TicketItemNo, _AdmissionCode, _PosUnitNo, _Member, _ResponseMessage);
        end;

        if (_FunctionOption = _FunctionOption::AttemptArrivalBatch) then begin
            _ResponseCode := DoAttemptMemberArrivalBatch(_MemberInfoCapture, _AdmissionCode, _PosUnitNo, _ResponseMessage);
        end;

    end;

    var
        _FunctionOption: Option NotSet,AttemptArrival,IssueTicket,AttemptArrivalBatch;
        _TicketItemNo: Code[50];
        _AdmissionCode: Code[20];
        _ScannerStationId: Code[10];
        _PosUnitNo: Code[10];
        _Member: Record "NPR MM Member";
        _MembershipEntryNo: Integer;
        _MemberInfoCapture: Record "NPR MM Member Info Capture";
        _ResponseMessage: Text;
        _ResponseCode: Integer;

#pragma warning disable AA0206
    procedure AttemptMemberArrival(TicketItemNo: Code[50]; AdmissionCode: Code[20]; PosUnitNo: Code[10]; ScannerStationId: Code[10]; Member: Record "NPR MM Member"; MembershipEntryNo: Integer)
    var
    begin
        _FunctionOption := _FunctionOption::AttemptArrival;
        _TicketItemNo := TicketItemNo;
        _AdmissionCode := AdmissionCode;
        _PosUnitNo := PosUnitNo;
        _ScannerStationId := ScannerStationId;
        _Member.Copy(Member);
        _MembershipEntryNo := MembershipEntryNo;
        _ResponseCode := -2; // When DoAttemptMemberArrival() throws error
        _ResponseMessage := 'Member Arrival Attempt failed with error.';
    end;
#pragma warning restore AA0206
    procedure AttemptMemberArrival(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AdmissionCode: Code[20]; PosUnitNo: Code[10]; ScannerStationId: Code[10])
    var
    begin
        _FunctionOption := _FunctionOption::AttemptArrivalBatch;
        _MemberInfoCapture.Copy(MemberInfoCapture);
        _AdmissionCode := AdmissionCode;
        _ScannerStationId := ScannerStationId;
        _PosUnitNo := PosUnitNo;
    end;

    procedure GetAttemptMemberArrivalResponse(var ResponseMessage: Text) ResponseCode: Integer
    begin
        ResponseMessage := _ResponseMessage;

        if (_ResponseCode = -2) then
            ResponseMessage := GetLastErrorText();

        exit(_ResponseCode);
    end;

    local procedure DoAttemptMemberArrivalBatch(var MemberInfoCapture: Record "NPR MM Member Info Capture"; AdmissionCode: Code[20]; PosUnitNo: Code[10]; var ResponseMessage: Text) ResponseCode: Integer
    var
        MembershipSetup: Record "NPR MM Membership Setup";
        Member: Record "NPR MM Member";
    begin

        if (not MemberInfoCapture.HasFilter()) then
            Error('No filter attached on MemberInfoCapture when attempting to AttemptArrivalBatch (Programming Error).');

        MemberInfoCapture.FindSet();
        repeat
            Clear(Member);
            if (Member.Get(MemberInfoCapture."Member Entry No")) then begin
                MemberInfoCapture."External Member No" := Member."External Member No.";

                MembershipSetup.Get(MemberInfoCapture."Membership Code");

                ResponseCode := DoAttemptMemberArrivalSingle(MembershipSetup."Ticket Item Barcode", AdmissionCode, PosUnitNo, Member, ResponseMessage);
                if (ResponseCode <> 0) then
                    Error(ResponseMessage);
            end;
        until (MemberInfoCapture.Next() = 0);
        exit(0); // Success
    end;

    local procedure DoAttemptMemberArrivalSingle(ItemCrossReference: Code[50]; AdmissionCode: Code[20]; PosUnitNo: Code[10]; Member: Record "NPR MM Member"; var ResponseMessage: Text): Integer
    var
        Ticket: Record "NPR TM Ticket";
        MemberTicketManagement: Codeunit "NPR MM Member Ticket Manager";
        MemberRetailIntegration: Codeunit "NPR MM Member Retail Integr.";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        TicketNo: Code[20];
        TicketIsReused: Boolean;
        NEW_MEMBER_TICKET: Label 'Ticket %1 for admission %2 was created for member %3.';
        MEMBER_TICKET: Label 'Ticket %1 for admission %2 was reused for member %3.';
        MemberTicketNotSetup: Label 'No ticket reservation found for member %1 that is valid for today, with admission code [%2] or an admission code selected from POS unit [%3].';
    begin

        TicketIsReused := MemberTicketManagement.SelectReusableTicket(Member."Entry No.", ItemCrossReference, AdmissionCode, PosUnitNo, 1, '', Ticket);
        if (TicketIsReused) then begin
            if ((AdmissionCode = '') and (PosUnitNo = '')) then
                AdmissionCode := '-default-';

            if ((AdmissionCode = '') and (PosUnitNo <> '')) then
                AdmissionCode := '-pos unit-';

            ResponseMessage := StrSubstNo(MEMBER_TICKET, Ticket."No.", AdmissionCode, Member."External Member No.");
            exit(0);
        end;

        // Create new ticket - only possible when ExternalItemNo <> ''
        if (ItemCrossReference = '') then begin
            ResponseMessage := StrSubstNo(MemberTicketNotSetup, Member."External Member No.", AdmissionCode, PosUnitNo);
            exit(-1);
        end;

        if (MemberRetailIntegration.IssueTicketFromMemberScan(Member, ItemCrossReference, TicketNo, ResponseMessage) <> 0) then
            exit(-1);

        TicketManagement.RegisterArrivalScanTicket("NPR TM TicketIdentifierType"::INTERNAL_TICKET_NO, TicketNo, AdmissionCode, -1, PosUnitNo, '', false);


        if (AdmissionCode = '') then
            AdmissionCode := '-default-';

        if ((AdmissionCode = '') and (PosUnitNo <> '')) then
            AdmissionCode := '-pos unit-';

        ResponseMessage := StrSubstNo(NEW_MEMBER_TICKET, TicketNo, AdmissionCode, Member."External Member No.");
        exit(0);

    end;

}
