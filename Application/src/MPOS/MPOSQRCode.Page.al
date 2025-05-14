page 6185056 "NPR MPOS QR Code"
{
    PageType = Card;
    UsageCategory = None;
    Extensible = false;
    SourceTable = "NPR MPOS QR Codes";
    CardPageId = "NPR MPOS QR Code";

    layout
    {
        area(content)
        {
            group(General)
            {
                field("User ID"; Rec."User ID")
                {
                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRRetail;
                }
                field(Password; Rec.Password)
                {
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Password field';
                    ApplicationArea = NPRRetail;
                }
                field(Company; Rec.Company)
                {

                    ToolTip = 'Specifies the value of the Company field';
                    ApplicationArea = NPRRetail;
                }
                field(Tenant; Rec.Tenant)
                {
                    ToolTip = 'Specifies the value of the Tenant field';
                    ApplicationArea = NPRRetail;
                }
                field(Url; Rec.Url)
                {
                    ToolTip = 'Specifies the value of the Url field';
                    ApplicationArea = NPRRetail;
                }
                field("Webservice Url"; Rec."Webservice Url")
                {
                    ToolTip = 'Specifies the value of the Webservice Url field';
                    ApplicationArea = NPRRetail;
                }

                field("Scanner Type"; Rec."Scanner Type")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Scanner Type';
                    ToolTip = 'Specifies Scanner Type used for Emergency mPOS';
                }
                field("Adyen Environment"; Rec."Adyen Environment")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Adyen Environment';
                    ToolTip = 'Specifies Adyen Environment';
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

            }
            group("LAN Terminal Setup")
            {
                Visible = _IsLan;

                field("Terminal Url"; Rec."Terminal Url")
                {
                    ApplicationArea = NPRRetail;
                    Caption = 'Terminal Url';
                    ToolTip = 'Specify Adyen terminal Url on the same LAN as the POS device.';
                }
            }



        }
        area(factboxes)
        {
            part(Control6014419; "NPR MPOS QR Code FactBox")
            {
                SubPageLink = "User ID" = FIELD("User ID"),
                              Company = FIELD(Company);
                ApplicationArea = NPRRetail;

            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Set Defaults")
            {
                Caption = 'Set Defaults';
                Image = Add;
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Set Defaults action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.SetDefaults(Rec);
                end;
            }
            action("Create QR Code")
            {
                Caption = 'Create QR Code';
                Image = "Action";
                Promoted = true;
                PromotedOnly = true;
                PromotedCategory = Process;
                PromotedIsBig = true;

                ToolTip = 'Executes the Create QR Code action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.CreateQRCode(Rec);
                end;

            }
        }
    }

    local procedure PaymentIntegrationToggle()
    begin
        case Rec."Payment Integration" of
            Rec."Payment Integration"::LocalTerminal:
                begin
                    _IsTapToPay := false;
                    _IsLan := true;
                end;
            Rec."Payment Integration"::TapToPay:
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

