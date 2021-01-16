page 6060164 "NPR Event Attr. Column Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.38/TJ  /20171221 CASE Fixed Name and ENU caption of the page

    AutoSplitKey = true;
    Caption = 'Attribute Column Values';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Line No. field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Include in Formula"; "Include in Formula")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Include in Formula field';
                }
                field(Promote; Promote)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Promote field';
                }
            }
        }
    }

    actions
    {
    }
}

