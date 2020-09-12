page 6151026 "NPR NpRv Partners"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company Vouchers

    Caption = 'Retail Voucher Partners';
    CardPageID = "NPR NpRv Partner Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR NpRv Partner";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field("Service Url"; "Service Url")
                {
                    ApplicationArea = All;
                }
                field("Service Username"; "Service Username")
                {
                    ApplicationArea = All;
                }
                field("Service Password"; "Service Password")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Partner Relations")
            {
                Caption = 'Partner Relations';
                Image = UserCertificate;
                RunObject = Page "NPR NpRv Partner Relations";
                RunPageLink = "Partner Code" = FIELD(Code);
                ApplicationArea = All;
            }
        }
    }

    trigger OnOpenPage()
    var
        NpRvPartnerMgt: Codeunit "NPR NpRv Partner Mgt.";
    begin
    end;
}

