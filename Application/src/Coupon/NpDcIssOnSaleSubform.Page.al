page 6151605 "NPR NpDc Iss.OnSale Subform"
{
    AutoSplitKey = true;
    Caption = 'Issue On-Sale Subform';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NpDc Iss.OnSale Setup Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Item Description field';
                }
                field("Variant Code"; "Variant Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Variant Code field';
                }
                field("Lot Quantity"; "Lot Quantity")
                {
                    ApplicationArea = All;
                    Visible = LotQtyVisible;
                    ToolTip = 'Specifies the value of the Lot Quantity field';
                }
                field("Unit Price"; "Unit Price")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Unit Price field';
                }
                field("Profit %"; "Profit %")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Profit % field';
                }
            }
        }
    }

    var
        LotQtyVisible: Boolean;

    procedure SetLotQtyVisible(Type: Integer)
    var
        NpDcIssueOnSaleSetup: Record "NPR NpDc Iss.OnSale Setup";
    begin
        LotQtyVisible := Type = NpDcIssueOnSaleSetup.Type::Lot;
        CurrPage.Update(false);
    end;
}

