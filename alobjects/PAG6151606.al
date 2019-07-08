page 6151606 "NpDc Extra Item Qty."
{
    // NPR5.47/MHA /20181026  CASE 332655 Object created

    AutoSplitKey = true;
    Caption = 'Extra Coupon Item';
    PageType = Card;
    SourceTable = "NpDc Extra Coupon Item";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014405)
                {
                    ShowCaption = false;
                    field("Item No.";"Item No.")
                    {
                    }
                    field("Discount Type";"Discount Type")
                    {
                    }
                    group(Control6014411)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type"=0);
                        field("Discount Amount";"Discount Amount")
                        {
                            Caption = 'Discount Amount per Item';
                            ShowMandatory = true;
                        }
                    }
                    group(Control6014409)
                    {
                        ShowCaption = false;
                        Visible = ("Discount Type"=1);
                        field("Discount %";"Discount %")
                        {
                            ShowMandatory = true;
                        }
                    }
                    field(LotValidation;LotValidation)
                    {
                        Caption = 'Extra Item per Lot';

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
                        field(TotalValidQty;ValidQty)
                        {
                            BlankZero = true;
                            Caption = 'Extra Item per Qty.';

                            trigger OnValidate()
                            begin
                                SetTotals();
                            end;
                        }
                    }
                    field(TotalMaxQty;MaxQty)
                    {
                        BlankZero = true;
                        Caption = 'Max. Extra Item Qty. per Coupon';
                        DecimalPlaces = 0:5;
                        Importance = Promoted;

                        trigger OnValidate()
                        begin
                            SetTotals();
                        end;
                    }
                }
                group(Control6014406)
                {
                    ShowCaption = false;
                    field("Item Description";"Item Description")
                    {
                    }
                    field("Unit Price";"Unit Price")
                    {
                    }
                    field("Profit %";"Profit %")
                    {
                    }
                }
            }
            part(NpDcExtraItemQtySubform;"NpDc Extra Item Qty. Subform")
            {
                SubPageLink = "Coupon Type"=FIELD("Coupon Type");
            }
        }
    }

    actions
    {
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
        NpDcCouponListItem: Record "NpDc Coupon List Item";
        CouponType: Code[20];
        PrevRec: Text;
    begin
        CouponType := "Coupon Type";
        if CouponType = '' then begin
          FilterGroup(2);
          CouponType := GetRangeMax("Coupon Type");
          FilterGroup(0);
        end;

        if (MaxQty <= 0) and (ValidQty <= 0) and (not LotValidation) then begin
          if NpDcCouponListItem.Get(CouponType,-1) then
            NpDcCouponListItem.Delete(true);

          CurrPage.Update(false);
          exit;
        end;

        if not NpDcCouponListItem.Get(CouponType,-1) then begin
          NpDcCouponListItem.Init;
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
        NpDcCouponListItem: Record "NpDc Coupon List Item";
        CouponType: Code[20];
    begin
        CouponType := "Coupon Type";
        if CouponType = '' then begin
          if GetFilter("Coupon Type") = '' then
            exit;

          FilterGroup(2);
          CouponType := GetRangeMax("Coupon Type");
          FilterGroup(0);
        end;
        MaxDiscountAmt := 0;
        MaxQty := 0;
        ValidQty := 0;
        LotValidation := false;

        if not NpDcCouponListItem.Get(CouponType,-1) then
          exit;

        MaxQty := NpDcCouponListItem."Max. Quantity";
        ValidQty := NpDcCouponListItem."Validation Quantity";
        LotValidation := NpDcCouponListItem."Lot Validation";
    end;
}

