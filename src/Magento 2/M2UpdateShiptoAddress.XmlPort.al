xmlport 6151155 "NPR M2 Update Shipto Address"
{
    // NPR5.48/TSA /20181221 CASE 320424 Intial Version
    // MAG2.23/TSA /20191015 CASE 373151 Added the contact field

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
                        fieldelement(Postcode; TmpShipToAddressRequest."Phone No.")
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
                            var
                                MagentoContactShiptoAdrs: Record "NPR Magento Contact ShipToAdr.";
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
                            fieldelement(Postcode; TmpShipToAddressResponse."Phone No.")
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
        StartTime: Time;

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
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime), 0, 9);

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
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime), 0, 9);
    end;
}

