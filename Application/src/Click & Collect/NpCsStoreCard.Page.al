page 6151196 "NPR NpCs Store Card"
{
    Extensible = False;
    Caption = 'Collect Store Card';
    PageType = Card;
    UsageCategory = None;
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

                        ShowMandatory = true;
                        ToolTip = 'Specifies the value of the Code field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Company Name"; Rec."Company Name")
                    {

                        ToolTip = 'Specifies the value of the Company Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field(Name; Rec.Name)
                    {

                        ToolTip = 'Specifies the value of the Name field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Local Store"; Rec."Local Store")
                    {

                        ToolTip = 'Specifies the value of the Local Store field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    field("Opening Hour Set"; Rec."Opening Hour Set")
                    {

                        ToolTip = 'Specifies the value of the Opening Hour Set field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Magento Description"; Format(Rec."Magento Description".HasValue))
                    {

                        Caption = 'Magento Description';
                        ToolTip = 'Specifies the value of the Magento Description field';
                        ApplicationArea = NPRRetail;

                        trigger OnAssistEdit()
                        var
                            MagentoFunctions: Codeunit "NPR Magento Functions";
                            TempBlob: Codeunit "Temp Blob";
                            OutStr: OutStream;
                            InStr: InStream;
                        begin
                            TempBlob.CreateOutStream(OutStr);
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

                        ToolTip = 'Specifies the value of the Store Stock Item Url field';
                        Importance = Additional;
                        ApplicationArea = NPRRetail;
                    }
                    field("Store Stock Status Url"; Rec."Store Stock Status Url")
                    {

                        ToolTip = 'Specifies the value of the Store Stock Status Url field';
                        Importance = Additional;
                        ApplicationArea = NPRRetail;
                    }
                    field("Service Url"; Rec."Service Url")
                    {

                        ToolTip = 'Specifies the value of the Service Url field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Authorization)
                    {
                        Caption = 'Authorization';

                        field(AuthType; Rec.AuthType)
                        {
                            ApplicationArea = NPRRetail;
                            Tooltip = 'Specifies the Authorization Type.';

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

                                ToolTip = 'Specifies the value of the Service Username field';
                                ApplicationArea = NPRRetail;
                            }
                            field("API Password"; pw)
                            {
                                ToolTip = 'Specifies the value of the User Password field';
                                ApplicationArea = NPRRetail;
                                Caption = 'API Password';
                                ExtendedDatatype = Masked;
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
                                ToolTip = 'Specifies the OAuth2.0 Setup Code.';
                            }
                        }
                    }

                    field("Geolocation Latitude"; Rec."Geolocation Latitude")
                    {

                        ToolTip = 'Specifies the value of the Geolocation Latitude field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Geolocation Longitude"; Rec."Geolocation Longitude")
                    {

                        ToolTip = 'Specifies the value of the Geolocation Longitude field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            group(Order)
            {
                Caption = 'Order';
                field("Salesperson Code"; Rec."Salesperson Code")
                {

                    ToolTip = 'Specifies the value of the Salesperson Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Location Code"; Rec."Location Code")
                {

                    ToolTip = 'Specifies the value of the Location Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {

                    ToolTip = 'Specifies the value of the Bill-to Customer No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Prepayment Account No."; Rec."Prepayment Account No.")
                {

                    ToolTip = 'Specifies the value of the Prepayment Account No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            group("Store Notification")
            {
                Caption = 'Store Notification';
                field("E-mail"; Rec."E-mail")
                {

                    ToolTip = 'Specifies the value of the E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Mobile Phone No."; Rec."Mobile Phone No.")
                {

                    ToolTip = 'Specifies the value of the Mobile Phone No. field';
                    ApplicationArea = NPRRetail;
                }
            }
            group(Contact)
            {
                Caption = 'Contact';
                field("Contact Name"; Rec."Contact Name")
                {

                    ToolTip = 'Specifies the value of the Contact Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Name 2"; Rec."Contact Name 2")
                {

                    ToolTip = 'Specifies the value of the Contact Name 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Address"; Rec."Contact Address")
                {

                    ToolTip = 'Specifies the value of the Contact Address field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Address 2"; Rec."Contact Address 2")
                {

                    ToolTip = 'Specifies the value of the Contact Address 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Post Code"; Rec."Contact Post Code")
                {

                    ToolTip = 'Specifies the value of the Contact Post Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact City"; Rec."Contact City")
                {

                    ToolTip = 'Specifies the value of the Contact City field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Country/Region Code"; Rec."Contact Country/Region Code")
                {

                    ToolTip = 'Specifies the value of the Contact Country/Region Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact County"; Rec."Contact County")
                {

                    ToolTip = 'Specifies the value of the Contact County field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Phone No."; Rec."Contact Phone No.")
                {

                    ToolTip = 'Specifies the value of the Contact Phone No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact E-mail"; Rec."Contact E-mail")
                {

                    ToolTip = 'Specifies the value of the Contact E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("Contact Fax No."; Rec."Contact Fax No.")
                {

                    ToolTip = 'Specifies the value of the Contact Fax No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Store Url"; Rec."Store Url")
                {

                    ToolTip = 'Specifies the value of the Store Url field';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Workflows; "NPR NpCs Store Card Workflows")
            {
                Caption = 'Workflows';
                SubPageLink = "Store Code" = FIELD(Code);
                ApplicationArea = NPRRetail;

            }
            part("POS Relations"; "NPR NpCs Store Card POSRelat.")
            {
                Caption = 'POS Relations';
                SubPageLink = "Store Code" = FIELD(Code);
                Visible = Rec."Local Store";
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Validate Store Setup action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Update Contact Information action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Show Address action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Show Geolocation action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Stores by Distance action';
                ApplicationArea = NPRRetail;

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

                ToolTip = 'Executes the Store Stock Items action';
                ApplicationArea = NPRRetail;
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
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        NpCsStoreMgt: Codeunit "NPR NpCs Store Mgt.";
    begin
        if not NpCsStoreMgt.TryGetCollectService(Rec) then
            exit(Confirm(Text000, false));
    end;

    var
        [InDataSet]
        pw: Text[200];

        [InDataSet]
        IsBasicAuthVisible, IsOAuth2Visible : Boolean;
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
        Text000: Label 'Error in Store Setup\\Close anway?';
        Text001: Label 'Store Setup validated successfully';
}
