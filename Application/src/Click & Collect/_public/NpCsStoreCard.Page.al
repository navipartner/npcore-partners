page 6151196 "NPR NpCs Store Card"
{
    Caption = 'Collect Store Card';
    ContextSensitiveHelpPage = 'docs/retail/click_and_collect/how-to/setup/setup/';
    PageType = Card;
    SourceTable = "NPR NpCs Store";
    UsageCategory = None;

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
                        ApplicationArea = NPRRetail;
                        ShowMandatory = true;
                        ToolTip = 'Specifies unique identifier for this store. ';
                    }
                    field("Company Name"; Rec."Company Name")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies name of the company associated with this store.';
                    }
                    field(Name; Rec.Name)
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies name of the store.';
                    }
                    field("HeyLoyalty Name"; HeyLoyaltyName)
                    {
                        ApplicationArea = NPRHeyLoyalty;
                        Caption = 'HeyLoyalty Name';
                        ToolTip = 'Specifies name used for the store at HeyLoyalty, a loyalty platform.';

                        trigger OnValidate()
                        begin
                            CurrPage.SaveRecord();
                            HLMappedValueMgt.SetMappedValue(Rec.RecordId(), Rec.FieldNo(Name), HeyLoyaltyName, true);
                            CurrPage.Update(false);
                        end;
                    }
                    field("Local Store"; Rec."Local Store")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies whether this is a local store or not.';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Opening Hour Set"; Rec."Opening Hour Set")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies set of opening hours for this store.';
                    }
                    field("Magento Description"; Format(Rec."Magento Description".HasValue))
                    {
                        ApplicationArea = NPRRetail;
                        Caption = 'Magento Description';
                        ToolTip = 'Specifies description associated with this store in Magento, an e-commerce platform.';

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
                            Rec.CalcFields("Magento Description");
                            Rec."Magento Description".CreateInStream(InStr);
                            CopyStream(OutStr, InStr);
                            if MagentoFunctions.NaviEditorEditTempBlob(TempBlob) then begin
                                if TempBlob.HasValue() then begin
                                    TempBlob.CreateInStream(InStr);
                                    Rec."Magento Description".CreateOutStream(OutStr);
                                    CopyStream(OutStr, InStr);
                                end else
                                    Clear(Rec."Magento Description");
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
                        ApplicationArea = NPRRetail;
                        Importance = Additional;
                        ToolTip = 'Specifies URL for store stock items.';
                    }
                    field("Store Stock Status Url"; Rec."Store Stock Status Url")
                    {
                        ApplicationArea = NPRRetail;
                        Importance = Additional;
                        ToolTip = 'Specifies URL for store stock status.';
                    }
                    field("Service Url"; Rec."Service Url")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies URL for the service associated with this store.';
                    }
                    group(Authorization)
                    {
                        Caption = 'Authorization';

                        field(AuthType; Rec.AuthType)
                        {
                            ApplicationArea = NPRRetail;
                            Tooltip = 'Specifies the type of authorization used for this store.';

                            trigger OnValidate()
                            begin
                                CurrPage.Update();
                            end;
                        }
                        group(BasicAuth)
                        {
                            ShowCaption = false;
                            Visible = IsBasicAuthVisible;
                            field("Service Username"; Rec."Service Username")
                            {
                                ApplicationArea = NPRRetail;
                                ToolTip = 'Specifies username for the service associated with this store.';
                            }
                            field("API Password"; pw)
                            {
                                ApplicationArea = NPRRetail;
                                Caption = 'API Password';
                                ExtendedDatatype = Masked;
                                ToolTip = 'Specifies password for the service associated with this store.';
                                trigger OnValidate()
                                begin
                                    if pw <> '' then
                                        WebServiceAuthHelper.SetApiPassword(pw, Rec."API Password Key")
                                    else begin
                                        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
                                            WebServiceAuthHelper.RemoveApiPassword(Rec."API Password Key");
                                    end;
                                end;
                            }
                        }
                        group(OAuth2)
                        {
                            ShowCaption = false;
                            Visible = IsOAuth2Visible;
                            field("OAuth2 Setup Code"; Rec."OAuth2 Setup Code")
                            {
                                ApplicationArea = NPRRetail;
                                ToolTip = 'Specifies OAuth2.0 Setup Code for this store.';
                            }
                        }
                    }
                    field("Geolocation Latitude"; Rec."Geolocation Latitude")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies latitude coordinate for the geolocation of this store.';
                    }
                    field("Geolocation Longitude"; Rec."Geolocation Longitude")
                    {
                        ApplicationArea = NPRRetail;
                        ToolTip = 'Specifies longitude coordinate for the geolocation of this store.';
                    }
                }
            }
            group(Order)
            {
                Caption = 'Order';
                field("Salesperson Code"; Rec."Salesperson Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies code of the salesperson associated with this store.';
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies code representing the location of this store.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies customer number used for billing this store.';
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies account number used for prepayment associated with this store.';
                }
            }
            group("Store Notification")
            {
                Caption = 'Store Notification';
                field("E-mail"; Rec."E-mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies email address associated with this store for notifications.';
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies mobile phone number associated with this store for notifications.';
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name"; Rec."Contact Name")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies name of the primary contact person for this store.';
                }
                field("Contact Name 2"; Rec."Contact Name 2")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies name of the secondary contact person for this store.';
                }
                field("Contact Address"; Rec."Contact Address")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies address of the primary contact person for this store.';
                }
                field("Contact Address 2"; Rec."Contact Address 2")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies address of the secondary contact person for this store.';
                }
                field("Contact Post Code"; Rec."Contact Post Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies postal code of the contact person for this store.';
                }
                field("Contact City"; Rec."Contact City")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies city of the contact person for this store.';
                }
                field("Contact Country/Region Code"; Rec."Contact Country/Region Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies country or region code of the contact person for this store.';
                }
                field("Contact County"; Rec."Contact County")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies county of the contact person for this store.';
                }
                field("Contact Phone No."; Rec."Contact Phone No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies phone number of the contact person for this store.';
                }
                field("Contact E-mail"; Rec."Contact E-mail")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies email address of the contact person for this store.';
                }
                field("Contact Fax No."; Rec."Contact Fax No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies fax number of the contact person for this store.';
                }
                field("Store Url"; Rec."Store Url")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies URL associated with this store for external access.';
                }
            }
            part(Workflows; "NPR NpCs Store Card Workflows")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Workflows';
                SubPageLink = "Store Code" = FIELD(Code);
            }
            part("POS Relations"; "NPR NpCs Store Card POSRelat.")
            {
                ApplicationArea = NPRRetail;
                Caption = 'POS Relations';
                SubPageLink = "Store Code" = FIELD(Code);
                Visible = Rec."Local Store";
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Validate Store Setup")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Validate Store Setup';
                Image = Approve;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Validate the setup of this store for compatibility.';

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
                ApplicationArea = NPRRetail;
                Caption = 'Update Contact Information';
                Image = User;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Update contact information for this store.';

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
                ApplicationArea = NPRRetail;
                Caption = 'Show Address';
                Image = Map;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Display the address of this store on a map.';

                trigger OnAction()
                var
                    NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
                begin
                    NpCsStoreMgt.ShowAddress(Rec);
                end;
            }
            action("Show Geolocation")
            {
                ApplicationArea = NPRRetail;
                Caption = 'Show Geolocation';
                Image = Map;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                PromotedOnly = true;
                ToolTip = 'Display the geolocation coordinates of this store on a map.';

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
                ApplicationArea = NPRRetail;
                Caption = 'Stores by Distance';
                Image = List;
                ToolTip = 'View nearby stores based on distance from this store.';

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
                ApplicationArea = NPRRetail;
                Caption = 'Store Stock Items';
                Image = List;
                RunObject = Page "NPR NpCs Store Stock Items";
                RunPageLink = "Store Code" = FIELD(Code);
                ToolTip = 'View stock items associated with this store.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
    end;

    trigger OnAfterGetRecord()
    begin
        pw := '';
        if WebServiceAuthHelper.HasApiPassword(Rec."API Password Key") then
            pw := '***';
        WebServiceAuthHelper.SetAuthenticationFieldsVisibility(Rec.AuthType, IsBasicAuthVisible, IsOAuth2Visible);
        HeyLoyaltyName := HLMappedValueMgt.GetMappedValue(Rec.RecordId(), Rec.FieldNo(Name), false);
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
    begin
        if not NpCsStoreMgt.TryGetCollectService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        HLMappedValueMgt: Codeunit "NPR HL Mapped Value Mgt.";
        HeyLoyaltyName: Text[100];
        pw: Text[200];
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Error in Store Setup\\Close anyway?';
        Text001: Label 'Store Setup validated successfully';
}