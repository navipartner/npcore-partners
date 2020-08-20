table 6060112 "RC Ticket Cues"
{
    // TM1.30/TSA /20180409 CASE 310669 Fixed calculation of MaxCapacity

    Caption = 'RC Ticket Cues';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[10])
        {
            Caption = 'Code';
            DataClassification = CustomerContent;
            NotBlank = true;
        }
        field(10; "Event Count 1"; Integer)
        {
            Caption = 'Events (Today)';
            DataClassification = CustomerContent;
            Description = 'Count of Scheduled Events';
        }
        field(11; "Event Capacity 1"; Integer)
        {
            Caption = 'Capacity (Today)';
            DataClassification = CustomerContent;
            Description = 'Sum of Event Capacity';
        }
        field(12; "Event Open Reservations 1"; Integer)
        {
            Caption = 'Reservations (Today)';
            DataClassification = CustomerContent;
            Description = 'Sum of Event Reservation';
        }
        field(13; "Event Admitted 1"; Integer)
        {
            Caption = 'Admitted Cnt. (Today)';
            DataClassification = CustomerContent;
        }
        field(14; "Event Utilization Avg. 1"; Decimal)
        {
            Caption = 'Utilization % (Today)';
            DataClassification = CustomerContent;
            Description = 'Average of Event Utilization';
        }
        field(20; "Event Count 2"; Integer)
        {
            Caption = 'Events (Tomorrow)';
            DataClassification = CustomerContent;
            Description = 'Count of Scheduled Events';
        }
        field(21; "Event Capacity 2"; Integer)
        {
            Caption = 'Capacity (Tomorrow)';
            DataClassification = CustomerContent;
            Description = 'Sum of Event Capacity';
        }
        field(22; "Event Open Reservations 2"; Integer)
        {
            Caption = 'Reservations (Tomorrow)';
            DataClassification = CustomerContent;
            Description = 'Sum of Event Reservation';
        }
        field(23; "Event Admitted 2"; Integer)
        {
            Caption = 'Admitted Cnt. (Tomorrow)';
            DataClassification = CustomerContent;
        }
        field(24; "Event Utilization Avg. 2"; Decimal)
        {
            Caption = 'Utilization % (Tomorrow)';
            DataClassification = CustomerContent;
            Description = 'Average of Event Utilization';
        }
    }

    keys
    {
        key(Key1; "Code")
        {
        }
    }

    fieldgroups
    {
    }

    procedure CalculateCues()
    var
        EventDate: Date;
    begin

        EventDate := WorkDate;
        GetEventCues(EventDate, "Event Count 1", "Event Capacity 1", "Event Open Reservations 1", "Event Admitted 1", "Event Utilization Avg. 1");

        EventDate := CalcDate('<+1D>', EventDate);
        GetEventCues(EventDate, "Event Count 2", "Event Capacity 2", "Event Open Reservations 2", "Event Admitted 2", "Event Utilization Avg. 2");
    end;

    local procedure GetEventCues(ReferenceDate: Date; var EventCount: Integer; var MaxCapacity: Integer; var OpenReservations: Integer; var Admitted: Integer; var Utilization: Decimal)
    var
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        AdmissionScheduleLine: Record "TM Admission Schedule Lines";
        Admission: Record "TM Admission";
        TicketManagement: Codeunit "TM Ticket Management";
        Capacity: Integer;
        CapacityControl: Option;
    begin

        EventCount := 0;
        MaxCapacity := 0;
        OpenReservations := 0;
        Admitted := 0;
        Utilization := 0;

        AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', ReferenceDate);
        AdmissionScheduleEntry.SetFilter("Admission Is", '=%1', AdmissionScheduleEntry."Admission Is"::OPEN);

        if (not AdmissionScheduleEntry.FindSet()) then
            exit;

        repeat
            if (Admission.Get(AdmissionScheduleEntry."Admission Code")) then begin
                if (Admission.Type = Admission.Type::OCCASION) then begin
                    if (AdmissionScheduleLine.Get(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code")) then begin
                        AdmissionScheduleEntry.CalcFields("Open Reservations", "Open Admitted", Departed);

                        EventCount += 1;
                        //-#310669 [310669]
                        Capacity := 0;
                        TicketManagement.GetAdmissionCapacity(AdmissionScheduleEntry."Admission Code", AdmissionScheduleEntry."Schedule Code", AdmissionScheduleEntry."Entry No.", Capacity, CapacityControl);
                        MaxCapacity += Capacity;
                        if (Capacity = 0) then
                            Capacity := 1;
                        //MaxCapacity := AdmissionScheduleLine."Max Capacity Per Sch. Entry";
                        //+#310669 [310669]

                        OpenReservations += AdmissionScheduleEntry."Open Reservations";
                        Admitted += AdmissionScheduleEntry."Open Admitted";
                        if (AdmissionScheduleLine."Max Capacity Per Sch. Entry" > 0) then
                            //-#310669 [310669]
                            //Utilization += (AdmissionScheduleEntry."Open Reservations" + AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry.Departed) / AdmissionScheduleLine."Max Capacity Per Sch. Entry";
                            Utilization += (AdmissionScheduleEntry."Open Reservations" + AdmissionScheduleEntry."Open Admitted" + AdmissionScheduleEntry.Departed) / Capacity;
                        //+#310669 [310669]

                    end;
                end;
            end;
        until (AdmissionScheduleEntry.Next() = 0);

        if (EventCount > 0) then
            Utilization := (Utilization / EventCount) * 100;
    end;
}

