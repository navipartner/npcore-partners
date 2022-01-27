page 6150638 "NPR POS Posting Profiles"
{
    Extensible = False;
    Caption = 'POS Posting Profiles';
    CardPageID = "NPR POS Post. Profile Card";
    Editable = false;
    PageType = List;
    UsageCategory = Administration;
    SourceTable = "NPR POS Posting Profile";
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
                field("Max. POS Posting Diff. (LCY)"; Rec."Max. POS Posting Diff. (LCY)")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Max. POS Posting Diff. (LCY) field';
                    ApplicationArea = NPRRetail;
                }
                field("POS Posting Diff. Account"; Rec."POS Posting Diff. Account")
                {

                    Visible = false;
                    ToolTip = 'Specifies the value of the Differences Account field';
                    ApplicationArea = NPRRetail;
                }
                field("Source Code"; Rec."Source Code")
                {

                    ToolTip = 'Specifies the value of the Source Code field';
                    ApplicationArea = NPRRetail;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {

                    ToolTip = 'Specifies the value of the Gen. Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("VAT Bus. Posting Group"; Rec."VAT Bus. Posting Group")
                {

                    ToolTip = 'Specifies the value of the VAT Bus. Posting Group field';
                    ApplicationArea = NPRRetail;
                }
                field("Journal Template Name"; Rec."Journal Template Name")
                {
                    ToolTip = 'Specifies the value of the Journal Template Name which will be assigned to General Journal Lines in the POS Posting activity.';
                    ApplicationArea = NPRRetail;
                    Description = 'Initially created for BE localization';
                }
            }
        }
    }

    actions
    {
    }
}

