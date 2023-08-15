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

                            trigger OnBeforePassVariable()
                            begin
                                SetResponseMessageText();
                            end;
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
                            trigger OnBeforePassVariable()
                            begin
                                xCustomerPriceOut := Format((xAdmCapacityPriceBufferResponse.Quantity * _DynamicCustomerPrice - xAdmCapacityPriceBufferResponse.Quantity * _DynamicCustomerPrice * xAdmCapacityPriceBufferResponse.DiscountPct / 100), 0, 9)
                            end;
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
                        begin

                            _RemainingCapacity := 0;
                            _CapacityStatusCode := 1;
                            _DynamicCustomerPrice := 0;

                            HavePriceRule := TicketPrice.SelectPriceRule(TmpAdmScheduleEntryResponse, Today(), Time(), PriceRule);
                            if (HavePriceRule) then
                                TicketPrice.EvaluatePriceRule(PriceRule, xAdmCapacityPriceBufferResponse.UnitPrice, xAdmCapacityPriceBufferResponse.UnitPriceIncludesVat, xAdmCapacityPriceBufferResponse.UnitPriceVatPercentage, false, BasePrice, AddonPrice);


                            if (TmpAdmScheduleEntryResponse."Admission Is" = TmpAdmScheduleEntryResponse."Admission Is"::CLOSED) then
                                _CapacityStatusCode := -5;

                            if (not TicketManagement.ValidateAdmSchEntryForSales(TmpAdmScheduleEntryResponse,
                                        xAdmCapacityPriceBufferResponse.ItemNumber,
                                        xAdmCapacityPriceBufferResponse.VariantCode,
                                        Today, Time,
                                        ReasonCode, _RemainingCapacity)) then begin
                                _CapacityStatusCode := -1;
                                if (ReasonCode = ReasonCode::ScheduleExceedTicketDuration) then
                                    currXMLport.Skip();
                            end;

                            TicketManagement.CheckTicketBaseCalendar(TmpAdmScheduleEntryResponse."Admission Code",
                                xAdmCapacityPriceBufferResponse.ItemNumber,
                                xAdmCapacityPriceBufferResponse.VariantCode,
                                TmpAdmScheduleEntryResponse."Admission Start Date",
                                NonWorking,
                                _CalendarExceptionText);

                            if (NonWorking) then
                                _CapacityStatusCode := -6;

                            if (_CapacityStatusCode <> 1) then
                                exit;

                            SetCapacityStatusCode();

                            if ((_CalendarExceptionText <> '') and (_CapacityStatusCode > 0)) then
                                _CapacityStatusCode := 6;

                            xDynPriceOptionOut := '';
                            xDynAmountOut := '';
                            xDynPercentageOut := '';

                            _DynamicCustomerPrice := xAdmCapacityPriceBufferResponse.UnitPrice;
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
                            end;

                            if (_DynamicCustomerPrice < 0) then
                                _DynamicCustomerPrice := 0;
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

    internal procedure AddResponse()
    begin
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
        if (not TicketRequestManager.TranslateBarcodeToItemVariant(AdmCapacityPriceBuffer.ItemReference, AdmCapacityPriceBuffer.ItemNumber, AdmCapacityPriceBuffer.VariantCode, ItemResolver)) then
            Error('Invalid ItemReference.');

        TicketBom.SetFilter("Item No.", '=%1', AdmCapacityPriceBuffer.ItemNumber);
        TicketBom.SetFilter("Variant Code", '=%1', AdmCapacityPriceBuffer.VariantCode);
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

    local procedure SetCapacityStatusCode()
    begin
        _CapacityStatusCode := 1;
        if (_RemainingCapacity < 1) then begin
            _RemainingCapacity := 0;
            _CapacityStatusCode := -1;
        end;
    end;

    local procedure SetResponseMessageText()
    begin
        case _CapacityStatusCode of
            6:
                xResponseMessageOut := _CalendarExceptionText;
            1:
                xResponseMessageOut := 'Ok.';
            -1:
                xResponseMessageOut := 'Capacity exceeded.';
            -2:
                xResponseMessageOut := 'The schedule does not allow admissions at this time.';
            -3:
                xResponseMessageOut := 'Unexpected problem with capacity calculation, invalid parameters?';
            -4:
                xResponseMessageOut := 'The external schedule id is invalid or all schedules have been cancelled.';
            -5:
                xResponseMessageOut := 'The admission schedule indicated that admission is closed.';
            -6:
                xResponseMessageOut := _CalendarExceptionText;
            else
                xResponseMessageOut := StrSubstNo(_ResponseLbl, _CapacityStatusCode);
        end;
    end;

    local procedure CalculateErpPrice(var AdmCapacityPriceBuffer: Record "NPR TM AdmCapacityPriceBuffer")
    var
        M2PriceService: Codeunit "NPR M2 POS Price WebService";
        TempSalePOS: Record "NPR POS Sale" temporary;
        TempSaleLinePOS: Record "NPR POS Sale Line" temporary;
    begin
        TempSalePOS."Sales Ticket No." := Format(AdmCapacityPriceBuffer.EntryNo);
        TempSalePOS."Customer No." := AdmCapacityPriceBuffer.CustomerNo;
        TempSalePOS.Date := AdmCapacityPriceBuffer.ReferenceDate;
        TempSalePOS.Insert();

        TempSaleLinePOS."Sales Ticket No." := TempSalePOS."Sales Ticket No.";
        TempSaleLinePOS."Line No." := AdmCapacityPriceBuffer.EntryNo;
        TempSaleLinePOS."Line Type" := TempSaleLinePOS."Line Type"::Item;
        TempSaleLinePOS."No." := AdmCapacityPriceBuffer.ItemNumber;
        TempSaleLinePOS."Variant Code" := AdmCapacityPriceBuffer.VariantCode;
        TempSaleLinePOS.Quantity := AdmCapacityPriceBuffer.Quantity;
        TempSaleLinePOS.Date := AdmCapacityPriceBuffer.ReferenceDate;
        TempSaleLinePOS."Allow Line Discount" := true;
        TempSaleLinePOS.Insert();

        if (M2PriceService.TryPosQuoteRequest(TempSalePOS, TempSaleLinePOS)) then begin
            AdmCapacityPriceBuffer.UnitPrice := TempSaleLinePOS."Unit Price";
            AdmCapacityPriceBuffer.DiscountPct := TempSaleLinePOS."Discount %";
            AdmCapacityPriceBuffer.TotalDiscountAmount := TempSaleLinePOS."Discount Amount";
            AdmCapacityPriceBuffer.UnitPriceIncludesVat := TempSaleLinePOS."Price Includes VAT";
            AdmCapacityPriceBuffer.UnitPriceVatPercentage := TempSaleLinePOS."VAT %";
        end
    end;
}

