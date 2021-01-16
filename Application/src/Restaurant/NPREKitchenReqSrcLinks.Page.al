page 6150697 "NPR NPRE Kitchen Req.Src.Links"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

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
                field("Request No."; "Request No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Request No. field';
                }
                field("Source Document Type"; "Source Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Document Type field';
                }
                field("Source Document Subtype"; "Source Document Subtype")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Source Document Subtype field';
                }
                field("Source Document No."; "Source Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Document No. field';
                }
                field("Source Document Line No."; "Source Document Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Source Document Line No. field';
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity field';
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Quantity (Base) field';
                }
                field(Context; Context)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Context field';
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                    Visible = false;
                    ToolTip = 'Specifies the value of the Serving Step field';
                }
                field("Created Date-Time"; "Created Date-Time")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Created Date-Time field';
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Entry No. field';
                }
            }
        }
    }

    actions
    {
    }
}

