﻿page 6059778 "NPR Glob. POS Sal. Setups Sel."
{
    Extensible = False;
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
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Company Name"; Rec."Company Name")
                {

                    ToolTip = 'Specifies the value of the Company Name field';
                    ApplicationArea = NPRRetail;
                }
                field("Service Url"; Rec."Service Url")
                {

                    ToolTip = 'Specifies the value of the Service Url field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    internal procedure SetRec(var TempGlobalPOSSalesSetup: Record "NPR NpGp POS Sales Setup")
    begin
        if TempGlobalPOSSalesSetup.FindSet() then
            repeat
                Rec.Copy(TempGlobalPOSSalesSetup);
                Rec.Insert();
            until TempGlobalPOSSalesSetup.Next() = 0;

        if Rec.FindSet() then;
    end;
}
