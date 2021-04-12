page 6014422 "NPR Pacsoft Customs Item Rows"
{
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Creation of Page

    Caption = 'Pacsoft Customs Item Rows';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR Pacsoft Customs Item Rows";
    SourceTableView = SORTING("Shipment Document Entry No.", "Entry No.");

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
                field("Item Code"; Rec."Item Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Item Code (Stat No.) field';
                }
                field("Line Information"; Rec."Line Information")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Line Information field';
                }
                field(Copies; Rec.Copies)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Copies field';
                }
                field("Customs Value"; Rec."Customs Value")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Customs Value field';
                }
                field("Entry Content"; Rec.Content)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Content field';
                }
                field("Country of Origin"; Rec."Country of Origin")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Country of Origin field';
                }
            }
        }
    }

    actions
    {
    }
}

