page 6151196 "NpCs Store Card"
{
    // NPR5.50/MHA /20190531  CASE 345261 Object created - Collect in Store

    Caption = 'Collect Store Card';
    PageType = Card;
    SourceTable = "NpCs Store";

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                group(Control6014404)
                {
                    ShowCaption = false;
                    field("Code";Code)
                    {
                        ShowMandatory = true;
                    }
                    field("Company Name";"Company Name")
                    {
                    }
                    field(Name;Name)
                    {
                    }
                    field("Local Store";"Local Store")
                    {

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                }
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Service Url";"Service Url")
                    {
                    }
                    field("Service Username";"Service Username")
                    {
                    }
                    field("Service Password";"Service Password")
                    {
                    }
                    field("Geolocation Latitude";"Geolocation Latitude")
                    {
                    }
                    field("Geolocation Longitude";"Geolocation Longitude")
                    {
                    }
                }
            }
            group("Order")
            {
                Caption = 'Order';
                field("Salesperson Code";"Salesperson Code")
                {
                }
                field("Location Code";"Location Code")
                {
                }
                field("Bill-to Customer No.";"Bill-to Customer No.")
                {
                }
                field("Prepayment Account No.";"Prepayment Account No.")
                {
                }
            }
            group("Store Notification")
            {
                Caption = 'Store Notification';
                field("E-mail";"E-mail")
                {
                }
                field("Mobile Phone No.";"Mobile Phone No.")
                {
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name";"Contact Name")
                {
                }
                field("Contact Name 2";"Contact Name 2")
                {
                }
                field("Contact Address";"Contact Address")
                {
                }
                field("Contact Address 2";"Contact Address 2")
                {
                }
                field("Contact Post Code";"Contact Post Code")
                {
                }
                field("Contact City";"Contact City")
                {
                }
                field("Contact Country/Region Code";"Contact Country/Region Code")
                {
                }
                field("Contact County";"Contact County")
                {
                }
                field("Contact Phone No.";"Contact Phone No.")
                {
                }
                field("Contact E-mail";"Contact E-mail")
                {
                }
            }
            part(Workflows;"NpCs Store Card Workflows")
            {
                Caption = 'Workflows';
                SubPageLink = "Store Code"=FIELD(Code);
                Visible = (NOT "Local Store");
            }
            part("POS Relations";"NpCs Store Card POS Relations")
            {
                Caption = 'POS Relations';
                SubPageLink = "Store Code"=FIELD(Code);
                Visible = "Local Store";
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Store Setup")
            {
                Caption = 'Validate Store Setup';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
                begin
                    if NpCsStoreMgt.TryGetCollectService(Rec) then
                      Message(Text001)
                    else
                      Error(GetLastErrorText);
                end;
            }
            action("Update Contact Information")
            {
                Caption = 'Update Contact Information';
                Image = User;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.UpdateContactInfo(Rec);
                    CurrPage.Update(false);
                end;
            }
            action("Show Address")
            {
                Caption = 'Show Address';
                Image = Map;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.ShowAddress(Rec);
                end;
            }
            action("Show Geolocation")
            {
                Caption = 'Show Geolocation';
                Image = Map;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.ShowGeolocation(Rec);
                end;
            }
        }
        area(navigation)
        {
            action("Stores by Distance")
            {
                Caption = 'Stores by Distance';
                Image = List;

                trigger OnAction()
                var
                    NpCsStoresbyDistance: Page "NpCs Stores by Distance";
                begin
                    Clear(NpCsStoresbyDistance);
                    NpCsStoresbyDistance.SetFromStoreCode(Code);
                    NpCsStoresbyDistance.Run;
                end;
            }
        }
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpCsStoreMgt: Codeunit "NpCs Store Mgt.";
    begin
        if not NpCsStoreMgt.TryGetCollectService(Rec) then
          exit(Confirm(Text000,false));
    end;

    var
        Text000: Label 'Error in Store Setup\\Close anway?';
        Text001: Label 'Store Setup validated successfully';
}

