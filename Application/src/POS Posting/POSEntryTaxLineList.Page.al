page 6150676 "NPR POS Entry Tax Line List"
{
    Caption = 'POS Entry Tax Line List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "NPR POS Entry Tax Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; Rec."Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Date field';
                }
                field("Starting Time"; Rec."Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; Rec."Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Document No. field';
                }
                field("Tax Base Amount"; Rec."Tax Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                }
                field("Tax %"; Rec."Tax %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax % field';
                }
                field("Tax Amount"; Rec."Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field';
                }
                field("Amount Including Tax"; Rec."Amount Including Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                }
                field("VAT Identifier"; Rec."VAT Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Identifier field';
                }
                field("Tax Calculation Type"; Rec."Tax Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                }
                field("Tax Jurisdiction Code"; Rec."Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Group Code"; Rec."Tax Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Use Tax"; Rec."Use Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Tax field';
                }
                field("POS Entry No."; Rec."POS Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry No. field';
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
                    ApplicationArea = All;
                    ToolTip = 'Executes the POS Entry Card action';
                }
            }
        }
    }
}

