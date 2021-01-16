page 6060049 "NPR Item Worksh. Missing Setup"
{
    // NPR4.19\BR\20160216  CASE 182391 Object Created
    // NPR5.48/TS  /20181206 CASE 338656 Added Missing Picture to Action

    Caption = 'Item Worksheet Missing Setup';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
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
                    ToolTip = 'Specifies the value of the Field Name field';
                }
                field("Related Table Name"; "Related Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Related Table Name field';
                }
                field("Missing Records"; "Missing Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Missing Records field';
                }
                field("Create New"; "Create New")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create New field';
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
                ToolTip = 'Executes the Create Records action';

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

