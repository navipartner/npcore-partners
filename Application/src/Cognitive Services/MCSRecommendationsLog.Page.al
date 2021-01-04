page 6060084 "NPR MCS Recommendations Log"
{
    // NPR5.30/BR  /20170220  CASE 252646 Object Created

    Caption = 'MCS Recommendations Log';
    Editable = false;
    PageType = List;
    SourceTable = "NPR MCS Recommendations Log";
    UsageCategory = History;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
                field("Start Date Time"; "Start Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Start Date Time field';
                }
                field("End Date Time"; "End Date Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the End Date Time field';
                }
                field(Response; Response)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Response field';
                }
                field(Success; Success)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Success field';
                }
                field("Model No."; "Model No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Model No. field';
                }
                field("Seed Item No."; "Seed Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Seed Item No. field';
                }
                field("Selected Item"; "Selected Item")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Selected Recommendation Item field';
                }
                field("Selected Rating"; "Selected Rating")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Rating field';
                }
            }
        }
    }

    actions
    {
        area(navigation)
        {
            action("Recommended Items")
            {
                Caption = 'Recommended Items';
                Image = SuggestLines;
                RunObject = Page "NPR MCS Recomm. Lines";
                RunPageLink = "Log Entry No." = FIELD("Entry No.");
                ApplicationArea = All;
                ToolTip = 'Executes the Recommended Items action';
            }
        }
    }
}

