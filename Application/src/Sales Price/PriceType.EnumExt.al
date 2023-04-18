enumextension 6014406 "NPR Price Type" extends "Price Source Type"
{

    value(6014400; "NPR POS Price Profile")
    {
        Caption = 'POS Price Profile';
        Implementation = "Price Source" = "NPR Price Source - Profile", "Price Source Group" = "Price Source Group - Customer";
    }
}
