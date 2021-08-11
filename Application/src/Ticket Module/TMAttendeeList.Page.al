page 6014517 "NPR TM Attendee List"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM Attendees Buffer";
    SourceTableView = sorting(EntryNo);
    SourceTableTemporary = true;
    ShowFilter = false;
    LinksAllowed = false;
    Editable = false;
    Caption = 'List of Attendees';
    DataCaptionExpression = '';

    layout
    {
        area(Content)
        {
            repeater(RepeaterListName)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(TicketNumber; Rec.TicketNumber)
                {
                    ToolTip = 'Specifies the value of the Ticket No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(TicketStatus; Rec.TicketStatus)
                {
                    ToolTip = 'Specifies the value of the Ticket Status field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ToolTip = 'Specifies the value of the Admission Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(ScheduleCode; Rec.ScheduleCode)
                {
                    ToolTip = 'Specifies the value of the Schedule Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AdmissionStartDate; Rec.AdmissionStartDate)
                {
                    ToolTip = 'Specifies the value of the Admission Start Date field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AdmissionStartTime; Rec.AdmissionStartTime)
                {
                    ToolTip = 'Specifies the value of the Admission Start Time field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(MemberNumber; Rec.MemberNumber)
                {
                    ToolTip = 'Specifies the value of the Member No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(CustomerNumber; Rec.CustomerNumber)
                {
                    ToolTip = 'Specifies the value of the Customer No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(OrderNumber; Rec.OrderNumber)
                {
                    ToolTip = 'Specifies the value of the Order No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(NotificationAddress; Rec.NotificationAddress)
                {
                    ToolTip = 'Specifies the value of the Notification Address field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AdmittedDate; Rec.AdmittedDate)
                {
                    ToolTip = 'Specifies the value of the Admitted Date field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(AdmittedTime; Rec.AdmittedTime)
                {
                    ToolTip = 'Specifies the value of the Admitted Time field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(DisplayName; Rec.DisplayName)
                {
                    ToolTip = 'Specifies the value of the Display Name field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Address; Rec.Address)
                {
                    ToolTip = 'Specifies the value of the Address field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Address2; Rec.Address2)
                {
                    ToolTip = 'Specifies the value of the Address 2 field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(City; Rec.City)
                {
                    ToolTip = 'Specifies the value of the City field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(CountryCode; Rec.CountryCode)
                {
                    ToolTip = 'Specifies the value of the Country Code field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(Email; Rec.Email)
                {
                    ToolTip = 'Specifies the value of the E-Mail field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }
                field(PhoneNumber; Rec.PhoneNumber)
                {
                    ToolTip = 'Specifies the value of the Phone No. field';
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                }

            }
        }
    }

    procedure LoadPageBuffer(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"): Integer
    begin
        exit(LoadPageBuffer(AdmissionScheduleEntry, 20000));
    end;

    procedure LoadPageBuffer(AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry"; TopNumberOfRows: Integer): Integer
    var
        TicketReservationQuery: Query "NPR TM Attendees";
        TempAttendeeBuffer: Record "NPR TM Attendees Buffer" temporary;
        Member: Record "NPR MM Member";
        Customer: Record "Customer";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        RecordCounter: Integer;
    begin
        TicketReservationQuery.SetFilter(TicketReservationQuery.ExternalScheduleEntryNo, '=%1', AdmissionScheduleEntry."External Schedule Entry No.");

        TicketReservationQuery.TopNumberOfRows(TopNumberOfRows);
        TicketReservationQuery.Open();

        while (TicketReservationQuery.Read()) do begin
            RecordCounter += 1;
            TempAttendeeBuffer.Init();

            TempAttendeeBuffer.TicketStatus := TempAttendeeBuffer.TicketStatus::OPEN;
            if (TicketReservationQuery.SumQuantity = 0) then
                TempAttendeeBuffer.TicketStatus := TempAttendeeBuffer.TicketStatus::REVOKED;
            if (TicketReservationQuery.AccessDate <> 0D) then
                TempAttendeeBuffer.TicketStatus := TempAttendeeBuffer.TicketStatus::ADMITTED;

            TempAttendeeBuffer.AdmissionCode := TicketReservationQuery.AdmissionCode;
            TempAttendeeBuffer.ScheduleCode := TicketReservationQuery.ScheduleCode;
            TempAttendeeBuffer.TicketNumber := TicketReservationQuery.ExternalTicketNo;
            TempAttendeeBuffer.MemberNumber := TicketReservationQuery.MemberNumber;
            TempAttendeeBuffer.OrderNumber := TicketReservationQuery.ExternalOrderNumber;
            TempAttendeeBuffer.CustomerNumber := TicketReservationQuery.CustomerNumber;
            TempAttendeeBuffer.ExternalScheduleEntryNumber := TicketReservationQuery.ExternalScheduleEntryNo;
            TempAttendeeBuffer.AdmittedDate := TicketReservationQuery.AccessDate;
            TempAttendeeBuffer.AdmittedTime := TicketReservationQuery.AccessTime;

            TempAttendeeBuffer.AdmissionStartDate := AdmissionScheduleEntry."Admission Start Date";
            TempAttendeeBuffer.AdmissionStartTime := AdmissionScheduleEntry."Admission Start Time";

            if (TicketReservationQuery.MemberNumber <> '') then begin
                Member.SetFilter("External Member No.", '=%1', TicketReservationQuery.MemberNumber);
                if (Member.FindFirst()) then begin
                    TempAttendeeBuffer.DisplayName := Member."Display Name";
                    TempAttendeeBuffer.Address := Member.Address;
                    TempAttendeeBuffer.ZipCode := Member."Post Code Code";
                    TempAttendeeBuffer.City := Member.City;
                    TempAttendeeBuffer.CountryCode := Member."Country Code";
                    TempAttendeeBuffer.PhoneNumber := Member."Phone No.";
                    TempAttendeeBuffer.Email := Member."E-Mail Address";
                end;
            end;

            if (TicketReservationQuery.CustomerNumber <> '') then begin
                if (Customer.Get(TicketReservationQuery.CustomerNumber)) then begin
                    TempAttendeeBuffer.DisplayName := Customer.Name;
                    TempAttendeeBuffer.Address := Customer.Address;
                    TempAttendeeBuffer.Address2 := Customer."Address 2";
                    TempAttendeeBuffer.ZipCode := Customer."Post Code";
                    TempAttendeeBuffer.City := Customer.City;
                    TempAttendeeBuffer.CountryCode := Customer."Country/Region Code";
                    TempAttendeeBuffer.PhoneNumber := Customer."Phone No.";
                    TempAttendeeBuffer.Email := Customer."E-Mail";
                end;
            end;

            if (TicketReservationQuery.ExternalOrderNumber <> '') then begin
                SalesInvoiceHeader.SetFilter("External Document No.", '=%1', TicketReservationQuery.ExternalOrderNumber);
                if (SalesInvoiceHeader.FindFirst()) then begin
                    TempAttendeeBuffer.DisplayName := SalesInvoiceHeader."Sell-to Customer Name";
                    TempAttendeeBuffer.Address := SalesInvoiceHeader."Sell-to Address";
                    TempAttendeeBuffer.Address2 := SalesInvoiceHeader."Sell-to Address 2";
                    TempAttendeeBuffer.ZipCode := SalesInvoiceHeader."Sell-to Post Code";
                    TempAttendeeBuffer.City := SalesInvoiceHeader."Sell-to City";
                    TempAttendeeBuffer.CountryCode := SalesInvoiceHeader."Sell-to Country/Region Code";
                    TempAttendeeBuffer.Email := SalesInvoiceHeader."Sell-to E-Mail";
                    TempAttendeeBuffer.PhoneNumber := SalesInvoiceHeader."Sell-to Phone No.";
                end;
            end;

            TempAttendeeBuffer.EntryNo := RecordCounter;
            TempAttendeeBuffer.Insert();

        end;

        if (Rec.IsTemporary()) then
            Rec.DeleteAll();
        Rec.Copy(TempAttendeeBuffer, true);

        exit(RecordCounter);

    end;

}

