page 6151196 "NPR NpCs Store Card"
{
    Caption = 'Collect Store Card';
    PageType = Card;
    UsageCategory = Administration;
    SourceTable = "NPR NpCs Store";

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
                    field("Code"; Code)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                    }
                    field("Company Name"; "Company Name")
                    {
                        ApplicationArea = All;
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                    }
                    field("Local Store"; "Local Store")
                    {
                        ApplicationArea = All;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Opening Hour Set"; "Opening Hour Set")
                    {
                        ApplicationArea = All;
                    }
                }
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                    }
                    field("Service Password"; "Service Password")
                    {
                        ApplicationArea = All;
                    }
                    field("Geolocation Latitude"; "Geolocation Latitude")
                    {
                        ApplicationArea = All;
                    }
                    field("Geolocation Longitude"; "Geolocation Longitude")
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(Order)
            {
                Caption = 'Order';
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                }
                field("Prepayment Account No."; "Prepayment Account No.")
                {
                    ApplicationArea = All;
                }
            }
            group("Store Notification")
            {
                Caption = 'Store Notification';
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name"; "Contact Name")
                {
                    ApplicationArea = All;
                }
                field("Contact Name 2"; "Contact Name 2")
                {
                    ApplicationArea = All;
                }
                field("Contact Address"; "Contact Address")
                {
                    ApplicationArea = All;
                }
                field("Contact Address 2"; "Contact Address 2")
                {
                    ApplicationArea = All;
                }
                field("Contact Post Code"; "Contact Post Code")
                {
                    ApplicationArea = All;
                }
                field("Contact City"; "Contact City")
                {
                    ApplicationArea = All;
                }
                field("Contact Country/Region Code"; "Contact Country/Region Code")
                {
                    ApplicationArea = All;
                }
                field("Contact County"; "Contact County")
                {
                    ApplicationArea = All;
                }
                field("Contact Phone No."; "Contact Phone No.")
                {
                    ApplicationArea = All;
                }
                field("Contact E-mail"; "Contact E-mail")
                {
                    ApplicationArea = All;
                }
            }
            part(Workflows; "NPR NpCs Store Card Workflows")
            {
                Caption = 'Workflows';
                SubPageLink = "Store Code" = FIELD(Code);
                ApplicationArea = All;
            }
            part("POS Relations"; "NPR NpCs Store Card POSRelat.")
            {
                Caption = 'POS Relations';
                SubPageLink = "Store Code" = FIELD(Code);
                Visible = "Local Store";
                ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
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
                ApplicationArea = All;

                trigger OnAction()
                var
                    NpCsStoresbyDistance: Page "NPR NpCs Stores by Distance";
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
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
    begin
        if not NpCsStoreMgt.TryGetCollectService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        Text000: Label 'Error in Store Setup\\Close anway?';
        Text001: Label 'Store Setup validated successfully';
}

