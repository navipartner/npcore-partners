page 6151006 "NPR POS Entry Rel. Sales Doc."
{
    Caption = 'POS Entry Related Sales Documents';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    UsageCategory = Administration;
    ShowFilter = false;
    SourceTable = "NPR POS Entry Sales Doc. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Document Type"; "Sales Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Document Type field';
                }
                field("Sales Document No"; "Sales Document No")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Sales Document No field';

                    trigger OnAssistEdit()
                    begin
                        Rec.GetDocumentRecord(RecordVar);
                        PAGE.Run(Rec.GetCardpageID(), RecordVar);
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin
                        Rec.GetDocumentRecord(RecordVar);
                        PAGE.Run(Rec.GetCardpageID(), RecordVar);
                    end;
                }
                field("POS Entry Reference Type"; "POS Entry Reference Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS Entry Reference Type field';
                }
            }
        }
    }

    actions
    {
    }

    var
        RecordVar: Variant;
}

