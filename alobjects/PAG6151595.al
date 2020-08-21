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
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Code"; Code)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Event Codeunit ID"; "Event Codeunit ID")
                {
                    ApplicationArea = All;
                }
                field("Event Codeunit Name"; "Event Codeunit Name")
                {
                    ApplicationArea = All;
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

