page 6150697 "NPR NPRE Kitchen Req.Src.Links"
{

    Caption = 'Kitchen Request Source Links';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR NPRE Kitchen Req.Src. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; Rec."Request No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Document Type field';
                }
                field("Source Document Subtype"; Rec."Source Document Subtype")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Document Subtype field';
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Document No. field';
                }
                field("Source Document Line No."; Rec."Source Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Document Line No. field';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                }
                field(Context; Rec.Context)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Context field';
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date-Time field';
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }
}