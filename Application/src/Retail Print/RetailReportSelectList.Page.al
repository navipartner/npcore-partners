page 6014481 "NPR Retail Report Select. List"
{

    Caption = 'Report Type List - Retail';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR Report Selection Retail";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Report Type"; Rec."Report Type")
                {

                    ToolTip = 'Specifies the value of the Report Type field';
                    ApplicationArea = NPRRetail;
                }
                field(Sequence; Rec.Sequence)
                {

                    ToolTip = 'Specifies the value of the Sequence field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Report Name"; Rec."Report Name")
                {

                    ToolTip = 'Specifies the value of the Report Name field';
                    ApplicationArea = NPRRetail;
                }
                field("XML Port ID"; Rec."XML Port ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the XML Port ID field';
                    ApplicationArea = NPRRetail;
                }
                field("XML Port Name"; Rec."XML Port Name")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the XML Port Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit ID"; Rec."Codeunit ID")
                {

                    ToolTip = 'Specifies the value of the Codeunit ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Codeunit Name"; Rec."Codeunit Name")
                {

                    ToolTip = 'Specifies the value of the Codeunit Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Print Template"; Rec."Print Template")
                {

                    Width = 20;
                    ToolTip = 'Specifies the value of the Print Template field';
                    ApplicationArea = NPRRetail;
                }
                field("Filter Object ID"; Rec."Filter Object ID")
                {

                    ToolTip = 'Specifies the value of the Filter Object ID field';
                    ApplicationArea = NPRRetail;
                }
                field("Record Filter"; Rec."Record Filter")
                {

                    AssistEdit = true;
                    ToolTip = 'Specifies the value of the Record Filter field';
                    ApplicationArea = NPRRetail;
                }
                field(Optional; Rec.Optional)
                {

                    ToolTip = 'Specifies the value of the Optional field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}

