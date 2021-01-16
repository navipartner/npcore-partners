report 6060126 "NPR TM Admission List"
{
    // TM1.13/BRI/20160419 CASE 239055 Initial Version of Attendance Report
    // #334163/JDH /20181109 CASE 334163 Added Caption to object
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019
    // TM1.42/TSA /20190610 CASE 357991 Removed PAGENO field for AL convert
    UsageCategory = None;
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Admission List.rdlc';

    Caption = 'TM Admission List';

    dataset
    {
        dataitem("TM Admission"; "NPR TM Admission")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Admission Code";
            column(COMPANYNAME; CompanyName)
            {
            }
            column(AdmissionCode; "TM Admission"."Admission Code")
            {
                IncludeCaption = true;
            }
            column(AdmissionType; "TM Admission".Type)
            {
                IncludeCaption = true;
            }
            column(AdmissionDescription; "TM Admission".Description)
            {
            }
            column(AdmissionLocationCode; "TM Admission"."Location Admission Code")
            {
            }
            dataitem("TM Admission Schedule Lines"; "NPR TM Admis. Schedule Lines")
            {
                DataItemLink = "Admission Code" = FIELD("Admission Code");
                DataItemTableView = SORTING("Admission Code", "Schedule Code") ORDER(Ascending);
                PrintOnlyIfDetail = true;
                RequestFilterFields = "Schedule Code";
                column(ScheduleCode; "TM Admission Schedule Lines"."Schedule Code")
                {
                }
                column(MaxCapacity; "TM Admission Schedule Lines"."Max Capacity Per Sch. Entry")
                {
                }
                dataitem("TM Admission Schedule Entry"; "NPR TM Admis. Schedule Entry")
                {
                    PrintOnlyIfDetail = true;
                    RequestFilterFields = "Admission Start Date", "Admission Start Time";
                    column(StartDateTime; StartDateTime)
                    {
                    }
                    column(EndDateTime; EndDateTime)
                    {
                    }
                    column(EventDuration; "TM Admission Schedule Entry"."Event Duration")
                    {
                    }
                    dataitem("TM Det. Ticket Access Entry"; "NPR TM Det. Ticket AccessEntry")
                    {
                        DataItemLink = "External Adm. Sch. Entry No." = FIELD("External Schedule Entry No.");
                        DataItemTableView = SORTING("External Adm. Sch. Entry No.", Type, Open, "Posting Date") ORDER(Ascending);
                        column(AccessType; "TM Det. Ticket Access Entry".Type)
                        {
                        }
                        column(AccessOpen; "TM Det. Ticket Access Entry".Open)
                        {
                        }
                        column(AccessQuantity; "TM Det. Ticket Access Entry".Quantity)
                        {
                        }
                        column(AccessName; AccessName)
                        {
                        }
                        column(AccessEmail; AccessEmail)
                        {
                        }
                        column(AccessPhone; AccessPhone)
                        {
                        }

                        trigger OnAfterGetRecord()
                        var
                            ShowRecord: Boolean;
                        begin
                            if not ((ShowOpenReservations and (Type = Type::RESERVATION) and Open) or
                              (ShowOpenAdmitted and (Type = Type::ADMITTED) and Open) or
                              (ShowDeparted and (Type = Type::DEPARTED) and (not Open))) then
                                CurrReport.Skip;
                            AccessName := TxtUnknown;
                            AccessEmail := TxtUnknown;
                            AccessPhone := TxtUnknown;
                            TMTicket.Get("Ticket No.");
                            if TMTicket."External Member Card No." <> '' then begin
                                MMMember.SetFilter("External Member No.", '=%1', TMTicket."External Member Card No.");
                                if MMMember.FindFirst() then begin
                                    //Member found
                                    if ShowEachMemberOnce then begin
                                        if TempMMMember.Get(MMMember."Entry No.") then
                                            CurrReport.Skip;
                                        TempMMMember."Entry No." := MMMember."Entry No.";
                                        TempMMMember.Insert;
                                    end;
                                    AccessName := StrSubstNo('%3, %1 %2', MMMember."First Name", MMMember."Middle Name", MMMember."Last Name");
                                    AccessEmail := MMMember."E-Mail Address";
                                    AccessPhone := MMMember."Phone No.";
                                end else
                                    if not ShowTicketsWithoutMembers then
                                        CurrReport.Skip;
                            end else
                                if not ShowTicketsWithoutMembers then
                                    CurrReport.Skip;
                        end;
                    }

                    trigger OnAfterGetRecord()
                    begin
                        StartDateTime := CreateDateTime("Admission Start Date", "Admission Start Time");
                        EndDateTime := CreateDateTime("Admission End Date", "Admission End Time");
                    end;
                }
            }
        }
    }

    requestpage
    {

        layout
        {
            area(content)
            {
                group(Types)
                {
                    field(ShowOpenReservations; ShowOpenReservations)
                    {
                        Caption = 'Show Open Reservations';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Open Reservations field';
                    }
                    field(ShowOpenAdmitted; ShowOpenAdmitted)
                    {
                        Caption = 'Show Open Admitted';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Open Admitted field';
                    }
                    field(ShowDeparted; ShowDeparted)
                    {
                        Caption = 'Show Departed';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Departed field';
                    }
                }
                group(Options)
                {
                    field(ShowEachMemberOnce; ShowEachMemberOnce)
                    {
                        Caption = 'Show Each Member Only Once';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Each Member Only Once field';
                    }
                    field(ShowTicketsWithoutMembers; ShowTicketsWithoutMembers)
                    {
                        Caption = 'Show Entries Without Members/Contact Information';
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Show Entries Without Members/Contact Information field';
                    }
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

    var
        TempMMMember: Record "NPR MM Member" temporary;
        TMTicket: Record "NPR TM Ticket";
        MMMember: Record "NPR MM Member";
        ShowOpenReservations: Boolean;
        ShowOpenAdmitted: Boolean;
        ShowDeparted: Boolean;
        ShowTicketsWithoutMembers: Boolean;
        ShowEachMemberOnce: Boolean;
        AccessName: Text;
        AccessEmail: Text;
        AccessPhone: Text;
        Admissions___ListCaptionLbl: Label 'Admissions - List';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        TxtUnknown: Label 'Unknown';
        StartDateTime: DateTime;
        EndDateTime: DateTime;
}

