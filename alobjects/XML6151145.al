xmlport 6151145 "M2 POS Quote Price Request"
{
    // NPR5.48/TSA /20181009 CASE 320429 Initial Version
    // MAG2.21/TSA /20190423 CASE 350006 Added optional request field OrderDate
    // MAG2.25/TSA /20200226 CASE 391299 Removed NPR version tag

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
                tableelement(tmpsaleposrequest;"Sale POS")
                {
                    MaxOccurs = Once;
                    XmlName = 'Customer';
                    UseTemporary = true;
                    fieldattribute(Number;TmpSalePOSRequest."Customer No.")
                    {
                    }
                    fieldattribute(OrderDate;TmpSalePOSRequest.Date)
                    {
                        Occurrence = Optional;
                    }
                    tableelement(tmpsalelineposrequest;"Sale Line POS")
                    {
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(LineNumber;TmpSaleLinePOSRequest."Line No.")
                        {
                        }
                        fieldattribute(ItemNumber;TmpSaleLinePOSRequest."No.")
                        {
                        }
                        fieldattribute(VariantCode;TmpSaleLinePOSRequest."Variant Code")
                        {
                            Occurrence = Optional;
                        }
                        fieldattribute(Quantity;TmpSaleLinePOSRequest.Quantity)
                        {
                        }

                        trigger OnBeforeInsertRecord()
                        begin

                            TmpSaleLinePOSRequest."Sales Ticket No." := TicketNumber;
                            TmpSaleLinePOSRequest.Type := TmpSaleLinePOSRequest.Type::Item;

                            //-MAG2.21 [350006]
                            // TmpSaleLinePOSRequest.Date := TODAY;
                            TmpSaleLinePOSRequest.Date := TmpSalePOSRequest.Date
                            //+MAG2.21 [350006]
                        end;
                    }

                    trigger OnBeforeInsertRecord()
                    begin

                        TmpSalePOSRequest."Sales Ticket No." := TicketNumber;
                        //-MAG2.21 [350006]
                        // TmpSalePOSRequest.Date := TODAY;
                        if (TmpSalePOSRequest.Date < Today) then
                            TmpSalePOSRequest.Date := Today;
                        //+MAG2.21 [350006]
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
                tableelement(tmpsalesheaderresponse;"Sale POS")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'Customer';
                    UseTemporary = true;
                    fieldattribute(Number;TmpSalesHeaderResponse."Customer No.")
                    {
                    }
                    textattribute(currencycoderesponse)
                    {
                        XmlName = 'CurrencyCode';
                    }
                    fieldattribute(OrderDate;TmpSalesHeaderResponse.Date)
                    {
                    }
                    tableelement(tmpsaleslineresponse;"Sale Line POS")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'Line';
                        UseTemporary = true;
                        fieldattribute(LineNumber;TmpSalesLineResponse."Line No.")
                        {
                        }
                        fieldattribute(ItemNumber;TmpSalesLineResponse."No.")
                        {
                        }
                        fieldattribute(VariantCode;TmpSalesLineResponse."Variant Code")
                        {
                        }
                        fieldattribute(Quantity;TmpSalesLineResponse.Quantity)
                        {
                        }
                        fieldattribute(UnitOfMeasure;TmpSalesLineResponse."Unit of Measure Code")
                        {
                        }
                        fieldattribute(UnitPrice;TmpSalesLineResponse."Unit Price")
                        {
                        }
                        textattribute(LineAmount)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                LineAmount := Format (
                                  Round (TmpSalesLineResponse."Unit Price" * TmpSalesLineResponse.Quantity - TmpSalesLineResponse."Discount Amount"), 0, 9);
                            end;
                        }
                        fieldattribute(LineDiscountPercent;TmpSalesLineResponse."Discount %")
                        {
                        }
                        fieldattribute(LineDiscountAmount;TmpSalesLineResponse."Discount Amount")
                        {
                        }
                        fieldattribute(PriceIncludesVat;TmpSalesLineResponse."Price Includes VAT")
                        {
                        }
                        textattribute(TotalVatPercent)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                TotalVatPercent := '';
                                if (TmpSalesLineResponse."Price Includes VAT") then
                                  TotalVatPercent := Format (Round (TmpSalesLineResponse."VAT %"), 0, 9);
                            end;
                        }
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

    trigger OnInitXmlPort()
    begin
        TicketNumber := DelChr (Format (CurrentDateTime (),0,9), '<=>', DelChr (Format (CurrentDateTime (),0,9), '<=>', '0123456789'));
    end;

    var
        TicketNumber: Code[20];
        LineNo: Integer;
        StartTime: Time;

    procedure GetRequest(var TmpSalesHeader: Record "Sale POS" temporary;var TmpSalesLine: Record "Sale Line POS" temporary)
    begin

        TmpSalePOSRequest.FindFirst ();

        TmpSalesHeader.TransferFields (TmpSalePOSRequest, true);
        TmpSalesHeader.Insert ();

        if (TmpSaleLinePOSRequest.FindSet ()) then begin
          repeat
            TmpSalesLine.TransferFields (TmpSaleLinePOSRequest, true);
            TmpSalesLine.Insert ();
          until (TmpSaleLinePOSRequest.Next () = 0);
        end;

        ResponseCode := 'ERROR';
        ResponseDescription := 'No Response';
        StartTime := Time;
    end;

    procedure SetResponse(var TmpSalePOS: Record "Sale POS" temporary;var TmpSaleLinePOS: Record "Sale Line POS" temporary)
    begin

        ExecutionTime := StrSubstNo ('%1 (ms)', Format ((Time - StartTime), 0, 9));

        TmpSalesHeaderResponse.TransferFields (TmpSalePOS, true);
        TmpSalesHeaderResponse.Insert ();

        if (TmpSaleLinePOS.FindSet ()) then begin
          repeat
            TmpSalesLineResponse.TransferFields (TmpSaleLinePOS, true);
            TmpSalesLineResponse.Insert ();
          until (TmpSaleLinePOS.Next () = 0);

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

