page 6059796 "NPR E-mail Log"
{
    Caption = 'Mail And Document Log List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR E-mail Log";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Recipient E-mail"; "Recipient E-mail")
                {
                    ApplicationArea = All;
                }
                field("From E-mail"; "From E-mail")
                {
                    ApplicationArea = All;
                }
                field("E-mail subject"; "E-mail subject")
                {
                    ApplicationArea = All;
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Sent Date"; "Sent Date")
                {
                    ApplicationArea = All;
                }
                field("Sent Time"; "Sent Time")
                {
                    ApplicationArea = All;
                }
                field("Sent Username"; "Sent Username")
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

