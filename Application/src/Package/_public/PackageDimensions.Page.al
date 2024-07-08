page 6059910 "NPR Package Dimensions"
{
    Extensible = true;
    ApplicationArea = NPRRetail;
    Caption = 'Package Dimensions';
    PageType = List;
    SourceTable = "NPR Package Dimension";
    UsageCategory = Lists;
    AutoSplitKey = true;

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Package Code"; Rec."Package Code")
                {
                    ToolTip = 'Specifies the Package Code.';
                    ApplicationArea = NPRRetail;
                }
                field(Quantity; Rec.Quantity)
                {
                    ToolTip = 'Specifies the Quantity of Packages.';
                    ApplicationArea = NPRRetail;
                }
                field(Weight; Rec.Weight_KG)
                {
                    ToolTip = 'Specifies the Weight of Package.';
                    ApplicationArea = NPRRetail;
                }
                field(Width; Rec.Width)
                {
                    ToolTip = 'Specifies the Width of Package in cm.';
                    ApplicationArea = NPRRetail;
                }
                field(Length; Rec.Length)
                {
                    ToolTip = 'Specifies the Length of Package in cm.';
                    ApplicationArea = NPRRetail;
                }
                field(Height; Rec.Height)
                {
                    ToolTip = 'Specifies the Height of Package in cm.';
                    ApplicationArea = NPRRetail;
                }
                field(Volume; Rec.Volume)
                {
                    ToolTip = 'Specifies the value of the  Volume cubic metres  field.';
                    ApplicationArea = NPRRetail;
                }
                field(running_metre; Rec.running_metre)
                {
                    ToolTip = 'Specifies the value of the running_metre field.';
                    ApplicationArea = NPRRetail;
                }

                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Package Description field.';
                    ApplicationArea = NPRRetail;
                }

                field("Package Amount Incl. VAT"; Rec."Package Amount Incl. VAT")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Package Amount Incl. VAT field.';
                }
                field("Package Amount Currency Code"; Rec."Package Amount Currency Code")
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Package Amount Currency Code field.';
                }
                field(Items; Rec.Items)
                {
                    ApplicationArea = NPRRetail;
                    ToolTip = 'Specifies the value of the Items field.';
                }

            }
        }

    }
    trigger OnClosePage()
    var
        PackageDimension: Record "NPR Package Dimension";
    begin
        PackageDimension.Reset();
        PackageDimension.SetRange("Document Type", Rec."Document Type");
        PackageDimension.SetRange("Document No.", Rec."Document No.");
        PackageDimension.SetFilter(Quantity, '0');
        if PackageDimension.FindFirst() then
            Message(CheckQty);
    end;

    var
        CheckQty: label 'Please note there are lines with Quantity 0. these will not be sent to Posted Documents. ';
}
