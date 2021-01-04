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
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field("Company Name"; "Company Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Company Name field';
                    }
                    field(Name; Name)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Local Store"; "Local Store")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Local Store field';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Opening Hour Set"; "Opening Hour Set")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Opening Hour Set field';
                    }
                }
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Service Url"; "Service Url")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Url field';
                    }
                    field("Service Username"; "Service Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Username field';
                    }
                    field("Service Password"; "Service Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Password field';
                    }
                    field("Geolocation Latitude"; "Geolocation Latitude")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Geolocation Latitude field';
                    }
                    field("Geolocation Longitude"; "Geolocation Longitude")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Geolocation Longitude field';
                    }
                }
            }
            group(Order)
            {
                Caption = 'Order';
                field("Salesperson Code"; "Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Location Code"; "Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Bill-to Customer No."; "Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                }
                field("Prepayment Account No."; "Prepayment Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                }
            }
            group("Store Notification")
            {
                Caption = 'Store Notification';
                field("E-mail"; "E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail field';
                }
                field("Mobile Phone No."; "Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name"; "Contact Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Name field';
                }
                field("Contact Name 2"; "Contact Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Name 2 field';
                }
                field("Contact Address"; "Contact Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Address field';
                }
                field("Contact Address 2"; "Contact Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Address 2 field';
                }
                field("Contact Post Code"; "Contact Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Post Code field';
                }
                field("Contact City"; "Contact City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact City field';
                }
                field("Contact Country/Region Code"; "Contact Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Country/Region Code field';
                }
                field("Contact County"; "Contact County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact County field';
                }
                field("Contact Phone No."; "Contact Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Phone No. field';
                }
                field("Contact E-mail"; "Contact E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact E-mail field';
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
                ToolTip = 'Executes the Validate Store Setup action';

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
                ToolTip = 'Executes the Update Contact Information action';

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
                ToolTip = 'Executes the Show Address action';

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
                ToolTip = 'Executes the Show Geolocation action';

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
                ToolTip = 'Executes the Stores by Distance action';

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

