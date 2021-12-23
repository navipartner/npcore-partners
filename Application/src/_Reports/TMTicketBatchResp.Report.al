report 6060124 "NPR TM Ticket Batch Resp."
{
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
            column(Token; ReservationRequest."Session Token ID")
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
                DataItemLink = "No." = FIELD("External Item Code");
                column(ItemDescription; Item.Description)
                {
                }
            }
            dataitem(TicketBom; "NPR TM Ticket Admission BOM")
            {
                DataItemLink = "Item No." = FIELD("External Item Code");
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
    }

    trigger OnPreReport()
    begin
        if (TicketSetup.Get()) then;
    end;

    var
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketURL: Text;
        Pct1Lbl: Label '%1%2', locked = true;
}

