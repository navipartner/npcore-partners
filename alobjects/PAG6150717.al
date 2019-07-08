page 6150717 "POS Menu Filter SubPage"
{
    // NPR5.32/NPKNAV/20170526  CASE 270854 Transport NPR5.32 - 26 May 2017

    AutoSplitKey = true;
    Caption = 'Filter Line';
    PageType = ListPart;
    SourceTable = "POS Menu Filter Line";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Object Type";"Object Type")
                {
                    Visible = false;
                }
                field("Object Id";"Object Id")
                {
                    Visible = false;
                }
                field("Filter Code";"Filter Code")
                {
                    Visible = false;
                }
                field("Line No.";"Line No.")
                {
                }
                field("Object Name";"Object Name")
                {
                    Visible = false;
                }
                field("Table No.";"Table No.")
                {
                }
                field("Table Name";"Table Name")
                {
                }
                field("Field No.";"Field No.")
                {
                }
                field("Field Name";"Field Name")
                {
                }
                field("Filter Value";"Filter Value")
                {
                }
                field("Filter Sale POS Field Id";"Filter Sale POS Field Id")
                {
                }
                field("Filter Sale POS Field Name";"Filter Sale POS Field Name")
                {
                }
                field("Filter Sale Line POS Field Id";"Filter Sale Line POS Field Id")
                {
                }
                field("Filter Sale Line POS Field Nam";"Filter Sale Line POS Field Nam")
                {
                }
            }
        }
    }

    actions
    {
    }

    var
        POSMenuFilterMain: Record "POS Menu Filter" temporary;
}

