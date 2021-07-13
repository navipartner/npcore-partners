page 6059796 "NPR E-mail Log"
{
    Caption = 'Mail And Document Log List';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR E-mail Log";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Recipient E-mail"; Rec."Recipient E-mail")
                {

                    ToolTip = 'Specifies the value of the Recipient E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("From E-mail"; Rec."From E-mail")
                {

                    ToolTip = 'Specifies the value of the From E-mail field';
                    ApplicationArea = NPRRetail;
                }
                field("E-mail subject"; Rec."E-mail subject")
                {

                    ToolTip = 'Specifies the value of the E-mail subject field';
                    ApplicationArea = NPRRetail;
                }
                field(Filename; Rec.Filename)
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Filename field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Date"; Rec."Sent Date")
                {

                    ToolTip = 'Specifies the value of the Sent Date field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Time"; Rec."Sent Time")
                {

                    ToolTip = 'Specifies the value of the Sent time field';
                    ApplicationArea = NPRRetail;
                }
                field("Sent Username"; Rec."Sent Username")
                {

                    ToolTip = 'Specifies the value of the Sent by Username field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

