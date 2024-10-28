page 6151496 "NPR TM DeferRevenueReqDetail"
{
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR TM DeferRevenueReqDetail";
    Caption = 'Ticketing Revenue Recognition Details';
    Editable = false;
    Extensible = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(TokenID; Rec.TokenID)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Session Token ID field.';
                }
                field(ItemNo; Rec.ItemNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Item No. field.';
                }
                field(VariantCode; Rec.VariantCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Variant Code field.';
                    Visible = false;
                }
                field(AdmissionCode; Rec.AdmissionCode)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Admission Code field.';
                }
                field(EntryNo; Rec.EntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Entry No. field.';
                }
                field(DocumentNo; Rec.DocumentNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Document No. field.';
                }
                field(DocumentLineNo; Rec.DocumentLineNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Document Line No. field.';
                }
                field(TicketNo; Rec.TicketNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket No. field.';
                }
                field(TicketAccessEntryNo; Rec.TicketAccessEntryNo)
                {
                    ApplicationArea = NPRTicketEssential, NPRTicketAdvanced;
                    ToolTip = 'Specifies the value of the Ticket Access Entry No. field.';
                }
            }
        }
    }
}