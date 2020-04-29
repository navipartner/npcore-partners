xmlport 6150903 "HC Customer Price Request"
{
    // NPR5.38/TSA /20171127 CASE 297859 Initial Version

    Caption = 'Customer Price Request';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(customerPrice)
        {
            textelement(priceRequest)
            {
                MaxOccurs = Once;
                tableelement(tmpsalesheaderrequest;"Sales Header")
                {
                    MaxOccurs = Once;
                    XmlName = 'customer';
                    UseTemporary = true;
                    fieldattribute(number;TmpSalesHeaderRequest."Sell-to Customer No.")
                    {
                    }
                    fieldattribute(externalDocumentNumber;TmpSalesHeaderRequest."External Document No.")
                    {
                    }
                    fieldattribute(currencyCode;TmpSalesHeaderRequest."Currency Code")
                    {
                        Occurrence = Optional;
                    }
                    tableelement(tmpsaleslinerequest;"Sales Line")
                    {
                        XmlName = 'line';
                        UseTemporary = true;
                        fieldattribute(lineNumber;TmpSalesLineRequest."Line No.")
                        {
                        }
                        fieldattribute(type;TmpSalesLineRequest.Type)
                        {
                        }
                        fieldattribute(number;TmpSalesLineRequest."No.")
                        {
                        }
                        fieldattribute(variantCode;TmpSalesLineRequest."Variant Code")
                        {
                        }
                        fieldattribute(quantity;TmpSalesLineRequest.Quantity)
                        {
                        }
                        fieldattribute(unitOfMeasure;TmpSalesLineRequest."Unit of Measure Code")
                        {
                            Occurrence = Optional;
                        }

                        trigger OnBeforeInsertRecord()
                        begin

                            TmpSalesLineRequest."Document Type" := TmpSalesHeaderRequest."Document Type";
                            TmpSalesLineRequest."Document No." := TmpSalesHeaderRequest."No.";
                        end;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        TmpSalesHeaderRequest."Document Type" := TmpSalesHeaderRequest."Document Type"::Quote;
                        TmpSalesHeaderRequest."No." := 'TMPVALUE';
                    end;
                }
            }
            textelement(priceResponse)
            {
                MaxOccurs = Once;
                MinOccurs = Zero;
                textelement(responseStatus)
                {
                    MaxOccurs = Once;
                    textelement(responseCode)
                    {
                        MaxOccurs = Once;
                    }
                    textelement(responseDescription)
                    {
                        MaxOccurs = Once;
                    }
                }
                tableelement(tmpsalesheaderresponse;"Sales Header")
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'customer';
                    UseTemporary = true;
                    fieldattribute(number;TmpSalesHeaderResponse."Sell-to Customer No.")
                    {
                    }
                    fieldattribute(externalDocumentNumber;TmpSalesHeaderResponse."External Document No.")
                    {
                    }
                    fieldattribute(currencyCode;TmpSalesHeaderResponse."Currency Code")
                    {
                    }
                    tableelement(tmpsaleslineresponse;"Sales Line")
                    {
                        MaxOccurs = Unbounded;
                        MinOccurs = Zero;
                        XmlName = 'line';
                        UseTemporary = true;
                        fieldattribute(lineNumber;TmpSalesLineResponse."Line No.")
                        {
                        }
                        fieldattribute(type;TmpSalesLineResponse.Type)
                        {
                        }
                        fieldattribute(number;TmpSalesLineResponse."No.")
                        {
                        }
                        fieldattribute(variantCode;TmpSalesLineResponse."Variant Code")
                        {
                        }
                        fieldattribute(quantity;TmpSalesLineResponse.Quantity)
                        {
                        }
                        fieldattribute(unitOfMeasure;TmpSalesLineResponse."Unit of Measure Code")
                        {
                        }
                        fieldattribute(unitPrice;TmpSalesLineResponse."Unit Price")
                        {
                        }
                        fieldattribute(lineAmount;TmpSalesLineResponse."Line Amount")
                        {
                        }
                        fieldattribute(lineDiscountPercent;TmpSalesLineResponse."Line Discount %")
                        {
                        }
                        fieldattribute(lineDiscountAmount;TmpSalesLineResponse."Line Discount Amount")
                        {
                        }
                        fieldattribute(vatPct;TmpSalesLineResponse."VAT %")
                        {
                        }
                        fieldattribute(vatBaseAmount;TmpSalesLineResponse."VAT Base Amount")
                        {
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

    var
        LineNo: Integer;

    procedure GetRequest(var TmpSalesHeader: Record "Sales Header" temporary;var TmpSalesLine: Record "Sales Line" temporary)
    begin
        TmpSalesHeader.TransferFields (TmpSalesHeaderRequest, true);
        TmpSalesHeader.Insert ();

        if (TmpSalesLineRequest.FindSet ()) then begin
          repeat
            TmpSalesLine.TransferFields (TmpSalesLineRequest, true);
            TmpSalesLine.Insert ();
          until (TmpSalesLineRequest.Next () = 0);
        end;

        responseCode := 'ERROR';
        responseDescription := 'No Response';
    end;

    procedure SetResponse(var TmpSalesHeader: Record "Sales Header" temporary;var TmpSalesLine: Record "Sales Line" temporary)
    begin
        TmpSalesHeaderResponse.TransferFields (TmpSalesHeader, true);
        TmpSalesHeaderResponse.Insert ();

        if (TmpSalesLine.FindSet ()) then begin
          repeat
            TmpSalesLineResponse.TransferFields (TmpSalesLine, true);
            TmpSalesLineResponse.Insert ();
          until (TmpSalesLine.Next () = 0);

          responseCode := 'OK';
          responseDescription := '';

        end;
    end;

    procedure SetErrorResponse(ErrorDescription: Text)
    begin

        responseCode := 'ERROR';
        responseDescription := ErrorDescription;
    end;
}

