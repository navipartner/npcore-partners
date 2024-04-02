page 6150697 "NPR NPRE Kitchen Req.Src.Links"
{
    Extensible = False;
    Caption = 'Kitchen Request Source Links';
    Editable = false;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR NPRE Kitchen Req.Src. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No."; Rec."Request No.")
                {
                    ToolTip = 'Specifies the request Id this source document link applies to.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document Type"; Rec."Source Document Type")
                {
                    ToolTip = 'Specifies the document type this kitchen request link originates from.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document Subtype"; Rec."Source Document Subtype")
                {
                    Visible = false;
                    ToolTip = 'Specifies the document subtype this kitchen request link originates from.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document No."; Rec."Source Document No.")
                {
                    ToolTip = 'Specifies the document number this kitchen request link originates from.';
                    ApplicationArea = NPRRetail;
                }
                field("Source Document Line No."; Rec."Source Document Line No.")
                {
                    ToolTip = 'Specifies the document line number this kitchen request link originates from.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies how many units of the product have been requested.';
                    ApplicationArea = NPRRetail;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ToolTip = 'Specifies how many units (base unit of measure) of the product have been requested.';
                    ApplicationArea = NPRRetail;
                }
                field(Context; Rec.Context)
                {
                    ToolTip = 'Specifies the process this kitchen request link created by.';
                    ApplicationArea = NPRRetail;
                }
                field("Serving Step"; Rec."Serving Step")
                {
                    Visible = false;
                    ToolTip = 'Specifies the meal flow serving step the product of this request is to be served at.';
                    ApplicationArea = NPRRetail;
                }
                field("Seating Code"; Rec."Seating Code")
                {
                    ToolTip = 'Specifies the seating (table) code the request was created for.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Seating No."; Rec."Seating No.")
                {
                    ToolTip = 'Specifies the seating (table) No. the request was created for.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Assigned Waiter Code"; Rec."Assigned Waiter Code")
                {
                    Caption = 'Waiter Code';
                    ToolTip = 'Specifies the waiter (salesperson) code the request was created for.';
                    Visible = false;
                    ApplicationArea = NPRRetail;
                }
                field("Created Date-Time"; Rec."Created Date-Time")
                {
                    ToolTip = 'Specifies date-time this kitchen request link was created at.';
                    ApplicationArea = NPRRetail;
                }
                field("Entry No."; Rec."Entry No.")
                {
                    ToolTip = 'Specifies a unique entry number, assigned by the system to this record according to an automatically maintained number series.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
