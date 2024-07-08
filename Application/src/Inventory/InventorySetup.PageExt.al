pageextension 6014406 "NPR Inventory Setup" extends "Inventory Setup"
{
    layout
    {
        addlast(content)
        {
            group("NPR Scanner Setup")
            {
                Caption = 'Scanner Setup';

                field("NPR Scanner Provider"; Rec."NPR Scanner Provider")
                {
                    ToolTip = 'Specifies from which scanner the file for import is generated.';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}