codeunit 85011 "NPR Library - Ticket Module"
{

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Variety Clone Data", 'CheckIfSkipCreateDefaultBarcode', '', true, true)]
    local procedure CheckIfSkipCreateDefaultBarcode(ItemNo: Code[20]; VariantCode: Code[10]; var SkipCreateDefaultBarcode: Boolean; var Handled: Boolean)
    begin
        // Variety number series vs data are messed-up in default dev container
        SkipCreateDefaultBarcode := true;
        Handled := true;
    end;

    procedure CreateScenario_DynamicPrice() SalesItemNo: Code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketSetup: Record "NPR TM Ticket Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
    begin

        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // Used for testing dynamic prices

        CreateNoSerie('ATF-TM-ATF001', 'QWETMATF9000001');
        CreateNoSerie('ATF-TM-TICKET', 'QWE9000001');
        CreateNoSerie('ATF-TM-PK10', 'QWEPK10000');         // Code 10 number series
        CreateNoSerie('ATF-TM-PK20', 'QWEPK2000000000');    // Code 20 number series

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', ''));
        ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, true, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, '');
        CreateScheduleLinePriceProfile(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+7D>', 0, 0);


        ItemNo := CreateItem('', TicketTypeCode, 100);
        CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
    end;

    procedure CreateScenario_SmokeTest() SalesItemNo: Code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketSetup: Record "NPR TM Ticket Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
    begin

        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // Used for smoke testing
        // This scenario creates a ticket which is always available today.

        CreateNoSerie('ATF-TM-ATF001', 'QWETMATF9000001');
        CreateNoSerie('ATF-TM-TICKET', 'QWE9000001');
        CreateNoSerie('ATF-TM-PK10', 'QWEPK10000');         // Code 10 number series
        CreateNoSerie('ATF-TM-PK20', 'QWEPK2000000000');    // Code 20 number series

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', ''));
        ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, true, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, '');
        CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');

        ItemNo := CreateItem('', TicketTypeCode, Random(200) + 100);
        CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
    end;

    procedure CreateScenario_ReservationRequired(NumberOfTimeSlots: Integer) SalesItemNo: Code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketSetup: Record "NPR TM Ticket Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        i, SlotSize : Integer;
    begin

        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // This scenario creates a ticket setup that requires a reservation time entry that you provide.

        SlotSize := Round((24 * 60 * 60 - 2) / NumberOfTimeSlots, 0.001); // -2 => 00:00:01 -> 23:59:59 intervall

        CreateNoSerie('ATF-TM-ATF001', 'QWETMATF9000001');
        CreateNoSerie('ATF-TM-TICKET', 'QWE9000001');
        CreateNoSerie('ATF-TM-PK10', 'QWEPK10000');         // Code 10 number series
        CreateNoSerie('ATF-TM-PK20', 'QWEPK2000000000');    // Code 20 number series

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::OCCASION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::SCHEDULE_ENTRY, '', ''));
        for i := 1 to NumberOfTimeSlots do begin
            ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::"EVENT", AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, (000001T + SlotSize * (i - 1) * 1000), (000001T + SlotSize * i * 1000), true, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, '');
            CreateScheduleLine(AdmissionCode, ScheduleCode, 1, true, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');
        end;

        ItemNo := CreateItem('', TicketTypeCode, Random(200) + 100);
        CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
    end;


    procedure CreateScenario_TicketStatistics(RevisitPolicy: Option NA,NONINITIAL,DAILY_NONINITIAL,NEVER) SalesItemNo: Code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketSetup: Record "NPR TM Ticket Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
    begin

        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // Used for smoke testing
        // This scenario creates a ticket which is always available today.

        CreateNoSerie('ATF-TM-ATF001', 'QWETMATF9000001');
        CreateNoSerie('ATF-TM-TICKET', 'QWE9000001');
        CreateNoSerie('ATF-TM-PK10', 'QWEPK10000');         // Code 10 number series
        CreateNoSerie('ATF-TM-PK20', 'QWEPK2000000000');    // Code 20 number series

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::MULTIPLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', ''));
        ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, true, true, true, true, true, true, true, '');
        CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+10D>', 0, 0, '');

        ItemNo := CreateItem('', TicketTypeCode, Random(200) + 100);
        CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, true, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::MULTIPLE);

        TicketBom.Get(ItemNo, '', AdmissionCode);
        TicketBom."Revisit Condition (Statistics)" := RevisitPolicy;
        TicketBom."Max No. Of Entries" := 100;
        TicketBom."Revoke Policy" := TicketBom."Revoke Policy"::ALWAYS;
        TicketBom.Modify();

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
    end;

    procedure CreateScenario_BaseCalendar() SalesItemNo: Code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        TicketSetup: Record "NPR TM Ticket Setup";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        AdmissionBaseCalendarCode, TicketBaseCalendarCode : Code[10];
    begin

        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // Used for smoke testing
        // This scenario creates a ticket which is always available today.

        CreateNoSerie('ATF-TM-ATF001', 'QWETMATF9000001');
        CreateNoSerie('ATF-TM-TICKET', 'QWE9000001');
        CreateNoSerie('ATF-TM-PK10', 'QWEPK10000');         // Code 10 number series
        CreateNoSerie('ATF-TM-PK20', 'QWEPK2000000000');    // Code 20 number series

        AdmissionBaseCalendarCode := CreateBaseCalendar(GenerateCode10());
        TicketBaseCalendarCode := CreateBaseCalendar(GenerateCode10());

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+1M>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::MULTIPLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, AdmissionBaseCalendarCode, TicketBaseCalendarCode));
        ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, true, true, true, true, true, true, true, AdmissionBaseCalendarCode);
        CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+1M>', 0, 0, AdmissionBaseCalendarCode);

        ItemNo := CreateItem('', TicketTypeCode, Random(200) + 100);
        CreateTicketBOM(ItemNo, '', AdmissionCode, TicketBaseCalendarCode, 1, true, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::MULTIPLE);

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
    end;

    local procedure CreateBaseCalendar(CalendarCode: Code[10]): Code[10]
    var
        BaseCalendar: Record "Base Calendar";
    begin
        if (CalendarCode = '') then
            CalendarCode := GenerateCode10();

        if (not BaseCalendar.Get(CalendarCode)) then begin
            BaseCalendar.Init();
            BaseCalendar.Code := CalendarCode;
            BaseCalendar.Insert();
        end;

        exit(BaseCalendar.Code);
    end;

    procedure CreateItem(VariantCode: Code[10]; TicketTypeCode: Code[10]; UnitPrice: Decimal) ItemNo: Code[20]
    var
        TicketItem: Record "Item";
        ItemVariant: Record "Item Variant";
        ItemReference: Record "Item Reference";
        LibraryInventory: Codeunit "NPR Library - Inventory";
    begin
        LibraryInventory.CreateItem(TicketItem);

        TicketItem."Unit Price" := UnitPrice;
        TicketItem.Blocked := false;
        TicketItem."NPR Group sale" := false;
        TicketItem.VALIDATE("NPR Ticket Type", TicketTypeCode);
        TicketItem.Modify();

        if (VariantCode <> '') then begin
            ItemVariant.INIT();
            if (not ItemVariant.Get(TicketItem."No.", VariantCode)) then begin
                ItemVariant."Item No." := TicketItem."No.";
                ItemVariant.Code := VariantCode;
                ItemVariant.Insert();
            end;
            ItemVariant.Description := TicketItem.Description;
            ItemVariant.Modify();
        end;

        ItemReference.INIT();
        ItemReference.SetFilter("Reference Type", '=%1', ItemReference."Reference Type"::"Bar Code");
        ItemReference.SetFilter("Reference No.", '=%1', StrSubstNo('IXRF-%1', TicketItem."No."));
        if (VariantCode <> '') then
            ItemReference.SetFilter("Reference No.", '=%1', StrSubstNo('IXRF-%1-%2', TicketItem."No.", VariantCode));

        if (not ItemReference.FindFirst()) then begin
            ItemReference."Item No." := TicketItem."No.";
            ItemReference."Variant Code" := VariantCode;
            ItemReference."Unit of Measure" := TicketItem."Sales Unit of Measure";
            ItemReference."Reference Type" := ItemReference."Reference Type"::"Bar Code";
            ItemReference."Reference No." := StrSubstNo('IXRF-%1', TicketItem."No.");
            if (VariantCode <> '') then
                ItemReference."Reference No." := StrSubstNo('IXRF-%1-%2', TicketItem."No.", VariantCode);
            ItemReference.Description := TicketItem.Description;
            ItemReference.Insert();
        end;

        exit(TicketItem."No.");
    end;

    procedure CreateAdmissionCode(AdmissionCode: Code[20]; AdmissionType: Option; CapacityLimit: Option; DefaultSchedule: Option; AdmissionBaseCalendarCode: Code[10]; TicketBaseCalendarCode: Code[10]): code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.INIT();
        if (not Admission.Get(AdmissionCode)) then begin
            Admission."Admission Code" := AdmissionCode;
            Admission.Insert();
        end;

        Admission.Type := AdmissionType;
        Admission.Description := AdmissionCode;
        Admission."Capacity Limits By" := CapacityLimit;
        Admission."Default Schedule" := DefaultSchedule;

        Admission."Admission Base Calendar Code" := AdmissionBaseCalendarCode;
        Admission."Ticket Base Calendar Code" := TicketBaseCalendarCode;

        Admission.Modify();

        exit(AdmissionCode);
    end;

    procedure CreateTicketType(TicketTypeCode: Code[10]; DurationFormula: Text[30]; MaxNumberOfEntries: Integer; AdmissionRegistration: Option; ActivationMethod: Option; EntryValidation: Option; ConfigurationSource: Option): Code[10]
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        TicketType.INIT();
        if (not TicketType.Get(TicketTypeCode)) then begin
            TicketType.Code := TicketTypeCode;
            TicketType.Insert();
        end;

        TicketType.Description := TicketTypeCode;
        TicketType."Print Ticket" := false;
        TicketType.VALIDATE("No. Series", 'ATF-TM-TICKET');
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

    local procedure CreateNoSerie(NoSerieCode: Code[20]; StartNumber: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (not NoSeries.Get(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.Insert();
        end;

        NoSeries.Description := NoSerieCode;
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

    procedure CreateSchedule(ScehduleCode: Code[20]; ScheduleType: Option; AdmissionIs: Option; StartFrom: Date; RecurrencePattern: Option; StartTime: Time; EndTime: Time; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean; AdmissionBaseCalendarCode: Code[10]): Code[20]
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
    begin
        AdmissionSchedule.INIT();
        if (not AdmissionSchedule.Get(ScehduleCode)) then begin
            AdmissionSchedule."Schedule Code" := ScehduleCode;
            AdmissionSchedule.Insert();
        end;

        AdmissionSchedule."Schedule Type" := ScheduleType;
        AdmissionSchedule."Admission Is" := AdmissionIs;
        AdmissionSchedule.Description := ScehduleCode;
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
        AdmissionSchedule."Admission Base Calendar Code" := AdmissionBaseCalendarCode;
        AdmissionSchedule.Modify();

        exit(ScehduleCode);
    end;

    procedure CreateScheduleLinePriceProfile(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ProcessOrder: Integer; PreBookRequired: Boolean; MaxCapacity: Integer; CapacityControl: Option; PrebookFromFormula: Text[30]; AllowAdmissionBeforeStart_Minutes: Integer; AllowAdmissionPassedStart_Minutes: Integer)
    var
        ScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        CreateScheduleLine(AdmissionCode, ScheduleCode, ProcessOrder, PreBookRequired, MaxCapacity, CapacityControl, PrebookFromFormula, AllowAdmissionBeforeStart_Minutes, AllowAdmissionPassedStart_Minutes, '');
        ScheduleLines.Get(AdmissionCode, ScheduleCode);
        ScheduleLines."Dynamic Price Profile Code" := CreatePriceProfile(GenerateCode10());
        ScheduleLines.Modify();
    end;

    procedure CreateScheduleLine(AdmissionCode: Code[20]; ScheduleCode: Code[20]; ProcessOrder: Integer; PreBookRequired: Boolean; MaxCapacity: Integer; CapacityControl: Option; PrebookFromFormula: Text[30]; AllowAdmissionBeforeStart_Minutes: Integer; AllowAdmissionPassedStart_Minutes: Integer; AdmissionBaseCalendar: Code[10])
    var
        ScheduleLines: Record "NPR TM Admis. Schedule Lines";
    begin
        ScheduleLines.INIT();
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
            ScheduleLines.CALCFIELDS("Scheduled Start Time", "Scheduled Stop Time");

            ScheduleLines."Event Arrival From Time" := ScheduleLines."Scheduled Start Time";
            if (AllowAdmissionBeforeStart_Minutes > 0) then
                ScheduleLines."Event Arrival From Time" := ScheduleLines."Scheduled Start Time" + AllowAdmissionBeforeStart_Minutes * 60 * 1000; //millis

            ScheduleLines."Event Arrival Until Time" := ScheduleLines."Scheduled Stop Time";
            if (AllowAdmissionPassedStart_Minutes >= 0) then
                ScheduleLines."Event Arrival Until Time" := ScheduleLines."Scheduled Stop Time" + AllowAdmissionPassedStart_Minutes * 60 * 1000; // millis

        end;
        ScheduleLines."Max Capacity Per Sch. Entry" := MaxCapacity;
        ScheduleLines."Capacity Control" := CapacityControl;
        ScheduleLines."Admission Base Calendar Code" := AdmissionBaseCalendar;
        ScheduleLines.Modify();
    end;

    procedure CreatePriceProfile(ProfileCode: Code[10]): Code[10]
    var
        PriceProfile: Record "NPR TM Dynamic Price Profile";
    begin
        PriceProfile.Init();
        if (not PriceProfile.Get(ProfileCode)) then begin
            PriceProfile.ProfileCode := ProfileCode;
            PriceProfile.Insert();
        end;
        PriceProfile.Modify();
        exit(PriceProfile.ProfileCode);
    end;

    procedure CreateTicketBOM(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; TicketBaseCalendarCode: Code[10]; Quantity: Integer; Default: Boolean; DurationFormula: Text[30]; MaxNoOfEntries: Integer; ActivationMethod: Option; EntryValidation: Option)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Item: Record Item;
        Admission: Record "NPR TM Admission";
    begin
        TicketBom.INIT();
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

        TicketBom.Modify();
    end;

    procedure CreateTicketBOMDynamic(ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; TicketBaseCalendarCode: Code[10]; Quantity: Integer; Default: Boolean; DurationFormula: Text[30]; MaxNoOfEntries: Integer; ActivationMethod: Option; EntryValidation: Option; AdmissionInclusion: Option)
    var
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Item: Record Item;
        Admission: Record "NPR TM Admission";
    begin
        TicketBom.INIT();
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

    procedure CreateAttribute(CodePrefix: Code[10]; AttributeNumber: Integer; BaseDescription: Text): Code[20]
    var
        NPRAttribute: Record "NPR Attribute";
    begin
        if (CodePrefix <> '') then
            NPRAttribute.Code := StrSubstNo('%1-%2', CodePrefix, AttributeNumber);
        if (NPRAttribute.Code = '') then
            NPRAttribute.Code := GenerateCode10();

        if (not NPRAttribute.Get(NPRAttribute.Code)) then
            NPRAttribute.Insert();

        NPRAttribute.Name := StrSubstNo('%1 %2', BaseDescription, AttributeNumber);
        NPRAttribute."Code Caption" := StrSubstNo('%1 %2 c', BaseDescription, AttributeNumber);
        NPRAttribute."Filter Caption" := StrSubstNo('%1 %2 f', BaseDescription, AttributeNumber);
        NPRAttribute.Description := StrSubstNo('%1 %2 d', BaseDescription, AttributeNumber);

        NPRAttribute."Value Datatype" := NPRAttribute."Value Datatype"::DT_TEXT;
        NPRAttribute."On Validate" := NPRAttribute."On Validate"::DATATYPE;
        NPRAttribute."On Format" := NPRAttribute."On Format"::NATIVE;
        NPRAttribute.Modify();

        exit(NPRAttribute.Code);
    end;

    procedure CreateAttributeTableLink(AttributeCode: Code[20]; TableId: Integer; AttributeNumber: Integer): Code[20]
    var
        NPRAttributeID: Record "NPR Attribute ID";
    begin

        NPRAttributeID.SetFilter("Table ID", '=%1', TableId);
        NPRAttributeID.SetFilter("Shortcut Attribute ID", '=%1', AttributeNumber);
        NPRAttributeID.DeleteAll();

        if (not NPRAttributeID.Get(TableId, AttributeNumber)) then begin
            NPRAttributeID."Table ID" := TableId;
            NPRAttributeID."Attribute Code" := AttributeCode;
            NPRAttributeID.Insert();
        end;

        NPRAttributeID.Validate("Shortcut Attribute ID", AttributeNumber);
        NPRAttributeID.Modify();

        exit(AttributeCode);
    end;

    procedure GenerateCode10(): Code[20]
    begin
        exit(GetNextNoFromSeries('C1'));
    end;

    procedure GenerateCode20(): Code[20]
    begin
        exit(GetNextNoFromSeries('C2'));
    end;

    internal procedure CreateDynamicTicketScenario(TicketBOMElements: Integer; RequiredBOMElements: Integer): Code[20]
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        AdmissionSchedule: Record "NPR TM Admis. Schedule";
        ScheduleLine: Record "NPR TM Admis. Schedule Lines";
        POSPostingProfile: Record "NPR POS Posting Profile";
        NprMasterData: Codeunit "NPR Library - POS Master Data";
        ScheduleManager: Codeunit "NPR TM Admission Sch. Mgt.";
        AdmissionCode: Code[20];
        ScheduleCode: Code[20];
        ItemNo: Code[20];
        TicketTypeCode: Code[10];
        i: Integer;
        Default: Boolean;
        AdmissionInclusion: Option;
    begin
        NprMasterData.CreateDefaultPostingSetup(POSPostingProfile);
        WorkDate(Today());

        // Used for smoke testing
        // This scenario creates a ticket which is always available today.

        CreateNoSerie('ATF-TM-ATF001', 'QWETMATF9000001');
        CreateNoSerie('ATF-TM-TICKET', 'QWE9000001');
        CreateNoSerie('ATF-TM-PK10', 'QWEPK10000');         // Code 10 number series
        CreateNoSerie('ATF-TM-PK20', 'QWEPK2000000000');    // Code 20 number series

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        ItemNo := CreateItem('', TicketTypeCode, Random(200) + 100);

        for i := 1 to TicketBOMElements do begin
            Setup(i, Default, AdmissionInclusion, RequiredBOMElements);
            AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY, '', ''));
            ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, true, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, '');
            CreateScheduleLine(AdmissionCode, ScheduleCode, 1, false, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0, '');

            CreateTicketBOMDynamic(ItemNo, '', AdmissionCode, '', 1, Default, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::SINGLE, AdmissionInclusion);
        end;

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
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
                exit(NoSeriesManagement.GetNextNo('ATF-TM-ATF001', TODAY, true));
            'C1':
                exit(NoSeriesManagement.GetNextNo('ATF-TM-PK10', TODAY, true));
            'C2':
                exit(NoSeriesManagement.GetNextNo('ATF-TM-PK20', TODAY, true));
            else
                Error('Get Next No %1 from number series is not configured.', FromSeries);
        end;
    end;

    local procedure Setup(i: Integer; var Default: Boolean; var AdmissionInclusion: Option; RequiredBOMElements: Integer)
    begin
        Default := i = 1;
        if i <= RequiredBOMElements then
            AdmissionInclusion := 0
        else
            AdmissionInclusion := 2;
    end;

}