xmlport 6150904 "NPR HC Customer"
{
    Caption = 'HC Customer';
    FormatEvaluate = Xml;
    UseDefaultNamespace = true;

    schema
    {
        textelement(customer)
        {
            textelement(updatecustomerinfo)
            {
                tableelement(tempcustomer; Customer)
                {
                    XmlName = 'customerinfo';
                    UseTemporary = true;
                    fieldelement(no; TempCustomer."No.")
                    {
                    }
                    fieldelement(name; TempCustomer.Name)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(searchname; TempCustomer."Search Name")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(name2; TempCustomer."Name 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address; TempCustomer.Address)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(address2; TempCustomer."Address 2")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(city; TempCustomer.City)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(contact; TempCustomer.Contact)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(phoneno; TempCustomer."Phone No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(ouraccountno; TempCustomer."Our Account No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(globaldimension1; TempCustomer."Global Dimension 1 Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(globaldimension2; TempCustomer."Global Dimension 2 Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(currencycode; TempCustomer."Currency Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(customerpricegroup; TempCustomer."Customer Price Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(languagecode; TempCustomer."Language Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(salespersoncode; TempCustomer."Salesperson Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(customerdiscgroup; TempCustomer."Customer Disc. Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(countryregion; TempCustomer."Country/Region Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(billtocustomer; TempCustomer."Bill-to Customer No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(paymentmethod; TempCustomer."Payment Method Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(locationcode; TempCustomer."Location Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(vatregistration; TempCustomer."VAT Registration No.")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(postcode; TempCustomer."Post Code")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(county; TempCustomer.County)
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(email; TempCustomer."E-Mail")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(vatbuspostinggroup; TempCustomer."VAT Bus. Posting Group")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(responsibilitycenter; TempCustomer."Responsibility Center")
                    {
                        MaxOccurs = Once;
                        MinOccurs = Zero;
                    }
                    fieldelement(pricesIncludesVat; TempCustomer."Prices Including VAT")
                    {
                    }
                }
            }
        }
    }
}

