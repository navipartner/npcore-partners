page 6151605 "NpDc Issue On-Sale Subform"
{
    // NPR5.36/MHA /20170831  CASE 286812 Object created - Discount Coupon Issue Module

    AutoSplitKey = true;
    Caption = 'Issue On-Sale Subform';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "NpDc Issue On-Sale Setup Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                }
                field("Lot Quantity"; "Lot Quantity")
                {
                    ApplicationArea = All;
                    Visible = LotQtyVisible;
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    Editable = false;
                }
            }
        }
    }

    actions
    {
    }

    var
        LotQtyVisible: Boolean;

    procedure SetLotQtyVisible(Type: Integer)
    var
        NpDcIssueOnSaleSetup: Record "NpDc Issue On-Sale Setup";
    begin
        LotQtyVisible := Type = NpDcIssueOnSaleSetup.Type::Lot;
        CurrPage.Update(false);
    end;
}

