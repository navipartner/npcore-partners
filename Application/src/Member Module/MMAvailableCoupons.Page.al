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
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Coupon Type Code field';
                }
                field("Points Threshold"; Rec."Points Threshold")
                {
                    Caption = 'Points to Deduct';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Points to Deduct field';
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount % field';
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount Amount field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("Amount LCY"; Rec."Amount LCY")
                {
                    Caption = 'Discount';
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount field';
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