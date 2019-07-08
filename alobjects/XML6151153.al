xmlport 6151153 "M2 Create Corporate Account"
{
    // NPR5.49/TSA /20190307 CASE 347894 Changed PasswordMD5 to PasswordHash
    // NPR5.49/JAKUBV/20190402  CASE 320424-01 Transport NPR5.49 - 1 April 2019

    Caption = 'Create Corporate Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(CreateAccount)
        {
            tableelement(tmpcontactrequest;Contact)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    fieldattribute(Email;TmpContactRequest."E-Mail")
                    {
                    }
                    fieldattribute(PasswordHash;TmpContactRequest."Magento Password (Md5)")
                    {
                    }
                }
                textelement(Company)
                {
                    fieldelement(CompanyName;TmpContactRequest."Company Name")
                    {
                    }
                    fieldelement(VatId;TmpContactRequest."VAT Registration No.")
                    {
                    }
                    textelement(Ean)
                    {
                        MaxOccurs = Once;

                        trigger OnAfterAssignVariable()
                        begin
                            if (Ean <> '') then
                              Error ('EAN code is not supported in W1 version and must be left blank');
                        end;
                    }
                    fieldelement(CurrencyCode;TmpContactRequest."Currency Code")
                    {
                    }
                }
                textelement(Person)
                {
                    MaxOccurs = Once;
                    MinOccurs = Zero;
                    fieldelement(FirstName;TmpContactRequest."First Name")
                    {
                    }
                    fieldelement(Surname;TmpContactRequest.Surname)
                    {
                    }
                }
                textelement(Address)
                {
                    MaxOccurs = Once;
                    fieldelement(Name2;TmpContactRequest."Name 2")
                    {
                    }
                    fieldelement(Address;TmpContactRequest.Address)
                    {
                    }
                    fieldelement(Address2;TmpContactRequest."Address 2")
                    {
                    }
                    fieldelement(Postcode;TmpContactRequest."Post Code")
                    {
                    }
                    fieldelement(City;TmpContactRequest.City)
                    {
                    }
                    fieldelement(CountryCode;TmpContactRequest."Country/Region Code")
                    {
                    }
                    fieldelement(Telephone;TmpContactRequest."Phone No.")
                    {
                    }
                }
                tableelement(tmpcustomerrequest;Customer)
                {
                    MaxOccurs = Once;
                    XmlName = 'MagentoDetails';
                    UseTemporary = true;
                    fieldelement(StoreCode;TmpCustomerRequest."Magento Store Code")
                    {
                    }
                    textelement(CustomerGroup)
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin
                            TmpContactRequest."Magento Customer Group" := CustomerGroup;
                            TmpContactRequest.Modify ();
                        end;
                    }
                    fieldelement(DisplayGroup;TmpCustomerRequest."Magento Display Group")
                    {
                    }
                    fieldelement(PaymentGroup;TmpCustomerRequest."Magento Payment Group")
                    {
                    }
                    fieldelement(ShippingGroup;TmpCustomerRequest."Magento Shipping Group")
                    {
                    }
                }

                trigger OnBeforeInsertRecord()
                begin

                    TmpContactRequest."No." := '1';
                    TmpContactRequest.Type := TmpContactRequest.Type::Company;
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
                        MaxOccurs = Once;
                    }
                }
                tableelement(tmpcontactresponse;Contact)
                {
                    MinOccurs = Zero;
                    XmlName = 'Account';
                    UseTemporary = true;
                    fieldattribute(Id;TmpContactResponse."No.")
                    {
                    }
                    textattribute(Type)
                    {

                        trigger OnBeforePassVariable()
                        begin
                            case TmpContactResponse.Type of
                              TmpContactResponse.Type::Company : Type := 'company';
                              TmpContactResponse.Type::Person : Type := 'person';
                            end;
                        end;
                    }
                    fieldattribute(CorporateId;TmpContactResponse."Company No.")
                    {
                        Occurrence = Optional;

                        trigger OnBeforePassField()
                        begin
                            if (TmpContactResponse.Type = TmpContactResponse.Type::Company) then
                              TmpContactResponse."Company No." := '';
                        end;
                    }
                    fieldelement(Name;TmpContactResponse.Name)
                    {
                    }
                    fieldelement(CompanyName;TmpContactResponse."Company Name")
                    {
                    }
                    fieldelement(Email;TmpContactResponse."E-Mail")
                    {
                    }
                    textelement(accountstatus)
                    {
                        XmlName = 'Status';

                        trigger OnBeforePassVariable()
                        begin

                            case TmpContactResponse."Magento Account Status" of
                              TmpContactResponse."Magento Account Status"::ACTIVE : AccountStatus := 'active';
                              TmpContactResponse."Magento Account Status"::BLOCKED : AccountStatus := 'blocked';
                              TmpContactResponse."Magento Account Status"::CHECKOUT_BLOCKED : AccountStatus := 'checkout_blocked';
                            end;
                        end;
                    }
                    textelement(pricevisibility)
                    {
                        XmlName = 'PriceVisibility';

                        trigger OnBeforePassVariable()
                        begin

                            case TmpContactResponse."Magento Price Visibility" of
                              TmpContactResponse."Magento Price Visibility"::VISIBLE : PriceVisibility := 'visible';
                              TmpContactResponse."Magento Price Visibility"::HIDDEN : PriceVisibility := 'hidden';
                            end;
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
        StartTime: Time;

    procedure GetRequest(var TmpContact: Record Contact temporary;var TmpCustomer: Record Customer temporary)
    begin

        StartTime := Time;
        SetErrorResponse ('No response.');

        TmpContactRequest.FindFirst;
        TmpContact.TransferFields (TmpContactRequest, true);
        TmpContact.Insert ();

        TmpCustomerRequest.FindFirst;
        TmpCustomer.TransferFields  (TmpCustomerRequest, true);
        TmpCustomer.Insert ();
    end;

    procedure SetResponse(var TmpContact: Record Contact temporary)
    begin

        TmpContactResponse.TransferFields (TmpContact, true);

        if not (TmpContact.FindSet ()) then begin
          SetErrorResponse ('Account creation failed.');
          exit;
        end;

        repeat
          TmpContactResponse.TransferFields (TmpContact, true);
          TmpContactResponse.Insert ();
        until (TmpContact.Next () = 0);

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime), 0, 9);
    end;

    procedure SetErrorResponse(ErrorMessage: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime), 0, 9);
    end;
}

