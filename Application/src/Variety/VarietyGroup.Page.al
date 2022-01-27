page 6059977 "NPR Variety Group"
{
    Extensible = False;
    // NPR5.43/NPKNAV/20180629  CASE 317108 Transport NPR5.43 - 29 June 2018

    Caption = 'Variety Group';
    PageType = List;
    SourceTable = "NPR Variety Group";
    UsageCategory = Administration;
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
                field("Cross Variety No."; Rec."Cross Variety No.")
                {

                    ToolTip = 'Specifies the value of the Cross Variety No. field';
                    ApplicationArea = NPRRetail;
                }
                field("No. Series"; Rec."No. Series")
                {

                    ToolTip = 'Specifies the value of the No. Series field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1"; Rec."Variety 1")
                {

                    ToolTip = 'Specifies the value of the Variety 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 1 Table"; Rec."Variety 1 Table")
                {

                    ToolTip = 'Specifies the value of the Variety 1 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 1 Table"; Rec."Create Copy of Variety 1 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 1 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Copy Naming Variety 1"; Rec."Copy Naming Variety 1")
                {

                    ToolTip = 'Specifies the value of the Copy Naming Variety 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2"; Rec."Variety 2")
                {

                    ToolTip = 'Specifies the value of the Variety 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 2 Table"; Rec."Variety 2 Table")
                {

                    ToolTip = 'Specifies the value of the Variety 2 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 2 Table"; Rec."Create Copy of Variety 2 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 2 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Copy Naming Variety 2"; Rec."Copy Naming Variety 2")
                {

                    ToolTip = 'Specifies the value of the Copy Naming Variety 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3"; Rec."Variety 3")
                {

                    ToolTip = 'Specifies the value of the Variety 3 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 3 Table"; Rec."Variety 3 Table")
                {

                    ToolTip = 'Specifies the value of the Variety 3 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 3 Table"; Rec."Create Copy of Variety 3 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 3 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Copy Naming Variety 3"; Rec."Copy Naming Variety 3")
                {

                    ToolTip = 'Specifies the value of the Copy Naming Variety 3 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4"; Rec."Variety 4")
                {

                    ToolTip = 'Specifies the value of the Variety 4 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variety 4 Table"; Rec."Variety 4 Table")
                {

                    ToolTip = 'Specifies the value of the Variety 4 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Create Copy of Variety 4 Table"; Rec."Create Copy of Variety 4 Table")
                {

                    ToolTip = 'Specifies the value of the Create Copy of Variety 4 Table field';
                    ApplicationArea = NPRRetail;
                }
                field("Copy Naming Variety 4"; Rec."Copy Naming Variety 4")
                {

                    ToolTip = 'Specifies the value of the Copy Naming Variety 4 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Part 1"; Rec."Variant Code Part 1")
                {

                    ToolTip = 'Specifies the value of the Variant Code Part 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Part 1 Length"; Rec."Variant Code Part 1 Length")
                {

                    ToolTip = 'Specifies the value of the Variant Code Part 1 Length field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Seperator 1"; Rec."Variant Code Seperator 1")
                {

                    ToolTip = 'Specifies the value of the Variant Code Seperator 1 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Part 2"; Rec."Variant Code Part 2")
                {

                    ToolTip = 'Specifies the value of the Variant Code Part 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Part 2 Length"; Rec."Variant Code Part 2 Length")
                {

                    ToolTip = 'Specifies the value of the Variant Code Part 2 Length field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Seperator 2"; Rec."Variant Code Seperator 2")
                {

                    ToolTip = 'Specifies the value of the Variant Code Seperator 2 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Part 3"; Rec."Variant Code Part 3")
                {

                    ToolTip = 'Specifies the value of the Variant Code Part 3 field';
                    ApplicationArea = NPRRetail;
                }
                field("Variant Code Part 3 Length"; Rec."Variant Code Part 3 Length")
                {

                    ToolTip = 'Specifies the value of the Variant Code Part 3 Length field';
                    ApplicationArea = NPRRetail;
                }
                field(GetVariantCodeExample; Rec.GetVariantCodeExample())
                {

                    Caption = 'Example';
                    ToolTip = 'Specifies the value of the Example field';
                    ApplicationArea = NPRRetail;
                }
            }
        }
    }

    actions
    {
    }
}

