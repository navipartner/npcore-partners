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
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Document Type"; Rec."Sales Document Type")
                {

                    ToolTip = 'Specifies the value of the Sales Document Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Sales Document No"; Rec."Sales Document No")
                {

                    ToolTip = 'Specifies the value of the Sales Document No field';
                    ApplicationArea = NPRRetail;

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
                field("POS Entry Reference Type"; Rec."POS Entry Reference Type")
                {

                    ToolTip = 'Specifies the value of the POS Entry Reference Type field';
                    ApplicationArea = NPRRetail;
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

