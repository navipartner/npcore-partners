codeunit 85201 "NPR TM K6LoadTestSetup"
{
    [Normal]
    procedure PrepareLoadTest(ScenarioCode: Code[20]): Boolean
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
    begin
        TicketTestLibrary.CreateMinimalSetup();

        case ScenarioCode of
            'K6-1':
                begin
                    CreateSetup1();
                    SetRequestExpiry(5);
                end;
            'RESTORE':
                SetRequestExpiry(1500);
            else
                Error('Unknown scenario code %1', ScenarioCode);
        end;

        exit(true);
    end;

    [Normal]
    local procedure SetRequestExpiry(RequestExpiry: Integer)
    var
        TicketSetup: Record "NPR TM Ticket Setup";
    begin
        TicketSetup.Get();
        TicketSetup.DefaultExpireTimeSeconds := RequestExpiry;
        TicketSetup.PosExternalExpireTimeSeconds := RequestExpiry;
        TicketSetup.UserDefaultExpireTimeSeconds := RequestExpiry;
        TicketSetup.PosUnattendedExpireTimeSeconds := RequestExpiry;
        TicketSetup.Modify();
    end;

    [Normal]
    local procedure CreateSetup1()
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketType: Record "NPR TM Ticket Type";
        Admission: Record "NPR TM Admission";
        TicketTypeCode: Code[10];
        ItemNo: Code[20];
        AdmissionCode: Code[20];
    begin
        TicketTypeCode := TicketTestLibrary.CreateTicketType('K6-T-TYPE', '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        ItemNo := TicketTestLibrary.CreateItem('K6LT-ITEM-1', '', TicketTypeCode, Random(200) + 100);

        AdmissionCode := (TicketTestLibrary.CreateAdmissionCode('K6LT-ADM-1-3', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', ''));
        TicketTestLibrary.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, false, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        CreateTimeSlotDaily(AdmissionCode, 'K6LT-SCH-1-3', Today(), 0D, 000001T, 235959T, 7);
        SoftRegenerateSchedule(AdmissionCode, Today());

        AdmissionCode := (TicketTestLibrary.CreateAdmissionCode('K6LT-ADM-1-2', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', ''));
        TicketTestLibrary.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, false, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        CreateTimeSlotDaily(AdmissionCode, 'K6LT-SCH-1-2', Today(), 0D, 000001T, 235959T, 7);
        SoftRegenerateSchedule(AdmissionCode, Today());

        AdmissionCode := (TicketTestLibrary.CreateAdmissionCode('K6LT-ADM-1-1', Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', ''));
        TicketTestLibrary.CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);
        CreateTimeSlotDaily(AdmissionCode, 'K6LT-SCH-1-1', Today(), 0D, 000001T, 235959T, 7);
        SoftRegenerateSchedule(AdmissionCode, Today());

    end;

    [Normal]
    local procedure CreateTimeSlotDaily(AdmissionCode: Code[20]; ScheduleCode: Code[20]; StartFromDate: Date; StopAtDate: Date; AdmissionStartTime: Time; AdmissionEndTime: Time; NumberOfDays: Integer)
    var
        TicketTestLibrary: Codeunit "NPR Library - Ticket Module";
        Schedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
    begin
        if (ScheduleCode = '') then
            ScheduleCode := TicketTestLibrary.GenerateCode20();

        ScheduleCode := TicketTestLibrary.CreateSchedule(
            ScheduleCode,
            Schedule."Schedule Type"::"EVENT",
            Schedule."Admission Is"::OPEN,
            StartFromDate,
            Schedule."Recurrence Until Pattern"::NO_END_DATE,
            AdmissionStartTime, AdmissionEndTime, true, true, true, true, true, true, true, '');

        Schedule.Get(ScheduleCode);
        if (StopAtDate > 0D) then begin
            Schedule."Recurrence Until Pattern" := Schedule."Recurrence Until Pattern"::END_DATE;
            Schedule."End After Date" := StopAtDate;
        end;
        Schedule."Recurrence Pattern" := Schedule."Recurrence Pattern"::DAILY;
        Schedule."Event Arrival From Time" := AdmissionStartTime - 2 * 3600 * 1000; // arrive from 2 hours before
        Schedule."Event Arrival Until Time" := AdmissionStartTime + 3600 / 2 * 1000; // arrive
        Schedule."Sales Until Time" := AdmissionStartTime; // stop sale when event starts
        Schedule.Modify();

        TicketTestLibrary.CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 10000, ScheduleLine."Capacity Control"::Sales, StrSubstNo('<+%1D>', NumberOfDays), 0, 0, '');
    end;

    local procedure SoftRegenerateSchedule(AdmissionCode: Code[20]; ReferenceDate: Date)
    var
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
    begin
        ScheduleLine.SetFilter("Admission Code", '=%1', AdmissionCode);
        ScheduleLine.SetFilter("Schedule Generated At", '>=%1', ReferenceDate);
        ScheduleLine.ModifyAll("Schedule Generated At", CalcDate('<-1D>', ReferenceDate));

        ScheduleManager.CreateAdmissionScheduleTestFramework(AdmissionCode, false, ReferenceDate, ReferenceDate);
    end;

}