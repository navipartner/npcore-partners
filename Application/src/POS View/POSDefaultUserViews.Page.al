page 6150751 "NPR POS Default User Views"
{
    Caption = 'POS Default User Views';
    PageType = List;
    SourceTable = "NPR POS Default User View";
    UsageCategory = Administration;
    ApplicationArea = NPRRetail;


    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Type; Rec.Type)
                {

                    ToolTip = 'Specifies the value of the Type field';
                    ApplicationArea = NPRRetail;
                }
                field("Register No."; Rec."Register No.")
                {

                    ToolTip = 'Specifies the value of the POS Unit No. field';
                    ApplicationArea = NPRRetail;
                }
                field("User Name"; Rec."User Name")
                {

                    ToolTip = 'Specifies the value of the User Name field';
                    ApplicationArea = NPRRetail;
                }
                field("POS View Code"; Rec."POS View Code")
                {

                    ToolTip = 'Specifies the value of the POS View Code field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}