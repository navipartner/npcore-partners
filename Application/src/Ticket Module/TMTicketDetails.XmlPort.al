xmlport 6060120 "NPR TM Ticket Details"
{
    Caption = 'TM Ticket Details';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(ticketdetails)
        {
            MaxOccurs = Once;
            tableelement(tmpticketreservationrequest; "NPR TM Ticket Reservation Req.")
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                XmlName = 'ticket_request';
                UseTemporary = true;
                textelement(ticket)
                {
                    MaxOccurs = Once;
                    textattribute(filter_type)
                    {
                    }
                    textattribute(full_history)
                    {
                    }
                    textelement(filter_value)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        XmlName = 'filter';
                    }
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
                    tableelement(tmpticket; "NPR TM Ticket")
                    {
                        LinkTable = tmpTicketReservationResponse;
                        MinOccurs = Zero;
                        XmlName = 'ticket';
                        UseTemporary = true;
                        fieldelement(ticket_uid; TmpTicket."External Ticket No.")
                        {
                        }
                        fieldelement(barcode_no; TmpTicket."Ticket No. for Printing")
                        {

                            trigger OnBeforePassField()
                            begin
                                if (TmpTicket."Ticket No. for Printing" = '') then
                                    TmpTicket."Ticket No. for Printing" := TmpTicket."External Ticket No.";
                            end;
                        }
                        textelement(token)
                        {

                            trigger OnBeforePassVariable()
                            var
                                TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                            begin

                                //-TM1.43 [367471]
                                token := '';
                                if (TicketReservationRequest.Get(TmpTicket."Ticket Reservation Entry No.")) then
                                    token := TicketReservationRequest."Session Token ID";
                                //+TM1.43 [367471]
                            end;
                        }
                        textelement(valid_from)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                valid_from := Format(TmpTicket."Valid From Date", 0, 9);
                            end;
                        }
                        textelement(valid_until)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                valid_until := Format(TmpTicket."Valid To Date", 0, 9);
                            end;
                        }
                        textelement(pin_code)
                        {
                            trigger OnBeforePassVariable()
                            var
                                TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                            begin
                                pin_code := '';
                                if (TicketReservationRequest.Get()) then
                                    pin_code := TicketReservationRequest."Authorization Code";
                            end;
                        }
                        tableelement("ticket access entry"; "NPR TM Ticket Access Entry")
                        {
                            LinkFields = "Ticket No." = FIELD("No.");
                            LinkTable = TmpTicket;
                            XmlName = 'admission';
                            fieldattribute(code; "Ticket Access Entry"."Admission Code")
                            {
                            }
                            fieldelement(description; "Ticket Access Entry".Description)
                            {
                            }
                            fieldelement(quantity; "Ticket Access Entry".Quantity)
                            {
                            }
                            tableelement(detticketaccessentry; "NPR TM Det. Ticket AccessEntry")
                            {
                                LinkTable = "Ticket Access Entry";
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                XmlName = 'reservation';
                                SourceTableView = SORTING("Ticket Access Entry No.", Type, Open, "Posting Date") WHERE(Type = CONST(RESERVATION));
                                fieldattribute(external_id; DetTicketAccessEntry."External Adm. Sch. Entry No.")
                                {
                                }
                                textattribute(start)
                                {
                                }
                                textattribute(finish)
                                {
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    start := Format(CreateDateTime(0D, 0T), 0, 9);
                                    finish := Format(CreateDateTime(0D, 0T), 0, 9);
                                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

                                    if (AdmissionScheduleEntry.FindFirst()) then begin
                                        start := Format(CreateDateTime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"), 0, 9);
                                        finish := Format(CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time"), 0, 9);
                                    end;
                                end;

                                trigger OnPreXmlItem()
                                begin

                                    DetTicketAccessEntry.Reset();
                                    DetTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', "Ticket Access Entry"."Entry No.");
                                    DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
                                end;
                            }
                            tableelement(arrivalentry; "NPR TM Det. Ticket AccessEntry")
                            {
                                LinkTable = "Ticket Access Entry";
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                XmlName = 'arrival';
                                SourceTableView = SORTING("Ticket Access Entry No.", Type, Open, "Posting Date") WHERE(Type = CONST(ADMITTED));
                                textelement(arrival_time)
                                {
                                    MaxOccurs = Unbounded;
                                    MinOccurs = Zero;
                                }

                                trigger OnAfterGetRecord()
                                begin
                                    arrival_time := Format(ArrivalEntry."Created Datetime", 0, 9);
                                end;

                                trigger OnPreXmlItem()
                                begin

                                    ArrivalEntry.Reset();
                                    ArrivalEntry.SetFilter("Ticket Access Entry No.", '=%1', "Ticket Access Entry"."Entry No.");
                                    ArrivalEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::ADMITTED);
                                end;
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
                    var
                        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    begin

                        if (TicketReservationRequest.Get(tmpTicketReservationResponse."Request Entry No.")) then begin
                        end;
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
        ExternalIdCount: Integer;
        QtySum: Integer;
        n: Integer;
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";

    procedure GetToken(): Text[50]
    begin
        exit(ReservationID);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit(StrSubstNo('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure GetResponse(var TmpTicketOut: Record "NPR TM Ticket")
    var
    begin
        TmpTicketOut.Copy(tmpticket, true);
    end;

    procedure CreateResponse()
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        FoundTickets: Boolean;
    begin
        tmpTicketReservationResponse.DeleteAll();

        tmpTicketReservationResponse.Reset();
        tmpTicketReservationResponse."Session Token ID" := '';
        tmpTicketReservationResponse.Confirmed := false;
        tmpTicketReservationResponse."Response Message" := 'Not found.';
        tmpTicketReservationResponse.Insert();

        if (filter_value = '') then
            exit;

        if (tmpTicketReservationRequest.FindFirst()) then begin

            case UpperCase(filter_type) of

                'TICKET':
                    begin
                        Ticket.SetFilter("External Ticket No.", '=%1', filter_value);
                        if (Ticket.FindSet()) then begin
                            tmpTicketReservationResponse.Confirmed := true;
                            tmpTicketReservationResponse."Response Message" := '';
                            tmpTicketReservationResponse.Modify();
                            repeat
                                TmpTicket.TransferFields(Ticket, true);
                                TmpTicket.Insert();
                            until (Ticket.Next() = 0);
                        end;
                    end;

                'TOKEN':
                    begin
                        TicketReservationRequest.SetFilter("Session Token ID", '=%1', filter_value);
                        //if (TicketReservationRequest.FindFirst()) then begin
                        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
                        if (TicketReservationRequest.FindSet()) then begin
                            repeat
                                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                                if (Ticket.FindSet()) then begin
                                    tmpTicketReservationResponse.Confirmed := true;
                                    tmpTicketReservationResponse."Response Message" := '';
                                    tmpTicketReservationResponse.Modify();
                                    repeat
                                        TmpTicket.TransferFields(Ticket, true);
                                        TmpTicket.Insert();
                                    until (Ticket.Next() = 0);
                                end;
                            until (TicketReservationRequest.Next() = 0)
                        end;
                    end;

                'CUSTOMER',
                'MEMBER':
                    begin
                        Ticket.SetFilter("External Member Card No.", '=%1', filter_value);
                        FoundTickets := Ticket.FindSet();

                        if (not FoundTickets) then begin
                            Ticket.Reset();
                            Ticket.SetFilter("Customer No.", '=%1', filter_value);
                            FoundTickets := Ticket.FindSet();
                        end;

                        if (FoundTickets) then begin
                            tmpTicketReservationResponse.Confirmed := true;
                            tmpTicketReservationResponse."Response Message" := '';
                            tmpTicketReservationResponse.Modify();
                            repeat
                                TmpTicket.TransferFields(Ticket, true);
                                TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                                TicketAccessEntry.SetFilter("Access Date", '<>%1', 0D);
                                if ((TicketAccessEntry.IsEmpty() and
                                    (Ticket."Valid From Date" <= Today) and (Ticket."Valid To Date" >= Today) and
                                    (Ticket."Printed Date" = 0D)) or
                                  (UpperCase(full_history) = 'YES')) then begin
                                    if (TmpTicket.Insert()) then;
                                end;
                            until (Ticket.Next() = 0);
                        end;
                    end;
                else
                    Error('Invalid filter type use one of CUSTOMER, MEMBER, TICKET, TOKEN');
            end;
        end;
    end;
}

