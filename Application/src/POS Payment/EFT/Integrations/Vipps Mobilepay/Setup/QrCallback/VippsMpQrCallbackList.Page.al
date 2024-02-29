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
        }
    }
}