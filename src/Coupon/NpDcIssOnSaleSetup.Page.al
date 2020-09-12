page 6151604 "NPR NpDc Iss.OnSale Setup"
{
    // NPR5.36/MHA /20170831  CASE 286812 Object created - Discount Coupon Issue Module

    Caption = 'Issue On-Sale Setup';
    PageType = Card;
    SourceTable = "NPR NpDc Iss.OnSale Setup";

    layout
    {
        area(content)
        {
            group(General)
            {
                group(Control6014410)
                {
                    ShowCaption = false;
                    field(Type; Type)
                    {
                        ApplicationArea = All;
                        ToolTip = '- Item Sales Amount: Discount Coupons will be issued for POS Sales per defined Item Sales Amount  - Item Sales Qty.: Discount Coupons will be issued for POS Sales per defined Item Sales Qty.  - Lot: Discount Coupons will be issued for POS Sales per exact Lot Quantity on On-Sale Items';

                        trigger OnValidate()
                        begin
                            CurrPage.Update(true);
                        end;
                    }
                    group(Control6014406)
                    {
                        ShowCaption = false;
                        Visible = (Type = 0);
                        field("Item Sales Amount"; "Item Sales Amount")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Discount Coupons will be issued for POS Sales per defined Item Sales Amount';
                        }
                    }
                    group(Control6014407)
                    {
                        ShowCaption = false;
                        Visible = (Type = 1);
                        field("Item Sales Qty."; "Item Sales Qty.")
                        {
                            ApplicationArea = All;
                            ToolTip = 'Discount Coupons will be issued for POS Sales per defined Item Sales Qty.';
                        }
                    }
                }
                group(Control6014411)
                {
                    ShowCaption = false;
                    field("Max. Allowed Issues per Sale"; "Max. Allowed Issues per Sale")
                    {
                        ApplicationArea = All;
                        ToolTip = 'The Max. Qty. of Coupons that can be issued for a single Sale';
                    }
                }
            }
            part(OnSaleItems; "NPR NpDc Iss.OnSale Subform")
            {
                Caption = 'On-Sale Items';
                SubPageLink = "Coupon Type" = FIELD("Coupon Type");
                ApplicationArea = All;
            }
        }
    }

    actions
    {
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
        CurrPage.OnSaleItems.PAGE.SetLotQtyVisible(Type);
    end;
}

