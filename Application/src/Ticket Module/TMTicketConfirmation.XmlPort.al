xmlport 6060117 "NPR TM Ticket Confirmation"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.05/TSA/20160119  CASE 232250 Added Field line_no to XML for external referencing of lines
    // TM1.08/TSA/20160121  CASE 234296 Added value for order_uid and barcode_no
    // TM1.08/TSA/20160222  CASE 235208 Added admission Code value as attribute on admission
    // TM1.09/TSA/20160309  CASE 236563 Boolean XML response in changed to use XML style format
    // TM1.11/TSA/20160329  CASE 237803 returns a message text on fail
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.16/TSA/20160622  CASE 245004 Added field email and external order no.
    // TM1.17/TSA /20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.19/TSA/20170130  CASE 264591 Added a reservation element line to the admission section, changed cardinality from 1-n to 0-n on element ticket.
    // TM1.21/TSA/20170523  CASE 276898 Added error text when response not found
    // TM1.38/TSA /20181017 CASE 332109 Added eTicket support

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
                    tableelement(ticket; "NPR TM Ticket")
                    {
                        LinkTable = tmpTicketReservationResponse;
                        MinOccurs = Zero;
                        XmlName = 'ticket';
                        textattribute(external_id)
                        {
                        }
                        textattribute(line_no)
                        {
                        }
                        fieldelement(ticket_uid; Ticket."External Ticket No.")
                        {
                        }
                        fieldelement(barcode_no; Ticket."Ticket No. for Printing")
                        {

                            trigger OnBeforePassField()
                            begin
                                if (Ticket."Ticket No. for Printing" = '') then
                                    Ticket."Ticket No. for Printing" := Ticket."External Ticket No.";
                            end;
                        }
                        textelement(valid_from)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                valid_from := Format(Ticket."Valid From Date", 0, 9);
                            end;
                        }
                        textelement(valid_until)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                valid_until := Format(Ticket."Valid To Date", 0, 9);
                            end;
                        }
                        textelement(available_as_eticket)
                        {

                            trigger OnBeforePassVariable()
                            var
                                TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                            begin

                                //-TM1.38 [332109]
                                available_as_eticket := 'false';
                                if (TicketRequestManager.IsETicket(Ticket."No.")) then
                                    available_as_eticket := 'true';
                                //+TM1.38 [332109]
                            end;
                        }
                        textelement(pin_code)
                        {
                        }
                        tableelement("ticket access entry"; "NPR TM Ticket Access Entry")
                        {
                            LinkFields = "Ticket No." = FIELD("No.");
                            LinkTable = Ticket;
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
                        }

                        trigger OnPreXmlItem()
                        begin
                            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', tmpTicketReservationResponse."Request Entry No.");
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
                    begin
                        if (TicketReservationRequest.Get(tmpTicketReservationResponse."Request Entry No.")) then begin
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
        n: Integer;
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";

    procedure GetToken(): Text[100]
    begin
        exit(ReservationID);
    end;

    procedure GetSummary(): Text[30]
    begin
        exit(StrSubstNo('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure SetReservationResult(DocumentID: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin
        tmpTicketReservationResponse.DeleteAll();
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentID);
        if (TicketReservationResponse.FindSet()) then begin
            repeat
                tmpTicketReservationResponse.TransferFields(TicketReservationResponse, true);
                tmpTicketReservationResponse.Insert();
            until (TicketReservationResponse.Next = 0);

        end else begin
            tmpTicketReservationResponse.Reset();
            tmpTicketReservationResponse."Session Token ID" := DocumentID;
            tmpTicketReservationResponse."Response Message" := StrSubstNo('Invalid token [%1]', DocumentID);
            tmpTicketReservationResponse.Insert();
        end;
    end;
}

