xmlport 6151157 "NPR M2 Add Account"
{
    Caption = 'Add Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(AddAccount)
        {
            tableelement(tmpcontactrequest; Contact)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(CorporateAccount)
                {
                    MaxOccurs = Once;
                    fieldattribute(CorporateId; TmpContactRequest."Company No.")
                    {
                    }
                    fieldattribute(Email; TmpContactRequest."E-Mail")
                    {
                    }
                    fieldattribute(PasswordHash; TmpContactRequest."NPR Magento Password (Md5)")
                    {
                    }
                }
                textelement(Account)
                {
                    MaxOccurs = Once;
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
                        fieldelement(Telephone; TmpContactRequest."Phone No.")
                        {
                        }
                        fieldelement(Email; TmpContactRequest."E-Mail 2")
                        {
                        }
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
        ExecutionTimeLbl: Label '%1 (ms)', Locked = true;

    procedure GetRequest(var TmpContact: Record Contact temporary)
    begin

        StartTime := Time;
        SetErrorResponse('No response.');

        TmpContactRequest.FindFirst();
        TmpContact.TransferFields(TmpContactRequest, true);
        TmpContact.Insert();
    end;

    procedure SetResponse(var TmpContact: Record Contact temporary)
    begin

        TmpContactResponse.TransferFields(TmpContact, true);

        if not (TmpContact.FindSet()) then begin
            SetErrorResponse('Account creation failed.');
            exit;
        end;

        repeat
            TmpContactResponse.TransferFields(TmpContact, true);
            TmpContactResponse.Insert();
        until (TmpContact.Next() = 0);

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ErrorMessage: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo(ExecutionTimeLbl, Format(Time - StartTime, 0, 9));
    end;
}