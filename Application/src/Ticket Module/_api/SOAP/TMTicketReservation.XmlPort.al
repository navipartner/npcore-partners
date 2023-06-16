xmlport 6060114 "NPR TM Ticket Reservation"
{
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
                    fieldattribute(line_no; tmpTicketReservationRequest."Ext. Line Reference No.") { }
                    fieldattribute(qty; tmpTicketReservationRequest.Quantity)
                    {

                        trigger OnAfterAssignField()
                        begin
                            QtySum += tmpTicketReservationRequest.Quantity;
                        end;
                    }
                    fieldattribute(admission_schedule_entry; tmpTicketReservationRequest."External Adm. Sch. Entry No.") { Occurrence = Optional; }
                    fieldattribute(member_number; tmpTicketReservationRequest."External Member No.") { Occurrence = Optional; }
                    fieldattribute(admission_code; tmpTicketReservationRequest."Admission Code") { Occurrence = Optional; }
                    fieldattribute(waitinglist_reference_code; tmpTicketReservationRequest."Waiting List Reference Code") { Occurrence = Optional; }
                    fieldattribute("waitinglist_opt-in_address"; tmpTicketReservationRequest."Notification Address") { Occurrence = Optional; }

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
                            AtUTC := Format(CurrentDateTime() + (tmpTicketReservationResponse."Exires (Seconds)" - 1) * 1000, 0, 9);
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
                        fieldattribute(line_no; tmpResponseDetails."Request Entry No.") { }
                        fieldattribute(status; tmpResponseDetails.Status) { }
                        fieldattribute(message; tmpResponseDetails."Response Message") { }
                        textattribute(ticket_price)
                        {
                            XmlName = 'ticket_price';
                            trigger OnBeforePassVariable()
                            begin
                                ticket_price := Format(TicketPrice, 0, 9);
                            end;
                        }

                        textelement(admissions)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(tmpAdmissions; "NPR TM Ticket Reservation Req.")
                            {
                                XmlName = 'Admission';
                                UseTemporary = true;
                                MinOccurs = Once;
                                MaxOccurs = Unbounded;
                                SourceTableView = sorting("Admission Inclusion");

                                fieldattribute(AdmissionCode; tmpAdmissions."Admission Code")
                                {
                                    XmlName = 'Code';
                                    Occurrence = Required;
                                }

                                textelement(SceduleEntry)
                                {
                                    fieldattribute(EntryNo; tmpAdmissions."External Adm. Sch. Entry No.")
                                    {
                                        XmlName = 'ExternalEntryNo';
                                        Occurrence = Required;
                                    }

                                    textattribute(ReservationType)
                                    {
                                        XmlName = 'ReservationType';
                                        Occurrence = Required;
                                    }

                                    textattribute(AdmissionStartDate)
                                    {
                                        XmlName = 'Date';
                                        Occurrence = Optional;
                                    }

                                    textattribute(AdmissionStartTime)
                                    {
                                        XmlName = 'StartTime';
                                        Occurrence = Optional;
                                    }

                                    textattribute(AdmissionEndTime)
                                    {
                                        XmlName = 'EndTime';
                                        Occurrence = Optional;
                                    }

                                    textattribute(ValidFrom)
                                    {
                                        XmlName = 'ValidFrom';
                                        Occurrence = Optional;
                                    }

                                    textattribute(ValidUntil)
                                    {
                                        XmlName = 'ValidUntil';
                                        Occurrence = Optional;
                                    }

                                    textattribute(CanReschedule)
                                    {
                                        XmlName = 'CanReschedule';
                                        Occurrence = Required;
                                    }
                                    textattribute(admission_price)
                                    {
                                        XmlName = 'admission_price';
                                        trigger OnBeforePassVariable()
                                        begin
                                            admission_price := tmpAdmissions."Notification Address";
                                        end;
                                    }
                                    textelement(admission_is)
                                    {
                                        XmlName = 'admission_is';
                                        textattribute(admission_is_id)
                                        {
                                            XmlName = 'option_value';

                                            trigger OnBeforePassVariable()
                                            begin

                                                admission_is_id := Format(tmpAdmissions."Admission Inclusion", 0, 9);
                                            end;
                                        }


                                        trigger OnBeforePassVariable()
                                        begin

                                            admission_is := Format(tmpAdmissions."Admission Inclusion");
                                        end;
                                    }

                                }

                                textelement(AdmissionDescription)
                                {
                                    XmlName = 'Description';
                                    MinOccurs = Once;
                                    MaxOccurs = Once;
                                }

                                trigger OnAfterGetRecord()
                                var
                                    AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
                                    Admission: Record "NPR TM Admission";
                                    Ticket: Record "NPR TM Ticket";
                                begin
                                    if Admission.Get(tmpAdmissions."Admission Code") then begin
                                        AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', tmpAdmissions."External Adm. Sch. Entry No.");
                                        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                                        AdmissionScheduleEntry.FindLast();
                                    end;
                                    ReservationType := 'Open';
                                    AdmissionDescription := Admission.Description;
                                    AdmissionStartDate := '';
                                    AdmissionStartTime := '';
                                    AdmissionEndTime := '';
                                    ValidFrom := '';
                                    ValidUntil := '';

                                    CanReschedule := Format(IsRescheduleAllowed(tmpAdmissions."Item No.", tmpAdmissions."Variant Code", tmpAdmissions."Admission Code"));

                                    if (Admission.Type = Admission.Type::OCCASION) then begin
                                        ReservationType := 'Reservation';
                                        AdmissionStartDate := Format(AdmissionScheduleEntry."Admission Start Date", 0, 9);
                                        AdmissionStartTime := Format(AdmissionScheduleEntry."Admission Start Time", 0, 9);
                                        AdmissionEndTime := Format(AdmissionScheduleEntry."Admission End Time", 0, 9);
                                    end else begin
                                        Ticket.Init();
                                        ValidFrom := Format(Ticket."Valid From Date", 0, 9);
                                        ValidUntil := Format(Ticket."Valid To Date", 0, 9)
                                    end;

                                end;
                            }
                        }
                        trigger OnAfterGetRecord()
                        begin
                            tmpAdmissions.DeleteAll();
                            PopulateResponseAdmissions(tmpTicketReservationResponse."Session Token ID", tmpResponseDetails."Request Entry No.");
                        end;
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
        AdmissionPrice: Decimal;
        ExternalIdCount: Integer;
        TicketPrice: Decimal;
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
        if (ReservationSuccess) then
            tmpTicketReservationResponse."Response Message" := 'OK';

        tmpTicketReservationResponse.Insert();
        tmpTicketReservationResponse.Reset();
        Commit();
    end;

    internal procedure SetErrorResult(DocumentID: Text[100]; ReasonText: Text)
    begin
        tmpTicketReservationResponse.DeleteAll();

        tmpTicketReservationResponse."Session Token ID" := DocumentID;
        tmpTicketReservationResponse."Exires (Seconds)" := 0;
        tmpTicketReservationResponse."Response Message" := CopyStr(ReasonText, 1, MaxStrLen(tmpTicketReservationResponse."Response Message"));
        tmpTicketReservationResponse.Insert();
    end;

    internal procedure GetResult(var TokenId: Text[100]; var ResponseMessage: Text): Boolean
    begin
        TokenId := tmpTicketReservationResponse."Session Token ID";
        ResponseMessage := tmpTicketReservationResponse."Response Message";

        exit(ResponseMessage = 'OK');
    end;


    local procedure PopulateResponseAdmissions(Token: Text[100]; RequestEntryNo: Integer)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        DynamicPrice: Codeunit "NPR TM Dynamic Price";
        BasePrice, AddonPrice : Decimal;
    begin
        TicketPrice := 0;
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', RequestEntryNo);
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        if (not TicketReservationRequest.FindFirst()) then
            exit;

        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        if (not Ticket.FindFirst()) then
            exit;

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("Session Token ID", "Ext. Line Reference No.", "Admission Inclusion");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', RequestEntryNo);
        if (not TicketReservationRequest.FindSet()) then
            exit;

        repeat
            tmpAdmissions.TransferFields(TicketReservationRequest, true);
            if tmpAdmissions."External Adm. Sch. Entry No." = 0 then
                tmpAdmissions."External Adm. Sch. Entry No." := FindExternalAdmissionScheduleEntryNo(Ticket."No.", TicketReservationRequest."Admission Code");

            DynamicPrice.CalculateScheduleEntryPrice(tmpAdmissions."Item No.", tmpAdmissions."Variant Code", tmpAdmissions."Admission Code", tmpAdmissions."External Adm. Sch. Entry No.", Today(), Time(), BasePrice, AddonPrice);
            AdmissionPrice := BasePrice + AddonPrice;
            if tmpAdmissions."Admission Inclusion" <> tmpAdmissions."Admission Inclusion"::NOT_SELECTED then
                TicketPrice := TicketPrice + AdmissionPrice;
            tmpAdmissions."Notification Address" := Format(AdmissionPrice, 0, 9);
            tmpAdmissions.Insert();
        until (TicketReservationRequest.Next() = 0);
    end;

    local procedure IsRescheduleAllowed(ItemNo: Code[20]; VariantCode: Code[10]; ParamAdmissionCode: Code[20]): Boolean
    var
        TicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
    begin
        if not TicketAdmissionBOM.Get(ItemNo, VariantCode, ParamAdmissionCode) then
            exit(false);
        case TicketAdmissionBOM."Reschedule Policy" of
            TicketAdmissionBOM."Reschedule Policy"::NOT_ALLOWED:
                exit(false);
            TicketAdmissionBOM."Reschedule Policy"::UNTIL_USED, TicketAdmissionBOM."Reschedule Policy"::CUTOFF_HOUR:
                exit(true);
        end;
    end;

    local procedure FindExternalAdmissionScheduleEntryNo(TicketNo: Code[20]; ParamAdmissionCode: Code[20]): Integer
    var
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
    begin
        TicketAccessEntry.SetRange("Ticket No.", TicketNo);
        TicketAccessEntry.SetRange("Admission Code", ParamAdmissionCode);
        if TicketAccessEntry.FindFirst() then begin
            DetTicketAccessEntry.SetRange("Ticket Access Entry No.", TicketAccessEntry."Entry No.");
            if DetTicketAccessEntry.FindLast() then
                exit(DetTicketAccessEntry."External Adm. Sch. Entry No.");
        end;
    end;
}

