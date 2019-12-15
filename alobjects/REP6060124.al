report 6060124 "TM Ticket Batch Response"
{
    // TM1.22/NPKNAV/20170612  CASE 278142 Transport T0007 - 12 June 2017
    // TM1.26/TSA /20171103 CASE 285601 Added Ticket URL
    DefaultLayout = RDLC;
    RDLCLayout = './TM Ticket Batch Response.rdlc';

    Caption = 'Ticket Batch Response';

    dataset
    {
        dataitem(ReservationRequest;"TM Ticket Reservation Request")
        {
            column(ExternalOrderNo;ReservationRequest."External Order No.")
            {
            }
            column(Token;ReservationRequest."Session Token ID")
            {
            }
            column(ItemNo;ReservationRequest."External Item Code")
            {
            }
            column(Quantity;ReservationRequest.Quantity)
            {
            }
            column(EntryNo;ReservationRequest."Entry No.")
            {
            }
            dataitem(Item;Item)
            {
                DataItemLink = "No."=FIELD("External Item Code");
                column(ItemDescription;Item.Description)
                {
                }
            }
            dataitem(TicketBom;"TM Ticket Admission BOM")
            {
                DataItemLink = "Item No."=FIELD("External Item Code");
                column(AdmissionCode;TicketBom."Admission Code")
                {
                }
                column(AdmissionDescription;TicketBom."Admission Description")
                {
                }
            }
            dataitem(Ticket;"TM Ticket")
            {
                DataItemLink = "Ticket Reservation Entry No."=FIELD("Entry No.");
                column(TicketNo;Ticket."External Ticket No.")
                {
                }
                column(ValidFromDate;Ticket."Valid From Date")
                {
                }
                column(ValidUntilDate;Ticket."Valid To Date")
                {
                }
                column(TicketURL;TicketURL)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    if (ReservationRequest."DIY Print Order Requested") then
                      TicketURL := StrSubstNo ('%1%2', TicketSetup."Print Server Ticket URL",Ticket."External Ticket No.");
                end;
            }
        }
    }

    requestpage
    {

        layout
        {
        }

        actions
        {
        }
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
        if (TicketSetup.Get ()) then ;
    end;

    var
        TicketSetup: Record "TM Ticket Setup";
        TicketURL: Text;
}

