page 6014407 "NPR Discount Priority List"
{
    // NPR5.31/MHA /20170210  CASE 262904 Object created
    // NPR5.44/MMV /20180627  CASE 312154 Added field 30

    Caption = 'Discount Priority List';
    ContextSensitiveHelpPage = 'docs/retail/discounts/how-to/discount_priority/';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Discount Priority";
    SourceTableView = SORTING(Priority);
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Priority; Rec.Priority)
                {
                    ToolTip = 'Specifies the priority of the discount';
                    ApplicationArea = NPRRetail;
                }
                field("Table ID"; Rec."Table ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the table ID of the discount priority';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {
                    ToolTip = 'Specifies the table name of the discount priority';
                    ApplicationArea = NPRRetail;
                }
                field(Disabled; Rec.Disabled)
                {
                    ToolTip = 'Specifies if this discount priority is disabled or not';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Calc. Codeunit ID"; Rec."Discount Calc. Codeunit ID")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the ID of the codeunit that calculates the discount for the stated discount priority.';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Calc. Codeunit Name"; Rec."Discount Calc. Codeunit Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the name of the codeunit that calculates the discount for the stated discount priority.';
                    ApplicationArea = NPRRetail;
                }
                field("Cross Line Calculation"; Rec."Cross Line Calculation")
                {

                    Editable = false;
                    ToolTip = 'Specifies if cross line calculation is allowed or not';
                    ApplicationArea = NPRRetail;
                }
                field("Discount No. Series"; Rec."Discount No. Series")
                {
                    ToolTip = 'Specifies the number series of the discount for the stated discount priority.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        POSSalesDiscCalcMgt: Codeunit "NPR POS Sales Disc. Calc. Mgt.";
    begin
        POSSalesDiscCalcMgt.InitDiscountPriority(Rec);
    end;
}

