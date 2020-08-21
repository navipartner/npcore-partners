page 6060049 "Item Worksheet Missing Setup"
{
    // NPR4.19\BR\20160216  CASE 182391 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Worksheet Missing Setup';
    PageType = List;
    SourceTable = "Missing Setup Table";
    SourceTableView = SORTING("Table ID", "Field No.")
                      ORDER(Ascending)
                      WHERE("Missing Records" = FILTER(> 0));

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; "Field Name")
                {
                    ApplicationArea = All;
                }
                field("Related Table Name"; "Related Table Name")
                {
                    ApplicationArea = All;
                }
                field("Missing Records"; "Missing Records")
                {
                    ApplicationArea = All;
                }
                field("Create New"; "Create New")
                {
                    ApplicationArea = All;
                }
            }
            part(Control6150620; "Item Worksheet Setup Subpage")
            {
                SubPageLink = "Table ID" = FIELD("Table ID"),
                              "Field No." = FIELD("Field No.");
                SubPageView = SORTING("Table ID", "Field No.", Value)
                              ORDER(Ascending);
            }
        }
    }

    actions
    {
        area(processing)
        {
            action("Create Records")
            {
                Caption = 'Create Records';
                Image = Create;

                trigger OnAction()
                begin
                    ItemWorksheetManagement.CreateMissingSetup;
                end;
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "Item Worksheet Management";
}

