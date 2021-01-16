page 6059964 "NPR MPOS QR Code List"
{
    // NPR5.33/NPKNAV/20170630  CASE 277791 Transport NPR5.33 - 30 June 2017
    // NPR5.36/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.42/CLVA/20180302 CASE 304559 Added Company and "Cash Register Id" to the primary key/link to factbox

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
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                    ToolTip = 'Specifies the value of the Password field';
                }
                field("Client Type"; "Client Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Client Type field';
                }
                field(Company; Company)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company field';
                }
                field(Tenant; Tenant)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tenant field';
                }
                field("Payment Gateway"; "Payment Gateway")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Payment Gateway field';
                }
                field("Cash Register Id"; "Cash Register Id")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Cash Register Id field';
                }
                field(Url; Url)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Url field';
                }
                field("Webservice Url"; "Webservice Url")
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
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Set Defaults action';

                trigger OnAction()
                begin
                    SetDefaults(Rec);
                end;
            }
            action("Create QR Code")
            {
                Caption = 'Create QR Code';
                Image = "Action";
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ApplicationArea = All;
                ToolTip = 'Executes the Create QR Code action';

                trigger OnAction()
                begin
                    CreateQRCode(Rec);
                end;
            }
        }
    }
}

