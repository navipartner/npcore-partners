codeunit 85011 "NPR Library - Ticket Module"
{

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
        WorkDate(Today);

        // Used for smoke testing
        // This scenario creates a ticket which is always available today.

        CreateNoSerie('TM-ATF001', 'TMATF0000001');
        CreateNoSerie('NPR-TICKET', 'NPR0000001');
        CreateNoSerie('TM-PK10', 'TM-PK10000');         // Code 10 number series
        CreateNoSerie('TM-PK20', 'TM-PK2000000000');    // Code 20 number series

        TicketTypeCode := CreateTicketType(GenerateCode10(), '<+7D>', 0, TicketType."Admission Registration"::INDIVIDUAL, TicketType."Activation Method"::SCAN, TicketType."Ticket Entry Validation"::SINGLE, TicketType."Ticket Configuration Source"::TICKET_BOM);
        AdmissionCode := (CreateAdmissionCode(GenerateCode20(), Admission.Type::LOCATION, Admission."Capacity Limits By"::OVERRIDE, Admission."Default Schedule"::TODAY));
        ScheduleCode := CreateSchedule(GenerateCode20(), AdmissionSchedule."Schedule Type"::LOCATION, AdmissionSchedule."Admission Is"::OPEN, TODAY, AdmissionSchedule."Recurrence Until Pattern"::NO_END_DATE, 000001T, 235959T, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE, TRUE);
        CreateScheduleLine(AdmissionCode, ScheduleCode, 1, FALSE, 1000, ScheduleLine."Capacity Control"::ADMITTED, '<+5D>', 0, 0);

        ItemNo := CreateItem('', TicketTypeCode, Random(200) + 100);
        CreateTicketBOM(ItemNo, '', AdmissionCode, '', 1, TRUE, '<+7D>', 0, TicketBom."Activation Method"::SCAN, TicketBom."Admission Entry Validation"::SINGLE);

        ScheduleManager.CreateAdmissionSchedule(AdmissionCode, true, Today);

        exit(ItemNo)
    end;


    procedure CreateItem(VariantCode: Code[10]; TicketTypeCode: Code[10]; UnitPrice: Decimal) ItemNo: Code[20]
    var
        TicketItem: Record "Item";
        ItemVariant: Record "Item Variant";
        ItemCrossReference: Record "Item Cross Reference";
        LibraryInventory: Codeunit "NPR Library - Inventory";
    begin
        LibraryInventory.CreateItem(TicketItem);

        TicketItem."Unit Price" := UnitPrice;
        TicketItem.VALIDATE("NPR Ticket Type", TicketTypeCode);

        TicketItem.Blocked := FALSE;
        TicketItem."NPR Blocked on Pos" := FALSE;
        TicketItem."NPR Group sale" := FALSE;

        TicketItem.MODIFY();

        if (VariantCode <> '') then begin
            ItemVariant.INIT();
            if (NOT ItemVariant.GET(TicketItem."No.", VariantCode)) then begin
                ItemVariant."Item No." := TicketItem."No.";
                ItemVariant.Code := VariantCode;
                ItemVariant.INSERT();
            end;
            ItemVariant.Description := TicketItem.Description;
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

        exit(TicketItem."No.");
    end;

    procedure CreateAdmissionCode(AdmissionCode: Code[20]; AdmissionType: Option; CapacityLimit: Option; DefaultSchedule: Option): code[20]
    var
        Admission: Record "NPR TM Admission";
    begin
        Admission.INIT();
        if (NOT Admission.GET(AdmissionCode)) then begin
            Admission."Admission Code" := AdmissionCode;
            Admission.INSERT();
        end;

        Admission.Type := AdmissionType;
        Admission.Description := AdmissionCode;
        Admission."Capacity Limits By" := CapacityLimit;
        Admission."Default Schedule" := DefaultSchedule;

        Admission.MODIFY();

        exit(AdmissionCode);
    end;

    procedure CreateTicketType(TicketTypeCode: Code[10]; DurationFormula: Text[30]; MaxNumberOfEntries: Integer; AdmissionRegistration: Option; ActivationMethod: Option; EntryValidation: Option; ConfigurationSource: Option): Code[10]
    var
        TicketType: Record "NPR TM Ticket Type";
    begin
        TicketType.INIT();
        if (NOT TicketType.GET(TicketTypeCode)) then begin
            TicketType.Code := TicketTypeCode;
            TicketType.INSERT();
        end;

        TicketType.Description := TicketTypeCode;
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

    local procedure CreateNoSerie(NoSerieCode: Code[10]; StartNumber: Code[20])
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        if (NOT NoSeries.GET(NoSerieCode)) then begin
            NoSeries.Code := NoSerieCode;
            NoSeries.INSERT();
        end;

        NoSeries.Description := NoSerieCode;
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


}