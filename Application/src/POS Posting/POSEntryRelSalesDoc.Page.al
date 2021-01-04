page 6151006 "NPR POS Entry Rel. Sales Doc."
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object
    // NPR5.52/TSA /20191015 CASE 372920 Added lookup handler code
    // NPR5.55/SARA/20200706 CASE 412905 Added 'POS Entry Reference Type'

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

                        //-NPR5.52 [372920]
                        Rec.GetDocumentRecord(RecordVar);
                        PAGE.Run(Rec.GetCardpageID(), RecordVar);
                        //+NPR5.52 [372920]
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        //-NPR5.52 [372920]
                        Rec.GetDocumentRecord(RecordVar);
                        PAGE.Run(Rec.GetCardpageID(), RecordVar);
                        //+NPR5.52 [372920]
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

