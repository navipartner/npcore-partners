page 6059776 "Member Card Types Subform"
{
    Caption = 'Point Card - Types Subform';
    PageType = ListPart;
    SourceTable = "Member Card Setup";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Base Calculation On"; "Base Calculation On")
                {
                    ApplicationArea = All;
                }
                field("Units Per Point"; "Units Per Point")
                {
                    ApplicationArea = All;
                }
                field(Points; Points)
                {
                    ApplicationArea = All;
                }
                field("Customer Group"; "Customer Group")
                {
                    ApplicationArea = All;
                }
                field("Starting Date"; "Starting Date")
                {
                    ApplicationArea = All;
                }
                field("Ending Date"; "Ending Date")
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

