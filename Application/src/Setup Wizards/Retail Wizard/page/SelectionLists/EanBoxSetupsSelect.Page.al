page 6014699 "NPR Ean Box Setups Select"
{
    Caption = 'Ean Box Setups';
    PageType = List;
    SourceTable = "NPR Ean Box Setup";
    SourceTableTemporary = true;
    DelayedInsert = true;
    UsageCategory = None;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Code"; Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Code field';
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Description field';
                }
                field("POS View"; "POS View")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the POS View field';
                }
            }
        }
    }

    procedure SetRec(var TempEanBoxSetups: Record "NPR Ean Box Setup")
    begin
        if TempEanBoxSetups.FindSet() then
            repeat
                Rec.Copy(TempEanBoxSetups);
                Rec.Insert();
            until TempEanBoxSetups.Next() = 0;

        if Rec.FindSet() then;
    end;
}