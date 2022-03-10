xmlport 6151146 "NPR M2 Item Price Request"
{
    Caption = 'Item Price Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    UseRequestPage = false;

    schema
    {
        textelement(ItemPrice)
        {
            tableelement(salespricerequest; "NPR M2 Price Calc. Buffer")
            {
                XmlName = 'Request';
                UseTemporary = true;
                fieldattribute(RequestId; SalesPriceRequest."Request ID")
                {
                }
                fieldattribute(ItemNumber; SalesPriceRequest."Item No.")
                {
                }
                fieldattribute(VariantCode; SalesPriceRequest."Variant Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(CustomerNumber; SalesPriceRequest."Source Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(UnitOfMeasureCode; SalesPriceRequest."Unit of Measure Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(CurrencyCode; SalesPriceRequest."Currency Code")
                {
                    Occurrence = Optional;
                }
                fieldattribute(Quantity; SalesPriceRequest."Minimum Quantity")
                {
                    Occurrence = Optional;
                }
                fieldattribute(OrderDate; SalesPriceRequest."Price End Date")
                {
                    Occurrence = Optional;
                }

                trigger OnPreXmlItem()
                begin

                    SalesPriceRequest.SetCurrentKey("Request ID");
                end;

                trigger OnAfterInitRecord()
                begin
                    SalesPriceRequest.Init();
                end;

                trigger OnBeforeInsertRecord()
                begin

                    RequestLineNo += 1;
                    if (SalesPriceRequest."Request ID" = '') then
                        SalesPriceRequest."Request ID" := Format(RequestLineNo);

                    SalesPriceRequest.Reset();
                    if (SalesPriceRequest."Request ID" <> '') then begin
                        SalesPriceRequest.SetFilter("Request ID", '=%1', SalesPriceRequest."Request ID");
                        if (not SalesPriceRequest.IsEmpty()) then begin
                            ImportMessage += StrSubstNo(DuplicateReqIdLbl, SalesPriceRequest."Request ID");
                            currXMLport.Skip();
                        end;
                    end;


                    SalesPriceRequest.Reset();
                    SalesPriceRequest.SetFilter("Item No.", '=%1', SalesPriceRequest."Item No.");
                    SalesPriceRequest.SetFilter("Variant Code", '=%1', SalesPriceRequest."Variant Code");
                    SalesPriceRequest.SetFilter("Source Code", '=%1', SalesPriceRequest."Source Code");
                    SalesPriceRequest.SetFilter("Currency Code", '=%1', SalesPriceRequest."Currency Code");
                    SalesPriceRequest.SetFilter("Unit of Measure Code", '=%1', SalesPriceRequest."Unit of Measure Code");
                    SalesPriceRequest.SetFilter("Minimum Quantity", '=%1', SalesPriceRequest."Minimum Quantity");

                    if (not SalesPriceRequest.IsEmpty()) then begin
                        ImportMessage += StrSubstNo(DuplicateReqLbl, SalesPriceRequest.RecordId);
                        currXMLport.Skip();
                    end;
                end;
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(Status)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseMessage)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ExecutionTime)
                    {
                    }
                }
                textelement(Items)
                {
                    MinOccurs = Zero;
                    tableelement(salespriceresponse; "NPR M2 Price Calc. Buffer")
                    {
                        MinOccurs = Zero;
                        XmlName = 'Item';
                        UseTemporary = true;
                        fieldattribute(RequestId; SalesPriceResponse."Request ID")
                        {
                        }
                        textelement(itemstatus)
                        {
                            XmlName = 'Status';
                            textelement(itemresponsecode)
                            {
                                XmlName = 'ResponseCode';

                                trigger OnBeforePassVariable()
                                begin

                                    ItemResponseCode := 'OK';
                                    if (SalesPriceResponse."Response Message" <> '') then
                                        ItemResponseCode := 'ERROR';
                                end;
                            }
                            fieldelement(ResponseMessage; SalesPriceResponse."Response Message")
                            {
                            }
                        }
                        fieldelement(CurrencyCode; SalesPriceResponse."Currency Code")
                        {
                        }
                        fieldelement(UnitOfMeasureCode; SalesPriceResponse."Unit of Measure Code")
                        {
                        }
                        textelement(Prices)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            tableelement(pricepointresponse; "NPR M2 Price Calc. Buffer")
                            {
                                LinkFields = "Request ID" = FIELD("Request ID");
                                LinkTable = SalesPriceResponse;
                                MinOccurs = Zero;
                                XmlName = 'PricePoint';
                                UseTemporary = true;
                                fieldattribute(ItemNumber; PricePointResponse."Item No.")
                                {
                                }
                                fieldattribute(VariantCode; PricePointResponse."Variant Code")
                                {
                                }
                                fieldattribute(MinimumQuantity; PricePointResponse."Minimum Quantity")
                                {
                                }
                                fieldelement(DiscountPercent; PricePointResponse."Line Discount %")
                                {
                                    fieldattribute(ValidUntil; PricePointResponse."Discount End Date")
                                    {
                                        Occurrence = Optional;
                                    }
                                }
                                fieldelement(UnitPrice; PricePointResponse."Unit Price")
                                {
                                    fieldattribute(ExcludingDiscount; PricePointResponse."Unit Price Base")
                                    {
                                        Occurrence = Optional;
                                    }
                                    fieldattribute(ValidUntil; PricePointResponse."Price End Date")
                                    {
                                        Occurrence = Optional;
                                    }
                                }
                                fieldelement(PriceIncludesVat; PricePointResponse."Price Includes VAT")
                                {
                                }
                                fieldelement(TotalVatPercent; PricePointResponse."Total VAT %")
                                {
                                }
                            }
                        }

                        trigger OnPreXmlItem()
                        begin
                            SalesPriceResponse.SetCurrentKey("Request ID");
                        end;
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        RequestLineNo := 1000000;
    end;

    var
        RequestLineNo: Integer;
        StartTime: Time;
        ImportMessage: Text;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;
        DuplicateReqIdLbl: Label 'Skipping duplicate Request Id %1;', Locked = true;
        DuplicateReqLbl: Label 'Skipping duplicate request %1;', Locked = true;

    internal procedure GetSalesPriceRequest(var TmpM2PriceCalculationBuffer: Record "NPR M2 Price Calc. Buffer" temporary)
    begin

        if (SalesPriceRequest.FindSet()) then begin
            repeat
                TmpM2PriceCalculationBuffer.TransferFields(SalesPriceRequest, true);
                TmpM2PriceCalculationBuffer.Insert();
            until (SalesPriceRequest.Next() = 0);
        end;

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'Did not complete.';
    end;

    internal procedure SetSalesPriceResponse(var TmpPricePoint: Record "NPR M2 Price Calc. Buffer" temporary; var TmpSalesPriceResponse: Record "NPR M2 Price Calc. Buffer" temporary; ResponseMessageIn: Text; ResponseCodeIn: Code[10])
    var
        PlaceHolder2Lbl: Label '%1; %2', Locked = true;
    begin

        SalesPriceRequest.Reset();
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Time - StartTime);

        if (TmpSalesPriceResponse.FindSet()) then begin
            repeat
                SalesPriceResponse.TransferFields(TmpSalesPriceResponse, true);
                SalesPriceResponse.Insert();
            until (TmpSalesPriceResponse.Next() = 0);
        end;

        if (TmpPricePoint.FindSet()) then begin
            repeat
                PricePointResponse.TransferFields(TmpPricePoint, true);
                PricePointResponse.Insert();
            until (TmpPricePoint.Next() = 0);
        end;

        ResponseCode := ResponseCodeIn;
        ResponseMessage := ResponseMessageIn;

        if (ImportMessage <> '') then
            ResponseMessage := StrSubstNo(PlaceHolder2Lbl, ImportMessage, ResponseMessageIn);

        if (ResponseCode <> 'ERROR') and (ImportMessage <> '') then
            ResponseCode := 'WARNING';
    end;

    internal procedure SetErrorResponse(ReasonText: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;
}