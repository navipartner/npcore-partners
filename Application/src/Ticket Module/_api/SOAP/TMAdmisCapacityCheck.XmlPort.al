xmlport 6060113 "NPR TM Admis. Capacity Check"
{
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
                            if (externalItemNo <> '') then begin
                                if (gExternalItemNo <> '') and (gExternalItemNo <> externalItemNo) then
                                    Error('The external item number must be the same on all request lines.');

                                gExternalItemNo := externalItemNo;
                            end;
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
                            ResponseStatus := Format((CapacityStatusCode >= 1), 0, 9);
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
                                6:
                                    ResponseMessage := _CalendarExceptionText;
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
                                -6:
                                    ResponseMessage := _CalendarExceptionText;
                                else
                                    ResponseMessage := StrSubstNo(ResponseLbl, CapacityStatusCode);
                            end;
                        end;
                    }
                    textattribute(priceoption)
                    {
                        XmlName = 'price_option';
                        trigger OnBeforePassVariable()
                        begin
                            priceoption := PriceOption;
                        end;
                    }
                    textattribute(amount)
                    {
                        XmlName = 'price_amount';
                        trigger OnBeforePassVariable()
                        begin
                            amount := Amount;
                        end;
                    }
                    textattribute(percentage)
                    {
                        XmlName = 'price_percentage';
                        trigger OnBeforePassVariable()
                        begin
                            percentage := Percentage;
                        end;
                    }
                    textattribute(includesvat)
                    {
                        XmlName = 'includes_vat';
                        trigger OnBeforePassVariable()
                        begin
                            includesvat := IncludesVAT;
                        end;
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
                    textattribute(admission_price)
                    {
                        XmlName = 'admission_price';
                        trigger OnBeforePassVariable()
                        begin
                            admission_price := Format(AdmissionPrice, 0, 9);
                        end;
                    }

                    trigger OnAfterGetRecord()
                    var
                        TicketManagement: Codeunit "NPR TM Ticket Management";
                        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
                        TicketPrice: Codeunit "NPR TM Dynamic Price";
                        PriceRule: Record "NPR TM Dynamic Price Rule";
                        ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
                        ItemNumber: Code[20];
                        VariantCode: Code[10];
                        ResolvingTable: Integer;
                        NonWorking: Boolean;
                        BasePrice, AddonPrice : Decimal;
                        TimeHelper: Codeunit "NPR TM TimeHelper";
                        LocalDateTime: DateTime;
                        LocalDate: Date;
                        LocalTime: Time;
                    begin

                        RemainingCapacity := 0;
                        CapacityStatusCode := 1;
                        AdmissionPrice := 0;

                        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(TmpAdmScheduleEntryResponse."Admission Code");
                        LocalDate := DT2Date(LocalDateTime);
                        LocalTime := DT2Time(LocalDateTime);

                        TicketPrice.CalculateScheduleEntryPrice(gExternalItemNo, '', TmpAdmScheduleEntryResponse."Admission Code", TmpAdmScheduleEntryResponse."External Schedule Entry No.", LocalDate, LocalTime, BasePrice, AddonPrice);
                        AdmissionPrice := BasePrice + AddonPrice;

                        if (TmpAdmScheduleEntryResponse."Admission Code" = '') then
                            CapacityStatusCode := -4;

                        if (TmpAdmScheduleEntryResponse."Schedule Code" = '') then
                            CapacityStatusCode := -4;

                        if (TmpAdmScheduleEntryResponse."Entry No." < 1) then
                            CapacityStatusCode := -4;

                        if (TmpAdmScheduleEntryResponse."Admission Is" = TmpAdmScheduleEntryResponse."Admission Is"::CLOSED) then
                            CapacityStatusCode := -5;

                        ItemNumber := '';
                        VariantCode := '';
                        if (TmpAdmScheduleEntryResponse."Schedule Code" <> '') then begin

                            TicketRequestManager.TranslateBarcodeToItemVariant(gExternalItemNo, ItemNumber, VariantCode, ResolvingTable);
                        end;

                        if (not TicketManagement.ValidateAdmSchEntryForSales(TmpAdmScheduleEntryResponse, ItemNumber, VariantCode, LocalDate, LocalTime, ReasonCode, RemainingCapacity)) then begin
                            CapacityStatusCode := -1;
                            if (ReasonCode = ReasonCode::ScheduleExceedTicketDuration) then
                                currXMLport.Skip();
                        end;

                        TicketManagement.CheckTicketBaseCalendar(TmpAdmScheduleEntryResponse."Admission Code", ItemNumber, VariantCode, TmpAdmScheduleEntryResponse."Admission Start Date", NonWorking, _CalendarExceptionText);
                        if (NonWorking) then
                            CapacityStatusCode := -6;

                        if (CapacityStatusCode <> 1) then
                            exit;

                        SetCapacityStatusCode();

                        if ((_CalendarExceptionText <> '') and (CapacityStatusCode > 0)) then
                            CapacityStatusCode := 6;

                        PriceOption := '';
                        Amount := '';
                        Percentage := '';
                        IncludesVAT := '';
                        if (TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponse, LocalDate, LocalTime, PriceRule)) then begin
                            case (PriceRule.PricingOption) of
                                PriceRule.PricingOption::NA:
                                    PriceOption := '';
                                PriceRule.PricingOption::FIXED:
                                    PriceOption := 'fixed_amount';
                                PriceRule.PricingOption::RELATIVE:
                                    PriceOption := 'relative_amount';
                                PriceRule.PricingOption::PERCENT:
                                    PriceOption := 'percentage';
                            end;
                            Amount := Format(PriceRule.Amount, 0, 9);
                            Percentage := Format(PriceRule.Percentage, 0, 9);
                            IncludesVAT := Format(PriceRule.AmountIncludesVAT, 0, 9);

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
        AdmissionPrice: Decimal;
        CapacityStatusCode: Integer;
        gExternalItemNo: Code[20];
        ResponseLbl: Label 'Capacity Status Code %1 does not have a dedicated message yet.';
        _CalendarExceptionText: Text;

    internal procedure AddResponse()
    begin
        if (not TmpAdmScheduleEntryRequest.FindSet()) then
            exit;

        repeat
            TmpAdmScheduleEntryResponse.TransferFields(TmpAdmScheduleEntryRequest, true);
            GetEntry(TmpAdmScheduleEntryResponse);

        until (TmpAdmScheduleEntryRequest.Next() = 0);
    end;

    internal procedure GetResponse(var TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    var
    begin
        TmpAdmScheduleEntryResponseOut.Copy(TmpAdmScheduleEntryResponse, true);
        exit(not TmpAdmScheduleEntryResponseOut.IsEmpty());
    end;

    local procedure GetEntry(var TmpAdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry" temporary)
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        TimeHelper: Codeunit "NPR TM TimeHelper";
        LocalDateTime: DateTime;
        LocalDate: Date;
    begin

        if (TmpAdmissionScheduleEntry."Admission Code" = '') then begin
            AdmissionScheduleEntry.SetFilter("External Schedule Entry No.", '=%1', TmpAdmissionScheduleEntry."External Schedule Entry No.");
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);

            TmpAdmissionScheduleEntry.Init();
            if (AdmissionScheduleEntry.FindFirst()) then
                TmpAdmissionScheduleEntry.TransferFields(AdmissionScheduleEntry, true);

            TmpAdmissionScheduleEntry.Insert();
            exit;
        end;
        LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(TmpAdmissionScheduleEntry."Admission Code");
        LocalDate := DT2Date(LocalDateTime);

        AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TmpAdmissionScheduleEntry."Admission Code");
        AdmissionScheduleEntry.SetFilter("Admission Start Date", '>=%1', LocalDate);

        if (TmpAdmissionScheduleEntry."Admission Start Date" > 0D) then begin
            if (TmpAdmissionScheduleEntry."Admission Start Date" < LocalDate) then begin
                CapacityStatusCode := -3;
                exit;
            end;
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', TmpAdmissionScheduleEntry."Admission Start Date");
        end;

        AdmissionScheduleEntry.SetFilter("Visibility On Web", '=%1', AdmissionScheduleEntry."Visibility On Web"::VISIBLE);
        AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
        if (AdmissionScheduleEntry.FindSet()) then begin
            repeat
                TmpAdmissionScheduleEntry.TransferFields(AdmissionScheduleEntry, true);
                if (not TmpAdmissionScheduleEntry.Insert()) then;
            until (AdmissionScheduleEntry.Next() = 0);
        end;

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

