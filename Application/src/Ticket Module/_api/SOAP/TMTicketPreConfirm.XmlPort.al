xmlport 6060115 "NPR TM Ticket PreConfirm"
{
    Caption = 'Ticket PreConfirm';
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
                XmlName = 'ticket_tokens';
                UseTemporary = true;
                fieldelement(ticket_token; tmpTicketReservationRequest."Session Token ID")
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
                            status := Format(tmpTicketReservationResponse.Status, 0, 9);
                        end;
                    }
                    fieldelement(new_expiry_time; tmpTicketReservationResponse."Exires (Seconds)")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        textattribute(atutc)
                        {
                            XmlName = 'utc';

                            trigger OnBeforePassVariable()
                            begin

                                //-TM1.48 [415894]
                                IF (tmpTicketReservationResponse.Status) THEN
                                    AtUTC := Format(CurrentDateTime() + (tmpTicketReservationResponse."Exires (Seconds)" - 1) * 1000, 0, 9);
                                //+TM1.48 [415894]
                            end;
                        }
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

    internal procedure GetToken(): Text[100]
    begin
        exit(ReservationID);
    end;

    internal procedure GetSummary(): Text[30]
    var
        SummaryLbl: Label '%1-%2', Locked = true;
    begin
        exit(StrSubstNo(SummaryLbl, ExternalIdCount, QtySum));
    end;

    internal procedure SetReservationResult(DocumentID: Text[100]; AuthoriativeResponse: Boolean)
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin
        tmpTicketReservationResponse.DeleteAll();

        tmpTicketReservationResponse.Reset();
        tmpTicketReservationResponse."Session Token ID" := DocumentID;
        tmpTicketReservationResponse.Status := false;

        TicketReservationResponse.SetCurrentKey("Session Token ID");
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentID);
        if (TicketReservationResponse.FindFirst()) then
            tmpTicketReservationResponse.TransferFields(TicketReservationResponse, true);

        tmpTicketReservationResponse.Insert();
    end;
}

