enum 6014484 "NPR TM Sch. Block Sales Reason"
{
#IF NOT BC17
    Access = Internal;       
#ENDIF
    Extensible = false;

    value(0; OpenForSales)
    {
        Caption = 'Open for Sale';
    }
    value(1; ScheduleExceedTicketDuration)
    {
        Caption = 'Schedule Exceed Ticket Duration';
    }
    value(2; ConcurrentCapacityExceeded)
    {
        Caption = 'Concurrent Capacity Exceeded';
    }
    value(3; EventDateNotReferenceDate)
    {
        Caption = 'Event Date must be same as Reference Date';
    }
    value(4; EventAdmissionNotStarted)
    {
        Caption = 'Event Admission has not yet Started.';
    }
    value(5; EventHasEndedTime)
    {
        Caption = 'Event Sale has Ended.';
    }
    value(6; AdmissionSaleHasNotStartedDate)
    {
        Caption = 'Admission Sale has not Started (Date).';
    }
    value(7; AdmissionSaleHasNotStartedTime)
    {
        Caption = 'Admission Sales has not Started (Time).';
    }
    value(8; AdmissionSalesHasEndedDate)
    {
        Caption = 'Admission Sales has Ended (Date).';
    }
    value(9; AdmissionSalesHasEndedTime)
    {
        Caption = 'Admission Sales has Ended (Time).';
    }
    value(10; RemainingCapacityZeroOrLess)
    {
        Caption = 'Remaining Capacity Zero or Less.';
    }
}
