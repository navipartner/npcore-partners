page 6151130 "NPR TM Seating Setup"
{
    // TM1.45/TSA /20191113 CASE 322432 Initial Version

    Caption = 'Seating Setup';
    PageType = List;
    SourceTable = "NPR TM Seating Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = All;
                }
                field("Seat Numbering"; "Seat Numbering")
                {
                    ApplicationArea = All;
                }
                field("Row Numbering"; "Row Numbering")
                {
                    ApplicationArea = All;
                }
                field("Template Cache"; "Template Cache")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Seating Template")
            {
                Caption = 'Seating Template';
                Image = Template;
                Promoted = true;
                PromotedIsBig = true;
                ApplicationArea = All;

                trigger OnAction()
                var
                    SeatingManagement: Codeunit "NPR TM Seating Mgt.";
                begin

                    SeatingManagement.ShowSeatingTemplate("Admission Code");
                end;
            }
        }
    }
}

