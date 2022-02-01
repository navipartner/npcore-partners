pageextension 6014491 "NPR Sales Cr. Memo Subform" extends "Sales Cr. Memo Subform"
{
    actions
    {
        addafter(DeferralSchedule)
        {
            action("NPR Variety")
            {
                Caption = 'Variety';
                Image = ItemVariant;
                ShortCutKey = 'Ctrl+Alt+V';

                ToolTip = 'View the variety matrix for the item used on the Sales Credit Memo Line.';
                ApplicationArea = NPRRetail;

                trigger OnAction()
                var
                    VarietyWrapper: Codeunit "NPR Variety Wrapper";
                begin
                    VarietyWrapper.SalesLineShowVariety(Rec, 0);
                end;
            }
        }
    }
}