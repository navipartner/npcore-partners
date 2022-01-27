page 6014699 "NPR Ean Box Setups Select"
{
    Extensible = False;
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
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View"; Rec."POS View")
                {

                    ToolTip = 'Specifies the value of the POS View field';
                    ApplicationArea = NPRRetail;
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
