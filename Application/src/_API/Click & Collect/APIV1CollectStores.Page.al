page 6059806 "NPR APIV1 Collect Stores"
{
    APIGroup = 'clickAndCollect';
    APIPublisher = 'navipartner';
    APIVersion = 'v1.0';
    Caption = 'Collect Stores';
    DelayedInsert = true;
    EntityName = 'collectStore';
    EntitySetName = 'collectStores';
    Extensible = false;
    PageType = API;
    SourceTable = "NPR NpCs Store";

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("code"; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(companyName; Rec."Company Name")
                {
                    Caption = 'Company Name';
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(localStore; Rec."Local Store")
                {
                    Caption = 'Local Store';
                }
                field(openingHourSet; Rec."Opening Hour Set")
                {
                    Caption = 'Opening Hour Set';
                }

                field(storeStockItemUrl; Rec."Store Stock Item Url")
                {
                    Caption = 'Store Stock Item Url';
                }
                field(storeStockStatusUrl; Rec."Store Stock Status Url")
                {
                    Caption = 'Store Stock Status Url';
                }
                field(serviceUrl; Rec."Service Url")
                {
                    Caption = 'Service Url';
                }
                field(eMail; Rec."E-mail")
                {
                    Caption = 'E-mail';
                }
                field(mobilePhoneNo; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.';
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code';
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code';
                }

                field(billToCustomerNo; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.';
                }

                field(prepaymentAccountNo; Rec."Prepayment Account No.")
                {
                     Caption = 'Prepayment Account No.';
                }

                field(contactName; Rec."Contact Name")
                {
                    Caption = 'Contact Name';
                }

                field(contactName2; Rec."Contact Name 2")
                {
                    Caption = 'Contact Name 2';
                }
                field(contactAddress; Rec."Contact Address")
                {
                    Caption = 'Contact Address';
                }

                field(contactAddress2; Rec."Contact Address 2")
                {
                    Caption = 'Contact Address 2';
                }

                field(contactPostCode; Rec."Contact Post Code")
                {
                    Caption = 'Contact Post Code';
                }

                field(contactCity; Rec."Contact City")
                {
                    Caption = 'Contact City';
                }
                field(contactCountryRegionCode; Rec."Contact Country/Region Code")
                {
                    Caption = 'Contact Country/Region Code';
                }

                field(contactCounty; Rec."Contact County")
                {
                    Caption = 'Contact County';
                }

                field(contactPhoneNo; Rec."Contact Phone No.")
                {
                    Caption = 'Contact Phone No.';
                }

                field(contactEmail; Rec."Contact E-mail")
                {
                    Caption = 'Contact E-mail';
                }

                field(contactFaxNo; Rec."Contact Fax No.")
                {
                    Caption = 'Contact Fax No.';
                }

                field(storeUrl; Rec."Store Url")
                {
                    Caption = 'Store Url';
                }

                field(geolocationLatitude; Rec."Geolocation Latitude")
                {
                    Caption = 'Geolocation Latitude';
                }
                field(geolocationLongitude; Rec."Geolocation Longitude")
                {
                    Caption = 'Geolocation Longitude';
                }
                part(openingHours; "NPR APIV1 Store Opening Hours")
                {
                    Caption = 'Store Opening Hours';
                    EntityName = 'storeOpeningHour';
                    EntitySetName = 'storeOpeningHours';
                    SubPageLink = Store = field(Code);
                }
            }
        }
    }

}
