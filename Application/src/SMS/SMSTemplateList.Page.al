page 6059940 "NPR SMS Template List"
{
    Extensible = False;
    Caption = 'SMS Template List';
    CardPageID = "NPR SMS Template Card";
    Editable = false;
    PageType = List;
    SourceTable = "NPR SMS Template Header";
    UsageCategory = Lists;
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
                field("Table No."; Rec."Table No.")
                {

                    ToolTip = 'Specifies the value of the Table No. field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Caption"; Rec."Table Caption")
                {

                    ToolTip = 'Specifies the value of the Table Caption field';
                    ApplicationArea = NPRRetail;
                }
                field("Table Filters"; Rec."Table Filters".HasValue())
                {

                    Caption = 'Filters on Table';
                    ToolTip = 'Specifies the value of the Filters on Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Report ID"; Rec."Report ID")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Report ID field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }
}

