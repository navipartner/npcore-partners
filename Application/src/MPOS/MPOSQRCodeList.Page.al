page 6059964 "NPR MPOS QR Code List"
{
    Caption = 'MPOS QR Code List';
    PageType = List;
    UsageCategory = Administration;

    ShowFilter = false;
    SourceTable = "NPR MPOS QR Code";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
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
                field("Client Type"; Rec."Client Type")
                {

                    ToolTip = 'Specifies the value of the Client Type field';
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
                field("Payment Gateway"; Rec."Payment Gateway")
                {

                    ToolTip = 'Specifies the value of the Payment Gateway field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Unit No."; Rec."Cash Register Id")
                {

                    ToolTip = 'Specifies assigned POS Unit';
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
            }
        }
        area(factboxes)
        {
            part(Control6014419; "NPR MPOS QR Code FactBox")
            {
                SubPageLink = "User ID" = FIELD("User ID"),
                              Company = FIELD(Company),
                              "Cash Register Id" = FIELD("Cash Register Id");
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
}

