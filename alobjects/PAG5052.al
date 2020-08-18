pageextension 6014453 pageextension6014453 extends "Contact List" 
{
    // NPR5.23/BHR/20160329 CASE 222711 Added PhoneLookup Action.
    // NPR5.29/TJ /20170125 CASE 263507 Moved code from PhoneLookup action to a subscriber and also renamed that action from default to PhoneLookup
    // NPR5.38/BR /20171117 CASE 295255 Added Action POS Entries
    actions
    {
        addafter(Statistics)
        {
            action("POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;
            }
        }
        addafter(NewSalesQuote)
        {
            action(PhoneLookup)
            {
                Caption = 'PhoneLookup';
                Image = ImportLog;
            }
        }
    }
}

