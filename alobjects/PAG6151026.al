page 6151026 "NpRv Partners"
{
    // NPR5.49/MHA /20190228  CASE 342811 Object created - Retail Voucher Partner used with Cross Company Vouchers

    Caption = 'Retail Voucher Partners';
    CardPageID = "NpRv Partner Card";
    Editable = false;
    PageType = List;
    SourceTable = "NpRv Partner";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code";Code)
                {
                }
                field(Name;Name)
                {
                }
                field("Service Url";"Service Url")
                {
                }
                field("Service Username";"Service Username")
                {
                }
                field("Service Password";"Service Password")
                {
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
                RunObject = Page "NpRv Partner Relations";
                RunPageLink = "Partner Code"=FIELD(Code);
            }
        }
    }

    trigger OnOpenPage()
    var
        NpRvPartnerMgt: Codeunit "NpRv Partner Mgt.";
    begin
    end;
}

