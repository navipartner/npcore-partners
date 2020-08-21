page 6150656 "POS Payment Line List"
{
    // NPR5.36/BR  /20170810  CASE  277096 Object created
    // NPR5.53/SARA/20191024 CASE 373672 Addde Action button POS Entry Card

    Caption = 'POS Payment Line List';
    Editable = false;
    PageType = List;
    PromotedActionCategories = 'New,Process,Report,POS Entry';
    SourceTable = "POS Payment Line";

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
                field("Document No."; "Document No.")
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
                field("POS Store Code"; "POS Store Code")
                {
                    ApplicationArea = All;
                }
                field("POS Unit No."; "POS Unit No.")
                {
                    ApplicationArea = All;
                }
                field("POS Period Register No."; "POS Period Register No.")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Method Code"; "POS Payment Method Code")
                {
                    ApplicationArea = All;
                }
                field("POS Payment Bin Code"; "POS Payment Bin Code")
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Amount; Amount)
                {
                    ApplicationArea = All;
                }
                field("Currency Code"; "Currency Code")
                {
                    ApplicationArea = All;
                }
                field("Amount (Sales Currency)"; "Amount (Sales Currency)")
                {
                    ApplicationArea = All;
                }
                field("Amount (LCY)"; "Amount (LCY)")
                {
                    ApplicationArea = All;
                }
                field("POS Entry No."; "POS Entry No.")
                {
                    ApplicationArea = All;
                }
                field("Line No."; "Line No.")
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
                    RunObject = Page "POS Entry Card";
                    RunPageLink = "Entry No." = FIELD("POS Entry No.");
                    RunPageView = SORTING("Entry No.");
                }
            }
        }
    }
}

