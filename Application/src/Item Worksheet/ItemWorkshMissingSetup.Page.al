page 6060049 "NPR Item Worksh. Missing Setup"
{
    Caption = 'Item Worksheet Missing Setup';
    PageType = List;
    SourceTable = "NPR Missing Setup Table";
    SourceTableView = SORTING("Table ID", "Field No.")
                      ORDER(Ascending)
                      WHERE("Missing Records" = FILTER(> 0));
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Field Name"; Rec."Field Name")
                {

                    ToolTip = 'Specifies the value of the Field Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Related Table Name"; Rec."Related Table Name")
                {

                    ToolTip = 'Specifies the value of the Related Table Name field.';
                    ApplicationArea = NPRRetail;
                }
                field("Missing Records"; Rec."Missing Records")
                {

                    ToolTip = 'Specifies the value of the Missing Records field.';
                    ApplicationArea = NPRRetail;
                }
                field("Create New"; Rec."Create New")
                {

                    ToolTip = 'Specifies the value of the Create New field.';
                    ApplicationArea = NPRRetail;
                }
            }
            part(Control6150620; "NPR Item Worksh. Setup Subpage")
            {

                SubPageLink = "Table ID" = FIELD("Table ID"),
                              "Field No." = FIELD("Field No.");
                SubPageView = SORTING("Table ID", "Field No.", Value)
                              ORDER(Ascending);
                ApplicationArea = NPRRetail;
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
                ToolTip = 'Executes the Create Records action.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                begin
                    ItemWorksheetManagement.CreateMissingSetup();
                end;
            }
        }
    }

    var
        ItemWorksheetManagement: Codeunit "NPR Item Worksheet Mgt.";
}

