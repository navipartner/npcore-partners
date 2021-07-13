page 6151604 "NPR NpDc Iss.OnSale Setup"
{
    Caption = 'Issue On-Sale Setup';
    PageType = Card;
    UsageCategory = Administration;

    SourceTable = "NPR NpDc Iss.OnSale Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014410)
                {
                    ShowCaption = false;
                    field(Type; Rec.Type)
                    {

                        ToolTip = '- Item Sales Amount: Discount Coupons will be issued for POS Sales per defined Item Sales Amount  - Item Sales Qty.: Discount Coupons will be issued for POS Sales per defined Item Sales Qty.  - Lot: Discount Coupons will be issued for POS Sales per exact Lot Quantity on On-Sale Items';
                        ApplicationArea = NPRRetail;

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = (Rec.Type = 0);
                        field("Item Sales Amount"; Rec."Item Sales Amount")
                        {

                            ToolTip = 'Discount Coupons will be issued for POS Sales per defined Item Sales Amount';
                            ApplicationArea = NPRRetail;
                        }
                    }
                    group(Control6014407)
                    {
                        ShowCaption = false;
                        Visible = (Rec.Type = 1);
                        field("Item Sales Qty."; Rec."Item Sales Qty.")
                        {

                            ToolTip = 'Discount Coupons will be issued for POS Sales per defined Item Sales Qty.';
                            ApplicationArea = NPRRetail;
                        }
                    }
                }
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Max. Allowed Issues per Sale"; Rec."Max. Allowed Issues per Sale")
                    {

                        ToolTip = 'The Max. Qty. of Coupons that can be issued for a single Sale';
                        ApplicationArea = NPRRetail;
                    }
                }
            }
            part(OnSaleItems; "NPR NpDc Iss.OnSale Subform")
            {
                Caption = 'On-Sale Items';
                SubPageLink = "Coupon Type" = FIELD("Coupon Type");
                ApplicationArea = NPRRetail;

            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        SetLotQtyVisible();
    end;

    trigger OnOpenPage()
    begin
        SetLotQtyVisible();
    end;

    local procedure SetLotQtyVisible()
    begin
        CurrPage.OnSaleItems.PAGE.SetLotQtyVisible(Rec.Type);
    end;
}

