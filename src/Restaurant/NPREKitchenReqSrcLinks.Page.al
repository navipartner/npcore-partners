page 6150697 "NPR NPRE Kitchen Req.Src.Links"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Request Source Links';
    Editable = false;
    PageType = List;
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
                }
                field("Source Document Type"; "Source Document Type")
                {
                    ApplicationArea = All;
                }
                field("Source Document Subtype"; "Source Document Subtype")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Document No."; "Source Document No.")
                {
                    ApplicationArea = All;
                }
                field("Source Document Line No."; "Source Document Line No.")
                {
                    ApplicationArea = All;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Quantity (Base)"; "Quantity (Base)")
                {
                    ApplicationArea = All;
                }
                field(Context; Context)
                {
                    ApplicationArea = All;
                }
                field("Serving Step"; "Serving Step")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Created Date-Time"; "Created Date-Time")
                {
                    ApplicationArea = All;
                }
                field("Entry No."; "Entry No.")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

