page 6150697 "NPRE Kitchen Req. Source Links"
{
    // NPR5.55/ALPO/20200708 CASE 382428 Kitchen Display System (KDS) for NP Restaurant (further enhancements)

    Caption = 'Kitchen Request Source Links';
    Editable = false;
    PageType = List;
    SourceTable = "NPRE Kitchen Req. Source Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Request No.";"Request No.")
                {
                }
                field("Source Document Type";"Source Document Type")
                {
                }
                field("Source Document Subtype";"Source Document Subtype")
                {
                    Visible = false;
                }
                field("Source Document No.";"Source Document No.")
                {
                }
                field("Source Document Line No.";"Source Document Line No.")
                {
                }
                field(Quantity;Quantity)
                {
                }
                field("Quantity (Base)";"Quantity (Base)")
                {
                }
                field(Context;Context)
                {
                }
                field("Serving Step";"Serving Step")
                {
                    Visible = false;
                }
                field("Created Date-Time";"Created Date-Time")
                {
                }
                field("Entry No.";"Entry No.")
                {
                }
            }
        }
    }

    actions
    {
    }
}

