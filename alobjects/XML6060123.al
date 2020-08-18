xmlport 6060123 "TM Ticket TicketServer Request"
{
    // TM1.26/NPKNAV/20171122  CASE 285601-01 Transport TM1.26 - 22 November 2017
    // TM1.35/TSA /20180712 CASE 320783 Added Elements Valid From and Valid To
    // TM1.35/TSA /20180712 CASE 320783 Changed to XML date / time format
    // TM1.43/TSA /20191004 CASE 367471 Refactored and reworked message signatures to be able to return fault reason
    // TM1.45/TSA /20191118 CASE 352050 Assigned the name field with customer name when customer is assigned
    // TM1.48/TSA /20200623 CASE 399259 Added ticket_name, ticket_description, ticket_full_description

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
                    textelement(ticket_name)
                    {
                    }
                    textelement(ticket_description)
                    {
                    }
                    textelement(ticket_full_description)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        Customer: Record Customer;
                        TicketType: Record "TM Ticket Type";
                    begin

                        //-TM1.48 [399259] Refactored
                        //
                        // GeneralLedgerSetup.GET ();
                        //
                        // //-TM1.43 [367471]
                        // // TicketSetup.GET ();
                        // // TicketSetup.TESTFIELD ("Default Ticket Language");
                        // //
                        // // TicketType.GET (TmpTicket."Ticket Type Code");
                        // // TicketType.TESTFIELD ("DIY Print Layout Code");
                        //
                        // TicketType.GET (TmpTicket."Ticket Type Code");
                        // //+TM1.43 [367471]
                        //
                        // Item.GET (TmpTicket."Item No.");
                        //
                        // TicketBOM.SETFILTER ("Item No.", '=%1', TmpTicket."Item No.");
                        // TicketBOM.SETFILTER ("Variant Code", '=%1', TmpTicket."Variant Code");
                        // TicketBOM.SETFILTER (Default, '=%1', TRUE);
                        // IF (NOT TicketBOM.FINDFIRST ()) THEN
                        //  TicketBOM.SETFILTER (Default, '=%1', FALSE);
                        // TicketBOM.FINDFIRST ();
                        // Admission.GET (TicketBOM."Admission Code");
                        //
                        // // default
                        // language := TicketSetup."Default Ticket Language";
                        //
                        // //-TM1.35 [320783]
                        // //visit_date := STRSUBSTNO ('%1 %2', TmpTicket."Valid From Date", TmpTicket."Valid From Time");
                        // //visit_end_date := STRSUBSTNO ('%1 %2', TmpTicket."Valid To Date", TmpTicket."Valid To Time");
                        // visit_date := FORMAT (TmpTicket."Valid From Date", 0, 9);
                        // visit_end_date := FORMAT (TmpTicket."Valid To Date", 0,9);
                        // //+TM1.35 [320783]
                        //
                        // ticket_title := Item.Description;
                        // price := STRSUBSTNO ('%1 %2', Item."Unit Price", GeneralLedgerSetup."LCY Code");
                        //
                        // //-TM1.35 [320783]
                        // //valid_from := FORMAT (CREATEDATETIME (TmpTicket."Valid From Date", TmpTicket."Valid From Time"), 0, 9);
                        // //valid_to  := FORMAT (CREATEDATETIME (TmpTicket."Valid To Date", TmpTicket."Valid To Time"), 0, 9);
                        // valid_from := FORMAT (TmpTicket."Valid From Date", 0, 9);
                        // valid_to  := FORMAT (TmpTicket."Valid To Date", 0, 9);
                        //
                        // //+TM1.35 [320783]
                        //
                        // DetTicketAccessEntry.SETFILTER ("Ticket No.", '=%1', TmpTicket."No.");
                        // DetTicketAccessEntry.SETFILTER (Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
                        // IF (DetTicketAccessEntry.FINDFIRST ()) THEN BEGIN
                        //  AdmissionScheduleEntry.SETFILTER ("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                        //  IF (AdmissionScheduleEntry.FINDFIRST ()) THEN BEGIN
                        //
                        //    //-TM1.35 [320783]
                        //    //visit_date := STRSUBSTNO ('%1 %2', AdmissionScheduleEntry."Admission Start Date", AdmissionScheduleEntry."Admission Start Time");
                        //    //visit_end_date := STRSUBSTNO ('%1 %2', AdmissionScheduleEntry."Admission End Date", AdmissionScheduleEntry."Admission End Time");
                        //    visit_date := STRSUBSTNO ('%1 %2', FORMAT (AdmissionScheduleEntry."Admission Start Date", 0, 9), FORMAT (AdmissionScheduleEntry."Admission Start Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));
                        //    visit_end_date := STRSUBSTNO ('%1 %2', FORMAT (AdmissionScheduleEntry."Admission End Date", 0, 9), FORMAT (AdmissionScheduleEntry."Admission End Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));
                        //    //+TM1.35 [320783]
                        //
                        //    Admission.GET (AdmissionScheduleEntry."Admission Code");
                        //  END;
                        // END;
                        //
                        // TicketAccessEntry.SETFILTER ("Ticket No.", '=%1', TmpTicket."No.");
                        // TicketAccessEntry.SETFILTER ("Admission Code", '=%1', Admission."Admission Code");
                        // TicketAccessEntry.FINDFIRST ();
                        // TmpTicketReservationRequest.Quantity := TicketAccessEntry.Quantity;
                        //
                        // ticket_sub_title := Admission.Description;
                        // quantity := FORMAT (TmpTicketReservationRequest.Quantity, 0, 9);
                        //
                        // //-TM1.45 [352050]
                        // IF (TmpTicketReservationRequest."Customer No." <> '') THEN
                        //  IF (Customer.GET (TmpTicketReservationRequest."Customer No.")) THEN
                        //    name := Customer.Name;
                        // //+TM1.45 [352050]


                        TicketType.Get (TmpTicket."Ticket Type Code");
                        visit_date := Format (TmpTicket."Valid From Date", 0, 9);
                        visit_end_date := Format (TmpTicket."Valid To Date", 0,9);
                        ticket_type := TicketType."DIY Print Layout Code";

                        ticket_title := GetDescription (TmpTicket, '', TicketSetup.FieldNo (TicketSetup."Ticket Title"));
                        ticket_sub_title := GetDescription (TmpTicket, '', TicketSetup.FieldNo ("Ticket Sub Title"));

                        ticket_name := GetDescription (TmpTicket, '', TicketSetup.FieldNo ("Ticket Name"));
                        ticket_description := GetDescription (TmpTicket, '', TicketSetup.FieldNo ("Ticket Description"));
                        ticket_full_description := GetDescription (TmpTicket, '', TicketSetup.FieldNo ("Ticket Full Description"));
                        price := GetPrice (TmpTicket);

                        valid_from := Format (TmpTicket."Valid From Date", 0, 9);
                        valid_to  := Format (TmpTicket."Valid To Date", 0, 9);


                        DetTicketAccessEntry.SetFilter ("Ticket No.", '=%1', TmpTicket."No.");
                        DetTicketAccessEntry.SetFilter (Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
                        if (DetTicketAccessEntry.FindFirst ()) then begin
                          AdmissionScheduleEntry.SetFilter ("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                          if (AdmissionScheduleEntry.FindFirst ()) then begin
                            visit_date := StrSubstNo ('%1 %2', Format (AdmissionScheduleEntry."Admission Start Date", 0, 9), Format (AdmissionScheduleEntry."Admission Start Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));
                            visit_end_date := StrSubstNo ('%1 %2', Format (AdmissionScheduleEntry."Admission End Date", 0, 9), Format (AdmissionScheduleEntry."Admission End Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));

                            ticket_sub_title := GetDescription (TmpTicket, AdmissionScheduleEntry."Admission Code", TicketSetup.FieldNo ("Ticket Sub Title"));
                            TicketAccessEntry.SetFilter ("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                          end;

                        end;

                        TicketAccessEntry.SetFilter ("Ticket No.", '=%1', TmpTicket."No.");
                        TicketAccessEntry.FindFirst ();
                        quantity := Format (TicketAccessEntry.Quantity, 0, 9);

                        if (TmpTicketReservationRequest."Customer No." <> '') then
                          if (Customer.Get (TmpTicketReservationRequest."Customer No.")) then
                            name := Customer.Name;
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
        TicketAccessEntry: Record "TM Ticket Access Entry";
        DetTicketAccessEntry: Record "TM Det. Ticket Access Entry";
        AdmissionScheduleEntry: Record "TM Admission Schedule Entry";
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        DefaultAdmissionCode: Code[20];

    procedure SetRequestEntryNo(Token: Text[100];MarkTicketAsPrinted: Boolean;var FailureReason: Text): Boolean
    var
        TicketReservationRequest: Record "TM Ticket Reservation Request";
        TicketType: Record "TM Ticket Type";
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
        //-TM1.48 [399259]
        language := TicketSetup."Default Ticket Language";

        GeneralLedgerSetup.Get ();
        //+TM1.48 [399259]

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

    local procedure GetDescription(CurrentTicket: Record "TM Ticket";AdmissionCode: Code[20];FieldNo: Integer) Description: Text
    var
        TicketType: Record "TM Ticket Type";
        TicketBOM: Record "TM Ticket Admission BOM";
        Admission: Record "TM Admission";
        Item: Record Item;
        Variant: Record "Item Variant";
        MagentoStoreItem: Record "Magento Store Item";
        DescriptionSelector: Option ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK;
        InStr: InStream;
    begin

        //-TM1.48 [399259]
        case FieldNo of
          TicketSetup.FieldNo ("Ticket Title")            : DescriptionSelector := TicketSetup."Ticket Title";
          TicketSetup.FieldNo ("Ticket Sub Title")        : DescriptionSelector := TicketSetup."Ticket Sub Title";
          TicketSetup.FieldNo ("Ticket Name")             : DescriptionSelector := TicketSetup."Ticket Name";
          TicketSetup.FieldNo ("Ticket Description")      : DescriptionSelector := TicketSetup."Ticket Description";
          TicketSetup.FieldNo ("Ticket Full Description") : DescriptionSelector := TicketSetup."Ticket Full Description";
        else
          DescriptionSelector := DescriptionSelector::BLANK;
        end;

        TicketType.Get (CurrentTicket."Ticket Type Code");
        Item.Get (CurrentTicket."Item No.");

        if (not Variant.Get (CurrentTicket."Item No.", CurrentTicket."Variant Code")) then
          Variant.Init ();

        TicketBOM.SetFilter ("Item No.", '=%1', CurrentTicket."Item No.");
        TicketBOM.SetFilter ("Variant Code", '=%1', CurrentTicket."Variant Code");

        if (AdmissionCode <> '') then
          TicketBOM.SetFilter ("Admission Code", '=%1', AdmissionCode);

        if (AdmissionCode = '') then
          TicketBOM.SetFilter (Default, '=%1', true);

        if (not TicketBOM.FindFirst ()) then
          TicketBOM.SetFilter (Default, '=%1', false);
        TicketBOM.FindFirst ();

        Admission.Get (TicketBOM."Admission Code");

        if (not MagentoStoreItem.Get (Item."No.", TicketSetup."Store Code")) then
          MagentoStoreItem.Init ();

        case DescriptionSelector of
          DescriptionSelector::ITEM_DESC    : exit (Item.Description);
          DescriptionSelector::VARIANT_DESC : exit (Variant.Description);
          DescriptionSelector::ADM_DESC     : exit (Admission.Description);
          DescriptionSelector::BOM_DESC     : exit (TicketBOM.Description);
          DescriptionSelector::TYPE_DESC    : exit (TicketType.Description);
          DescriptionSelector::WEBSHOP_SHORT :
            if (MagentoStoreItem."Webshop Short Desc. Enabled") then
              if (MagentoStoreItem."Webshop Short Desc.".HasValue ()) then begin
                MagentoStoreItem.CalcFields ("Webshop Short Desc.");
                MagentoStoreItem."Webshop Short Desc.".CreateInStream (InStr);
                InStr.Read (Description);
                exit (Description);
              end;
          DescriptionSelector::WEBSHOP_FULL :
            if (MagentoStoreItem."Webshop Description Enabled") then
              if (MagentoStoreItem."Webshop Description".HasValue ()) then begin
                MagentoStoreItem.CalcFields ("Webshop Description");
                MagentoStoreItem."Webshop Description".CreateInStream (InStr);
                InStr.Read (Description);
                exit (Description);
              end;
        end;

        exit ('');
        //+TM1.48 [399259]
    end;

    local procedure GetPrice(TmpTicket: Record "TM Ticket" temporary): Text
    var
        Item: Record Item;
    begin

        //-TM1.48 [399259]
        Item.Get (TmpTicket."Item No.");
        exit (StrSubstNo ('%1 %2', Item."Unit Price", GeneralLedgerSetup."LCY Code"));
        //+TM1.48 [399259]
    end;
}

