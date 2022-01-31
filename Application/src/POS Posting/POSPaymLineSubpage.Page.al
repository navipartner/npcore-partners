page 6150654 "NPR POS Paym. Line Subpage"
{
    Extensible = False;
    Caption = 'POS Payment Line Subpage';
    Editable = false;
    PageType = ListPart;
    UsageCategory = None;
    SourceTable = "NPR POS Entry Payment Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("POS Payment Method Code"; Rec."POS Payment Method Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Method Code field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Payment Bin Code"; Rec."POS Payment Bin Code")
                {

                    ToolTip = 'Specifies the value of the POS Payment Bin Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field(Amount; Rec.Amount)
                {

                    ToolTip = 'Specifies the value of the Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Currency Code"; Rec."Currency Code")
                {

                    ToolTip = 'Specifies the value of the Paid Currency Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount (LCY)"; Rec."Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount (Sales Currency)"; Rec."Amount (Sales Currency)")
                {

                    ToolTip = 'Specifies the value of the Amount (Sales Currency) field';
                    ApplicationArea = NPRRetail;
                }
                field("External Document No."; Rec."External Document No.")
                {

                    ToolTip = 'Specifies the value of the External Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Amount (LCY)"; Rec."VAT Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the VAT Amount (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Base Amount (LCY)"; Rec."VAT Base Amount (LCY)")
                {

                    ToolTip = 'Specifies the value of the VAT Base Amount field';
                    ApplicationArea = NPRRetail;
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

                ToolTip = 'Executes the Dimensions action';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    Rec.ShowDimensions();
                end;
            }
        }
    }
}

