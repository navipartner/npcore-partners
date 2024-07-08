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
                XmlName = 'ticket_tokens';
                MaxOccurs = Once;
                MinOccurs = Once;
                UseTemporary = true;
                fieldelement(ticket_token; tmpTicketReservationRequest."Session Token ID")
                {
                    XmlName = 'ticket_token';
                    MinOccurs = Once;
                    MaxOccurs = Once;

                    trigger OnAfterAssignField()
                    begin
                        if (ReservationID = '') then
                            ReservationID := tmpTicketReservationRequest."Session Token ID";
                    end;
                }
                fieldelement(send_notification_to; tmpTicketReservationRequest."Notification Address")
                {
                    XmlName = 'send_notification_to';
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                }
                fieldelement(external_order_no; tmpTicketReservationRequest."External Order No.")
                {
                    XmlName = 'external_order_no';
                    MinOccurs = Zero;
                    MaxOccurs = Once;
                }
                fieldelement(TicketHolderName; tmpTicketReservationRequest.TicketHolderName)
                {
                    XmlName = 'ticket_holder_name';
                    MinOccurs = Zero;
                    MaxOccurs = Once;
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
                                textattribute(UTCstart)
                                {
                                    XmlName = 'start';
                                    Occurrence = Optional;
                                }
                                textattribute(LocalStartDate)
                                {
                                    XmlName = 'start_date';
                                    Occurrence = Optional;
                                }
                                textattribute(LocalStartTime)
                                {
                                    XmlName = 'start_time';
                                    Occurrence = Optional;
                                }
                                textattribute(UTCfinish)
                                {
                                    XmlName = 'finish';
                                    Occurrence = Optional;
                                }
                                textattribute(LocalEndDate)
                                {
                                    XmlName = 'end_date';
                                    Occurrence = Optional;
                                }
                                textattribute(LocalEndTime)
                                {
                                    XmlName = 'end_time';
                                    Occurrence = Optional;
                                }
                                trigger OnAfterGetRecord()
                                var
                                    AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                                begin
                                    UTCstart := Format(CreateDateTime(0D, 0T), 0, 9);
                                    UTCfinish := Format(CreateDateTime(0D, 0T), 0, 9);
                                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedTicketAccessEntry."External Adm. Sch. Entry No.");
                                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

                                    if (AdmissionScheduleEntry.FindFirst()) then begin
                                        LocalStartDate := Format(AdmissionScheduleEntry."Admission Start Date", 0, 9);
                                        LocalStartTime := Format(AdmissionScheduleEntry."Admission Start Time", 0, 9);
                                        LocalEndDate := Format(AdmissionScheduleEntry."Admission End Date", 0, 9);
                                        LocalEndTime := Format(AdmissionScheduleEntry."Admission End Time", 0, 9);

                                        UTCstart := Format(CreateDateTime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"), 0, 9);
                                        UTCfinish := Format(CreateDateTime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time"), 0, 9);
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
                            if (TempTicketReservationResponse."Request Entry No." <> 0) and (TempTicketReservationResponse.Confirmed) then
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

        TicketReservationResponse.SetCurrentKey("Session Token ID");
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

