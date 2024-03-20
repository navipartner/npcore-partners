page 6184501 "NPR NPRE Kitchen Req. Modif."
{
    Extensible = False;
    Caption = 'Kitchen Request Modifications';
    Editable = false;
    PageType = List;
    SourceTable = "NPR NPRE Kitchen Req. Modif.";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Request No."; Rec."Request No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the request Id this modifications applies to.';
                    ApplicationArea = NPRRetail;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ToolTip = 'Specifies the type of this request modification line.';
                    ApplicationArea = NPRRetail;
                }
                field("No."; Rec."No.")
                {
                    Visible = false;
                    ToolTip = 'Specifies the item number specifed on this request modification line.';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    Visible = false;
                    ToolTip = 'Specifies the variant code of the item specified on this request modification line.';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the description of this request modification line.';
                    ApplicationArea = NPRRetail;
                }
                field("Description 2"; Rec."Description 2")
                {
                    ToolTip = 'Specifies the second description of this request modification line.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the quantity of the item specified on this request modification line.';
                    ApplicationArea = NPRRetail;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ToolTip = 'Specifies the unit of measure code of the quantity.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
