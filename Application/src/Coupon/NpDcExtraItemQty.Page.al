page 6151606 "NPR NpDc Extra Item Qty."
{
    Extensible = False;
    AutoSplitKey = true;
    Caption = 'Extra Coupon Item';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Extra Coupon Item";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Item No."; Rec."Item No.")
                    {

                        ToolTip = 'Specifies the value of the Item No. field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Discount Type"; Rec."Discount Type")
                    {

                        ToolTip = 'Specifies the value of the Discount Type field';
                        ApplicationArea = NPRRetail;
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 0);
                        field("Discount Amount"; Rec."Discount Amount")
                        {

                            Caption = 'Discount Amount per Item';
                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount Amount per Item field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = (Rec."Discount Type" = 1);
                        field("Discount %"; Rec."Discount %")
                        {

                            ShowMandatory = true;
                            ToolTip = 'Specifies the value of the Discount % field';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    field(LotValidation; LotValidation)
                    {

                        Caption = 'Extra Item per Lot';
                        ToolTip = 'Specifies the value of the Extra Item per Lot field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            SetTotals();
                            CurrPage.NpDcExtraItemQtySubform.PAGE.SetLotValidation(LotValidation);
                        end;
                    }
                    group(Control6014416)
                    {
                        ShowCaption = false;
                        Visible = (NOT LotValidation);
                        field(TotalValidQty; ValidQty)
                        {

                            BlankZero = true;
                            Caption = 'Extra Item per Qty.';
                            ToolTip = 'Specifies the value of the Extra Item per Qty. field';
                            ApplicationArea = NPRRetail;

                            trigger OnValidate()
                            begin
                                SetTotals();
                            end;
                        }
                    }
                    field(TotalMaxQty; MaxQty)
                    {

                        BlankZero = true;
                        Caption = 'Max. Extra Item Qty. per Coupon';
                        DecimalPlaces = 0 : 5;
                        Importance = Promoted;
                        ToolTip = 'Specifies the value of the Max. Extra Item Qty. per Coupon field';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            SetTotals();
                        end;
                    }
                }
                group(Control6014406)
                {
                    ShowCaption = false;
                    field("Item Description"; Rec."Item Description")
                    {

                        ToolTip = 'Specifies the value of the Item Description field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Unit Price"; Rec."Unit Price")
                    {

                        ToolTip = 'Specifies the value of the Unit Price field';
                        ApplicationArea = NPRRetail;
                    }
                    field("Profit %"; Rec."Profit %")
                    {

                        ToolTip = 'Specifies the value of the Profit % field';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(NpDcExtraItemQtySubform; "NPR NpDc ExtraItemQty. Subform")
            {
                SubPageLink = "Coupon Type" = FIELD("Coupon Type");
                ApplicationArea = NPRRetail;

            }
        }
    }

    trigger OnOpenPage()
    begin
        GetTotals();
        CurrPage.NpDcExtraItemQtySubform.PAGE.SetLotValidation(LotValidation);
    end;

    var
        MaxDiscountAmt: Decimal;
        MaxQty: Decimal;
        ValidQty: Integer;
        LotValidation: Boolean;

    local procedure SetTotals()
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        CouponType: Code[20];
        PrevRec: Text;
    begin
        CouponType := Rec."Coupon Type";
        if CouponType = '' then begin
            Rec.FilterGroup(2);
            CouponType := Rec.GetRangeMax("Coupon Type");
            Rec.FilterGroup(0);
        end;

        if (MaxQty <= 0) and (ValidQty <= 0) and (not LotValidation) then begin
            if NpDcCouponListItem.Get(CouponType, -1) then
                NpDcCouponListItem.Delete(true);

            CurrPage.Update(false);
            exit;
        end;

        if not NpDcCouponListItem.Get(CouponType, -1) then begin
            NpDcCouponListItem.Init();
            NpDcCouponListItem."Coupon Type" := CouponType;
            NpDcCouponListItem."Line No." := -1;
            NpDcCouponListItem."Max. Discount Amount" := MaxDiscountAmt;
            NpDcCouponListItem."Max. Quantity" := MaxQty;
            NpDcCouponListItem."Validation Quantity" := ValidQty;
            NpDcCouponListItem."Lot Validation" := LotValidation;
            NpDcCouponListItem.Insert(true);
        end;

        PrevRec := Format(NpDcCouponListItem);

        NpDcCouponListItem."Max. Quantity" := MaxQty;
        NpDcCouponListItem."Validation Quantity" := ValidQty;
        NpDcCouponListItem."Lot Validation" := LotValidation;

        if PrevRec <> Format(NpDcCouponListItem) then
            NpDcCouponListItem.Modify(true);

        CurrPage.Update(false);
    end;

    local procedure GetTotals()
    var
        NpDcCouponListItem: Record "NPR NpDc Coupon List Item";
        CouponType: Code[20];
    begin
        CouponType := Rec."Coupon Type";
        if CouponType = '' then begin
            if Rec.GetFilter("Coupon Type") = '' then
                exit;

            Rec.FilterGroup(2);
            CouponType := Rec.GetRangeMax("Coupon Type");
            Rec.FilterGroup(0);
        end;
        MaxDiscountAmt := 0;
        MaxQty := 0;
        ValidQty := 0;
        LotValidation := false;

        if not NpDcCouponListItem.Get(CouponType, -1) then
            exit;

        MaxQty := NpDcCouponListItem."Max. Quantity";
        ValidQty := NpDcCouponListItem."Validation Quantity";
        LotValidation := NpDcCouponListItem."Lot Validation";
    end;
}

