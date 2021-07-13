page 6151533 "NPR Nc Collector Req. Lines"
{
    Caption = 'Nc Collector Request Lines';
    PageType = List;
    SourceTable = "NPR Nc Collector Request";
    UsageCategory = Lists;
    ApplicationArea = NPRNaviConnect;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Direction; Rec.Direction)
                {

                    ToolTip = 'Specifies the value of the Direction field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Collector Code"; Rec."Collector Code")
                {

                    ToolTip = 'Specifies the value of the Collector Code field';
                    ApplicationArea = NPRNaviConnect;
                }
                field(Status; Rec.Status)
                {

                    ToolTip = 'Specifies the value of the Status field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Creation Date"; Rec."Creation Date")
                {

                    ToolTip = 'Specifies the value of the Creation Date field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Processed Date"; Rec."Processed Date")
                {

                    ToolTip = 'Specifies the value of the Processed Date field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Database Name"; Rec."Database Name")
                {

                    ToolTip = 'Specifies the value of the Database Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("User ID"; Rec."User ID")
                {

                    ToolTip = 'Specifies the value of the User ID field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Processing Comment"; Rec."Processing Comment")
                {

                    ToolTip = 'Specifies the value of the Processing Comment field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("External No."; Rec."External No.")
                {

                    ToolTip = 'Specifies the value of the External No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Only New and Modified Records"; Rec."Only New and Modified Records")
                {

                    ToolTip = 'Specifies the value of the Only New and Modified Records field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table View"; Rec."Table View")
                {

                    ToolTip = 'Specifies the value of the Table View field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Filter"; Rec."Table Filter")
                {

                    ToolTip = 'Specifies the value of the Table Filter field';
                    ApplicationArea = NPRNaviConnect;
                }
                field("Table Name"; Rec."Table Name")
                {

                    ToolTip = 'Specifies the value of the Table Name field';
                    ApplicationArea = NPRNaviConnect;
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
                ApplicationArea = NPRNaviConnect;

            }
        }
    }
}

