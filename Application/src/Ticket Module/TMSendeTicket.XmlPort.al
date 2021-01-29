xmlport 6060124 "NPR TM Send eTicket"
{
    Caption = 'TM Send eTicket';
    Encoding = UTF8;
    FormatEvaluate = Xml;
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
                fieldelement(send_notification_to; tmpTicketReservationRequest."Notification Address")
                {
                    MinOccurs = Zero;
                }
            }
            textelement(ticket_results)
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
                            status := Format(tmpTicketReservationResponse.Confirmed, 0, 9);
                        end;
                    }
                    fieldelement(order_uid; tmpTicketReservationResponse."Session Token ID")
                    {
                    }
                    fieldelement(message_text; tmpTicketReservationResponse."Response Message")
                    {
                    }
                    textelement(result)
                    {
                        tableelement(tmpticketnotificationresponse; "NPR TM Ticket Notif. Entry")
                        {
                            MinOccurs = Zero;
                            XmlName = 'eticket';
                            UseTemporary = true;
                            fieldelement(ticketnumber; TmpTicketNotificationResponse."External Ticket No.")
                            {
                            }
                            fieldelement(eventdescription; TmpTicketNotificationResponse."Adm. Event Description")
                            {
                            }
                            fieldelement(locationdescription; TmpTicketNotificationResponse."Adm. Location Description")
                            {
                            }
                            fieldelement(ticketurl; TmpTicketNotificationResponse."eTicket Pass Landing URL")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    begin
                    end;
                }
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

    var
        ReservationID: Text[100];

    procedure CreateResponse(): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ReasonText: Text;
        TmpTicketNotificationEntry: Record "NPR TM Ticket Notif. Entry" temporary;
        TicketNotificationEntry: Record "NPR TM Ticket Notif. Entry";
    begin

        if (not tmpTicketReservationRequest.FindFirst()) then begin
            CreateErrorResponse('Invalid parameters.');
            exit;
        end;

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', ReservationID);
        TicketReservationRequest.SetFilter("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        if (not TicketReservationRequest.FindFirst()) then begin
            CreateErrorResponse('Invalid token or token not confirmed.');
            exit;
        end;

        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        if (not Ticket.FindSet()) then begin
            CreateErrorResponse('Invalid token.');
            exit;
        end;

        if (tmpTicketReservationRequest."Notification Address" <> '') then begin
            TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;
            TicketReservationRequest."Notification Address" := tmpTicketReservationRequest."Notification Address";
            TicketReservationRequest.Modify();
        end;

        repeat

            if (not TicketRequestManager.IsETicket(Ticket."No.")) then begin
                CreateErrorResponse('Not eTicket.');
                exit(false);
            end;

            if (not TicketRequestManager.CreateETicketNotificationEntry(Ticket, TmpTicketNotificationEntry, (tmpTicketReservationRequest."Notification Address" = ''), ReasonText)) then begin
                CreateErrorResponse(ReasonText);
                exit(false);
            end;


            TmpTicketNotificationEntry.Reset();
            TmpTicketNotificationEntry.FindSet();
            repeat

                if (tmpTicketReservationRequest."Notification Address" <> '') then begin
                    TicketNotificationEntry.Get(TmpTicketNotificationEntry."Entry No.");
                    TicketNotificationEntry."Notification Address" := tmpTicketReservationRequest."Notification Address";
                    TicketNotificationEntry."Notification Trigger" := TicketNotificationEntry."Notification Trigger"::ETICKET_CREATE;
                    TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::SMS;
                    if (StrPos(tmpTicketReservationRequest."Notification Address", '@') > 0) then
                        TicketNotificationEntry."Notification Method" := TicketNotificationEntry."Notification Method"::EMAIL;
                    TicketNotificationEntry.Modify();
                end;

                if (TmpTicketNotificationEntry."Notification Send Status" = TmpTicketNotificationEntry."Notification Send Status"::PENDING) then begin
                    if (not TicketRequestManager.SendETicketNotification(TmpTicketNotificationEntry."Entry No.", (tmpTicketReservationRequest."Notification Address" = ''), ReasonText)) then begin
                        CreateErrorResponse(ReasonText);
                        exit(false);
                    end;
                    TmpTicketNotificationEntry."Notification Send Status" := TmpTicketNotificationEntry."Notification Send Status"::SENT;
                    TmpTicketNotificationEntry.Modify();
                end;

            until (TmpTicketNotificationEntry.Next() = 0);

        until (Ticket.Next() = 0);

        tmpTicketReservationResponse.Confirmed := true;
        tmpTicketReservationResponse."Response Message" := 'OK';
        tmpTicketReservationResponse.Insert();

        TmpTicketNotificationEntry.Reset();
        TmpTicketNotificationEntry.FindSet();
        repeat
            TicketNotificationEntry.Get(TmpTicketNotificationEntry."Entry No.");
            TmpTicketNotificationResponse.TransferFields(TicketNotificationEntry, true);
            TmpTicketNotificationResponse.Insert();
        until (TmpTicketNotificationEntry.Next() = 0);

    end;

    procedure GetResponse(var ResponseMessage: Text[250]): Boolean
    begin
        tmpTicketReservationResponse.FindFirst();
        ResponseMessage := tmpTicketReservationResponse."Response Message";
        exit(tmpTicketReservationResponse.Confirmed);
    end;

    local procedure CreateErrorResponse(ResponseText: Text[250])
    begin

        if (TmpTicketNotificationResponse.IsTemporary()) then
            TmpTicketNotificationResponse.DeleteAll();

        tmpTicketReservationResponse.Confirmed := false;
        tmpTicketReservationResponse."Response Message" := ResponseText;
        tmpTicketReservationResponse.Insert();
    end;
}

