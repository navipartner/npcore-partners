page 6060164 "Event Attribute Column Values"
{
    // NPR5.31/NPKNAV/20170502  CASE 269162 Transport NPR5.31 - 2 May 2017
    // NPR5.38/TJ  /20171221 CASE Fixed Name and ENU caption of the page

    AutoSplitKey = true;
    Caption = 'Attribute Column Values';
    PageType = List;
    SourceTable = "Event Attribute Column Value";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Line No.";"Line No.")
                {
                    Editable = false;
                    Visible = false;
                }
                field(Description;Description)
                {
                }
                field(Type;Type)
                {
                }
                field("Include in Formula";"Include in Formula")
                {
                }
                field(Promote;Promote)
                {
                }
            }
        }
    }

    actions
    {
    }
}

