page 6014439 "NPR POS Unit Selection"
{
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
                    ApplicationArea = All;
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                }
                field("POS Store Code"; Rec."POS Store Code")
                {
                    ApplicationArea = All;
                }
            }
        }
    }
}