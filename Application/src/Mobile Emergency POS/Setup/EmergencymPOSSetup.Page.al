page 6184928 "NPR Emergency mPOS Setup"
{
    PageType = Card;
    UsageCategory = None;
    Extensible = false;
    SourceTable = "NPR Emergency mPOS Setup";
    CardPageId = "NPR Emergency mPOS Setup";

    layout
    {
        area(Content)
        {
            group(General)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Code';
                    ToolTip = 'Specifies the unique Id of the Emergency mPOS Setup.';
                }
                field("NP Pay POS Payment Setup"; Rec."NP Pay POS Payment Setup")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'NP Pay POS Payment Setup';
                    ToolTip = 'Specifies the which NP Pay POS Payment setup to use.';
                }
                field("Cash Payment Method"; Rec."Cash Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Cash Payment Method Code';
                    ToolTip = 'Specifies which Payment Method code to use for cash payments.';
                }
                field("Card Payment Method"; Rec."EFT Payment Method")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Card Payment Method Code';
                    ToolTip = 'Specifies which Payment Method code to use for card payments.';
                }
                field("SMS Header Template"; Rec."SMS Template")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'SMS Template';
                    ToolTip = 'Specifies which SMS template to use when sending SMS receipt.';
                }
                field("E-mail Header Template"; Rec."Email Template")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Email Template';
                    ToolTip = 'Specifies which Email template to use when sending Email receipt.';
                }
                field("CSV Url"; Rec."CSV Url")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'CSV Url';
                    ToolTip = 'Specifies a url from which to download a self-hosted CSV containing Item shortcuts';
                }
                field("Scanner Type"; Rec."Scanner Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Scanner Type';
                    ToolTip = 'Specifies Scanner Type used for Emergency mPOS';
                }
                field("Salespers/Purchaser Code"; Rec."Salespers/Purchaser Code")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Salesperson / Purchaser Code';
                    ToolTip = 'Specifies which Salesperson / Purchaser Code fo which to put the sale under';
                }
                field("POS Unit"; Rec."POS Unit")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POS Unit';
                    ToolTip = 'Specifies POS Unit';
                }
                field("Payment Integration"; Rec."Payment Integration")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Payment Integration';
                    ToolTip = 'Specifies Payment Integration';

                    trigger OnValidate()
                    begin
                        PaymentIntegrationToggle();
                    end;
                }
            }
            group("Tap To Pay Setup")
            {
                Visible = _IsTapToPay;

                field(TapToPayStoreId; Rec."Store Id")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Store Id';
                    ToolTip = 'Specify the unique identifier of the store';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AdyenStoreAPI: Codeunit "NPR Adyen Store API";
                        NPPayPOSPaymentSetup: Record "NPR NP Pay POS Payment Setup";

                        TempRetailList: Record "NPR Retail List" temporary;
                        Stores: Dictionary of [Text, Text];
                        StoreId: Text;
                        StoreDecription: Text;
                        StoreLookupErrLbl: Label 'Could not fetch stores: %1';
                        PayParameterNotFoundLbl: Label 'NP Pay POS Payment Setup was not found.';
                        NeedApiKeyLbl: Label 'The field ''API Key'' needs to be filled out in NP Pay POS Payment Setup.';
                        NeedMerchantAccountLbl: Label 'The field ''Merchant Account'' needs to be filled out in NP Pay POS Payment Setup.';
                    begin
                        Rec.TestField("POS Unit");
                        Rec.TestField("NP Pay POS Payment Setup");
                        if (not NPPayPOSPaymentSetup.Get(Rec."NP Pay POS Payment Setup")) then begin
                            Message(PayParameterNotFoundLbl);
                            exit(false);
                        end;
                        if not NPPayPOSPaymentSetup.HasAPIKey() then begin
                            Message(NeedApiKeyLbl);
                            exit(false);
                        end;
                        if (NPPayPOSPaymentSetup."Merchant Account" = '') then begin
                            Message(NeedMerchantAccountLbl);
                            exit(false);
                        end;

                        if not (AdyenStoreAPI.GetMerchantStoresIdAndNames(
                            NPPayPOSPaymentSetup.Environment = NPPayPOSPaymentSetup.Environment::Test,
                            NPPayPOSPaymentSetup."Merchant Account",
                            NPPayPOSPaymentSetup.GetApiKey(),
                            Stores)) then begin
                            Message(StrSubstNo(StoreLookupErrLbl, GetLastErrorText()));
                            exit(false);
                        end;
                        foreach StoreId in Stores.Keys() do begin
                            StoreDecription := Stores.Get(StoreId);
                            TempRetailList.Number += 1;
                            TempRetailList.Value := CopyStr(StoreId, 1, MaxStrLen(TempRetailList.Value));
                            TempRetailList.Choice := CopyStr(StoreDecription, 1, MaxStrLen(TempRetailList.Choice));
                            TempRetailList."Package Description" := CopyStr(StoreId, 1, MaxStrLen(TempRetailList."Package Description"));
                            TempRetailList.Insert();
                        end;
                        if Page.RunModal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
                            exit(false);
                        Text := TempRetailList.Value;
                        exit(true);
                    end;
                }
            }
            group("LAN Terminal Setup")
            {
                Visible = _IsLan;

                field("Poi Id"; Rec."Poi Id")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POI ID';
                    ToolTip = 'Specify the unique identifier of the terminal. Format: [device model]-[serial number].';
                }
                field("Terminal Url"; Rec."Terminal Url")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Terminal Url';
                    ToolTip = 'Specify Adyen terminal Url on the same LAN as the POS device.';
                }
            }
            group("Payment Methods")
            {
                part("POS Payment Methods"; "NPR Emergency POS Pay. Methods")
                {
                    Caption = 'Additional POS Payment Methods';
                    ApplicationArea = NPRRetail;
                    SubPageLink = "Emergency POS Setup Code" = field(Code);
                }
            }
        }
        area(Factboxes)
        {
            part("Qr Code"; "NPR Qr Code Scan Part")
            {
                Caption = 'Qr Setup Code';
                ApplicationArea = NPRRetail;
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action("Create QR")
            {
                Caption = 'Create QR Setup Code';
                ToolTip = 'Creates a QR code used for emergency mPOS Setup.';
                Image = Action;
                ApplicationArea = NPRRetail;
                trigger OnAction()
                begin
                    CurrPage."Qr Code".Page.SetQrContent(Rec.GetSetup());
                end;
            }
        }
    }

    local procedure PaymentIntegrationToggle()
    begin
        case Rec."Payment Integration" of
            Rec."Payment Integration"::AdyenLanTerminal:
                begin
                    _IsTapToPay := false;
                    _IsLan := true;
                end;
            Rec."Payment Integration"::AdyenTapToPay:
                begin
                    _IsTapToPay := true;
                    _IsLan := false;
                end;
            Rec."Payment Integration"::None:
                begin
                    _IsTapToPay := false;
                    _IsLan := false;
                end;
        end;
    end;

    trigger OnOpenPage()
    begin
        PaymentIntegrationToggle();
    end;

    var
        _IsTapToPay: Boolean;
        _IsLan: Boolean;
}