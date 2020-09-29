xmlport 6060108 "NPR TM Ticket Conf. Change Req"
{
    Caption = 'Ticket Configuration Change Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(Tickets)
        {
            MaxOccurs = Once;

            textelement(ConfirmChangeReservation)
            {
                MaxOccurs = Once;

                textelement(Request)
                {
                    MaxOccurs = Once;
                    textelement(ChangeRequestId)
                    {
                        XmlName = 'ChangeRequestToken';
                        MinOccurs = Once;
                        MaxOccurs = Once;
                    }
                    textelement(Admissions)
                    {
                        tableelement(tmpTicketReservationRequest; "NPR TM Ticket Reservation Req.")
                        {
                            XmlName = 'Admission';
                            UseTemporary = true;

                            fieldattribute(AdmissionCode; tmpTicketReservationRequest."Admission Code")
                            {
                                XmlName = 'Code';
                                Occurrence = Required;
                            }

                            fieldattribute(OldScheduleEntryNo; tmpTicketReservationRequest."Line No.")
                            {
                                XmlName = 'OldScheduleEntryNo';
                                Occurrence = Required;
                            }

                            fieldattribute(NewScheduleEntryNo; tmpTicketReservationRequest."External Adm. Sch. Entry No.")
                            {
                                XmlName = 'NewScheduleEntryNo';
                                Occurrence = Required;
                            }
                        }
                    }


                }
                textelement(Result)
                {
                    XmlName = 'Result';
                    MinOccurs = Zero;
                    MaxOccurs = Once;

                    textelement(ResponseCode)
                    {
                        MinOccurs = Zero;
                        MaxOccurs = Once;
                    }

                    textelement(ResponseMessage)
                    {
                        MinOccurs = Zero;
                        MaxOccurs = Once;
                    }

                    tableelement(tmpTicketReservationResponse; "NPR TM Ticket Reserv. Resp.")
                    {
                        XmlName = 'Tickets';
                        UseTemporary = true;
                        MinOccurs = Zero;
                        MaxOccurs = Once;

                        textattribute(OrderId)
                        {
                            XmlName = 'OrderId';
                            Occurrence = Required;
                        }

                        tableelement(Ticket; "NPR TM Ticket")
                        {
                            XmlName = 'Ticket';

                            textattribute(ExternalId)
                            {
                                XmlName = 'external_id';
                                Occurrence = Required;
                            }

                            textelement(LineNo)
                            {
                                XmlName = 'line_no';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            textelement(TicketUid)
                            {
                                XmlName = 'ticket_uid';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            textelement(BarcodeNo)
                            {
                                XmlName = 'barcode_no';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            textelement(ValidFrom)
                            {
                                XmlName = 'valid_from';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            textelement(ValidUntil)
                            {
                                XmlName = 'valid_until';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            textelement(AvailableAsEticket)
                            {
                                XmlName = 'available_as_eticket';
                                MinOccurs = Zero;
                                MaxOccurs = Once;
                            }

                            textelement(PinCode)
                            {
                                XmlName = 'pin_code';
                            }

                            tableelement(TicketAccessEntry; "NPR TM Ticket Access Entry")
                            {
                                XmlName = 'admission';
                                MinOccurs = Once;
                                MaxOccurs = Unbounded;

                                fieldattribute(AdmissionCode; TicketAccessEntry."Admission Code")
                                {
                                    XmlName = 'code';
                                    Occurrence = Required;
                                }

                                fieldelement(Description; TicketAccessEntry.Description)
                                {
                                    XmlName = 'description';
                                    MinOccurs = Zero;
                                    MaxOccurs = Once;
                                }

                                fieldelement(Quantity; TicketAccessEntry.Quantity)
                                {
                                    XmlName = 'quantity';
                                    MinOccurs = Zero;
                                    MaxOccurs = Once;
                                }

                                tableelement(Reservation; "NPR TM Det. Ticket AccessEntry")
                                {
                                    XmlName = 'reservation';
                                    MinOccurs = Zero;
                                    MaxOccurs = Once;
                                    textattribute(StartDateTime)
                                    {
                                        XmlName = 'start';
                                        Occurrence = Optional;
                                    }

                                    textattribute(UntilDateTime)
                                    {
                                        XmlName = 'finish';
                                        Occurrence = Optional;
                                    }

                                    trigger OnPreXmlItem()
                                    begin
                                        Reservation.SetFilter("Ticket Access Entry No.", '=%1', TicketAccessEntry."Entry No.");
                                        Reservation.SetFilter(Type, '=%1', Reservation.Type::RESERVATION);
                                    end;

                                    trigger OnAfterGetRecord()
                                    var
                                        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                                    begin
                                        StartDateTime := '';
                                        UntilDateTime := '';
                                        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', Reservation."External Adm. Sch. Entry No.");
                                        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                                        if (AdmissionScheduleEntry.findlast()) then begin
                                            StartDateTime := Format(createdatetime(AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time"), 0, 9);
                                            UntilDateTime := Format(createdatetime(AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time"), 0, 9);
                                        end;

                                    end;
                                }

                                trigger OnPreXmlItem()
                                begin
                                    TicketAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
                                end;
                            }

                            trigger OnPreXmlItem()
                            begin
                                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', tmpTicketReservationResponse."Request Entry No.");
                            end;

                            trigger OnAfterGetRecord()
                            var
                                TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                            begin
                                TicketUid := Ticket."Ticket No. for Printing";
                                BarcodeNo := Ticket."Ticket No. for Printing";
                                if (BarcodeNo = '') then
                                    BarcodeNo := Ticket."External Ticket No.";
                                ValidFrom := Format(Ticket."Valid From Date", 0, 9);
                                ValidUntil := Format(Ticket."Valid To Date", 0, 9);
                                AvailableAsEticket := Format(TicketRequestManager.IsETicket(Ticket."No."), 0, 9);

                            end;
                        }

                        trigger OnAfterGetRecord()
                        var
                            TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                        begin
                            if (TicketReservationRequest.GET(tmpTicketReservationResponse."Request Entry No.")) then begin
                                ExternalId := TicketReservationRequest."External Item Code";
                                LineNo := FORMAT(TicketReservationRequest."Ext. Line Reference No.", 0, 9);
                                PinCode := TicketReservationRequest."Authorization Code";
                            end;
                        end;
                    }
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

    procedure SetError(ErrorMessage: Text)
    begin
        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
    end;

    procedure GetToken(): TExt[100]
    begin
        Exit(ChangeRequestId);
    end;

    procedure SetChangeRequestId(DocumentId: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin

        tmpTicketReservationResponse.Reset();
        if (tmpTicketReservationResponse.IsTemporary) then
            tmpTicketReservationResponse.DeleteAll();

        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentId);
        if (TicketReservationResponse.FindSet()) then begin
            repeat
                tmpTicketReservationResponse.TransferFields(TicketReservationResponse, true);
                tmpTicketReservationResponse.Insert();
            until (TicketReservationResponse.Next() = 0);

            OrderId := DocumentId;
            ResponseCode := 'OK';
            ResponseMessage := '';

        end else begin
            tmpTicketReservationResponse."Session Token ID" := DocumentId;
            tmpTicketReservationResponse."Response Message" := StrSubstNo('Invalid token [%1]', DocumentId);
            tmpTicketReservationResponse.Insert();

            SetError(tmpTicketReservationResponse."Response Message");
        end;

    end;
}