page 6059781 "NPR POS Stores Select"
{
    Caption = 'Pos Store List';
    PageType = List;
    SourceTable = "NPR POS Store";
    SourceTableTemporary = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Name; Rec.Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Name field';
                }
                field("Post Code"; Rec."Post Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Post Code field';
                }
                field(City; Rec.City)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the City field';
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 1 Code field';
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Global Dimension 2 Code field';
                }
                field("Default POS Posting Setup"; Rec."Default POS Posting Setup")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Default POS Posting Setup field';
                }
                field("Tax Area Code"; Rec."Tax Area Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Area Code field';
                }
                field("Tax Liable"; Rec."Tax Liable")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Tax Liable field';
                }
            }
        }
    }

    procedure SetRec(var TempPOSStore: Record "NPR POS Store")
    begin
        Rec.DeleteAll();
        if TempPOSStore.FindSet() then
            repeat
                Rec.Copy(TempPOSStore);
                Rec.Insert();
            until TempPOSStore.Next() = 0;
    end;
}