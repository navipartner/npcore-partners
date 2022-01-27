page 6014422 "NPR Pacsoft Customs Item Rows"
{
    Extensible = False;
    // PS1.00/LS/20141021  CASE  188056 : PacSoft Module Integration Creation of Page

    Caption = 'Pacsoft Customs Item Rows';
    DelayedInsert = true;
    PageType = ListPart;
    UsageCategory = Administration;

    SourceTable = "NPR Pacsoft Customs Item Rows";
    SourceTableView = SORTING("Shipment Document Entry No.", "Entry No.");
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Item Code"; Rec."Item Code")
                {

                    ToolTip = 'Specifies the value of the Item Code (Stat No.) field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Information"; Rec."Line Information")
                {

                    ToolTip = 'Specifies the value of the Line Information field';
                    ApplicationArea = NPRRetail;
                }
                field(Copies; Rec.Copies)
                {

                    ToolTip = 'Specifies the value of the Copies field';
                    ApplicationArea = NPRRetail;
                }
                field("Customs Value"; Rec."Customs Value")
                {

                    ToolTip = 'Specifies the value of the Customs Value field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry Content"; Rec.Content)
                {

                    ToolTip = 'Specifies the value of the Content field';
                    ApplicationArea = NPRRetail;
                }
                field("Country of Origin"; Rec."Country of Origin")
                {

                    ToolTip = 'Specifies the value of the Country of Origin field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

