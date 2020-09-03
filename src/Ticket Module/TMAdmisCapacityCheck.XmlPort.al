xmlport 6060113 "NPR TM Admis. Capacity Check"
{
    // TM1.24/TSA /20170824 CASE 287582 First Version
    // TM1.37/TSA /20180926 CASE 327324 Refactored to use "Event Arrival From Time"
    // #334163/JDH /20181108 CASE 334163 Adding missing Captions
    // TM1.39/NPKNAV/20190125  CASE 343941 Transport TM1.39 - 25 January 2019
    // TM1.41/TSA /20190411 CASE 351846 Fixed the "event arrival from time" bug
    // TM1.41/TSA/20190527  CASE 353981 Transport TM1.41 - 27 May 2019
    // TM1.45/TSA /20191121 CASE 378339 Added Sales and Event Arrival cut-off dates and times
    // TM1.45/TSA /20191210 CASE 380754 Added filter by admission code to get the current schedules and added some for data to response, including waitinglist info
    // TM1.46/TSA /20200203 CASE 387877 Added admission code and schedule code for easier grouping
    // TM1.47/TSA /20200427 CASE 402048 Added date as request option, use common code for sales determination
    // TM1.47/TSA /20200528 CASE 402048 Added TmpAdmScheduleEntryResponse."Admission End Date" and TmpAdmScheduleEntryResponse."Admission End Time" to response
    // TM1.48/TSA /20200629 CASE 411704 Added ticket capacity support

    Caption = 'Admission Capacity Check';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(admission_capacity)
        {
            textelement(request)
            {
                MaxOccurs = Once;
                tableelement(tmpadmscheduleentryrequest; "NPR TM Admis. Schedule Entry")
                {
                    XmlName = 'admission_schedule_entry';
                    UseTemporary = true;
                    fieldattribute(admission_code; TmpAdmScheduleEntryRequest."Admission Code")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(external_entry_no; TmpAdmScheduleEntryRequest."External Schedule Entry No.")
                    {
                        Occurrence = Optional;
                    }
                    fieldattribute(reference_date; TmpAdmScheduleEntryRequest."Admission Start Date")
                    {
                        Occurrence = Optional;
                    }
                    textattribute(externalitemno)
                    {
                        Occurrence = Optional;
                        XmlName = 'external_item_number';

                        trigger OnAfterAssignVariable()
                        begin
                            //-TM1.48 [411704]
                            if (externalItemNo <> '') then begin
                                if (gExternalItemNo <> '') and (gExternalItemNo <> externalItemNo) then
                                    Error('The external item number must be the same on all request lines.');

                                gExternalItemNo := externalItemNo;
                            end;
                            //+TM1.48 [411704]
                        end;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        RequestEntryNo += 1;
                        TmpAdmScheduleEntryRequest."Entry No." := RequestEntryNo;
                    end;
                }
            }
            textelement(reponse)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                tableelement(tmpadmscheduleentryresponse; "NPR TM Admis. Schedule Entry")
                {
                    XmlName = 'admission_schedule_entry';
                    UseTemporary = true;
                    fieldattribute(admission_code; TmpAdmScheduleEntryResponse."Admission Code")
                    {
                    }
                    fieldattribute(schedule_code; TmpAdmScheduleEntryResponse."Schedule Code")
                    {
                    }
                    fieldattribute(external_entry_no; TmpAdmScheduleEntryResponse."External Schedule Entry No.")
                    {
                    }
                    fieldattribute(start_date; TmpAdmScheduleEntryResponse."Admission Start Date")
                    {
                    }
                    fieldattribute(start_time; TmpAdmScheduleEntryResponse."Admission Start Time")
                    {
                    }
                    fieldattribute(end_date; TmpAdmScheduleEntryResponse."Admission End Date")
                    {
                    }
                    fieldattribute(end_time; TmpAdmScheduleEntryResponse."Admission End Time")
                    {
                    }
                    textattribute(responsestatus)
                    {
                        XmlName = 'status';

                        trigger OnBeforePassVariable()
                        begin
                            ResponseStatus := Format((CapacityStatusCode = 1), 0, 9);
                        end;
                    }
                    textattribute(allocationby)
                    {
                        XmlName = 'allocation_by';

                        trigger OnBeforePassVariable()
                        begin

                            case TmpAdmScheduleEntryResponse."Allocation By" of
                                TmpAdmScheduleEntryResponse."Allocation By"::CAPACITY:
                                    AllocationBy := 'capacity';
                                TmpAdmScheduleEntryResponse."Allocation By"::WAITINGLIST:
                                    AllocationBy := 'waitinglist';
                            end;
                        end;
                    }
                    textattribute(responseremaining)
                    {
                        XmlName = 'remaining';

                        trigger OnBeforePassVariable()
                        begin
                            ResponseRemaining := Format(RemainingCapacity, 0, 9);
                        end;
                    }
                    textattribute(responsemessage)
                    {
                        XmlName = 'message';

                        trigger OnBeforePassVariable()
                        begin
                            case CapacityStatusCode of
                                1:
                                    ResponseMessage := 'Ok.';
                                -1:
                                    ResponseMessage := 'Capacity exceeded.';
                                -2:
                                    ResponseMessage := 'The schedule does not allow admissions at this time.';
                                -3:
                                    ResponseMessage := 'Unexpected problem with capacity calculation, invalid parameters?';
                                -4:
                                    ResponseMessage := 'The external schedule id is invalid or all schedules have been cancelled.';
                                -5:
                                    ResponseMessage := 'The admission schedule indicated that admission is closed.';
                                else
                                    ResponseMessage := StrSubstNo('Capacity Status Code %1 does not have a dedicated message yet.', CapacityStatusCode);
                            end;
                        end;
                    }
                    textattribute(priceoption)
                    {
                        XmlName = 'price_option';
                    }
                    textattribute(amount)
                    {
                        XmlName = 'price_amount';
                    }
                    textattribute(percentage)
                    {
                        XmlName = 'price_percentage';
                    }
                    textattribute(includesvat)
                    {
                        XmlName = 'includes_vat';
                    }
                    fieldattribute(event_arrival_from_time; TmpAdmScheduleEntryResponse."Event Arrival From Time")
                    {
                    }
                    fieldattribute(event_arrival_until_time; TmpAdmScheduleEntryResponse."Event Arrival Until Time")
                    {
                    }
                    fieldattribute(sales_from_date; TmpAdmScheduleEntryResponse."Sales From Date")
                    {
                    }
                    fieldattribute(sales_from_time; TmpAdmScheduleEntryResponse."Sales From Time")
                    {
                    }
                    fieldattribute(sales_until_date; TmpAdmScheduleEntryResponse."Sales Until Date")
                    {
                    }
                    fieldattribute(sales_until_time; TmpAdmScheduleEntryResponse."Sales Until Time")
                    {
                    }

                    trigger OnAfterGetRecord()
                    var
                        MaxCapacity: Integer;
                        CapacityControl: Option;
                        Admission: Record "NPR TM Admission";
                        TicketManagement: Codeunit "NPR TM Ticket Management";
                        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                        AdmissionScheduleLines: Record "NPR TM Admis. Schedule Lines";
                        ItemNumber: Code[20];
                        VariantCode: Code[10];
                        ResolvingTable: Integer;
                    begin
                        with TmpAdmScheduleEntryResponse do begin

                            RemainingCapacity := 0;
                            CapacityStatusCode := 1;

                            if ("Admission Code" = '') then
                                CapacityStatusCode := -4;

                            if ("Schedule Code" = '') then
                                CapacityStatusCode := -4;

                            if ("Entry No." < 1) then
                                CapacityStatusCode := -4;

                            //-TM1.47 [402048]
                            if ("Admission Is" = "Admission Is"::CLOSED) then
                                CapacityStatusCode := -5;

                            //-TM1.48 [411704]
                            // IF (NOT TicketManagement.ValidateAdmSchEntryForSales (TmpAdmScheduleEntryResponse, '', '', TODAY, TIME, RemainingCapacity)) THEN
                            //   CapacityStatusCode := -1;
                            ItemNumber := '';
                            VariantCode := '';
                            if ("Schedule Code" <> '') then begin
                                // "Schedule Code" has been hi-jacked to store the item number per request line
                                TicketRequestManager.TranslateBarcodeToItemVariant(gExternalItemNo, ItemNumber, VariantCode, ResolvingTable);
                            end;

                            if (not TicketManagement.ValidateAdmSchEntryForSales(TmpAdmScheduleEntryResponse, ItemNumber, VariantCode, Today, Time, RemainingCapacity)) then
                                CapacityStatusCode := -1;
                            //+TM1.48 [411704]

                            //+TM1.47 [402048]

                            if (CapacityStatusCode <> 1) then
                                exit;

                            SetCapacityStatusCode();

                            //-TM1.47 [402048]
                            //  IF (TicketManagement.GetMaxCapacity ("Admission Code", "Schedule Code", "Entry No.", MaxCapacity, CapacityControl)) THEN BEGIN
                            //    CALCFIELDS ("Open Reservations", "Open Admitted", "Initial Entry");
                            //
                            //    CASE CapacityControl OF
                            //      Admission."Capacity Control"::ADMITTED :
                            //        BEGIN
                            //          RemainingCapacity := MaxCapacity - "Open Admitted" - "Open Reservations";
                            //          SetCapacityStatusCode ();
                            //        END;
                            //
                            //      Admission."Capacity Control"::FULL :
                            //        BEGIN
                            //          RemainingCapacity :=  MaxCapacity - "Open Admitted" - "Open Reservations";
                            //          SetCapacityStatusCode ();
                            //        END;
                            //
                            //      Admission."Capacity Control"::NONE :
                            //        BEGIN
                            //          RemainingCapacity :=  -1;
                            //          CapacityStatusCode := 1;
                            //        END;
                            //
                            //      Admission."Capacity Control"::SALES :
                            //        BEGIN
                            //          RemainingCapacity := MaxCapacity - "Initial Entry";
                            //          SetCapacityStatusCode ();
                            //        END;
                            //
                            //      //-TM1.45 [378339]
                            //      Admission."Capacity Control"::SEATING :
                            //        BEGIN
                            //          RemainingCapacity := MaxCapacity - "Open Admitted" - "Open Reservations";
                            //          SetCapacityStatusCode ();
                            //        END;
                            //      //+TM1.45 [378339]
                            //
                            //    END;
                            //    //-TM1.37 [327324]
                            //    //    IF ("Admission Start Date" = TODAY) THEN BEGIN
                            //    //      IF ("Bookable Passed Start (Secs)" = 0) AND ("Admission End Time"  < TIME) THEN BEGIN
                            //    //        RemainingCapacity := 0;
                            //    //        CapacityStatusCode := -2
                            //    //      END;
                            //    //      IF ("Bookable Passed Start (Secs)" <> 0) AND (("Admission Start Time" + "Bookable Passed Start (Secs)"*1000) < TIME) THEN BEGIN
                            //    //        RemainingCapacity := 0;
                            //    //        CapacityStatusCode := -2
                            //    //      END;
                            //    //    END;
                            //
                            //    IF ("Admission Start Date" = TODAY) THEN BEGIN
                            //      IF (("Event Arrival From Time" = 0T) AND ("Admission End Time" < TIME)) THEN BEGIN
                            //        RemainingCapacity := 0;
                            //        CapacityStatusCode := -2;
                            //      END;
                            //      //-TM1.41 [351846]
                            //      // IF ("Event Arrival From Time" <> 0T) AND (("Event Arrival From Time" < TIME)) THEN BEGIN
                            //      //   RemainingCapacity := 0;
                            //      //  CapacityStatusCode := -2;
                            //      // END;
                            //      IF ("Event Arrival From Time" <> 0T) AND ((TIME < "Event Arrival From Time")) THEN BEGIN
                            //        RemainingCapacity := 0;
                            //        CapacityStatusCode := -2;
                            //      END;
                            //      IF ("Event Arrival Until Time" <> 0T) AND ((TIME > "Event Arrival Until Time")) THEN BEGIN
                            //        RemainingCapacity := 0;
                            //        CapacityStatusCode := -2;
                            //      END;
                            //      //+TM1.41 [351846]
                            //
                            //    END;
                            //    //+TM1.37 [327324]
                            //
                            //    IF ("Admission Start Date" < TODAY) THEN BEGIN
                            //      RemainingCapacity := 0;
                            //      CapacityStatusCode := -2;
                            //    END;
                            //
                            //    IF ("Admission Is" = "Admission Is"::CLOSED) THEN BEGIN
                            //      RemainingCapacity := 0;
                            //      CapacityStatusCode := -5;
                            //    END;
                            //
                            //  END ELSE BEGIN
                            //    RemainingCapacity := 0;
                            //    CapacityStatusCode := -3;
                            //  END;
                            //+TM1.47 [402048]

                            //-TM1.41 [353981]
                            PriceOption := '';
                            Amount := '';
                            Percentage := '';
                            IncludesVAT := '';
                            if (AdmissionScheduleLines.Get("Admission Code", "Schedule Code")) then begin
                                if (AdmissionScheduleLines."Price Scope" in [AdmissionScheduleLines."Price Scope"::API, AdmissionScheduleLines."Price Scope"::API_POS_M2]) then begin
                                    case AdmissionScheduleLines."Pricing Option" of
                                        AdmissionScheduleLines."Pricing Option"::NA:
                                            PriceOption := '';
                                        AdmissionScheduleLines."Pricing Option"::FIXED:
                                            PriceOption := 'fixed_amount';
                                        AdmissionScheduleLines."Pricing Option"::RELATIVE:
                                            PriceOption := 'relative_amount';
                                        AdmissionScheduleLines."Pricing Option"::PERCENT:
                                            PriceOption := 'percentage'
                                    end;
                                    Amount := Format(AdmissionScheduleLines.Amount, 0, 9);
                                    Percentage := Format(AdmissionScheduleLines.Percentage, 0, 9);
                                    IncludesVAT := Format(AdmissionScheduleLines."Amount Includes VAT", 0, 9);
                                end;
                            end;
                            //+TM1.41 [353981]

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
        RequestEntryNo: Integer;
        RemainingCapacity: Integer;
        CapacityStatusCode: Integer;
        gExternalItemNo: Code[20];

    procedure AddResponse()
    begin
        if (not TmpAdmScheduleEntryRequest.FindSet()) then
            exit;

        repeat
            TmpAdmScheduleEntryResponse.TransferFields(TmpAdmScheduleEntryRequest, true);
            GetEntry(TmpAdmScheduleEntryResponse);
        //-TM1.45 [380754]
        // TmpAdmScheduleEntryResponse.INSERT ();
        //+TM1.45 [380754]

        until (TmpAdmScheduleEntryRequest.Next() = 0);
    end;

    local procedure GetEntry(var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        StartDate: Date;
    begin

        //-TM1.45 [380754]
        // IF (TmpAdmissionScheduleEntry."External Schedule Entry No." < 1) THEN
        //  EXIT;
        //
        // AdmissionScheduleEntry.SETFILTER ("External Schedule Entry No.", '=%1', TmpAdmissionScheduleEntry."External Schedule Entry No.");
        // AdmissionScheduleEntry.SETFILTER (Cancelled, '=%1', FALSE);
        // IF (NOT AdmissionScheduleEntry.FINDFIRST ()) THEN
        //  EXIT;
        //
        // TmpAdmissionScheduleEntry.TRANSFERFIELDS (AdmissionScheduleEntry, TRUE);

        if (TmpAdmissionScheduleEntry."Admission Code" = '') then begin
            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TmpAdmissionScheduleEntry."External Schedule Entry No.");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

            TmpAdmissionScheduleEntry.Init;
            if (AdmissionScheduleEntry.FindFirst()) then
                TmpAdmissionScheduleEntry.TransferFields(AdmissionScheduleEntry, true);

            TmpAdmissionScheduleEntry.Insert();
            exit;
        end;

        AdmissionScheduleEntry.SetFilter("Admission Code", TmpAdmissionScheduleEntry."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '>=%1', Today);

        //-TM1.47 [402048]
        if (TmpAdmissionScheduleEntry."Admission Start Date" > 0D) then begin
            if (TmpAdmissionScheduleEntry."Admission Start Date" < Today) then begin
                CapacityStatusCode := -3;
                exit;
            end;
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', TmpAdmissionScheduleEntry."Admission Start Date");
        end;
        //+TM1.47 [402048]

        AdmissionScheduleEntry.SetFilter("Visibility On Web", '=%1', AdmissionScheduleEntry."Visibility On Web"::VISIBLE);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                TmpAdmissionScheduleEntry.TransferFields(AdmissionScheduleEntry, true);
                if (not TmpAdmissionScheduleEntry.Insert()) then; //-+TM1.47 [402048]
            until (AdmissionScheduleEntry.Next() = 0);
        end;
        //+TM1.45 [380754]
    end;

    local procedure SetCapacityStatusCode()
    begin
        CapacityStatusCode := 1;
        if (RemainingCapacity < 1) then begin
            RemainingCapacity := 0;
            CapacityStatusCode := -1;
        end;
    end;
}

