page 6014481 "NPR Retail Report Select. List"
{

    Caption = 'Report Type List - Retail';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Report Selection Retail";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report Type"; Rec."Report Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Type field';
                }
                field(Sequence; Rec.Sequence)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sequence field';
                }
                field("Register No."; Rec."Register No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Unit No. field';
                }
                field("Report ID"; Rec."Report ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report ID field';
                }
                field("Report Name"; Rec."Report Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Report Name field';
                }
                field("XML Port ID"; Rec."XML Port ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the XML Port ID field';
                }
                field("XML Port Name"; Rec."XML Port Name")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the XML Port Name field';
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit ID field';
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Codeunit Name field';
                }
                field("Print Template"; Rec."Print Template")
                {
                    ApplicationArea = All;
                    Width = 20;
                    ToolTip = 'Specifies the value of the Print Template field';
                }
                field("Filter Object ID"; Rec."Filter Object ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Filter Object ID field';
                }
                field("Record Filter"; Rec."Record Filter")
                {
                    ApplicationArea = All;
                    AssistEdit = true;
                    ToolTip = 'Specifies the value of the Record Filter field';
                }
                field(Optional; Rec.Optional)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Optional field';
                }
            }
        }
    }

}

