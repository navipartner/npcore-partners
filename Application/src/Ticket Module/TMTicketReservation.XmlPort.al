xmlport 6060114 "NPR TM Ticket Reservation"
{
    // TM1.00/TSA/20151217  CASE 228982 NaviPartner Ticket Management
    // TM1.04/TSA/20160118  CASE 231834 NaviPartner Ticket Management
    // TM1.05/TSA/20160119  CASE 232250 Added Field line_no to XML for external referencing of lines
    // TM1.08/TSA/20160222  CASE 235208 Added new Field Ext. Member No. for referencing a reservation made by members
    // TM1.09/TSA/20160309  CASE 236563 Boolean XML response in changed to use XML style format
    // TM1.12/TSA/20160407  CASE 230600 Added DAN Captions
    // TM1.18/TSA/20170120 CASE 264123 Included a detailed response, useful when having more than one reservation line
    // TM1.26/TSA /20171109 CASE 295981 Added an error result path rather then a success path
    // TM1.36/TSA/20180830  CASE 323737 Transport TM1.36 - 30 August 2018
    // TM1.45/TSA /20191206 CASE 380754 Add waitinglist_ref_code attribute
    // TM1.48/TSA /20200722 CASE 415894 Added expiry utc time to response

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
                textattribute(reservationid)
                {
                    Occurrence = Required;
                    XmlName = 'token';
                }
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
                    fieldattribute(admission_schedule_entry; tmpTicketReservationRequest."External Adm. Sch. Entry No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(member_number; tmpTicketReservationRequest."External Member No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(admission_code; tmpTicketReservationRequest."Admission Code")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(waitinglist_reference_code; tmpTicketReservationRequest."Waiting List Reference Code")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute("waitinglist_opt-in_address"; tmpTicketReservationRequest."Notification Address")
                    {
                        Occurrence = Optional;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        tmpTicketReservationRequest."Entry No." := ExternalIdCount;
                    end;
                }
            }
            tableelement(tmpticketreservationresponse; "NPR TM Ticket Reserv. Resp.")
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                XmlName = 'ticket_results';
                UseTemporary = true;
                textelement(status)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;

                    trigger OnBeforePassVariable()
                    begin
                        status := Format(tmpTicketReservationResponse.Status, 0, 9);
                    end;
                }
                fieldelement(reservation_token; tmpTicketReservationResponse."Session Token ID")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                fieldelement(expiry_time; tmpTicketReservationResponse."Exires (Seconds)")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    textattribute(atutc)
                    {
                        XmlName = 'utc';

                        trigger OnBeforePassVariable()
                        begin

                            //-TM1.48 [415894]
                            AtUTC := Format(CurrentDateTime() + (tmpTicketReservationResponse."Exires (Seconds)" - 1) * 1000, 0, 9);
                            //+TM1.48 [415894]
                        end;
                    }
                }
                fieldelement(message; tmpTicketReservationResponse."Response Message")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                }
                textelement(details)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    tableelement(tmpresponsedetails; "NPR TM Ticket Reserv. Resp.")
                    {
                        MinOccurs = Zero;
                        XmlName = 'ticket';
                        UseTemporary = true;
                        fieldattribute(line_no; tmpResponseDetails."Request Entry No.")
                        {
                        }
                        fieldattribute(status; tmpResponseDetails.Status)
                        {
                        }
                        fieldattribute(message; tmpResponseDetails."Response Message")
                        {
                        }
                    }
                }
            }
        }
    }

    requestpage
    {
        Caption = 'TM Ticket Reservation';

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
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        ReservationSuccess: Boolean;
    begin
        ReservationSuccess := true;

        tmpTicketReservationResponse.DeleteAll();
        TicketReservationResponse.SetFilter("Session Token ID", '=%1', DocumentID);
        TicketReservationResponse.FindSet();
        repeat
            Clear(tmpResponseDetails);
            TicketReservationRequest.Get(TicketReservationResponse."Request Entry No.");
            tmpResponseDetails."Entry No." := TicketReservationResponse."Request Entry No.";
            tmpResponseDetails."Request Entry No." := TicketReservationRequest."Ext. Line Reference No.";

            tmpResponseDetails.Status := TicketReservationResponse.Status;
            ReservationSuccess := (ReservationSuccess and tmpResponseDetails.Status);
            tmpResponseDetails."Response Message" := TicketReservationResponse."Response Message";

            if ((tmpResponseDetails.Status) and (tmpResponseDetails."Response Message" = '')) then
                tmpResponseDetails."Response Message" := 'OK';

            tmpResponseDetails.Insert();

        until (TicketReservationResponse.Next() = 0);

        tmpTicketReservationResponse.TransferFields(TicketReservationResponse, true);
        tmpTicketReservationResponse.Status := ReservationSuccess;

        //-TM1.26 [295981]
        if (ReservationSuccess) then
            tmpTicketReservationResponse."Response Message" := 'OK';
        //+TM1.26 [295981]

        //-TM1.45 [380754]
        //IF (NOT ReservationSuccess) THEN
        //  tmpTicketReservationResponse."Session Token ID" := '';
        //+TM1.45 [380754]

        tmpTicketReservationResponse.Insert();

        tmpTicketReservationResponse.Reset();
        Commit;
    end;

    procedure SetErrorResult(DocumentID: Text[100]; ReasonText: Text)
    begin

        tmpTicketReservationResponse.DeleteAll();

        tmpTicketReservationResponse."Session Token ID" := DocumentID;
        tmpTicketReservationResponse."Exires (Seconds)" := 0;
        tmpTicketReservationResponse."Response Message" := CopyStr(ReasonText, 1, MaxStrLen(tmpTicketReservationResponse."Response Message"));
        tmpTicketReservationResponse.Insert();
    end;

    procedure GetResult(var TokenId: Text[100]; var ResponseMessage: Text): Boolean
    begin

        TokenId := tmpTicketReservationResponse."Session Token ID";
        ResponseMessage := tmpTicketReservationResponse."Response Message";

        exit(ResponseMessage = 'OK');
    end;
}

