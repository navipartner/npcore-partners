page 6150635 "NPR POS View Profiles"
{
    Caption = 'POS View Profiles';
    CardPageID = "NPR POS View Profile Card";
    PageType = List;
    UsageCategory = Administration;

    Editable = false;
    SourceTable = "NPR POS View Profile";
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
                field("Client Decimal Separator"; Rec."Client Decimal Separator")
                {

                    ToolTip = 'Specifies the value of the Client Decimal Separator field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Thousands Separator"; Rec."Client Thousands Separator")
                {

                    ToolTip = 'Specifies the value of the Client Thousands Separator field';
                    ApplicationArea = NPRRetail;
                }
                field("Client Date Separator"; Rec."Client Date Separator")
                {

                    ToolTip = 'Specifies the value of the Client Date Separator field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Theme Code"; Rec."POS Theme Code")
                {

                    ToolTip = 'Specifies the value of the POS Theme Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Line Order on Screen"; Rec."Line Order on Screen")
                {

                    ToolTip = 'Specifies the value of the Line Order on Screen field';
                    ApplicationArea = NPRRetail;
                }
                field("Initial Sales View"; Rec."Initial Sales View")
                {

                    ToolTip = 'Specifies the value of the Initial Sales View field';
                    ApplicationArea = NPRRetail;
                }
                field("After End-of-Sale View"; Rec."After End-of-Sale View")
                {

                    ToolTip = 'Specifies the value of the After End-of-Sale View field';
                    ApplicationArea = NPRRetail;
                }
                field("POS - Show discount fields"; Rec."POS - Show discount fields")
                {

                    ToolTip = 'Specifies the value of the Show Discount field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
    actions
    {
        area(navigation)
        {
            action("&Picture")
            {
                Caption = '&Picture';
                Image = Picture;
                RunObject = Page "NPR POS View Picture";
                RunPageLink = Code = FIELD(Code);
                ToolTip = 'View or add a picture, for example, the company''s logo.';
                ApplicationArea = NPRRetail;
            }
        }
    }
}