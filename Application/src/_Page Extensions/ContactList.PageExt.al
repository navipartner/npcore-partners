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

                trigger OnAction()
                var
                    POSEntryNavigation: Codeunit "NPR POS Entry Navigation";
                begin
                    POSEntryNavigation.OpenPOSEntryListFromContact(Rec);
                end;
            }
        }
    }
}