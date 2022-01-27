page 6150693 "NPR NPRE Color Table"
{
    Extensible = False;
    Caption = 'Color Table';
    PageType = List;

    UsageCategory = Administration;
    SourceTable = "NPR NPRE Color Table";
    ApplicationArea = NPRRetail;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("RGB Color Code (Hex)"; Rec."RGB Color Code (Hex)")
                {

                    ToolTip = 'Specifies the value of the RGB Color Code (Hex) field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    trigger OnInit()
    begin
        Rec.InitializeTable(false);
    end;
}
