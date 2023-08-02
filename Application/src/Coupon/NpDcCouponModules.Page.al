page 6151595 "NPR NpDc Coupon Modules"
{
    Extensible = False;
    Caption = 'Coupon Modules';
    ContextSensitiveHelpPage = 'docs/retail/coupons/reference/coupon_types/';
    Editable = false;
    PageType = List;
    PopulateAllFields = true;
    SourceTable = "NPR NpDc Coupon Module";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {
                    ToolTip = 'Specifies the type of the action executed on the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {
                    ToolTip = 'Specifies the code of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of the coupon type';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit ID"; Rec."Event Codeunit ID")
                {
                    ToolTip = 'Specifies the codeunit ID executed for a specific coupon module.';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit Name"; Rec."Event Codeunit Name")
                {
                    ToolTip = 'Specifies the codeunit name executed for the action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnOpenPage()
    var
        NpDcCouponModuleMgt: Codeunit "NPR NpDc Coupon Module Mgt.";
    begin
        NpDcCouponModuleMgt.OnInitCouponModules(Rec);
    end;
}

