pageextension 70000073 pageextension70000073 extends "Posted Purch. Invoice Subform" 
{
    // VRT1.20/JDH /20150304 CASE 201022 Variety Action Added to raise Event
    actions
    {
        addafter(DocAttach)
        {
            action(Variety)
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';
            }
        }
    }
}

