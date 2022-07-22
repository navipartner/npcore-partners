page 6059910 "NPR Package Dimensions"
{
    Extensible = true;
    ApplicationArea = All;
    Caption = 'Package Dimensions';
    PageType = List;
    SourceTable = "NPR Package Dimension";
    UsageCategory = Lists;
    DelayedInsert = true;
    AutoSplitKey = true;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field("Package Code"; Rec."Package Code")
                {
                    ToolTip = 'Specifies the Package Code.';
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the Quantity of Packages.';
                    ApplicationArea = All;
                }
                field(Weight; Rec.Weight_KG)
                {
                    ToolTip = 'Specifies the Weight of Package.';
                    ApplicationArea = All;
                }
                field(Width; Rec.Width)
                {
                    ToolTip = 'Specifies the Width of Package in cm.';
                    ApplicationArea = All;
                }
                field(Length; Rec.Length)
                {
                    ToolTip = 'Specifies the Length of Package in cm.';
                    ApplicationArea = All;
                }
                field(Height; Rec.Height)
                {
                    ToolTip = 'Specifies the Height of Package in cm.';
                    ApplicationArea = All;
                }
                field(Volume; Rec.Volume)
                {
                    ToolTip = 'Specifies the value of the  Volume cubic metres  field.';
                    ApplicationArea = All;
                }
                field(running_metre; Rec.running_metre)
                {
                    ToolTip = 'Specifies the value of the running_metre field.';
                    ApplicationArea = All;
                }

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Package Description field.';
                    ApplicationArea = All;
                }
            }
        }
    }
}
