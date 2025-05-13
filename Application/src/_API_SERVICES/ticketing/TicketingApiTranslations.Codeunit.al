codeunit 6185046 "NPR TicketingApiTranslations"
{
    Access = Internal;

    internal procedure EncodeInclusion(AdmissionInclusion: Option): Text
    var
        TicketBom: Record "NPR TM Ticket Admission Bom";
    begin
        case AdmissionInclusion of
            TicketBom."Admission Inclusion"::REQUIRED:
                exit('mandatory');
            TicketBom."Admission Inclusion"::SELECTED:
                exit('optionalAndSelected');
            TicketBom."Admission Inclusion"::NOT_SELECTED:
                exit('optionalNotSelected');
        end;
    end;

    internal procedure EncodeCapacity(CapacityControl: Option): Text
    var
        Admission: Record "NPR TM Admission";
    begin
        case CapacityControl of
            Admission."Capacity Control"::NONE:
                exit('none');
            Admission."Capacity Control"::SALES:
                exit('sales');
            Admission."Capacity Control"::ADMITTED:
                exit('admitted');
            Admission."Capacity Control"::FULL:
                exit('full');
            Admission."Capacity Control"::SEATING:
                exit('seating');
        end;
    end;

    internal procedure EncodeScheduleSelection(TicketScheduleSelection: Option; DefaultSchedule: Option): Text
    var
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission Bom";
    begin
        case TicketScheduleSelection of
            TicketBom."Ticket Schedule Selection"::NONE:
                exit('noScheduleSelection');
            TicketBom."Ticket Schedule Selection"::NEXT_AVAILABLE:
                exit('nextAvailableSchedule');
            TicketBom."Ticket Schedule Selection"::SCHEDULE_ENTRY:
                exit('userSelectedSchedule');
            TicketBom."Ticket Schedule Selection"::TODAY:
                exit('currentSchedule');
            TicketBom."Ticket Schedule Selection"::ADMISSION:
                case DefaultSchedule of
                    Admission."Default Schedule"::NONE:
                        exit('noScheduleSelection');
                    Admission."Default Schedule"::NEXT_AVAILABLE:
                        exit('nextAvailableSchedule');
                    Admission."Default Schedule"::SCHEDULE_ENTRY:
                        exit('userSelectedSchedule');
                    Admission."Default Schedule"::TODAY:
                        exit('currentSchedule');
                end;
        end;
    end;

    internal procedure EncodeAllocationBy(AllocationBy: Option) Description: Text
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        case AllocationBy of
            AdmissionScheduleEntry."Allocation By"::CAPACITY:
                Description := 'capacity';
            AdmissionScheduleEntry."Allocation By"::WAITINGLIST:
                Description := 'waitinglist';
        end;
    end;

    internal procedure EncodeRequestStatus(RequestStatus: Option; DuplicateMessage: Boolean): Text
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        // OptionCaption = 'Registered,Confirmed,Expired,Canceled,Work In Progress,Reserved,Waiting List,Optional';
        // OptionMembers = REGISTERED,CONFIRMED,EXPIRED,CANCELED,WIP,RESERVED,WAITINGLIST,OPTIONAL;
        case RequestStatus of
            TicketReservationRequest."Request Status"::REGISTERED:
                exit('registered');
            TicketReservationRequest."Request Status"::CONFIRMED:
                if (DuplicateMessage) then
                    exit('alreadyConfirmed')
                else
                    exit('confirmed');
            TicketReservationRequest."Request Status"::EXPIRED:
                exit('expired');
            TicketReservationRequest."Request Status"::CANCELED:
                exit('canceled');
            TicketReservationRequest."Request Status"::WIP:
                exit('workInProgress');
            TicketReservationRequest."Request Status"::RESERVED:
                exit('reserved');
            TicketReservationRequest."Request Status"::WAITINGLIST:
                exit('waitingList');
            TicketReservationRequest."Request Status"::OPTIONAL:
                exit('optional');
        end;
    end;

}
