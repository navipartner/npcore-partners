page 6150697 "NPR NPRE Kitchen Req.Src.Links"
{
    Extensible = False;

    Caption = 'Kitchen Request Source Links';
    Editable = false;
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR NPRE Kitchen Req.Src. Link";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; Rec."Request No.")
                {

                    ToolTip = 'Specifies the value of the Request No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document Type"; Rec."Source Document Type")
                {

                    ToolTip = 'Specifies the value of the Source Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document Subtype"; Rec."Source Document Subtype")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Document Subtype field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document No."; Rec."Source Document No.")
                {

                    ToolTip = 'Specifies the value of the Source Document No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document Line No."; Rec."Source Document Line No.")
                {

                    ToolTip = 'Specifies the value of the Source Document Line No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {

                    ToolTip = 'Specifies the value of the Quantity field';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {

                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                    ApplicationArea = NPRRetail;
                }
                field(Context; Rec.Context)
                {

                    ToolTip = 'Specifies the value of the Context field';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Serving Step field';
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {

                    ToolTip = 'Specifies the value of the Created Date-Time field';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {

                    ToolTip = 'Specifies the value of the Entry No. field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
