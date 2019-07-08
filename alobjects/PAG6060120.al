page 6060120 "TM Ticket Admissions"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.08/TSA/20160262  CASE 232262 Dependant admission objects
    // TM1.09/TSA/20160229  CASE 235795 Default Schedule option on Admission Code
    // TM1.11/TSA/20160404  CASE 232250 Added new fields 47 and 48
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.13/TSA/20160502  CASE 239055 Transport TM1.13 - 29 April 2016
    // TM1.16/TSA/20160714  CASE 245004 Added support for participant notifications
    // TM1.18/NPKNAV/20170125  CASE 258974 Transport TM1.18 - 25 January 2017
    // TM1.21/ANEN /20170406 CASE 271150 Added field "POS Schedule Selection To Date"
    // TM1.28/TSA /20180201 CASE 303925 Added field for Base Calendar
    // TM1.38/TSA /20181012 CASE 332109 Adding eTicket

    Caption = 'Ticket Admissions';
    PageType = List;
    SourceTable = "TM Admission";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code";"Admission Code")
                {
                }
                field(Type;Type)
                {
                }
                field(Description;Description)
                {
                }
                field("Location Admission Code";"Location Admission Code")
                {
                    Visible = false;
                }
                field("Capacity Limits By";"Capacity Limits By")
                {
                }
                field("Default Schedule";"Default Schedule")
                {
                }
                field("Prebook Is Required";"Prebook Is Required")
                {
                }
                field("Max Capacity Per Sch. Entry";"Max Capacity Per Sch. Entry")
                {
                }
                field("Reserved For Web";"Reserved For Web")
                {
                    Visible = false;
                }
                field("Reserved For Members";"Reserved For Members")
                {
                    Visible = false;
                }
                field("Unbookable Before Start (Secs)";"Unbookable Before Start (Secs)")
                {
                    Visible = false;
                }
                field("Bookable Passed Start (Secs)";"Bookable Passed Start (Secs)")
                {
                    Visible = false;
                }
                field("Capacity Control";"Capacity Control")
                {
                }
                field("Prebook From";"Prebook From")
                {
                }
                field("Ticketholder Notification Type";"Ticketholder Notification Type")
                {
                }
                field("Dependent Admission Code";"Dependent Admission Code")
                {
                    Visible = false;
                }
                field("Dependency Type";"Dependency Type")
                {
                    Visible = false;
                }
                field("Dependency Timeframe";"Dependency Timeframe")
                {
                    Visible = false;
                }
                field("POS Schedule Selection Date F.";"POS Schedule Selection Date F.")
                {
                }
                field("Admission Base Calendar Code";"Admission Base Calendar Code")
                {
                }
                field("AdmissionCustomized Calendar";CalendarMgmt.CustomizedCalendarExistText(CustomizedCalendar."Source Type"::Location,"Admission Code",'',"Admission Base Calendar Code"))
                {
                    Caption = 'Admission Customized Calendar';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalEntry."Source Type"::Location,"Admission Code",'',"Admission Base Calendar Code");
                    end;
                }
                field("Ticket Base Calendar Code";"Ticket Base Calendar Code")
                {
                }
                field("TicketCustomized Calendar";CalendarMgmt.CustomizedCalendarExistText(CustomizedCalendar."Source Type"::Service,"Admission Code",'',"Ticket Base Calendar Code"))
                {
                    Caption = 'Ticket Customized Calendar';
                    Editable = false;

                    trigger OnDrillDown()
                    begin
                        CurrPage.SaveRecord;
                        TestField("Admission Base Calendar Code");
                        CalendarMgmt.ShowCustomizedCalendar(CustomizedCalEntry."Source Type"::Service,"Admission Code",'',"Ticket Base Calendar Code");
                    end;
                }
                field("eTicket Type Code";"eTicket Type Code")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Ticket BOM")
            {
                Caption = 'Ticket Admission BOM';
                Image = BOM;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "TM Ticket BOM";
                RunPageLink = "Admission Code"=FIELD("Admission Code");
            }
            action(Schedules)
            {
                Caption = 'Schedules';
                Image = Workdays;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                RunObject = Page "TM Ticket Schedules";
            }
            action("Admission Schedules")
            {
                Caption = 'Admission Schedules';
                Image = CalendarWorkcenter;
                Promoted = true;
                PromotedCategory = Process;
                RunObject = Page "TM Admission Schedule Lines";
                RunPageLink = "Admission Code"=FIELD("Admission Code");
            }
            action("Event List")
            {
                Caption = 'Event List';
                Image = CustomerList;
                RunObject = Report "TM Admission List";
            }
        }
    }

    var
        CustomizedCalEntry: Record "Customized Calendar Entry";
        CustomizedCalendar: Record "Customized Calendar Change";
        CalendarMgmt: Codeunit "Calendar Management";
}

