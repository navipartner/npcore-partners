xmlport 6151145 "NPR M2 POS Sv. Sale Price Req."
{
    Caption = 'POS Price Quote';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(PriceQuote)
        {
            textelement(Request)
            {
                MaxOccurs = Once;
                tableelement(tmpsaleposrequest; "NPR POS Sale")
                {
                    MaxOccurs = Once;
                    XmlName = 'Customer';
                    UseTemporary = true;
                    fieldattribute(Number; TmpSalePOSRequest."Customer No.")
                    {
                    }
                    fieldattribute(OrderDate; TmpSalePOSRequest.Date)
                    {
                        Occurrence = Optional;
                    }
                    tableelement(tmpsalelineposrequest; "NPR POS Sale Line")
                    {
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(LineNumber; TmpSaleLinePOSRequest."Line No.")
                        {
                        }
                        fieldattribute(ItemNumber; TmpSaleLinePOSRequest."No.")
                        {
                        }
                        fieldattribute(VariantCode; TmpSaleLinePOSRequest."Variant Code")
                        {
                            Occurrence = Optional;
                        }
                        fieldattribute(Quantity; TmpSaleLinePOSRequest.Quantity)
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin

                            TmpSaleLinePOSRequest."Sales Ticket No." := TicketNumber;
                            TmpSaleLinePOSRequest.Type := TmpSaleLinePOSRequest.Type::Item;

                            TmpSaleLinePOSRequest.Date := TmpSalePOSRequest.Date
                        end;
                    }

                    trigger OnBeforeInsertRecord()
                    begin

                        TmpSalePOSRequest."Sales Ticket No." := TicketNumber;
                        if (TmpSalePOSRequest.Date < Today) then
                            TmpSalePOSRequest.Date := Today();
                    end;
                }
            }
            textelement(Response)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(ResponseStatus)
                {
                    MaxOccurs = Once;
                    textelement(ResponseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ResponseDescription)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(ExecutionTime)
                    {
                    }
                }
                tableelement(tmpsalesheaderresponse; "NPR POS Sale")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'Customer';
                    UseTemporary = true;
                    fieldattribute(Number; TmpSalesHeaderResponse."Customer No.")
                    {
                    }
                    textattribute(currencycoderesponse)
                    {
                        XmlName = 'CurrencyCode';
                    }
                    fieldattribute(OrderDate; TmpSalesHeaderResponse.Date)
                    {
                    }
                    tableelement(tmpsaleslineresponse; "NPR POS Sale Line")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(LineNumber; TmpSalesLineResponse."Line No.")
                        {
                        }
                        fieldattribute(ItemNumber; TmpSalesLineResponse."No.")
                        {
                        }
                        fieldattribute(VariantCode; TmpSalesLineResponse."Variant Code")
                        {
                        }
                        fieldattribute(Quantity; TmpSalesLineResponse.Quantity)
                        {
                        }
                        fieldattribute(UnitOfMeasure; TmpSalesLineResponse."Unit of Measure Code")
                        {
                        }
                        fieldattribute(UnitPrice; TmpSalesLineResponse."Unit Price")
                        {
                        }
                        textattribute(LineAmount)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                LineAmount := Format(
                                  Round(TmpSalesLineResponse."Unit Price" * TmpSalesLineResponse.Quantity - TmpSalesLineResponse."Discount Amount"), 0, 9);
                            end;
                        }
                        fieldattribute(LineDiscountPercent; TmpSalesLineResponse."Discount %")
                        {
                        }
                        fieldattribute(LineDiscountAmount; TmpSalesLineResponse."Discount Amount")
                        {
                        }
                        fieldattribute(PriceIncludesVat; TmpSalesLineResponse."Price Includes VAT")
                        {
                        }
                        textattribute(TotalVatPercent)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                TotalVatPercent := '';
                                if (TmpSalesLineResponse."Price Includes VAT") then
                                    TotalVatPercent := Format(Round(TmpSalesLineResponse."VAT %"), 0, 9);
                            end;
                        }
                    }
                }
            }
        }
    }

    trigger OnInitXmlPort()
    begin
        TicketNumber := DelChr(Format(CurrentDateTime(), 0, 9), '<=>', DelChr(Format(CurrentDateTime(), 0, 9), '<=>', '0123456789'));
    end;

    var
        TicketNumber: Code[20];
        StartTime: Time;

    procedure GetRequest(var TmpSalesHeader: Record "NPR POS Sale" temporary; var TmpSalesLine: Record "NPR POS Sale Line" temporary)
    begin

        TmpSalePOSRequest.FindFirst();

        TmpSalesHeader.TransferFields(TmpSalePOSRequest, true);
        TmpSalesHeader.Insert();

        if (TmpSaleLinePOSRequest.FindSet()) then begin
            repeat
                TmpSalesLine.TransferFields(TmpSaleLinePOSRequest, true);
                TmpSalesLine.Insert();
            until (TmpSaleLinePOSRequest.Next() = 0);
        end;

        ResponseCode := 'ERROR';
        ResponseDescription := 'No Response';
        StartTime := Time;
    end;

    procedure SetResponse(var TmpSalePOS: Record "NPR POS Sale" temporary; var TmpSaleLinePOS: Record "NPR POS Sale Line" temporary)
    begin

        ExecutionTime := StrSubstNo('%1 (ms)', Format((Time - StartTime), 0, 9));

        TmpSalesHeaderResponse.TransferFields(TmpSalePOS, true);
        TmpSalesHeaderResponse.Insert();

        if (TmpSaleLinePOS.FindSet()) then begin
            repeat
                TmpSalesLineResponse.TransferFields(TmpSaleLinePOS, true);
                TmpSalesLineResponse.Insert();
            until (TmpSaleLinePOS.Next() = 0);

            ResponseCode := 'OK';
            ResponseDescription := '';
        end;
    end;

    procedure SetErrorResponse(ErrorDescription: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseDescription := ErrorDescription;
    end;
}