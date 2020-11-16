codeunit 6151134 "NPR TM Ticket Create Demo Data"
{
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

    var
        myInt: Integer;

    procedure CreateTicketDemoData(DeleteCurrentSetup: Boolean)
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Item: Record Item;
        TicketSetup: Record "NPR TM Ticket Setup";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
        AdmissionList: array[10] of code[20];
        SeasonBaseCalendar: code[10];
        BaseCalendarChange: Record "Base Calendar Change";
        AllowAdmissionBeforeStart: Integer;
        AllowAdmissionAfterStart: Integer;
    begin

        CreateNoSerie('TM-ATF001', 'TMATF0000001');
        CreateNoSerie('NPR-TICKET', 'NPR0000001');
        CreateNoSerie('TM-PK10', 'TM-PK10000');
        CreateNoSerie('TM-PK20', 'TM-PK2000000000');

        SeasonBaseCalendar := CreateBaseCalendar('SEASONPASS', 'Season Pass Calendar');
        WITH BaseCalendarChange DO BEGIN
            SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', "Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Tuesday);
            SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', "Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Thursday);
            SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', "Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Saturday);
            SetNonWorking(SeasonBaseCalendar, 'Closed for Season Pass Holder', "Recurring System"::"Weekly Recurring", 0D, BaseCalendarChange.Day::Sunday);
        END;

        WITH Admission DO BEGIN
            AdmissionList[1] := (CreateAdmissionCode('CASTLE', 'Castle', Type::LOCATION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::TODAY));
            AdmissionList[2] := (CreateAdmissionCode('TREASURE', 'Treasure', Type::OCCASION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::TODAY));
            AdmissionList[3] := (CreateAdmissionCode('DUNGEON', 'Dungeon', Type::OCCASION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::TODAY));

            AdmissionList[4] := (CreateAdmissionCode('TOUR01', 'Event Tour', Type::OCCASION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::SCHEDULE_ENTRY));
            AdmissionList[5] := (CreateAdmissionCode('TOUR02', 'Event Tour', Type::OCCASION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::SCHEDULE_ENTRY));
            AdmissionList[6] := (CreateAdmissionCode('TOUR03', 'Event Tour', Type::OCCASION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::SCHEDULE_ENTRY));
            AdmissionList[7] := (CreateAdmissionCode('TOUR04', 'Event Tour', Type::OCCASION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::SCHEDULE_ENTRY));
        END;

        WITH AdmissionSchedule DO BEGIN
            CreateSchedule('M-WEEKDAYS', "Schedule Type"::LOCATION, "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
            CreateSchedule('M-WEEKENDS', "Schedule Type"::LOCATION, "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);

            CreateSchedule('E-WEEKDAYS-01', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 100000T, 120000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
            CreateSchedule('E-WEEKDAYS-02', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 140000T, 160000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);

            CreateSchedule('E-WEEKENDS-01', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 103000T, 123000T, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);
            CreateSchedule('E-WEEKENDS-02', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 150000T, 170000T, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);

            CreateSchedule('TS-08-01', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 080000T, 100000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
            CreateSchedule('TS-08-02', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 100000T, 120000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
            CreateSchedule('TS-08-03', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 120000T, 140000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
            CreateSchedule('TS-08-04', "Schedule Type"::"EVENT", "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 140000T, 160000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
        END;


        AllowAdmissionBeforeStart := 15;
        AllowAdmissionAfterStart := 5;

        WITH ScheduleLine DO BEGIN
            CreateScheduleLine('CASTLE', 'M-WEEKDAYS', 1, FALSE, 17, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('CASTLE', 'M-WEEKENDS', 1, FALSE, 23, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

            CreateScheduleLine('TREASURE', 'E-WEEKDAYS-01', 1, TRUE, 7, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('TREASURE', 'E-WEEKDAYS-02', 1, FALSE, 9, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('TREASURE', 'E-WEEKENDS-01', 1, FALSE, 11, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('TREASURE', 'E-WEEKENDS-02', 1, FALSE, 5, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

            CreateScheduleLine('DUNGEON', 'E-WEEKDAYS-01', 1, FALSE, 7, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('DUNGEON', 'E-WEEKDAYS-02', 1, FALSE, 9, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('DUNGEON', 'E-WEEKENDS-01', 1, FALSE, 11, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine('DUNGEON', 'E-WEEKENDS-02', 1, FALSE, 5, "Capacity Control"::ADMITTED, '<+5D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

            CreateScheduleLine(AdmissionList[4], 'TS-08-01', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[4], 'TS-08-02', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[4], 'TS-08-03', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[4], 'TS-08-04', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

            CreateScheduleLine(AdmissionList[5], 'TS-08-01', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[5], 'TS-08-02', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[5], 'TS-08-03', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[5], 'TS-08-04', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

            CreateScheduleLine(AdmissionList[6], 'TS-08-01', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[6], 'TS-08-02', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[6], 'TS-08-03', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[6], 'TS-08-04', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

            CreateScheduleLine(AdmissionList[7], 'TS-08-01', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[7], 'TS-08-02', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[7], 'TS-08-03', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);
            CreateScheduleLine(AdmissionList[7], 'TS-08-04', 1, FALSE, 2, "Capacity Control"::SALES, '<+3D>', AllowAdmissionBeforeStart, AllowAdmissionAfterStart);

        END;

        WITH AdmissionGroupConcurrency DO
            CreateConcurrencyLimit('MAX3', 'Max 3 tours at the same time', 3, "Capacity Control"::SALES, "Concurrency Type"::SCHEDULE);

        ApplyConcurrencyLimit(AdmissionList[4], '*', 'MAX3');
        ApplyConcurrencyLimit(AdmissionList[5], '*', 'MAX3');
        ApplyConcurrencyLimit(AdmissionList[6], '*', 'MAX3');
        ApplyConcurrencyLimit(AdmissionList[7], '*', 'MAX3');

        CreateStakeholder('TREASURE', 'E-WEEKDAYS-01', 'tsa@navipartner.dk', AdmissionSchedule."Notify Stakeholder"::ALL);

        WITH TicketType DO BEGIN
            TicketType.GET(CreateTicketType('POS-MSCAN', 'Manual Scan', '<+7D>', 0, "Admission Registration"::INDIVIDUAL, "Activation Method"::SCAN, "Ticket Entry Validation"::SINGLE, "Ticket Configuration Source"::TICKET_BOM));
            TicketType.GET(CreateTicketType('POS-AUTO', 'Auto Admit on Sale', '<+7D>', 0, "Admission Registration"::INDIVIDUAL, "Activation Method"::POS_DEFAULT, "Ticket Entry Validation"::SINGLE, "Ticket Configuration Source"::TICKET_BOM));
            TicketType.GET(CreateTicketType('GROUP', 'Group Ticket', '<+7D>', 0, "Admission Registration"::GROUP, "Activation Method"::SCAN, "Ticket Entry Validation"::SINGLE, "Ticket Configuration Source"::TICKET_BOM));
        END;

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

        WITH TicketBom DO BEGIN
            CreateTicketBOM('31001', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31002', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31003', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31004', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31006', '', AdmissionList[1], SeasonBaseCalendar, 1, TRUE, '<CY>', 4, "Activation Method"::SCAN, "Admission Entry Validation"::MULTIPLE);

            CreateTicketBOM('31008', '', AdmissionList[1], '', 4, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31009', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SAME_DAY);
            CreateTicketBOM('31009', '', AdmissionList[2], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31010', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SAME_DAY);
            CreateTicketBOM('31010', '', AdmissionList[2], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31010', '', AdmissionList[3], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('32001', '', AdmissionList[1], '', 10, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31031', 'ADULT', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31031', 'CHILD', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31041', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31041', '', AdmissionList[4], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31042', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31042', '', AdmissionList[5], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31043', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31043', '', AdmissionList[6], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

            CreateTicketBOM('31044', '', AdmissionList[1], '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);
            CreateTicketBOM('31044', '', AdmissionList[7], '', 1, FALSE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

        END;

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

        IF (NOT TicketSetup.INSERT()) THEN TicketSetup.MODIFY();


        MESSAGE('Setup of DEMO data for ticketing, completed.');

    end;


    procedure SetupMembershipGuestTicket(AdmissionCode: Code[20]; AdmissionDescription: text[50]; ItemCode: Code[20]; ItemDescription: text[50]): code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        Item: Record Item;
        TicketSetup: Record "NPR TM Ticket Setup";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
        AdmissionList: array[10] of code[20];
    begin

        if (not Admission.get(AdmissionCode)) then begin
            WITH Admission DO
                CreateAdmissionCode(AdmissionCode, AdmissionDescription, Type::LOCATION, "Capacity Limits By"::OVERRIDE, "Default Schedule"::TODAY);

            WITH AdmissionSchedule DO BEGIN
                CreateSchedule(StrSubstNo('%1-WD', AdmissionCode), "Schedule Type"::LOCATION, "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, TRUE, TRUE, TRUE, TRUE, TRUE, FALSE, FALSE);
                CreateSchedule(StrSubstNo('%1-WE', AdmissionCode), "Schedule Type"::LOCATION, "Admission Is"::OPEN, TODAY, "Recurrence Until Pattern"::NO_END_DATE, 080000T, 230000T, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE, TRUE);
            END;

            WITH ScheduleLine DO BEGIN
                CreateScheduleLine(AdmissionCode, StrSubstNo('%1-WD', AdmissionCode), 1, FALSE, 17, "Capacity Control"::ADMITTED, '<+5D>', 0, 0);
                CreateScheduleLine(AdmissionCode, StrSubstNo('%1-WE', AdmissionCode), 1, FALSE, 23, "Capacity Control"::ADMITTED, '<+5D>', 0, 0);
            END;
        end;

        WITH TicketType DO
            CreateTicketType('MM-AUTO', 'Members and Member Guests', '<+7D>', 0, "Admission Registration"::INDIVIDUAL, "Activation Method"::POS_DEFAULT, "Ticket Entry Validation"::SINGLE, "Ticket Configuration Source"::TICKET_BOM);

        CreateItem(ItemCode, '', 'MM-AUTO', ItemDescription, 0);

        WITH TicketBom DO
            CreateTicketBOM(ItemCode, '', AdmissionCode, '', 1, TRUE, '', 0, "Activation Method"::SCAN, "Admission Entry Validation"::SINGLE);

        exit(StrSubstNo('IXRF-%1', ItemCode));
    end;

    local procedure ApplyConcurrencyLimit(AdmissionCodeFilter: Code[20]; ScheduleCodeFilter: Code[20]; ConcurrencyCode: Code[20])
    var
        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
    begin
        AdmissionScheduleLines.SETFILTER("Admission Code", AdmissionCodeFilter);


        AdmissionScheduleLines.SETFILTER("Schedule Code", ScheduleCodeFilter);

        if (ConcurrencyCode <> '') then
            AdmissionGroupConcurrency.GET(ConcurrencyCode);

        AdmissionScheduleLines.MODIFYALL("Concurrency Code", ConcurrencyCode);
    end;


    procedure CreateAdmissionCode(AdmissionCode: Code[20]; Description: text[50]; AdmissionType: Option; CapacityLimit: Option; DefaultSchedule: Option): code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.INIT();
        if (NOT Admission.GET(AdmissionCode)) then begin
            Admission."Admission Code" := AdmissionCode;
            Admission.INSERT();
        end;

        Admission.Type := AdmissionType;
        Admission.Description := Description;
        Admission."Capacity Limits By" := CapacityLimit;
        Admission."Default Schedule" := DefaultSchedule;

        Admission."Admission Base Calendar Code" := CreateBaseCalendar('', AdmissionCode);
        Admission.MODIFY();

        exit(AdmissionCode);
    end;

    local procedure CreateAdmissionScheduleEntry(AdmissionCode: Code[20]; ScheduleCode: Code[20]; StartDate: Date; StartTime: Time; EndDate: Date; EndTime: Time) EntryNo: Integer
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        AdmissionScheduleEntry."Entry No." := 0;
        AdmissionScheduleEntry.INSERT();

        AdmissionScheduleEntry."External Schedule Entry No." := AdmissionScheduleEntry."Entry No.";
        AdmissionScheduleEntry."Admission Code" := AdmissionCode;
        AdmissionScheduleEntry."Schedule Code" := GenerateCode20();
        AdmissionScheduleEntry."Admission Start Date" := StartDate;
        AdmissionScheduleEntry."Admission Start Time" := StartTime;
        AdmissionScheduleEntry."Admission End Date" := EndDate;
        AdmissionScheduleEntry."Admission End Time" := EndTime;
        AdmissionScheduleEntry.MODIFY();

        exit(AdmissionScheduleEntry."Entry No.");
    end;

    local procedure CreateBaseCalendar(CalendarCode: Code[10]; Desc: Text[30]): Code[10]
    var
        BaseCalendar: Record "Base Calendar";
    begin


        if (CalendarCode <> '') then
            if (NOT BaseCalendar.GET(CalendarCode)) then begin
                BaseCalendar.Code := CalendarCode;
                BaseCalendar.INSERT();
            end;

        if (CalendarCode = '') then begin
            BaseCalendar.Code := GenerateCode10();
            BaseCalendar.INSERT();
        end;

        BaseCalendar.INIT;
        BaseCalendar.Name := 'Automated Test Framework';
        if (Desc <> '') then
            BaseCalendar.Name := Desc;

        BaseCalendar.MODIFY();

        exit(BaseCalendar.Code);
    end;


    local procedure CreateConcurrencyLimit(Code: Code[20]; Description: Text; Limit: Integer; CapacityOption: Option; ConcurrencyOption: Option): Code[20]
    var
        AdmissionGroupConcurrency: Record "NPR TM Concurrent Admis. Setup";
    begin
        if (Code = '') then
            Code := GenerateCode20();

        if (NOT AdmissionGroupConcurrency.GET(Code)) then begin
            AdmissionGroupConcurrency.Code := Code;
            AdmissionGroupConcurrency.INSERT();
        end;

        AdmissionGroupConcurrency.Description := Description;
        AdmissionGroupConcurrency."Total Capacity" := Limit;
        AdmissionGroupConcurrency."Capacity Control" := CapacityOption;
        AdmissionGroupConcurrency."Concurrency Type" := ConcurrencyOption;
        AdmissionGroupConcurrency.MODIFY();

        exit(AdmissionGroupConcurrency.Code);
    end;

    procedure CreateItem(No: Code[20]; VariantCode: Code[10]; TicketTypeCode: Code[10]; Description: Text[30]; UnitPrice: Decimal): Code[20]
    var
        TicketItem: Record "Item";
        ItemVariant: Record "Item Variant";
        ItemCrossReference: Record "Item Cross Reference";
    begin
        TicketItem.INIT();
        if (NOT (TicketItem.GET(No))) then begin
            TicketItem.GET('70000');
            TicketItem."No." := No;
            TicketItem.INSERT();
        end;

        TicketItem.Description := Description;
        TicketItem."Unit Price" := UnitPrice;
        TicketItem.VALIDATE("NPR Ticket Type", TicketTypeCode);

        TicketItem.Blocked := FALSE;
        TicketItem."NPR Blocked on Pos" := FALSE;
        TicketItem."NPR Group sale" := FALSE;

        TicketItem.MODIFY();

        if (VariantCode <> '') then begin
            ItemVariant.INIT();
            if (NOT ItemVariant.GET(No, VariantCode)) then begin
                ItemVariant."Item No." := No;
                ItemVariant.Code := VariantCode;
                ItemVariant.INSERT();
            end;
            ItemVariant.Description := Description;
            ItemVariant.MODIFY();
        end;

        ItemCrossReference.INIT();
        ItemCrossReference.SETFILTER("Cross-Reference Type", '=%1', ItemCrossReference."Cross-Reference Type"::"Bar Code");
        ItemCrossReference.SETFILTER("Cross-Reference No.", '=%1', STRSUBSTNO('IXRF-%1', TicketItem."No."));
        if (VariantCode <> '') then
            ItemCrossReference.SETFILTER("Cross-Reference No.", '=%1', STRSUBSTNO('IXRF-%1-%2', TicketItem."No.", VariantCode));

        if (NOT ItemCrossReference.FINDFIRST()) then begin
            ItemCrossReference."Item No." := TicketItem."No.";
            ItemCrossReference."Variant Code" := VariantCode;
            ItemCrossReference."Unit of Measure" := TicketItem."Sales Unit of Measure";
            ItemCrossReference."Cross-Reference Type" := ItemCrossReference."Cross-Reference Type"::"Bar Code";
            ItemCrossReference."Cross-Reference No." := STRSUBSTNO('IXRF-%1', TicketItem."No.");
            if (VariantCode <> '') then
                ItemCrossReference."Cross-Reference No." := STRSUBSTNO('IXRF-%1-%2', TicketItem."No.", VariantCode);
            ItemCrossReference.Description := TicketItem.Description;
            ItemCrossReference.INSERT();
        end;

        exit(No);
    end;


    local procedure CreateNoSerie(NoSerieCode: Code[10]; StartNumber: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (NOT NoSeries.GET(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.INSERT();
        end;

        NoSeries.Description := 'Ticket Automated Test Framework';
        NoSeries."Default Nos." := TRUE;
        NoSeries.MODIFY();

        if (NOT NoSeriesLine.GET(NoSerieCode, 10000)) then begin
            NoSeriesLine."Series Code" := NoSerieCode;
            NoSeriesLine."Line No." := 10000;
            NoSeriesLine."Starting Date" := DMY2Date(1, 1, 2020);
            NoSeriesLine."Starting No." := StartNumber;
            NoSeriesLine."Increment-by No." := 1;
            NoSeriesLine.INSERT();
        end;
    end;

    procedure CreateSchedule(ScehduleCode: Code[20]; ScheduleType: Option; AdmissionIs: Option; StartFrom: Date; RecurrencePattern: Option; StartTime: Time; EndTime: Time; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Code[20]
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        AdmissionSchedule.INIT();
        if (NOT AdmissionSchedule.GET(ScehduleCode)) then begin
            AdmissionSchedule."Schedule Code" := ScehduleCode;
            AdmissionSchedule.INSERT();
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

        AdmissionSchedule.MODIFY();

        exit(ScehduleCode);
    end;

    procedure CreateSchedule(ScehduleCode: Code[20]; ScheduleType: Option; AdmissionIs: Option; StartFrom: Date; RecurrencePattern: Option; EndAfter: Date; StartTime: Time; EndTime: Time; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Code[20]
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        AdmissionSchedule.get(
            CreateSchedule(ScehduleCode, ScheduleType, AdmissionIs, StartFrom, RecurrencePattern, StartTime, EndTime, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday)
        );

        AdmissionSchedule."End After Date" := EndAfter;
        AdmissionSchedule.MODIFY();

        exit(ScehduleCode);
    end;


    procedure CreateScheduleLine(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ProcessOrder: Integer; PreBookRequired: Boolean; MaxCapacity: Integer; CapacityControl: Option; PrebookFromFormula: Text[30]; AllowAdmissionBeforeStart_Minutes: Integer; AllowAdmissionPassedStart_Minutes: Integer)
    var
        ScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleLines.INIT();
        if (NOT ScheduleLines.GET(AdmissionCode, ScheduleCode)) then begin
            ScheduleLines."Admission Code" := AdmissionCode;
            ScheduleLines."Schedule Code" := ScheduleCode;
            ScheduleLines.INSERT();
        end;

        ScheduleLines."Process Order" := ProcessOrder;
        ScheduleLines.Blocked := FALSE;
        ScheduleLines."Prebook Is Required" := PreBookRequired;
        EVALUATE(ScheduleLines."Prebook From", PrebookFromFormula);

        if (ScheduleLines."Prebook Is Required") then begin
            ScheduleLines.CALCFIELDS("Scheduled Start Time", "Scheduled Stop Time");

            ScheduleLines."Event Arrival From Time" := ScheduleLines."Scheduled Start Time";
            if (AllowAdmissionBeforeStart_Minutes > 0) then
                ScheduleLines."Event Arrival From Time" := ScheduleLines."Scheduled Start Time" + AllowAdmissionBeforeStart_Minutes * 60 * 1000; //millis

            ScheduleLines."Event Arrival Until Time" := ScheduleLines."Scheduled Stop Time";
            if (AllowAdmissionPassedStart_Minutes >= 0) then
                ScheduleLines."Event Arrival Until Time" := ScheduleLines."Scheduled Start Time" + AllowAdmissionPassedStart_Minutes * 60 * 1000; // millis


        end;
        ScheduleLines."Max Capacity Per Sch. Entry" := MaxCapacity;
        ScheduleLines."Capacity Control" := CapacityControl;
        ScheduleLines.MODIFY();

    end;


    local procedure CreateStakeholder(AdmissionCode: Code[20]; ScheduleCode: Code[20]; Stakeholder: Text[30]; NotificationModel: Option)
    var
        Admission: Record "NPR TM Admission";
        Schedule: Record "NPR TM Admis. Schedule";
    begin

        Admission.GET(AdmissionCode);
        Admission."Stakeholder (E-Mail/Phone No.)" := Stakeholder;
        Admission.MODIFY();

        Schedule.GET(ScheduleCode);
        Schedule."Notify Stakeholder" := NotificationModel;
        Schedule.MODIFY();
    end;

    procedure CreateTicketBOM(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; TicketBaseCalendarCode: Code[10]; Quantity: Integer; Default: Boolean; DurationFormula: Text[30]; MaxNoOfEntries: Integer; ActivationMethod: Option; EntryValidation: Option)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Item: Record Item;
        Admission: Record "NPR TM Admission";
    begin
        TicketBom.INIT();
        if (NOT TicketBom.GET(ItemNo, VariantCode, AdmissionCode)) then begin
            TicketBom."Item No." := ItemNo;
            TicketBom."Variant Code" := VariantCode;
            TicketBom."Admission Code" := AdmissionCode;
            TicketBom.INSERT();
        end;

        Item.GET(ItemNo);
        Admission.GET(AdmissionCode);

        TicketBom.Quantity := Quantity;
        TicketBom.Description := Item.Description;
        TicketBom.Default := Default;
        TicketBom."Admission Description" := Admission.Description;
        TicketBom."Prefered Sales Display Method" := TicketBom."Prefered Sales Display Method"::DEFAULT;

        EVALUATE(TicketBom."Duration Formula", DurationFormula);
        TicketBom."Max No. Of Entries" := MaxNoOfEntries;
        TicketBom."Activation Method" := ActivationMethod;
        TicketBom."Admission Entry Validation" := EntryValidation;
        TicketBom."Ticket Base Calendar Code" := TicketBaseCalendarCode;

        TicketBom.MODIFY();
    end;

    procedure CreateTicketType(TicketTypeCode: Code[10]; Description: text[50]; DurationFormula: Text[30]; MaxNumberOfEntries: Integer; AdmissionRegistration: Option; ActivationMethod: Option; EntryValidation: Option; ConfigurationSource: Option): Code[10]
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        TicketType.INIT();
        if (NOT TicketType.GET(TicketTypeCode)) then begin
            TicketType.Code := TicketTypeCode;
            TicketType.INSERT();
        end;

        TicketType.Description := Description;
        TicketType."Print Ticket" := FALSE;
        TicketType.VALIDATE("No. Series", 'NPR-TICKET');
        TicketType."External Ticket Pattern" := 'ATF-[S][A*1]-[N]';
        TicketType."Is Ticket" := TRUE;
        TicketType."Defer Revenue" := FALSE;

        EVALUATE(TicketType."Duration Formula", DurationFormula);
        TicketType."Max No. Of Entries" := MaxNumberOfEntries;
        TicketType."Admission Registration" := AdmissionRegistration;
        TicketType."Activation Method" := ActivationMethod;
        TicketType."Ticket Entry Validation" := EntryValidation;
        TicketType."Ticket Configuration Source" := ConfigurationSource;
        TicketType.MODIFY();

        exit(TicketTypeCode);
    end;

    local procedure GenerateCode10(): Code[20]
    begin
        exit(GetNextNoFromSeries('C1'));
    end;

    local procedure GenerateCode20(): Code[20]
    begin
        exit(GetNextNoFromSeries('C2'));
    end;

    local procedure GetNextNo(): Code[20]
    begin
        exit(GetNextNoFromSeries('TM'));
    end;

    local procedure GetNextNoFromSeries(FromSeries: Code[2]): Code[20]
    var
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        case FromSeries OF
            'TM':
                exit(NoSeriesManagement.GetNextNo('TM-ATF001', TODAY, TRUE));
            'C1':
                exit(NoSeriesManagement.GetNextNo('TM-PK10', TODAY, TRUE));
            'C2':
                exit(NoSeriesManagement.GetNextNo('TM-PK20', TODAY, TRUE));
            ELSE
                ERROR('Get Next No %1 from number series is not configured.', FromSeries);
        end;
    end;

    local procedure SetNonWorking(Code: Code[10]; Description: Text[30]; RecurringPattern: Integer; Date: Date; Day: Integer)
    var
        BaseCalendarChange: Record "Base Calendar Change";
    begin
        BaseCalendarChange."Base Calendar Code" := Code;
        BaseCalendarChange.Description := Description;
        BaseCalendarChange.Nonworking := TRUE;

        BaseCalendarChange."Recurring System" := RecurringPattern;
        case BaseCalendarChange."Recurring System" OF
            BaseCalendarChange."Recurring System"::"Annual Recurring":
                BaseCalendarChange.Date := Date;
            BaseCalendarChange."Recurring System"::"Weekly Recurring":
                BaseCalendarChange.Day := Day;
        END;

        IF (BaseCalendarChange.INSERT()) THEN;
    end;



}
