xmlport 6014413 "NPR DocLxCityCardRedeem"
{
    Caption = 'DocLx CityCard';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;
    Encoding = UTF8;
    UseRequestPage = false;

    schema
    {
        textelement(_CityCards)
        {
            XmlName = 'CityCards';
            textelement(_Request)
            {
                MinOccurs = Once;
                MaxOccurs = Once;
                XmlName = 'Request';

                tableelement(_RequestBuffer; "NPR DocLXCityCardHistory")
                {
                    MinOccurs = Once;
                    MaxOccurs = Unbounded;
                    XmlName = 'Card';
                    UseTemporary = true;

                    fieldattribute(CityCode; _RequestBuffer.CityCode)
                    {
                        XmlName = 'CityCode';
                        Occurrence = Optional;
                    }
                    fieldattribute(Number; _RequestBuffer.CardNumber)
                    {
                        XmlName = 'CardNumber';
                        Occurrence = Required;
                    }
                    fieldattribute(LocationCode; _RequestBuffer.LocationCode)
                    {
                        XmlName = 'LocationCode';
                        Occurrence = Required;
                    }
                    fieldattribute(DeviceId; _RequestBuffer.POSUnitNo)
                    {
                        XmlName = 'DeviceId';
                        Occurrence = Optional;
                    }
                    fieldattribute(SalesDocumentNo; _RequestBuffer.SalesDocumentNo)
                    {
                        XmlName = 'DocumentNo';
                        Occurrence = Optional;
                    }

                    trigger OnBeforeInsertRecord()
                    begin
                        _EntryNumber += 1;
                        _RequestBuffer.EntryNo := _EntryNumber;
                    end;
                }

            }
            textelement(_Response)
            {
                MinOccurs = Zero;
                MaxOccurs = Once;
                XmlName = 'Response';

                tableelement(_ResponseBuffer; "NPR DocLXCityCardHistory")
                {
                    MinOccurs = Once;
                    MaxOccurs = Unbounded;
                    XmlName = 'Card';
                    UseTemporary = true;

                    fieldattribute(Id; _ResponseBuffer.EntryNo)
                    {
                        XmlName = 'EntryNo';
                        Occurrence = Required;
                    }
                    fieldattribute(CardNumber; _ResponseBuffer.CardNumber)
                    {
                        XmlName = 'CardNumber';
                        Occurrence = Required;
                    }
                    fieldattribute(LocationCode; _ResponseBuffer.LocationCode)
                    {
                        XmlName = 'LocationCode';
                        Occurrence = Required;
                    }
                    fieldattribute(DeviceId; _ResponseBuffer.POSUnitNo)
                    {
                        XmlName = 'DeviceId';
                        Occurrence = Optional;
                    }
                    fieldattribute(SalesDocumentNo; _ResponseBuffer.SalesDocumentNo)
                    {
                        XmlName = 'DocumentNo';
                        Occurrence = Optional;
                    }
                    textelement(CardInfo)
                    {
                        XmlName = 'CardInfo';
                        MinOccurs = Zero;
                        MaxOccurs = Once;

                        fieldattribute(ResponseCode; _ResponseBuffer.RedemptionResultCode)
                        {
                            XmlName = 'ResponseCode';
                            Occurrence = Required;
                        }
                        fieldattribute(ResponseMessage; _ResponseBuffer.RedemptionResultMessage)
                        {
                            XmlName = 'ResponseMessage';
                            Occurrence = Required;
                        }
                        fieldelement(ArticleId; _ResponseBuffer.ArticleId)
                        {
                            XmlName = 'ArticleId';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(ArticleName; _ResponseBuffer.ArticleName)
                        {
                            XmlName = 'ArticleName';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(ValidTimeSpan; _ResponseBuffer.ValidTimeSpan)
                        {
                            XmlName = 'ValidTimeSpan';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(ShopKey; _ResponseBuffer.ShopKey)
                        {
                            XmlName = 'ShopKey';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(CategoryName; _ResponseBuffer.CategoryName)
                        {
                            XmlName = 'CategoryName';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(ActivationDate; _ResponseBuffer.ActivationDate)
                        {
                            XmlName = 'ActivationDate';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(ValidUntilDate; _ResponseBuffer.ValidUntilDate)
                        {
                            XmlName = 'ValidUntilDate';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(ValidatedAtDateTime; _ResponseBuffer.ValidatedAtDateTime)
                        {
                            XmlName = 'ValidatedAtDateTime';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                    }

                    textelement(CouponInfo)
                    {
                        XmlName = 'CouponInfo';
                        MinOccurs = Zero;
                        MaxOccurs = Once;

                        fieldattribute(ResponseCode; _ResponseBuffer.CouponResultCode)
                        {
                            XmlName = 'ResponseCode';
                            Occurrence = Optional;
                        }

                        fieldattribute(ResponseMessage; _ResponseBuffer.CouponResultMessage)
                        {
                            XmlName = 'ResponseMessage';
                            Occurrence = Optional;
                        }
                        fieldelement(CouponId; _ResponseBuffer.CouponNo)
                        {
                            XmlName = 'CouponId';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }

                        fieldelement(CouponType; _ResponseBuffer.CouponType)
                        {
                            XmlName = 'CouponType';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }
                        fieldelement(CouponReferenceNo; _ResponseBuffer.CouponReferenceNo)
                        {
                            XmlName = 'CouponReferenceNo';
                            MinOccurs = Zero;
                            MaxOccurs = Once;
                        }

                        trigger OnBeforePassVariable()
                        begin
                            if (_ResponseBuffer.CouponReferenceNo = '') then
                                CurrXMLport.Skip();
                        end;
                    }
                }
            }
        }
    }

    internal procedure GetCityCardRequest(var TempRequestBuffer: Record "NPR DocLXCityCardHistory" temporary)
    begin
        TempRequestBuffer.Copy(_RequestBuffer, true);
    end;

    internal procedure SetCityCardResponse(var TempResponseBuffer: Record "NPR DocLXCityCardHistory" temporary)
    begin
        _ResponseBuffer.Copy(TempResponseBuffer, true);
    end;

    var
        _EntryNumber: Integer;
}