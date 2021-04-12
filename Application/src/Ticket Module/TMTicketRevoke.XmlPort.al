xmlport 6060119 "NPR TM Ticket Revoke"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.09/TSA/20160309  CASE 236563 Boolean XML response in changed to use XML style format
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.15/TSA/20160603  CASE 240864 Transport TM1.15 - 1 June 2016

    Caption = 'Ticket Revoke';
    Encoding = UTF8;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(tickets)
        {
            MaxOccurs = Once;
            tableelement(tmpticketreservationrequest; "NPR TM Ticket Reservation Req.")
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                XmlName = 'revoke_ticket';
                UseTemporary = true;
                fieldelement(ticket_number; tmpTicketReservationRequest."Session Token ID")
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
                tableelement(tmpticketreservationresponse; "NPR TM Ticket Reserv. Resp.")
                {
                    MinOccurs = Zero;
                    XmlName = 'tickets';
                    UseTemporary = true;
                    textelement(status)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            status := Format(tmpTicketReservationResponse.Canceled, 0, 9);
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'TM Ticket Revoke';

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

    procedure GetToken(): Text[100]
    begin
        exit(ReservationID);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit(StrSubstNo('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure SetReservationResult(DocumentID: Text[100]; Success: Boolean)
    begin
        tmpTicketReservationResponse.DeleteAll();

        tmpTicketReservationResponse.Reset();
        tmpTicketReservationResponse."Session Token ID" := DocumentID;
        tmpTicketReservationResponse.Canceled := Success;
        tmpTicketReservationResponse.Insert();
    end;
}

