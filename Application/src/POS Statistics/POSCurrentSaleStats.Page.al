page 6059892 "NPR POS Current Sale Stats"
{
    Extensible = false;
    PageType = Card;
    Caption = 'Current Sale Statistics';
    UsageCategory = None;
    SourceTable = "NPR POS Single Stats Buffer";
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    DataCaptionFields = "Document No.";

    layout
    {
        area(Content)
        {
            group(ContentValues)
            {
                Editable = false;
                Caption = 'Content';


                grid(FixedContent)
                {
                    group(Header)
                    {
                        ShowCaption = false;

                        field("POS Unit No."; Rec."POS Unit No.")
                        {
                            ToolTip = 'Specifies the value of the POS Unit No.';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Document No."; Rec."Document No.")
                        {
                            ToolTip = 'Specifies the value of the Document No.';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                    }
                    group(Values)
                    {
                        ShowCaption = false;
                        field("Sales Amount (Actual)"; Rec."Sales Amount")
                        {
                            ToolTip = 'Specifies the value of the Sales Amount (Actual)';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Cost Amount (Actual)"; Rec."Cost Amount")
                        {
                            ToolTip = 'Specifies the value of the Cost Amount (Actual)';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Profit %"; Rec."Profit %")
                        {
                            ToolTip = 'Specifies the value of the Profit %';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Favorable';
                        }
                        field("Profit Amount"; Rec."Profit Amount")
                        {
                            ToolTip = 'Specifies the value of the Profit Amount';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Favorable';
                        }
                        field("Discount Amount"; Rec."Discount Amount")
                        {
                            Caption = 'Disc. Amt Excl. VAT';
                            ToolTip = 'Specifies the value of the Disc. Amt Excl. VAT field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Tax Amount"; Rec."Tax Amount")
                        {
                            ToolTip = 'Specifies the value of the Tax Amount field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Amount Incl. Tax"; Rec."Amount Incl. Tax")
                        {
                            ToolTip = 'Specifies the value of the Amount Incl. Tax field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Sales Quantity"; Rec."Sales Quantity")
                        {

                            DecimalPlaces = 0 : 2;
                            ToolTip = 'Specifies the value of the Sales Quantity field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                        field("Return Sales Quantity"; Rec."Return Sales Quantity")
                        {
                            DecimalPlaces = 0 : 2;
                            ToolTip = 'Specifies the value of the Return Sales Quantity field';
                            ApplicationArea = NPRRetail;
                            StyleExpr = 'Strong';
                        }
                    }
                }
            }
        }
    }
}