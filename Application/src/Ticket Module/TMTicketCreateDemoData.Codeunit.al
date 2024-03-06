codeunit 6151134 "NPR TM Ticket Create Demo Data"
{
    Access = Internal;
    /***    
            ****** TICKET SERVER setup ******
            http://test.ticket.navipartner.dk/import/api/rest/v1/ticket/orders
            web_experimentarium
            bf103bceddfb087198b0d032afea29db
            http://test.ticket.navipartner.dk/ticket/
            http://test.ticket.navipartner.dk/order/
            Danish
              
            ==> Ticket Type Code: Master-Ticket

            ****** eTicket (Wallet) ******
            Administration section can be reached at https://passes.npecommerce.dk/webadmin

            For server administrators: wallet-admin@navipartner.com / a1234567
            Super admin user credentials are as follows: wallet@navipartner.com / yT0WhYEo

            ==> eTicket Type Code: ticket

    ***/
    trigger OnRun()
    begin

    end;

    procedure CreateTicketDemoData(DeleteCurrentSetup: Boolean)
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketSetup: Record "NPR TM Ticket Setup";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
        AdmissionList: array[10] of code[20];
        SeasonBaseCalendar: code[10];
        BaseCalendarChange: Record "Base Calendar Change";
        AllowAdmissionBeforeStart: Integer;
        AllowAdmissionAfterStart: Integer;
        PriceProfileCodeList: array[10] of Code[10];
        i: Integer;
    begin
        CreateNoSerie('TM-ATF001', 'TMATF0000001');
        CreateNoSerie('NPR-TICKET', 'NPR0000001');
        CreateNoSerie('TM-PK10', 'TM-PK10000');
        CreateNoSerie('TM-PK20', 'TM-PK2000000000');

        SeasonBaseCalendar := CreateBaseCalendar('SEASONPASS', 'Season Pass Calendar');
        SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', BaseCalendarChange."Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Tuesday);
        SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', BaseCalendarChange."Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Thursday);
        SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', BaseCalendarChange."Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Saturday);
        SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', BaseCalendarChange."Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Sunday);

        AdmissionList[1] := (CreateAdmissionCode('CASTLE', 'Castle', Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));
        AdmissionList[2] := (CreateAdmissionCode('TREASURE', 'Treasure', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));
        AdmissionList[3] := (CreateAdmissionCode('DUNGEON', 'Dungeon', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));

        AdmissionList[4] := (CreateAdmissionCode('TOUR01', 'Event Tour', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY));
        AdmissionList[5] := (CreateAdmissionCode('TOUR02', 'Event Tour', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY));
        AdmissionList[6] := (CreateAdmissionCode('TOUR03', 'Event Tour', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY));
        AdmissionList[7] := (CreateAdmissionCode('TOUR04', 'Event Tour', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY));
        AdmissionList[8] := (CreateAdmissionCode('OPTIONAL1', 'Optional admission 1', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));
        AdmissionList[9] := (CreateAdmissionCode('OPTIONAL2', 'Optional admission 2', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));
        AdmissionList[10] := (CreateAdmissionCode('OPTIONAL3', 'Optional admission 3', Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));

        CreateSchedule('M-WEEKDAYS', AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, true, true, true, true, true, false, false);
        CreateSchedule('M-WEEKENDS', AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, false, false, false, false, false, true, true);

        CreateSchedule('E-WEEKDAYS-01', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 100000T, 120000T, true, true, true, true, true, false, false);
        CreateSchedule('E-WEEKDAYS-02', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 140000T, 160000T, true, true, true, true, true, false, false);

        CreateSchedule('E-WEEKENDS-01', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 103000T, 123000T, false, false, false, false, false, true, true);
        CreateSchedule('E-WEEKENDS-02', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 150000T, 170000T, false, false, false, false, false, true, true);

        CreateSchedule('TS-08-01', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 080000T, 100000T, true, true, true, true, true, false, false);
        CreateSchedule('TS-08-02', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 100000T, 120000T, true, true, true, true, true, false, false);
        CreateSchedule('TS-08-03', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 120000T, 140000T, true, true, true, true, true, false, false);
        CreateSchedule('TS-08-04', AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 140000T, 160000T, true, true, true, true, true, false, false);

        AllowAdmissionBeforeStart := 15;
        AllowAdmissionAfterStart := 5;

        CreateScheduleLine('CASTLE', 'M-WEEKDAYS', 1, false, 17, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('CASTLE', 'M-WEEKENDS', 1, false, 23, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine('TREASURE', 'E-WEEKDAYS-01', 1, true, 7, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('TREASURE', 'E-WEEKDAYS-02', 1, false, 9, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('TREASURE', 'E-WEEKENDS-01', 1, false, 11, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('TREASURE', 'E-WEEKENDS-02', 1, false, 5, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine('DUNGEON', 'E-WEEKDAYS-01', 1, false, 7, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('DUNGEON', 'E-WEEKDAYS-02', 1, false, 9, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('DUNGEON', 'E-WEEKENDS-01', 1, false, 11, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine('DUNGEON', 'E-WEEKENDS-02', 1, false, 5, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        PriceProfileCodeList[1] := CreatePriceProfile('SPL', 'Sliding Price Ladder, progressively cheaper.');
        for i := 0 to 6 do
            CreatePriceRule(PriceProfileCodeList[1], StrSubstNo('%1 days out, %1 cheaper.', i), 0D, 0D, '', 0D, 0D, '', StrSubstNo('<+%1D>', i), 2, (0 - i), true, 25, 0);

        PriceProfileCodeList[2] := CreatePriceProfile('DPW', 'Differentiate Price based on Weekday');
        CreatePriceRule(PriceProfileCodeList[2], 'Book a Monday event and get 10 knocked off regular price.', 0D, 0D, '', 0D, 0D, '<WD1>', '', 2, -10, true, 25, 0);
        CreatePriceRule(PriceProfileCodeList[2], 'Book a Wednesday event and get 20 knocked off regular price.', 0D, 0D, '', 0D, 0D, '<WD3>', '', 2, -20, true, 25, 0);
        CreatePriceRule(PriceProfileCodeList[2], 'Book a Friday event and add 10 to regular price.', 0D, 0D, '', 0D, 0D, '<WD5>', '', 2, 10, true, 25, 0);

        CreateScheduleLine(AdmissionList[4], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart, PriceProfileCodeList[1]);
        CreateScheduleLine(AdmissionList[4], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart, PriceProfileCodeList[2]);
        CreateScheduleLine(AdmissionList[4], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[4], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine(AdmissionList[5], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[5], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[5], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[5], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine(AdmissionList[6], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[6], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[6], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[6], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine(AdmissionList[7], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[7], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[7], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[7], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine(AdmissionList[8], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[8], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[8], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[8], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine(AdmissionList[9], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[9], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[9], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[9], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        CreateScheduleLine(AdmissionList[10], 'TS-08-01', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[10], 'TS-08-02', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[10], 'TS-08-03', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
        CreateScheduleLine(AdmissionList[10], 'TS-08-04', 1, false, 2, ScheduleLine."Capacity Control"::SALES, '<+7D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);



        CreateConcurrencyLimit('MAX3', 'Max 3 tours at the same time', 3, AdmissionGroupConcurrency."Capacity Control"::SALES, AdmissionGroupConcurrency."Concurrency Type"::SCHEDULE);

        ApplyConcurrencyLimit(AdmissionList[4], '*', 'MAX3');
        ApplyConcurrencyLimit(AdmissionList[5], '*', 'MAX3');
        ApplyConcurrencyLimit(AdmissionList[6], '*', 'MAX3');
        ApplyConcurrencyLimit(AdmissionList[7], '*', 'MAX3');

        CreateStakeholder('TREASURE', 'E-WEEKDAYS-01', 'tsa@navipartner.dk', AdmissionSchedule."Notify Stakeholder"::ALL);

        TicketType.Get(CreateTicketType('POS-MSCAN', 'Manual Scan', '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM));
        TicketType.Get(CreateTicketType('POS-AUTO', 'Auto Admit on Sale', '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::POS_DEFAULT, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM));
        TicketType.Get(CreateTicketType('GROUP', 'Group Ticket', '<+7D>', 0, TicketType."Admission Registration"::GROUP, "NPR TM ActivationMethod_Type"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM));

        // Single ticket same day
        CreateItem('31001', '', 'POS-AUTO', 'Adult Ticket', 157);
        CreateItem('31002', '', 'POS-AUTO', 'Child Ticket', 107);
        CreateItem('31003', '', 'POS-AUTO', 'Senior Ticket', 57);
        CreateItem('31004', '', 'POS-AUTO', 'Child Ticket (free)', 0);

        // Mon, Wed, Fri
        CreateItem('31006', '', 'POS-MSCAN', 'Season Pass (Mon, Wed, Fri)', 0);

        // 2 adults, 2 kids
        CreateItem('31008', '', 'POS-AUTO', 'Family Ticket (2+2)', 500);

        CreateItem('31009', '', 'POS-MSCAN', 'Event Ticket', 197);
        CreateItem('31010', '', 'POS-MSCAN', 'Sponsor Ticket', 1);

        CreateItem('32001', '', 'GROUP', 'Group Ticket', 99);

        CreateItem('31031', 'ADULT', 'POS-AUTO', 'Ticket With Variant', 157);
        CreateItem('31031', 'CHILD', 'POS-AUTO', 'Ticket With Variant', 107);

        CreateItem('31041', '', 'POS-MSCAN', 'Tour 1 Ticket with Concurrency', 107);
        CreateItem('31042', '', 'POS-MSCAN', 'Tour 2 Ticket with Concurrency', 107);
        CreateItem('31043', '', 'POS-MSCAN', 'Tour 3 Ticket with Concurrency', 107);
        CreateItem('31044', '', 'POS-MSCAN', 'Tour 4 Ticket with Concurrency', 107);

        //Dynamic ticket        
        CreateItem('31100', '', 'POS-MSCAN', 'Dynamic ticket', 111);
        CreateItem('31110', '', '', 'Optional admission 1', 11);
        CreateItem('31111', '', '', 'Optional admission 2', 23);
        CreateItem('31112', '', '', 'Optional admission 3', 37);
        AddItemToAdmission('31110', AdmissionList[8]);
        AddItemToAdmission('31111', AdmissionList[9]);
        AddItemToAdmission('31112', AdmissionList[10]);


        CreateTicketBOM('31001', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31002', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31003', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31004', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31006', '', AdmissionList[1], SeasonBaseCalendar, 1, true, '<CY>', 4, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::MULTIPLE, 0);

        CreateTicketBOM('31008', '', AdmissionList[1], '', 4, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31009', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SAME_DAY, 0);
        CreateTicketBOM('31009', '', AdmissionList[2], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31010', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SAME_DAY, 0);
        CreateTicketBOM('31010', '', AdmissionList[2], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31010', '', AdmissionList[3], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('32001', '', AdmissionList[1], '', 10, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31031', 'ADULT', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31031', 'CHILD', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31041', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31041', '', AdmissionList[4], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31042', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31042', '', AdmissionList[5], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31043', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31043', '', AdmissionList[6], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        CreateTicketBOM('31044', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31044', '', AdmissionList[7], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);


        CreateTicketBOM('31100', '', AdmissionList[1], '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SAME_DAY, 0);
        CreateTicketBOM('31100', '', AdmissionList[2], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31100', '', AdmissionList[3], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);
        CreateTicketBOM('31100', '', AdmissionList[8], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 2);
        CreateTicketBOM('31100', '', AdmissionList[9], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 2);
        CreateTicketBOM('31100', '', AdmissionList[10], '', 1, false, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 2);

        TicketSetup."Print Server Generator URL" := 'http://test.ticket.navipartner.dk/import/api/rest/v1/ticket/orders';
        TicketSetup."Timeout (ms)" := 30000;
        TicketSetup."Print Server Gen. Username" := 'web_experimentarium';
        TicketSetup."Print Server Gen. Password" := 'bf103bceddfb087198b0d032afea29db';
        TicketSetup."Print Server Ticket URL" := 'http://test.ticket.navipartner.dk/ticket/';
        TicketSetup."Print Server Order URL" := 'http://test.ticket.navipartner.dk/order/';
        TicketSetup."Default Ticket Language" := 'Danish';

        TicketSetup."NP-Pass Server Base URL" := 'https://passes.npecommerce.dk/api/v1';
        TicketSetup."NP-Pass Notification Method" := TicketSetup."NP-Pass Notification Method"::ASYNCHRONOUS;
        TicketSetup."NP-Pass API" := '/passes/%1/%2';
        TicketSetup."NP-Pass Token" := 'eyJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE1MjIyNDQyNjEsIm5iZiI6MTUyMjI0NDI2MSwidWlkIjo2fQ.yWeKjD8hDGhDNn8KLf345v7tYBZ-bA20DzS07bgHRxo';

        if (not TicketSetup.Insert()) then TicketSetup.Modify();

        MESSAGE('Setup of DEMO data for ticketing, completed.');

    end;

    procedure SetupMembershipGuestTicket(AdmissionCode: Code[20]; AdmissionDescription: text[50]; ItemCode: Code[20]; ItemDescription: text[100]): code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        MembershipGuestTicketLbl: Label '%1-WD', Locked = true;
        MembershipGuestTicket2Lbl: Label '%1-WE', Locked = true;
        MembershipGuestTicket3Lbl: Label 'IXRF-%1', Locked = true;
    begin

        if (not Admission.get(AdmissionCode)) then begin
            CreateAdmissionCode(AdmissionCode, AdmissionDescription, Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY);

            CreateSchedule(StrSubstNo(MembershipGuestTicketLbl, AdmissionCode), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, true, true, true, true, true, false, false);
            CreateSchedule(StrSubstNo(MembershipGuestTicket2Lbl, AdmissionCode), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, false, false, false, false, false, true, true);

            CreateScheduleLine(AdmissionCode, StrSubstNo(MembershipGuestTicketLbl, AdmissionCode), 1, false, 17, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0);
            CreateScheduleLine(AdmissionCode, StrSubstNo(MembershipGuestTicket2Lbl, AdmissionCode), 1, false, 23, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0);
        end;

        CreateTicketType('MM-AUTO', 'Members and Member Guests', '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, "NPR TM ActivationMethod_Type"::POS_DEFAULT, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);

        CreateItem(ItemCode, '', 'MM-AUTO', ItemDescription, 0);

        CreateTicketBOM(ItemCode, '', AdmissionCode, '', 1, true, '', 0, "NPR TM ActivationMethod_Bom"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, 0);

        exit(StrSubstNo(MembershipGuestTicket3Lbl, ItemCode));
    end;

    local procedure ApplyConcurrencyLimit(AdmissionCodeFilter: Code[20]; ScheduleCodeFilter: Code[20]; ConcurrencyCode: Code[20])
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
    begin
        AdmissionScheduleLines.SetFilter("Admission Code", AdmissionCodeFilter);

        AdmissionScheduleLines.SetFilter("Schedule Code", ScheduleCodeFilter);

        if (ConcurrencyCode <> '') then
            AdmissionGroupConcurrency.Get(ConcurrencyCode);

        AdmissionScheduleLines.MODIFYALL("Concurrency Code", ConcurrencyCode);
    end;

    procedure CreateAdmissionCode(AdmissionCode: Code[20]; Description: text[50]; AdmissionType: Option; CapacityLimit: Enum "NPR TM CapacityLimit"; DefaultSchedule: Option): code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Init();
        if (not Admission.Get(AdmissionCode)) then begin
            Admission."Admission Code" := AdmissionCode;
            Admission.Insert();
        end;

        Admission.Type := AdmissionType;
        Admission.Description := Description;
        Admission."Capacity Limits By" := CapacityLimit;
        Admission."Default Schedule" := DefaultSchedule;

        Admission."Admission Base Calendar Code" := CreateBaseCalendar('', AdmissionCode);
        Admission.Modify();

        exit(AdmissionCode);
    end;

    local procedure CreateBaseCalendar(CalendarCode: Code[10]; Desc: Text[30]): Code[10]
    var
        BaseCalendar: Record "Base Calendar";
    begin

        if (CalendarCode <> '') then
            if (not BaseCalendar.Get(CalendarCode)) then begin
                BaseCalendar.Code := CalendarCode;
                BaseCalendar.Insert();
            end;

        if (CalendarCode = '') then begin
            BaseCalendar.Code := GenerateCode10();
            BaseCalendar.Insert();
        end;

        BaseCalendar.Init();
        BaseCalendar.Name := 'Automated Test Framework';
        if (Desc <> '') then
            BaseCalendar.Name := Desc;

        BaseCalendar.Modify();

        exit(BaseCalendar.Code);
    end;

    local procedure CreatePriceProfile(ProfileCode: Code[10]; Description: Text): Code[10]
    var
        PriceProfile: Record "NPR TM Dynamic Price Profile";
    begin
        if (ProfileCode = '') then
            ProfileCode := GenerateCode10();

        if (not (PriceProfile.Get(ProfileCode))) then begin
            PriceProfile.ProfileCode := ProfileCode;
            PriceProfile.Insert();
        end;

        PriceProfile.Description := CopyStr(Description, 1, MaxStrLen(PriceProfile.Description));
        PriceProfile.Modify();

        exit(ProfileCode);
    end;

    local procedure CreatePriceRule(var ProfileCode: Code[10]; Description: Text[100];
                                        BookingFrom: Date; BookingUntil: Date; RelativeBookingDateFormula: Text;
                                        EventFrom: Date; EventUntil: Date; RelativeEventDateFormula: Text;
                                        RelativeUntilDateFormula: Text;
                                        PricingOption: Option; Amount: Decimal; AmountIncludesVat: Boolean; VatPercentage: Decimal; AddonPercentage: Decimal
                                    ): Integer
    var
        PriceRule: Record "NPR TM Dynamic Price Rule";
    begin
        if (ProfileCode = '') then
            ProfileCode := CreatePriceProfile('', Description);

        PriceRule.ProfileCode := ProfileCode;
        PriceRule.Insert(true);

        PriceRule.Description := Description;

        // Rule selection properties
        PriceRule.BookingDateFrom := BookingFrom;
        PriceRule.BookingDateUntil := BookingUntil;
        Evaluate(PriceRule.RelativeBookingDateFormula, RelativeBookingDateFormula, 9);

        PriceRule.EventDateFrom := EventFrom;
        PriceRule.EventDateUntil := EventUntil;
        Evaluate(PriceRule.RelativeEventDateFormula, RelativeEventDateFormula, 9);

        Evaluate(PriceRule.RelativeUntilEventDate, RelativeUntilDateFormula, 9);

        // Price Properties
        PriceRule.PricingOption := PricingOption;
        PriceRule.Amount := Amount;
        PriceRule.AmountIncludesVAT := AmountIncludesVat;
        PriceRule.VatPercentage := VatPercentage;
        PriceRule.Percentage := AddonPercentage;

        PriceRule.Modify();
    end;

    local procedure CreateConcurrencyLimit(Code: Code[20]; Description: Text; Limit: Integer; CapacityOption: Option; ConcurrencyOption: Option): Code[20]
    var
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
    begin
        if (Code = '') then
            Code := GenerateCode20();

        if (not AdmissionGroupConcurrency.Get(Code)) then begin
            AdmissionGroupConcurrency.Code := Code;
            AdmissionGroupConcurrency.Insert();
        end;

        AdmissionGroupConcurrency.Description := CopyStr(Description, 1, MaxStrLen(AdmissionGroupConcurrency.Description));
        AdmissionGroupConcurrency."Total Capacity" := Limit;
        AdmissionGroupConcurrency."Capacity Control" := CapacityOption;
        AdmissionGroupConcurrency."Concurrency Type" := ConcurrencyOption;
        AdmissionGroupConcurrency.Modify();

        exit(AdmissionGroupConcurrency.Code);
    end;

    procedure CreateItem(No: Code[20]; VariantCode: Code[10]; TicketTypeCode: Code[10]; Description: Text[100]; UnitPrice: Decimal): Code[20]
    var
        TicketItem: Record "Item";
        ItemVariant: Record "Item Variant";
        ItemReference: Record "Item Reference";
        CreateItemLbl: Label 'IXRF-%1', Locked = true;
        CreateItem2Lbl: Label 'IXRF-%1-%2', Locked = true;
    begin
        TicketItem.Init();
        if (not (TicketItem.Get(No))) then begin
            TicketItem.Get('70000');
            TicketItem."No." := No;
            TicketItem.Insert();
        end;

        TicketItem.Description := Description;
        TicketItem."Unit Price" := UnitPrice;
        TicketItem.Validate("NPR Ticket Type", TicketTypeCode);


        TicketItem.Blocked := false;
        TicketItem."NPR Group sale" := false;

        TicketItem.Modify();

        if (VariantCode <> '') then begin
            ItemVariant.Init();
            if (not ItemVariant.Get(No, VariantCode)) then begin
                ItemVariant."Item No." := No;
                ItemVariant.Code := VariantCode;
                ItemVariant.Insert();
            end;
            ItemVariant.Description := Description;
            ItemVariant.Modify();
        end;

        ItemReference.Init();
        ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetFilter("Reference No.", '=%1', StrSubstNo(CreateItemLbl, TicketItem."No."));
        if (VariantCode <> '') then
            ItemReference.SetFilter("Reference No.", '=%1', StrSubstNo(CreateItem2Lbl, TicketItem."No.", VariantCode));

        if (not ItemReference.FindFirst()) then begin
            ItemReference."Item No." := TicketItem."No.";
            ItemReference."Variant Code" := VariantCode;
            ItemReference."Unit of Measure" := TicketItem."Sales Unit of Measure";
            ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
            ItemReference."Reference No." := StrSubstNo(CreateItemLbl, TicketItem."No.");
            if (VariantCode <> '') then
                ItemReference."Reference No." := StrSubstNo(CreateItem2Lbl, TicketItem."No.", VariantCode);
            ItemReference.Description := TicketItem.Description;
            ItemReference.Insert();
        end;

        exit(No);
    end;

    local procedure CreateNoSerie(NoSerieCode: Code[20]; StartNumber: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (not NoSeries.Get(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.Insert();
        end;

        NoSeries.Description := 'Ticket Automated Test Framework';
        NoSeries."Default Nos." := true;
        NoSeries.Modify();

        if (not NoSeriesLine.Get(NoSerieCode, 10000)) then begin
            NoSeriesLine."Series Code" := NoSerieCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := DMY2Date(1, 1, 2020);
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.Insert();
        end;
    end;

    procedure CreateSchedule(ScheduleCode: Code[20]; ScheduleType: Option; AdmissionIs: Option; StartFrom: Date; RecurrencePattern: Option; StartTime: Time; EndTime: Time; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Code[20]
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        AdmissionSchedule.Init();
        if (not AdmissionSchedule.Get(ScheduleCode)) then begin
            AdmissionSchedule."Schedule Code" := ScheduleCode;
            AdmissionSchedule.Insert();
        end;

        AdmissionSchedule."Schedule Type" := ScheduleType;
        AdmissionSchedule."Admission Is" := AdmissionIs;
        AdmissionSchedule.Description := 'Automated Test Framework';
        AdmissionSchedule."Start From" := StartFrom;
        AdmissionSchedule."Recurrence Until Pattern" := RecurrencePattern;
        AdmissionSchedule.VALIDATE("Start Time", StartTime);
        AdmissionSchedule.VALIDATE("Stop Time", EndTime);
        AdmissionSchedule.Monday := Monday;
        AdmissionSchedule.Tuesday := Tuesday;
        AdmissionSchedule.Wednesday := Wednesday;
        AdmissionSchedule.Thursday := Thursday;
        AdmissionSchedule.Friday := Friday;
        AdmissionSchedule.Saturday := Saturday;
        AdmissionSchedule.Sunday := Sunday;

        AdmissionSchedule.Modify();

        exit(ScheduleCode);
    end;

    procedure CreateSchedule(ScheduleCode: Code[20]; ScheduleType: Option; AdmissionIs: Option; StartFrom: Date; RecurrencePattern: Option; EndAfter: Date; StartTime: Time; EndTime: Time; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Code[20]
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        AdmissionSchedule.get(
            CreateSchedule(ScheduleCode, ScheduleType, AdmissionIs, StartFrom, RecurrencePattern, StartTime, EndTime, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
        );

        AdmissionSchedule."End After Date" := EndAfter;
        AdmissionSchedule.Modify();

        exit(ScheduleCode);
    end;

    procedure CreateScheduleLine(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ProcessOrder: Integer; PreBookRequired: Boolean; MaxCapacity: Integer; CapacityControl: Option; PrebookFromFormula: Text[30]; AllowAdmissionBeforeStart_Minutes: Integer; AllowAdmissionPassedStart_Minutes: Integer; PriceProfileCode: Code[10])
    var
        ScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        CreateScheduleLine(AdmissionCode, ScheduleCode,
            ProcessOrder, PrebookRequired, MaxCapacity, CapacityControl,
            PrebookFromFormula, AllowAdmissionBeforeStart_Minutes, AllowAdmissionPassedStart_Minutes);

        ScheduleLines.Get(AdmissionCode, ScheduleCode);
        ScheduleLines."Dynamic Price Profile Code" := PriceProfileCode;
        ScheduleLines.Modify();
    end;

    procedure CreateScheduleLine(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ProcessOrder: Integer; PreBookRequired: Boolean; MaxCapacity: Integer; CapacityControl: Option; PrebookFromFormula: Text[30]; AllowAdmissionBeforeStart_Minutes: Integer; AllowAdmissionPassedStart_Minutes: Integer)
    var
        ScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleLines.Init();
        if (not ScheduleLines.Get(AdmissionCode, ScheduleCode)) then begin
            ScheduleLines."Admission Code" := AdmissionCode;
            ScheduleLines."Schedule Code" := ScheduleCode;
            ScheduleLines.Insert();
        end;

        ScheduleLines."Process Order" := ProcessOrder;
        ScheduleLines.Blocked := false;
        ScheduleLines."Prebook Is Required" := PreBookRequired;
        Evaluate(ScheduleLines."Prebook From", PrebookFromFormula);

        if (ScheduleLines."Prebook Is Required") then begin
            ScheduleLines.CalcFields("Scheduled Start Time", "Scheduled Stop Time");

            ScheduleLines."Event Arrival From Time" := ScheduleLines."Scheduled Start Time";
            if (AllowAdmissionBeforeStart_Minutes > 0) then
                ScheduleLines."Event Arrival From Time" := ScheduleLines."Scheduled Start Time" + AllowAdmissionBeforeStart_Minutes * 60 * 1000; //millis

            ScheduleLines."Event Arrival Until Time" := ScheduleLines."Scheduled Stop Time";
            if (AllowAdmissionPassedStart_Minutes >= 0) then
                ScheduleLines."Event Arrival Until Time" := ScheduleLines."Scheduled Start Time" + AllowAdmissionPassedStart_Minutes * 60 * 1000; // millis

        end;
        ScheduleLines."Max Capacity Per Sch. Entry" := MaxCapacity;
        ScheduleLines."Capacity Control" := CapacityControl;
        ScheduleLines.Modify();
    end;

    local procedure CreateStakeholder(AdmissionCode: Code[20]; ScheduleCode: Code[20]; Stakeholder: Text[30]; NotificationModel: Option)
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
    begin

        Admission.Get(AdmissionCode);
        Admission."Stakeholder (E-Mail/Phone No.)" := Stakeholder;
        Admission.Modify();

        Schedule.Get(ScheduleCode);
        Schedule."Notify Stakeholder" := NotificationModel;
        Schedule.Modify();
    end;

    procedure CreateTicketBOM(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; TicketBaseCalendarCode: Code[10]; Quantity: Integer; Default: Boolean; DurationFormula: Text[30]; MaxNoOfEntries: Integer; ActivationMethod: Enum "NPR TM ActivationMethod_Bom"; EntryValidation: Option; AdmissionInclusion: Option)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Item: Record Item;
        Admission: Record "NPR TM Admission";
    begin
        TicketBom.Init();
        if (not TicketBom.Get(ItemNo, VariantCode, AdmissionCode)) then begin
            TicketBom."Item No." := ItemNo;
            TicketBom."Variant Code" := VariantCode;
            TicketBom."Admission Code" := AdmissionCode;
            TicketBom.Insert();
        end;

        Item.Get(ItemNo);
        Admission.Get(AdmissionCode);

        TicketBom.Quantity := Quantity;
        TicketBom.Description := Item.Description;
        TicketBom.Default := Default;
        TicketBom."Admission Description" := Admission.Description;
        TicketBom."Prefered Sales Display Method" := TicketBom."Prefered Sales Display Method"::DEFAULT;

        Evaluate(TicketBom."Duration Formula", DurationFormula);
        TicketBom."Max No. Of Entries" := MaxNoOfEntries;
        TicketBom."Activation Method" := ActivationMethod;
        TicketBom."Admission Entry Validation" := EntryValidation;
        TicketBom."Ticket Base Calendar Code" := TicketBaseCalendarCode;
        TicketBom."Admission Inclusion" := AdmissionInclusion;
        TicketBom.Modify();
    end;

    procedure CreateTicketType(TicketTypeCode: Code[10]; Description: text; DurationFormula: Text[30]; MaxNumberOfEntries: Integer; AdmissionRegistration: Option; ActivationMethod: Enum "NPR TM ActivationMethod_Type"; EntryValidation: Option; ConfigurationSource: Option): Code[10]
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        TicketType.Init();
        if (not TicketType.Get(TicketTypeCode)) then begin
            TicketType.Code := TicketTypeCode;
            TicketType.Insert();
        end;

        TicketType.Description := CopyStr(Description, 1, MaxStrLen(TicketType.Description));
        TicketType."Print Ticket" := false;
        TicketType.VALIDATE("No. Series", 'NPR-TICKET');
        TicketType."External Ticket Pattern" := 'ATF-[S][A*1]-[N]';
        TicketType."Is Ticket" := true;
        TicketType."Defer Revenue" := false;

        Evaluate(TicketType."Duration Formula", DurationFormula);
        TicketType."Max No. Of Entries" := MaxNumberOfEntries;
        TicketType."Admission Registration" := AdmissionRegistration;
        TicketType."Activation Method" := ActivationMethod;
        TicketType."Ticket Entry Validation" := EntryValidation;
        TicketType."Ticket Configuration Source" := ConfigurationSource;
        TicketType.Modify();

        exit(TicketTypeCode);
    end;

    local procedure GenerateCode10(): Code[10]
    begin
        exit(CopyStr(GetNextNoFromSeries('C1'), 1, 10));
    end;

    local procedure GenerateCode20(): Code[20]
    begin
        exit(GetNextNoFromSeries('C2'));
    end;

    local procedure GetNextNoFromSeries(FromSeries: Code[2]): Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        case FromSeries OF
            'TM':
                exit(NoSeriesManagement.GetNextNo('TM-ATF001', TODAY, true));
            'C1':
                exit(NoSeriesManagement.GetNextNo('TM-PK10', TODAY, true));
            'C2':
                exit(NoSeriesManagement.GetNextNo('TM-PK20', TODAY, true));
            else
                Error('Get Next No %1 from number series is not configured.', FromSeries);
        end;
    end;

    local procedure SetNonWorking(Code: Code[10]; Description: Text[30]; RecurringPattern: Integer; Date: Date; Day: Integer)
    var
        BaseCalendarChange: Record "Base Calendar Change";
    begin
        BaseCalendarChange."Base Calendar Code" := Code;
        BaseCalendarChange.Description := Description;
        BaseCalendarChange.Nonworking := true;

        BaseCalendarChange."Recurring System" := RecurringPattern;
        case BaseCalendarChange."Recurring System" OF
            BaseCalendarChange."Recurring System"::"Annual Recurring":
                BaseCalendarChange.Date := Date;
            BaseCalendarChange."Recurring System"::"Weekly Recurring":
                BaseCalendarChange.Day := Day;
        end;

        if (BaseCalendarChange.Insert()) then;
    end;

    local procedure AddItemToAdmission(ItemNo: Code[20]; AdmissionCode: Code[20])
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.Get(AdmissionCode);
        Admission.Validate("Additional Experience Item No.", ItemNo);
        Admission.Modify(true);
    end;

}
