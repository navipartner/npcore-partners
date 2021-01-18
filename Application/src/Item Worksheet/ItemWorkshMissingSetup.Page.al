page 6060049 "NPR Item Worksh. Missing Setup"
{
    Caption = 'Item Worksheet Missing Setup';
    PageType = List;
    SourceTable = "NPR Missing Setup Table";
    SourceTableView = SORTING("Table ID", "Field No.")
                      ORDER(Ascending)
                      WHERE("Missing Records" = FILTER(> 0));
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; Rec."Field Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Field Name field.';
                }
                field("Related Table Name"; Rec."Related Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Related Table Name field.';
                }
                field("Missing Records"; Rec."Missing Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Missing Records field.';
                }
                field("Create New"; Rec."Create New")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Create New field.';
                }
            }
            part(Control6150620; "NPR Item Worksh. Setup Subpage")
            {
                ApplicationArea = All;
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
                ApplicationArea = All;
                Caption = 'Create Records';
                Image = Create;
                ToolTip = 'Executes the Create Records action.';

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

