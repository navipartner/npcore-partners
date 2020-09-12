page 6150676 "NPR POS Tax Line List"
{
    // NPR5.53/SARA/20191024 CASE 373672 Object create

    Caption = 'POS Tax Line List';
    Editable = false;
    PageType = List;
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
                }
                field("Starting Time"; "Starting Time")
                {
                    ApplicationArea = All;
                }
                field("Ending Time"; "Ending Time")
                {
                    ApplicationArea = All;
                }
                field("Tax Base Amount"; "Tax Base Amount")
                {
                    ApplicationArea = All;
                }
                field("Tax %"; "Tax %")
                {
                    ApplicationArea = All;
                }
                field("Tax Amount"; "Tax Amount")
                {
                    ApplicationArea = All;
                }
                field("Amount Including Tax"; "Amount Including Tax")
                {
                    ApplicationArea = All;
                }
                field("VAT Identifier"; "VAT Identifier")
                {
                    ApplicationArea = All;
                }
                field("Tax Calculation Type"; "Tax Calculation Type")
                {
                    ApplicationArea = All;
                }
                field("Tax Jurisdiction Code"; "Tax Jurisdiction Code")
                {
                    ApplicationArea = All;
                }
                field("Tax Area Code"; "Tax Area Code")
                {
                    ApplicationArea = All;
                }
                field("Tax Group Code"; "Tax Group Code")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Use Tax"; "Use Tax")
                {
                    ApplicationArea = All;
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
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
                }
            }
        }
    }
}

