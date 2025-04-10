xmlport 6060107 "NPR TM Ticket Change Request"
{
    Caption = 'Ticket Get Change Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(Tickets)
        {
            MinOccurs = Once;
            MaxOccurs = Once;

            textelement(ChangeReservation)
            {
                MinOccurs = Once;
                MaxOccurs = Once;

                tableelement(tmpTicketReservationRequest; "NPR TM Ticket Reservation Req.")
                {
                    XmlName = 'Request';
                    UseTemporary = true;
                    MinOccurs = Once;
                    MaxOccurs = Once;

                    textelement(TicketNumber)
                    {
                        MinOccurs = Once;
                        MaxOccurs = Once;
                    }

                    textelement(PinCode)
                    {
                        MinOccurs = Once;
                        MaxOccurs = Once;
                    }
                }

                tableelement(tmpResult; "NPR TM Ticket Reservation Req.")
                {
                    XmlName = 'Result';
                    UseTemporary = true;
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

                    textelement(ExpiresAt)
                    {
                        XmlName = 'ExpiresAt';
                        MinOccurs = Zero;
                        MaxOccurs = Once;

                        textattribute(ExpiresAtUTC)
                        {
                            XmlName = 'UTC';
                            trigger OnBeforePassVariable()
                            begin
                                ExpiresAtUTC := Format(tmpResult."Expires Date Time", 0, 9);
                            end;
                        }
                    }

                    textelement(Ticket)
                    {
                        XmlName = 'Ticket';
                        MinOccurs = Zero;
                        MaxOccurs = Once;

                        textattribute(ChangeRequestToken)
                        {
                            XmlName = 'ChangeRequestToken';
                            Occurrence = Required;
                        }

                        textelement(Admissions)
                        {
                            XmlName = 'Admissions';
                            MinOccurs = Zero;
                            MaxOccurs = Once;

                            tableelement(tmpChangeRequest; "NPR TM Ticket Reservation Req.")
                            {
                                XmlName = 'Admission';
                                UseTemporary = true;
                                MinOccurs = Once;
                                MaxOccurs = Unbounded;

                                fieldattribute(AdmissionCode; tmpChangeRequest."Admission Code")
                                {
                                    XmlName = 'Code';
                                    Occurrence = Required;
                                }

                                textelement(ScheduleEntry)
                                {
                                    XmlName = 'ScheduleEntry';

                                    fieldattribute(EntryNo; tmpChangeRequest."External Adm. Sch. Entry No.")
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
                                            admission_price := Format(AdmissionPrice, 0, 9);
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

                                                admission_is_id := Format(tmpChangeRequest."Admission Inclusion", 0, 9);
                                            end;
                                        }


                                        trigger OnBeforePassVariable()
                                        begin

                                            admission_is := Format(tmpChangeRequest."Admission Inclusion");
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
                                    TicketManagement: Codeunit "NPR TM Ticket Management";
                                    TicketPrice: Codeunit "NPR TM Dynamic Price";
                                    BasePrice, AddonPrice : Decimal;
                                begin
                                    AdmissionPrice := 0;
                                    Admission.Get(tmpChangeRequest."Admission Code");
                                    AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', tmpChangeRequest."External Adm. Sch. Entry No.");
                                    AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
                                    if (not AdmissionScheduleEntry.FindLast()) then
                                        AdmissionScheduleEntry.Init();

                                    ReservationType := 'Open';
                                    AdmissionDescription := Admission.Description;
                                    AdmissionStartDate := '';
                                    AdmissionStartTime := '';
                                    AdmissionEndTime := '';
                                    ValidFrom := '';
                                    ValidUntil := '';

                                    CanReschedule := Format(TicketManagement.IsRescheduleAllowed(TicketNumber, tmpChangeRequest."External Adm. Sch. Entry No.", tmpChangeRequest."Request Status Date Time"));

                                    if (Admission.Type = Admission.Type::OCCASION) then begin
                                        ReservationType := 'Reservation';
                                        AdmissionStartDate := Format(AdmissionScheduleEntry."Admission Start Date", 0, 9);
                                        AdmissionStartTime := Format(AdmissionScheduleEntry."Admission Start Time", 0, 9);
                                        AdmissionEndTime := Format(AdmissionScheduleEntry."Admission End Time", 0, 9);
                                    end else begin
                                        Ticket.SetFilter("External Ticket No.", '=%1', TicketNumber);
                                        if (not (Ticket.FindFirst())) then
                                            Ticket.Init();
                                        ValidFrom := Format(Ticket."Valid From Date", 0, 9);
                                        ValidUntil := Format(Ticket."Valid To Date", 0, 9)
                                    end;
                                    TicketPrice.CalculateScheduleEntryPrice(tmpChangeRequest."Item No.", tmpChangeRequest."Variant Code", tmpChangeRequest."Admission Code", tmpChangeRequest."External Adm. Sch. Entry No.", Today(), Time(), BasePrice, AddonPrice);
                                    AdmissionPrice := BasePrice + AddonPrice;
                                end;
                            }
                        }
                    }

                    trigger OnAfterGetRecord()
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
        AdmissionPrice: Decimal;

    internal procedure SetChangeRequestId(Token: Text[100])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        TMTicketAdmissionBOM: Record "NPR TM Ticket Admission BOM";
        TMTicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
    begin
        Commit();
        if (tmpResult.IsTemporary) then
            tmpResult.DeleteAll();

        ChangeRequestToken := Token;

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindFirst();
        TMTicketAdmissionBOM.SetFilter("Item No.", '=%1', TicketReservationRequest."Item No.");
        TMTicketAdmissionBOM.SetFilter("Variant Code", '=%1', TicketReservationRequest."Variant Code");
        TMTicketAdmissionBOM.FindSet();
        repeat
            TicketReservationRequest2.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest2.SetRange("Admission Code", TMTicketAdmissionBOM."Admission Code");
            if TicketReservationRequest2.IsEmpty() then
                TMTicketRequestManager.POS_AppendToReservationRequest(Token, TicketReservationRequest."Receipt No.", TicketReservationRequest."Line No.", TicketReservationRequest."Item No.", TicketReservationRequest."Variant Code", TMTicketAdmissionBOM."Admission Code", TicketReservationRequest.Quantity, 0, TicketReservationRequest."External Member No.", TicketReservationRequest."Ext. Line Reference No.");
        until (TMTicketAdmissionBOM.Next() = 0);

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        TicketReservationRequest.FindSet();

        tmpResult."Entry No." := 1;
        tmpResult.TransferFields(TicketReservationRequest, false);
        tmpResult.Insert();

        repeat
            tmpChangeRequest.TransferFields(TicketReservationRequest, true);
            tmpChangeRequest.Insert();
        until (TicketReservationRequest.Next() = 0);



        ResponseCode := 'OK';
        ResponseMessage := '';
    end;

    internal procedure GetChangeRequest(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; ErrorMessage: Text): Boolean
    begin
        ErrorMessage := ResponseMessage;
        TmpTicketReservationRequest.Copy(tmpChangeRequest, true);

        exit(ResponseCode = 'OK');
    end;

    internal procedure SetError(ErrorMessage: Text)
    begin
        if (tmpResult.IsTemporary) then
            tmpResult.DeleteAll();

        tmpResult."Entry No." := 1;
        tmpResult.Insert();

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
    end;
}