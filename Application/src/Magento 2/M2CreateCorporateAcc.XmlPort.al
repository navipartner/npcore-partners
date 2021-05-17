xmlport 6151153 "NPR M2 Create Corporate Acc."
{
    Caption = 'Create Corporate Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(CreateAccount)
        {
            tableelement(tmpcontactrequest; Contact)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    fieldattribute(Email; TmpContactRequest."E-Mail")
                    {
                    }
                    fieldattribute(PasswordHash; TmpContactRequest."NPR Magento Password (Md5)")
                    {
                    }
                    fieldattribute(ExcludeFromMembership; TmpContactRequest."Exclude from Segment")
                    {
                        Occurrence = Optional;
                    }
                }
                textelement(Company)
                {
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
                    fieldelement(Telephone; TmpContactRequest."Phone No.")
                    {
                    }
                }
                tableelement(tmpcustomerrequest; Customer)
                {
                    MaxOccurs = Once;
                    XmlName = 'MagentoDetails';
                    UseTemporary = true;
                    fieldelement(StoreCode; TmpCustomerRequest."NPR Magento Store Code")
                    {
                    }
                    textelement(CustomerGroup)
                    {
                        MaxOccurs = Once;

                        trigger OnBeforePassVariable()
                        begin
                            TmpContactRequest."NPR Magento Customer Group" := CustomerGroup;
                            TmpContactRequest.Modify();
                        end;
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
                    tableelement(tmpmembershiproleresponse; "NPR MM Membership Role")
                    {
                        LinkFields = "Contact No." = FIELD("No.");
                        LinkTable = TmpContactResponse;
                        MinOccurs = Zero;
                        XmlName = 'Membership';
                        UseTemporary = true;
                        fieldelement(MembershipCode; TmpMembershipRoleResponse."Membership Code")
                        {
                        }
                        fieldelement(ExternalMembershipNumber; TmpMembershipRoleResponse."External Membership No.")
                        {
                        }
                        fieldelement(ExternalMemberNumber; TmpMembershipRoleResponse."External Member No.")
                        {
                        }
                        fieldelement(DisplayName; TmpMembershipRoleResponse."Member Display Name")
                        {
                        }
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

        TmpCustomerRequest.FindFirst();
        TmpCustomer.TransferFields(TmpCustomerRequest, true);
        TmpCustomer.Insert();
    end;

    procedure SetResponse(var TmpContact: Record Contact temporary)
    var
        MembershipRole: Record "NPR MM Membership Role";
    begin

        TmpContactResponse.TransferFields(TmpContact, true);

        if not (TmpContact.FindSet()) then begin
            SetErrorResponse('Account creation failed.');
            exit;
        end;

        repeat
            TmpContactResponse.TransferFields(TmpContact, true);
            TmpContactResponse.Insert();
            if (not MembershipRole.SetCurrentKey("Contact No.")) then;
            MembershipRole.SetFilter("Contact No.", '=%1', TmpContact."No.");
            MembershipRole.SetFilter(Blocked, '=%1', false);
            if (MembershipRole.FindFirst()) then begin
                MembershipRole.CalcFields("External Member No.", "External Membership No.", "Member Display Name", "Membership Code");
                TmpMembershipRoleResponse.TransferFields(MembershipRole, true);
                TmpMembershipRoleResponse.Insert();
            end;
        until (TmpContact.Next() = 0);

        ResponseCode := 'OK';
        ResponseMessage := '';
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ErrorMessage: Text)
    begin

        ResponseCode := 'ERROR';
        ResponseMessage := ErrorMessage;
        ExecutionTime := StrSubstNo('%1 (ms)', Format(Time - StartTime, 0, 9));
    end;
}