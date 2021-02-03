page 6151000 "NPR Upgrade History"
{
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
                field("Upgrade Time"; Rec."Upgrade Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Upgrade Time field';
                }
                field(Version; Rec.Version)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Version field';
                }
            }
        }
    }
}

