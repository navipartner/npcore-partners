page 6059964 "NPR MPOS QR Code List"
{
    // NPR5.33/NPKNAV/20170630  CASE 277791 Transport NPR5.33 - 30 June 2017
    // NPR5.36/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.42/CLVA/20180302 CASE 304559 Added Company and "Cash Register Id" to the primary key/link to factbox

    Caption = 'MPOS QR Code List';
    PageType = List;
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
                }
                field(Password; Password)
                {
                    ApplicationArea = All;
                    ExtendedDatatype = Masked;
                }
                field("Client Type"; "Client Type")
                {
                    ApplicationArea = All;
                }
                field(Company; Company)
                {
                    ApplicationArea = All;
                }
                field(Tenant; Tenant)
                {
                    ApplicationArea = All;
                }
                field("Payment Gateway"; "Payment Gateway")
                {
                    ApplicationArea = All;
                }
                field("Cash Register Id"; "Cash Register Id")
                {
                    ApplicationArea = All;
                }
                field(Url; Url)
                {
                    ApplicationArea = All;
                }
                field("Webservice Url"; "Webservice Url")
                {
                    ApplicationArea = All;
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
                ApplicationArea=All;
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
                ApplicationArea=All;

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
                ApplicationArea=All;

                trigger OnAction()
                begin
                    CreateQRCode(Rec);
                end;
            }
        }
    }
}

