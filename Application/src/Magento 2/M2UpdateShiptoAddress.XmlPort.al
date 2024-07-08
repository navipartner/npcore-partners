xmlport 6151155 "NPR M2 Update Shipto Address"
{
    Caption = 'Add Shipto Address';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(UpdateShiptoAddress)
        {
            textelement(Request)
            {
                MaxOccurs = Once;
                tableelement(tmpaccountrequest; Contact)
                {
                    MaxOccurs = Once;
                    XmlName = 'Account';
                    UseTemporary = true;
                    fieldattribute(Id; TmpAccountRequest."No.")
                    {
                    }
                }
                textelement(shiptoaddressrequest)
                {
                    MaxOccurs = Once;
                    XmlName = 'ShiptoAddress';
                    tableelement(tmpshiptoaddressrequest; "Ship-to Address")
                    {
                        XmlName = 'Address';
                        UseTemporary = true;
                        fieldattribute(Id; TmpShipToAddressRequest.Code)
                        {
                        }
                        fieldelement(Name; TmpShipToAddressRequest.Name)
                        {
                        }
                        fieldelement(Name2; TmpShipToAddressRequest."Name 2")
                        {
                        }
                        fieldelement(Address; TmpShipToAddressRequest.Address)
                        {
                        }
                        fieldelement(Address2; TmpShipToAddressRequest."Address 2")
                        {
                        }
                        fieldelement(Postcode; TmpShipToAddressRequest."Post Code")
                        {
                        }
                        fieldelement(City; TmpShipToAddressRequest.City)
                        {
                        }
                        fieldelement(County; tmpshiptoaddressrequest.County)
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(CountryCode; TmpShipToAddressRequest."Country/Region Code")
                        {
                        }
                        fieldelement(Email; TmpShipToAddressRequest."E-Mail")
                        {
                        }
                        fieldelement(Telephone; TmpShipToAddressRequest."Phone No.")
                        {
                        }
                        fieldelement(Contact; TmpShipToAddressRequest.Contact)
                        {
                        }
                    }
                }
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
                        MaxOccurs = Once;
                    }
                }
                textelement(ShipTo)
                {
                    MaxOccurs = Once;
                    tableelement(tmpshiptoaddressresponse; "Ship-to Address")
                    {
                        MinOccurs = Zero;
                        XmlName = 'ShipToAddress';
                        UseTemporary = true;
                        fieldattribute(Id; TmpShipToAddressResponse.Code)
                        {
                        }
                        textattribute(shiptoeditable)
                        {
                            XmlName = 'Editable';

                            trigger OnBeforePassVariable()
                            begin
                                ShipToEditable := 'true';
                            end;
                        }
                        textelement(shiptoaddress)
                        {
                            XmlName = 'Address';
                            fieldelement(Name; TmpShipToAddressResponse.Name)
                            {
                            }
                            fieldelement(Name2; TmpShipToAddressResponse."Name 2")
                            {
                            }
                            fieldelement(Address; TmpShipToAddressResponse.Address)
                            {
                            }
                            fieldelement(Address2; TmpShipToAddressResponse."Address 2")
                            {
                            }
                            fieldelement(Postcode; TmpShipToAddressResponse."Post Code")
                            {
                            }
                            fieldelement(City; TmpShipToAddressResponse.City)
                            {
                            }
                            fieldelement(County; tmpshiptoaddressresponse.County)
                            {
                            }
                            textelement(shiptoaddresscountry)
                            {
                                XmlName = 'Country';
                                fieldattribute(Code; TmpShipToAddressResponse."Country/Region Code")
                                {
                                }

                                trigger OnBeforePassVariable()
                                var
                                    CountryRegion: Record "Country/Region";
                                begin
                                    ShipToAddressCountry := '';

                                    if (TmpShipToAddressResponse."Country/Region Code" <> '') then
                                        if (CountryRegion.Get(TmpShipToAddressResponse."Country/Region Code")) then
                                            ShipToAddressCountry := CountryRegion.Name;
                                end;
                            }
                            fieldelement(Email; TmpShipToAddressResponse."E-Mail")
                            {
                            }
                            fieldelement(Telephone; TmpShipToAddressResponse."Phone No.")
                            {
                            }
                            fieldelement(Contact; TmpShipToAddressResponse.Contact)
                            {
                            }
                        }
                    }
                }
            }
        }
    }

    var
        StartTime: Time;
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    internal procedure GetRequest(var TmpAccount: Record Contact temporary; var TmpShipToAddress: Record "Ship-to Address" temporary)
    begin

        StartTime := Time;
        SetErrorResponse('No response.');

        TmpAccountRequest.FindFirst();
        TmpAccount.TransferFields(TmpAccountRequest, true);
        TmpAccount.Insert();

        TmpShipToAddressRequest.FindSet();
        repeat
            TmpShipToAddress.TransferFields(TmpShipToAddressRequest, true);
            TmpShipToAddress.Insert();
        until (TmpShipToAddressRequest.Next() = 0);
    end;

    internal procedure SetResponse(var TmpShiptoAddress: Record "Ship-to Address" temporary)
    begin

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));

        if (not TmpShiptoAddress.FindSet()) then begin
            SetErrorResponse('There was a problem handling the request.');
            exit;
        end;

        repeat
            TmpShipToAddressResponse.TransferFields(TmpShiptoAddress, true);
            TmpShipToAddressResponse.Insert();
        until (TmpShiptoAddress.Next() = 0);
    end;

    internal procedure SetErrorResponse(ErrorMessage: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;
}