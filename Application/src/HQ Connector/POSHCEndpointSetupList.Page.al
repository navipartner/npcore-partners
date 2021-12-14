page 6059843 "NPR POS HC Endpoint Setup List"
{
    Caption = 'Endpoint Setup List';
    CardPageId = "NPR POS HC Endpoint Setup";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS HC Endpoint Setup";
    ApplicationArea = NPRRetail;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Code"; Rec.Code)
                {

                    ToolTip = 'Specifies the value of the Code field';
                    ApplicationArea = NPRRetail;
                }
                field(Active; Rec.Active)
                {

                    ToolTip = 'Specifies the value of the Active field';
                    ApplicationArea = NPRRetail;
                }
                field(Description; Rec.Description)
                {

                    ToolTip = 'Specifies the value of the Description field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

}