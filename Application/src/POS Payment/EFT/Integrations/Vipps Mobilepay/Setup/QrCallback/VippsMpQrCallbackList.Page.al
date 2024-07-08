page 6151375 "NPR Vipps Mp QrCallback List"
{
    PageType = List;
    Caption = 'Vipps Mobilepay Static QRs';
    Extensible = false;
    UsageCategory = None;
    Editable = False;
    InsertAllowed = True;
    DeleteAllowed = True;
    SourceTable = "NPR Vipps Mp QrCallback";
    CardPageId = "NPR Vipps Mp QrCallback";

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Location Description"; Rec."Location Description")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the Location Description, which is displayed on the user device during a payment.';
                }
                field("Merchant Qr Id"; Rec."Merchant Qr Id")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the unique identifier of the static QR.';
                }
                field("Merchant Serial Number"; Rec."Merchant Serial Number")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies which MSN the static QR belongs too.';
                }
                field("Qr Content"; Rec."Qr Content")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies what the QR code contains.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(CreateNew)
            {
                ApplicationArea = NPRRetail;
                Image = BarCode;
                Description = 'Automatically creates a new static Qr code';
                Caption = 'Auto create new Qr';
                Tooltip = 'Automatically creates a new static Qr code';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                    LblUseExistingRec: Label 'Do you wan''t to create the qr with id "%1" with selected record?';
                begin
                    if ((Rec."Merchant Qr Id" <> '') and (Rec."Qr Content" = '')) then begin
                        if (Confirm(StrSubstNo(LblUseExistingRec, Rec."Merchant Qr Id"))) then begin
                            VippsMpQrMgt.CreateQRBarcode(Rec);
                            exit;
                        end
                    end;
                    VippsMpQrMgt.CreateQRBarcodeUI();
                end;
            }

            action(DeleteQr)
            {
                ApplicationArea = NPRRetail;
                Image = Delete;
                Description = 'Delete the current static QR code, also in Vipps Mobilepay';
                Caption = 'Delete Qr';
                Tooltip = 'Delete the current static QR code, also in Vipps Mobilepay';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                begin
                    VippsMpQrMgt.RemoveQrBarcode(Rec);
                end;
            }

            action(UpdateQr)
            {
                ApplicationArea = NPRRetail;
                Image = UpdateDescription;
                Description = 'Updates location description.';
                Caption = 'Update location description';
                Tooltip = 'Updates location description.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpQRAPI: Codeunit "NPR Vipps Mp QR API";
                    VippsMpStore: Record "NPR Vipps Mp Store";
                    LblNoContentLbl: Label 'Please ensure the Qr is first created in Vipps Mobilepay with either create option.';
                    LblNoMsnLbl: Label 'Please ensure the Qr has a msn value first.';
                begin
                    if (Rec."Qr Content" = '') then begin
                        Message(LblNoContentLbl);
                        exit;
                    end;
                    if (not VippsMpStore.Get(Rec."Merchant Serial Number")) then begin
                        Message(LblNoMsnLbl);
                        exit;
                    end;
                    if (Rec."Qr Content".StartsWith('mobilepaypos')) then begin
                        VippsMpQRAPI.CreateORUpdateMobilepayQr(VippsMpStore, Rec."Merchant Qr Id", Rec."Location Description");
                    end else begin
                        VippsMpQRAPI.CreateOrUpdateCallbackQr(VippsMpStore, Rec."Merchant Qr Id", Rec."Location Description")
                    end;
                end;
            }
            action(Sync)
            {
                ApplicationArea = NPRRetail;
                Image = Refresh;
                Caption = 'Refresh';
                Description = 'Refresh all Qr codes from Vipps Mobilepay.';
                Tooltip = 'Refresh all Qr codes from Vipps Mobilepay.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpVippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                begin
                    VippsMpVippsMpQrMgt.RefreshQrBarcodes();
                end;
            }


            action(CreateMobilePay)
            {
                ApplicationArea = NPRRetail;
                Image = Redo;
                Description = 'Automatically creates a Qr code from an existing beacon id in Mobilepay_V10 integration.';
                Caption = 'Auto Create Mobilepay Qr';
                Tooltip = 'Automatically creates a Qr code from an existing beacon id in Mobilepay_V10 integration.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
                    VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                    VippsMpQrCallback: Record "NPR Vipps Mp QrCallback";
                    POSUnit: Record "NPR POS Unit";
                    EFTSetup: Record "NPR EFT Setup";
                    MobilePayV10UnitSetup: Record "NPR MobilePayV10 Unit Setup";
                    LblError: Label 'No such Mobilepay V10 setup Or beaconId not defined.';
                    LblSamePos: Label 'A matching setup was found for POS %1 %2, do you want to use that setup?';
                    LblUseExistingSetup: Label 'Do you wan''t to use an existing Mobilepay_V10 setup?';
                    LblUseExistingValue: Label 'Click on the "new" button to create a new static qr with the desired old mobilepay beacon id.';
                    LblUseExistingRec: Label 'Do you wan''t to re-create the qr with beacon id "%1" with selected record?';

                begin
                    if ((Rec."Merchant Qr Id" <> '') and (Rec."Qr Content" = '')) then begin
                        if (Confirm(StrSubstNo(LblUseExistingRec, Rec."Merchant Qr Id"))) then begin
                            VippsMpQrMgt.CreateUpdateMobilepayQr(Rec);
                            exit;
                        end;
                    end;
                    POSUnit.Get(VippsMpSetupState.GetCurrentPosUnitNo());
                    EFTSetup.SetFilter("POS Unit No.", POSUnit."No.");
                    EFTSetup.SetFilter("EFT Integration Type", 'MOBILEPAY_V10');
                    if (EFTSetup.FindFirst()) then begin
                        if (Confirm(StrSubstNo(LblSamePos, POSUnit."No.", POSUnit.Name))) then begin
                            MobilePayV10UnitSetup.Get(POSUnit."No.");
                        end;

                    end;
                    if (MobilePayV10UnitSetup."POS Unit No." = '') then begin
                        if (Confirm(LblUseExistingSetup)) then begin
                            EFTSetup.Reset();
                            EFTSetup.SetFilter("EFT Integration Type", 'MOBILEPAY_V10');
                            if (Page.RunModal(Page::"NPR EFT Setup", EFTSetup) <> Action::LookupOK) then
                                exit;
                            if ((not MobilePayV10UnitSetup.Get(EFTSetup."POS Unit No.")) or (MobilePayV10UnitSetup."Beacon ID" = '')) then
                                Error(LblError);
                        end;
                    end;
                    if (VippsMpQrCallback.Get(MobilePayV10UnitSetup."Beacon ID")) then begin
                        VippsMpQrMgt.CreateUpdateMobilepayQrUI(VippsMpQrCallback);
                        exit;
                    end;
                    //Enter manually
                    if (MobilePayV10UnitSetup."Beacon ID" = '') then begin
                        Message(LblUseExistingValue);
                    end else begin
                        VippsMpQrCallback.Init();
                        VippsMpQrCallback."Merchant Qr Id" := MobilePayV10UnitSetup."Beacon ID";
                        VippsMpQrCallback."Location Description" := POSUnit.Name;
                        VippsMpQrCallback."Merchant Serial Number" := VippsMpSetupState.GetCurrentMsn();
                        VippsMpQrCallback.Insert();
                        VippsMpQrMgt.CreateUpdateMobilepayQr(VippsMpQrCallback);
                    end;
                end;
            }
        }
    }
}