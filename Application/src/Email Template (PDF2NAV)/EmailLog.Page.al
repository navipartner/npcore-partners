page 6059796 "NPR E-mail Log"
{
    Caption = 'Mail And Document Log List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Recipient E-mail field';
                }
                field("From E-mail"; "From E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From E-mail field';
                }
                field("E-mail subject"; "E-mail subject")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail subject field';
                }
                field(Filename; Filename)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Filename field';
                }
                field("Sent Date"; "Sent Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent Date field';
                }
                field("Sent Time"; "Sent Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent time field';
                }
                field("Sent Username"; "Sent Username")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent by Username field';
                }
            }
        }
    }

    actions
    {
    }
}

