page 6014439 "NPR POS Unit Selection"
{
    Extensible = False;
    PageType = List;
    UsageCategory = None;
    SourceTable = "NPR POS Unit";
    Editable = false;
    Caption = 'POS Unit Selection';
    ShowFilter = false;
    DeleteAllowed = false;
    ModifyAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;

    layout
    {
        area(Content)
        {
            group(Instructions)
            {
                Caption = '';
                InstructionalText = 'This appears to be the first time you are using the POS. Select a POS Unit for your user';
            }
            repeater(Repeater)
            {
                field("No."; Rec."No.")
                {

                    ToolTip = 'Specifies the value of the No. field';
                    ApplicationArea = NPRRetail;
                }
                field(Name; Rec.Name)
                {

                    ToolTip = 'Specifies the value of the Name field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {

                    ToolTip = 'Specifies the value of the POS Store Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}
