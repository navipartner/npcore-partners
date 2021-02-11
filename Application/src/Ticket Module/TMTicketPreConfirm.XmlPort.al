xmlport 6060115 "NPR TM Ticket PreConfirm"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.09/TSA/20160309  CASE 236563 Boolean XML response in changed to use XML style format
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.48/TSA /20200722 CASE 415894 Added expiry utc time to response

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
        n: Integer;

    procedure GetToken(): Text[100]
    begin
        exit(ReservationID);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit(StrSubstNo('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure SetReservationResult(DocumentID: Text[100]; AuthoriativeResponse: Boolean)
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin
        tmpTicketReservationResponse.DeleteAll();

        tmpTicketReservationResponse.Reset();
        tmpTicketReservationResponse."Session Token ID" := DocumentID;
        tmpTicketReservationResponse.Status := false;

        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentID);
        if (TicketReservationResponse.FindFirst()) then
            //-TM1.48 [415894]
            //tmpTicketReservationResponse.Status := TicketReservationResponse.Status;
            tmpTicketReservationResponse.TransferFields(TicketReservationResponse, true);
        //+TM1.48 [415894]

        tmpTicketReservationResponse.Insert();
    end;
}

