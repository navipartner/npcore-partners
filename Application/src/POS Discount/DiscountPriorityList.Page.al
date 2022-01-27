page 6014407 "NPR Discount Priority List"
{
    Extensible = False;
    // NPR5.31/MHA /20170210  CASE 262904 Object created
    // NPR5.44/MMV /20180627  CASE 312154 Added field 30

    Caption = 'Discount Priority List';
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

                    ToolTip = 'Specifies the value of the Priority field';
                    ApplicationArea = NPRRetail;
                }
                field("Table ID"; Rec."Table ID")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Table ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRRetail;
                }
                field(Disabled; Rec.Disabled)
                {

                    ToolTip = 'Specifies the value of the Disabled field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Calc. Codeunit ID"; Rec."Discount Calc. Codeunit ID")
                {

                    Editable = false;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Calc. Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount Calc. Codeunit Name"; Rec."Discount Calc. Codeunit Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Discount Calc. Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Cross Line Calculation"; Rec."Cross Line Calculation")
                {

                    Editable = false;
                    ToolTip = 'Specifies the value of the Cross Line Calculation field';
                    ApplicationArea = NPRRetail;
                }
                field("Discount No. Series"; Rec."Discount No. Series")
                {

                    ToolTip = 'Specifies the value of the Discount No. Series field';
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

