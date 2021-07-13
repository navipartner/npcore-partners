page 6014557 "NPR MM Available Coupons"
{
    PageType = List;
    SourceTable = "NPR MM Loyalty Point Setup";
    SourceTableTemporary = true;
    Editable = false;
    Caption = 'Available Coupons';
    DataCaptionExpression = _LookupCaption;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {

                field("Coupon Type Code"; Rec."Coupon Type Code")
                {

                    ToolTip = 'Specifies the value of the Coupon Type Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Points Threshold"; Rec."Points Threshold")
                {
                    Caption = 'Points to Deduct';

                    ToolTip = 'Specifies the value of the Points to Deduct field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount %"; Rec."Discount %")
                {

                    ToolTip = 'Specifies the value of the Discount % field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {

                    ToolTip = 'Specifies the value of the Discount Amount field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount LCY"; Rec."Amount LCY")
                {
                    Caption = 'Discount';

                    ToolTip = 'Specifies the value of the Discount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    var
        _LookupCaption: Text;

    procedure LoadEntries(LookupCaption: Text; var TmpEntry: Record "NPR MM Loyalty Point Setup" temporary)
    begin
        _LookupCaption := LookupCaption;
        Rec.Copy(TmpEntry, true);
    end;


}