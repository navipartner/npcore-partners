page 6014619 "NPR Tax Free CC Param."
{
    Extensible = False;

    Caption = 'Custom Cash Parameters';
    PageType = Card;
    SourceTable = "NPR Tax Free CC Param.";
    UsageCategory = None;
    InsertAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(content)
        {
            group(General)
            {
                field("Shop ID"; Rec."Shop ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop ID field';
                }
                field("Shop User Name"; Rec."Shop User Name")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop User Name field';
                }
                field("Shop Password"; Rec."Shop Password")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Shop Password field';
                }
                field("X Auth Token"; Rec."X Auth Token")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the X Auth Token field';
                }
            }
            group(Restrictions)
            {
                field("Minimal Amount"; Rec."Minimal Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Minimal Amount field';
                }
                field("Maximal Amount"; Rec."Maximal Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the value of the Maximal Amount field';
                }
            }
        }
    }

}
