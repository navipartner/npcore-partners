page 6151000 "NPR Upgrade History"
{
    Extensible = False;
    Caption = 'NPR Upgrade History';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Upgrade History";
    SourceTableView = SORTING("Entry No.")
                      ORDER(Descending);
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Upgrade Time"; Rec."Upgrade Time")
                {

                    ToolTip = 'Specifies the value of the Upgrade Time field';
                    ApplicationArea = NPRRetail;
                }
                field(Version; Rec.Version)
                {

                    ToolTip = 'Specifies the value of the Version field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

