page 6184885 "NPR Emergency mPOS Setup List"
{
    PageType = List;
    ApplicationArea = NPRRetail;
    UsageCategory = Lists;
    Extensible = false;
    SourceTable = "NPR Emergency mPOS Setup";
    CardPageId = "NPR Emergency mPOS Setup";
    Caption = 'Emergency mPOS Setup';

    layout
    {
        area(Content)
        {
            repeater(General)
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
}