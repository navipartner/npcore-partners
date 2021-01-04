page 6150676 "NPR POS Tax Line List"
{
    // NPR5.53/SARA/20191024 CASE 373672 Object create

    Caption = 'POS Tax Line List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "NPR POS Tax Amount Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry Date"; "Entry Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry Date field';
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Starting Time field';
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Ending Time field';
                }
                field("Tax Base Amount"; "Tax Base Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Base Amount field';
                }
                field("Tax %"; "Tax %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax % field';
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Amount field';
                }
                field("Amount Including Tax"; "Amount Including Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Amount Including Tax field';
                }
                field("VAT Identifier"; "VAT Identifier")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Identifier field';
                }
                field("Tax Calculation Type"; "Tax Calculation Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the VAT Calculation Type field';
                }
                field("Tax Jurisdiction Code"; "Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Jurisdiction Code field';
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Group Code field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Use Tax"; "Use Tax")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Use Tax field';
                }
                field("POS Entry No."; "POS Entry No.")
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

