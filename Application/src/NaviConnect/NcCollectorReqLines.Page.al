page 6151533 "NPR Nc Collector Req. Lines"
{
    Caption = 'Nc Collector Request Lines';
    PageType = List;
    SourceTable = "NPR Nc Collector Request";
    UsageCategory = Lists;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the No. field';
                }
                field(Direction; Rec.Direction)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Direction field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Collector Code"; Rec."Collector Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Collector Code field';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Status field';
                }
                field("Creation Date"; Rec."Creation Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Creation Date field';
                }
                field("Processed Date"; Rec."Processed Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processed Date field';
                }
                field("Database Name"; Rec."Database Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Database Name field';
                }
                field("Company Name"; Rec."Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the User ID field';
                }
                field("Processing Comment"; Rec."Processing Comment")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Processing Comment field';
                }
                field("External No."; Rec."External No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the External No. field';
                }
                field("Only New and Modified Records"; Rec."Only New and Modified Records")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Only New and Modified Records field';
                }
                field("Table No."; Rec."Table No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table No. field';
                }
                field("Table View"; Rec."Table View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table View field';
                }
                field("Table Filter"; Rec."Table Filter")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Filter field';
                }
                field("Table Name"; Rec."Table Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Table Name field';
                }
            }
        }
        area(factboxes)
        {
            part(Control6151420; "NPR Nc Collector Req.Filt.Subf")
            {
                SubPageLink = "Nc Collector Request No." = FIELD("No.");
                SubPageView = SORTING("Nc Collector Request No.")
                              ORDER(Ascending);
                ApplicationArea = All;
            }
        }
    }
}

