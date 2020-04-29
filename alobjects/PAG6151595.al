page 6151595 "NpDc Coupon Modules"
{
    // NPR5.34/MHA /20170720  CASE 282799 Object created - NpDc: NaviPartner Discount Coupon

    Caption = 'Coupon Modules';
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NpDc Coupon Module";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type;Type)
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Event Codeunit ID";"Event Codeunit ID")
                {
                }
                field("Event Codeunit Name";"Event Codeunit Name")
                {
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        NpDcCouponModuleMgt: Codeunit "NpDc Coupon Module Mgt.";
    begin
        NpDcCouponModuleMgt.OnInitCouponModules(Rec);
    end;
}

