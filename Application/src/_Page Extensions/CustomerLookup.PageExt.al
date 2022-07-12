pageextension 6014493 "NPR Customer Lookup" extends "Customer Lookup"
{
    Editable = true;

    layout
    {
        addfirst(content)
        {
            //Smart search is removed but this field cannot be deleted because of the AppSource validation rules.
            field("NPR Search"; Rec."No.")
            {
                Visible = false;
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s No.';
            }
        }
        
        addlast(Group)
        {
            field("NPR E-Mail"; Rec."E-Mail")
            {
                ApplicationArea = NPRRetail;
                ToolTip = 'Specifies the customer''s e-mail address. Clicking on the e-mail address opens an e-mail application.';
            }
        }

        modify(Group)
        {
            Editable = false;
        }
    }
}
