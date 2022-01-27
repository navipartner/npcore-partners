page 6150676 "NPR POS Entry Tax Line List"
{
    Extensible = False;
    Caption = 'POS Entry Tax Line List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "NPR POS Entry Tax Line";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; Rec."Entry Date")
                {

                    ToolTip = 'Specifies the value of the Entry Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Starting Time"; Rec."Starting Time")
                {

                    ToolTip = 'Specifies the value of the Starting Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Ending Time"; Rec."Ending Time")
                {

                    ToolTip = 'Specifies the value of the Ending Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax %"; Rec."Tax %")
                {

                    ToolTip = 'Specifies the value of the Tax % field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Amount"; Rec."Tax Amount")
                {

                    ToolTip = 'Specifies the value of the Tax Amount field';
                    ApplicationArea = NPRRetail;
                }
                field("Amount Including Tax"; Rec."Amount Including Tax")
                {

                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {

                    ToolTip = 'Specifies the value of the Tax Identifier field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Calculation Type"; Rec."Tax Calculation Type")
                {

                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {

                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {

                    ToolTip = 'Specifies the value of the Tax Area Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {

                    ToolTip = 'Specifies the value of the Tax Group Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Use Tax"; Rec."Use Tax")
                {

                    ToolTip = 'Specifies the value of the Use Tax field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {

                    ToolTip = 'Specifies the value of the POS Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("POS Entry")
            {
                Caption = 'POS Entry';
                action("POS Entry Card")
                {
                    Caption = 'POS Entry Card';
                    Image = List;
                    Promoted = true;
                    PromotedOnly = true;
                    PromotedCategory = Category4;
                    RunObject = Page "NPR POS Entry Card";
                    RunPageLink = "Entry No." = FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");

                    ToolTip = 'Executes the POS Entry Card action';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

