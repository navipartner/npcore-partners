xmlport 6014411 "NPR TM AdmissionCapacityPrice"
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
                tableelement(xAdmCapacityPriceBufferRequest; "NPR TM AdmCapacityPriceBuffer")
                {
                    XmlName = 'admission_schedule';
                    UseTemporary = true;
                    fieldattribute(xRequestId; xAdmCapacityPriceBufferRequest.RequestId)
                    {
                        XmlName = 'request_id';
                        Occurrence = Optional;
                    }
                    fieldattribute(xAdmissionCode; xAdmCapacityPriceBufferRequest.AdmissionCode)
                    {
                        XmlName = 'admission_code';
                        Occurrence = Required;
                    }
                    fieldattribute(xReferenceDate; xAdmCapacityPriceBufferRequest.ReferenceDate)
                    {
                        XmlName = 'reference_date';
                        Occurrence = Required;
                    }
                    fieldattribute(xItemReference; xAdmCapacityPriceBufferRequest.ItemReference)
                    {
                        XmlName = 'item_reference';
                        Occurrence = Required;
                    }
                    fieldattribute(xCustomerNo; xAdmCapacityPriceBufferRequest.CustomerNo)
                    {
                        XmlName = 'customer_number';
                        Occurrence = Optional;
                    }
                    fieldattribute(xQuantity; xAdmCapacityPriceBufferRequest.Quantity)
                    {
                        XmlName = 'quantity';
                        Occurrence = Required;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        _RequestEntryNo += 1000;
                        xAdmCapacityPriceBufferRequest.EntryNo := _RequestEntryNo;
                    end;
                }
            }
            textelement(xResponse)
            {
                XmlName = 'response';
                MaxOccurs = Once;
                MinOccurs = Zero;

                tableelement(xAdmCapacityPriceBufferResponse; "NPR TM AdmCapacityPriceBuffer")
                {
                    XmlName = 'admission_schedule';
                    MaxOccurs = Unbounded;
                    MinOccurs = Zero;
                    UseTemporary = true;

                    fieldattribute(xRequestIdOut; xAdmCapacityPriceBufferResponse.RequestId)
                    {
                        XmlName = 'request_id';
                    }

                    fieldattribute(xAdmissionCodeOut; xAdmCapacityPriceBufferResponse.AdmissionCode)
                    {
                        XmlName = 'admission_code';
                    }
                    fieldattribute(xDefaultOut; xAdmCapacityPriceBufferResponse.DefaultAdmission)
                    {
                        XmlName = 'default';
                    }
                    textattribute(xIncludedOut)
                    {
                        XmlName = 'included';
                        trigger OnBeforePassVariable()
                        begin
                            case xAdmCapacityPriceBufferResponse.AdmissionInclusion of
                                xAdmCapacityPriceBufferResponse.AdmissionInclusion::REQUIRED:
                                    xIncludedOut := 'required';
                                xAdmCapacityPriceBufferResponse.AdmissionInclusion::SELECTED:
                                    xIncludedOut := 'selected';
                                xAdmCapacityPriceBufferResponse.AdmissionInclusion::NOT_SELECTED:
                                    xIncludedOut := 'not_selected';
                            end;
                        end;
                    }
                    fieldattribute(xCustomerNoOut; xAdmCapacityPriceBufferResponse.CustomerNo)
                    {
                        XmlName = 'customer_number';
                    }
                    fieldattribute(xReferenceDateOut; xAdmCapacityPriceBufferResponse.ReferenceDate)
                    {
                        XmlName = 'reference_date';
                    }
                    fieldattribute(xQuantityOut; xAdmCapacityPriceBufferResponse.Quantity)
                    {
                        XmlName = 'quantity';
                    }
                    fieldattribute(xUnitPriceOut; xAdmCapacityPriceBufferResponse.UnitPrice)
                    {
                        XmlName = 'unit_price';
                    }
                    fieldattribute(xDiscountPctOut; xAdmCapacityPriceBufferResponse.DiscountPct)
                    {
                        XmlName = 'discount_pct';
                    }
                    fieldattribute(xUnitPriceIncludeVatOut; xAdmCapacityPriceBufferResponse.UnitPriceIncludesVat)
                    {
                        XmlName = 'unit_price_includes_vat';
                    }
                    fieldattribute(xVatPctOut; xAdmCapacityPriceBufferResponse.UnitPriceVatPercentage)
                    {
                        XmlName = 'vat_pct';
                    }

                    tableelement(TmpAdmScheduleEntryResponse; "NPR TM Admis. Schedule Entry")
                    {
                        XmlName = 'admission_schedule_entry';
                        UseTemporary = true;
                        MinOccurs = Zero;

                        fieldattribute(external_entry_no; TmpAdmScheduleEntryResponse."External Schedule Entry No.")
                        {
                        }
                        fieldattribute(schedule_code; TmpAdmScheduleEntryResponse."Schedule Code")
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
                        textattribute(xCapacityStatusOut)
                        {
                            XmlName = 'status';

                            trigger OnBeforePassVariable()
                            begin
                                xCapacityStatusOut := Format((_CapacityStatusCode >= 1), 0, 9);
                            end;
                        }
                        textattribute(xAllocationByOut)
                        {
                            XmlName = 'allocation_by';

                            trigger OnBeforePassVariable()
                            begin

                                case TmpAdmScheduleEntryResponse."Allocation By" of
                                    TmpAdmScheduleEntryResponse."Allocation By"::CAPACITY:
                                        xAllocationByOut := 'capacity';
                                    TmpAdmScheduleEntryResponse."Allocation By"::WAITINGLIST:
                                        xAllocationByOut := 'waitinglist';
                                end;
                            end;
                        }
                        textattribute(xRemainingCapacityOut)
                        {
                            XmlName = 'remaining';

                            trigger OnBeforePassVariable()
                            begin
                                xRemainingCapacityOut := Format(_RemainingCapacity, 0, 9);
                            end;
                        }
                        textattribute(xResponseMessageOut)
                        {
                            XmlName = 'message';
                        }

                        fieldattribute(xEventArrivalFromTime; TmpAdmScheduleEntryResponse."Event Arrival From Time")
                        {
                            XmlName = 'event_arrival_from_time';
                        }
                        fieldattribute(xEventArrivalUntilTime; TmpAdmScheduleEntryResponse."Event Arrival Until Time")
                        {
                            XmlName = 'event_arrival_until_time';
                        }
                        fieldattribute(xSalesFromDate; TmpAdmScheduleEntryResponse."Sales From Date")
                        {
                            XmlName = 'sales_from_date';
                        }
                        fieldattribute(xSalesFromTime; TmpAdmScheduleEntryResponse."Sales From Time")
                        {
                            XmlName = 'sales_from_time';
                        }
                        fieldattribute(xSalesUntilDate; TmpAdmScheduleEntryResponse."Sales Until Date")
                        {
                            XmlName = 'sales_until_date';
                        }
                        fieldattribute(xSalesUntilTime; TmpAdmScheduleEntryResponse."Sales Until Time")
                        {
                            XmlName = 'sales_until_time';
                        }
                        textattribute(xDynPriceOptionOut)
                        {
                            XmlName = 'dyn_price_option';
                        }
                        textattribute(xDynAmountOut)
                        {
                            XmlName = 'dyn_price_amount';
                        }
                        textattribute(xDynPercentageOut)
                        {
                            XmlName = 'dyn_price_percentage';
                        }
                        textattribute(xDynamicUnitPriceOut)
                        {
                            XmlName = 'dynamic_customer_unit_price';
                            trigger OnBeforePassVariable()
                            begin
                                xDynamicUnitPriceOut := Format(_DynamicCustomerPrice, 0, 9);
                            end;
                        }
                        textattribute(xCustomerPriceOut)
                        {
                            XmlName = 'customer_price';
                        }


                        trigger OnPreXmlItem()
                        begin
                            TmpAdmScheduleEntryResponse.SetCurrentKey("Admission Code");
                            TmpAdmScheduleEntryResponse.SetFilter("Admission Code", '=%1', xAdmCapacityPriceBufferResponse.AdmissionCode);
                            TmpAdmScheduleEntryResponse.SetFilter("Admission Start Date", '=%1', xAdmCapacityPriceBufferResponse.ReferenceDate);
                            _RemainingCapacity := 0;
                            _CapacityStatusCode := 1;
                            _DynamicCustomerPrice := 0;
                        end;

                        trigger OnAfterGetRecord()
                        var
                            TicketManagement: Codeunit "NPR TM Ticket Management";
                            TicketPrice: Codeunit "NPR TM Dynamic Price";
                            PriceRule: Record "NPR TM Dynamic Price Rule";
                            ReasonCode: Enum "NPR TM Sch. Block Sales Reason";
                            NonWorking: Boolean;
                            HavePriceRule: Boolean;
                            BasePrice, AddonPrice : Decimal;
                            CustomerPriceOut: Decimal;
                            TimeHelper: Codeunit "NPR TM TimeHelper";
                            LocalDateTime: DateTime;
                            LocalDate: Date;
                            LocalTime: Time;
                        begin

                            _RemainingCapacity := 0;
                            _CapacityStatusCode := 1;
                            _DynamicCustomerPrice := 0;
                            CustomerPriceOut := 0;

                            xDynPriceOptionOut := '';
                            xDynAmountOut := '';
                            xDynPercentageOut := '';
                            xDynamicUnitPriceOut := '';
                            xCustomerPriceOut := '';

                            LocalDateTime := TimeHelper.GetLocalTimeAtAdmission(TmpAdmScheduleEntryResponse."Admission Code");
                            LocalDate := DT2Date(LocalDateTime);
                            LocalTime := DT2Time(LocalDateTime);

                            HavePriceRule := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponse, xAdmCapacityPriceBufferResponse.ItemNumber, xAdmCapacityPriceBufferResponse.VariantCode, LocalDate, LocalTime, PriceRule);
                            if (HavePriceRule) then
                                TicketPrice.EvaluatePriceRule(PriceRule, xAdmCapacityPriceBufferResponse.UnitPrice, xAdmCapacityPriceBufferResponse.UnitPriceIncludesVat, xAdmCapacityPriceBufferResponse.UnitPriceVatPercentage, false, BasePrice, AddonPrice);

                            if (TmpAdmScheduleEntryResponse."Admission Is" = TmpAdmScheduleEntryResponse."Admission Is"::CLOSED) then
                                _CapacityStatusCode := -5;

                            if (TmpAdmScheduleEntryResponse."Admission End Date" < LocalDate) then
                                _CapacityStatusCode := -5;

                            if ((TmpAdmScheduleEntryResponse."Admission End Date" = LocalDate) and (TmpAdmScheduleEntryResponse."Admission End Time" < LocalTime)) then
                                _CapacityStatusCode := -5;

                            if (not TicketManagement.ValidateAdmSchEntryForSales(TmpAdmScheduleEntryResponse,
                                        xAdmCapacityPriceBufferResponse.RequestItemNumber,
                                        xAdmCapacityPriceBufferResponse.RequestVariantCode,
                                        LocalDate, LocalTime,
                                        ReasonCode, _RemainingCapacity)) then begin
                                _CapacityStatusCode := -1;
                                if (ReasonCode = ReasonCode::ScheduleExceedTicketDuration) then
                                    currXMLport.Skip();
                            end;

                            TicketManagement.CheckTicketBaseCalendar(TmpAdmScheduleEntryResponse."Admission Code",
                                xAdmCapacityPriceBufferResponse.RequestItemNumber,
                                xAdmCapacityPriceBufferResponse.RequestVariantCode,
                                TmpAdmScheduleEntryResponse."Admission Start Date",
                                NonWorking,
                                _CalendarExceptionText);

                            _DynamicCustomerPrice := xAdmCapacityPriceBufferResponse.UnitPrice;
                            if (not HavePriceRule) then begin
                                CustomerPriceOut := xAdmCapacityPriceBufferResponse.Quantity * _DynamicCustomerPrice - xAdmCapacityPriceBufferResponse.Quantity * _DynamicCustomerPrice * xAdmCapacityPriceBufferResponse.DiscountPct / 100;
                                xCustomerPriceOut := Format(TicketPrice.RoundAmount(CustomerPriceOut, _GeneralLedgerSetup."Inv. Rounding Precision (LCY)", _GeneralLedgerSetup."Inv. Rounding Type (LCY)"), 0, 9);
                            end;

                            if (HavePriceRule) then begin
                                case (PriceRule.PricingOption) of
                                    PriceRule.PricingOption::NA:
                                        begin
                                            xDynPriceOptionOut := '';
                                            _DynamicCustomerPrice := xAdmCapacityPriceBufferResponse.UnitPrice;
                                        end;
                                    PriceRule.PricingOption::FIXED:
                                        begin
                                            xDynPriceOptionOut := 'fixed_amount';
                                            _DynamicCustomerPrice := BasePrice;
                                        end;
                                    PriceRule.PricingOption::RELATIVE:
                                        begin
                                            xDynPriceOptionOut := 'relative_amount';
                                            _DynamicCustomerPrice := xAdmCapacityPriceBufferResponse.UnitPrice + AddonPrice;
                                        end;
                                    PriceRule.PricingOption::PERCENT:
                                        begin
                                            xDynPriceOptionOut := 'percentage';
                                            _DynamicCustomerPrice := xAdmCapacityPriceBufferResponse.UnitPrice + AddonPrice;
                                        end;
                                end;
                                xDynAmountOut := Format(PriceRule.Amount, 0, 9);
                                xDynPercentageOut := Format(PriceRule.Percentage, 0, 9);

                                if (_DynamicCustomerPrice < 0) then
                                    _DynamicCustomerPrice := 0;

                                CustomerPriceOut := xAdmCapacityPriceBufferResponse.Quantity * _DynamicCustomerPrice - xAdmCapacityPriceBufferResponse.Quantity * _DynamicCustomerPrice * xAdmCapacityPriceBufferResponse.DiscountPct / 100;
                                xCustomerPriceOut := Format(TicketPrice.RoundAmount(CustomerPriceOut, PriceRule.RoundingPrecision, PriceRule.RoundingDirection), 0, 9);

                            end;

                            if (NonWorking) then
                                _CapacityStatusCode := -6;

                            if (_RemainingCapacity < 1) then begin
                                _RemainingCapacity := 0;
                                _CapacityStatusCode := -1;
                                ReasonCode := ReasonCode::RemainingCapacityZeroOrLess;
                            end;

                            xResponseMessageOut := SetResponseMessageText(ReasonCode);
                        end;

                    }
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
        _RequestEntryNo: Integer;
        _RemainingCapacity: Integer;
        _DynamicCustomerPrice: Decimal;
        _CapacityStatusCode: Integer;
        _ResponseLbl: Label 'Capacity Status Code %1 does not have a dedicated message yet.';
        _CalendarExceptionText: Text;
        _GeneralLedgerSetup: Record "General Ledger Setup";

    internal procedure AddResponse()
    begin
        _GeneralLedgerSetup.Get();

        xAdmCapacityPriceBufferRequest.Reset();
        if (not xAdmCapacityPriceBufferRequest.FindSet()) then
            exit;

        repeat
            FindEntries(xAdmCapacityPriceBufferRequest);
        until (xAdmCapacityPriceBufferRequest.Next() = 0);
    end;

    internal procedure GetResponse(var TmpAdmScheduleEntryResponseOut: Record "NPR TM Admis. Schedule Entry" temporary): Boolean
    var
    begin
        TmpAdmScheduleEntryResponseOut.Copy(TmpAdmScheduleEntryResponse, true);
        exit(not TmpAdmScheduleEntryResponseOut.IsEmpty());
    end;

    local procedure FindEntries(AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer")
    var
        AdmissionScheduleEntry: Record "NPR TM Admis. Schedule Entry";
        Admission: Record "NPR TM Admission";
        TicketBom: Record "NPR TM Ticket Admission BOM";
        TicketRequestManager: Codeunit "NPR TM Ticket Request Manager";
        ItemResolver: Integer;
        BomIndex: Integer;
    begin

        AdmCapacityPriceBuffer.TestField(ItemReference);
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(AdmCapacityPriceBuffer.ItemReference, AdmCapacityPriceBuffer.RequestItemNumber, AdmCapacityPriceBuffer.RequestVariantCode, ItemResolver)) then
            Error('Invalid ItemReference.');

        TicketBom.SetFilter("Item No.", '=%1', AdmCapacityPriceBuffer.RequestItemNumber);
        TicketBom.SetFilter("Variant Code", '=%1', AdmCapacityPriceBuffer.RequestVariantCode);
        if (xAdmCapacityPriceBufferRequest.AdmissionCode <> '') then
            TicketBom.SetFilter("Admission Code", '=%1', AdmCapacityPriceBuffer.AdmissionCode);

        if (not TicketBom.FindSet()) then
            Error('Invalid ItemReference.');

        BomIndex := 0;
        repeat
            xAdmCapacityPriceBufferResponse.TransferFields(AdmCapacityPriceBuffer, false);
            xAdmCapacityPriceBufferResponse.EntryNo := AdmCapacityPriceBuffer.EntryNo + BomIndex;
            xAdmCapacityPriceBufferResponse.AdmissionCode := TicketBom."Admission Code";
            xAdmCapacityPriceBufferResponse.DefaultAdmission := TicketBom.Default;
            xAdmCapacityPriceBufferResponse.AdmissionInclusion := TicketBom."Admission Inclusion";
            xAdmCapacityPriceBufferResponse.ItemNumber := xAdmCapacityPriceBufferResponse.RequestItemNumber;
            xAdmCapacityPriceBufferResponse.VariantCode := xAdmCapacityPriceBufferResponse.RequestVariantCode;

            if (TicketBom."Admission Inclusion" = TicketBom."Admission Inclusion"::REQUIRED) then
                if (TicketBom.Default) then
                    CalculateErpPrice(xAdmCapacityPriceBufferResponse);

            if (TicketBom."Admission Inclusion" <> TicketBom."Admission Inclusion"::REQUIRED) then begin
                Admission.Get(TicketBom."Admission Code");
                xAdmCapacityPriceBufferResponse.ItemNumber := Admission."Additional Experience Item No.";
                xAdmCapacityPriceBufferResponse.VariantCode := '';
                if (xAdmCapacityPriceBufferResponse.ItemNumber <> '') then
                    CalculateErpPrice(xAdmCapacityPriceBufferResponse);
            end;

            if (not xAdmCapacityPriceBufferResponse.Insert()) then;
            BomIndex += 1;

            AdmissionScheduleEntry.SetFilter("Admission Code", '=%1', TicketBom."Admission Code");
            AdmissionScheduleEntry.SetFilter("Admission Start Date", '=%1', AdmCapacityPriceBuffer.ReferenceDate);
            AdmissionScheduleEntry.SetFilter("Visibility On Web", '=%1', AdmissionScheduleEntry."Visibility On Web"::VISIBLE);
            AdmissionScheduleEntry.SetFilter(Cancelled, '=%1', false);
            if (AdmissionScheduleEntry.FindSet()) then begin
                repeat
                    TmpAdmScheduleEntryResponse.TransferFields(AdmissionScheduleEntry, true);
                    if (not TmpAdmScheduleEntryResponse.Insert()) then;
                until (AdmissionScheduleEntry.Next() = 0);
            end;
        until (TicketBom.Next() = 0);

    end;

    local procedure SetResponseMessageText(ReasonCode: Enum "NPR TM Sch. Block Sales Reason"): Text
    begin
        if ((_CalendarExceptionText <> '') and (_CapacityStatusCode > 0)) then
            _CapacityStatusCode := 6;

        case _CapacityStatusCode of
            6:
                exit(_CalendarExceptionText);
            1:
                exit('Ok.');
            -1:
                exit(StrSubstNo('Capacity exceeded (code: %1).', ReasonCode.AsInteger()));
            -2:
                exit('The schedule does not allow admissions at this time.');
            -3:
                exit('Unexpected problem with capacity calculation, invalid parameters?');
            -4:
                exit('The external schedule id is invalid or all schedules have been cancelled.');
            -5:
                exit('The admission schedule indicated that admission is closed.');
            -6:
                exit(_CalendarExceptionText);

            else
                exit(StrSubstNo(_ResponseLbl, _CapacityStatusCode));
        end;
    end;

    local procedure CalculateErpPrice(var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer")
    var
        TicketPriceService: Codeunit "NPR TM Dynamic Price";
    begin
        if (not TicketPriceService.CalculateErpPrice(AdmCapacityPriceBuffer)) then
            Error('<errorText>%1</errorText><callStack>%2</callStack>', GetLastErrorText(), GetLastErrorCallStack());
    end;
}

