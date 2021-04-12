page 6014407 "NPR Discount Priority List"
{
    // NPR5.31/MHA /20170210  CASE 262904 Object created
    // NPR5.44/MMV /20180627  CASE 312154 Added field 30

    Caption = 'Discount Priority List';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = List;
    SourceTable = "NPR Discount Priority";
    SourceTableView = SORTING(Priority);
    UsageCategory = Administration;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Priority; Rec.Priority)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Priority field';
                }
                field("Table ID"; Rec."Table ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Table ID field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
                field(Disabled; Rec.Disabled)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Disabled field';
                }
                field("Discount Calc. Codeunit ID"; Rec."Discount Calc. Codeunit ID")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Calc. Codeunit ID field';
                }
                field("Discount Calc. Codeunit Name"; Rec."Discount Calc. Codeunit Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Calc. Codeunit Name field';
                }
                field("Cross Line Calculation"; Rec."Cross Line Calculation")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the value of the Cross Line Calculation field';
                }
                field("Discount No. Series"; Rec."Discount No. Series")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Discount No. Series field';
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

