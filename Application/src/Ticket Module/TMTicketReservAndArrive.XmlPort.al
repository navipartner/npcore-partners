xmlport 6060118 "NPR TM Ticket Reserv.AndArrive"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.05/TSA/20160119  CASE 232250 Added Field line_no to XML for external referencing of lines
    // TM1.08/TSA/20160222  CASE 235208 Added new Field Ext. Member No. for referencing a reservation made by members
    // TM1.09/TSA/20160309  CASE 236563 Boolean XML response in changed to use XML style format
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.17/TSA/20161025  CASE 256152 Conform to OMA Guidelines
    // TM1.20/TSA/20170327  CASE 270164 Made Admission Code optional
    // #335889/TSA /20190124 CASE 335889 Changed output formating option XML, removed field specific formating

    Caption = 'Ticket Reservation';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(tickets)
        {
            MaxOccurs = Once;
            textelement(reserve_tickets)
            {
                MaxOccurs = Once;
                MinOccurs = Once;
                tableelement(tmpticketreservationrequest; "NPR TM Ticket Reservation Req.")
                {
                    XmlName = 'ticket';
                    UseTemporary = true;
                    fieldattribute(external_id; tmpTicketReservationRequest."External Item Code")
                    {

                        trigger OnAfterAssignField()
                        begin
                            ExternalIdCount += 1;
                        end;
                    }
                    fieldattribute(line_no; tmpTicketReservationRequest."Ext. Line Reference No.")
                    {
                    }
                    fieldattribute(qty; tmpTicketReservationRequest.Quantity)
                    {

                        trigger OnAfterAssignField()
                        begin
                            QtySum += tmpTicketReservationRequest.Quantity;
                        end;
                    }
                    fieldattribute(admission_code; tmpTicketReservationRequest."Admission Code")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(admission_schedule_entry; tmpTicketReservationRequest."External Adm. Sch. Entry No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(member_number; tmpTicketReservationRequest."External Member No.")
                    {
                        Occurrence = Optional;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        tmpTicketReservationRequest."Entry No." := ExternalIdCount;
                    end;
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
                        MinOccurs = Zero;
                    }
                    tableelement(ticket; "NPR TM Ticket")
                    {
                        LinkFields = "Ticket Reservation Entry No." = FIELD("Request Entry No.");
                        LinkTable = tmpTicketReservationResponse;
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
                        fieldelement(valid_from; Ticket."Valid From Date")
                        {
                        }
                        fieldelement(valid_until; Ticket."Valid To Date")
                        {
                        }
                        tableelement("ticket access entry"; "NPR TM Ticket Access Entry")
                        {
                            LinkFields = "Ticket No." = FIELD("No.");
                            LinkTable = Ticket;
                            XmlName = 'admissions_validated';
                            fieldattribute(code; "Ticket Access Entry"."Admission Code")
                            {
                            }
                            fieldelement(description; "Ticket Access Entry".Description)
                            {
                            }
                            fieldelement(quantity; "Ticket Access Entry".Quantity)
                            {
                            }

                            trigger OnPreXmlItem()
                            begin

                                "Ticket Access Entry".SetFilter("Admission Code", '=%1', TicketReservationRequest."Admission Code");
                            end;
                        }

                        trigger OnAfterGetRecord()
                        begin
                            if (TicketReservationRequest.Get(Ticket."Ticket Reservation Entry No.")) then begin
                                external_id := TicketReservationRequest."External Item Code";
                                line_no := Format(TicketReservationRequest."Ext. Line Reference No.", 0, 9);
                            end;
                        end;
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'TM Ticket ReservationAndArrive';

        layout
        {
        }

        actions
        {
        }
    }

    var
        ExternalIdCount: Integer;
        QtySum: Integer;
        n: Integer;
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        BLANK_DOC_ID: Label 'Document ID may not be blank.';

    procedure GetToken(): Text[100]
    begin
        exit('');
    end;

    procedure GetSummary(): Text[30]
    begin
        exit(StrSubstNo('%1-%2', ExternalIdCount, QtySum));
    end;

    procedure SetReservationResult(DocumentID: Text[100])
    var
        TicketReservationResponse: Record "NPR TM Ticket Reserv. Resp.";
    begin
        if (DocumentID = '') then
            Error(BLANK_DOC_ID);

        tmpTicketReservationResponse.DeleteAll();
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationResponse.FindSet();
        repeat
            tmpTicketReservationResponse.TransferFields(TicketReservationResponse, true);
            tmpTicketReservationResponse.Insert();
        until (TicketReservationResponse.Next() = 0);

        Commit;
    end;
}

