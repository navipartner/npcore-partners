page 6150996 "NPR Ecom Coupon Lookup"
{
    Caption = 'Coupons';
    Extensible = false;
    PageType = List;
    SourceTable = "NPR NpDc Coupon";
    SourceTableTemporary = true;
    Editable = false;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    ApplicationArea = NPRRetail;
    UsageCategory = None;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the coupon number.';
                }
                field("Reference No."; Rec."Reference No.")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the customer-facing reference number.';
                }
                field("Coupon Type"; Rec."Coupon Type")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the coupon type.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies the coupon description. Archived coupons are prefixed with [Archived].';
                }
                field("Starting Date"; Rec."Starting Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies when the coupon became valid.';
                }
                field("Ending Date"; Rec."Ending Date")
                {
                    ApplicationArea = NPRRetail;
                    StyleExpr = _RowStyle;
                    ToolTip = 'Specifies when the coupon expires.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            action(OpenCoupon)
            {
                Caption = 'Open';
                ApplicationArea = NPRRetail;
                Image = ViewDetails;
                ToolTip = 'Open the selected coupon (live or archived).';

                trigger OnAction()
                var
                    EcomCreateCouponImpl: Codeunit "NPR EcomCreateCouponImpl";
                begin
                    EcomCreateCouponImpl.OpenCouponCardForSystemId(Rec.SystemId);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                actionref(OpenCoupon_Promoted; OpenCoupon) { }
            }
        }
    }

    trigger OnAfterGetRecord()
    var
        EcomCreateVchrImpl: Codeunit "NPR EcomCreateVchrImpl";
    begin
        if EcomCreateVchrImpl.IsArchivedTempDescription(Rec.Description) then
            _RowStyle := 'Subordinate'
        else
            _RowStyle := 'Standard';
    end;

    var
        _RowStyle: Text;
}
