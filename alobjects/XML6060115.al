xmlport 6060115 "TM Ticket PreConfirm"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.09/TSA/20160309  CASE 236563 Boolean XML response in changed to use XML style format
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions

    Caption = 'Ticket PreConfirm';
    Encoding = UTF8;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(tickets)
        {
            MaxOccurs = Once;
            tableelement(tmpticketreservationrequest;"TM Ticket Reservation Request")
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                XmlName = 'ticket_tokens';
                UseTemporary = true;
                fieldelement(ticket_token;tmpTicketReservationRequest."Session Token ID")
                {

                    trigger OnAfterAssignField()
                    begin
                        if (ReservationID = '') then
                          ReservationID := tmpTicketReservationRequest."Session Token ID";
                    end;
                }
            }
            textelement(ticket_tokens_result)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                tableelement(tmpticketreservationresponse;"TM Ticket Reservation Response")
                {
                    MinOccurs = Zero;
                    XmlName = 'tickets';
                    UseTemporary = true;
                    textelement(status)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            status := Format (tmpTicketReservationResponse.Status, 0, 9);
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'TM Ticket PreConfirm';

        layout
        {
        }

        actions
        {
        }
    }

    var
        ReservationID: Text[100];
        ExternalIdCount: Integer;
        QtySum: Integer;
        n: Integer;

    procedure GetToken(): Text[50]
    begin
        exit (ReservationID);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit (StrSubstNo ('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure SetReservationResult(DocumentID: Text[100];AuthoriativeResponse: Boolean)
    var
        TicketReservationResponse: Record "TM Ticket Reservation Response";
    begin
        tmpTicketReservationResponse.DeleteAll ();

        tmpTicketReservationResponse.Reset ();
        tmpTicketReservationResponse."Session Token ID" := DocumentID;
        tmpTicketReservationResponse.Status := false;

        TicketReservationResponse.SetFilter ("Session Token ID", '=%1', DocumentID);
        if (TicketReservationResponse.FindFirst ()) then
          tmpTicketReservationResponse.Status := TicketReservationResponse.Status;

        tmpTicketReservationResponse.Insert ();
    end;
}

