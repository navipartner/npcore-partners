page 6150731 "NPR POS Secure Methods"
{
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.

    Caption = 'POS Secure Methods';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "NPR POS Secure Method";
    SourceTableTemporary = true;

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
                field(Type; Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Type field';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        RunDiscovery();
    end;
}

