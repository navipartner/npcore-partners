page 6060049 "NPR Item Worksh. Missing Setup"
{
    // NPR4.19\BR\20160216  CASE 182391 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Worksheet Missing Setup';
    PageType = List;
    SourceTable = "NPR Missing Setup Table";
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
            part(Control6150620; "NPR Item Worksh. Setup Subpage")
            {
                SubPageLink = "Table ID" = FIELD("Table ID"),
                              "Field No." = FIELD("Field No.");
                SubPageView = SORTING("Table ID", "Field No.", Value)
                              ORDER(Ascending);
                ApplicationArea = All;
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
                ApplicationArea = All;

                trigger OnAction()
                begin
                    ItemWorksheetManagement.CreateMissingSetup;
                end;
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
}

