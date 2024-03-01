page 6151375 "NPR Vipps Mp QrCallback List"
{
    PageType = List;
    Caption = 'Vipps Mobilepay Static QRs';
    Extensible = false;
    UsageCategory = None;
    Editable = False;
    InsertAllowed = False;
    DeleteAllowed = False;
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
            action(Sync)
            {
                ApplicationArea = NPRRetail;
                Image = Refresh;
                Caption = 'Synchronize';
                Description = 'Synchronises QR code with Vipps Mobilepay.';
                Tooltip = 'Synchronises QR code with Vipps Mobilepay.';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpVippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                begin
                    VippsMpVippsMpQrMgt.SynchronizeQrBarcodes();
                end;
            }
            action(ListAll)
            {
                ApplicationArea = NPRRetail;
                Image = Refresh;
                Caption = 'List QR Info';
                Description = 'Lists the raw information about the QR code data in Vipps Mobilepay';
                Tooltip = 'Lists the raw information about the QR code data in Vipps Mobilepay';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                    VippsMpSetupState: Codeunit "NPR Vipps Mp SetupState";
                    VippsMpStore: Record "NPR Vipps Mp Store";
                begin
                    VippsMpStore.Get(VippsMpSetupState.GetCurrentMsn());
                    VippsMpQrMgt.ListAll(VippsMpStore);
                end;
            }
            action(CreateNew)
            {
                ApplicationArea = NPRRetail;
                Image = BarCode;
                Description = 'Create a new Static QR code';
                Caption = 'Create new QR';
                Tooltip = 'Create a new Static QR code';
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                trigger OnAction();
                var
                    VippsMpQrMgt: Codeunit "NPR Vipps Mp Qr Mgt.";
                begin
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

            action(CreateMobilePay)
            {
                ApplicationArea = NPRRetail;
                Image = Redo;
                Description = 'Creates/Updates a new QR using an old Mobilepay QR.';
                Caption = 'Create/Update Mobilepay QR';
                Tooltip = 'Creates/Updates a new QR using an old Mobilepay QR.';
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
                    LblError: Label 'No such Mobilepay V10 setup.';
                    LblSamePos: Label 'A matching setup was found for POS %1 %2, do you want to use that setup?';
                begin
                    POSUnit.Get(VippsMpSetupState.GetCurrentPosUnitNo());
                    EFTSetup.SetFilter("POS Unit No.", POSUnit."No.");
                    EFTSetup.SetFilter("EFT Integration Type", 'MOBILEPAY_V10');
                    if (EFTSetup.FindFirst()) then begin
                        if (Confirm(StrSubstNo(LblSamePos, POSUnit."No.", POSUnit.Name))) then begin
                            MobilePayV10UnitSetup.Get(POSUnit."No.");
                        end;

                    end;
                    if (MobilePayV10UnitSetup."POS Unit No." = '') then begin
                        EFTSetup.Reset();
                        EFTSetup.SetFilter("EFT Integration Type", 'MOBILEPAY_V10');
                        if (Page.RunModal(Page::"NPR EFT Setup", EFTSetup) <> Action::LookupOK) then
                            exit;
                        if (not MobilePayV10UnitSetup.Get(EFTSetup."POS Unit No.")) then
                            Error(LblError);
                    end;
                    if (not VippsMpQrCallback.Get(MobilePayV10UnitSetup."Beacon ID")) then begin
                        VippsMpQrCallback.Init();
                        VippsMpQrCallback."Merchant Qr Id" := MobilePayV10UnitSetup."Beacon ID";
                        VippsMpQrCallback."Location Description" := POSUnit.Name;
                        VippsMpQrCallback."Merchant Serial Number" := VippsMpSetupState.GetCurrentMsn();
                        VippsMpQrCallback.Insert();
                        VippsMpQrMgt.CreateUpdateMobilepayQr(VippsMpQrCallback);
                    end else begin
                        VippsMpQrMgt.CreateUpdateMobilepayQrUI(Rec);
                    end;
                end;
            }
        }
    }
}