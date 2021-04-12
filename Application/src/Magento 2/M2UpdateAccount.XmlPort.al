xmlport 6151156 "NPR M2 Update Account"
{
    Caption = 'Update Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(UpdateAccount)
        {
            tableelement(tmpcontactrequest; Contact)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(Id; TmpContactRequest."No.")
                    {
                    }
                }
                textelement(Company)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    fieldelement(VatId; TmpContactRequest."VAT Registration No.")
                    {
                    }
                    fieldelement(CurrencyCode; TmpContactRequest."Currency Code")
                    {
                    }
                }
                textelement(Address)
                {
                    MaxOccurs = Once;
                    textelement(Person)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        fieldelement(FirstName; TmpContactRequest."First Name")
                        {
                        }
                        fieldelement(LastName; TmpContactRequest.Surname)
                        {
                        }
                    }
                    fieldelement(Name; TmpContactRequest."Company Name")
                    {
                    }
                    fieldelement(Name2; TmpContactRequest."Name 2")
                    {
                    }
                    fieldelement(Address; TmpContactRequest.Address)
                    {
                    }
                    fieldelement(Address2; TmpContactRequest."Address 2")
                    {
                    }
                    fieldelement(Postcode; TmpContactRequest."Post Code")
                    {
                    }
                    fieldelement(City; TmpContactRequest.City)
                    {
                    }
                    fieldelement(CountryCode; TmpContactRequest."Country/Region Code")
                    {
                    }
                    fieldelement(Email; TmpContactRequest."E-Mail")
                    {
                    }
                    fieldelement(Telephone; TmpContactRequest."Phone No.")
                    {
                    }
                }
                tableelement(tmpcustomerrequest; Customer)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    XmlName = 'MagentoDetails';
                    UseTemporary = true;
                    fieldelement(StoreCode; TmpCustomerRequest."NPR Magento Store Code")
                    {
                    }
                    textelement(CustomerGroup)
                    {
                        MaxOccurs = Once;
                    }
                    fieldelement(DisplayGroup; TmpCustomerRequest."NPR Magento Display Group")
                    {
                    }
                    fieldelement(PaymentGroup; TmpCustomerRequest."NPR Magento Payment Group")
                    {
                    }
                    fieldelement(ShippingGroup; TmpCustomerRequest."NPR Magento Shipping Group")
                    {
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
                tableelement(tmpcontactresponse; Contact)
                {
                    MinOccurs = Zero;
                    XmlName = 'Account';
                    UseTemporary = true;
                    fieldattribute(Id; TmpContactResponse."No.")
                    {
                    }
                    textattribute(Type)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            case TmpContactResponse.Type of
                                TmpContactResponse.Type::Company:
                                    Type := 'company';
                                TmpContactResponse.Type::Person:
                                    Type := 'person';
                            end;
                        end;
                    }
                    fieldattribute(CorporateId; TmpContactResponse."Company No.")
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassField()
                        begin
                            if (TmpContactResponse.Type = TmpContactResponse.Type::Company) then
                                TmpContactResponse."Company No." := '';
                        end;
                    }
                    fieldelement(Name; TmpContactResponse."Company Name")
                    {
                    }
                    textelement(personresponse)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'Person';
                        fieldelement(FirstName; TmpContactResponse."First Name")
                        {
                            MinOccurs = Zero;
                        }
                        fieldelement(LastName; TmpContactResponse.Surname)
                        {
                            MinOccurs = Zero;
                        }

                        trigger OnBeforePassVariable()
                        begin

                            if (TmpContactResponse."First Name" = '') and (TmpContactResponse.Surname = '') then
                                currXMLport.Skip();
                        end;
                    }
                    fieldelement(Email; TmpContactResponse."E-Mail")
                    {
                    }
                    textelement(accountstatus)
                    {
                        XmlName = 'Status';

                        trigger OnBeforePassVariable()
                        begin

                            case TmpContactResponse."NPR Magento Account Status" of
                                TmpContactResponse."NPR Magento Account Status"::ACTIVE:
                                    AccountStatus := 'active';
                                TmpContactResponse."NPR Magento Account Status"::BLOCKED:
                                    AccountStatus := 'blocked';
                                TmpContactResponse."NPR Magento Account Status"::CHECKOUT_BLOCKED:
                                    AccountStatus := 'checkout_blocked';
                            end;
                        end;
                    }
                    textelement(pricevisibility)
                    {
                        XmlName = 'PriceVisibility';

                        trigger OnBeforePassVariable()
                        begin

                            case TmpContactResponse."NPR Magento Price Visibility" of
                                TmpContactResponse."NPR Magento Price Visibility"::VISIBLE:
                                    PriceVisibility := 'visible';
                                TmpContactResponse."NPR Magento Price Visibility"::HIDDEN:
                                    PriceVisibility := 'hidden';
                            end;
                        end;
                    }
                }
            }
        }
    }

    var
        StartTime: Time;

    procedure GetRequest(var TmpContact: Record Contact temporary; var TmpCustomer: Record Customer temporary)
    begin

        StartTime := Time;
        SetErrorResponse('No response.');

        TmpContactRequest.FindFirst();
        TmpContact.TransferFields(TmpContactRequest, true);
        TmpContact.Insert();

        if (TmpCustomerRequest.FindFirst()) then begin
            ;
            TmpCustomer.TransferFields(TmpCustomerRequest, true);
            TmpCustomer.Insert();
        end;
    end;

    procedure SetResponse(var TmpContact: Record Contact temporary)
    begin

        TmpContactResponse.TransferFields(TmpContact, true);

        if not (TmpContact.FindSet()) then begin
            SetErrorResponse('Account update failed.');
            exit;
        end;

        repeat
            TmpContactResponse.TransferFields(TmpContact, true);
            TmpContactResponse.Insert();
        until (TmpContact.Next() = 0);

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime), 0, 9);
    end;

    procedure SetErrorResponse(ErrorMessage: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime), 0, 9);
    end;
}