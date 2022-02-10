report 6060121 "NPR TM Ticket Reservation List"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = '.\src\_Reports\layouts\TM Ticket Reservation List.rdlc';
    UsageCategory = ReportsAndAnalysis;
    Caption = 'Ticket Reservation List';
    ApplicationArea = all;

    dataset
    {
        dataitem("Integer"; Integer)
        {
            DataItemTableView = SORTING(Number);
            column(AdmissionCode; TicketReservationList.AdmissionCode)
            {
            }
            column(ScheduleCode; TicketReservationList.ScheduleCode)
            {
            }
            column(TicketNumber; TicketReservationList.TicketID)
            {
            }
            column(NotificationAddress; TicketReservationList.NotificationAddress)
            {
            }
            column(ToBeRedeemed; ToBeRedeemed)
            {
            }
            column(AdmittedDate; TicketReservationList.AccessDate)
            {
            }
            column(AdmittedTime; TicketReservationList.AccessTime)
            {
            }
            column(AdmissionStartDate; AdmissionScheduleEntry."Admission Start Date")
            {
            }
            column(AdmissionStartTime; AdmissionScheduleEntry."Admission Start Time")
            {
            }
            column(SalesDateTime; InitialEntry."Created Datetime")
            {
            }
            column(TicketStatus; TicketStatus)
            {
                OptionCaption = 'Open,Revoked,Admitted';
            }
            column(MemberNo; TicketReservationList.CustomerNumber)
            {
            }
            column(CustomerNo; TicketReservationList.CustomerNumber)
            {
            }
            column(ExternalOrderNo; TicketReservationList.ExternalOrderNumber)
            {
            }
            column(Name; Name)
            {
            }
            column(Address; Address1)
            {
            }
            column(Address2; Address2)
            {
            }
            column(ZipCode; ZipCode)
            {
            }
            column(City; City)
            {
            }
            column(Country; Country)
            {
            }
            column(PhoneNumber; PhoneNumber)
            {
            }

            trigger OnAfterGetRecord()
            var
                Member: Record "NPR MM Member";
                Customer: Record Customer;
                SalesInvoiceHeader: Record "Sales Invoice Header";
            begin

                IF (NOT TicketReservationList.READ()) THEN
                    CurrReport.BREAK();

                AdmissionScheduleEntry.GET(TicketReservationList.EntryID);
                IF (NOT ((AdmissionScheduleEntry."Admission Start Date" >= AdmissionStart_DateLow) AND (AdmissionScheduleEntry."Admission Start Date" <= AdmissionStart_DateHigh))) THEN
                    CurrReport.SKIP();

                InitialEntry.SETFILTER("External Adm. Sch. Entry No.", '=%1', TicketReservationList.ExternalScheduleEntryNo);
                InitialEntry.SETFILTER("Ticket Access Entry No.", '=%1', TicketReservationList.TicketAccessEntryID);
                InitialEntry.SETFILTER(Type, '=%1', InitialEntry.Type::INITIAL_ENTRY);
                InitialEntry.SETFILTER(Quantity, '>=%1', 1);
                InitialEntry.FINDFIRST();

                TicketStatus := TicketStatus::OPEN;
                IF (TicketReservationList.SumQuantity = 0) THEN
                    TicketStatus := TicketStatus::REVOKED;
                IF (TicketReservationList.AccessDate <> 0D) THEN
                    TicketStatus := TicketStatus::ADMITTED;


                Name := '';
                Address1 := '';
                Address2 := '';
                ZipCode := '';
                City := '';
                Country := '';
                PhoneNumber := '';

                IF (TicketReservationList.MemberNumber <> '') THEN BEGIN
                    Member.SETFILTER("External Member No.", '=%1', TicketReservationList.MemberNumber);
                    IF (NOT Member.FINDFIRST()) THEN
                        Member.INIT();
                    Name := Member."Display Name";
                    Address1 := Member.Address;
                    ZipCode := Member."Post Code Code";
                    City := Member.City;
                    Country := Member."Country Code";
                    PhoneNumber := Member."Phone No.";
                END;

                IF (TicketReservationList.CustomerNumber <> '') THEN BEGIN
                    IF (NOT Customer.GET(TicketReservationList.CustomerNumber)) THEN
                        Customer.INIT();
                    Name := Customer.Name;
                    Address1 := Customer.Address;
                    Address2 := Customer."Address 2";
                    ZipCode := Customer."Post Code";
                    City := Customer.City;
                    Country := Customer."Country/Region Code";
                    PhoneNumber := Customer."Phone No.";
                END;

                IF (TicketReservationList.ExternalOrderNumber <> '') THEN BEGIN
                    SalesInvoiceHeader.SETFILTER("External Document No.", '=%1', TicketReservationList.ExternalOrderNumber);
                    IF (NOT SalesInvoiceHeader.FINDFIRST()) THEN
                        SalesInvoiceHeader.INIT();
                    Name := SalesInvoiceHeader."Sell-to Customer Name";
                    Address1 := SalesInvoiceHeader."Sell-to Address";
                    Address2 := SalesInvoiceHeader."Sell-to Address 2";
                    ZipCode := SalesInvoiceHeader."Sell-to Post Code";
                    City := SalesInvoiceHeader."Sell-to City";
                    Country := SalesInvoiceHeader."Sell-to Country/Region Code";
                    IF (Customer.GET(SalesInvoiceHeader."Sell-to Customer No.")) THEN
                        PhoneNumber := Customer."Phone No.";
                END;
            end;

            trigger OnPreDataItem()
            begin

                IF (Admission_Code <> '') THEN
                    TicketReservationList.SETFILTER(AdmissionCode, '=%1', Admission_Code);

                IF (Schedule_Code <> '') THEN
                    TicketReservationList.SETFILTER(ScheduleCode, '=%1', Schedule_Code);

                IF (Admitted_ = Admitted_::ADMITTED) THEN
                    TicketReservationList.SETFILTER(AccessDate, '>%1', 0D);

                IF (Admitted_ = Admitted_::NOT_ADMITTED) THEN
                    TicketReservationList.SETFILTER(AccessDate, '=%1', 0D);

                IF (AdmissionStart_DateHigh = 0D) THEN
                    AdmissionStart_DateHigh := DMY2DATE(31, 12, 9999);

                TicketReservationList.TOPNUMBEROFROWS(TopX_Rows);
                TicketReservationList.OPEN();
            end;
        }
    }

    requestpage
    {
        Caption = 'Ticket Reservation List';

        layout
        {
            area(content)
            {
                field(AdmissionCode; Admission_Code)
                {
                    Caption = 'Admission Code';
                    TableRelation = "NPR TM Admission" WHERE(Type = CONST(OCCASION));
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Code field.';
                }
                field(ScheduleCode; Schedule_Code)
                {
                    Caption = 'Schedule Code';
                    TableRelation = "NPR TM Admis. Schedule";
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Schedule Code field.';
                }
                field(AdmissionStartDateLow; AdmissionStart_DateLow)
                {
                    Caption = 'Admission Start Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Start Date field.';
                }
                field(AdmissionStartDateHigh; AdmissionStart_DateHigh)
                {
                    Caption = 'Admission Until Date';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admission Until Date field.';
                }
                field(Admitted; Admitted_)
                {
                    Caption = 'Admitted';
                    OptionCaption = 'Either,Admitted,Not Admitted';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Admitted field.';
                }
                field(TopXRows; TopX_Rows)
                {
                    Caption = 'Max Number of Rows';
                    MinValue = 1;
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Max Number of Rows field.';
                }
            }
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnInitReport()
    begin

        TopX_Rows := 1000;
        AdmissionStart_DateLow := TODAY;
        AdmissionStart_DateHigh := TODAY;
        Admitted_ := Admitted_::EITHER;
    end;

    var
        TicketReservationList: Query "NPR TM Attendees";
        Admission_Code: Code[20];
        Schedule_Code: Code[20];
        AdmissionStart_DateLow: Date;
        AdmissionStart_DateHigh: Date;
        Admitted_: Option EITHER,ADMITTED,NOT_ADMITTED;
        TopX_Rows: Integer;
        ToBeRedeemed: Boolean;
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        InitialEntry: Record "NPR TM Det. Ticket AccessEntry";
        TicketStatus: Option OPEN,REVOKED,ADMITTED;
        Name: Text;
        Address1: Text;
        Address2: Text;
        ZipCode: Text;
        City: Text;
        Country: Text;
        PhoneNumber: Text;

    procedure SetQueryFilter(var AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry")
    begin

        Admission_Code := AdmissionScheduleEntry."Admission Code";
        Schedule_Code := AdmissionScheduleEntry."Schedule Code";
        AdmissionStart_DateLow := AdmissionScheduleEntry."Admission Start Date";
        AdmissionStart_DateHigh := AdmissionScheduleEntry."Admission Start Date";
    end;
}

