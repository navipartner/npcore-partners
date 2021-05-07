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
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("RGB Color Code (Hex)"; Rec."RGB Color Code (Hex)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the RGB Color Code (Hex) field';
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.InitializeTable(false);
    end;
}