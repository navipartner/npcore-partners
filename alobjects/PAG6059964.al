page 6059964 "MPOS QR Code List"
{
    // NPR5.33/NPKNAV/20170630  CASE 277791 Transport NPR5.33 - 30 June 2017
    // NPR5.36/CLVA/20170703 CASE 280444 Upgrading MPOS functionality to transcendence
    // NPR5.42/CLVA/20180302 CASE 304559 Added Company and "Cash Register Id" to the primary key/link to factbox

    Caption = 'MPOS QR Code List';
    PageType = List;
    ShowFilter = false;
    SourceTable = "MPOS QR Code";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("User ID";"User ID")
                {
                }
                field(Password;Password)
                {
                    ExtendedDatatype = Masked;
                }
                field("Client Type";"Client Type")
                {
                }
                field(Company;Company)
                {
                }
                field(Tenant;Tenant)
                {
                }
                field("Payment Gateway";"Payment Gateway")
                {
                }
                field("Cash Register Id";"Cash Register Id")
                {
                }
                field(Url;Url)
                {
                }
                field("Webservice Url";"Webservice Url")
                {
                }
            }
        }
        area(factboxes)
        {
            part(Control6014419;"MPOS QR Code FactBox")
            {
                SubPageLink = "User ID"=FIELD("User ID"),
                              Company=FIELD(Company),
                              "Cash Register Id"=FIELD("Cash Register Id");
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

                trigger OnAction()
                begin
                    CreateQRCode(Rec);
                end;
            }
        }
    }
}

