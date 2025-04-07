page 6150838 "NPR EFT Adyen Unit Setup"
{
    Extensible = False;
    Caption = 'EFT Adyen POS Unit Setup';
    DelayedInsert = false;
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    UsageCategory = None;
    ShowFilter = false;
    SourceTable = "NPR EFT Adyen Unit Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("POS Unit No."; Rec."POS Unit No.")
                {
                    ApplicationArea = NPRRetail;
                    Enabled = False;
                    ToolTip = 'The POS Unit for this configuration';
                }
            }

            group("Tap To Pay Setup")
            {
                Visible = _IsTapToPay;

                field(TapToPayStoreId; Rec."In Person Store Id")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Store Id';
                    ToolTip = 'Specify the unique identifier of the store';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        AdyenStoreAPI: Codeunit "NPR Adyen Store API";
                        EFTSetup: Record "NPR EFT Setup";
                        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
                        EFTAdyenTTPInteg: Codeunit "NPR EFT Adyen TTP Integ.";
                        TempRetailList: Record "NPR Retail List" temporary;
                        Stores: Dictionary of [Text, Text];
                        StoreId: Text;
                        StoreDecription: Text;
                        EftSetupNotFoundLbl: Label 'Could not find a matching EFT setup, ensure you have a record with the relevant POS Unit No. and Integration type.';
                        PayParameterNotFoundLbl: Label 'The payment parameter was not found.';
                        StoreLookupErrLbl: Label 'Could not fetch stores: %1';
                        NeedApiKeyLbl: Label 'The field ''API Key'' needs to be filled out in payment parameters.';
                        NeedMerchantAccountLbl: Label 'The field ''Merchant Account'' needs to be filled out in payment parameters..';
                    begin
                        EFTSetup.SetFilter("POS Unit No.", Rec."POS Unit No.");
                        EFTSetup.SetFilter("EFT Integration Type", EFTAdyenTTPInteg.IntegrationType());
                        if (not EFTSetup.FindFirst()) then begin
                            Message(EftSetupNotFoundLbl);
                            exit(false);
                        end;
                        if (not EFTAdyenPaymTypeSetup.Get(EFTSetup."Payment Type POS")) then begin
                            Message(PayParameterNotFoundLbl);
                            exit(false);
                        end;
                        if not EFTAdyenPaymTypeSetup.HasAPIKey() then begin
                            Message(NeedApiKeyLbl);
                            exit(false);
                        end;
                        if (EFTAdyenPaymTypeSetup."Merchant Account" = '') then begin
                            Message(NeedMerchantAccountLbl);
                            exit(false);
                        end;
                        if not (AdyenStoreAPI.GetMerchantStoresIdAndNames(
                            EFTAdyenPaymTypeSetup.Environment = EFTAdyenPaymTypeSetup.Environment::TEST,
                            EFTAdyenPaymTypeSetup."Merchant Account",
                            EFTAdyenPaymTypeSetup.GetApiKey(),
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
                        if Page.Runmodal(Page::"NPR Retail List", TempRetailList) <> Action::LookupOK then
                            exit(false);
                        Text := TempRetailList.Value;
                        exit(true);
                    end;
                }
            }
            group("Cloud Unit Setup")
            {
                Visible = _IsCloud;
                field(CloudPOIID; Rec.POIID)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POI ID';
                    ToolTip = 'Specify the unique identifier of the terminal. Format: [device model]-[serial number].';
                }
            }
            group("LAN Unit Setup")
            {
                Visible = _IsLan;

                field(LANPOITID; Rec.POIID)
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'POI ID';
                    ToolTip = 'Specify the unique identifier of the terminal. Format: [device model]-[serial number].';
                }
                field(TerminalIP; Rec."Terminal LAN IP")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'LAN IP';
                    ToolTip = 'Specify the IP of the adyen terminal on the same LAN as the POS device. Do not specify the http protcol prefix or the port postfix.';
                }
            }

        }

    }

    procedure SetCloud()
    begin
        _IsCloud := True;
        _IsTapToPay := false;
        _IsLan := false;
    end;

    procedure SetLan()
    begin
        _IsCloud := false;
        _IsTapToPay := false;
        _IsLan := True;
    end;

    procedure SetTapToPay()
    begin
        _IsCloud := false;
        _IsTapToPay := true;
        _IsLan := false;
    end;


    var
        _IsCloud: Boolean;
        _IsTapToPay: Boolean;
        _IsLan: Boolean;
}