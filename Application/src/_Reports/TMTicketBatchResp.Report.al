﻿report 6060124 "NPR TM Ticket Batch Resp."
{
#IF NOT BC17
    Extensible = False; 
#ENDIF
    DefaultLayout = RDLC;
    RDLCLayout = './src/_Reports/layouts/TM Ticket Batch Response.rdlc';
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = NPRRetail;
    Caption = 'Ticket Batch Response';
    DataAccessIntent = ReadOnly;

    dataset
    {
        dataitem(ReservationRequest; "NPR TM Ticket Reservation Req.")
        {
            column(ExternalOrderNo; ReservationRequest."External Order No.")
            {
            }
            column(Token; OrderUrl)
            {
            }
            column(ItemNo; ReservationRequest."External Item Code")
            {
            }
            column(Quantity; ReservationRequest.Quantity)
            {
            }
            column(EntryNo; ReservationRequest."Entry No.")
            {
            }
            dataitem(Item; Item)
            {
                DataItemLink = "No." = FIELD("Item No.");
                column(ItemDescription; Item.Description)
                {
                }
            }
            dataitem(TicketBom; "NPR TM Ticket Admission BOM")
            {
                DataItemLink = "Item No." = FIELD("Item No.");
                column(AdmissionCode; TicketBom."Admission Code")
                {
                }
                column(AdmissionDescription; TicketBom."Admission Description")
                {
                }
            }
            dataitem(Ticket; "NPR TM Ticket")
            {
                DataItemLink = "Ticket Reservation Entry No." = FIELD("Entry No.");
                column(TicketNo; Ticket."External Ticket No.")
                {
                }
                column(ValidFromDate; Ticket."Valid From Date")
                {
                }
                column(ValidUntilDate; Ticket."Valid To Date")
                {
                }
                column(TicketURL; TicketURL)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (ReservationRequest."DIY Print Order Requested") then
                        TicketURL := StrSubstNo(Pct1Lbl, TicketSetup."Print Server Ticket URL", Ticket."External Ticket No.");
                end;
            }
            trigger OnAfterGetRecord()
            begin
                OrderUrl := ReservationRequest."Session Token ID";
                if (ReservationRequest."DIY Print Order Requested") then
                    OrderUrl := StrSubstNo(Pct1Lbl, TicketSetup."Print Server Order URL", ReservationRequest."Session Token ID");
            end;
        }
    }
    requestpage
    {
        SaveValues = true;
    }
    labels
    {
        YourRef = 'Your Reference:';
        OurRef = 'Our Reference:';
        Admission = 'Admission';
        AdmDesc = 'Description';
        TicketNumber = 'Ticket No';
        ValidFrom = 'Valid From';
        ValidUntil = 'Valid Until';
        ItemNumber = 'Item No.';
        ItemDesc = 'Item Description';
        Qty = 'Quantity';

    }

    trigger OnPreReport()
    begin
        if (TicketSetup.Get()) then;
    end;

    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketURL: Text;
        OrderUrl: Text;
        Pct1Lbl: Label '%1%2', locked = true;
}

