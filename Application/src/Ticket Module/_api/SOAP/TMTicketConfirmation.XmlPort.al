xmlport 6060117 "NPR TM Ticket Confirmation"
{
    Caption = 'Ticket Confirmation';
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
                fieldelement(external_order_no; tmpTicketReservationRequest."External Order No.")
                {
                    MinOccurs = Zero;
                }
            }
            textelement(ticket_results)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                tableelement(TempTicketReservationResponse; "NPR TM Ticket Reserv. Resp.")
                {
                    MinOccurs = Zero;
                    XmlName = 'tickets';
                    UseTemporary = true;
                    textelement(status)
                    {
                        XmlName = 'status';
                        MinOccurs = Once;
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin
                            status := Format(TempTicketReservationResponse.Confirmed, 0, 9);
                        end;
                    }
                    fieldelement(order_uid; TempTicketReservationResponse."Session Token ID")
                    {
                        XmlName = 'order_uid';
                        MinOccurs = Once;
                        MaxOccurs = Once;
                    }
                    fieldelement(message_text; TempTicketReservationResponse."Response Message")
                    {
                        XmlName = 'message_text';
                        MinOccurs = Zero;
                        MaxOccurs = Once;
                    }
                    tableelement(Ticket; "NPR TM Ticket")
                    {
                        LinkTable = TempTicketReservationResponse;
                        MinOccurs = Zero;
                        MaxOccurs = Unbounded;
                        XmlName = 'ticket';
                        textattribute(external_id)
                        {
                            XmlName = 'external_id';
                            Occurrence = Required;
                        }
                        textattribute(line_no)
                        {
                            XmlName = 'line_no';
                            Occurrence = Required;
                        }
                        fieldelement(ticket_uid; Ticket."External Ticket No.")
                        {
                            XmlName = 'ticket_uid';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(barcode_no; Ticket."Ticket No. for Printing")
                        {
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            XmlName = 'barcode_no';
                            trigger OnBeforePassField()
                            begin
                                if (Ticket."Ticket No. for Printing" = '') then
                                    Ticket."Ticket No. for Printing" := Ticket."External Ticket No.";
                            end;
                        }
                        textelement(ValidFrom)
                        {
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            XmlName = 'valid_from';
                            trigger OnBeforePassVariable()
                            begin
                                ValidFrom := Format(Ticket."Valid From Date", 0, 9);
                            end;
                        }
                        textelement(ValidUntil)
                        {
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            XmlName = 'valid_until';

                            trigger OnBeforePassVariable()
                            begin
                                ValidUntil := Format(Ticket."Valid To Date", 0, 9);
                            end;
                        }
                        textelement(AvailableAsETicket)
                        {
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            XmlName = 'available_as_eticket';

                            trigger OnBeforePassVariable()
                            var
                                TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                            begin
                                AvailableAsETicket := 'false';
                                if (TicketRequestManager.IsETicket(Ticket."No.")) then
                                    AvailableAsETicket := 'true';
                            end;
                        }
                        textelement(pin_code)
                        {
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                            XmlName = 'pin_code';
                        }
                        tableelement(TicketAccessEntry; "NPR TM Ticket Access Entry")
                        {
                            LinkFields = "Ticket No." = FIELD("No.");
                            LinkTable = Ticket;
                            XmlName = 'admission';
                            MinOccurs = Zero;
                            MaxOccurs = Unbounded;
                            fieldattribute(code; TicketAccessEntry."Admission Code")
                            {
                            }
                            fieldelement(description; TicketAccessEntry.Description)
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }
                            fieldelement(quantity; TicketAccessEntry.Quantity)
                            {
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }
                            tableelement(DetailedTicketAccessEntry; "NPR TM Det. Ticket AccessEntry")
                            {
                                LinkTable = TicketAccessEntry;
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                                XmlName = 'reservation';
                                SourceTableView = SORTING("Ticket Access Entry No.", Type, Open, "Posting Date") WHERE(Type = CONST(RESERVATION));
                                fieldattribute(external_id; DetailedTicketAccessEntry."External Adm. Sch. Entry No.")
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
                                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedTicketAccessEntry."External Adm. Sch. Entry No.");
                                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

                                    if (AdmissionScheduleEntry.FindFirst()) then begin
                                        start := Format(CreateDateTime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"), 0, 9);
                                        finish := Format(CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time"), 0, 9);
                                    end;
                                end;

                                trigger OnPreXmlItem()
                                begin

                                    DetailedTicketAccessEntry.Reset();
                                    DetailedTicketAccessEntry.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                                    DetailedTicketAccessEntry.SetFilter(Type, '=%1', DetailedTicketAccessEntry.Type::RESERVATION);
                                    DetailedTicketAccessEntry.SetFilter(Quantity, '>%1', 0);
                                end;
                            }
                        }

                        trigger OnPreXmlItem()
                        begin
                            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', -2);
                            if (TempTicketReservationResponse."Request Entry No." <> 0) then
                                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TempTicketReservationResponse."Request Entry No.");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    begin
                        if (TicketReservationRequest.Get(TempTicketReservationResponse."Request Entry No.")) then begin
                            external_id := TicketReservationRequest."External Item Code";
                            line_no := Format(TicketReservationRequest."Ext. Line Reference No.", 0, 9);
                            pin_code := TicketReservationRequest."Authorization Code";
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
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";

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

    internal procedure SetReservationResult(DocumentID: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
        InvalidTokenLbl: Label 'Invalid token [%1]';
    begin
        if (TempTicketReservationResponse.IsTemporary()) then
            TempTicketReservationResponse.DeleteAll();

        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentID);
        if (TicketReservationResponse.FindFirst()) then begin
            repeat
                TempTicketReservationResponse.TransferFields(TicketReservationResponse, true);
                if (TempTicketReservationResponse."Response Message" = '') then
                    TempTicketReservationResponse."Response Message" := 'OK';
                TempTicketReservationResponse.Insert();
            until (TicketReservationResponse.Next() = 0);

        end else begin
            TempTicketReservationResponse.Reset();
            TempTicketReservationResponse."Session Token ID" := DocumentID;
            TempTicketReservationResponse."Response Message" := StrSubstNo(InvalidTokenLbl, DocumentID);
            TempTicketReservationResponse.Insert();
        end;
    end;

    procedure SetErrorResult(DocumentID: Text[100]; ErrorText: Text)
    var
    begin

        SetReservationResult(DocumentID);
        TempTicketReservationResponse.Reset();
        TempTicketReservationResponse.ModifyAll("Response Message", CopyStr(ErrorText, 1, MaxStrLen(TempTicketReservationResponse."Response Message")));
    end;
}

