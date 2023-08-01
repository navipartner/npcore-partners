page 6151083 "NPR Total Discount Lines"
{
    Extensible = False;
    Caption = 'Total Discount Lines';
    DelayedInsert = true;
    PageType = List;
    SourceTable = "NPR Total Discount Line";
    AutoSplitKey = true;
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Total Discount Code"; Rec."Total Discount Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the code of the total discount.';
                }

                field(Type; Rec.Type)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Type of the Total Discount Line. Item - the trigger amount is going to be calculated from all POS Sale lines that contain the specified item. Item Category - the trigger amount is going to be calculated from all POS Sale lines that contain items from the specified item category. Vendor - the trigger amount is going to be calculated from all POS Sale lines that contain items that are bought from the specified vendor. All - the trigger amount is going to be calculated from all POS Sale lines that contain an item which is not a benefit item.';
                }
                field("No."; Rec."No.")
                {

                    ToolTip = 'Defines the No. of the Total Discount Line. Based on the Type field you can choose between an Item, an Item Category or a Vendor.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {

                    Enabled = (Rec."Type" = Rec."Type"::Item);
                    ToolTip = 'Defines the Variant Code of the Total Discount Line. If the Type field is set to Item you can choose an item variant.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    Editable = false;
                    ToolTip = 'Defines the Description of the Total Discount Line.';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {

                    Editable = false;
                    ToolTip = 'Defines the Description 2 of the Total Discount Line.';
                    ApplicationArea = NPRRetail;
                }

                field("Vendod Item No."; Rec."Vendor Item No.")
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Vendod Item No. of the Total Discount Line. If the Type field is set to Item you can see the Vendor Item No. of the specified item.';
                }
                field("Vendor No."; Rec."Vendor No.")
                {

                    Editable = false;
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Defines the Vendod No. of the Total Discount Line. If the Type field is set to Item you can see the Vendor No. from which the specified item is bought.';
                }

            }
        }
    }

    actions
    {
        area(Navigation)
        {
            action(Card)
            {
                Caption = 'Card';
                Image = Card;
                ApplicationArea = NPRRetail;
                ToolTip = 'Opens the card of the total discount.';
                Promoted = true;
                PromotedOnly = true;
                PromotedIsBig = true;
                PromotedCategory = Process;
                trigger OnAction()
                var
                    NPRTotalDiscLineUtils: Codeunit "NPR Total Disc. Line Utils";
                begin
                    NPRTotalDiscLineUtils.OpenTotalDiscount(Rec);
                end;
            }

        }

    }
}