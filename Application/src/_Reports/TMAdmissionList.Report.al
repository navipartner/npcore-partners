report 6060126 "NPR TM Admission List"
{
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Admission List.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'TM Admission List';
    DataAccessIntent = ReadOnly;

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
                        begin
                            if not ((ShowOpenReservations and (Type = Type::RESERVATION) and Open) or
                              (ShowOpenAdmitted and (Type = Type::ADMITTED) and Open) or
                              (ShowDeparted and (Type = Type::DEPARTED) and (not Open))) then
                                CurrReport.Skip();
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
                                            CurrReport.Skip();
                                        TempMMMember."Entry No." := MMMember."Entry No.";
                                        TempMMMember.Insert();
                                    end;
                                    AccessName := StrSubstNo(Pct1Lbl, MMMember."First Name", MMMember."Middle Name", MMMember."Last Name");
                                    AccessEmail := MMMember."E-Mail Address";
                                    AccessPhone := MMMember."Phone No.";
                                end else
                                    if not ShowTicketsWithoutMembers then
                                        CurrReport.Skip();
                            end else
                                if not ShowTicketsWithoutMembers then
                                    CurrReport.Skip();
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
                    field("Show Open Reservations"; ShowOpenReservations)
                    {
                        Caption = 'Show Open Reservations';

                        ToolTip = 'Specifies the value of the Show Open Reservations field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Open Admitted"; ShowOpenAdmitted)
                    {
                        Caption = 'Show Open Admitted';

                        ToolTip = 'Specifies the value of the Show Open Admitted field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Departed"; ShowDeparted)
                    {
                        Caption = 'Show Departed';

                        ToolTip = 'Specifies the value of the Show Departed field';
                        ApplicationArea = NPRRetail;
                    }
                }
                group(Options)
                {
                    field("Show Each Member Once"; ShowEachMemberOnce)
                    {
                        Caption = 'Show Each Member Only Once';

                        ToolTip = 'Specifies the value of the Show Each Member Only Once field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Show Tickets Without Members"; ShowTicketsWithoutMembers)
                    {
                        Caption = 'Show Entries Without Members/Contact Information';

                        ToolTip = 'Specifies the value of the Show Entries Without Members/Contact Information field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
        }
    }

    var
        MMMember: Record "NPR MM Member";
        TempMMMember: Record "NPR MM Member" temporary;
        TMTicket: Record "NPR TM Ticket";
        ShowDeparted: Boolean;
        ShowEachMemberOnce: Boolean;
        ShowOpenAdmitted: Boolean;
        ShowOpenReservations: Boolean;
        ShowTicketsWithoutMembers: Boolean;
        EndDateTime: DateTime;
        StartDateTime: DateTime;
        TxtUnknown: Label 'Unknown';
        AccessEmail: Text;
        AccessName: Text;
        AccessPhone: Text;
        Pct1Lbl: Label '%3, %1 %2', locked = true;
}

