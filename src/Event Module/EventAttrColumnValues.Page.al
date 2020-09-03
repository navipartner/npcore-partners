page 6060164 "NPR Event Attr. Column Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.38/TJ  /20171221 CASE Fixed Name and ENU caption of the page

    AutoSplitKey = true;
    Caption = 'Attribute Column Values';
    PageType = List;
    SourceTable = "NPR Event Attr. Column Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No."; "Line No.")
                {
                    ApplicationArea = All;
                    Editable = false;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                }
                field("Include in Formula"; "Include in Formula")
                {
                    ApplicationArea = All;
                }
                field(Promote; Promote)
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

