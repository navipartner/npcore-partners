pageextension 6014406 "NPR Posted S.Invoice Subform" extends "Posted Sales Invoice Subform"
{
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    actions
    {
        addafter(DocAttach)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
                ApplicationArea=All;
            }
        }
    }
}

