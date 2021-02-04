page 6150693 "NPR NPRE Color Table"
{
    Caption = 'Color Table';
    PageType = List;
    ApplicationArea = All;
    UsageCategory = Administration;
    SourceTable = "NPR NPRE Color Table";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                }
                field("RGB Color Code (Hex)"; Rec."RGB Color Code (Hex)")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.InitializeTable(false);
    end;
}