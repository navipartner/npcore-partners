page 6059964 "NPR MPOS QR Code List"
{
    Caption = 'MPOS QR Code List';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    ShowFilter = false;
    SourceTable = "NPR MPOS QR Code";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(Password; Rec.Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field("Client Type"; Rec."Client Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Type field';
                }
                field(Company; Rec.Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company field';
                }
                field(Tenant; Rec.Tenant)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tenant field';
                }
                field("Payment Gateway"; Rec."Payment Gateway")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Gateway field';
                }
                field("Cash Register Id"; Rec."Cash Register Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit Id field';
                }
                field(Url; Rec.Url)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Url field';
                }
                field("Webservice Url"; Rec."Webservice Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Webservice Url field';
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
                ApplicationArea = All;
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
                ApplicationArea = All;
                ToolTip = 'Executes the Set Defaults action';

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
                ApplicationArea = All;
                ToolTip = 'Executes the Create QR Code action';

                trigger OnAction()
                begin
                    Rec.CreateQRCode(Rec);
                end;

            }
        }
    }
}

