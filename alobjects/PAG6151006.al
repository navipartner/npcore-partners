page 6151006 "POS Entry Related Sales Doc."
{
    // NPR5.50/MMV /20190417 CASE 300557 Created object
    // NPR5.52/TSA /20191015 CASE 372920 Added lookup handler code

    Caption = 'POS Entry Related Sales Documents';
    DelayedInsert = false;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    LinksAllowed = false;
    ModifyAllowed = false;
    MultipleNewLines = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = "POS Entry Sales Doc. Link";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Sales Document Type";"Sales Document Type")
                {
                }
                field("Sales Document No";"Sales Document No")
                {

                    trigger OnAssistEdit()
                    begin

                        //-NPR5.52 [372920]
                        Rec.GetDocumentRecord (RecordVar);
                        PAGE.Run (Rec.GetCardpageID(), RecordVar);
                        //+NPR5.52 [372920]
                    end;

                    trigger OnLookup(var Text: Text): Boolean
                    begin

                        //-NPR5.52 [372920]
                        Rec.GetDocumentRecord (RecordVar);
                        PAGE.Run (Rec.GetCardpageID(), RecordVar);
                        //+NPR5.52 [372920]
                    end;
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

