page 6151196 "NPR NpCs Store Card"
{
    Caption = 'Collect Store Card';
    PageType = Card;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    field("Code"; Rec.Code)
                    {
                        ApplicationArea = All;
                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                    }
                    field("Company Name"; Rec."Company Name")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Company Name field';
                    }
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Name field';
                    }
                    field("Local Store"; Rec."Local Store")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Local Store field';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Opening Hour Set"; Rec."Opening Hour Set")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Opening Hour Set field';
                    }
                    field("Magento Description"; Format(Rec."Magento Description".HasValue))
                    {
                        ApplicationArea = All;
                        Caption = 'Magento Description';
                        ToolTip = 'Specifies the value of the Magento Description field';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            RecRef: RecordRef;
                            FieldRef: FieldRef;
                        begin
                            RecRef.GetTable(Rec);
                            FieldRef := RecRef.Field(Rec.FieldNo("Magento Description"));
                            if MagentoFunctions.NaviEditorEditBlob(FieldRef) then begin
                                RecRef.SetTable(Rec);
                                Rec.Modify(true);
                            end;
                        end;
                    }
                }
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Store Stock Item Url"; Rec."Store Stock Item Url")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store Stock Item Url field';
                        Importance = Additional;
                    }
                    field("Store Stock Status Url"; Rec."Store Stock Status Url")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Store Stock Status Url field';
                        Importance = Additional;
                    }
                    field("Service Url"; Rec."Service Url")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Url field';
                    }
                    field("Service Username"; Rec."Service Username")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Username field';
                    }
                    field("Service Password"; Rec."Service Password")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Service Password field';
                    }
                    field("Geolocation Latitude"; Rec."Geolocation Latitude")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Geolocation Latitude field';
                    }
                    field("Geolocation Longitude"; Rec."Geolocation Longitude")
                    {
                        ApplicationArea = All;
                        ToolTip = 'Specifies the value of the Geolocation Longitude field';
                    }
                }
            }
            group(Order)
            {
                Caption = 'Order';
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Salesperson Code field';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Location Code field';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                }
            }
            group("Store Notification")
            {
                Caption = 'Store Notification';
                field("E-mail"; Rec."E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail field';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Name field';
                }
                field("Contact Name 2"; Rec."Contact Name 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Name 2 field';
                }
                field("Contact Address"; Rec."Contact Address")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Address field';
                }
                field("Contact Address 2"; Rec."Contact Address 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Address 2 field';
                }
                field("Contact Post Code"; Rec."Contact Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Post Code field';
                }
                field("Contact City"; Rec."Contact City")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact City field';
                }
                field("Contact Country/Region Code"; Rec."Contact Country/Region Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Country/Region Code field';
                }
                field("Contact County"; Rec."Contact County")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact County field';
                }
                field("Contact Phone No."; Rec."Contact Phone No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Phone No. field';
                }
                field("Contact E-mail"; Rec."Contact E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact E-mail field';
                }
                field("Contact Fax No."; Rec."Contact Fax No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Contact Fax No. field';
                }
                field("Store Url"; Rec."Store Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Store Url field';
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
                Visible = Rec."Local Store";
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
                PromotedOnly = true;
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
                    NpCsStoresbyDistance.SetFromStoreCode(Rec.Code);
                    NpCsStoresbyDistance.Run();
                end;
            }
            action("Store Stock Items")
            {
                Caption = 'Store Stock Items';
                Image = List;
                RunObject = Page "NPR NpCs Store Stock Items";
                RunPageLink = "Store Code" = FIELD(Code);
                ApplicationArea = All;
                ToolTip = 'Executes the Store Stock Items action';
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
