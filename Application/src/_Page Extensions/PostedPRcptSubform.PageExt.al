pageextension 6014410 "NPR Posted P.Rcpt. Subform" extends "Posted Purchase Rcpt. Subform"
{
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    actions
    {
        addafter(DocumentLineTracking)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea = All;
                ToolTip = 'Executes the Variety action';
            }
        }
    }
}

