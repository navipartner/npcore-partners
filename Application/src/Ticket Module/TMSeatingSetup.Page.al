page 6151130 "NPR TM Seating Setup"
{
    // TM1.45/TSA /20191113 CASE 322432 Initial Version

    Caption = 'Seating Setup';
    PageType = List;
    SourceTable = "NPR TM Seating Setup";
    UsageCategory = Administration;
    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Admission Code"; "Admission Code")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field';
                }
                field("Seat Numbering"; "Seat Numbering")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Seat Numbering field';
                }
                field("Row Numbering"; "Row Numbering")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Row Numbering field';
                }
                field("Template Cache"; "Template Cache")
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Template Cache field';
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
                ToolTip = 'Navigate to Seating Template.';
                ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                Caption = 'Seating Template';
                Image = Template;
                Promoted = true;
				PromotedOnly = true;
                PromotedIsBig = true;


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

