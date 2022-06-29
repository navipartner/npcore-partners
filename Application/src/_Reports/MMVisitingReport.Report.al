﻿report 6060133 "NPR MM Visiting Report"
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/MM Visiting Report.rdlc';
    Caption = 'MM Visiting Report';
    UsageCategory = None;
    DataAccessIntent = ReadOnly;
    ObsoleteState = Pending;
    ObsoleteReason = 'Not used';

    dataset
    {
        dataitem("MM Membership"; "NPR MM Membership")
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "Membership Code";
            column(MembershipEntryNo_MMMembership; "MM Membership"."Entry No.")
            {
            }
            column(MembershipCode_MMMembership; "MM Membership"."Membership Code")
            {
            }
            column(ReportFilters; GetFilters)
            {
            }
            column(TheCompanyName; CompanyName)
            {
            }
            column(MembershipCode_Lbl; MembershipCode_Lbl)
            {
            }
            column(DisplayName_Lbl; DisplayName_Lbl)
            {
            }
            column(TicketCode_Lbl; TicketCode_Lbl)
            {
            }
            column(AccessDate_Lbl; AccessDate_Lbl)
            {
            }
            column(Guests_Lbl; Guests_Lbl)
            {
            }
            column(AccessTime_Lbl; AccessTime_Lbl)
            {
            }
            dataitem("MM Membership Role"; "NPR MM Membership Role")
            {
                DataItemLink = "Membership Entry No." = FIELD("Entry No.");
                PrintOnlyIfDetail = true;
                column(MembershipRoleEntryNo_MMMembershipRole; "MM Membership Role"."Membership Entry No.")
                {
                }
                column(MemberRole_MMMembershipRole; "MM Membership Role"."Member Role")
                {
                }
                dataitem("MM Member"; "NPR MM Member")
                {
                    DataItemLink = "Entry No." = FIELD("Member Entry No.");
                    PrintOnlyIfDetail = true;
                    column(EntryNo_MMMember; "MM Member"."Entry No.")
                    {
                    }
                    column(DisplayName_MMMember; "MM Member"."Display Name")
                    {
                    }
                    dataitem("TM Ticket"; "NPR TM Ticket")
                    {
                        DataItemLink = "External Member Card No." = FIELD("External Member No.");
                        PrintOnlyIfDetail = true;
                        column(No_TMTicket; "TM Ticket"."No.")
                        {
                        }
                        column(TicketTypeCode_TMTicket; "TM Ticket"."Ticket Type Code")
                        {
                        }
                        column(ValidFromDate_TMTicket; Format("TM Ticket"."Valid From Date", 0, 1))
                        {
                        }
                        column(ValidFromTime_TMTicket; Format("TM Ticket"."Valid From Time", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))
                        {
                        }
                        column(ValidToDate_TMTicket; Format("TM Ticket"."Valid To Date", 0, 1))
                        {
                        }
                        column(ValidToTime_TMTicket; Format("TM Ticket"."Valid To Time", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))
                        {
                        }
                        column(Quantity; Qty)
                        {
                        }
                        dataitem("TM Ticket Access Entry"; "NPR TM Ticket Access Entry")
                        {
                            DataItemLink = "Ticket No." = FIELD("No.");
                            PrintOnlyIfDetail = false;
                            column(EntryNo_TMTicketAccessEntry; Format("TM Ticket Access Entry"."Entry No."))
                            {
                            }
                            column(AccessDate_TMTicketAccessEntry; Format("TM Ticket Access Entry"."Access Date", 0, 1))
                            {
                            }
                            column(AccessTime_TMTicketAccessEntry; Format("TM Ticket Access Entry"."Access Time", 0, '<Hours24,2><Filler Character,0>:<Minutes,2>:<Seconds,2>'))
                            {
                            }
                            column(NumberOfVisits; NumberOfVisits)
                            {
                            }

                            trigger OnAfterGetRecord()
                            begin
                                if not ("Access Date" <> 0D) then
                                    CurrReport.Skip();

                                if not ("Entry No." <> 0) then
                                    CurrReport.Skip();

                                NumberOfVisits += 1;
                            end;

                            trigger OnPreDataItem()
                            begin
                                Clear(NumberOfVisits);
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            AdmSet.SetRange("Membership  Code", "MM Membership"."Membership Code");
                            if AdmSet.FindFirst() then
                                if AdmSet."Ticket No." = "TM Ticket"."Item No." then
                                    Qty := 1
                                else
                                    Qty := 0;
                        end;

                        trigger OnPreDataItem()
                        begin
                            Clear(Qty);
                            Clear(Temp);
                        end;
                    }
                }
            }
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    labels
    {
        ReportName = 'Member Visting Report';
        CustomerName = 'Name';
        CustomerAddress = 'Address';
    }

    var
        AdmSet: Record "NPR MM Members. Admis. Setup";
        Temp: Code[100];
        NumberOfVisits: Integer;
        Qty: Integer;
        AccessDate_Lbl: Label 'Access Date';
        AccessTime_Lbl: Label 'Access Time';
        DisplayName_Lbl: Label 'Display Name';
        Guests_Lbl: Label 'Guests';
        MembershipCode_Lbl: Label 'Membership Code';
        TicketCode_Lbl: Label 'Ticket Type Code';
}

