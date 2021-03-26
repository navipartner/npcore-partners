page 6014427 "NPR MM Available Coupons"
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
                }
                field("Points Threshold"; Rec."Points Threshold")
                {
                    Caption = 'Points to Deduct';
                    ApplicationArea = All;
                }
                field("Discount %"; Rec."Discount %")
                {
                    ApplicationArea = All;
                }
                field("Discount Amount"; Rec."Discount Amount")
                {
                    ApplicationArea = All;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("Amount LCY"; Rec."Amount LCY")
                {
                    Caption = 'Discount';
                    ApplicationArea = All;
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