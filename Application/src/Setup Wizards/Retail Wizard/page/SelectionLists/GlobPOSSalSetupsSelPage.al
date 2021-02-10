page 6059778 "NPR Glob. POS Sal. Setups Sel."
{
    Caption = 'Global POS Sales Setups';
    PageType = List;
    SourceTable = "NPR NpGp POS Sales Setup";
    SourceTableTemporary = true;
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
                field("Company Name"; "Company Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Company Name field';
                }
                field("Service Url"; "Service Url")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Service Url field';
                }
            }
        }
    }
    procedure SetRec(var TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    begin
        if TempGlobalPOSSalesSetup.FindSet() then
            repeat
                Rec.Copy(TempGlobalPOSSalesSetup);
                Rec.Insert();
            until TempGlobalPOSSalesSetup.Next() = 0;

        if Rec.FindSet() then;
    end;
}