page 6150731 "NPR POS Secure Methods"
{
    Extensible = False;
    // NPR5.43/VB  /20180611  CASE 314603 Implemented secure method behavior functionality.

    Caption = 'POS Secure Methods';
    PageType = List;
    UsageCategory = Administration;

    SourceTable = "NPR POS Secure Method";
    SourceTableTemporary = true;
    ApplicationArea = NPRRetail;

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
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        Rec.RunDiscovery();
    end;
}

