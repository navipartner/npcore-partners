xmlport 6151154 "NPR M2 Add Shipto Address"
{
    Caption = 'Add Shipto Address';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(AddShiptoAddress)
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

                        trigger OnBeforeInsertRecord()
                        begin

                            TmpShipToAddressRequest.Code := Format(TmpShipToAddressRequest.Count() + 1);
                        end;
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

    procedure GetRequest(var TmpAccount: Record Contact temporary; var TmpShipToAddress: Record "Ship-to Address" temporary)
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

    procedure SetResponse(var TmpShiptoAddress: Record "Ship-to Address" temporary)
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

    procedure SetErrorResponse(ErrorMessage: Text)
    begin
        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;
}