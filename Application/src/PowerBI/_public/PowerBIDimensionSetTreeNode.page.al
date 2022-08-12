page 6184606 NPRPowerBIDimensionSetTreeNode
{
    PageType = List;
    Caption = 'PowerBI Dimension Set Tree Node';
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Dimension Set Tree Node";
    Editable = false;
    ObsoleteState = pending;
    ObsoleteReason = 'Page type changed to API';

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Parent Dimension Set ID"; Rec."Parent Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Parent Dimension Set ID field.';
                    ApplicationArea = All;
                }
                field("Dimension Set ID"; Rec."Dimension Set ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Set ID field.';
                    ApplicationArea = All;
                }
                field("Dimension Value ID"; Rec."Dimension Value ID")
                {
                    ToolTip = 'Specifies the value of the Dimension Value ID field.';
                    ApplicationArea = All;
                }
                field("In Use"; Rec."In Use")
                {
                    ToolTip = 'Specifies the value of the In Use field.';
                    ApplicationArea = All;
                }

            }
        }

    }


}