xmlport 6060124 "TM Send eTicket"
{
    // 
    // TM1.38/TSA /20181017 CASE 332109 Sending an eTicket
    // TM1.39/NPKNAV/20190125  CASE 310057 Transport TM1.39 - 25 January 2019

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
                fieldelement(send_notification_to;tmpTicketReservationRequest."Notification Address")
                {
                    MinOccurs = Zero;
                }
            }
            textelement(ticket_results)
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
                            status := Format (tmpTicketReservationResponse.Confirmed, 0, 9);
                        end;
                    }
                    fieldelement(order_uid;tmpTicketReservationResponse."Session Token ID")
                    {
                    }
                    fieldelement(message_text;tmpTicketReservationResponse."Response Message")
                    {
                    }
                    textelement(result)
                    {
                        tableelement(tmpticketnotificationresponse;"TM Ticket Notification Entry")
                        {
                            MinOccurs = Zero;
                            XmlName = 'eticket';
                            UseTemporary = true;
                            fieldelement(ticketnumber;TmpTicketNotificationResponse."External Ticket No.")
                            {
                            }
                            fieldelement(eventdescription;TmpTicketNotificationResponse."Adm. Event Description")
                            {
                            }
                            fieldelement(locationdescription;TmpTicketNotificationResponse."Adm. Location Description")
                            {
                            }
                            fieldelement(ticketurl;TmpTicketNotificationResponse."eTicket Pass Landing URL")
                            {
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        TicketReservationRequest: Record "TM Ticket Reservation Request";
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
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
        TicketRequestManager: Codeunit "TM Ticket Request Manager";
        ReasonText: Text;
        TmpTicketNotificationEntry: Record "TM Ticket Notification Entry" temporary;
        TicketNotificationEntry: Record "TM Ticket Notification Entry";
    begin

        if (not tmpTicketReservationRequest.FindFirst ()) then begin
          CreateErrorResponse ('Invalid parameters.');
          exit;
        end;

        TicketReservationRequest.SetCurrentKey ("Session Token ID");
        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', ReservationID);
        TicketReservationRequest.SetFilter ("Request Status", '=%1', TicketReservationRequest."Request Status"::CONFIRMED);
        if (not TicketReservationRequest.FindFirst ()) then begin
          CreateErrorResponse ('Invalid token or token not confirmed.');
          exit;
        end;

        Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        if (not Ticket.FindSet ()) then begin
          CreateErrorResponse ('Invalid token.');
          exit;
        end;

        if (tmpTicketReservationRequest."Notification Address" <> '') then begin
          TicketReservationRequest."Notification Method" := TicketReservationRequest."Notification Method"::SMS;
          TicketReservationRequest."Notification Address" := tmpTicketReservationRequest."Notification Address";
          TicketReservationRequest.Modify ();
        end;

        repeat
          //-TM1.39 [310057]
          // IF (TicketRequestManager.IsETicket (Ticket."No.")) THEN
          // IF NOT (TicketRequestManager.CreateAndSendETicket (Ticket."No.", ReasonText)) THEN BEGIN
          //   CreateErrorResponse (COPYSTR (ReasonText, 1, MAXSTRLEN (tmpTicketReservationResponse."Response Message")));
          //   EXIT;
          // END;
          // Ticket.GET (TicketNo);

          if (not TicketRequestManager.IsETicket (Ticket."No.")) then begin
            CreateErrorResponse ('Not eTicket.');
            exit (false);
          end;

          if (not TicketRequestManager.CreateETicketNotificationEntry (Ticket, TmpTicketNotificationEntry, (tmpTicketReservationRequest."Notification Address" = '') , ReasonText)) then begin
            CreateErrorResponse (ReasonText);
            exit (false);
          end;


          TmpTicketNotificationEntry.Reset ();
          TmpTicketNotificationEntry.FindSet ();
          repeat

            if (TmpTicketNotificationEntry."Notification Send Status" = TmpTicketNotificationEntry."Notification Send Status"::PENDING) then begin
              if (not TicketRequestManager.SendETicketNotification (TmpTicketNotificationEntry."Entry No.", (tmpTicketReservationRequest."Notification Address" = ''), ReasonText)) then begin
                CreateErrorResponse (ReasonText);
                exit (false);
              end;
              TmpTicketNotificationEntry."Notification Send Status" := TmpTicketNotificationEntry."Notification Send Status"::SENT;
              TmpTicketNotificationEntry.Modify ();
            end;

          until (TmpTicketNotificationEntry.Next () = 0);
          //+TM1.39 [310057]

        until (Ticket.Next () = 0);

        tmpTicketReservationResponse.Confirmed := true;
        tmpTicketReservationResponse."Response Message" := 'OK';
        tmpTicketReservationResponse.Insert ();

        //-TM1.39 [310057]
        TmpTicketNotificationEntry.Reset ();
        TmpTicketNotificationEntry.FindSet ();
        repeat
          TicketNotificationEntry.Get (TmpTicketNotificationEntry."Entry No.");
          TmpTicketNotificationResponse.TransferFields (TicketNotificationEntry, true);
          TmpTicketNotificationResponse.Insert ();
        until (TmpTicketNotificationEntry.Next () = 0);
        //+TM1.39 [310057]
    end;

    local procedure CreateErrorResponse(ResponseText: Text[250])
    begin

        if (TmpTicketNotificationResponse.IsTemporary ()) then
          TmpTicketNotificationResponse.DeleteAll();

        tmpTicketReservationResponse.Confirmed := false;
        tmpTicketReservationResponse."Response Message" := ResponseText;
        tmpTicketReservationResponse.Insert ();
    end;
}

