page 6151000 "NPR Upgrade History"
{
    // NPR5.41/THRO/20180425 CASE 311567 Page created

    Caption = 'NPR Upgrade History';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Upgrade History";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Upgrade Time"; "Upgrade Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Upgrade Time field';
                }
                field(Version; Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
            }
        }
    }

    actions
    {
    }
}

