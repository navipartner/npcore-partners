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
                field("Recipient E-mail"; Rec."Recipient E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Recipient E-mail field';
                }
                field("From E-mail"; Rec."From E-mail")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the From E-mail field';
                }
                field("E-mail subject"; Rec."E-mail subject")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the E-mail subject field';
                }
                field(Filename; Rec.Filename)
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Filename field';
                }
                field("Sent Date"; Rec."Sent Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent Date field';
                }
                field("Sent Time"; Rec."Sent Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sent time field';
                }
                field("Sent Username"; Rec."Sent Username")
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

