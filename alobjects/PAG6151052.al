page 6151052 "Item Hierarchy Listpart"
{
    // NPR5.38.01/JKL /20180126  CASE 289017 Object created - Replenishment Module

    AutoSplitKey = true;
    Caption = 'Item Hiearachy Levels';
    DelayedInsert = true;
    PageType = ListPart;
    SourceTable = "Item Hierarchy Level";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Level;Level)
                {
                }
                field("Code";Code)
                {
                }
                field(Description;Description)
                {
                }
                field("Table No.";"Table No.")
                {
                    Caption = 'Table No.';
                }
                field("Primary Field No.";"Primary Field No.")
                {
                    LookupPageID = "Field List";
                }
                field("Description Field No.";"Description Field No.")
                {
                    LookupPageID = "Field List";
                }
                field("Level Link Table No.";"Level Link Table No.")
                {
                }
                field("Level Link Field No.";"Level Link Field No.")
                {
                    LookupPageID = "Field List";
                }
                field("Level Link Filter";"Level Link Filter")
                {
                }
                field("Second Level Primary Field No.";"Second Level Primary Field No.")
                {
                    Visible = false;
                }
                field("Second Level Link Table No.";"Second Level Link Table No.")
                {
                    Visible = false;
                }
                field("Second Level Link Field No.";"Second Level Link Field No.")
                {
                    Visible = false;
                }
                field("Second Level Link Filter";"Second Level Link Filter")
                {
                    Visible = false;
                }
            }
        }
    }

    actions
    {
    }
}

