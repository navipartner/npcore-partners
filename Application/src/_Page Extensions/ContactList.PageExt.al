pageextension 6014453 "NPR Contact List" extends "Contact List"
{
    actions
    {
        addafter(Statistics)
        {
            action("NPR POS Entries")
            {
                Caption = 'POS Entries';
                Image = Entries;

                ToolTip = 'Executes the POS Entries action';
                ApplicationArea = NPRRetail;
            }
        }
    }
}