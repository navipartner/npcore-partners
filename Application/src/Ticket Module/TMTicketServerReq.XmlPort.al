xmlport 6060123 "NPR TM Ticket Server Req."
{
    Caption = 'Ticket TicketServer Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseRequestPage = false;

    schema
    {
        textelement(ticket_orders)
        {
            tableelement(tmpticketreservationrequest; "NPR TM Ticket Reservation Req.")
            {
                XmlName = 'ticket_order';
                UseTemporary = true;

                fieldattribute(order_uid; TmpTicketReservationRequest."Session Token ID")
                {
                }
                tableelement(tmpticket; "NPR TM Ticket")
                {
                    LinkFields = "Ticket Reservation Entry No." = FIELD("Entry No.");
                    LinkTable = TmpTicketReservationRequest;
                    XmlName = 'ticket';
                    UseTemporary = true;
                    textattribute(ticket_uid)
                    {
                    }
                    fieldelement(barcode; TmpTicket."Ticket No. for Printing")
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
                    fieldelement(ticket_no; TmpTicket."No.")
                    {
                    }
                    textelement(language)
                    {
                    }
                    textelement(ticket_title)
                    {
                    }
                    fieldelement(purchased_date; TmpTicket."Document Date")
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
                    fieldelement(email; TmpTicketReservationRequest."Notification Address")
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
                    textelement(pincode)
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        Customer: Record Customer;
                        TicketType: Record "NPR TM Ticket Type";
                    begin

                        TicketType.Get(TmpTicket."Ticket Type Code");
                        visit_date := Format(TmpTicket."Valid From Date", 0, 9);
                        visit_end_date := Format(TmpTicket."Valid To Date", 0, 9);
                        ticket_type := TicketType."DIY Print Layout Code";

                        ticket_title := GetDescription(TmpTicket, '', TicketSetup.FieldNo(TicketSetup."Ticket Title"));
                        ticket_sub_title := GetDescription(TmpTicket, '', TicketSetup.FieldNo("Ticket Sub Title"));

                        ticket_name := GetDescription(TmpTicket, '', TicketSetup.FieldNo("Ticket Name"));
                        ticket_description := GetDescription(TmpTicket, '', TicketSetup.FieldNo("Ticket Description"));
                        ticket_full_description := GetDescription(TmpTicket, '', TicketSetup.FieldNo("Ticket Full Description"));
                        price := GetPrice(TmpTicket);

                        valid_from := Format(TmpTicket."Valid From Date", 0, 9);
                        valid_to := Format(TmpTicket."Valid To Date", 0, 9);

                        pincode := TmpTicketReservationRequest."Authorization Code";
                        ticket_uid := TmpTicket."External Ticket No.";
                        if (TmpTicketReservationRequest."Entry Type" = TmpTicketReservationRequest."Entry Type"::CHANGE) then
                            ticket_uid := STRSUBSTNO('%1-%2', TmpTicket."External Ticket No.", TmpTicket."Ticket Reservation Entry No.");

                        DetTicketAccessEntry.SetFilter("Ticket No.", '=%1', TmpTicket."No.");
                        DetTicketAccessEntry.SetFilter(Type, '=%1', DetTicketAccessEntry.Type::RESERVATION);
                        if (DetTicketAccessEntry.FindFirst()) then begin
                            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', DetTicketAccessEntry."External Adm. Sch. Entry No.");
                            if (AdmissionScheduleEntry.FindFirst()) then begin
                                visit_date := StrSubstNo('%1 %2', Format(AdmissionScheduleEntry."Admission Start Date", 0, 9), Format(AdmissionScheduleEntry."Admission Start Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));
                                visit_end_date := StrSubstNo('%1 %2', Format(AdmissionScheduleEntry."Admission End Date", 0, 9), Format(AdmissionScheduleEntry."Admission End Time", 0, '<Filler Character,0><Hours24,2>:<Minutes,2>:<Seconds,2>'));

                                ticket_sub_title := GetDescription(TmpTicket, AdmissionScheduleEntry."Admission Code", TicketSetup.FieldNo("Ticket Sub Title"));
                                TicketAccessEntry.SetFilter("Admission Code", '=%1', AdmissionScheduleEntry."Admission Code");
                            end;

                        end;

                        TicketAccessEntry.SetFilter("Ticket No.", '=%1', TmpTicket."No.");
                        TicketAccessEntry.FindFirst();
                        quantity := Format(TicketAccessEntry.Quantity, 0, 9);

                        if (TmpTicketReservationRequest."Customer No." <> '') then
                            if (Customer.Get(TmpTicketReservationRequest."Customer No.")) then
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
        GeneralLedgerSetup: Record "General Ledger Setup";
        TicketSetup: Record "NPR TM Ticket Setup";
        TicketAccessEntry: Record "NPR TM Ticket Access Entry";
        DetTicketAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";

    procedure SetRequestEntryNo(Token: Text[100]; MarkTicketAsPrinted: Boolean; var FailureReason: Text): Boolean
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketType: Record "NPR TM Ticket Type";
        Ticket: Record "NPR TM Ticket";
    begin

        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);

        if (not TicketReservationRequest.FindSet()) then begin
            FailureReason := 'Invalid Token.';
            exit(false);
        end;

        TicketSetup.Get();
        if (TicketSetup."Default Ticket Language" = '') then begin
            FailureReason := 'Ticket Setup."Default Ticket Language" must not be blank.';
            exit(false);
        end;

        language := TicketSetup."Default Ticket Language";
        GeneralLedgerSetup.Get();

        repeat
            TmpTicketReservationRequest.TransferFields(TicketReservationRequest, true);

            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                TmpTicketReservationRequest.Insert();

                repeat
                    TmpTicket.TransferFields(Ticket, true);
                    TicketType.Get(TmpTicket."Ticket Type Code");
                    if (TicketType."DIY Print Layout Code" = '') then begin
                        FailureReason := StrSubstNo('"DIY Print Layout Code" must not blank for "Ticket Type" %1.', TmpTicket."Ticket Type Code");
                        exit(false);
                    end;

                    if (TmpTicket.Insert()) then begin
                        Ticket."Printed Date" := Today();
                        if (MarkTicketAsPrinted) then
                            Ticket.Modify();
                    end;
                until (Ticket.Next() = 0);

            end;
        until (TicketReservationRequest.Next() = 0);

        exit(true);
    end;

    local procedure GetDescription(CurrentTicket: Record "NPR TM Ticket"; AdmissionCode: Code[20]; FieldNo: Integer) Description: Text
    var
        TicketType: Record "NPR TM Ticket Type";
        TicketBOM: Record "NPR TM Ticket Admission BOM";
        Admission: Record "NPR TM Admission";
        Item: Record Item;
        Variant: Record "Item Variant";
        MagentoStoreItem: Record "NPR Magento Store Item";
        DescriptionSelector: Option ITEM_DESC,ADM_DESC,TYPE_DESC,BOM_DESC,WEBSHOP_SHORT,WEBSHOP_FULL,VARIANT_DESC,BLANK;
        InStr: InStream;
    begin

        case FieldNo of
            TicketSetup.FieldNo("Ticket Title"):
                DescriptionSelector := TicketSetup."Ticket Title";
            TicketSetup.FieldNo("Ticket Sub Title"):
                DescriptionSelector := TicketSetup."Ticket Sub Title";
            TicketSetup.FieldNo("Ticket Name"):
                DescriptionSelector := TicketSetup."Ticket Name";
            TicketSetup.FieldNo("Ticket Description"):
                DescriptionSelector := TicketSetup."Ticket Description";
            TicketSetup.FieldNo("Ticket Full Description"):
                DescriptionSelector := TicketSetup."Ticket Full Description";
            else
                DescriptionSelector := DescriptionSelector::BLANK;
        end;

        TicketType.Get(CurrentTicket."Ticket Type Code");
        Item.Get(CurrentTicket."Item No.");

        if (not Variant.Get(CurrentTicket."Item No.", CurrentTicket."Variant Code")) then
            Variant.Init();

        TicketBOM.SetFilter("Item No.", '=%1', CurrentTicket."Item No.");
        TicketBOM.SetFilter("Variant Code", '=%1', CurrentTicket."Variant Code");

        if (AdmissionCode <> '') then
            TicketBOM.SetFilter("Admission Code", '=%1', AdmissionCode);

        if (AdmissionCode = '') then
            TicketBOM.SetFilter(Default, '=%1', true);

        if (not TicketBOM.FindFirst()) then
            TicketBOM.SetFilter(Default, '=%1', false);
        TicketBOM.FindFirst();

        Admission.Get(TicketBOM."Admission Code");

        if (not MagentoStoreItem.Get(Item."No.", TicketSetup."Store Code")) then
            MagentoStoreItem.Init();

        case DescriptionSelector of
            DescriptionSelector::ITEM_DESC:
                exit(Item.Description);
            DescriptionSelector::VARIANT_DESC:
                exit(Variant.Description);
            DescriptionSelector::ADM_DESC:
                exit(Admission.Description);
            DescriptionSelector::BOM_DESC:
                exit(TicketBOM.Description);
            DescriptionSelector::TYPE_DESC:
                exit(TicketType.Description);
            DescriptionSelector::WEBSHOP_SHORT:
                if (MagentoStoreItem."Webshop Short Desc. Enabled") then
                    if (MagentoStoreItem."Webshop Short Desc.".HasValue()) then begin
                        MagentoStoreItem.CalcFields("Webshop Short Desc.");
                        MagentoStoreItem."Webshop Short Desc.".CreateInStream(InStr);
                        InStr.Read(Description);
                        exit(Description);
                    end;
            DescriptionSelector::WEBSHOP_FULL:
                if (MagentoStoreItem."Webshop Description Enabled") then
                    if (MagentoStoreItem."Webshop Description".HasValue()) then begin
                        MagentoStoreItem.CalcFields("Webshop Description");
                        MagentoStoreItem."Webshop Description".CreateInStream(InStr);
                        InStr.Read(Description);
                        exit(Description);
                    end;
        end;

        exit('');
    end;

    local procedure GetPrice(TmpTicket: Record "NPR TM Ticket" temporary): Text
    var
        Item: Record Item;
    begin

        Item.Get(TmpTicket."Item No.");
        exit(StrSubstNo('%1 %2', Item."Unit Price", GeneralLedgerSetup."LCY Code"));

    end;
}

