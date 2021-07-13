page 6151595 "NPR NpDc Coupon Modules"
{
    Caption = 'Coupon Modules';
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

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit ID"; Rec."Event Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Event Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Event Codeunit Name"; Rec."Event Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Event Codeunit Name field';
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

