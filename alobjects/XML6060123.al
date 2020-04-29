xmlport 6060123 "TM Ticket TicketServer Request"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.35/TSA /20180712 CASE 320783 Added Elements Valid From and Valid To
    // TM1.35/TSA /20180712 CASE 320783 Changed to XML date / time format
    // TM1.43/TSA /20191004 CASE 367471 Refactored and reworked message signatures to be able to return fault reason
    // TM1.45/TSA /20191118 CASE 352050 Assigned the name field with customer name when customer is assigned

    Caption = 'Ticket TicketServer Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseRequestPage = false;

    schema
    {
        textelement(ticket_orders)
        {
            tableelement(tmpticketreservationrequest;"TM Ticket Reservation Request")
            {
                XmlName = 'ticket_order';
                UseTemporary = true;
                fieldattribute(order_uid;TmpTicketReservationRequest."Session Token ID")
                {
                }
                tableelement(tmpticket;"TM Ticket")
                {
                    LinkFields = "Ticket Reservation Entry No."=FIELD("Entry No.");
                    LinkTable = TmpTicketReservationRequest;
                    XmlName = 'ticket';
                    UseTemporary = true;
                    fieldattribute(ticket_uid;TmpTicket."External Ticket No.")
                    {
                    }
                    fieldelement(barcode;TmpTicket."Ticket No. for Printing")
                    {

                        trigger OnBeforePassField()
                        begin
                            if (TmpTicket."Ticket No. for Printing" = '') then
                              TmpTicket."Ticket No. for Printing" := TmpTicket."External Ticket No.";
                        end;
                    }
                    textelement(ticket_type)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            ticket_type := TicketType."DIY Print Layout Code";
                        end;
                    }
                    fieldelement(ticket_no;TmpTicket."No.")
                    {
                    }
                    textelement(language)
                    {
                    }
                    textelement(ticket_title)
                    {

                        trigger OnBeforePassVariable()
                        var
                            Item: Record Item;
                        begin
                        end;
                    }
                    fieldelement(purchased_date;TmpTicket."Document Date")
                    {
                    }
                    textelement(quantity)
                    {
                    }
                    textelement(price)
                    {
                    }
                    textelement(name)
                    {
                    }
                    fieldelement(email;TmpTicketReservationRequest."Notification Address")
                    {
                    }
                    textelement(visit_date)
                    {
                    }
                    textelement(visit_end_date)
                    {
                    }
                    textelement(ticket_sub_title)
                    {
                    }
                    textelement(price_with_fee)
                    {
                    }
                    textelement(valid_from)
                    {
                    }
                    textelement(valid_to)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        Customer: Record Customer;
                    begin

                        GeneralLedgerSetup.Get ();

                        //-TM1.43 [367471]
                        // TicketSetup.GET ();
                        // TicketSetup.TESTFIELD ("Default Ticket Language");
                        //
                        // TicketType.GET (TmpTicket."Ticket Type Code");
                        // TicketType.TESTFIELD ("DIY Print Layout Code");

                        TicketType.Get (TmpTicket."Ticket Type Code");
                        //+TM1.43 [367471]

                        Item.Get (TmpTicket."Item No.");

                        TicketBOM.SetFilter ("Item No.", '=%1', TmpTicket."Item No.");
                        TicketBOM.SetFilter ("Variant Code", '=%1', TmpTicket."Variant Code");
                        TicketBOM.SetFilter (Default, '=%1', true);
                        if (not TicketBOM.FindFirst ()) then
                          TicketBOM.SetFilter (Default, '=%1', false);
                        TicketBOM.FindFirst ();
                        Admission.Get (TicketBOM."Admission Code");

                        // default
                        language := TicketSetup."Default Ticket Language";

                        //-TM1.35 [320783]
                        //visit_date := STRSUBSTNO ('%1 %2', TmpTicket."Valid From Date", TmpTicket."Valid From Time");
                        //visit_end_date := STRSUBSTNO ('%1 %2', TmpTicket."Valid To Date", TmpTicket."Valid To Time");
                        visit_date := Format (TmpTicket."Valid From Date", 0, 9);
                        visit_end_date := Format (TmpTicket."Valid To Date", 0,9);
                        //+TM1.35 [320783]

                        ticket_title := Item.Description;
                        price := StrSubstNo ('%1 %2', Item."Unit Price", GeneralLedgerSetup."LCY Code");

                        //-TM1.35 [320783]
                        //valid_from := FORMAT (CREATEDATETIME (TmpTicket."Valid From Date", TmpTicket."Valid From Time"), 0, 9);
                        //valid_to  := FORMAT (CREATEDATETIME (TmpTicket."Valid To Date", TmpTicket."Valid To Time"), 0, 9);
                        valid_from := Format (TmpTicket."Valid From Date", 0, 9);
                        valid_to  := Format (TmpTicket."Valid To Date", 0, 9);

                        //+TM1.35 [320783]

                        DetTicketAccessEntry.SetFilter ("Ticket No.", '=%1', TmpTicket."No.");
                        DetTicketAccessEntry.SetFilter (Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
                        if (DetTicketAccessEntry.FindFirst ()) then begin
                          AdmissionScheduleEntry.SetFilter ("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                          if (AdmissionScheduleEntry.FindFirst ()) then begin

                            //-TM1.35 [320783]
                            //visit_date := STRSUBSTNO ('%1 %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
                            //visit_end_date := STRSUBSTNO ('%1 %2', AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time");
                            visit_date := StrSubstNo ('%1 %2', Format (AdmissionScheduleEntry."Admission Start Date", 0, 9), Format (AdmissionScheduleEntry."Admission Start Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));
                            visit_end_date := StrSubstNo ('%1 %2', Format (AdmissionScheduleEntry."Admission End Date", 0, 9), Format (AdmissionScheduleEntry."Admission End Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));
                            //+TM1.35 [320783]

                            Admission.Get (AdmissionScheduleEntry."Admission Code");
                          end;
                        end;

                        TicketAccessEntry.SetFilter ("Ticket No.", '=%1', TmpTicket."No.");
                        TicketAccessEntry.SetFilter ("Admission Code", '=%1', Admission."Admission Code");
                        TicketAccessEntry.FindFirst ();
                        TmpTicketReservationRequest.Quantity := TicketAccessEntry.Quantity;

                        ticket_sub_title := Admission.Description;
                        quantity := Format (TmpTicketReservationRequest.Quantity, 0, 9);

                        //-TM1.45 [352050]
                        if (TmpTicketReservationRequest."Customer No." <> '') then
                          if (Customer.Get (TmpTicketReservationRequest."Customer No.")) then
                            name := Customer.Name;
                        //+TM1.45 [352050]
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
        TicketManagement: Codeunit "TM Ticket Management";
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketSetup: Record "TM Ticket Setup";
        TicketType: Record "TM Ticket Type";
        TicketBOM: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        Item: Record Item;
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        DefaultAdmissionCode: Code[20];

    procedure SetRequestEntryNo(Token: Text[100];MarkTicketAsPrinted: Boolean;var FailureReason: Text): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        Ticket: Record "TM Ticket";
    begin

        TicketReservationRequest.SetFilter ("Session Token ID", '=%1', Token);
        //-TM1.43 [367471]
        // IF (NOT TicketReservationRequest.FINDSET ()) THEN
        //  EXIT;

        if (not TicketReservationRequest.FindSet ()) then begin
          FailureReason := 'Invalid Token.';
          exit (false);
        end;

        TicketSetup.Get ();
        if (TicketSetup."Default Ticket Language" = '') then begin
          FailureReason := 'Ticket Setup."Default Ticket Language" must not be blank.';
          exit (false);
        end;


        repeat
          TmpTicketReservationRequest.TransferFields (TicketReservationRequest, true);

          Ticket.SetFilter ("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
          if (Ticket.FindSet ()) then begin
            TmpTicketReservationRequest.Insert ();

            repeat
              TmpTicket.TransferFields (Ticket, true);
              //-TM1.43 [367471]
              TicketType.Get (TmpTicket."Ticket Type Code");
              if (TicketType."DIY Print Layout Code" = '') then begin
                FailureReason := StrSubstNo ('"DIY Print Layout Code" must not blank for "Ticket Type" %1.', TmpTicket."Ticket Type Code");
                exit (false);
              end;
              //+TM1.43 [367471]

              if (TmpTicket.Insert()) then begin
                Ticket."Printed Date" := Today;
                if (MarkTicketAsPrinted) then
                  Ticket.Modify ();
              end;
            until (Ticket.Next () = 0);

          end;
        until (TicketReservationRequest.Next () = 0);

        //-TM1.43 [367471]
        exit (true);
        //+TM1.43 [367471]
    end;
}

