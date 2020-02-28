xmlport 6151152 "M2 Get Account"
{
    // NPR5.49/TSA /20181213 CASE 320424 Initial Version
    // NPR5.49/JAKUBV/20190402  CASE 320425-01 Transport NPR5.49 - 1 April 2019
    // MAG2.20/TSA /20190411 CASE 320424 City returned TmpContactResponse::Address 2 - fixed TmpContactResponse::City
    // MAG2.20/TSA /20190423 CASE 345373 Adding Balance LCY and Credit Limit
    // MAG2.20/MHA /20190501  CASE 320423 Mapped <CustomerGroup>
    // MAG2.22/TSA /20190531 CASE 349994 Added Terms subsection for sell-to and bill-to
    // NPR5.51/TSA /20190812 CASE 364644 Added Person section
    // NPR5.51/JAKUBV/20190904  CASE 364282 Transport NPR5.51 - 3 September 2019
    // MAG2.23/TSA /20191015 CASE 373151 Move Person to address, removed CompanyName, added Name, PricesIncludeVat, Contact
    // MAG2.24/TSA /20191119 CASE 372304 Added Membership section

    Caption = 'Get Account';
    Encoding = UTF8;
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(AccountDetails)
        {
            tableelement(tmpcontactrequest;Contact)
            {
                MaxOccurs = Once;
                XmlName = 'Request';
                UseTemporary = true;
                textelement(Account)
                {
                    MaxOccurs = Once;
                    fieldattribute(Id;TmpContactRequest."No.")
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
                tableelement(tmpcontactresponse;Contact)
                {
                    MinOccurs = Zero;
                    XmlName = 'Account';
                    UseTemporary = true;
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
                    fieldattribute(Id;TmpContactResponse."No.")
                    {
                    }
                    textelement(accountaddress)
                    {
                        XmlName = 'Address';
                        textattribute(accounteditable)
                        {
                            XmlName = 'Editable';

                            trigger OnBeforePassVariable()
                            begin
                                AccountEditable := Format (true, 0, 9);
                            end;
                        }
                        textelement(Person)
                        {
                            MaxOccurs = Once;
                            MinOccurs = Zero;
                            fieldelement(FirstName;TmpContactResponse."First Name")
                            {
                                MinOccurs = Zero;
                            }
                            fieldelement(LastName;TmpContactResponse.Surname)
                            {
                                MinOccurs = Zero;
                            }
                        }
                        fieldelement(Name;TmpContactResponse.Name)
                        {
                        }
                        fieldelement(Name2;TmpContactResponse."Name 2")
                        {
                        }
                        fieldelement(Address;TmpContactResponse.Address)
                        {
                        }
                        fieldelement(Address2;TmpContactResponse."Address 2")
                        {
                        }
                        fieldelement(Postcode;TmpContactResponse."Post Code")
                        {
                        }
                        fieldelement(City;TmpContactResponse.City)
                        {
                        }
                        textelement(contactcountry)
                        {
                            XmlName = 'Country';
                            fieldattribute(Code;TmpContactResponse."Country/Region Code")
                            {
                            }

                            trigger OnBeforePassVariable()
                            var
                                CountryRegion: Record "Country/Region";
                            begin
                                ContactCountry := '';

                                if (TmpContactResponse."Country/Region Code" <> '') then
                                  if (CountryRegion.Get (TmpContactResponse."Country/Region Code")) then
                                    ContactCountry := CountryRegion.Name;
                            end;
                        }
                        fieldelement(Email;TmpContactResponse."E-Mail")
                        {
                        }
                        fieldelement(Telephone;TmpContactResponse."Phone No.")
                        {
                        }
                    }
                    tableelement(tmpmembershiproleresponse;"MM Membership Role")
                    {
                        LinkFields = "Contact No."=FIELD("No.");
                        LinkTable = TmpContactResponse;
                        MinOccurs = Zero;
                        XmlName = 'Membership';
                        UseTemporary = true;
                        fieldelement(MembershipCode;TmpMembershipRoleResponse."Membership Code")
                        {
                        }
                        fieldelement(ExternalMembershipNumber;TmpMembershipRoleResponse."External Membership No.")
                        {
                        }
                        fieldelement(ExternalMemberNumber;TmpMembershipRoleResponse."External Member No.")
                        {
                        }
                        fieldelement(DisplayName;TmpMembershipRoleResponse."Member Display Name")
                        {
                        }
                    }
                    tableelement(tmpselltocustomer;Customer)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                        XmlName = 'SellTo';
                        UseTemporary = true;
                        fieldattribute(Id;TmpSellToCustomer."No.")
                        {
                        }
                        textattribute(selltoeditable)
                        {
                            XmlName = 'Editable';

                            trigger OnBeforePassVariable()
                            begin

                                SellToEditable := Format ((TmpContactResponse.Type = TmpContactResponse.Type::Company), 0, 9);
                            end;
                        }
                        fieldelement(VatId;TmpSellToCustomer."VAT Registration No.")
                        {
                        }
                        fieldelement(CurrencyCode;TmpSellToCustomer."Currency Code")
                        {
                        }
                        textelement(selltoaddress)
                        {
                            XmlName = 'Address';
                            tableelement(tmpselltocustomercontact;Contact)
                            {
                                LinkTable = TmpSellToCustomer;
                                MaxOccurs = Once;
                                MinOccurs = Zero;
                                XmlName = 'Person';
                                UseTemporary = true;
                                fieldelement(FirstName;TmpSellToCustomerContact."First Name")
                                {
                                }
                                fieldelement(LastName;TmpSellToCustomerContact.Surname)
                                {
                                }
                            }
                            fieldelement(Name;TmpSellToCustomer.Name)
                            {
                            }
                            fieldelement(Name2;TmpSellToCustomer."Name 2")
                            {
                            }
                            fieldelement(Address;TmpSellToCustomer.Address)
                            {
                            }
                            fieldelement(Address2;TmpSellToCustomer."Address 2")
                            {
                            }
                            fieldelement(Postcode;TmpSellToCustomer."Post Code")
                            {
                            }
                            fieldelement(City;TmpSellToCustomer.City)
                            {
                            }
                            textelement(selltocountry)
                            {
                                XmlName = 'Country';
                                fieldattribute(Code;TmpSellToCustomer."Country/Region Code")
                                {
                                }

                                trigger OnBeforePassVariable()
                                var
                                    CountryRegion: Record "Country/Region";
                                begin
                                    SellToCountry := '';

                                    if (TmpSellToCustomer."Country/Region Code" <> '') then
                                      if (CountryRegion.Get (TmpSellToCustomer."Country/Region Code")) then
                                        SellToCountry := CountryRegion.Name;
                                end;
                            }
                            fieldelement(Email;TmpSellToCustomer."E-Mail")
                            {
                            }
                            fieldelement(Telephone;TmpSellToCustomer."Phone No.")
                            {
                            }
                        }
                        textelement(selltoterms)
                        {
                            MaxOccurs = Once;
                            XmlName = 'Terms';
                            fieldelement(PriceGroup;TmpSellToCustomer."Customer Price Group")
                            {
                            }
                            fieldelement(DiscountGroup;TmpSellToCustomer."Customer Disc. Group")
                            {
                            }
                            fieldelement(PricesIncludeVat;TmpSellToCustomer."Prices Including VAT")
                            {
                            }
                        }
                    }
                    textelement(BillTo)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Once;
                        tableelement(tmpbilltocustomer;Customer)
                        {
                            MinOccurs = Zero;
                            XmlName = 'BillToAddress';
                            UseTemporary = true;
                            fieldattribute(Id;TmpBillToCustomer."No.")
                            {
                            }
                            textattribute(billtoeditable)
                            {
                                XmlName = 'Editable';

                                trigger OnBeforePassVariable()
                                begin

                                    BillToEditable := Format (
                                      (TmpContactResponse.Type = TmpContactResponse.Type::Company) and
                                      ((TmpBillToCustomer."No." = '') or (TmpBillToCustomer."No." = TmpSellToCustomer."No."))
                                      , 0, 9);
                                end;
                            }
                            fieldelement(BalanceLCY;TmpBillToCustomer."Balance (LCY)")
                            {
                            }
                            fieldelement(CreditLimitLCY;TmpBillToCustomer."Credit Limit (LCY)")
                            {
                            }
                            textelement(billtoaddress)
                            {
                                XmlName = 'Address';
                                tableelement(tmpbilltocustomercontact;Contact)
                                {
                                    LinkTable = TmpBillToCustomer;
                                    MaxOccurs = Once;
                                    MinOccurs = Zero;
                                    XmlName = 'Person';
                                    UseTemporary = true;
                                    fieldelement(FirstName;TmpBillToCustomerContact."First Name")
                                    {
                                    }
                                    fieldelement(LastName;TmpBillToCustomerContact.Surname)
                                    {
                                    }
                                }
                                fieldelement(Name;TmpBillToCustomer.Name)
                                {
                                }
                                fieldelement(Name2;TmpBillToCustomer."Name 2")
                                {
                                }
                                fieldelement(Address;TmpBillToCustomer.Address)
                                {
                                }
                                fieldelement(Address2;TmpBillToCustomer."Address 2")
                                {
                                }
                                fieldelement(Postcode;TmpBillToCustomer."Post Code")
                                {
                                }
                                fieldelement(City;TmpBillToCustomer.City)
                                {
                                }
                                textelement(billtoaddresscountry)
                                {
                                    XmlName = 'Country';
                                    fieldattribute(Code;TmpBillToCustomer."Country/Region Code")
                                    {
                                    }

                                    trigger OnBeforePassVariable()
                                    var
                                        CountryRegion: Record "Country/Region";
                                    begin
                                        BillToAddressCountry := '';

                                        if (TmpBillToCustomer."Country/Region Code" <> '') then
                                          if (CountryRegion.Get (TmpBillToCustomer."Country/Region Code")) then
                                            BillToAddressCountry := CountryRegion.Name;
                                    end;
                                }
                                fieldelement(Email;TmpBillToCustomer."E-Mail")
                                {
                                }
                                fieldelement(Telephone;TmpBillToCustomer."Phone No.")
                                {
                                }
                            }
                            textelement(billtoterms)
                            {
                                MaxOccurs = Once;
                                XmlName = 'Terms';
                                fieldelement(PaymentTerms;TmpBillToCustomer."Payment Terms Code")
                                {
                                }
                            }
                        }
                    }
                    textelement(ShipTo)
                    {
                        MaxOccurs = Once;
                        tableelement(tmpshiptoaddress;"Ship-to Address")
                        {
                            MinOccurs = Zero;
                            XmlName = 'ShipToAddress';
                            UseTemporary = true;
                            fieldattribute(Id;TmpShipToAddress.Code)
                            {
                            }
                            textattribute(shiptoeditable)
                            {
                                XmlName = 'Editable';

                                trigger OnBeforePassVariable()
                                var
                                    MagentoContactShiptoAdrs: Record "Magento Contact Ship-to Adrs.";
                                begin
                                    ShipToEditable := Format (
                                      (TmpContactResponse.Type = TmpContactResponse.Type::Company) or
                                      (MagentoContactShiptoAdrs.Get (TmpShipToAddress."Customer No.", TmpShipToAddress.Code, TmpContactResponse."No."))
                                      , 0, 9);
                                end;
                            }
                            textelement(shiptoaddress)
                            {
                                XmlName = 'Address';
                                fieldelement(Name;TmpShipToAddress.Name)
                                {
                                }
                                fieldelement(Name2;TmpShipToAddress."Name 2")
                                {
                                }
                                fieldelement(Address;TmpShipToAddress.Address)
                                {
                                }
                                fieldelement(Address2;TmpShipToAddress."Address 2")
                                {
                                }
                                fieldelement(Postcode;TmpShipToAddress."Phone No.")
                                {
                                }
                                fieldelement(City;TmpShipToAddress.City)
                                {
                                }
                                textelement(shiptoaddresscountry)
                                {
                                    XmlName = 'Country';
                                    fieldattribute(Code;TmpShipToAddress."Country/Region Code")
                                    {
                                    }

                                    trigger OnBeforePassVariable()
                                    var
                                        CountryRegion: Record "Country/Region";
                                    begin
                                        ShipToAddressCountry := '';

                                        if (TmpShipToAddress."Country/Region Code" <> '') then
                                          if (CountryRegion.Get (TmpShipToAddress."Country/Region Code")) then
                                            ShipToAddressCountry := CountryRegion.Name;
                                    end;
                                }
                                fieldelement(Email;TmpShipToAddress."E-Mail")
                                {
                                }
                                fieldelement(Telephone;TmpShipToAddress."Phone No.")
                                {
                                }
                                fieldelement(Contact;TmpShipToAddress.Contact)
                                {
                                }
                            }
                        }
                    }
                    textelement(MagentoDetails)
                    {
                        textelement(StoreCode)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                StoreCode := TmpSellToCustomer."Magento Store Code";
                            end;
                        }
                        fieldelement(CustomerGroup;TmpContactResponse."Magento Customer Group")
                        {
                        }
                        textelement(DisplayGroup)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                DisplayGroup := TmpSellToCustomer."Magento Display Group";
                            end;
                        }
                        textelement(PaymentGroup)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                PaymentGroup := TmpSellToCustomer."Magento Payment Group";
                            end;
                        }
                        textelement(ShippingGroup)
                        {

                            trigger OnBeforePassVariable()
                            begin
                                ShippingGroup := TmpSellToCustomer."Magento Shipping Group";
                            end;
                        }
                        textelement(PriceVisibility)
                        {

                            trigger OnBeforePassVariable()
                            begin

                                case TmpContactResponse."Magento Price Visibility" of
                                  TmpContactResponse."Magento Price Visibility"::HIDDEN : PriceVisibility := 'hidden';
                                  TmpContactResponse."Magento Price Visibility"::VISIBLE : PriceVisibility := 'visible';
                                end;
                            end;
                        }
                        textelement(AccountStatus)
                        {

                            trigger OnBeforePassVariable()
                            begin

                                case TmpContactResponse."Magento Account Status" of
                                  TmpContactResponse."Magento Account Status"::ACTIVE : AccountStatus := 'active';
                                  TmpContactResponse."Magento Account Status"::BLOCKED : AccountStatus := 'blocked';
                                  TmpContactResponse."Magento Account Status"::CHECKOUT_BLOCKED : AccountStatus := 'checkout_blocked';
                                end;
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

    var
        NPRDocLocalizationProxy: Codeunit "NPR Doc. Localization Proxy";
        StartTime: Time;

    procedure GetRequest() ContactNumber: Code[20]
    begin

        StartTime := Time;
        ResponseCode := 'ERROR';
        ResponseMessage := 'No result.';

        if (not TmpContactRequest.FindFirst ()) then ;
        exit (TmpContactRequest."No.");
    end;

    procedure SetResponse(var TmpContactIn: Record Contact temporary;var TmpSellToCustomerIn: Record Customer temporary;var TmpBillToCustomerIn: Record Customer temporary;var TmpShipToAddressIn: Record "Ship-to Address" temporary)
    var
        ContactBusinessRelation: Record "Contact Business Relation";
        Contact: Record Contact;
        MembershipRole: Record "MM Membership Role";
    begin

        ResponseMessage := 'Contact Id is unknown.';

        if (TmpContactIn.FindFirst ()) then begin
          TmpContactResponse.TransferFields (TmpContactIn, true);
          TmpContactResponse.Insert ();

          //-MAG2.24 [372304]
          if (not MembershipRole.SetCurrentKey ("Contact No.")) then ;
          MembershipRole.SetFilter ("Contact No.", '=%1', TmpContactIn."No.");
          MembershipRole.SetFilter (Blocked, '=%1', false);
          if (MembershipRole.FindFirst ()) then begin
            MembershipRole.CalcFields ("External Member No.", "External Membership No.", "Member Display Name", "Membership Code");
            TmpMembershipRoleResponse.TransferFields (MembershipRole, true);
            TmpMembershipRoleResponse.Insert ();
          end;
          //+MAG2.24 [372304]

          if (TmpSellToCustomerIn.FindFirst ()) then begin
            TmpSellToCustomer.TransferFields (TmpSellToCustomerIn, true);
            TmpSellToCustomer.Insert ();
          end;

          if (TmpBillToCustomerIn.FindFirst ()) then begin
            TmpBillToCustomer.TransferFields (TmpBillToCustomerIn, true);
            TmpBillToCustomer.Insert ();
          end;

          if (TmpShipToAddressIn.FindSet ()) then begin
            repeat
              TmpShipToAddress.TransferFields (TmpShipToAddressIn, true);
              TmpShipToAddress.Insert ();
            until (TmpShipToAddressIn.Next () = 0);
          end;

          //-MAG2.23 [373151]
          if (TmpSellToCustomer."No." <> '') then begin
            ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
            ContactBusinessRelation.SetFilter ("No.", '=%1', TmpSellToCustomer."No.");
            if (ContactBusinessRelation.FindFirst ()) then begin
              if (Contact.Get (ContactBusinessRelation."Contact No.")) then begin
                TmpSellToCustomerContact.TransferFields (Contact);
                TmpSellToCustomerContact.Insert ();
              end;
            end;
          end;

          if (TmpBillToCustomer."No." <> '') then begin
            ContactBusinessRelation.SetFilter ("Link to Table", '=%1', ContactBusinessRelation."Link to Table"::Customer);
            ContactBusinessRelation.SetFilter ("No.", '=%1', TmpBillToCustomer."No.");
            if (ContactBusinessRelation.FindFirst ()) then begin
              if (Contact.Get (ContactBusinessRelation."Contact No.")) then begin
                TmpBillToCustomerContact.TransferFields (Contact);
                TmpBillToCustomerContact.Insert ();
              end;
            end;
          end;
          //+MAG2.23 [373151]

          ResponseCode := 'OK';
          ResponseMessage := ''; //STRSUBSTNO ('%1 %2', TmpBillToCustomer.COUNT, TmpSellToCustomer.count);
        end;

        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
    end;

    procedure SetErrorResponse(ReasonText: Text)
    begin

        ExecutionTime := StrSubstNo ('%1 (ms)', Format (Time - StartTime, 0, 9));
        ResponseCode := 'ERROR';
        ResponseMessage := ReasonText;
    end;

    [TryFunction]
    local procedure TryGetEanNo(Customer: Record Customer temporary;var EanNo: Text)
    var
        TmpEan: Variant;
    begin

        //NPRDocLocalizationProxy.T18_GetFieldValue (Customer, 'Ean No.', TmpEan);
        EanNo := 'NOT IN W1';
    end;
}

