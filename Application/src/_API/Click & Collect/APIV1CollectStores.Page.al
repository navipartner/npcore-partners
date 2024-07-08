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
                    Caption = 'Code', Locked = true;
                }
                field(companyName; Rec."Company Name")
                {
                    Caption = 'Company Name', Locked = true;
                }
                field(name; Rec.Name)
                {
                    Caption = 'Name', Locked = true;
                }
                field(localStore; Rec."Local Store")
                {
                    Caption = 'Local Store', Locked = true;
                }
                field(openingHourSet; Rec."Opening Hour Set")
                {
                    Caption = 'Opening Hour Set', Locked = true;
                }

                field(storeStockItemUrl; Rec."Store Stock Item Url")
                {
                    Caption = 'Store Stock Item Url', Locked = true;
                }
                field(storeStockStatusUrl; Rec."Store Stock Status Url")
                {
                    Caption = 'Store Stock Status Url', Locked = true;
                }
                field(serviceUrl; Rec."Service Url")
                {
                    Caption = 'Service Url', Locked = true;
                }
                field(eMail; Rec."E-mail")
                {
                    Caption = 'E-mail', Locked = true;
                }
                field(mobilePhoneNo; Rec."Mobile Phone No.")
                {
                    Caption = 'Mobile Phone No.', Locked = true;
                }
                field(salespersonCode; Rec."Salesperson Code")
                {
                    Caption = 'Salesperson Code', Locked = true;
                }
                field(locationCode; Rec."Location Code")
                {
                    Caption = 'Location Code', Locked = true;
                }

                field(billToCustomerNo; Rec."Bill-to Customer No.")
                {
                    Caption = 'Bill-to Customer No.', Locked = true;
                }

                field(prepaymentAccountNo; Rec."Prepayment Account No.")
                {
                     Caption = 'Prepayment Account No.', Locked = true;
                }

                field(contactName; Rec."Contact Name")
                {
                    Caption = 'Contact Name', Locked = true;
                }

                field(contactName2; Rec."Contact Name 2")
                {
                    Caption = 'Contact Name 2', Locked = true;
                }
                field(contactAddress; Rec."Contact Address")
                {
                    Caption = 'Contact Address', Locked = true;
                }

                field(contactAddress2; Rec."Contact Address 2")
                {
                    Caption = 'Contact Address 2', Locked = true;
                }

                field(contactPostCode; Rec."Contact Post Code")
                {
                    Caption = 'Contact Post Code', Locked = true;
                }

                field(contactCity; Rec."Contact City")
                {
                    Caption = 'Contact City', Locked = true;
                }
                field(contactCountryRegionCode; Rec."Contact Country/Region Code")
                {
                    Caption = 'Contact Country/Region Code', Locked = true;
                }

                field(contactCounty; Rec."Contact County")
                {
                    Caption = 'Contact County', Locked = true;
                }

                field(contactPhoneNo; Rec."Contact Phone No.")
                {
                    Caption = 'Contact Phone No.', Locked = true;
                }

                field(contactEmail; Rec."Contact E-mail")
                {
                    Caption = 'Contact E-mail', Locked = true;
                }

                field(contactFaxNo; Rec."Contact Fax No.")
                {
                    Caption = 'Contact Fax No.', Locked = true;
                }

                field(storeUrl; Rec."Store Url")
                {
                    Caption = 'Store Url', Locked = true;
                }

                field(geolocationLatitude; Rec."Geolocation Latitude")
                {
                    Caption = 'Geolocation Latitude', Locked = true;
                }
                field(geolocationLongitude; Rec."Geolocation Longitude")
                {
                    Caption = 'Geolocation Longitude', Locked = true;
                }
                part(openingHours; "NPR APIV1 Store Opening Hours")
                {
                    Caption = 'Store Opening Hours', Locked = true;
                    EntityName = 'storeOpeningHour';
                    EntitySetName = 'storeOpeningHours';
                    SubPageLink = Store = field(Code);
                }
            }
        }
    }

}
