page 6150654 "NPR POS Paym. Line Subpage"
{
    Caption = 'POS Payment Line Subpage';
    Editable = false;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Entry Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Amount; Rec.Amount)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount field';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Paid Currency Code field';
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount (LCY) field';
                }
                field("Amount (Sales Currency)"; Rec."Amount (Sales Currency)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount (Sales Currency) field';
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External Document No. field';
                }
                field("VAT Amount (LCY)"; Rec."VAT Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Amount (LCY) field';
                }
                field("VAT Base Amount (LCY)"; Rec."VAT Base Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Base Amount field';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowDimensions)
            {
                Caption = 'Dimensions';
                Image = Dimensions;
                ApplicationArea = All;
                ToolTip = 'Executes the Dimensions action';

                trigger OnAction()
                begin
                    Rec.ShowDimensions;
                end;
            }
        }
    }
}

