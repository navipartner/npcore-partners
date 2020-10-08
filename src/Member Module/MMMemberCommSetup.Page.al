page 6151187 "NPR MM Member Comm. Setup"
{

    Caption = 'Member Communication Setup';
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR MM Member Comm. Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Membership Code"; "Membership Code")
                {
                    ApplicationArea = All;
                }
                field("Message Type"; "Message Type")
                {
                    ApplicationArea = All;
                }
                field("Preferred Method"; "Preferred Method")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

